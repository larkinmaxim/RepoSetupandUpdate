# ========================================================================
# GitHub HTTPS Connection Test Script
# ========================================================================
# This script tests your HTTPS connection to GitHub
# ========================================================================

Write-Host "=== GitHub HTTPS Connection Test ===" -ForegroundColor Cyan
Write-Host ""

# Test repository URL
$TestUrl = "https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git"

# Check Git installation
Write-Host "Checking Git installation..." -ForegroundColor Yellow
try {
    $gitVersion = git --version 2>&1
    Write-Host "[OK] Git is installed: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Git is not installed or not in PATH!" -ForegroundColor Red
    Write-Host "Please install Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press ENTER to close this window..." -ForegroundColor Yellow
    Read-Host
    exit 1
}

Write-Host ""

# Check SSL certificate configuration
Write-Host "Checking SSL certificate configuration..." -ForegroundColor Yellow
$sslCaInfo = git config --global http.sslcainfo

if ([string]::IsNullOrEmpty($sslCaInfo)) {
    Write-Host "[WARNING] No Netskope certificate configured!" -ForegroundColor Yellow
    Write-Host "You may need to run: .\STEP1_setup-netskope-certificate-https.ps1" -ForegroundColor Gray
} else {
    Write-Host "[OK] SSL certificate configured" -ForegroundColor Green
    Write-Host "Certificate path: $sslCaInfo" -ForegroundColor Gray
    
    if (Test-Path $sslCaInfo) {
        Write-Host "[OK] Certificate file exists" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Certificate file not found at configured path!" -ForegroundColor Yellow
        Write-Host "You may need to run: .\STEP1_setup-netskope-certificate-https.ps1" -ForegroundColor Gray
    }
}

Write-Host ""

# Test HTTPS connection
Write-Host "Testing HTTPS connection to GitHub..." -ForegroundColor Yellow
Write-Host "Repository: $TestUrl" -ForegroundColor Gray
Write-Host ""

try {
    Write-Host "Attempting to list remote branches..." -ForegroundColor Gray
    $output = git ls-remote --heads $TestUrl 2>&1
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host ""
        Write-Host "[SUCCESS] HTTPS Connection Working!" -ForegroundColor Green
        Write-Host "Successfully connected to GitHub via HTTPS!" -ForegroundColor Green
        Write-Host ""
        
        # Count and display branches
        $branches = $output | Where-Object { $_ -match 'refs/heads/' }
        $branchCount = ($branches | Measure-Object).Count
        
        Write-Host "Found $branchCount branches:" -ForegroundColor Cyan
        $branches | ForEach-Object {
            if ($_ -match 'refs/heads/(.+)$') {
                Write-Host "  - $($matches[1])" -ForegroundColor Gray
            }
        }
        
        Write-Host ""
        Write-Host "You're ready to clone repositories!" -ForegroundColor Green
        
    } elseif ($output -like "*fatal: could not read Username*" -or $output -like "*Authentication failed*") {
        Write-Host "[WARNING] Authentication Required" -ForegroundColor Yellow
        Write-Host "GitHub is asking for credentials." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "This is normal for private repositories." -ForegroundColor Gray
        Write-Host "When you run the clone scripts, you'll be prompted to authenticate via:" -ForegroundColor Gray
        Write-Host "  - Web browser (OAuth)" -ForegroundColor Gray
        Write-Host "  - Personal Access Token" -ForegroundColor Gray
        Write-Host "  - SSO/SAML (company authentication)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Connection test is OK - authentication will happen during clone." -ForegroundColor Green
        
    } else {
        Write-Host "[ERROR] Connection Failed" -ForegroundColor Red
        Write-Host "Exit code: $exitCode" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Error details:" -ForegroundColor Yellow
        Write-Host $output -ForegroundColor Gray
        Write-Host ""
        
        # Provide troubleshooting steps
        if ($output -like "*SSL certificate problem*" -or $output -like "*certificate*") {
            Write-Host "SSL Certificate Issue Detected!" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Troubleshooting Steps:" -ForegroundColor White
            Write-Host "  1. Run: .\STEP1_setup-netskope-certificate-https.ps1" -ForegroundColor Gray
            Write-Host "  2. Restart PowerShell after certificate installation" -ForegroundColor Gray
            Write-Host "  3. Run this test again" -ForegroundColor Gray
        } elseif ($output -like "*Connection timed out*" -or $output -like "*Failed to connect*") {
            Write-Host "Network Connection Issue Detected!" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Troubleshooting Steps:" -ForegroundColor White
            Write-Host "  1. Check your internet connection" -ForegroundColor Gray
            Write-Host "  2. Verify you're connected to the company VPN (if required)" -ForegroundColor Gray
            Write-Host "  3. Check if proxy settings are correct" -ForegroundColor Gray
        } else {
            Write-Host "General Troubleshooting Steps:" -ForegroundColor White
            Write-Host "  1. Ensure Netskope certificate is installed: .\STEP1_setup-netskope-certificate-https.ps1" -ForegroundColor Gray
            Write-Host "  2. Check internet connection and VPN" -ForegroundColor Gray
            Write-Host "  3. Verify Git configuration: git config --global --list" -ForegroundColor Gray
        }
    }
    
} catch {
    Write-Host "[ERROR] Test Failed" -ForegroundColor Red
    Write-Host "Exception: $($_.Exception.Message)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

# Additional diagnostics
Write-Host ""
Write-Host "Additional Diagnostics:" -ForegroundColor Cyan
Write-Host "Current git configuration (global):" -ForegroundColor Gray
$gitConfig = git config --global --list | Select-String -Pattern "http|ssl|credential"
if ($gitConfig) {
    $gitConfig | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
} else {
    Write-Host "  No HTTP/SSL related configurations found" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Test completed!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press ENTER to close this window..." -ForegroundColor Yellow
Read-Host

