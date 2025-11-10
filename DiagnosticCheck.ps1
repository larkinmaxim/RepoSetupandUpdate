# Git Configuration Diagnostic Script (HTTPS-Focused)
# Run this before repository setup to identify potential issues
# Primarily checks HTTPS configuration (recommended for Netskope environments)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  GIT CONFIGURATION DIAGNOSTIC (v3.0)" -ForegroundColor Cyan
Write-Host "  HTTPS-First Detection" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "This script checks for common Git configuration issues" -ForegroundColor Gray
Write-Host "Recommends HTTPS authentication (SSH port 22 blocked by Netskope)`n" -ForegroundColor Gray

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

# ============================================================================
# STEP 0: Detect Git Version and Basic Configuration
# ============================================================================
Write-Host "`n=== STEP 0: Git Installation Check ===" -ForegroundColor Yellow
try {
    $gitVersion = git --version 2>&1
    Show-Status "Git detected: $gitVersion" "OK"
} catch {
    Show-Status "Git is NOT installed or not in PATH" "ERROR"
    Write-Host "   Install Git: https://git-scm.com/download/win" -ForegroundColor Cyan
    Pause-WithMessage
    exit 1
}

# ============================================================================
# STEP 1: Protocol Detection - Determine SSH vs HTTPS
# ============================================================================
Write-Host "`n=== STEP 1: Authentication Method Detection ===" -ForegroundColor Yellow

$sshKeyPath = "$env:USERPROFILE\.ssh\id_rsa"
$sshKeyExists = Test-Path $sshKeyPath
$netskopeCertPath = "C:\Netskope Certs\nscacert_combined.pem"
$netskopeCertExists = Test-Path $netskopeCertPath
$sslCaInfo = git config --global --get http.sslcainfo

# Determine which protocol is configured
$sshConfigured = $sshKeyExists
$httpsConfigured = ($netskopeCertExists -and $sslCaInfo -eq $netskopeCertPath)

Write-Host ""
Write-Host "Authentication Methods Available:" -ForegroundColor Cyan

if ($httpsConfigured) {
    Show-Status "HTTPS: Configured (Netskope certificate configured) - RECOMMENDED" "OK"
    Write-Host "   Certificate: $netskopeCertPath" -ForegroundColor Gray
    $primaryMethod = "HTTPS"
} elseif ($netskopeCertExists) {
    Show-Status "HTTPS: Partially configured (certificate exists but not in Git config)" "WARNING"
    Write-Host "   To enable HTTPS: Run STEP1_setup-netskope-certificate-https.ps1" -ForegroundColor Cyan
} else {
    Show-Status "HTTPS: Not configured (no Netskope certificate)" "WARNING"
    Write-Host "   To enable HTTPS: Run STEP1_setup-netskope-certificate-https.ps1" -ForegroundColor Yellow
}

if ($sshConfigured) {
    Show-Status "SSH: Configured (SSH key found) - NOT RECOMMENDED (port 22 blocked)" "WARNING"
    Write-Host "   Key location: $sshKeyPath" -ForegroundColor Gray
    Write-Host "   Note: SSH (port 22) is blocked by Netskope - use HTTPS instead" -ForegroundColor Yellow
} else {
    Show-Status "SSH: Not configured" "INFO"
    Write-Host "   SSH not needed (port 22 blocked by Netskope)" -ForegroundColor Gray
}

Write-Host ""
if ($httpsConfigured) {
    Show-Status "HTTPS authentication is configured and ready!" "OK"
    $primaryMethod = "HTTPS"
} elseif ($sshConfigured) {
    Show-Status "Only SSH is configured, but SSH (port 22) is blocked!" "WARNING"
    Write-Host "   You should configure HTTPS instead" -ForegroundColor Yellow
    Write-Host "   Run: STEP1_setup-netskope-certificate-https.ps1" -ForegroundColor Cyan
    $primaryMethod = "SSH"
} else {
    Show-Status "Neither SSH nor HTTPS is configured!" "ERROR"
    Write-Host "   You must configure HTTPS authentication" -ForegroundColor Red
    Write-Host "   Run: STEP1_setup-netskope-certificate-https.ps1" -ForegroundColor Cyan
    Pause-WithMessage
    exit 1
}

# ============================================================================
# STEP 2: SSH Configuration Checks (if SSH is configured)
# ============================================================================
if ($sshConfigured) {
    Write-Host "`n=== STEP 2: SSH Configuration Checks ===" -ForegroundColor Yellow
    
    # Check 2.1: SSH Key permissions and validity
    Write-Host "`n2.1. Checking SSH Key..." -ForegroundColor Cyan
    if (Test-Path "$sshKeyPath.pub") {
        try {
            $fingerprint = ssh-keygen -lf "$sshKeyPath.pub" 2>$null
            if ($fingerprint) {
                Show-Status "SSH key is valid" "OK"
                Write-Host "   Fingerprint: $fingerprint" -ForegroundColor Gray
            } else {
                Show-Status "SSH key exists but may be invalid" "WARNING"
            }
        } catch {
            Show-Status "Could not validate SSH key" "WARNING"
        }
    } else {
        Show-Status "SSH private key exists but public key is missing" "ERROR"
        Write-Host "   Fix: Run STEP1_sshKeygen.ps1 to regenerate" -ForegroundColor Cyan
    }
    
    # Check 2.2: Test SSH Connection
    Write-Host "`n2.2. Testing SSH Connection to GitHub..." -ForegroundColor Cyan
    try {
        $sshTest = ssh -o ConnectTimeout=10 -o BatchMode=yes -T git@github.com 2>&1
        $sshExitCode = $LASTEXITCODE
        
        if ($sshTest -like "*successfully authenticated*" -or $sshTest -like "*You've successfully authenticated*") {
            Show-Status "SSH connection to GitHub successful!" "OK"
            Write-Host "   Response: $($sshTest -split "`n" | Select-Object -First 1)" -ForegroundColor Gray
        } elseif ($sshTest -like "*Permission denied*") {
            Show-Status "SSH authentication FAILED" "ERROR"
            Write-Host "   Your SSH key is not added to GitHub or is incorrect" -ForegroundColor Red
            Write-Host "   Fix: Add your public key to https://github.com/settings/keys" -ForegroundColor Cyan
        } elseif ($sshTest -like "*Connection refused*" -or $sshTest -like "*Connection timed out*") {
            Show-Status "SSH connection BLOCKED or TIMED OUT (Expected - Netskope blocks port 22)" "WARNING"
            Write-Host "   SSH (port 22) is blocked by Netskope" -ForegroundColor Yellow
            Write-Host "   Switch to HTTPS authentication" -ForegroundColor Cyan
            Write-Host "   Run: STEP1_setup-netskope-certificate-https.ps1" -ForegroundColor Cyan
        } else {
            Show-Status "SSH connection test returned unexpected result" "WARNING"
            Write-Host "   Exit code: $sshExitCode" -ForegroundColor Gray
            Write-Host "   Output: $sshTest" -ForegroundColor Gray
        }
    } catch {
        Show-Status "SSH connection test failed: $($_.Exception.Message)" "ERROR"
    }
    
    # Check 2.3: Known hosts
    Write-Host "`n2.3. Checking GitHub Host Key..." -ForegroundColor Cyan
    $knownHostsPath = "$env:USERPROFILE\.ssh\known_hosts"
    if (Test-Path $knownHostsPath) {
        $knownHosts = Get-Content $knownHostsPath -ErrorAction SilentlyContinue
        $githubHostExists = $knownHosts | Where-Object { $_ -like "*github.com*" }
        if ($githubHostExists) {
            Show-Status "GitHub host key is in known_hosts" "OK"
        } else {
            Show-Status "GitHub host key not in known_hosts" "WARNING"
            Write-Host "   This is OK - will be added on first connection" -ForegroundColor Gray
        }
    } else {
        Show-Status "known_hosts file does not exist" "INFO"
        Write-Host "   This is OK - will be created on first SSH connection" -ForegroundColor Gray
    }
}

# ============================================================================
# STEP 3: HTTPS Configuration Checks (if HTTPS is configured)
# ============================================================================
if ($httpsConfigured -or $netskopeCertExists) {
    Write-Host "`n=== STEP 3: HTTPS/SSL Configuration Checks ===" -ForegroundColor Yellow
    
    # Check 3.1: Netskope Certificate
    Write-Host "`n3.1. Checking Netskope Certificate..." -ForegroundColor Cyan
    if ($netskopeCertExists) {
        Show-Status "Netskope certificate file found" "OK"
        Write-Host "   Location: $netskopeCertPath" -ForegroundColor Gray
        
        $fileSize = (Get-Item $netskopeCertPath).Length
        Write-Host "   Size: $([math]::Round($fileSize/1KB, 2)) KB" -ForegroundColor Gray
        
        if ($fileSize -lt 1000) {
            Show-Status "Warning: Certificate file seems too small" "WARNING"
        }
        
        if ($sslCaInfo -eq $netskopeCertPath) {
            Show-Status "Git is configured to use Netskope certificate" "OK"
        } else {
            Show-Status "Git is NOT configured to use Netskope certificate" "WARNING"
            Write-Host "   Current setting: $sslCaInfo" -ForegroundColor Gray
            Write-Host "   Expected: $netskopeCertPath" -ForegroundColor Gray
            Write-Host "   Fix: Run Setup_netskopecertificate_administrator.ps1" -ForegroundColor Cyan
        }
    } else {
        Show-Status "Netskope certificate NOT found" "INFO"
        Write-Host "   Not needed if using SSH authentication" -ForegroundColor Gray
        Write-Host "   To enable HTTPS: Run Setup_netskopecertificate_administrator.ps1" -ForegroundColor Gray
    }
    
    # Check 3.2: SSL Backend Configuration
    Write-Host "`n3.2. Checking SSL Backend..." -ForegroundColor Cyan
    $gitConfig = git config --list
    $sslBackendEntries = $gitConfig | Where-Object { $_ -match '^http\.sslbackend=' }
    
    if ($sslBackendEntries.Count -eq 0) {
        Show-Status "No SSL backend configured (using default)" "INFO"
    } elseif ($sslBackendEntries.Count -eq 1) {
        Show-Status "SSL backend: $sslBackendEntries" "OK"
    } else {
        Show-Status "Multiple SSL backend entries found (CONFLICT)" "ERROR"
        $sslBackendEntries | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
        Write-Host "   Fix: git config --global --unset-all http.sslbackend" -ForegroundColor Cyan
        Write-Host "        git config --global http.sslbackend schannel" -ForegroundColor Cyan
    }
    
    # Check 3.3: SSL CA Info Configuration
    Write-Host "`n3.3. Checking SSL CA Info..." -ForegroundColor Cyan
    $sslCaInfoEntries = $gitConfig | Where-Object { $_ -match '^http\.sslcainfo=' }
    
    if ($sslCaInfoEntries.Count -eq 0) {
        if ($httpsConfigured) {
            Show-Status "No SSL CA info configured" "WARNING"
            Write-Host "   HTTPS may not work without certificate configuration" -ForegroundColor Yellow
        } else {
            Show-Status "No SSL CA info configured (not needed for SSH)" "INFO"
        }
    } elseif ($sslCaInfoEntries.Count -eq 1) {
        Show-Status "SSL CA Info: $sslCaInfoEntries" "OK"
    } else {
        Show-Status "Multiple SSL CA info entries found (CONFLICT)" "ERROR"
        $sslCaInfoEntries | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
        Write-Host "   Fix: git config --global --unset-all http.sslcainfo" -ForegroundColor Cyan
        Write-Host "        git config --global http.sslcainfo `"$netskopeCertPath`"" -ForegroundColor Cyan
    }
    
    # Check 3.4: Test HTTPS Connection (if HTTPS is configured)
    if ($httpsConfigured) {
        Write-Host "`n3.4. Testing HTTPS Connection to GitHub..." -ForegroundColor Cyan
        try {
            $httpsTest = git ls-remote --heads https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git 2>&1
            if ($LASTEXITCODE -eq 0) {
                Show-Status "HTTPS connection to GitHub successful!" "OK"
            } else {
                Show-Status "HTTPS connection failed (Exit code: $LASTEXITCODE)" "ERROR"
                Write-Host "   Error: $httpsTest" -ForegroundColor Gray
                Write-Host "   This may indicate SSL/certificate issues" -ForegroundColor Yellow
            }
        } catch {
            Show-Status "HTTPS connection test failed: $($_.Exception.Message)" "WARNING"
        }
    }
}

# ============================================================================
# STEP 4: Common Git Configuration Checks
# ============================================================================
Write-Host "`n=== STEP 4: Common Git Configuration ===" -ForegroundColor Yellow

# Check 4.1: User Configuration
Write-Host "`n4.1. Checking User Configuration..." -ForegroundColor Cyan
$userName = git config --global --get user.name
$userEmail = git config --global --get user.email

if ($userName -and $userEmail) {
    Show-Status "User name: $userName" "OK"
    Show-Status "User email: $userEmail" "OK"
} else {
    if (-not $userName) {
        Show-Status "User name NOT configured" "WARNING"
        Write-Host "   Fix: git config --global user.name `"Your Name`"" -ForegroundColor Cyan
    }
    if (-not $userEmail) {
        Show-Status "User email NOT configured" "WARNING"
        Write-Host "   Fix: git config --global user.email `"your.email@company.com`"" -ForegroundColor Cyan
    }
}

# Check 4.2: Long Paths Support
Write-Host "`n4.2. Checking Long Paths Support..." -ForegroundColor Cyan
$longPaths = git config --global --get core.longpaths
if ($longPaths -eq "true") {
    Show-Status "Long paths support enabled" "OK"
} else {
    Show-Status "Long paths support NOT enabled (may cause issues on Windows)" "WARNING"
    Write-Host "   Fix: git config --global core.longpaths true" -ForegroundColor Cyan
}

# Check 4.3: Credential Helper
Write-Host "`n4.3. Checking Credential Helper..." -ForegroundColor Cyan
$credHelper = git config --global --get credential.helper
if ($credHelper) {
    Show-Status "Credential helper: $credHelper" "OK"
} else {
    if ($primaryMethod -eq "HTTPS") {
        Show-Status "No credential helper configured (needed for HTTPS)" "WARNING"
        Write-Host "   Fix: git config --global credential.helper manager" -ForegroundColor Cyan
    } else {
        Show-Status "No credential helper configured (not needed for SSH)" "INFO"
    }
}

# Check 4.4: Git LFS Configuration
Write-Host "`n4.4. Checking Git LFS Configuration..." -ForegroundColor Cyan
$lfsClean = git config --global --get filter.lfs.clean
$lfsSmudge = git config --global --get filter.lfs.smudge
$lfsProcess = git config --global --get filter.lfs.process

if ($lfsClean -and $lfsSmudge -and $lfsProcess) {
    Show-Status "Git LFS configured correctly" "OK"
} else {
    Show-Status "Git LFS not fully configured" "INFO"
    Write-Host "   This is OK if you don't use Git LFS" -ForegroundColor Gray
}

# ============================================================================
# SUMMARY and RECOMMENDATIONS
# ============================================================================
Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "  DIAGNOSTIC SUMMARY" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host "`nConfiguration Status:" -ForegroundColor Yellow

if ($sshConfigured) {
    Write-Host "  [OK] SSH Authentication: Configured" -ForegroundColor Green
} else {
    Write-Host "  [ ] SSH Authentication: Not configured" -ForegroundColor Gray
}

if ($httpsConfigured) {
    Write-Host "  [OK] HTTPS Authentication: Configured" -ForegroundColor Green
} elseif ($netskopeCertExists) {
    Write-Host "  [!] HTTPS Authentication: Partially configured" -ForegroundColor Yellow
} else {
    Write-Host "  [ ] HTTPS Authentication: Not configured" -ForegroundColor Gray
}

Write-Host "`nRecommendations:" -ForegroundColor Yellow

if ($httpsConfigured) {
    Write-Host "  ✅ HTTPS authentication is ready!" -ForegroundColor Green
    Write-Host "  - You can run STEP2-4 scripts to clone repositories" -ForegroundColor Gray
    Write-Host "  - All setup scripts now use HTTPS by default" -ForegroundColor Gray
    if ($sshConfigured) {
        Write-Host "  - SSH is configured but blocked (port 22) - HTTPS is used instead" -ForegroundColor Yellow
    }
} elseif ($sshConfigured) {
    Write-Host "  ⚠️  SSH is configured but SSH (port 22) is blocked by Netskope!" -ForegroundColor Yellow
    Write-Host "  - You must switch to HTTPS authentication" -ForegroundColor Red
    Write-Host "  - Run: STEP1_setup-netskope-certificate-https.ps1" -ForegroundColor Cyan
} else {
    Write-Host "  ❌ No authentication method configured!" -ForegroundColor Red
    Write-Host "  - Next step: Run STEP1_setup-netskope-certificate-https.ps1" -ForegroundColor Yellow
    Write-Host "  - This will enable HTTPS authentication (SSH is blocked)" -ForegroundColor Gray
}

Write-Host "`nExit Code 128 Troubleshooting:" -ForegroundColor Yellow
Write-Host "  If you encounter 'Exit code 128' during git clone:" -ForegroundColor Gray
Write-Host ""
Write-Host "  For HTTPS users (https://github.com/...) - RECOMMENDED:" -ForegroundColor Cyan
Write-Host "    - Ensure Netskope certificate is configured" -ForegroundColor Gray
Write-Host "    - Run: STEP1_setup-netskope-certificate-https.ps1" -ForegroundColor Gray
Write-Host "    - Check network/VPN connectivity" -ForegroundColor Gray
Write-Host "    - Verify GitHub SSO authorization" -ForegroundColor Gray
Write-Host "    - Test: STEP0_test-https-connection.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "  Note: SSH (git@github.com:...) is blocked by Netskope" -ForegroundColor Yellow
Write-Host "    - Port 22 is not accessible" -ForegroundColor Gray
Write-Host "    - Use HTTPS instead (all scripts now default to HTTPS)" -ForegroundColor Gray

Write-Host "`nLegend:" -ForegroundColor Cyan
Write-Host "  [OK] OK      - No action needed" -ForegroundColor Green
Write-Host "  [!] WARNING - May cause issues but not critical" -ForegroundColor Yellow
Write-Host "  [X] ERROR   - Should be fixed before running STEP3-5" -ForegroundColor Red
Write-Host "  [i] INFO    - Informational message" -ForegroundColor Cyan

Write-Host ""
Pause-WithMessage "Press any key to exit..."