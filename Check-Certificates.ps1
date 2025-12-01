# Certificate Health Check Script
# Run this periodically to check if certificates need updating

Write-Host "=== Certificate Health Check ===" -ForegroundColor Cyan
Write-Host ""

$certFilePath = "C:\Netskope Certs\nscacert_combined.pem"

# Check 1: Does certificate file exist?
if (-not (Test-Path $certFilePath)) {
    Write-Host "[ERROR] Certificate bundle not found!" -ForegroundColor Red
    Write-Host "Location: $certFilePath" -ForegroundColor Gray
    Write-Host "Solution: Run STEP1_setup-netskope-certificate-https.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Certificate bundle exists" -ForegroundColor Green
Write-Host "Location: $certFilePath" -ForegroundColor Gray

# Check 2: File age
$fileAge = (Get-Date) - (Get-Item $certFilePath).LastWriteTime
$daysOld = [math]::Round($fileAge.TotalDays)

Write-Host "Certificate bundle age: $daysOld days old" -ForegroundColor Gray

if ($daysOld -gt 365) {
    Write-Host "[WARNING] Certificate bundle is over 1 year old!" -ForegroundColor Yellow
    Write-Host "Recommendation: Re-run STEP1 to refresh certificates" -ForegroundColor Yellow
} elseif ($daysOld -gt 730) {
    Write-Host "[CRITICAL] Certificate bundle is over 2 years old!" -ForegroundColor Red
    Write-Host "Action required: Re-run STEP1_setup-netskope-certificate-https.ps1" -ForegroundColor Red
} else {
    Write-Host "[OK] Certificate bundle is recent" -ForegroundColor Green
}

# Check 3: Git configuration
Write-Host ""
Write-Host "Checking Git configuration..." -ForegroundColor Cyan
$gitSslCaInfo = git config --global --get http.sslcainfo

if ($gitSslCaInfo -eq $certFilePath) {
    Write-Host "[OK] Git is configured to use certificate bundle" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Git configuration mismatch!" -ForegroundColor Red
    Write-Host "Expected: $certFilePath" -ForegroundColor Gray
    Write-Host "Actual: $gitSslCaInfo" -ForegroundColor Gray
    Write-Host "Solution: Re-run STEP1_setup-netskope-certificate-https.ps1" -ForegroundColor Yellow
}

# Check 4: Test GitHub connection
Write-Host ""
Write-Host "Testing GitHub HTTPS connection..." -ForegroundColor Cyan
$testUrl = "https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git"

try {
    $testResult = git ls-remote --heads $testUrl 2>&1
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host "[OK] GitHub HTTPS connection successful!" -ForegroundColor Green
        Write-Host "Certificates are working correctly" -ForegroundColor Green
    } elseif ($testResult -like "*certificate*" -or $testResult -like "*SSL*") {
        Write-Host "[ERROR] Certificate verification failed!" -ForegroundColor Red
        Write-Host "This usually means certificates need updating" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Solution:" -ForegroundColor Yellow
        Write-Host "  1. Run: .\STEP1_setup-netskope-certificate-https.ps1" -ForegroundColor White
        Write-Host "  2. This will extract fresh certificates from Windows" -ForegroundColor White
    } else {
        Write-Host "[WARNING] Connection test returned unexpected result" -ForegroundColor Yellow
        Write-Host "Exit code: $exitCode" -ForegroundColor Gray
        Write-Host "Output: $testResult" -ForegroundColor Gray
    }
} catch {
    Write-Host "[ERROR] Connection test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Summary
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan

if ($daysOld -gt 365 -or $exitCode -ne 0) {
    Write-Host ""
    Write-Host "!!! RECOMMENDATION: Update certificates" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Run this command:" -ForegroundColor White
    Write-Host "  .\STEP1_setup-netskope-certificate-https.ps1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Why? This will:" -ForegroundColor Gray
    Write-Host "  - Extract latest certificates from Windows" -ForegroundColor Gray
    Write-Host "  - Include any Netskope updates" -ForegroundColor Gray
    Write-Host "  - Refresh expired certificates" -ForegroundColor Gray
    Write-Host "  - Take only 30-60 seconds" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "OK: All checks passed! Certificates are healthy." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next check recommended: $(((Get-Item $certFilePath).LastWriteTime).AddYears(1).ToString('yyyy-MM-dd'))" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

