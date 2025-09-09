param(
    [string]$Email = "",
    [switch]$Force
)

# ========================================================================
# SSH Key Generator for GitLab Authentication  
# ========================================================================
# CONFIGURATION SECTION - Set your email here to avoid prompts each time
$DEFAULT_EMAIL = ""  # Example: "john.doe@company.com"
# ========================================================================

Write-Host "=== SSH Key Generator for GitLab ===" -ForegroundColor Cyan

# Use default email if parameter is empty
if ([string]::IsNullOrEmpty($Email)) {
    $Email = $DEFAULT_EMAIL
}

# Get email if not provided in config or parameter
if ([string]::IsNullOrEmpty($Email)) {
    do {
        $Email = Read-Host "Enter your email address"
        if ([string]::IsNullOrEmpty($Email)) {
            Write-Host "Email cannot be empty!" -ForegroundColor Red
            Write-Host "Press ENTER to try again..." -ForegroundColor Yellow
            Read-Host
            continue
        }
        if ($Email -notmatch "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$") {
            Write-Host "Invalid email format!" -ForegroundColor Red
            Write-Host "Press ENTER to try again..." -ForegroundColor Yellow
            Read-Host
            continue
        }
        break
    } while ($true)
}

Write-Host "Using email: $Email" -ForegroundColor Cyan

# Setup paths
$keyPath = "$env:USERPROFILE\.ssh\id_rsa"
if (-not (Test-Path "$env:USERPROFILE\.ssh")) {
    New-Item -ItemType Directory -Path "$env:USERPROFILE\.ssh" -Force | Out-Null
}

# Handle existing keys
if (Test-Path "$keyPath*") {
    if (-not $Force) {
        $choice = Read-Host "SSH key already exists. Overwrite? (y/N)"
        if ($choice -ne "y" -and $choice -ne "Y") {
            Write-Host "Operation cancelled" -ForegroundColor Yellow
            Write-Host "Press ENTER to close this window..." -ForegroundColor Yellow
            Read-Host
            exit 0
        }
    }
    Remove-Item "$keyPath*" -Force
}

# Generate the SSH key
Write-Host "Generating SSH key..." -ForegroundColor Yellow
Write-Host "This may take a moment..." -ForegroundColor Gray

# Use a more reliable method - create a batch file to handle the command
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
    Write-Host "Batch method failed, trying direct execution..." -ForegroundColor Yellow
    Remove-Item $batchFile -Force -ErrorAction SilentlyContinue
    
    # Fallback: Try without the empty passphrase parameter
    try {
        $process = Start-Process -FilePath "ssh-keygen" -ArgumentList @("-t", "rsa", "-b", "4096", "-C", $Email, "-f", $keyPath, "-q") -Wait -PassThru -NoNewWindow
        $exitCode = $process.ExitCode
    } catch {
        $exitCode = 1
    }
}

if ($exitCode -eq 0) {
    Write-Host "SSH key generated successfully!" -ForegroundColor Green
    
    $publicKey = Get-Content "$keyPath.pub" -Raw
    Write-Host ""
    Write-Host "=== PUBLIC KEY ===" -ForegroundColor Cyan
    Write-Host $publicKey.Trim()
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Copy the public key above" -ForegroundColor Gray
    Write-Host "2. Go to: https://gitlab.office.transporeon.com/-/profile/keys" -ForegroundColor Gray
    Write-Host "3. Click 'Add SSH Key' and paste the key" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Test connection: ssh -T git@gitlab.office.transporeon.com" -ForegroundColor Gray
} else {
    Write-Host "ERROR: Key generation failed!" -ForegroundColor Red
    Write-Host "Press ENTER to close this window..." -ForegroundColor Yellow
    Read-Host
    exit 1
}

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Press ENTER to close this window..." -ForegroundColor Yellow
Read-Host
