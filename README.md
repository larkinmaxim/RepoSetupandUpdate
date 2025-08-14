# GitLab Repository Setup and Management

This repository contains PowerShell scripts for setting up and managing multiple GitLab repository environments (INT, TEST, PROD) with automated SSH key generation and daily updates.

## 📋 Overview

The setup process consists of 5 main steps:
1. **SSH Key Generation** - Generate SSH keys for GitLab authentication
2. **Connection Testing** - Verify GitLab SSH connectivity
3. **INT Repository Setup** - Clone and configure Integration environment
4. **TEST Repository Setup** - Clone and configure Test/Acceptance environment  
5. **PROD Repository Setup** - Clone and configure Production environment

Additionally, there's a daily update script that automatically pulls the latest changes from all environments.

## 🔧 Prerequisites

Before running these scripts, ensure you have:

- **PowerShell 5.0+** (Windows PowerShell or PowerShell Core)
- **Git** installed and accessible from command line
- **Network access** to GitLab server (`gitlab.office.transporeon.com`)
- **VPN connection** (if required by your organization)
- **Email address** for SSH key generation
- **TortoiseGit** (optional, for GUI Git operations)

## 🚀 Step-by-Step Setup Instructions

### Step 1: Generate SSH Keys

Run the SSH key generation script:

```powershell
.\STEP1_sshKeygen.ps1
```

**What it does:**
- Generates a 4096-bit RSA SSH key pair
- Saves keys to `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`
- Displays the public key for GitLab registration
- Validates email format
- Handles existing key conflicts

**Options:**
```powershell
# Use with email parameter
.\STEP1_sshKeygen.ps1 -Email "your.email@company.com"

# Force overwrite existing keys
.\STEP1_sshKeygen.ps1 -Force
```

**Manual Steps After Running:**
1. Copy the displayed public key
2. Go to: https://gitlab.office.transporeon.com/-/profile/keys
3. Click "Add SSH Key" and paste the public key
4. Give it a descriptive title (e.g., "Development Workstation")

### Step 2: Test GitLab Connection

Verify your SSH setup is working:

```powershell
.\STEP2_testGitLabConnection.ps1
```

**What it does:**
- Checks if SSH keys exist
- Shows key fingerprint
- Tests connection to GitLab server
- Provides troubleshooting guidance for common issues

**Expected Success Output:**
```
[SUCCESS] Connection Working!
SSH connection to GitLab is working perfectly!
GitLab Response: Welcome to GitLab, @username!
```

### Step 3: Setup INT Repository

Clone the Integration environment:

```powershell
.\STEP3_setup-int-repo.ps1
```

**What it does:**
- Clones repository branch `3.100/in` to `INT/` folder
- Configures Git settings for TortoiseGit compatibility
- Sets up proper line ending handling
- Shows clone progress with timing

**Options:**
```powershell
# Custom branch
.\STEP3_setup-int-repo.ps1 -BranchName "3.101/in"

# Custom folder name
.\STEP3_setup-int-repo.ps1 -FolderName "Integration"

# Custom repository URL
.\STEP3_setup-int-repo.ps1 -RemoteUrl "https://gitlab.example.com/project.git"
```

### Step 4: Setup TEST Repository

Clone the Test/Acceptance environment:

```powershell
.\STEP4_setup-test-repo.ps1
```

**What it does:**
- Clones repository branch `3.100/ac` to `TEST/` folder
- Configures Git settings for optimal performance
- Handles existing directories with user confirmation

**Options:** Same as Step 3, but defaults to branch `3.100/ac`

### Step 5: Setup PROD Repository

Clone the Production environment:

```powershell
.\STEP5_setup-prod-repo.ps1
```

**What it does:**
- Clones repository branch `3.100/pd` to `PROD/` folder
- Completes the three-environment setup
- Configures repository for production branch tracking

**Options:** Same as previous steps, but defaults to branch `3.100/pd`

## 📅 Daily Updates

Use the daily update script to keep all repositories synchronized:

```powershell
.\DailyUpdate.ps1
```

**What it does:**
- Automatically detects the latest version number
- Force-pulls latest changes from all configured repositories
- Shows progress bars for each operation
- Handles branch creation and switching automatically
- Provides detailed completion summary

**Configuration:**
The script can be customized by editing the `$RepositoryConfig` section:

```powershell
$RepositoryConfig = @(
    @{ 
        FolderPath = "INT"     # Local folder name
        BranchSuffix = "in"    # Git branch suffix
        DisplayColor = [System.ConsoleColor]::Cyan 
        Description = "Integration Environment"
    },
    # Add more repositories as needed
)
```

## 📁 Folder Structure

After setup completion, your directory structure will be:

```
C:\DEV\
├── README.md
├── STEP1_sshKeygen.ps1
├── STEP2_testGitLabConnection.ps1
├── STEP3_setup-int-repo.ps1
├── STEP4_setup-test-repo.ps1
├── STEP5_setup-prod-repo.ps1
├── DailyUpdate.ps1
├── INT/                    # Integration environment (branch: 3.100/in)
├── TEST/                   # Test environment (branch: 3.100/ac)
└── PROD/                   # Production environment (branch: 3.100/pd)
```

## 🔧 Configuration Options

### Email Configuration (Step 1)
To avoid being prompted for email each time, edit `STEP1_sshKeygen.ps1`:

```powershell
$DEFAULT_EMAIL = "your.email@company.com"
```

### Repository URLs
All setup scripts default to:
```
https://gitlab.office.transporeon.com/Development/portfolio.git
```

Override with the `-RemoteUrl` parameter if needed.

### Branch Names
Default branches:
- INT: `3.100/in`
- TEST: `3.100/ac`  
- PROD: `3.100/pd`

Override with the `-BranchName` parameter.

## ❗ Troubleshooting

### SSH Authentication Issues

**Problem:** "Permission denied" when testing connection
**Solution:**
1. Ensure public key is correctly added to GitLab
2. Check key file permissions: `icacls ~/.ssh/id_rsa`
3. Verify you're using the correct GitLab URL

### Network Connection Issues

**Problem:** "Connection refused" or timeouts
**Solution:**
1. Check VPN connection
2. Verify network access to `gitlab.office.transporeon.com`
3. Check corporate firewall settings

### Clone Operation Issues

**Problem:** Clone fails or times out
**Solution:**
1. Use Ctrl+C to cancel stuck operations
2. Check available disk space
3. Verify branch exists: `git ls-remote origin`
4. Try cloning a different branch to test connectivity

### TortoiseGit Integration

**Problem:** TortoiseGit doesn't recognize repositories
**Solution:**
1. Ensure TortoiseGit is installed
2. Repositories are automatically configured for TortoiseGit compatibility
3. Right-click in repository folder to access TortoiseGit menu

## 🔄 Daily Workflow

1. **Morning Setup:**
   ```powershell
   .\DailyUpdate.ps1
   ```

2. **Development Work:**
   - Use TortoiseGit or command line for commits
   - Work in appropriate environment folder (INT/TEST/PROD)

3. **End of Day:**
   - Commit and push changes
   - Optional: Run DailyUpdate.ps1 to sync final changes

## 📞 Support

If you encounter issues:

1. **Check Prerequisites** - Ensure all requirements are met
2. **Review Error Messages** - Scripts provide detailed error information
3. **Test Individual Components** - Run connection test independently
4. **Check GitLab Access** - Verify you can access GitLab web interface
5. **Network Connectivity** - Ensure VPN and network access

## 🔐 Security Notes

- SSH keys are stored in `~/.ssh/` with appropriate permissions
- Scripts handle credential caching automatically
- Public keys are safe to share; private keys should never be shared
- Keys are generated with 4096-bit encryption for enhanced security

## 📝 Script Parameters Reference

### STEP1_sshKeygen.ps1
- `-Email <string>`: Email address for key generation
- `-Force`: Overwrite existing keys without prompting

### STEP2_testGitLabConnection.ps1
- No parameters required

### STEP3-5_setup-*-repo.ps1
- `-RemoteUrl <string>`: Git repository URL
- `-BranchName <string>`: Target branch name
- `-FolderName <string>`: Local folder name

### DailyUpdate.ps1
- No parameters - configuration via script editing

---

**Happy coding!** 🚀 