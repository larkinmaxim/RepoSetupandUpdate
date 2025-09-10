# Component Reference Documentation

## Overview

This document provides detailed technical specifications for all components in the GitLab Repository Setup and Management system, including internal architecture, data flows, and extensibility points.

## Table of Contents

1. [System Architecture](#system-architecture)
2. [Component Specifications](#component-specifications)
3. [Data Flow Diagrams](#data-flow-diagrams)
4. [Extension Points](#extension-points)
5. [Performance Considerations](#performance-considerations)
6. [Security Model](#security-model)

## System Architecture

### High-Level Architecture

```
GitLab Repository Management System
┌─────────────────────────────────────────────────────────┐
│                    User Interface Layer                │
├─────────────────────────────────────────────────────────┤
│  STEP1_sshKeygen.ps1  │  STEP2_testConnection.ps1      │
│  STEP3_setup-int.ps1  │  STEP4_setup-test.ps1          │
│  STEP5_setup-prod.ps1 │  DailyUpdate.ps1               │
├─────────────────────────────────────────────────────────┤
│                   Business Logic Layer                 │
├─────────────────────────────────────────────────────────┤
│  SSH Management       │  Git Operations                 │
│  Progress Tracking    │  Error Handling                 │
│  Configuration Mgmt   │  Repository Management          │
├─────────────────────────────────────────────────────────┤
│                   Integration Layer                    │
├─────────────────────────────────────────────────────────┤
│  PowerShell Runtime   │  Git CLI                        │
│  Windows SSH Client   │  TortoiseGit Integration        │
├─────────────────────────────────────────────────────────┤
│                    External Systems                    │
├─────────────────────────────────────────────────────────┤
│  GitLab Server        │  File System                    │
│  Network/VPN          │  Windows Security               │
└─────────────────────────────────────────────────────────┘
```

### Component Interaction Diagram

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    User     │───▶│   Scripts   │───▶│  Git CLI    │
└─────────────┘    └─────────────┘    └─────────────┘
                           │                   │
                           ▼                   ▼
                   ┌─────────────┐    ┌─────────────┐
                   │  File Sys   │    │   GitLab    │
                   └─────────────┘    └─────────────┘
                           ▲                   ▲
                           │                   │
                   ┌─────────────┐    ┌─────────────┐
                   │ SSH Keys    │    │  Network    │
                   └─────────────┘    └─────────────┘
```

## Component Specifications

### 1. SSH Key Management Component

**Files**: `STEP1_sshKeygen.ps1`  
**Purpose**: Handles SSH key generation, validation, and management.

#### Internal Architecture

```powershell
SSH Key Management Component
├── Input Validation Module
│   ├── Email Format Validation
│   ├── Parameter Validation
│   └── Environment Checks
├── Key Generation Engine
│   ├── Primary Generation Method (Batch)
│   ├── Fallback Generation Method (Direct)
│   └── Error Recovery Logic
├── File System Operations
│   ├── Directory Creation
│   ├── Key Storage Management
│   └── Permission Setting
└── Output Formatting
    ├── Public Key Display
    ├── Instruction Generation
    └── Status Reporting
```

#### Key Generation Algorithm

```powershell
# Primary method using batch file wrapper
function Generate-SSHKeyPrimary {
    param([string]$Email, [string]$KeyPath)
    
    $batchContent = @"
@echo off
ssh-keygen -t rsa -b 4096 -C "$Email" -f "$KeyPath" -q -N ""
echo Exit code: %ERRORLEVEL%
"@
    
    $tempBatch = "$env:TEMP\ssh_keygen_$(Get-Random).bat"
    $batchContent | Out-File -FilePath $tempBatch -Encoding ASCII
    
    try {
        $process = Start-Process -FilePath $tempBatch -Wait -PassThru -NoNewWindow
        return $process.ExitCode
    } finally {
        Remove-Item $tempBatch -Force -ErrorAction SilentlyContinue
    }
}

# Fallback method with direct execution
function Generate-SSHKeyFallback {
    param([string]$Email, [string]$KeyPath)
    
    $arguments = @("-t", "rsa", "-b", "4096", "-C", $Email, "-f", $KeyPath, "-q")
    $process = Start-Process -FilePath "ssh-keygen" -ArgumentList $arguments -Wait -PassThru -NoNewWindow
    return $process.ExitCode
}
```

#### Configuration Parameters

| Parameter | Type | Validation | Default | Description |
|-----------|------|------------|---------|-------------|
| `Email` | String | Regex pattern | "" | Email for key comment |
| `Force` | Switch | Boolean | False | Overwrite existing keys |
| `$DEFAULT_EMAIL` | String | Email format | "" | Script-level default |

### 2. Connection Testing Component

**Files**: `STEP2_testGitLabConnection.ps1`  
**Purpose**: Validates SSH connectivity and authentication to GitLab.

#### Testing Algorithm Flow

```
Start
  │
  ▼
Check SSH Key Files Exist
  │
  ├─No──▶ [ERROR] SSH Key Missing
  │
  ▼
Display Key Information
  │
  ▼
Check/Add Host Key
  │
  ▼
Execute SSH Test Command
  │
  ├─Success──▶ [SUCCESS] Connection Working
  ├─Auth Fail─▶ [ERROR] Authentication Failed
  ├─Network───▶ [ERROR] Connection Failed
  └─Other────▶ [WARNING] Unknown Result
```

#### Host Key Management

```powershell
function Manage-GitLabHostKey {
    param([string]$HostName = "gitlab.office.transporeon.com")
    
    $knownHostsPath = "$env:USERPROFILE\.ssh\known_hosts"
    
    # Ensure known_hosts exists
    if (-not (Test-Path $knownHostsPath)) {
        New-Item -ItemType File -Path $knownHostsPath -Force | Out-Null
    }
    
    # Check if host key already exists
    $existingKey = Get-Content $knownHostsPath -ErrorAction SilentlyContinue | Where-Object { $_ -like "*$HostName*" }
    
    if (-not $existingKey) {
        # Retrieve and add host key
        $hostKey = ssh-keyscan -t rsa $HostName 2>$null
        if ($hostKey) {
            $hostKey | Out-File -FilePath $knownHostsPath -Append -Encoding UTF8
            return $true
        }
    }
    
    return $false
}
```

### 3. Repository Setup Components

**Files**: `STEP3_setup-int-repo.ps1`, `STEP4_setup-test-repo.ps1`, `STEP5_setup-prod-repo.ps1`  
**Purpose**: Clone and configure GitLab repositories for different environments.

#### Setup Process Architecture

```
Repository Setup Process
├── Parameter Validation
│   ├── Base Directory Resolution
│   ├── Target Path Construction
│   └── Parameter Sanitization
├── User Confirmation
│   ├── Configuration Display
│   ├── Confirmation Prompt
│   └── Cancellation Handling
├── Directory Management
│   ├── Existing Directory Detection
│   ├── Cleanup Options
│   └── Directory Creation
├── Git Operations
│   ├── Repository Cloning
│   ├── Progress Monitoring
│   └── Error Recovery
├── Repository Configuration
│   ├── Git Settings Application
│   ├── Remote URL Configuration
│   └── TortoiseGit Integration
└── Completion Reporting
    ├── Success Confirmation
    ├── Status Summary
    └── Next Steps Guidance
```

#### Git Configuration Template

```powershell
function Configure-Repository {
    param([string]$RepositoryPath)
    
    Push-Location $RepositoryPath
    try {
        # Core Git settings
        git config pull.rebase false          # Use merge for pulls
        git config push.default simple        # Push current branch only
        
        # Windows-specific settings
        git config core.autocrlf true         # Handle CRLF conversion
        git config core.filemode false        # Ignore file mode changes
        
        # TortoiseGit integration
        git config gui.recentrepo $RepositoryPath
        
        # Performance optimizations
        git config core.preloadindex true     # Preload index for performance
        git config core.fscache true          # Enable file system cache
        
        # SSH configuration
        git remote set-url origin "git@gitlab.office.transporeon.com:Development/portfolio.git"
        
    } finally {
        Pop-Location
    }
}
```

### 4. Daily Update Component

**Files**: `DailyUpdate.ps1`  
**Purpose**: Automated multi-repository update system with progress tracking.

#### Update Process Architecture

```
Daily Update System
├── Configuration Management
│   ├── Repository Config Loading
│   ├── Version Detection
│   └── Environment Validation
├── Progress Tracking System
│   ├── Overall Progress (Id: 2)
│   ├── Individual Repo Progress (Id: 3)
│   └── Cleanup Progress (Id: 4)
├── Version Management
│   ├── Remote Branch Fetching
│   ├── Version Extraction
│   └── Latest Version Selection
├── Repository Update Engine
│   ├── Directory Navigation
│   ├── Remote Synchronization
│   ├── Branch Management
│   └── Force Update Operations
└── Completion System
    ├── Progress Cleanup
    ├── Summary Generation
    └── Auto-close Timer
```

#### Version Detection Algorithm

```powershell
function Get-LatestVersionNumber {
    # Fetch all remote branches
    Invoke-GitCommand "git fetch origin"
    
    # Get branch list
    $branches = git branch -r | ForEach-Object { $_.ToString().Trim() }
    
    # Extract version numbers using regex
    $versionObjects = $branches | ForEach-Object {
        if ($_ -match "origin/(\d+\.\d+)/") {
            [PSCustomObject]@{
                Version = [System.Version]$matches[1]
                Branch = $_
            }
        }
    } | Where-Object { $_.Version -ne $null }
    
    # Sort by version and return latest
    $latestVersion = $versionObjects | 
        Sort-Object Version -Unique | 
        Select-Object -Last 1
    
    return $latestVersion.Version.ToString()
}
```

#### Repository Update State Machine

```
Repository Update States
┌─────────────┐
│    Start    │
└─────┬───────┘
      │
      ▼
┌─────────────┐
│  Navigate   │──Error──▶ [FAIL]
└─────┬───────┘
      │
      ▼
┌─────────────┐
│    Fetch    │──Error──▶ [FAIL]
└─────┬───────┘
      │
      ▼
┌─────────────┐
│   Branch    │──Create──▶ [NEW BRANCH]
│   Check     │
└─────┬───────┘
      │ Exists
      ▼
┌─────────────┐
│   Reset     │──Error──▶ [FAIL]
│    Hard     │
└─────┬───────┘
      │
      ▼
┌─────────────┐
│  Complete   │
└─────────────┘
```

## Data Flow Diagrams

### SSH Key Generation Data Flow

```
User Input (Email) ──▶ Validation ──▶ Key Generation ──▶ File Storage
                                           │
                                           ▼
                                    Public Key Display
                                           │
                                           ▼
                                    User Instructions
```

### Repository Update Data Flow

```
Configuration ──▶ Version Detection ──▶ Repository Loop ──▶ Progress Updates
     │                    │                    │                    │
     ▼                    ▼                    ▼                    ▼
Repository List ──▶ Branch Analysis ──▶ Git Operations ──▶ Status Reporting
```

### Error Handling Data Flow

```
Operation ──Error──▶ Error Classification ──▶ User Guidance ──▶ Exit/Retry
   │                        │                      │
   │                        ▼                      ▼
   │                 Log Recording            Recovery Options
   │                        │                      │
   └──Success──▶ Continue Process ◀────────────────┘
```

## Extension Points

### 1. Custom Repository Configuration

```powershell
# Extension point: Custom repository definitions
interface IRepositoryConfig {
    [string] $FolderPath
    [string] $BranchSuffix
    [ConsoleColor] $DisplayColor
    [string] $Description
    [hashtable] $CustomSettings  # Extension point
}

# Example custom configuration
$ExtendedRepositoryConfig = @(
    @{ 
        FolderPath = "CUSTOM"
        BranchSuffix = "custom"
        DisplayColor = [System.ConsoleColor]::Magenta
        Description = "Custom Environment"
        CustomSettings = @{
            PostUpdateScript = "custom-post-update.ps1"
            BackupEnabled = $true
            NotificationEmail = "admin@company.com"
        }
    }
)
```

### 2. Custom Progress Handlers

```powershell
# Extension point: Custom progress tracking
interface IProgressHandler {
    [void] StartActivity([string]$Activity)
    [void] UpdateProgress([int]$Percent, [string]$Status)
    [void] CompleteActivity()
}

# Example custom progress handler
class EmailProgressHandler : IProgressHandler {
    [void] StartActivity([string]$Activity) {
        Send-MailMessage -Subject "Started: $Activity" -Body "Activity started at $(Get-Date)"
    }
    
    [void] UpdateProgress([int]$Percent, [string]$Status) {
        if ($Percent -eq 50) {
            Send-MailMessage -Subject "Progress: 50%" -Body "Halfway complete: $Status"
        }
    }
    
    [void] CompleteActivity() {
        Send-MailMessage -Subject "Completed" -Body "Activity completed at $(Get-Date)"
    }
}
```

### 3. Custom Git Operations

```powershell
# Extension point: Custom git command wrappers
interface IGitOperations {
    [object] ExecuteCommand([string]$Command)
    [bool] ValidateRepository([string]$Path)
    [void] ConfigureRepository([string]$Path)
}

# Example custom git operations
class EnhancedGitOperations : IGitOperations {
    [object] ExecuteCommand([string]$Command) {
        # Add logging, metrics, etc.
        $startTime = Get-Date
        $result = Invoke-Expression $Command 2>&1
        $duration = (Get-Date) - $startTime
        
        # Log command execution
        Write-Log "Git command '$Command' executed in $($duration.TotalSeconds)s"
        
        return $result
    }
    
    [bool] ValidateRepository([string]$Path) {
        # Custom validation logic
        return (Test-Path "$Path\.git") -and (Test-Path "$Path\.git\config")
    }
    
    [void] ConfigureRepository([string]$Path) {
        # Custom configuration logic
        Push-Location $Path
        try {
            # Apply custom settings
            git config custom.company "MyCompany"
            git config custom.team "MyTeam"
        } finally {
            Pop-Location
        }
    }
}
```

### 4. Plugin Architecture

```powershell
# Extension point: Plugin system
interface IPlugin {
    [string] GetName()
    [void] OnBeforeOperation([string]$Operation, [hashtable]$Context)
    [void] OnAfterOperation([string]$Operation, [hashtable]$Context, [bool]$Success)
    [void] OnError([string]$Operation, [Exception]$Error)
}

# Plugin manager
class PluginManager {
    [System.Collections.ArrayList] $Plugins = @()
    
    [void] RegisterPlugin([IPlugin]$Plugin) {
        $this.Plugins.Add($Plugin)
    }
    
    [void] ExecuteBeforeHooks([string]$Operation, [hashtable]$Context) {
        foreach ($plugin in $this.Plugins) {
            try {
                $plugin.OnBeforeOperation($Operation, $Context)
            } catch {
                Write-Warning "Plugin $($plugin.GetName()) failed in BeforeOperation: $($_.Exception.Message)"
            }
        }
    }
}

# Example plugin
class NotificationPlugin : IPlugin {
    [string] GetName() { return "NotificationPlugin" }
    
    [void] OnBeforeOperation([string]$Operation, [hashtable]$Context) {
        Send-SlackMessage "Starting operation: $Operation"
    }
    
    [void] OnAfterOperation([string]$Operation, [hashtable]$Context, [bool]$Success) {
        $status = if ($Success) { "✅ Success" } else { "❌ Failed" }
        Send-SlackMessage "Operation $Operation completed: $status"
    }
    
    [void] OnError([string]$Operation, [Exception]$Error) {
        Send-SlackMessage "⚠️ Error in $Operation: $($Error.Message)"
    }
}
```

## Performance Considerations

### 1. Git Operations Optimization

```powershell
# Optimized git operations for large repositories
function Optimize-GitOperations {
    param([string]$RepositoryPath)
    
    Push-Location $RepositoryPath
    try {
        # Enable performance optimizations
        git config core.preloadindex true
        git config core.fscache true
        git config gc.auto 256
        git config pack.threads 0  # Use all available CPU cores
        
        # Configure for large repositories
        git config core.commitGraph true
        git config gc.writeCommitGraph true
        
        # Optimize network operations
        git config http.postBuffer 524288000  # 500MB buffer
        git config pack.windowMemory 256m
        
    } finally {
        Pop-Location
    }
}
```

### 2. Progress Tracking Optimization

```powershell
# Efficient progress tracking with minimal overhead
class OptimizedProgressTracker {
    [int] $LastReportedPercent = -1
    [DateTime] $LastUpdate = [DateTime]::MinValue
    [int] $MinUpdateIntervalMs = 100  # Minimum 100ms between updates
    
    [void] UpdateProgress([int]$Id, [string]$Activity, [int]$Percent) {
        $now = Get-Date
        
        # Only update if significant change or enough time has passed
        if ($Percent -ne $this.LastReportedPercent -or 
            ($now - $this.LastUpdate).TotalMilliseconds -gt $this.MinUpdateIntervalMs) {
            
            Write-Progress -Id $Id -Activity $Activity -PercentComplete $Percent
            $this.LastReportedPercent = $Percent
            $this.LastUpdate = $now
        }
    }
}
```

### 3. Memory Management

```powershell
# Memory-efficient processing for large outputs
function Process-GitOutputEfficiently {
    param([string]$Command)
    
    # Use streaming instead of loading all output into memory
    $process = Start-Process -FilePath "git" -ArgumentList $Command.Split(' ') -NoNewWindow -PassThru -RedirectStandardOutput
    
    while (-not $process.StandardOutput.EndOfStream) {
        $line = $process.StandardOutput.ReadLine()
        # Process line by line instead of storing all lines
        Process-GitOutputLine $line
    }
    
    $process.WaitForExit()
    return $process.ExitCode
}
```

## Security Model

### 1. SSH Key Security

```powershell
# Secure SSH key management
function Secure-SSHKeys {
    param([string]$KeyPath)
    
    # Set restrictive permissions on private key (Windows)
    $acl = Get-Acl $KeyPath
    $acl.SetAccessRuleProtection($true, $false)  # Remove inherited permissions
    
    # Grant access only to current user
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $env:USERNAME, "FullControl", "Allow"
    )
    $acl.SetAccessRule($accessRule)
    
    # Apply the ACL
    Set-Acl -Path $KeyPath -AclObject $acl
    
    # Verify permissions
    $currentAcl = Get-Acl $KeyPath
    $hasOnlyUserAccess = ($currentAcl.AccessToString -split "`n").Count -eq 1
    
    if (-not $hasOnlyUserAccess) {
        Write-Warning "SSH key permissions may not be secure"
    }
}
```

### 2. Credential Management

```powershell
# Secure credential handling
function Invoke-SecureGitCommand {
    param([string]$Command)
    
    # Temporarily disable credential caching to prevent credential leaks
    $originalHelper = git config --global credential.helper
    
    try {
        git config --global credential.helper ""
        
        # Execute command with secure environment
        $env:GIT_SSH_COMMAND = "ssh -o StrictHostKeyChecking=yes -o UserKnownHostsFile=$env:USERPROFILE\.ssh\known_hosts"
        
        $result = Invoke-Expression $Command 2>&1
        return $result
        
    } finally {
        # Restore original credential helper
        if ($originalHelper) {
            git config --global credential.helper $originalHelper
        } else {
            git config --global --unset credential.helper
        }
        
        # Clear sensitive environment variables
        Remove-Item Env:GIT_SSH_COMMAND -ErrorAction SilentlyContinue
    }
}
```

### 3. Input Validation Security

```powershell
# Secure input validation to prevent injection attacks
function Test-SecureInput {
    param([string]$Input, [string]$Type)
    
    switch ($Type) {
        "Email" {
            # Strict email validation
            if ($Input -notmatch "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$") {
                throw "Invalid email format"
            }
            # Additional checks for dangerous patterns
            if ($Input -match "[;&|`]") {
                throw "Email contains potentially dangerous characters"
            }
        }
        "Path" {
            # Path validation to prevent directory traversal
            if ($Input -match "\.\." -or $Input -match "[<>|]") {
                throw "Path contains potentially dangerous patterns"
            }
            # Ensure path is within expected boundaries
            $resolvedPath = Resolve-Path $Input -ErrorAction SilentlyContinue
            if ($resolvedPath -and -not $resolvedPath.Path.StartsWith($PWD.Path)) {
                Write-Warning "Path is outside current directory structure"
            }
        }
        "BranchName" {
            # Git branch name validation
            if ($Input -match "[~^:?*\[\]\\]" -or $Input -like "*/.." -or $Input -like "../*") {
                throw "Invalid branch name format"
            }
        }
    }
    
    return $true
}
```

This component reference provides the technical foundation for understanding, extending, and maintaining the GitLab Repository Setup and Management system.