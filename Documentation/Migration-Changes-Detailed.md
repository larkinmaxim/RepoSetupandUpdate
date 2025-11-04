# Detailed Migration Changes: GitLab to GitHub

## Overview
This document provides line-by-line changes needed for migrating from GitLab to GitHub.

---

## 🔧 Script Changes Required

### 1. STEP1_sshKeygen.ps1

#### Line-by-Line Changes:

| Line # | Old Value | New Value |
|--------|-----------|-----------|
| 7-8 | `# SSH Key Generator for GitLab Authentication` | `# SSH Key Generator for GitHub Authentication` |
| 13 | `Write-Host "=== SSH Key Generator for GitLab ===" -ForegroundColor Cyan` | `Write-Host "=== SSH Key Generator for GitHub ===" -ForegroundColor Cyan` |
| 104 | `https://gitlab.office.transporeon.com/-/user_settings/ssh_keys` | `https://github.com/settings/keys` |
| 107 | `Test connection: ssh -T git@gitlab.office.transporeon.com` | `Test connection: ssh -T git@github.com` |

**Summary:** 4 lines to update

---

### 2. STEP2_testGitLabConnection.ps1

**Recommendation:** Rename file to `STEP2_testGitHubConnection.ps1`

#### Line-by-Line Changes:

| Line # | Old Value | New Value |
|--------|-----------|-----------|
| 2 | `# GitLab SSH Connection Test Script` | `# GitHub SSH Connection Test Script` |
| 4 | `# This script tests your SSH connection to GitLab and displays the results` | `# This script tests your SSH connection to GitHub and displays the results` |
| 7 | `Write-Host "=== GitLab SSH Connection Test ===" -ForegroundColor Cyan` | `Write-Host "=== GitHub SSH Connection Test ===" -ForegroundColor Cyan` |
| 41 | `Write-Host "Checking GitLab host key..." -ForegroundColor Yellow` | `Write-Host "Checking GitHub host key..." -ForegroundColor Yellow` |
| 51 | `$gitlabHost = "gitlab.office.transporeon.com"` | `$githubHost = "github.com"` |
| 56 | `$hostKeyExists = $knownHosts \| Where-Object { $_ -like "*$gitlabHost*" }` | `$hostKeyExists = $knownHosts \| Where-Object { $_ -like "*$githubHost*" }` |
| 60 | `Write-Host "Adding GitLab host key to known_hosts..." -ForegroundColor Yellow` | `Write-Host "Adding GitHub host key to known_hosts..." -ForegroundColor Yellow` |
| 62 | `$hostKey = ssh-keyscan -t rsa $gitlabHost 2>$null` | `$hostKey = ssh-keyscan -t rsa $githubHost 2>$null` |
| 65 | `Write-Host "[OK] GitLab host key added successfully!" -ForegroundColor Green` | `Write-Host "[OK] GitHub host key added successfully!" -ForegroundColor Green` |
| 73 | `Write-Host "[OK] GitLab host key already known" -ForegroundColor Green` | `Write-Host "[OK] GitHub host key already known" -ForegroundColor Green` |
| 77 | `Write-Host "Testing connection to GitLab..." -ForegroundColor Yellow` | `Write-Host "Testing connection to GitHub..." -ForegroundColor Yellow` |
| 80 | `$result = ssh -o ConnectTimeout=10 -o BatchMode=yes -T git@gitlab.office.transporeon.com 2>&1` | `$result = ssh -o ConnectTimeout=10 -o BatchMode=yes -T git@github.com 2>&1` |
| 85 | `if ($exitCode -eq 0 -and $result -like "*Welcome to GitLab*")` | `if ($result -like "*successfully authenticated*" -or $result -like "*You've successfully authenticated*")` |
| 87 | `Write-Host "SSH connection to GitLab is working perfectly!" -ForegroundColor Green` | `Write-Host "SSH connection to GitHub is working perfectly!" -ForegroundColor Green` |
| 89 | `Write-Host "GitLab Response:" -ForegroundColor Cyan` | `Write-Host "GitHub Response:" -ForegroundColor Cyan` |
| 93 | `Write-Host "Your SSH key is not added to GitLab or is incorrect." -ForegroundColor Red` | `Write-Host "Your SSH key is not added to GitHub or is incorrect." -ForegroundColor Red` |
| 97 | `Write-Host "2. Add it to GitLab: https://gitlab.office.transporeon.com/-/user_settings/ssh_keys" -ForegroundColor Gray` | `Write-Host "2. Add it to GitHub: https://github.com/settings/keys" -ForegroundColor Gray` |
| 100 | `Write-Host "Cannot connect to GitLab server." -ForegroundColor Red` | `Write-Host "Cannot connect to GitHub server." -ForegroundColor Red` |
| 108 | `Write-Host "ssh -T git@gitlab.office.transporeon.com" -ForegroundColor White` | `Write-Host "ssh -T git@github.com" -ForegroundColor White` |

**Summary:** 19 lines to update + file rename

---

### 3. STEP3_setup-int-repo.ps1

#### Line-by-Line Changes:

| Line # | Old Value | New Value |
|--------|-----------|-----------|
| 2 | `[string]$RemoteUrl = "https://gitlab.office.transporeon.com/Development/portfolio.git",` | `[string]$RemoteUrl = "https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git",` |
| 3 | `[string]$BranchName = "3.100/in",` | `[string]$BranchName = "stage-in",` |
| 176 | `git remote set-url origin git@gitlab.office.transporeon.com:Development/portfolio.git` | `git remote set-url origin git@github.com:trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git` |

**Summary:** 3 lines to update

---

### 4. STEP4_setup-test-repo.ps1

#### Line-by-Line Changes:

| Line # | Old Value | New Value |
|--------|-----------|-----------|
| 2 | `[string]$RemoteUrl = "https://gitlab.office.transporeon.com/Development/portfolio.git",` | `[string]$RemoteUrl = "https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git",` |
| 3 | `[string]$BranchName = "3.100/ac",` | `[string]$BranchName = "stage-ac",` |
| 175 | `git remote set-url origin git@gitlab.office.transporeon.com:Development/portfolio.git` | `git remote set-url origin git@github.com:trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git` |

**Summary:** 3 lines to update

---

### 5. STEP5_setup-prod-repo.ps1

#### Line-by-Line Changes:

| Line # | Old Value | New Value |
|--------|-----------|-----------|
| 2 | `[string]$RemoteUrl = "https://gitlab.office.transporeon.com/Development/portfolio.git",` | `[string]$RemoteUrl = "https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git",` |
| 3 | `[string]$BranchName = "3.100/pd",` | `[string]$BranchName = "stage-pd",` |
| 174 | `git remote set-url origin git@gitlab.office.transporeon.com:Development/portfolio.git` | `git remote set-url origin git@github.com:trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git` |

**Summary:** 3 lines to update

---

### 6. DailyUpdate.ps1 (MAJOR CHANGES)

This file requires significant restructuring due to the change from version-based branches to static branches.

#### Section 1: Configuration (Lines 9-28)

**OLD:**
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

**NEW:**
```powershell
$RepositoryConfig = @(
    @{ 
        FolderPath = "INT"     # Local folder name
        BranchName = "stage-in"    # Git branch name
        DisplayColor = [System.ConsoleColor]::Cyan 
        Description = "Integration Environment"
    },
    @{ 
        FolderPath = "TEST"    # Local folder name  
        BranchName = "stage-ac"    # Git branch name
        DisplayColor = [System.ConsoleColor]::Magenta 
        Description = "Acceptance Environment"
    },
    @{ 
        FolderPath = "PROD"    # Local folder name
        BranchName = "stage-pd"    # Git branch name
        DisplayColor = [System.ConsoleColor]::Yellow 
        Description = "Production Environment"
    }
)
```

#### Section 2: Remove Version Detection Function (Lines 62-92)

**DELETE ENTIRE FUNCTION:** The `Get-LatestVersionNumber` function is no longer needed.

**OLD (DELETE):**
```powershell
# Function to get the latest version number once with progress tracking
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

#### Section 3: Update Repository Function (Lines 94-168)

**Update function signature and remove VersionNumber parameter:**

**OLD:**
```powershell
function Update-Repository {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FolderPath,
        
        [Parameter(Mandatory = $true)]
        [string]$VersionNumber,
        
        [Parameter(Mandatory = $true)]
        [string]$BranchSuffix,
        # ... rest
    )
```

**NEW:**
```powershell
function Update-Repository {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FolderPath,
        
        [Parameter(Mandatory = $true)]
        [string]$BranchName,
        # ... rest
    )
```

**Update branch name logic (Line 144-146):**

**OLD:**
```powershell
Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Status "Preparing branch information..." -PercentComplete 50
$branchName = "$VersionNumber/$BranchSuffix"
$remoteBranch = "origin/$VersionNumber/$BranchSuffix"
```

**NEW:**
```powershell
Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Status "Preparing branch information..." -PercentComplete 50
$remoteBranch = "origin/$BranchName"
```

#### Section 4: Main Execution (Lines 170-207)

**Remove version detection call (Lines 185-188):**

**OLD (DELETE):**
```powershell
# Get the latest version number once
Write-Host "Determining latest version number..."
$latestVersion = Get-LatestVersionNumber
Write-Host "Latest version detected: $latestVersion" -ForegroundColor Yellow
```

**Update display configuration (Lines 193-201):**

**OLD:**
```powershell
Write-Host "Repository Configuration:" -ForegroundColor White
for ($i = 0; $i -lt $totalRepos; $i++) {
    $repo = $RepositoryConfig[$i]
    Write-Host "  $($i + 1). $($repo.FolderPath) -> $latestVersion/$($repo.BranchSuffix) ($($repo.Description))" -ForegroundColor $repo.DisplayColor
}
```

**NEW:**
```powershell
Write-Host "Repository Configuration:" -ForegroundColor White
for ($i = 0; $i -lt $totalRepos; $i++) {
    $repo = $RepositoryConfig[$i]
    Write-Host "  $($i + 1). $($repo.FolderPath) -> $($repo.BranchName) ($($repo.Description))" -ForegroundColor $repo.DisplayColor
}
```

**Update repository update calls (Lines 204-207):**

**OLD:**
```powershell
for ($i = 0; $i -lt $totalRepos; $i++) {
    $repo = $RepositoryConfig[$i]
    Update-Repository -FolderPath $repo.FolderPath -VersionNumber $latestVersion -BranchSuffix $repo.BranchSuffix -Color $repo.DisplayColor -RepoIndex ($i + 1) -TotalRepos $totalRepos -Description $repo.Description
}
```

**NEW:**
```powershell
for ($i = 0; $i -lt $totalRepos; $i++) {
    $repo = $RepositoryConfig[$i]
    Update-Repository -FolderPath $repo.FolderPath -BranchName $repo.BranchName -Color $repo.DisplayColor -RepoIndex ($i + 1) -TotalRepos $totalRepos -Description $repo.Description
}
```

**Update summary display (Lines 230-234):**

**OLD:**
```powershell
Write-Host "Update Summary:" -ForegroundColor White
for ($i = 0; $i -lt $totalRepos; $i++) {
    $repo = $RepositoryConfig[$i]
    Write-Host "  - $($repo.FolderPath) repository -> $latestVersion/$($repo.BranchSuffix)" -ForegroundColor $repo.DisplayColor
}
Write-Host "`nTarget Version: $latestVersion" -ForegroundColor Green
```

**NEW:**
```powershell
Write-Host "Update Summary:" -ForegroundColor White
for ($i = 0; $i -lt $totalRepos; $i++) {
    $repo = $RepositoryConfig[$i]
    Write-Host "  - $($repo.FolderPath) repository -> $($repo.BranchName)" -ForegroundColor $repo.DisplayColor
}
```

**Summary:** Major refactoring required - approximately 15+ sections to update

---

## 📄 README.md Changes

### Key Changes Required:

| Section | Line Range | Type of Change | Description |
|---------|------------|----------------|-------------|
| Title | 1 | Update | Change "GitLab Repository Setup" to "GitHub Repository Setup" |
| Description | 3 | Update | Change "GitLab repository environments" to "GitHub repository environments" |
| Clone Command | 29, 56, 78 | Update | Change repository URL to GitHub |
| SSH Instructions | 104, 283-286 | Update | Update GitLab URLs to GitHub |
| Repository URL | 427-431 | Update | Change default URLs to GitHub |
| Branch Names | 436-440 | Update | Change to stage-based branches |
| GitLab References | Throughout | Update | Replace all "GitLab" with "GitHub" |
| Troubleshooting | 444-502 | Update | Update for GitHub-specific issues |

### Specific URL Updates:

**Clone Command (Multiple Locations):**
- OLD: `git clone https://github.com/larkinmaxim/RepoSetupandUpdate.git .`
- NEW: Keep as-is (this is the setup scripts repo, not the main repo)

**Repository Configuration:**
- OLD: `https://gitlab.office.transporeon.com/Development/portfolio.git`
- NEW: `https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git`

**SSH Key Setup:**
- OLD: `https://gitlab.office.transporeon.com/-/profile/keys`
- NEW: `https://github.com/settings/keys`

**Branch Documentation:**
- OLD: INT: `3.100/in`, TEST: `3.100/ac`, PROD: `3.100/pd`
- NEW: INT: `stage-in`, TEST: `stage-ac`, PROD: `stage-pd`

---

## 📚 Documentation Files Changes

### docs/STEP1_sshKeygen.md
- Update all GitLab references to GitHub
- Change SSH key registration URL
- Update test connection command

### docs/STEP2_testGitLabConnection.md
- **RENAME TO:** `docs/STEP2_testGitHubConnection.md`
- Update all GitLab references to GitHub
- Update expected response messages
- Update troubleshooting steps

### docs/STEP3_setup-int-repo.md
- Update repository URL
- Change branch name from `3.100/in` to `stage-in`
- Update all examples

### docs/STEP4_setup-test-repo.md
- Update repository URL
- Change branch name from `3.100/ac` to `stage-ac`
- Update all examples

### docs/STEP5_setup-prod-repo.md
- Update repository URL
- Change branch name from `3.100/pd` to `stage-pd`
- Update all examples

### docs/DailyUpdate.md
- Update configuration examples
- Remove version detection documentation
- Update branch naming convention
- Simplify usage instructions

### docs/README.md
- Update all GitLab references to GitHub
- Update repository URLs
- Update authentication instructions

---

## 🔍 Quick Reference Table

### URL Changes

| Type | Old Value | New Value |
|------|-----------|-----------|
| HTTPS | `https://gitlab.office.transporeon.com/Development/portfolio.git` | `https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git` |
| SSH | `git@gitlab.office.transporeon.com:Development/portfolio.git` | `git@github.com:trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git` |
| SSH Test | `git@gitlab.office.transporeon.com` | `git@github.com` |
| Settings | `https://gitlab.office.transporeon.com/-/user_settings/ssh_keys` | `https://github.com/settings/keys` |

### Branch Name Changes

| Environment | Old Branch | New Branch |
|-------------|------------|------------|
| INT | `3.100/in` | `stage-in` |
| TEST | `3.100/ac` | `stage-ac` |
| PROD | `3.100/pd` | `stage-pd` |

### File Changes Summary

| File | Lines Changed | Complexity | Estimated Time |
|------|---------------|------------|----------------|
| STEP1_sshKeygen.ps1 | 4 | Low | 5 min |
| STEP2_testGitLabConnection.ps1 | 19 + rename | Medium | 15 min |
| STEP3_setup-int-repo.ps1 | 3 | Low | 5 min |
| STEP4_setup-test-repo.ps1 | 3 | Low | 5 min |
| STEP5_setup-prod-repo.ps1 | 3 | Low | 5 min |
| DailyUpdate.ps1 | 30+ | High | 45 min |
| README.md | 50+ | High | 60 min |
| docs/*.md (7 files) | 100+ | Medium | 90 min |

**Total Estimated Time:** ~3.5 hours for all changes

---

## ✅ Validation Checklist

After making changes, verify:

- [ ] All scripts use GitHub URLs (no GitLab references)
- [ ] All scripts use new branch names (stage-in, stage-ac, stage-pd)
- [ ] STEP1 generates keys and shows correct GitHub URL
- [ ] STEP2 tests connection to GitHub successfully
- [ ] STEP3, STEP4, STEP5 clone from GitHub with correct branches
- [ ] DailyUpdate.ps1 uses static branch names (no version detection)
- [ ] README.md has all GitHub references updated
- [ ] All docs/*.md files reference GitHub
- [ ] No broken links in documentation
- [ ] All code examples use correct syntax

---

**Document Version:** 1.0  
**Last Updated:** November 4, 2025  
**Purpose:** Detailed change reference for GitLab to GitHub migration

