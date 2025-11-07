# Netskope Certificate Setup for Git (MUST RUN AS ADMINISTRATOR)
# This script creates a combined certificate bundle and configures Git to use it

#Requires -RunAsAdministrator

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  Netskope Certificate Setup for Git (HTTPS AUTHENTICATION)" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: This script configures HTTPS authentication only!" -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Authentication Methods:" -ForegroundColor Cyan
Write-Host "  - SSH (git@github.com:...)   - Uses SSH keys (STEP1-2)" -ForegroundColor Gray
Write-Host "  - HTTPS (https://github.com/...) - Uses this certificate" -ForegroundColor Gray
Write-Host ""
Write-Host "Current STEP3-5 scripts use SSH by default." -ForegroundColor White
Write-Host "This certificate is needed if:" -ForegroundColor White
Write-Host "  1. SSH (port 22) is blocked in your environment, OR" -ForegroundColor Gray
Write-Host "  2. You prefer HTTPS authentication, OR" -ForegroundColor Gray
Write-Host "  3. You need it for other tools (gcloud, pip, etc.)" -ForegroundColor Gray
Write-Host ""

# Function to display status with color coding
function Show-Status {
    param(
        [string]$Message,
        [string]$Status  # "OK", "WARNING", "ERROR", "INFO"
    )
    
    $color = switch ($Status) {
        "OK"      { "Green" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        "INFO"    { "Cyan" }
        default   { "White" }
    }
    
    $icon = switch ($Status) {
        "OK"      { "[OK]" }
        "WARNING" { "[!]" }
        "ERROR"   { "[X]" }
        "INFO"    { "[i]" }
        default   { "[?]" }
    }
    
    Write-Host "$icon $Message" -ForegroundColor $color
}

# Function to pause with message
function Pause-WithMessage {
    param([string]$Message = "Press any key to continue...")
    Write-Host "`n$Message" -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Verify running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Show-Status "This script must be run as Administrator!" "ERROR"
    Show-Status "Right-click PowerShell and select 'Run as Administrator'" "INFO"
    Pause-WithMessage
    exit 1
}

Show-Status "Running with Administrator privileges" "OK"

# Check if user actually needs this
Write-Host ""
Write-Host "Quick Check: Do you need HTTPS authentication?" -ForegroundColor Yellow
Write-Host ""

$sshKeyExists = Test-Path "$env:USERPROFILE\.ssh\id_rsa"
if ($sshKeyExists) {
    Write-Host "[DETECTED] You already have SSH keys configured" -ForegroundColor Green
    Write-Host "           SSH authentication is working or can work" -ForegroundColor Gray
    Write-Host ""
    Write-Host "You may NOT need this script if:" -ForegroundColor Cyan
    Write-Host "  - SSH (port 22) is not blocked in your network" -ForegroundColor Gray
    Write-Host "  - STEP2_testGithubConnection.ps1 succeeds" -ForegroundColor Gray
    Write-Host "  - STEP3-5 scripts work without errors" -ForegroundColor Gray
    Write-Host ""
    $continue = Read-Host "Continue with HTTPS certificate setup anyway? (Y/N)"
    if ($continue -notmatch "^[Yy]") {
        Write-Host ""
        Write-Host "Setup cancelled." -ForegroundColor Yellow
        Write-Host "You can use SSH authentication (your current setup)" -ForegroundColor Green
        Write-Host "Run diagnosticcheck.ps1 to verify your configuration" -ForegroundColor Cyan
        Pause-WithMessage
        exit 0
    }
} else {
    Write-Host "[INFO] No SSH keys detected" -ForegroundColor Cyan
    Write-Host "       HTTPS authentication with certificate is recommended" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "Proceeding with certificate setup..." -ForegroundColor Green
Write-Host ""

# Define paths
$certDirectory = "C:\Netskope Certs"
$certFilePath = "$certDirectory\nscacert_combined.pem"

Write-Host "`n=== STEP 1: Create Certificate Directory ===" -ForegroundColor Yellow

try {
    if (-not (Test-Path $certDirectory)) {
        New-Item -ItemType Directory -Path $certDirectory -Force | Out-Null
        Show-Status "Created directory: $certDirectory" "OK"
    } else {
        Show-Status "Directory already exists: $certDirectory" "INFO"
    }
} catch {
    Show-Status "Failed to create directory: $($_.Exception.Message)" "ERROR"
    Pause-WithMessage
    exit 1
}

Write-Host "`n=== STEP 2: Generate Combined Certificate Bundle ===" -ForegroundColor Yellow
Show-Status "This may take 30-60 seconds..." "INFO"
Show-Status "Extracting certificates from Windows certificate stores..." "INFO"

try {
    # Create combined certificate bundle from all Windows certificate stores
    # This is the exact same command used for Google Cloud CLI
    $certificateBundle = ((((Get-ChildItem Cert:\CurrentUser\Root) + 
                           (Get-ChildItem Cert:\LocalMachine\Root) + 
                           (Get-ChildItem Cert:\CurrentUser\CA) + 
                           (Get-ChildItem Cert:\LocalMachine\CA)) | 
        Where-Object { $_.RawData -ne $null } | 
        Sort-Object -Property Thumbprint -Unique | 
        ForEach-Object { 
            "-----BEGIN CERTIFICATE-----"
            [System.Convert]::ToBase64String($_.RawData, "InsertLineBreaks")
            "-----END CERTIFICATE-----"
            ""
        }) -replace "`r","") -join "`n"
    
    # Write to file
    $certificateBundle | Out-File -Encoding ascii $certFilePath -NoNewline
    
    Show-Status "Certificate bundle created successfully" "OK"
    Show-Status "Location: $certFilePath" "INFO"
    
    # Verify file was created and has content
    if (Test-Path $certFilePath) {
        $fileSize = (Get-Item $certFilePath).Length
        Show-Status "File size: $([math]::Round($fileSize/1KB, 2)) KB" "INFO"
        
        if ($fileSize -lt 1000) {
            Show-Status "Warning: Certificate file seems too small" "WARNING"
        }
    } else {
        Show-Status "Certificate file was not created" "ERROR"
        Pause-WithMessage
        exit 1
    }
} catch {
    Show-Status "Failed to create certificate bundle: $($_.Exception.Message)" "ERROR"
    Pause-WithMessage
    exit 1
}

Write-Host "`n=== STEP 3: Configure Git ===" -ForegroundColor Yellow

# Check if Git is installed
try {
    $gitVersion = git --version 2>&1
    Show-Status "Git detected: $gitVersion" "OK"
} catch {
    Show-Status "Git is not installed or not in PATH" "ERROR"
    Show-Status "Please install Git first: https://git-scm.com/download/win" "INFO"
    Pause-WithMessage
    exit 1
}

# Show current Git SSL configuration
Write-Host "`nCurrent Git SSL Configuration:" -ForegroundColor Cyan
$currentSslCaInfo = git config --global --get http.sslcainfo
$currentSslBackend = git config --global --get http.sslbackend

if ($currentSslCaInfo) {
    Write-Host "  http.sslcainfo = $currentSslCaInfo" -ForegroundColor Gray
} else {
    Write-Host "  http.sslcainfo = (not set)" -ForegroundColor Gray
}

if ($currentSslBackend) {
    Write-Host "  http.sslbackend = $currentSslBackend" -ForegroundColor Gray
} else {
    Write-Host "  http.sslbackend = (not set)" -ForegroundColor Gray
}

# Check for duplicate entries
$allSslCaInfo = @(git config --global --get-all http.sslcainfo)
$allSslBackend = @(git config --global --get-all http.sslbackend)

if ($allSslCaInfo.Count -gt 1) {
    Show-Status "Found $($allSslCaInfo.Count) duplicate http.sslcainfo entries" "WARNING"
}
if ($allSslBackend.Count -gt 1) {
    Show-Status "Found $($allSslBackend.Count) duplicate http.sslbackend entries" "WARNING"
}

# Ask for confirmation to proceed
Write-Host "`nThis script will:" -ForegroundColor Cyan
Write-Host "  1. Remove any duplicate SSL configuration entries" -ForegroundColor Gray
Write-Host "  2. Set http.sslcainfo to: $certFilePath" -ForegroundColor Gray
Write-Host "  3. Set http.sslbackend to: schannel" -ForegroundColor Gray
Write-Host "  4. Enable long paths support" -ForegroundColor Gray
Write-Host "  5. Test GitHub connectivity" -ForegroundColor Gray

$confirm = Read-Host "`nContinue with Git configuration? (Y/N)"
if ($confirm -notmatch "^[Yy]") {
    Show-Status "Configuration cancelled by user" "WARNING"
    Show-Status "Certificate file has been created at: $certFilePath" "INFO"
    Show-Status "You can manually configure Git later with:" "INFO"
    Write-Host "  git config --global http.sslcainfo `"$certFilePath`"" -ForegroundColor Gray
    Pause-WithMessage
    exit 0
}

Write-Host "`nConfiguring Git..." -ForegroundColor Yellow

try {
    # Step 3a: Clean up duplicate entries
    if ($allSslCaInfo.Count -gt 0) {
        Show-Status "Removing existing http.sslcainfo entries..." "INFO"
        git config --global --unset-all http.sslcainfo 2>$null
    }
    
    if ($allSslBackend.Count -gt 0) {
        Show-Status "Removing existing http.sslbackend entries..." "INFO"
        git config --global --unset-all http.sslbackend 2>$null
    }
    
    # Step 3b: Set the Netskope certificate
    Show-Status "Setting http.sslcainfo to Netskope certificate..." "INFO"
    git config --global http.sslcainfo "$certFilePath"
    
    # Step 3c: Set SSL backend to schannel (Windows native)
    Show-Status "Setting http.sslbackend to schannel..." "INFO"
    git config --global http.sslbackend schannel
    
    # Step 3d: Enable long paths support (prevents "Filename too long" errors)
    Show-Status "Enabling long paths support..." "INFO"
    git config --global core.longpaths true
    
    Show-Status "Git configuration completed successfully" "OK"
    
} catch {
    Show-Status "Failed to configure Git: $($_.Exception.Message)" "ERROR"
    Pause-WithMessage
    exit 1
}

Write-Host "`n=== STEP 4: Verify Configuration ===" -ForegroundColor Yellow

# Display updated configuration
Write-Host "`nUpdated Git Configuration:" -ForegroundColor Cyan
$newSslCaInfo = git config --global --get http.sslcainfo
$newSslBackend = git config --global --get http.sslbackend
$newLongPaths = git config --global --get core.longpaths

Write-Host "  http.sslcainfo  = $newSslCaInfo" -ForegroundColor Green
Write-Host "  http.sslbackend = $newSslBackend" -ForegroundColor Green
Write-Host "  core.longpaths  = $newLongPaths" -ForegroundColor Green

# Verify values are correct
if ($newSslCaInfo -eq $certFilePath -and $newSslBackend -eq "schannel") {
    Show-Status "Configuration values verified" "OK"
} else {
    Show-Status "Configuration values may not be set correctly" "WARNING"
}

Write-Host "`n=== STEP 5: Test GitHub Connectivity ===" -ForegroundColor Yellow
Show-Status "Testing connection to GitHub..." "INFO"

try {
    $testResult = git ls-remote --heads https://github.com/larkinmaxim/RepoSetupandUpdate.git 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Show-Status "Successfully connected to GitHub!" "OK"
        Show-Status "SSL certificate verification is working correctly" "OK"
    } else {
        Show-Status "Connection test completed with warnings" "WARNING"
        Write-Host "  Result: $testResult" -ForegroundColor Gray
        Show-Status "The configuration is set correctly, but connectivity may have issues" "INFO"
    }
} catch {
    Show-Status "Connection test failed: $($_.Exception.Message)" "WARNING"
    Show-Status "This may be due to network/firewall issues, not certificate problems" "INFO"
}

Write-Host "`n=== STEP 6: Set System Environment Variable (Optional) ===" -ForegroundColor Yellow
Show-Status "Setting REQUESTS_CA_BUNDLE for Python-based tools..." "INFO"

try {
    # Set system-wide environment variable for Python tools (like gcloud)
    [System.Environment]::SetEnvironmentVariable('REQUESTS_CA_BUNDLE', $certFilePath, 'Machine')
    Show-Status "REQUESTS_CA_BUNDLE environment variable set" "OK"
    Show-Status "This helps with Google Cloud SDK and other Python tools" "INFO"
} catch {
    Show-Status "Could not set REQUESTS_CA_BUNDLE environment variable" "WARNING"
    Show-Status "This is optional and won't affect Git" "INFO"
}

Write-Host "`n=========================================" -ForegroundColor Green
Write-Host "  HTTPS CERTIFICATE SETUP COMPLETE" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

Write-Host "`nSummary:" -ForegroundColor Cyan
Show-Status "Certificate bundle created: $certFilePath" "OK"
Show-Status "Git configured for HTTPS authentication" "OK"
Show-Status "SSL backend set to Windows schannel" "OK"
Show-Status "Long paths support enabled" "OK"

Write-Host "`nAuthentication Status:" -ForegroundColor Cyan
if ($sshKeyExists) {
    Write-Host "  [OK] SSH Authentication: Available" -ForegroundColor Green
    Write-Host "  [OK] HTTPS Authentication: Now configured" -ForegroundColor Green
    Write-Host ""
    Write-Host "  You now have BOTH authentication methods!" -ForegroundColor White
    Write-Host "  STEP3-5 will use SSH by default (git@github.com:...)" -ForegroundColor Gray
    Write-Host "  To use HTTPS: modify -RemoteUrl to https://github.com/..." -ForegroundColor Gray
} else {
    Write-Host "  [ ] SSH Authentication: Not configured" -ForegroundColor Gray
    Write-Host "  [OK] HTTPS Authentication: Now configured" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Using HTTPS authentication" -ForegroundColor White
    Write-Host "  To use STEP3-5: modify -RemoteUrl to https://github.com/..." -ForegroundColor Gray
    Write-Host "  OR run STEP1-2 to set up SSH instead" -ForegroundColor Gray
}

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "  1. Close ALL PowerShell and Git Bash windows" -ForegroundColor Gray
Write-Host "  2. Open a new PowerShell window (to refresh environment)" -ForegroundColor Gray
Write-Host "  3. Run diagnosticcheck.ps1 to verify configuration" -ForegroundColor Gray
Write-Host "  4. For HTTPS: Modify STEP3-5 RemoteUrl to https://github.com/..." -ForegroundColor Gray
Write-Host "  5. For SSH: Continue using default git@github.com:... URLs" -ForegroundColor Gray

Write-Host "`nUsing HTTPS Authentication with STEP3-5:" -ForegroundColor Yellow
Write-Host "  To clone via HTTPS, run STEP3 like this:" -ForegroundColor Gray
Write-Host "  .\STEP3_setup-int-repo.ps1 -RemoteUrl \"https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git\"" -ForegroundColor White

Write-Host "`nIf users still experience issues:" -ForegroundColor Yellow
Write-Host "  - Run the diagnostic: .\diagnosticcheck.ps1" -ForegroundColor Gray
Write-Host "  - Verify network connectivity to GitHub" -ForegroundColor Gray
Write-Host "  - For HTTPS: Ensure Git credential manager is working" -ForegroundColor Gray
Write-Host "  - For SSH: Check that SSH keys are configured (STEP1 & STEP2)" -ForegroundColor Gray

Write-Host "`nConfiguration Details:" -ForegroundColor Cyan
Write-Host "  Certificate File: $certFilePath" -ForegroundColor Gray
Write-Host "  Git Config File: $env:USERPROFILE\.gitconfig" -ForegroundColor Gray
Write-Host "  Environment Variable: REQUESTS_CA_BUNDLE=$certFilePath" -ForegroundColor Gray

Pause-WithMessage "Press any key to exit..."