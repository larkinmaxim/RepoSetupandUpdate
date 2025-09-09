param(
    [string]$RemoteUrl = "https://gitlab.office.transporeon.com/Development/portfolio.git",
    [string]$BranchName = "3.100/pd",
    [string]$FolderName = "PROD"
)

# Script for setting up PROD repository only
# Follows PRD requirements for base directory - direct clone without validation
#
# Usage Examples:
#   .\setup-prod-repo.ps1                                   # Basic usage - direct clone, no validation
#   .\setup-prod-repo.ps1 -BranchName "3.100/pd"            # Specify custom branch
#   .\setup-prod-repo.ps1 -FolderName "PROD"                # Specify custom folder name
#   .\setup-prod-repo.ps1 -RemoteUrl "https://..."          # Specify custom repository URL
#
# NOTE: Ctrl+C now works properly to cancel the clone operation!

Write-Host "=== PROD REPOSITORY SETUP ===" -ForegroundColor Green
Write-Host "This script will set up the PROD repository for branch: $BranchName" -ForegroundColor Cyan

# Variables using script location as base directory (PRD requirement)
$BaseDirectory = $PSScriptRoot
if ([string]::IsNullOrEmpty($BaseDirectory)) {
    $BaseDirectory = Get-Location
    Write-Host "Warning: PSScriptRoot is null, using current location: $BaseDirectory" -ForegroundColor Yellow
}

if ([string]::IsNullOrEmpty($FolderName)) {
    Write-Host "Error: FolderName parameter is null or empty" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

$TargetPath = Join-Path $BaseDirectory $FolderName

# Validate that TargetPath was created successfully
if ([string]::IsNullOrEmpty($TargetPath)) {
    Write-Host "Error: Failed to create target path from BaseDirectory '$BaseDirectory' and FolderName '$FolderName'" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Base Directory: $BaseDirectory" -ForegroundColor Cyan
Write-Host "Target Path: $TargetPath" -ForegroundColor Cyan
Write-Host "Remote URL: $RemoteUrl" -ForegroundColor Cyan
Write-Host "Branch: $BranchName" -ForegroundColor Cyan

# Ask to continue
$continue = Read-Host "`nContinue with PROD setup? (Y/N)"
if ($continue -notmatch "^[Yy]") {
    Write-Host "Cancelled" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 0
}


Write-Host "`n=== REPOSITORY SETUP ===" -ForegroundColor Yellow

# Handle existing directory
if (Test-Path $TargetPath) {
    Write-Host "Existing PROD folder found" -ForegroundColor Yellow
    $overwrite = Read-Host "Remove existing folder and start fresh? (Y/N)"
    if ($overwrite -match "^[Yy]") {
        if (Test-Path "PROD") { Remove-Item "PROD" -Recurse -Force -ErrorAction SilentlyContinue; Write-Host "PROD directory removed" -ForegroundColor Green } else { Write-Host "PROD directory does not exist" -ForegroundColor Yellow }
    } else {
        Write-Host "Setup cancelled - existing folder preserved" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 0
    }
}

# Clone the repository
Write-Host "Cloning PROD repository (branch: $BranchName)..." -ForegroundColor Cyan
Write-Host "This may take several minutes for large repositories..." -ForegroundColor Gray
Write-Host "Press Ctrl+C at any time to cancel the operation" -ForegroundColor Yellow

# Simple clone with real-time Git progress (Ctrl+C responsive)
try {
    Write-Host "`n[STARTING] Clone operation..." -ForegroundColor Yellow
    Write-Host "Git will show progress directly below. Press Ctrl+C to cancel." -ForegroundColor Gray
    Write-Host "----------------------------------------" -ForegroundColor Gray
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    # Use git clone directly - this allows Ctrl+C to work properly
    # Git's --progress flag will show real-time progress to the console
    git clone -b $BranchName --progress $RemoteUrl $TargetPath
    
    $stopwatch.Stop()
    $cloneResult = @{
        Success = $LASTEXITCODE -eq 0
        ExitCode = $LASTEXITCODE
    }
    
    Write-Host "----------------------------------------" -ForegroundColor Gray
    Write-Host "[TIMING] Operation completed in $($stopwatch.Elapsed.TotalMinutes.ToString('F1')) minutes" -ForegroundColor Cyan
     
     if ($cloneResult.Success) {
        Write-Host "[OK] PROD repository cloned successfully" -ForegroundColor Green
        
        # Configure the repository
        Write-Host "Configuring repository..." -ForegroundColor Gray
        Push-Location $TargetPath
        
        # Basic Git configuration
        git config pull.rebase false
        git config push.default simple
        
        # TortoiseGit-friendly configurations
        git config core.autocrlf true
        git config core.filemode false
        git config gui.recentrepo $TargetPath
        
        # Configure SSH authentication (switch from HTTPS to SSH)
        Write-Host "Configuring SSH authentication..." -ForegroundColor Gray
        git remote set-url origin git@gitlab.office.transporeon.com:Development/portfolio.git
        Write-Host "[OK] Remote URL configured for SSH authentication" -ForegroundColor Green
        
        Pop-Location
        Write-Host "[OK] Repository configured" -ForegroundColor Green
        
    } else {
        Write-Host "[FAIL] Repository clone failed (Exit code: $($cloneResult.ExitCode))" -ForegroundColor Red
        Write-Host "Common causes:" -ForegroundColor Yellow
        Write-Host "  - Network connectivity issues" -ForegroundColor Gray
        Write-Host "  - SSH authentication problems (ensure STEP1 & STEP2 completed successfully)" -ForegroundColor Gray
        Write-Host "  - Branch '$BranchName' does not exist" -ForegroundColor Gray
        Write-Host "  - Repository URL is incorrect" -ForegroundColor Gray
        Write-Host "`nTip: Run STEP1_sshKeygen.ps1 and STEP2_testGitLabConnection.ps1 first" -ForegroundColor Cyan
        Read-Host "Press Enter to exit"
        exit 1
    }
} catch {
    Write-Host "[FAIL] Clone operation failed: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}


Write-Host "`n=== SETUP COMPLETE ===" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

# Summary
Write-Host "Repository Status:" -ForegroundColor Cyan
Write-Host "  [OK] PROD repository setup complete" -ForegroundColor Green
Write-Host "  Location: $TargetPath" -ForegroundColor Gray
Write-Host "  Branch: $BranchName" -ForegroundColor Gray

# TortoiseGit verification
Write-Host "`nTortoiseGit Integration:" -ForegroundColor Cyan
if (Get-Command "TortoiseGitProc.exe" -ErrorAction SilentlyContinue) {
    Write-Host "  [OK] TortoiseGit detected" -ForegroundColor Green
    Write-Host "  Repository is ready for TortoiseGit operations" -ForegroundColor Gray
} else {
    Write-Host "  [INFO] TortoiseGit not detected - Git command line operations available" -ForegroundColor Yellow
}


Write-Host "`nPROD setup completed successfully!" -ForegroundColor Green
Write-Host "You can now test Git operations and TortoiseGit integration." -ForegroundColor Gray
Write-Host "All three repository setups (INT, TEST, PROD) are now available." -ForegroundColor Gray

Read-Host "`nPress Enter to exit"
exit 0 