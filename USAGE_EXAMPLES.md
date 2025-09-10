# Usage Examples and Integration Guide

## Table of Contents

1. [Quick Start Examples](#quick-start-examples)
2. [Advanced Usage Patterns](#advanced-usage-patterns)
3. [Integration Scenarios](#integration-scenarios)
4. [Automation Examples](#automation-examples)
5. [Troubleshooting Examples](#troubleshooting-examples)
6. [Custom Configuration Examples](#custom-configuration-examples)

## Quick Start Examples

### Basic Setup Workflow

```powershell
# Complete setup from scratch
# Step 1: Generate SSH keys
.\STEP1_sshKeygen.ps1 -Email "developer@company.com"

# Step 2: Test connection (after adding public key to GitLab)
.\STEP2_testGitLabConnection.ps1

# Step 3-5: Setup all environments
.\STEP3_setup-int-repo.ps1
.\STEP4_setup-test-repo.ps1
.\STEP5_setup-prod-repo.ps1

# Daily workflow: Update all repositories
.\DailyUpdate.ps1
```

### Individual Script Usage

#### SSH Key Generation Examples

```powershell
# Interactive mode (prompts for email)
.\STEP1_sshKeygen.ps1

# Specify email directly
.\STEP1_sshKeygen.ps1 -Email "john.doe@company.com"

# Force overwrite existing keys
.\STEP1_sshKeygen.ps1 -Force

# Combined parameters
.\STEP1_sshKeygen.ps1 -Email "jane.smith@company.com" -Force
```

#### Connection Testing Examples

```powershell
# Basic connection test
.\STEP2_testGitLabConnection.ps1

# Expected successful output:
# [SUCCESS] Connection Working!
# SSH connection to GitLab is working perfectly!
# GitLab Response: Welcome to GitLab, @username!
```

#### Repository Setup Examples

```powershell
# Basic setup with defaults
.\STEP3_setup-int-repo.ps1    # Creates INT/ folder with branch 3.100/in
.\STEP4_setup-test-repo.ps1   # Creates TEST/ folder with branch 3.100/ac
.\STEP5_setup-prod-repo.ps1   # Creates PROD/ folder with branch 3.100/pd

# Custom branch names
.\STEP3_setup-int-repo.ps1 -BranchName "3.101/in"
.\STEP4_setup-test-repo.ps1 -BranchName "4.0/acceptance"

# Custom folder names
.\STEP3_setup-int-repo.ps1 -FolderName "Integration_V3"
.\STEP5_setup-prod-repo.ps1 -FolderName "Production_Main"

# Custom repository URL
.\STEP3_setup-int-repo.ps1 -RemoteUrl "https://gitlab.example.com/myproject.git"

# All parameters combined
.\STEP4_setup-test-repo.ps1 -RemoteUrl "https://gitlab.internal.com/project.git" -BranchName "main" -FolderName "TestEnv"
```

#### Daily Update Examples

```powershell
# Standard daily update
.\DailyUpdate.ps1

# Expected output shows progress for each repository:
# Latest version detected: 3.100
# Repository Configuration:
#   1. INT -> 3.100/in (Integration Environment)
#   2. TEST -> 3.100/ac (Acceptance Environment)  
#   3. PROD -> 3.100/pd (Production Environment)
```

## Advanced Usage Patterns

### Batch Environment Setup

```powershell
# Setup all environments with specific version
$version = "3.101"
$repositories = @(
    @{ Script = ".\STEP3_setup-int-repo.ps1"; Branch = "$version/in"; Folder = "INT_$version" },
    @{ Script = ".\STEP4_setup-test-repo.ps1"; Branch = "$version/ac"; Folder = "TEST_$version" },
    @{ Script = ".\STEP5_setup-prod-repo.ps1"; Branch = "$version/pd"; Folder = "PROD_$version" }
)

foreach ($repo in $repositories) {
    Write-Host "Setting up $($repo.Folder)..." -ForegroundColor Cyan
    & $repo.Script -BranchName $repo.Branch -FolderName $repo.Folder
}
```

### Conditional Setup Based on Environment

```powershell
param(
    [ValidateSet("DEV", "INT", "TEST", "PROD")]
    [string]$Environment = "INT",
    [string]$Version = "3.100"
)

# Setup based on environment parameter
switch ($Environment) {
    "INT" { 
        .\STEP3_setup-int-repo.ps1 -BranchName "$Version/in" -FolderName $Environment
    }
    "TEST" { 
        .\STEP4_setup-test-repo.ps1 -BranchName "$Version/ac" -FolderName $Environment
    }
    "PROD" { 
        .\STEP5_setup-prod-repo.ps1 -BranchName "$Version/pd" -FolderName $Environment
    }
}
```

### Multi-Version Environment Setup

```powershell
# Setup multiple versions side by side
$versions = @("3.100", "3.101", "4.0")

foreach ($version in $versions) {
    Write-Host "Setting up version $version environments..." -ForegroundColor Yellow
    
    # Create version-specific folders
    .\STEP3_setup-int-repo.ps1 -BranchName "$version/in" -FolderName "INT_$version"
    .\STEP4_setup-test-repo.ps1 -BranchName "$version/ac" -FolderName "TEST_$version"
    .\STEP5_setup-prod-repo.ps1 -BranchName "$version/pd" -FolderName "PROD_$version"
}
```

### Custom Repository Configuration

```powershell
# Modify DailyUpdate.ps1 for custom environments
$CustomRepositoryConfig = @(
    @{ 
        FolderPath = "DEVELOPMENT"
        BranchSuffix = "dev"
        DisplayColor = [System.ConsoleColor]::Green
        Description = "Development Environment"
    },
    @{ 
        FolderPath = "STAGING"
        BranchSuffix = "staging"
        DisplayColor = [System.ConsoleColor]::Blue
        Description = "Staging Environment"
    },
    @{ 
        FolderPath = "HOTFIX"
        BranchSuffix = "hotfix"
        DisplayColor = [System.ConsoleColor]::Red
        Description = "Hotfix Environment"
    }
)

# Replace the $RepositoryConfig in DailyUpdate.ps1 with $CustomRepositoryConfig
```

## Integration Scenarios

### CI/CD Pipeline Integration

#### Azure DevOps Pipeline Example

```yaml
# azure-pipelines.yml
stages:
- stage: Setup
  jobs:
  - job: GitLabSetup
    steps:
    - task: PowerShell@2
      displayName: 'Setup GitLab Repositories'
      inputs:
        targetType: 'inline'
        script: |
          # Setup repositories for pipeline
          .\STEP1_sshKeygen.ps1 -Email "$(Build.RequestedForEmail)" -Force
          .\STEP2_testGitLabConnection.ps1
          
          # Setup based on branch
          if ("$(Build.SourceBranchName)" -eq "main") {
              .\STEP5_setup-prod-repo.ps1
          } elseif ("$(Build.SourceBranchName)" -eq "develop") {
              .\STEP3_setup-int-repo.ps1
          } else {
              .\STEP4_setup-test-repo.ps1
          }
```

#### GitHub Actions Example

```yaml
# .github/workflows/gitlab-setup.yml
name: GitLab Repository Setup

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        default: 'INT'
        type: choice
        options:
        - INT
        - TEST
        - PROD

jobs:
  setup:
    runs-on: windows-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup GitLab Repositories
      shell: powershell
      run: |
        .\STEP1_sshKeygen.ps1 -Email "${{ github.actor }}@company.com" -Force
        .\STEP2_testGitLabConnection.ps1
        
        switch ("${{ github.event.inputs.environment }}") {
          "INT" { .\STEP3_setup-int-repo.ps1 }
          "TEST" { .\STEP4_setup-test-repo.ps1 }
          "PROD" { .\STEP5_setup-prod-repo.ps1 }
        }
```

### Scheduled Task Integration

#### Windows Task Scheduler Setup

```powershell
# Create scheduled task for daily updates
$taskName = "GitLab Daily Repository Update"
$scriptPath = "C:\DEV\DailyUpdate.ps1"
$logPath = "C:\Logs\GitUpdate-$(Get-Date -Format 'yyyyMMdd').log"

# Create the scheduled task action
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`" | Tee-Object -FilePath `"$logPath`""

# Create the trigger (daily at 8:00 AM)
$trigger = New-ScheduledTaskTrigger -Daily -At "08:00"

# Create task settings
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Register the scheduled task
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Description "Daily GitLab repository updates"

Write-Host "Scheduled task '$taskName' created successfully!" -ForegroundColor Green
```

#### PowerShell Profile Integration

```powershell
# Add to PowerShell profile ($PROFILE)
function Start-GitLabUpdate {
    param(
        [string]$Path = "C:\DEV"
    )
    
    Push-Location $Path
    try {
        .\DailyUpdate.ps1
    } finally {
        Pop-Location
    }
}

# Create alias for convenience
Set-Alias -Name "glu" -Value "Start-GitLabUpdate"

# Auto-update notification
if (Test-Path "C:\DEV\DailyUpdate.ps1") {
    $lastUpdate = (Get-Item "C:\DEV\INT\.git\FETCH_HEAD" -ErrorAction SilentlyContinue).LastWriteTime
    if ($lastUpdate -and $lastUpdate -lt (Get-Date).AddDays(-1)) {
        Write-Host "GitLab repositories haven't been updated in over 24 hours. Run 'glu' to update." -ForegroundColor Yellow
    }
}
```

### Docker Integration

#### Dockerfile for GitLab Setup

```dockerfile
# Dockerfile for GitLab repository management
FROM mcr.microsoft.com/powershell:latest

# Install Git
RUN apt-get update && apt-get install -y git openssh-client

# Copy scripts
COPY *.ps1 /app/
WORKDIR /app

# Set execution policy
RUN pwsh -c "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"

# Default command
CMD ["pwsh", "-File", "DailyUpdate.ps1"]
```

#### Docker Compose Setup

```yaml
# docker-compose.yml
version: '3.8'
services:
  gitlab-updater:
    build: .
    volumes:
      - ./repositories:/app/repositories
      - ./ssh-keys:/root/.ssh
    environment:
      - GIT_SSH_COMMAND=ssh -o StrictHostKeyChecking=no
    command: pwsh -File DailyUpdate.ps1
```

## Automation Examples

### Automated Environment Validation

```powershell
# validate-environment.ps1
function Test-GitLabEnvironment {
    param(
        [string[]]$RequiredFolders = @("INT", "TEST", "PROD")
    )
    
    $results = @()
    
    foreach ($folder in $RequiredFolders) {
        $result = @{
            Folder = $folder
            Exists = Test-Path $folder
            IsGitRepo = Test-Path "$folder\.git"
            LastUpdate = $null
            Status = "Unknown"
        }
        
        if ($result.IsGitRepo) {
            try {
                Push-Location $folder
                $result.LastUpdate = git log -1 --format="%cd" --date=short 2>$null
                $gitStatus = git status --porcelain 2>$null
                $result.Status = if ($gitStatus) { "Modified" } else { "Clean" }
                Pop-Location
            } catch {
                $result.Status = "Error"
                Pop-Location
            }
        }
        
        $results += $result
    }
    
    return $results
}

# Usage
$envStatus = Test-GitLabEnvironment
$envStatus | Format-Table -AutoSize

# Auto-fix missing repositories
$missing = $envStatus | Where-Object { -not $_.Exists }
foreach ($repo in $missing) {
    Write-Host "Setting up missing repository: $($repo.Folder)" -ForegroundColor Yellow
    switch ($repo.Folder) {
        "INT" { .\STEP3_setup-int-repo.ps1 }
        "TEST" { .\STEP4_setup-test-repo.ps1 }
        "PROD" { .\STEP5_setup-prod-repo.ps1 }
    }
}
```

### Automated Backup Before Updates

```powershell
# backup-before-update.ps1
function Backup-Repositories {
    param(
        [string[]]$Folders = @("INT", "TEST", "PROD"),
        [string]$BackupPath = ".\Backups\$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    )
    
    if (-not (Test-Path $BackupPath)) {
        New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
    }
    
    foreach ($folder in $Folders) {
        if (Test-Path $folder) {
            Write-Host "Backing up $folder..." -ForegroundColor Cyan
            Copy-Item -Path $folder -Destination "$BackupPath\$folder" -Recurse -Force
        }
    }
    
    Write-Host "Backup completed: $BackupPath" -ForegroundColor Green
    return $BackupPath
}

# Enhanced daily update with backup
function Start-SafeUpdate {
    # Create backup
    $backupPath = Backup-Repositories
    
    try {
        # Run daily update
        .\DailyUpdate.ps1
        
        # If successful, optionally remove old backups
        $oldBackups = Get-ChildItem ".\Backups" | Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-7) }
        $oldBackups | Remove-Item -Recurse -Force
        
    } catch {
        Write-Host "Update failed! Backup available at: $backupPath" -ForegroundColor Red
        throw
    }
}
```

### Automated Branch Management

```powershell
# branch-manager.ps1
function Switch-AllRepositoriesToBranch {
    param(
        [string]$TargetVersion,
        [hashtable]$RepositoryMapping = @{
            "INT" = "in"
            "TEST" = "ac"
            "PROD" = "pd"
        }
    )
    
    foreach ($repo in $RepositoryMapping.GetEnumerator()) {
        $folderName = $repo.Key
        $branchSuffix = $repo.Value
        $branchName = "$TargetVersion/$branchSuffix"
        
        if (Test-Path $folderName) {
            Write-Host "Switching $folderName to $branchName..." -ForegroundColor Cyan
            
            Push-Location $folderName
            try {
                git fetch origin
                git checkout -B $branchName "origin/$branchName"
                Write-Host "[OK] $folderName switched to $branchName" -ForegroundColor Green
            } catch {
                Write-Host "[ERROR] Failed to switch $folderName to $branchName" -ForegroundColor Red
            } finally {
                Pop-Location
            }
        }
    }
}

# Usage
Switch-AllRepositoriesToBranch -TargetVersion "3.101"
```

## Troubleshooting Examples

### Connection Diagnostics

```powershell
# diagnose-connection.ps1
function Test-GitLabConnectivity {
    Write-Host "=== GitLab Connectivity Diagnostics ===" -ForegroundColor Cyan
    
    # Test 1: SSH key existence
    $sshKeyExists = Test-Path "$env:USERPROFILE\.ssh\id_rsa"
    Write-Host "SSH Key Exists: $sshKeyExists" -ForegroundColor $(if($sshKeyExists){"Green"}else{"Red"})
    
    # Test 2: Network connectivity
    try {
        $ping = Test-NetConnection -ComputerName "gitlab.office.transporeon.com" -Port 22 -WarningAction SilentlyContinue
        Write-Host "Network Connectivity: $($ping.TcpTestSucceeded)" -ForegroundColor $(if($ping.TcpTestSucceeded){"Green"}else{"Red"})
    } catch {
        Write-Host "Network Connectivity: False" -ForegroundColor Red
    }
    
    # Test 3: SSH authentication
    if ($sshKeyExists) {
        $sshTest = ssh -o ConnectTimeout=5 -o BatchMode=yes -T git@gitlab.office.transporeon.com 2>&1
        $sshSuccess = $sshTest -like "*Welcome to GitLab*"
        Write-Host "SSH Authentication: $sshSuccess" -ForegroundColor $(if($sshSuccess){"Green"}else{"Red"})
        
        if (-not $sshSuccess) {
            Write-Host "SSH Error: $sshTest" -ForegroundColor Yellow
        }
    }
    
    # Test 4: Git installation
    try {
        $gitVersion = git --version
        Write-Host "Git Installation: $gitVersion" -ForegroundColor Green
    } catch {
        Write-Host "Git Installation: Not found" -ForegroundColor Red
    }
}

# Usage
Test-GitLabConnectivity
```

### Repository Repair

```powershell
# repair-repository.ps1
function Repair-GitRepository {
    param(
        [string]$RepositoryPath,
        [string]$RemoteUrl = "git@gitlab.office.transporeon.com:Development/portfolio.git"
    )
    
    if (-not (Test-Path $RepositoryPath)) {
        Write-Host "Repository path does not exist: $RepositoryPath" -ForegroundColor Red
        return $false
    }
    
    Push-Location $RepositoryPath
    try {
        Write-Host "Repairing repository: $RepositoryPath" -ForegroundColor Cyan
        
        # Check if it's a git repository
        if (-not (Test-Path ".git")) {
            Write-Host "Not a git repository. Initializing..." -ForegroundColor Yellow
            git init
            git remote add origin $RemoteUrl
        }
        
        # Repair common issues
        Write-Host "Running git fsck..." -ForegroundColor Gray
        git fsck --full
        
        Write-Host "Cleaning repository..." -ForegroundColor Gray
        git gc --prune=now
        
        Write-Host "Fetching from remote..." -ForegroundColor Gray
        git fetch origin
        
        Write-Host "Repository repair completed!" -ForegroundColor Green
        return $true
        
    } catch {
        Write-Host "Repository repair failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    } finally {
        Pop-Location
    }
}

# Repair all repositories
$repositories = @("INT", "TEST", "PROD")
foreach ($repo in $repositories) {
    if (Test-Path $repo) {
        Repair-GitRepository -RepositoryPath $repo
    }
}
```

### Log Analysis

```powershell
# analyze-logs.ps1
function Analyze-GitLabLogs {
    param(
        [string]$LogPath = "C:\Logs",
        [int]$Days = 7
    )
    
    $logFiles = Get-ChildItem "$LogPath\GitUpdate-*.log" | Where-Object { $_.CreationTime -gt (Get-Date).AddDays(-$Days) }
    
    $analysis = @{
        TotalRuns = $logFiles.Count
        SuccessfulRuns = 0
        FailedRuns = 0
        CommonErrors = @{}
    }
    
    foreach ($logFile in $logFiles) {
        $content = Get-Content $logFile.FullName -Raw
        
        if ($content -like "*ALL REPOSITORIES UPDATED SUCCESSFULLY*") {
            $analysis.SuccessfulRuns++
        } else {
            $analysis.FailedRuns++
            
            # Extract error patterns
            $errors = $content | Select-String -Pattern "\[FAIL\].*" -AllMatches
            foreach ($error in $errors.Matches) {
                $errorText = $error.Value
                if ($analysis.CommonErrors.ContainsKey($errorText)) {
                    $analysis.CommonErrors[$errorText]++
                } else {
                    $analysis.CommonErrors[$errorText] = 1
                }
            }
        }
    }
    
    Write-Host "=== GitLab Update Log Analysis (Last $Days days) ===" -ForegroundColor Cyan
    Write-Host "Total Runs: $($analysis.TotalRuns)" -ForegroundColor White
    Write-Host "Successful: $($analysis.SuccessfulRuns)" -ForegroundColor Green
    Write-Host "Failed: $($analysis.FailedRuns)" -ForegroundColor Red
    
    if ($analysis.CommonErrors.Count -gt 0) {
        Write-Host "`nCommon Errors:" -ForegroundColor Yellow
        $analysis.CommonErrors.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
            Write-Host "  $($_.Value)x: $($_.Key)" -ForegroundColor Gray
        }
    }
    
    return $analysis
}

# Usage
Analyze-GitLabLogs -Days 30
```

## Custom Configuration Examples

### Multi-Team Configuration

```powershell
# multi-team-config.ps1
# Configuration for multiple teams with different repositories

$TeamConfigurations = @{
    "TeamA" = @{
        RemoteUrl = "git@gitlab.office.transporeon.com:TeamA/project.git"
        Environments = @(
            @{ Folder = "TeamA_DEV"; Branch = "develop"; Color = "Green" }
            @{ Folder = "TeamA_PROD"; Branch = "main"; Color = "Red" }
        )
    }
    "TeamB" = @{
        RemoteUrl = "git@gitlab.office.transporeon.com:TeamB/application.git"
        Environments = @(
            @{ Folder = "TeamB_INT"; Branch = "integration"; Color = "Cyan" }
            @{ Folder = "TeamB_TEST"; Branch = "testing"; Color = "Magenta" }
            @{ Folder = "TeamB_PROD"; Branch = "production"; Color = "Yellow" }
        )
    }
}

function Setup-TeamEnvironments {
    param(
        [string]$TeamName
    )
    
    if (-not $TeamConfigurations.ContainsKey($TeamName)) {
        Write-Host "Unknown team: $TeamName" -ForegroundColor Red
        return
    }
    
    $config = $TeamConfigurations[$TeamName]
    
    foreach ($env in $config.Environments) {
        Write-Host "Setting up $($env.Folder)..." -ForegroundColor $env.Color
        
        # Use the setup scripts with custom parameters
        if ($env.Folder -like "*_INT*") {
            .\STEP3_setup-int-repo.ps1 -RemoteUrl $config.RemoteUrl -BranchName $env.Branch -FolderName $env.Folder
        } elseif ($env.Folder -like "*_TEST*") {
            .\STEP4_setup-test-repo.ps1 -RemoteUrl $config.RemoteUrl -BranchName $env.Branch -FolderName $env.Folder
        } elseif ($env.Folder -like "*_PROD*") {
            .\STEP5_setup-prod-repo.ps1 -RemoteUrl $config.RemoteUrl -BranchName $env.Branch -FolderName $env.Folder
        }
    }
}

# Setup environments for specific team
Setup-TeamEnvironments -TeamName "TeamA"
```

### Environment-Specific Configurations

```powershell
# environment-config.ps1
# Different configurations based on environment (dev machine vs server)

function Get-EnvironmentConfig {
    $computerName = $env:COMPUTERNAME
    $userName = $env:USERNAME
    
    # Development machine configuration
    if ($computerName -like "DEV-*" -or $userName -like "dev*") {
        return @{
            DefaultEmail = "$userName@company.com"
            Repositories = @("INT", "TEST")  # Only setup INT and TEST on dev machines
            AutoUpdate = $false  # Manual updates on dev machines
            BackupEnabled = $true
        }
    }
    # Server configuration
    elseif ($computerName -like "SRV-*") {
        return @{
            DefaultEmail = "server@company.com"
            Repositories = @("PROD")  # Only PROD on servers
            AutoUpdate = $true  # Automatic updates on servers
            BackupEnabled = $true
        }
    }
    # Default configuration
    else {
        return @{
            DefaultEmail = ""
            Repositories = @("INT", "TEST", "PROD")
            AutoUpdate = $false
            BackupEnabled = $false
        }
    }
}

function Setup-EnvironmentSpecific {
    $config = Get-EnvironmentConfig
    
    Write-Host "Environment Configuration:" -ForegroundColor Cyan
    Write-Host "  Computer: $env:COMPUTERNAME" -ForegroundColor Gray
    Write-Host "  User: $env:USERNAME" -ForegroundColor Gray
    Write-Host "  Repositories: $($config.Repositories -join ', ')" -ForegroundColor Gray
    Write-Host "  Auto-Update: $($config.AutoUpdate)" -ForegroundColor Gray
    
    # Setup SSH keys with environment-specific email
    if ($config.DefaultEmail) {
        .\STEP1_sshKeygen.ps1 -Email $config.DefaultEmail -Force
    } else {
        .\STEP1_sshKeygen.ps1
    }
    
    # Test connection
    .\STEP2_testGitLabConnection.ps1
    
    # Setup repositories based on environment
    foreach ($repo in $config.Repositories) {
        switch ($repo) {
            "INT" { .\STEP3_setup-int-repo.ps1 }
            "TEST" { .\STEP4_setup-test-repo.ps1 }
            "PROD" { .\STEP5_setup-prod-repo.ps1 }
        }
    }
    
    # Setup automatic updates if configured
    if ($config.AutoUpdate) {
        # Create scheduled task for automatic updates
        $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File $(Get-Location)\DailyUpdate.ps1"
        $trigger = New-ScheduledTaskTrigger -Daily -At "06:00"
        Register-ScheduledTask -TaskName "GitLab Auto Update" -Action $action -Trigger $trigger
    }
}

# Usage
Setup-EnvironmentSpecific
```

These examples provide comprehensive guidance for using the GitLab Repository Setup and Management system in various scenarios, from basic usage to complex enterprise integrations.