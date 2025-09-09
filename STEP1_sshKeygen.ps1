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

# Add error handling to keep window open on any unexpected error
trap {
    Write-Host ""
    Write-Host "UNEXPECTED ERROR OCCURRED:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Press ENTER to close this window..." -ForegroundColor Yellow
    Read-Host
    exit 1
}

# Function to pause and wait for user input
function Wait-ForUser {
    param([string]$Message = "Press ENTER to continue...")
    Write-Host $Message -ForegroundColor Yellow
    Read-Host
}

# Function to exit gracefully
function Exit-Gracefully {
    param(
        [int]$ExitCode = 0,
        [string]$Message = "Press ENTER to close this window..."
    )
    Write-Host ""
    Write-Host $Message -ForegroundColor Yellow
    Read-Host
    exit $ExitCode
}

Write-Host "=== SSH Key Generator for GitLab ===" -ForegroundColor Cyan
Write-Host ""

# Check if ssh-keygen is available
try {
    $null = Get-Command ssh-keygen -ErrorAction Stop
    Write-Host "✓ ssh-keygen found" -ForegroundColor Green
} catch {
    Write-Host "ERROR: ssh-keygen not found!" -ForegroundColor Red
    Write-Host "Please install Git for Windows or OpenSSH to get ssh-keygen" -ForegroundColor Yellow
    Exit-Gracefully -ExitCode 1
}

# Use default email if parameter is empty
if ([string]::IsNullOrEmpty($Email)) {
    $Email = $DEFAULT_EMAIL
}

# Get email if not provided in config or parameter
if ([string]::IsNullOrEmpty($Email)) {
    Write-Host "Email address is required for SSH key generation" -ForegroundColor Yellow
    Write-Host ""
    do {
        $Email = Read-Host "Enter your email address"
        if ([string]::IsNullOrEmpty($Email)) {
            Write-Host "Email cannot be empty!" -ForegroundColor Red
            Wait-ForUser "Press ENTER to try again..."
            continue
        }
        # Email validation regex
        $emailPattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
        if ($Email -notmatch $emailPattern) {
            Write-Host "Invalid email format!" -ForegroundColor Red
            Wait-ForUser "Press ENTER to try again..."
            continue
        }
        break
    } while ($true)
}

Write-Host "Using email: $Email" -ForegroundColor Cyan
Write-Host ""

# Setup paths
$keyPath = "$env:USERPROFILE\.ssh\id_rsa"
Write-Host "SSH key will be created at: $keyPath" -ForegroundColor Gray

try {
    if (-not (Test-Path "$env:USERPROFILE\.ssh")) {
        Write-Host "Creating .ssh directory..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path "$env:USERPROFILE\.ssh" -Force | Out-Null
        Write-Host "✓ .ssh directory created" -ForegroundColor Green
    } else {
        Write-Host "✓ .ssh directory exists" -ForegroundColor Green
    }
} catch {
    Write-Host "ERROR: Could not create .ssh directory!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Exit-Gracefully -ExitCode 1
}

# Handle existing keys
if (Test-Path "$keyPath*") {
    Write-Host ""
    Write-Host "WARNING: SSH key files already exist!" -ForegroundColor Yellow
    if (-not $Force) {
        $choice = Read-Host "SSH key already exists. Overwrite? (y/N)"
        if ($choice -ne "y" -and $choice -ne "Y") {
            Write-Host "Operation cancelled by user" -ForegroundColor Yellow
            Exit-Gracefully -ExitCode 0
        }
    }
    try {
        Remove-Item "$keyPath*" -Force
        Write-Host "✓ Existing SSH keys removed" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Could not remove existing SSH keys!" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Exit-Gracefully -ExitCode 1
    }
}

# Generate the SSH key
Write-Host ""
Write-Host "Generating SSH key..." -ForegroundColor Yellow
$sshKeyGenArgs = @("-t", "rsa", "-b", "4096", "-C", $Email, "-f", $keyPath, "-N", '""')

try {
    $process = Start-Process -FilePath "ssh-keygen" -ArgumentList $sshKeyGenArgs -Wait -PassThru -NoNewWindow -RedirectStandardError $true -RedirectStandardOutput $true
    $exitCode = $process.ExitCode
    
    if ($exitCode -ne 0) {
        Write-Host "ERROR: ssh-keygen failed with exit code $exitCode" -ForegroundColor Red
        Exit-Gracefully -ExitCode 1
    }
} catch {
    Write-Host "ERROR: Failed to execute ssh-keygen!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Exit-Gracefully -ExitCode 1
}

if ($exitCode -eq 0) {
    Write-Host "✓ SSH key generated successfully!" -ForegroundColor Green
    
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
    Write-Host "ERROR: Key generation failed!" -ForegroundColor Red
    Exit-Gracefully -ExitCode 1
}

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Exit-Gracefully -ExitCode 0 