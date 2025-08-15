# GitLab Repository Setup and Management

This repository contains PowerShell scripts for setting up and managing multiple GitLab repository environments (INT, TEST, PROD) with automated SSH key generation and daily updates.

## 📥 Getting Started

### What is "Cloning a Repository"?
Cloning means downloading a complete copy of this repository (all files and scripts) to your computer so you can use them locally.

### Step-by-Step Instructions for Absolute Beginners

#### Option 1: Using File Explorer + PowerShell (Recommended for Beginners)

1. **Create a folder for your development environment:**
   - Open File Explorer (Windows key + E)
   - Navigate to your C: drive
   - Create a new folder called `DEV` (Right-click → New → Folder)
   - Your path should now be: `C:\DEV`

2. **Open PowerShell in this folder:**
   - Navigate to `C:\DEV` in File Explorer
   - Click in the address bar and type `powershell`
   - Press Enter - this opens PowerShell in the correct location

3. **Clone the repository:**
   - Copy and paste this command into PowerShell:
   ```bash
   git clone https://github.com/larkinmaxim/RepoSetupandUpdate.git .
   ```
   - Press Enter and wait for the download to complete
   - You should see progress messages as files are downloaded

4. **Verify the download:**
   - Look in your `C:\DEV` folder
   - You should now see several `.ps1` files (STEP1_sshKeygen.ps1, etc.)

#### Option 2: Using Command Prompt

1. **Open Command Prompt:**
   - Press Windows key + R
   - Type `cmd` and press Enter

2. **Navigate to your development folder:**
   ```cmd
   cd C:\
   mkdir DEV
   cd DEV
   ```

3. **Clone the repository:**
   ```bash
   git clone https://github.com/larkinmaxim/RepoSetupandUpdate.git .
   ```

#### Option 3: Using Right-Click Context Menu (Easiest Visual Method)

1. **Create your development folder:**
   - Open File Explorer (Windows key + E)
   - Navigate to your C: drive
   - Create a new folder called `DEV` (Right-click → New → Folder)
   - **Double-click** to open the `C:\DEV` folder

2. **Use Git Bash from right-click menu:**
   - **Right-click** on empty space inside the `C:\DEV` folder
   - Look for **"Git Bash Here"** in the context menu
   - Click on **"Git Bash Here"** - this opens a Git terminal in the correct location

3. **Clone the repository:**
   - Copy and paste this command into the Git Bash window:
   ```bash
   git clone https://github.com/larkinmaxim/RepoSetupandUpdate.git .
   ```
   - Press Enter and wait for the download to complete

4. **Close Git Bash and check your folder:**
   - Type `exit` and press Enter to close Git Bash
   - Look in your `C:\DEV` folder - you should see all the `.ps1` files

> **Note:** If you don't see "Git Bash Here" in the right-click menu, you need to install Git for Windows first (see troubleshooting section below).

#### Option 4: Download as ZIP (Alternative if Git isn't working)

1. **Go to the GitHub page:**
   - Open your web browser
   - Go to: https://github.com/larkinmaxim/RepoSetupandUpdate

2. **Download the ZIP file:**
   - Click the green "Code" button
   - Select "Download ZIP"
   - Save it to your Downloads folder

3. **Extract the files:**
   - Go to your Downloads folder
   - Right-click on the ZIP file → "Extract All"
   - Choose `C:\DEV` as the destination
   - Make sure "Show extracted files when complete" is checked

### What You Should See After Cloning

After successful cloning, your `C:\DEV` folder should contain:
- `STEP1_sshKeygen.ps1`
- `STEP2_testGitLabConnection.ps1`
- `STEP3_setup-int-repo.ps1`
- `STEP4_setup-test-repo.ps1`
- `STEP5_setup-prod-repo.ps1`
- `DailyUpdate.ps1`
- `README.md`

### Troubleshooting Common Issues

**Problem: "git is not recognized as an internal or external command"**
- Solution: You need to install Git first
- Go to: https://git-scm.com/downloads
- Download and install Git for Windows
- ✅ **Important:** During installation, make sure "Git Bash Here" is selected
- Restart your computer and try again

**Problem: Don't see "Git Bash Here" in right-click menu**
- Solution: Git for Windows isn't installed or wasn't installed with context menu integration
- Download Git from: https://git-scm.com/downloads
- During installation, make sure these options are checked:
  - ✅ "Windows Explorer integration"
  - ✅ "Git Bash Here"
  - ✅ "Git GUI Here"
- Restart your computer after installation

**Problem: "Access denied" or permission errors**
- Solution: Run PowerShell as Administrator
- Right-click on PowerShell → "Run as administrator"
- Alternative: Use Git Bash instead (usually has fewer permission issues)

**Problem: Can't find the cloned files**
- Make sure you're in the correct directory (`C:\DEV`)
- The `.` at the end of the clone command is important - it means "clone into current folder"
- If files are in a subfolder, move them up to `C:\DEV` directly

**Problem: Git Bash window closes immediately**
- This is normal after the download completes
- Just check your `C:\DEV` folder - the files should be there
- If nothing downloaded, try running the command again

### Ready to Continue?
Once you see all the `.ps1` files in your `C:\DEV` folder, you're ready to proceed to the next section!

## ▶️ How to Run PowerShell Scripts

There are two easy ways to run the PowerShell scripts in this repository:

### Method 1: Right-Click (Easiest for Beginners)
1. **Navigate** to the folder where you cloned the repository
2. **Right-click** on any `.ps1` script file (e.g., `STEP1_sshKeygen.ps1`)
3. **Select** "Run with PowerShell" from the context menu
4. **Allow execution** if Windows asks for permission
5. **Follow** the on-screen prompts

### Method 2: PowerShell Command Line
1. **Open** PowerShell as Administrator (recommended)
2. **Navigate** to the repository folder: `cd C:\DEV` (or your chosen directory)
3. **Run** the script: `.\STEP1_sshKeygen.ps1`

> **💡 Tip:** If you get an execution policy error, run this command in PowerShell as Administrator:
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

## 📋 Overview

The setup process consists of 5 main steps:
1. **SSH Key Generation** - Generate SSH keys for GitLab authentication
2. **Connection Testing** - Verify GitLab SSH connectivity
3. **INT Repository Setup** - Clone and configure Integration environment
4. **TEST Repository Setup** - Clone and configure Test/Acceptance environment  
5. **PROD Repository Setup** - Clone and configure Production environment

⚠️ **Important:** Steps 3, 4, and 5 can each take up to 20 minutes due to the large size of the repositories being cloned.

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
- **Method 1 (Recommended):** Right-click on `STEP1_sshKeygen.ps1` → "Run with PowerShell"
- **Method 2 (Optional):** `.\STEP1_sshKeygen.ps1`

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
4. Give it a descriptive title (e.g., "GitLab SSH Key")

### Step 2: Test GitLab Connection

Verify your SSH setup is working:
- **Method 1 (Recommended):** Right-click on `STEP2_testGitLabConnection.ps1` → "Run with PowerShell"
- **Method 2 (Optional):** `.\STEP2_testGitLabConnection.ps1`

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
- **Method 1 (Recommended):** Right-click on `STEP3_setup-int-repo.ps1` → "Run with PowerShell"
- **Method 2 (Optional):** `.\STEP3_setup-int-repo.ps1`

**What it does:**
- Clones repository branch `3.100/in` to `INT/` folder
- Configures Git settings for TortoiseGit compatibility
- Sets up proper line ending handling
- Shows clone progress with timing

⏱️ **Time Required:** This step can take up to 20 minutes due to the large size of the cloned repository.


### Step 4: Setup TEST Repository

Clone the Test/Acceptance environment:
- **Method 1 (Recommended):** Right-click on `STEP4_setup-test-repo.ps1` → "Run with PowerShell"
- **Method 2 (Optional):** `.\STEP4_setup-test-repo.ps1`

**What it does:**
- Clones repository branch `3.100/ac` to `TEST/` folder
- Configures Git settings for optimal performance
- Handles existing directories with user confirmation

⏱️ **Time Required:** This step can take up to 20 minutes due to the large size of the cloned repository.


### Step 5: Setup PROD Repository

Clone the Production environment:
- **Method 1 (Recommended):** Right-click on `STEP5_setup-prod-repo.ps1` → "Run with PowerShell"
- **Method 2 (Optional):** `.\STEP5_setup-prod-repo.ps1`

**What it does:**
- Clones repository branch `3.100/pd` to `PROD/` folder
- Completes the three-environment setup
- Configures repository for production branch tracking

⏱️ **Time Required:** This step can take up to 20 minutes due to the large size of the cloned repository.


## 📅 Daily Updates

Use the daily update script to keep all repositories synchronized:
- **Method 1 (Recommended):** Right-click on `DailyUpdate.ps1` → "Run with PowerShell"
- **Method 2 (Optional):** `.\DailyUpdate.ps1`

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
   - **Method 1:** Right-click on `DailyUpdate.ps1` → "Run with PowerShell"
   - **Method 2:** `.\DailyUpdate.ps1`

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