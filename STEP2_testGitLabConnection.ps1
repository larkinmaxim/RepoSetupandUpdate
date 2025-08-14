# ========================================================================
# GitLab SSH Connection Test Script
# ========================================================================
# This script tests your SSH connection to GitLab and displays the results
# ========================================================================

Write-Host "=== GitLab SSH Connection Test ===" -ForegroundColor Cyan
Write-Host ""

# Check if SSH key exists
$keyPath = "$env:USERPROFILE\.ssh\id_rsa"
$publicKeyPath = "$env:USERPROFILE\.ssh\id_rsa.pub"

if (-not (Test-Path $keyPath) -or -not (Test-Path $publicKeyPath)) {
    Write-Host "[ERROR] SSH Key Missing!" -ForegroundColor Red
    Write-Host "Private key: $keyPath" -ForegroundColor Gray
    Write-Host "Public key: $publicKeyPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Please run STEP1_sshKeygen.ps1 first to generate your SSH key." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press ENTER to close this window..." -ForegroundColor Yellow
    Read-Host
    exit 1
}

# Display key information
Write-Host "[OK] SSH Key Found!" -ForegroundColor Green
Write-Host "Key location: $keyPath" -ForegroundColor Gray

# Get key fingerprint
try {
    $fingerprint = ssh-keygen -lf $publicKeyPath 2>$null
    if ($fingerprint) {
        Write-Host "Key fingerprint: $fingerprint" -ForegroundColor Gray
    }
} catch {
    Write-Host "[WARNING] Could not read key fingerprint" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Testing connection to GitLab..." -ForegroundColor Yellow

# Test the connection
$result = ssh -o ConnectTimeout=10 -o BatchMode=yes -T git@gitlab.office.transporeon.com 2>&1
$exitCode = $LASTEXITCODE

Write-Host ""

if ($exitCode -eq 0 -and $result -like "*Welcome to GitLab*") {
    Write-Host "[SUCCESS] Connection Working!" -ForegroundColor Green
    Write-Host "SSH connection to GitLab is working perfectly!" -ForegroundColor Green
    Write-Host ""
    Write-Host "GitLab Response:" -ForegroundColor Cyan
    Write-Host $result -ForegroundColor White
} elseif ($result -like "*Permission denied*") {
    Write-Host "[ERROR] AUTHENTICATION FAILED" -ForegroundColor Red
    Write-Host "Your SSH key is not added to GitLab or is incorrect." -ForegroundColor Red
    Write-Host ""
    Write-Host "To fix this:" -ForegroundColor Yellow
    Write-Host "1. Copy your public key: Get-Content '$publicKeyPath'" -ForegroundColor Gray
    Write-Host "2. Add it to GitLab: https://gitlab.office.transporeon.com/-/profile/keys" -ForegroundColor Gray
} elseif ($result -like "*Connection refused*" -or $result -like "*Connection timed out*") {
    Write-Host "[ERROR] CONNECTION FAILED" -ForegroundColor Red
    Write-Host "Cannot connect to GitLab server." -ForegroundColor Red
    Write-Host "Check your network connection or VPN status." -ForegroundColor Yellow
} else {
    Write-Host "[WARNING] UNKNOWN RESULT" -ForegroundColor Yellow
    Write-Host "Exit code: $exitCode" -ForegroundColor Gray
    Write-Host "Output: $result" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Test completed!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press ENTER to close this window..." -ForegroundColor Yellow
Read-Host 