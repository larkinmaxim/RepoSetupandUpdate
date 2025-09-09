param(
    [string]$Email = "",
    [switch]$Force
)

# Set error handling
$ErrorActionPreference = "Stop"

# Trap any errors and keep window open
trap {
    Write-Host ""
    Write-Host "ERROR OCCURRED:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Press ENTER to close..." -ForegroundColor Yellow
    try { Read-Host } catch { Start-Sleep -Seconds 10 }
    exit 1
}

# Function to exit gracefully
function Exit-Gracefully {
    param(
        [int]$ExitCode = 0,
        [string]$Message = "Press ENTER to close this window..."
    )
    Write-Host ""
    Write-Host $Message -ForegroundColor Yellow
    try {
        Read-Host
    } catch {
        Start-Sleep -Seconds 10
    }
    exit $ExitCode
}

Write-Host "=== SSH Key Generator Starting ===" -ForegroundColor Cyan
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Gray

# Configuration
$DEFAULT_EMAIL = ""

# Check if ssh-keygen is available
Write-Host "Checking for ssh-keygen..." -ForegroundColor Yellow
try {
    $sshKeygenPath = Get-Command ssh-keygen -ErrorAction Stop
    Write-Host "ssh-keygen found at: $($sshKeygenPath.Source)" -ForegroundColor Green
} catch {
    Write-Host "ERROR: ssh-keygen not found!" -ForegroundColor Red
    Write-Host "Please install Git for Windows or OpenSSH" -ForegroundColor Yellow
    Exit-Gracefully -ExitCode 1
}

# Get email
if ([string]::IsNullOrEmpty($Email)) {
    $Email = $DEFAULT_EMAIL
}

if ([string]::IsNullOrEmpty($Email)) {
    Write-Host "Email address is required" -ForegroundColor Yellow
    Write-Host ""
    
    $attempts = 0
    do {
        $attempts++
        if ($attempts -gt 5) {
            Write-Host "Too many attempts. Exiting." -ForegroundColor Red
            Exit-Gracefully -ExitCode 1
        }
        
        try {
            $Email = Read-Host "Enter your email address"
        } catch {
            Write-Host "Failed to read input. Trying again..." -ForegroundColor Red
            Start-Sleep -Seconds 2
            continue
        }
        
        if ([string]::IsNullOrEmpty($Email)) {
            Write-Host "Email cannot be empty!" -ForegroundColor Red
            Write-Host "Press ENTER to try again..." -ForegroundColor Yellow
            try { Read-Host } catch { Start-Sleep -Seconds 2 }
            continue
        }
        
        # Simple email check
        if (-not ($Email.Contains("@") -and $Email.Contains("."))) {
            Write-Host "Invalid email format! Must contain @ and ." -ForegroundColor Red
            Write-Host "Press ENTER to try again..." -ForegroundColor Yellow
            try { Read-Host } catch { Start-Sleep -Seconds 2 }
            continue
        }
        break
    } while ($true)
}

Write-Host "Using email: $Email" -ForegroundColor Cyan

# Setup paths
$keyPath = "$env:USERPROFILE\.ssh\id_rsa"
Write-Host "SSH key will be created at: $keyPath" -ForegroundColor Gray

# Create .ssh directory
Write-Host "Checking .ssh directory..." -ForegroundColor Yellow
try {
    $sshDir = "$env:USERPROFILE\.ssh"
    if (-not (Test-Path $sshDir)) {
        Write-Host "Creating .ssh directory..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
        Write-Host ".ssh directory created" -ForegroundColor Green
    } else {
        Write-Host ".ssh directory exists" -ForegroundColor Green
    }
} catch {
    Write-Host "ERROR: Could not create .ssh directory!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Exit-Gracefully -ExitCode 1
}

# Handle existing keys
Write-Host "Checking for existing SSH keys..." -ForegroundColor Yellow
if (Test-Path "$keyPath*") {
    Write-Host ""
    Write-Host "WARNING: SSH key files already exist!" -ForegroundColor Yellow
    
    if (-not $Force) {
        try {
            $choice = Read-Host "SSH key already exists. Overwrite? (y/N)"
        } catch {
            Write-Host "Failed to read input, assuming No" -ForegroundColor Yellow
            $choice = "N"
        }
        
        if ($choice -ne "y" -and $choice -ne "Y") {
            Write-Host "Operation cancelled by user" -ForegroundColor Yellow
            Exit-Gracefully -ExitCode 0
        }
    }
    
    try {
        Remove-Item "$keyPath*" -Force
        Write-Host "Existing SSH keys removed" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Could not remove existing SSH keys!" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Exit-Gracefully -ExitCode 1
    }
} else {
    Write-Host "No existing SSH keys found" -ForegroundColor Green
}

# Generate SSH key
Write-Host ""
Write-Host "Generating SSH key..." -ForegroundColor Yellow

try {
    $process = Start-Process -FilePath "ssh-keygen" -ArgumentList @("-t", "rsa", "-b", "4096", "-C", $Email, "-f", $keyPath, "-N", "") -Wait -PassThru -NoNewWindow
    $exitCode = $process.ExitCode
    Write-Host "ssh-keygen exit code: $exitCode" -ForegroundColor Gray
    
    if ($exitCode -ne 0) {
        Write-Host "ERROR: ssh-keygen failed with exit code $exitCode" -ForegroundColor Red
        Exit-Gracefully -ExitCode 1
    }
} catch {
    Write-Host "ERROR: Failed to execute ssh-keygen!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Exit-Gracefully -ExitCode 1
}

# Check if key was created
Write-Host "Checking if SSH key was created..." -ForegroundColor Yellow
if (Test-Path "$keyPath.pub") {
    Write-Host "SSH key generated successfully!" -ForegroundColor Green
    
    try {
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
    } catch {
        Write-Host "ERROR: Could not read the generated public key!" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Exit-Gracefully -ExitCode 1
    }
} else {
    Write-Host "ERROR: SSH key generation failed!" -ForegroundColor Red
    Write-Host "Expected location: $keyPath.pub" -ForegroundColor Gray
    Exit-Gracefully -ExitCode 1
}

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Exit-Gracefully -ExitCode 0
