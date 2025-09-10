# Function Reference Guide

## Overview

This document provides detailed reference information for all functions and components in the GitLab Repository Setup and Management system.

## Table of Contents

1. [Core Functions](#core-functions)
2. [Utility Functions](#utility-functions)
3. [Configuration Objects](#configuration-objects)
4. [Parameter Validation](#parameter-validation)
5. [Error Handling Patterns](#error-handling-patterns)

## Core Functions

### `Invoke-GitCommand`

**Location**: `DailyUpdate.ps1`  
**Purpose**: Wrapper function for Git commands that filters out cache daemon errors.

```powershell
function Invoke-GitCommand {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Command
    )
    
    # Execute the git command
    $output = Invoke-Expression $Command 2>&1
    
    # Filter out the cache daemon error
    $output | Where-Object { $_ -notmatch "fatal: unable to connect to cache daemon" }
}
```

#### Technical Details

- **Input Validation**: Validates that `$Command` is not null or empty
- **Error Filtering**: Removes Git credential cache daemon errors that are non-critical
- **Output Handling**: Returns filtered command output to caller
- **Error Redirection**: Uses `2>&1` to capture both stdout and stderr

#### Usage Patterns

```powershell
# Basic Git command execution
Invoke-GitCommand "git status"

# Fetch with error suppression
Invoke-GitCommand "git fetch origin"

# Complex Git operations
Invoke-GitCommand "git reset --hard origin/main"
```

#### Return Values

- **Success**: Filtered command output as string array
- **Failure**: Error messages (excluding cache daemon errors)

### `Get-LatestVersionNumber`

**Location**: `DailyUpdate.ps1`  
**Purpose**: Analyzes remote branches to determine the latest version number.

```powershell
function Get-LatestVersionNumber {
    Write-Progress -Id 1 -Activity "Initializing Repository Updates" -Status "Fetching remote branches..." -PercentComplete 10
    
    # Get all remote branches
    Invoke-GitCommand "git fetch origin"
    
    Write-Progress -Id 1 -Activity "Initializing Repository Updates" -Status "Analyzing remote branches..." -PercentComplete 50
    
    $branches = git branch -r | ForEach-Object { $_.ToString().Trim() }
    
    Write-Progress -Id 1 -Activity "Initializing Repository Updates" -Status "Processing version information..." -PercentComplete 80
    
    # Create objects with version and branch name for proper sorting
    $versionObjects = $branches | ForEach-Object {
        if ($_ -match "origin/(\d+\.\d+)/") {
            [PSCustomObject]@{
                Version = [System.Version]$matches[1]
            }
        }
    } | Where-Object { $_.Version -ne $null }
    
    # Sort by version and get the latest unique version
    $latestVersion = $versionObjects | Sort-Object Version -Unique | Select-Object -Last 1
    
    Write-Progress -Id 1 -Activity "Initializing Repository Updates" -Status "Version detection complete" -PercentComplete 100
    Start-Sleep -Milliseconds 500  # Brief pause to show completion
    Write-Progress -Id 1 -Activity "Initializing Repository Updates" -Completed
    
    return $latestVersion.Version.ToString()
}
```

#### Algorithm Details

1. **Branch Fetching**: Executes `git fetch origin` to get latest branch information
2. **Branch Parsing**: Extracts branch names using `git branch -r`
3. **Version Extraction**: Uses regex `origin/(\d+\.\d+)/` to extract version numbers
4. **Version Sorting**: Converts to `System.Version` objects for proper numerical sorting
5. **Latest Selection**: Returns the highest version number found

#### Progress Tracking

The function implements detailed progress tracking with multiple stages:
- 10%: Fetching remote branches
- 50%: Analyzing remote branches  
- 80%: Processing version information
- 100%: Version detection complete

#### Error Handling

```powershell
# Handles cases where no version branches are found
if ($versionObjects.Count -eq 0) {
    Write-Warning "No version branches found matching pattern"
    return $null
}
```

### `Update-Repository`

**Location**: `DailyUpdate.ps1`  
**Purpose**: Updates a single repository with comprehensive progress tracking and error handling.

```powershell
function Update-Repository {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FolderPath,
        
        [Parameter(Mandatory = $true)]
        [string]$VersionNumber,
        
        [Parameter(Mandatory = $true)]
        [string]$BranchSuffix,
        
        [Parameter(Mandatory = $false)]
        [System.ConsoleColor]$Color = [System.ConsoleColor]::Cyan,
        
        [Parameter(Mandatory = $true)]
        [int]$RepoIndex,
        
        [Parameter(Mandatory = $true)]
        [int]$TotalRepos,
        
        [Parameter(Mandatory = $false)]
        [string]$Description = ""
    )
}
```

#### Detailed Operation Flow

1. **Progress Initialization**
   ```powershell
   $overallPercent = [math]::Round((($RepoIndex - 1) / $TotalRepos) * 100)
   $displayName = if ($Description) { "$FolderPath ($Description)" } else { $FolderPath }
   Write-Progress -Id 2 -Activity "Updating All Repositories" -Status "Processing $displayName ($RepoIndex of $TotalRepos)" -PercentComplete $overallPercent
   ```

2. **Directory Navigation** (10% progress)
   ```powershell
   Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Status "Changing directory..." -PercentComplete 10
   
   if ($FolderPath -ne $StartingDirectory) {
       cd "../$FolderPath"
   } else {
       # Ensure we're in the starting directory
       $currentDir = (Get-Location).Path
       if (-not $currentDir.EndsWith($StartingDirectory)) {
           cd $StartingDirectory
       }
   }
   ```

3. **Remote Fetch** (30% progress)
   ```powershell
   Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Status "Fetching latest changes from remote..." -PercentComplete 30
   Invoke-GitCommand "git fetch origin"
   ```

4. **Branch Preparation** (50% progress)
   ```powershell
   Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Status "Preparing branch information..." -PercentComplete 50
   $branchName = "$VersionNumber/$BranchSuffix"
   $remoteBranch = "origin/$VersionNumber/$BranchSuffix"
   ```

5. **Branch Checkout/Creation** (70% progress)
   ```powershell
   Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Status "Checking out branch $branchName..." -PercentComplete 70
   
   git checkout $branchName 2>&1 | Out-Null
   if ($LASTEXITCODE -ne 0) {
       Write-Host "Creating local branch for $branchName..." -ForegroundColor $Color
       Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Status "Creating new local branch..." -PercentComplete 80
       Invoke-GitCommand "git checkout -b $branchName $remoteBranch"
   } else {
       # Force update the local branch
       Write-Host "Resetting local branch to match remote (force pull)..." -ForegroundColor $Color
       Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Status "Performing force pull (reset --hard)..." -PercentComplete 90
       Invoke-GitCommand "git reset --hard $remoteBranch"
   }
   ```

6. **Completion** (100% progress)
   ```powershell
   Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Status "$displayName update completed successfully!" -PercentComplete 100
   Start-Sleep -Milliseconds 800  # Brief pause to show completion
   Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Completed
   ```

## Utility Functions

### SSH Key Generation Logic

**Location**: `STEP1_sshKeygen.ps1`  
**Purpose**: Handles SSH key generation with multiple fallback methods.

```powershell
# Primary method using batch file
$batchContent = @"
@echo off
echo Generating SSH key...
ssh-keygen -t rsa -b 4096 -C "$Email" -f "$keyPath" -q -N ""
echo Exit code: %ERRORLEVEL%
"@

$batchFile = "$env:TEMP\ssh_keygen_temp.bat"
$batchContent | Out-File -FilePath $batchFile -Encoding ASCII

try {
    $process = Start-Process -FilePath $batchFile -Wait -PassThru -NoNewWindow
    $exitCode = $process.ExitCode
    Remove-Item $batchFile -Force -ErrorAction SilentlyContinue
} catch {
    # Fallback method
    Write-Host "Batch method failed, trying direct execution..." -ForegroundColor Yellow
    Remove-Item $batchFile -Force -ErrorAction SilentlyContinue
    
    try {
        $process = Start-Process -FilePath "ssh-keygen" -ArgumentList @("-t", "rsa", "-b", "4096", "-C", $Email, "-f", $keyPath, "-q") -Wait -PassThru -NoNewWindow
        $exitCode = $process.ExitCode
    } catch {
        $exitCode = 1
    }
}
```

#### Key Generation Features

- **RSA 4096-bit**: Uses maximum security key length
- **Empty Passphrase**: Generates keys without passphrase for automation
- **Fallback Methods**: Multiple generation methods for compatibility
- **Error Handling**: Comprehensive error detection and reporting

### Connection Testing Logic

**Location**: `STEP2_testGitLabConnection.ps1`  
**Purpose**: Comprehensive SSH connection validation.

```powershell
# Test the connection
$result = ssh -o ConnectTimeout=10 -o BatchMode=yes -T git@gitlab.office.transporeon.com 2>&1
$exitCode = $LASTEXITCODE

# Detailed result analysis
if ($exitCode -eq 0 -and $result -like "*Welcome to GitLab*") {
    Write-Host "[SUCCESS] Connection Working!" -ForegroundColor Green
    Write-Host "SSH connection to GitLab is working perfectly!" -ForegroundColor Green
    Write-Host "GitLab Response:" -ForegroundColor Cyan
    Write-Host $result -ForegroundColor White
} elseif ($result -like "*Permission denied*") {
    Write-Host "[ERROR] AUTHENTICATION FAILED" -ForegroundColor Red
    # Provide specific remediation steps
} elseif ($result -like "*Connection refused*" -or $result -like "*Connection timed out*") {
    Write-Host "[ERROR] CONNECTION FAILED" -ForegroundColor Red
    # Network troubleshooting guidance
}
```

#### Connection Test Features

- **Timeout Control**: 10-second connection timeout
- **Batch Mode**: Non-interactive SSH connection
- **Result Analysis**: Detailed parsing of SSH response
- **Troubleshooting**: Specific guidance for each error type

## Configuration Objects

### Repository Configuration Structure

**Location**: `DailyUpdate.ps1`  
**Purpose**: Defines repository update configuration.

```powershell
$RepositoryConfig = @(
    @{ 
        FolderPath = "INT"     # Local folder name
        BranchSuffix = "in"    # Git branch suffix (e.g., 3.100/in)
        DisplayColor = [System.ConsoleColor]::Cyan 
        Description = "Integration Environment"
    },
    @{ 
        FolderPath = "TEST"    # Local folder name  
        BranchSuffix = "ac"    # Git branch suffix (e.g., 3.100/ac)
        DisplayColor = [System.ConsoleColor]::Magenta 
        Description = "Acceptance Environment"
    },
    @{ 
        FolderPath = "PROD"    # Local folder name
        BranchSuffix = "pd"    # Git branch suffix (e.g., 3.100/pd)
        DisplayColor = [System.ConsoleColor]::Yellow 
        Description = "Production Environment"
    }
)
```

#### Configuration Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `FolderPath` | String | Yes | Local directory name for repository |
| `BranchSuffix` | String | Yes | Branch suffix combined with version |
| `DisplayColor` | ConsoleColor | Yes | Color for console output |
| `Description` | String | Yes | Human-readable environment description |

#### Custom Configuration Example

```powershell
# Extended configuration with additional environments
$RepositoryConfig = @(
    @{ 
        FolderPath = "DEV"
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
        FolderPath = "PROD"
        BranchSuffix = "main"
        DisplayColor = [System.ConsoleColor]::Red
        Description = "Production Environment"
    }
)
```

## Parameter Validation

### Email Validation Pattern

**Location**: `STEP1_sshKeygen.ps1`  
**Purpose**: Validates email address format.

```powershell
if ($Email -notmatch "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$") {
    Write-Host "Invalid email format!" -ForegroundColor Red
    Write-Host "Press ENTER to try again..." -ForegroundColor Yellow
    Read-Host
    continue
}
```

#### Validation Rules

- **Local Part**: Alphanumeric characters, dots, underscores, percent, plus, hyphens
- **Domain Part**: Alphanumeric characters, dots, hyphens
- **TLD**: At least 2 alphabetic characters
- **Overall Structure**: Standard email format with @ separator

### Path Validation Logic

**Location**: Setup scripts (`STEP3-5_setup-*-repo.ps1`)  
**Purpose**: Validates directory paths and parameters.

```powershell
# Base directory validation
$BaseDirectory = $PSScriptRoot
if ([string]::IsNullOrEmpty($BaseDirectory)) {
    $BaseDirectory = Get-Location
    Write-Host "Warning: PSScriptRoot is null, using current location: $BaseDirectory" -ForegroundColor Yellow
}

# Folder name validation
if ([string]::IsNullOrEmpty($FolderName)) {
    Write-Host "Error: FolderName parameter is null or empty" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Target path construction and validation
$TargetPath = Join-Path $BaseDirectory $FolderName
if ([string]::IsNullOrEmpty($TargetPath)) {
    Write-Host "Error: Failed to create target path from BaseDirectory '$BaseDirectory' and FolderName '$FolderName'" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
```

## Error Handling Patterns

### Standard Error Response Pattern

All scripts follow a consistent error handling pattern:

```powershell
try {
    # Main operation
    $result = Invoke-SomeOperation
    
    if ($result.Success) {
        Write-Host "[OK] Operation completed successfully" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Operation failed" -ForegroundColor Red
        # Specific error guidance
        exit 1
    }
} catch {
    Write-Host "[FAIL] Unexpected error: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
```

### Progress Bar Cleanup Pattern

```powershell
# Clean up all progress bars
Start-Sleep -Milliseconds 1000
Write-Progress -Id 4 -ParentId 2 -Activity "Cleanup" -Completed
Write-Progress -Id 2 -Activity "Main Activity" -Completed
```

### User Confirmation Pattern

```powershell
# Standard confirmation with validation
$continue = Read-Host "`nContinue with operation? (Y/N)"
if ($continue -notmatch "^[Yy]") {
    Write-Host "Cancelled" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 0
}
```

### Git Operation Error Handling

```powershell
# Git command with exit code checking
git clone -b $BranchName --progress $RemoteUrl $TargetPath
$cloneResult = @{
    Success = $LASTEXITCODE -eq 0
    ExitCode = $LASTEXITCODE
}

if ($cloneResult.Success) {
    Write-Host "[OK] Repository cloned successfully" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Repository clone failed (Exit code: $($cloneResult.ExitCode))" -ForegroundColor Red
    # Specific troubleshooting guidance
    exit 1
}
```

---

This function reference provides complete implementation details for all functions and components in the system. For usage examples and integration patterns, refer to the main API documentation.