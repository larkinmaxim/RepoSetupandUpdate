param(
    [string]$RemoteUrl = "https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git",
    [string]$BranchName = "stage-pd",
    [string]$FolderName = "PROD"
)

# IMMEDIATE DEBUG - This should show even if there are errors later
Write-Host "=== SCRIPT STARTED ===" -ForegroundColor Magenta
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Magenta
Write-Host "Execution Policy: $(Get-ExecutionPolicy)" -ForegroundColor Magenta
Write-Host "Current Location: $(Get-Location)" -ForegroundColor Magenta
Write-Host "Script Root: $PSScriptRoot" -ForegroundColor Magenta

# Test if we can pause immediately
try {
    Write-Host "Testing pause functionality..." -ForegroundColor Magenta
    Start-Sleep -Seconds 1
    Write-Host "Pause test successful" -ForegroundColor Green
} catch {
    Write-Host "ERROR in pause test: $($_.Exception.Message)" -ForegroundColor Red
}

# Trap any terminating errors
trap {
    Write-Host "TRAPPED ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Error occurred at line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
    Write-Host "Press any key to close..." -ForegroundColor Yellow
    try {
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } catch {
        Read-Host "Press Enter to continue"
    }
    exit 1
}

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

# Function to handle errors and pause before exit
function Exit-WithPause {
    param(
        [int]$ExitCode = 1,
        [string]$Message = "Script encountered an error"
    )
    Write-Host "`n$Message" -ForegroundColor Red
    Write-Host "Press any key to close this window..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit $ExitCode
}

# Function for debug output
function Write-Debug {
    param([string]$Message)
    Write-Host "[DEBUG] $Message" -ForegroundColor Magenta
}

Write-Host "=== PROD REPOSITORY SETUP ===" -ForegroundColor Green
Write-Host "This script will set up the PROD repository for branch: $BranchName" -ForegroundColor Cyan

# Debug: Show all parameters
Write-Debug "Script parameters:"
Write-Debug "  RemoteUrl: '$RemoteUrl'"
Write-Debug "  BranchName: '$BranchName'"  
Write-Debug "  FolderName: '$FolderName'"

# Variables using script location as base directory (PRD requirement)
$BaseDirectory = $PSScriptRoot
if ([string]::IsNullOrEmpty($BaseDirectory)) {
    $BaseDirectory = Get-Location
    Write-Host "Warning: PSScriptRoot is null, using current location: $BaseDirectory" -ForegroundColor Yellow
}

Write-Debug "BaseDirectory determined: '$BaseDirectory'"

if ([string]::IsNullOrEmpty($FolderName)) {
    Exit-WithPause -Message "Error: FolderName parameter is null or empty. Expected value: 'PROD'"
}

$TargetPath = Join-Path $BaseDirectory $FolderName
Write-Debug "TargetPath created: '$TargetPath'"

# Validate that TargetPath was created successfully
if ([string]::IsNullOrEmpty($TargetPath)) {
    Exit-WithPause -Message "Error: Failed to create target path from BaseDirectory '$BaseDirectory' and FolderName '$FolderName'"
}

Write-Host "Base Directory: $BaseDirectory" -ForegroundColor Cyan
Write-Host "Target Path: $TargetPath" -ForegroundColor Cyan
Write-Host "Remote URL: $RemoteUrl" -ForegroundColor Cyan
Write-Host "Branch: $BranchName" -ForegroundColor Cyan

# Ask to continue
$continue = Read-Host "`nContinue with PROD setup? (Y/N)"
if ($continue -notmatch "^[Yy]") {
    Write-Host "Cancelled by user" -ForegroundColor Yellow
    Write-Host "Press any key to close this window..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
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

# Enable Git long path support for Windows (fixes "Filename too long" errors)
Write-Host "Configuring Git for long path support..." -ForegroundColor Gray
git config --global core.longpaths true
Write-Host "[OK] Git long path support enabled" -ForegroundColor Green

# Simple clone with real-time Git progress (Ctrl+C responsive)
try {
    Write-Host "`n[STARTING] Clone operation..." -ForegroundColor Yellow
    Write-Host "Git will show progress directly below. Press Ctrl+C to cancel." -ForegroundColor Gray
    Write-Host "----------------------------------------" -ForegroundColor Gray
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    # Use git clone directly - this allows Ctrl+C to work properly
    # Git's --progress flag will show real-time progress to the console
    # --depth 1 creates a shallow clone (only latest commit) for faster, more reliable downloads
    git clone -b $BranchName --depth 1 --progress $RemoteUrl $TargetPath
    
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
        
        Pop-Location
        Write-Host "[OK] Repository configured (using HTTPS authentication)" -ForegroundColor Green
        
    } else {
        Write-Host "`n[FAIL] Repository clone failed (Exit code: $($cloneResult.ExitCode))" -ForegroundColor Red
        Write-Host ""
        
        # Specific troubleshooting for Exit Code 128
        if ($cloneResult.ExitCode -eq 128) {
            Write-Host "Exit Code 128 - Authentication or Connection Failure" -ForegroundColor Yellow
            Write-Host "================================================================" -ForegroundColor Yellow
            Write-Host ""
            
            # HTTPS troubleshooting
            Write-Host "Detected: HTTPS URL (https://github.com/...)" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "Common Causes for HTTPS:" -ForegroundColor White
            Write-Host "  1. Netskope certificate not configured" -ForegroundColor Gray
            Write-Host "  2. SSL/TLS verification failure" -ForegroundColor Gray
            Write-Host "  3. Git credential manager issues" -ForegroundColor Gray
            Write-Host "  4. Network connectivity issues" -ForegroundColor Gray
            Write-Host "  5. GitHub authentication not set up (SSO/SAML)" -ForegroundColor Gray
            Write-Host ""
            Write-Host "Troubleshooting Steps:" -ForegroundColor Yellow
            Write-Host "  1. Run: .\STEP1_setup-netskope-certificate-https.ps1 (if not done)" -ForegroundColor White
            Write-Host "  2. Verify: git config --global http.sslcainfo" -ForegroundColor White
            Write-Host "  3. Test HTTPS: git ls-remote --heads $RemoteUrl" -ForegroundColor White
            Write-Host "  4. Check GitHub SSO authorization at: https://github.com/settings/connections/applications" -ForegroundColor White
        } else {
            # Generic error message for other exit codes
            Write-Host "Common causes:" -ForegroundColor White
            Write-Host "  - Network connectivity issues" -ForegroundColor Gray
            Write-Host "  - Authentication problems (ensure STEP1 & STEP2 completed)" -ForegroundColor Gray
            Write-Host "  - Branch '$BranchName' does not exist" -ForegroundColor Gray
            Write-Host "  - Repository URL is incorrect" -ForegroundColor Gray
            Write-Host ""
            Write-Host "Troubleshooting:" -ForegroundColor Yellow
            Write-Host "  - Run: .\diagnosticcheck.ps1" -ForegroundColor White
            Write-Host "  - Run: .\STEP2_testGithubConnection.ps1" -ForegroundColor White
        }
        
        Write-Host ""
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
Write-Host "You can now use Git operations and TortoiseGit integration." -ForegroundColor Gray


Read-Host "`nPress Enter to exit"
exit 0 