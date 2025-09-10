# GitLab Repository Setup and Management - API Documentation

## Table of Contents

1. [Overview](#overview)
2. [Script APIs](#script-apis)
3. [Function Reference](#function-reference)
4. [Configuration Reference](#configuration-reference)
5. [Usage Examples](#usage-examples)
6. [Error Handling](#error-handling)
7. [Integration Guide](#integration-guide)

## Overview

This documentation provides comprehensive details for all public APIs, functions, and components in the GitLab Repository Setup and Management system. The system consists of 6 PowerShell scripts that handle SSH key generation, connection testing, repository setup, and daily updates.

### System Architecture

```
GitLab Repository Setup System
├── STEP1_sshKeygen.ps1          # SSH Key Generation API
├── STEP2_testGitLabConnection.ps1 # Connection Testing API  
├── STEP3_setup-int-repo.ps1     # Integration Repository Setup API
├── STEP4_setup-test-repo.ps1    # Test Repository Setup API
├── STEP5_setup-prod-repo.ps1    # Production Repository Setup API
└── DailyUpdate.ps1              # Multi-Repository Update API
```

## Script APIs

### 1. SSH Key Generation API (`STEP1_sshKeygen.ps1`)

**Purpose**: Generates 4096-bit RSA SSH keys for GitLab authentication.

#### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `Email` | String | No | "" | Email address for SSH key generation |
| `Force` | Switch | No | False | Overwrite existing keys without prompting |

#### Usage Examples

```powershell
# Basic usage with interactive email prompt
.\STEP1_sshKeygen.ps1

# Specify email parameter
.\STEP1_sshKeygen.ps1 -Email "john.doe@company.com"

# Force overwrite existing keys
.\STEP1_sshKeygen.ps1 -Force

# Combined parameters
.\STEP1_sshKeygen.ps1 -Email "john.doe@company.com" -Force
```

#### Return Values

- **Exit Code 0**: SSH key generated successfully
- **Exit Code 1**: Key generation failed

#### Output

The script outputs the public key to the console for manual copying to GitLab. The key files are saved to:
- Private key: `~/.ssh/id_rsa`
- Public key: `~/.ssh/id_rsa.pub`

#### Configuration

Set the `$DEFAULT_EMAIL` variable in the script to avoid email prompts:

```powershell
$DEFAULT_EMAIL = "your.email@company.com"
```

### 2. Connection Testing API (`STEP2_testGitLabConnection.ps1`)

**Purpose**: Tests SSH connectivity to GitLab server and validates authentication.

#### Parameters

None. This script operates without parameters.

#### Usage Examples

```powershell
# Test GitLab connection
.\STEP2_testGitLabConnection.ps1
```

#### Return Values

- **Exit Code 0**: Connection successful
- **Exit Code 1**: Connection failed (missing keys or authentication issues)

#### Validation Checks

1. **SSH Key Existence**: Verifies presence of `id_rsa` and `id_rsa.pub`
2. **Key Fingerprint**: Displays SSH key fingerprint for verification
3. **Host Key Management**: Automatically adds GitLab host key to `known_hosts`
4. **Authentication Test**: Performs actual SSH connection test

#### Output States

| State | Description | Action Required |
|-------|-------------|-----------------|
| `[SUCCESS] Connection Working!` | SSH authentication successful | None |
| `[ERROR] AUTHENTICATION FAILED` | SSH key not added to GitLab | Add public key to GitLab profile |
| `[ERROR] CONNECTION FAILED` | Network connectivity issues | Check VPN/network access |
| `[ERROR] HOST KEY VERIFICATION FAILED` | Host key issues | Manual SSH connection required |

### 3. Repository Setup APIs (`STEP3-5_setup-*-repo.ps1`)

**Purpose**: Clone and configure GitLab repositories for different environments.

#### Common Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `RemoteUrl` | String | No | "https://gitlab.office.transporeon.com/Development/portfolio.git" | Git repository URL |
| `BranchName` | String | No | Environment-specific | Target branch name |
| `FolderName` | String | No | Environment-specific | Local folder name |

#### Environment-Specific Defaults

| Script | Default Branch | Default Folder | Description |
|--------|----------------|----------------|-------------|
| `STEP3_setup-int-repo.ps1` | `3.100/in` | `INT` | Integration environment |
| `STEP4_setup-test-repo.ps1` | `3.100/ac` | `TEST` | Test/Acceptance environment |
| `STEP5_setup-prod-repo.ps1` | `3.100/pd` | `PROD` | Production environment |

#### Usage Examples

```powershell
# Basic usage with defaults
.\STEP3_setup-int-repo.ps1
.\STEP4_setup-test-repo.ps1
.\STEP5_setup-prod-repo.ps1

# Custom branch specification
.\STEP3_setup-int-repo.ps1 -BranchName "3.101/in"

# Custom folder name
.\STEP4_setup-test-repo.ps1 -FolderName "MyTestEnv"

# Custom repository URL
.\STEP5_setup-prod-repo.ps1 -RemoteUrl "https://gitlab.example.com/myproject.git"

# All parameters combined
.\STEP3_setup-int-repo.ps1 -RemoteUrl "https://gitlab.example.com/project.git" -BranchName "main" -FolderName "Integration"
```

#### Return Values

- **Exit Code 0**: Repository setup successful
- **Exit Code 1**: Setup failed (network, authentication, or repository issues)

#### Repository Configuration

Each setup script automatically configures the cloned repository with:

```powershell
# Git configuration applied to each repository
git config pull.rebase false          # Use merge strategy for pulls
git config push.default simple        # Push only current branch
git config core.autocrlf true         # Handle line endings on Windows
git config core.filemode false        # Ignore file mode changes
git config gui.recentrepo $TargetPath # TortoiseGit integration
```

#### SSH Authentication Setup

All repositories are automatically configured to use SSH authentication:

```powershell
git remote set-url origin git@gitlab.office.transporeon.com:Development/portfolio.git
```

### 4. Daily Update API (`DailyUpdate.ps1`)

**Purpose**: Automatically updates all configured repositories to the latest version.

#### Parameters

None. Configuration is handled through script variables.

#### Usage Examples

```powershell
# Update all repositories
.\DailyUpdate.ps1
```

#### Configuration

The script uses the `$RepositoryConfig` array for configuration:

```powershell
$RepositoryConfig = @(
    @{ 
        FolderPath = "INT"     # Local folder name
        BranchSuffix = "in"    # Git branch suffix
        DisplayColor = [System.ConsoleColor]::Cyan 
        Description = "Integration Environment"
    },
    @{ 
        FolderPath = "TEST"
        BranchSuffix = "ac"
        DisplayColor = [System.ConsoleColor]::Magenta 
        Description = "Acceptance Environment"
    },
    @{ 
        FolderPath = "PROD"
        BranchSuffix = "pd"
        DisplayColor = [System.ConsoleColor]::Yellow 
        Description = "Production Environment"
    }
)
```

#### Return Values

- **Exit Code 0**: All repositories updated successfully
- **Exit Code 1**: Update failed for one or more repositories

## Function Reference

### `Invoke-GitCommand` (DailyUpdate.ps1)

**Purpose**: Executes Git commands while filtering out cache daemon errors.

```powershell
function Invoke-GitCommand {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Command
    )
}
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `Command` | String | Yes | Git command to execute |

#### Usage Examples

```powershell
# Execute git fetch with error filtering
Invoke-GitCommand "git fetch origin"

# Execute git reset with error filtering
Invoke-GitCommand "git reset --hard origin/main"
```

#### Return Value

Filtered command output with cache daemon errors removed.

### `Get-LatestVersionNumber` (DailyUpdate.ps1)

**Purpose**: Determines the latest version number from remote branches.

```powershell
function Get-LatestVersionNumber {
    # No parameters
}
```

#### Algorithm

1. Fetches all remote branches
2. Extracts version numbers using regex pattern `(\d+\.\d+)/`
3. Sorts versions numerically
4. Returns the highest version number

#### Usage Examples

```powershell
# Get latest version
$latestVersion = Get-LatestVersionNumber
Write-Host "Latest version: $latestVersion"
```

#### Return Value

String representation of the latest version (e.g., "3.100").

### `Update-Repository` (DailyUpdate.ps1)

**Purpose**: Updates a single repository with progress tracking.

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

#### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `FolderPath` | String | Yes | - | Local repository folder name |
| `VersionNumber` | String | Yes | - | Version number for branch |
| `BranchSuffix` | String | Yes | - | Branch suffix (in, ac, pd) |
| `Color` | ConsoleColor | No | Cyan | Display color for output |
| `RepoIndex` | Int | Yes | - | Current repository index (1-based) |
| `TotalRepos` | Int | Yes | - | Total number of repositories |
| `Description` | String | No | "" | Repository description |

#### Usage Examples

```powershell
# Update single repository
Update-Repository -FolderPath "INT" -VersionNumber "3.100" -BranchSuffix "in" -RepoIndex 1 -TotalRepos 3

# Update with custom color and description
Update-Repository -FolderPath "TEST" -VersionNumber "3.100" -BranchSuffix "ac" -Color Yellow -RepoIndex 2 -TotalRepos 3 -Description "Test Environment"
```

#### Operations Performed

1. **Directory Navigation**: Changes to target repository folder
2. **Remote Fetch**: Fetches latest changes from origin
3. **Branch Management**: Creates or switches to target branch
4. **Force Update**: Performs `git reset --hard` to match remote
5. **Progress Reporting**: Updates progress bars throughout process

## Configuration Reference

### Environment Variables

| Variable | Description | Default Location |
|----------|-------------|------------------|
| `$env:USERPROFILE\.ssh\` | SSH key storage directory | User profile directory |
| `$PSScriptRoot` | Script execution directory | Script file location |

### Default Configuration Values

```powershell
# SSH Key Generation
$DEFAULT_EMAIL = ""  # Set to avoid email prompts

# Repository URLs
$DefaultRemoteUrl = "https://gitlab.office.transporeon.com/Development/portfolio.git"

# Branch Patterns
$BranchPattern = "{version}/{suffix}"  # e.g., "3.100/in"

# Directory Structure
$BaseDirectory = $PSScriptRoot  # Scripts use their location as base
```

### TortoiseGit Integration Settings

```powershell
# Applied to each repository
git config core.autocrlf true      # Windows line ending handling
git config core.filemode false     # Ignore file permissions
git config gui.recentrepo $path    # Add to TortoiseGit recent repositories
```

## Usage Examples

### Complete Setup Workflow

```powershell
# Step 1: Generate SSH keys
.\STEP1_sshKeygen.ps1 -Email "developer@company.com"

# Step 2: Test connection (after adding public key to GitLab)
.\STEP2_testGitLabConnection.ps1

# Step 3: Setup all environments
.\STEP3_setup-int-repo.ps1
.\STEP4_setup-test-repo.ps1  
.\STEP5_setup-prod-repo.ps1

# Daily workflow: Update all repositories
.\DailyUpdate.ps1
```

### Custom Configuration Example

```powershell
# Custom repository setup with different branch
.\STEP3_setup-int-repo.ps1 -BranchName "4.0/integration" -FolderName "INT_V4"

# Custom DailyUpdate configuration
# Edit DailyUpdate.ps1 to modify $RepositoryConfig:
$RepositoryConfig = @(
    @{ 
        FolderPath = "INT_V4"
        BranchSuffix = "integration"
        DisplayColor = [System.ConsoleColor]::Green
        Description = "Integration V4.0"
    }
)
```

### Batch Operations

```powershell
# Setup all environments with custom branch prefix
$version = "3.101"
.\STEP3_setup-int-repo.ps1 -BranchName "$version/in"
.\STEP4_setup-test-repo.ps1 -BranchName "$version/ac"
.\STEP5_setup-prod-repo.ps1 -BranchName "$version/pd"
```

### Integration with Other Scripts

```powershell
# Check if setup is complete before running updates
if (Test-Path "INT" -and Test-Path "TEST" -and Test-Path "PROD") {
    Write-Host "All repositories found. Running daily update..."
    .\DailyUpdate.ps1
} else {
    Write-Host "Repositories not found. Please run setup scripts first."
}
```

## Error Handling

### Common Error Scenarios

#### SSH Authentication Errors

```powershell
# Error: Permission denied (publickey)
# Solution: Ensure public key is added to GitLab
.\STEP2_testGitLabConnection.ps1  # Verify connection
```

#### Network Connectivity Errors

```powershell
# Error: Connection refused/timeout
# Solutions:
# 1. Check VPN connection
# 2. Verify network access to gitlab.office.transporeon.com
# 3. Check firewall settings
```

#### Repository Clone Errors

```powershell
# Error: Branch does not exist
# Solution: Verify branch name exists
git ls-remote origin  # List all remote branches

# Error: Insufficient disk space
# Solution: Free up disk space before cloning
```

#### TortoiseGit Integration Errors

```powershell
# Error: "No supported authentication methods available"
# Solution: Configure TortoiseGit to use OpenSSH
# Settings → Network → SSH client → Browse to ssh.exe
```

### Error Recovery Procedures

#### Corrupted Repository Recovery

```powershell
# Remove corrupted repository and re-clone
Remove-Item "INT" -Recurse -Force
.\STEP3_setup-int-repo.ps1
```

#### SSH Key Recovery

```powershell
# Regenerate SSH keys if corrupted
.\STEP1_sshKeygen.ps1 -Force
# Re-add public key to GitLab profile
```

#### Failed Update Recovery

```powershell
# Manual repository reset if daily update fails
cd INT
git fetch origin
git reset --hard origin/3.100/in
```

## Integration Guide

### CI/CD Integration

```powershell
# Example: Automated setup in CI/CD pipeline
param(
    [string]$Environment = "INT",
    [string]$Version = "3.100"
)

# Setup based on environment
switch ($Environment) {
    "INT" { .\STEP3_setup-int-repo.ps1 -BranchName "$Version/in" }
    "TEST" { .\STEP4_setup-test-repo.ps1 -BranchName "$Version/ac" }
    "PROD" { .\STEP5_setup-prod-repo.ps1 -BranchName "$Version/pd" }
}
```

### Scheduled Task Integration

```powershell
# Create scheduled task for daily updates
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\DEV\DailyUpdate.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At "08:00"
Register-ScheduledTask -TaskName "GitLab Daily Update" -Action $action -Trigger $trigger
```

### Monitoring Integration

```powershell
# Example: Log output for monitoring systems
.\DailyUpdate.ps1 | Tee-Object -FilePath "C:\Logs\GitUpdate-$(Get-Date -Format 'yyyyMMdd').log"
```

### Custom Extension Example

```powershell
# Extend DailyUpdate.ps1 with custom post-update actions
# Add to the end of Update-Repository function:

# Custom post-update hook
if (Test-Path "$TargetPath\post-update.ps1") {
    Write-Host "Running custom post-update script..." -ForegroundColor Yellow
    & "$TargetPath\post-update.ps1"
}
```

---

**Note**: This documentation covers all public APIs and functions. For internal implementation details, refer to the inline comments within each script file.