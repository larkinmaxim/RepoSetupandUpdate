# GitHub Repository Setup and Management

This repository contains PowerShell scripts for setting up and managing multiple GitHub repository environments (INT, TEST, PROD) with automated SSH key generation and daily updates.

## 📥 Getting Started !

### What is "Cloning a Repository"?
Cloning means downloading a complete copy of this repository (all files and scripts) to your computer so you can use them locally.

### Step-by-Step Instructions for Absolute Beginners

<details>
<summary><strong>Option 1: Using File Explorer + PowerShell (Recommended for Beginners)</strong></summary>

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

</details>

<details>
<summary><strong>Option 2: Using Command Prompt</strong></summary>

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

</details>

<details>
<summary><strong>Option 3: Using Right-Click Context Menu (Easiest Visual Method)</strong></summary>

1. **Create your development folder:**
   - Open File Explorer (Windows key + E)
   - Navigate to your C: drive
   - Create a new folder called `DEV` or any other NAME (Right-click → New → Folder)
   - **Double-click** to open the `C:\DEV` folder

2. **Open terminal from right-click menu:**
   - **Right-click** on empty space inside the `C:\DEV` folder
   - Look for **"Open in Terminal"** (Windows 11/newer) or **"Git Bash Here"** (older systems)
   - Click on the terminal option - this opens a terminal in the correct location

3. **Clone the repository:**
   - Copy and paste this command into the terminal window:
   ```bash
   git clone https://github.com/larkinmaxim/RepoSetupandUpdate.git .
   ```
   - Press Enter and wait for the download to complete
   - **Note:** This works in both PowerShell (Windows Terminal) and Git Bash

4. **Close the terminal and check your folder:**
   - Type `exit` and press Enter to close the terminal
   - Look in your `C:\DEV` folder - you should see all the `.ps1` files

> **Note:** If you don't see "Open in Terminal" or "Git Bash Here" in the right-click menu, you may need to install Git for Windows first (see troubleshooting section below).

</details>



### What You Should See After Cloning

After successful cloning, your `C:\DEV` folder should contain:
- `STEP1_sshKeygen.ps1`
- `STEP2_testGithubConnection.ps1`
- `STEP3_setup-int-repo.ps1`
- `STEP4_setup-test-repo.ps1`
- `STEP5_setup-prod-repo.ps1`
- `DailyUpdate.ps1`
- `README.md`

### Troubleshooting Common Issues

<details>
<summary><strong>Problem: "git is not recognized as an internal or external command"</strong></summary>

- Solution: You need to install Git first
- Go to: https://git-scm.com/downloads
- Download and install Git for Windows
- ✅ **Important:** During installation, make sure "Git Bash Here" is selected
- Restart your computer and try again

</details>

<details>
<summary><strong>Problem: Don't see "Open in Terminal" or "Git Bash Here" in right-click menu</strong></summary>

- **Windows 11/newer:** Look for "Open in Terminal" - this is the modern equivalent
- **Older Windows:** Look for "Git Bash Here" after installing Git for Windows
- **If neither appears:** Git for Windows isn't installed or wasn't installed with context menu integration
- Download Git from: https://git-scm.com/downloads
- During installation, make sure these options are checked:
  - ✅ "Windows Explorer integration"
  - ✅ "Git Bash Here"
  - ✅ "Git GUI Here"
- Restart your computer after installation

</details>

<details>
<summary><strong>Problem: "Access denied" or permission errors</strong></summary>

- Solution: Run PowerShell as Administrator
- Right-click on PowerShell → "Run as administrator"
- Alternative: Use Git Bash instead (usually has fewer permission issues)

</details>

<details>
<summary><strong>Problem: Can't find the cloned files</strong></summary>

- Make sure you're in the correct directory (`C:\DEV`)
- The `.` at the end of the clone command is important - it means "clone into current folder"
- If files are in a subfolder, move them up to `C:\DEV` directly

</details>

<details>
<summary><strong>Problem: Terminal window closes immediately</strong></summary>

- This is normal after the download completes
- Just check your `C:\DEV` folder - the files should be there
- If nothing downloaded, try running the command again
- This happens with both PowerShell (Windows Terminal) and Git Bash

</details>

<details>
<summary><strong>Problem: TortoiseGit "No supported authentication methods available (server sent: publickey)"</strong></summary>

- This is a TortoiseGit SSH configuration issue, not missing SSH keys
- **Solution 1 (Recommended):** Change TortoiseGit SSH client to OpenSSH
  
  **Detailed Steps:**
  1. **Open TortoiseGit Settings:**
     - Right-click on any folder in Windows Explorer
     - Select "TortoiseGit" → "Settings" from the context menu
  
  2. **Navigate to Network Settings:**
     - In the left panel, click on "Network"
     - Look for the "SSH client" field on the right side
  
  3. **Change SSH Client Path:**
     - **Current value:** Usually shows `TortoiseGitPlink.exe` (this causes the error)
     - **Click "Browse"** button next to the SSH client field
     - **Navigate to:** `C:\Windows\System32\OpenSSH\`
     - **Select:** `ssh.exe`
     - **Alternative path:** `C:\Program Files\Git\usr\bin\ssh.exe`
  
  4. **Apply Changes:**
     - Click "Apply" then "OK"
     - **Test:** Try your TortoiseGit operation again (clone, pull, push)
  
  **Why this works:** TortoiseGit's default SSH client (TortoiseGitPlink) uses different authentication than OpenSSH, which your system is already configured for.

</details>




### Ready to Continue?
Once you see all the `.ps1` files in your `C:\DEV` folder, you're ready to proceed to the next section!

## ▶️ How to Run PowerShell Scripts

There are two easy ways to run the PowerShell scripts in this repository:

<details>
<summary><strong>Method 1: Right-Click (Easiest for Beginners)</strong></summary>

1. **Navigate** to the folder where you cloned the repository
2. **Right-click** on any `.ps1` script file (e.g., `STEP1_sshKeygen.ps1`)
3. **Select** "Run with PowerShell" from the context menu
4. **Allow execution** if Windows asks for permission
5. **Follow** the on-screen prompts

</details>

<details>
<summary><strong>Method 2: PowerShell Command Line</strong></summary>

1. **Open** PowerShell as Administrator (recommended)
2. **Navigate** to the repository folder: `cd C:\DEV` (or your chosen directory)
3. **Run** the script: `.\STEP1_sshKeygen.ps1`

> **💡 Tip:** If you get an execution policy error, run this command in PowerShell as Administrator:
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

</details>

## 📋 Overview

The setup process consists of 5 main steps:
1. **SSH Key Generation** - Generate SSH keys for GitHub authentication
2. **Connection Testing** - Verify GitHub SSH connectivity
3. **INT Repository Setup** - Clone and configure Integration environment
4. **TEST Repository Setup** - Clone and configure Test/Acceptance environment  
5. **PROD Repository Setup** - Clone and configure Production environment

⚡ **Performance:** Steps 3, 4, and 5 use shallow cloning (--depth 1) to download only the latest commit. This makes cloning much faster (typically 2-5 minutes) and more reliable on unstable internet connections.

Additionally, there's a daily update script that automatically pulls the latest changes from all environments.

## 📚 API Documentation

Comprehensive documentation for all scripts (parameters, behavior, and examples) is available here:

- See API Docs: docs/README.md

## 🔧 Prerequisites

Before running these scripts, ensure you have:

- **PowerShell 5.0+** (Windows PowerShell or PowerShell Core)
- **Git** installed and accessible from command line
- **Network access** to GitHub server (`github.com`)
- **VPN connection** (if required by your organization)
- **Email address** for SSH key generation
- **TortoiseGit** (optional, for GUI Git operations)

## 🚀 Step-by-Step Setup Instructions

### Step 1: Generate SSH Keys

Run the SSH key generation script:
- **Method 1 (Recommended):** Right-click on `STEP1_sshKeygen.ps1` → "Run with PowerShell"
- **Method 2 (Optional):** `.\STEP1_sshKeygen.ps1`

<details>
<summary><strong>Step 1 Details - What it does and options</strong></summary>

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
2. Go to: https://github.com/settings/keys
3. Click "New SSH Key" and paste the public key
4. Give it a descriptive title (e.g., "GitHub SSH Key")

</details>

### Step 2: Test GitHub Connection

Verify your SSH setup is working:
- **Method 1 (Recommended):** Right-click on `STEP2_testGithubConnection.ps1` → "Run with PowerShell"
- **Method 2 (Optional):** `.\STEP2_testGithubConnection.ps1`

<details>
<summary><strong>Step 2 Details - What it does and expected output</strong></summary>

**What it does:**
- Checks if SSH keys exist
- Shows key fingerprint
- Tests connection to GitHub server
- Provides troubleshooting guidance for common issues

**Expected Success Output:**
```
[SUCCESS] Connection Working!
SSH connection to GitHub is working perfectly!
GitHub Response: Hi @username! You've successfully authenticated...
```

</details>

### Step 3: Setup INT Repository

Clone the Integration environment:
- **Method 1 (Recommended):** Right-click on `STEP3_setup-int-repo.ps1` → "Run with PowerShell"
- **Method 2 (Optional):** `.\STEP3_setup-int-repo.ps1`

<details>
<summary><strong>Step 3 Details - What it does and timing</strong></summary>

**What it does:**
- Clones repository branch `stage-in` to `INT/` folder using shallow clone (--depth 1)
- Shallow clone downloads only the latest commit for faster, more reliable cloning
- Configures Git settings for TortoiseGit compatibility
- Sets up proper line ending handling
- Shows clone progress with timing

⏱️ **Time Required:** Shallow clone significantly reduces download time and is more reliable on unstable connections. Typically completes in 2-5 minutes.

</details>


### Step 4: Setup TEST Repository

Clone the Test/Acceptance environment:
- **Method 1 (Recommended):** Right-click on `STEP4_setup-test-repo.ps1` → "Run with PowerShell"
- **Method 2 (Optional):** `.\STEP4_setup-test-repo.ps1`

<details>
<summary><strong>Step 4 Details - What it does and timing</strong></summary>

**What it does:**
- Clones repository branch `stage-ac` to `TEST/` folder using shallow clone (--depth 1)
- Shallow clone downloads only the latest commit for faster, more reliable cloning
- Configures Git settings for optimal performance
- Handles existing directories with user confirmation

⏱️ **Time Required:** Shallow clone significantly reduces download time and is more reliable on unstable connections. Typically completes in 2-5 minutes.

</details>


### Step 5: Setup PROD Repository

Clone the Production environment:
- **Method 1 (Recommended):** Right-click on `STEP5_setup-prod-repo.ps1` → "Run with PowerShell"
- **Method 2 (Optional):** `.\STEP5_setup-prod-repo.ps1`

<details>
<summary><strong>Step 5 Details - What it does and timing</strong></summary>

**What it does:**
- Clones repository branch `stage-pd` to `PROD/` folder using shallow clone (--depth 1)
- Shallow clone downloads only the latest commit for faster, more reliable cloning
- Completes the three-environment setup
- Configures repository for production branch tracking

⏱️ **Time Required:** Shallow clone significantly reduces download time and is more reliable on unstable connections. Typically completes in 2-5 minutes.

</details>


## 📅 Daily Updates

Use the daily update script to keep all repositories synchronized:
- **Method 1 (Recommended):** Right-click on `DailyUpdate.ps1` → "Run with PowerShell"
- **Method 2 (Optional):** `.\DailyUpdate.ps1`

**What it does:**
- Automatically pulls latest changes from all configured repositories
- Shows progress bars for each operation
- Handles branch creation and switching automatically
- Provides detailed completion summary

**Configuration:**
The script can be customized by editing the `$RepositoryConfig` section:

```powershell
$RepositoryConfig = @(
    @{ 
        FolderPath = "INT"     # Local folder name
        BranchName = "stage-in"    # Git branch name
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
├── STEP2_testGithubConnection.ps1
├── STEP3_setup-int-repo.ps1
├── STEP4_setup-test-repo.ps1
├── STEP5_setup-prod-repo.ps1
├── DailyUpdate.ps1
├── INT/                    # Integration environment (branch: stage-in)
├── TEST/                   # Test environment (branch: stage-ac)
└── PROD/                   # Production environment (branch: stage-pd)
```

## 🔧 Configuration Options

### Email Configuration (Step 1)
To avoid being prompted for email each time, edit `STEP1_sshKeygen.ps1`:

```powershell
$DEFAULT_EMAIL = "your.email@company.com"
```

### Repository URLs
All setup scripts default to SSH authentication:
```
git@github.com:trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git
```

Override with the `-RemoteUrl` parameter if needed (ensure SSH format for private repositories).

### Branch Names
Default branches:
- INT: `stage-in`
- TEST: `stage-ac`  
- PROD: `stage-pd`

Override with the `-BranchName` parameter.

## ❓ Frequently Asked Questions

### What is a shallow clone?
A shallow clone (`--depth 1`) downloads only the latest commit instead of the entire git history. This:
- ✅ Reduces download size significantly (from GB to MB)
- ✅ Makes cloning much faster (2-5 minutes vs 20+ minutes)
- ✅ More reliable on unstable connections
- ✅ Provides all current files you need for development
- ⚠️ Does not include commit history (you'll only see the latest commit)

### Do I need the full git history?
For most development work, no. Shallow clones provide all the current files and you can still:
- Make commits and push changes
- Create branches
- Pull updates
- Use TortoiseGit

### How do I convert a shallow clone to a full clone?
If you later need the full history, run this in the repository folder:
```powershell
git fetch --unshallow
```

## ❗ Troubleshooting

### SSH Authentication Issues

**Problem:** "Permission denied" when testing connection
**Solution:**
1. Ensure public key is correctly added to GitHub
2. Check key file permissions: `icacls ~/.ssh/id_rsa`
3. Verify you're using the correct GitHub URL

### Network Connection Issues

**Problem:** "Connection refused" or timeouts
**Solution:**
1. Check VPN connection
2. Verify network access to `github.com`
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

**Problem:** TortoiseGit "No supported authentication methods available (server sent: publickey)"
**Solution:** Change TortoiseGit SSH client to OpenSSH
  1. Open TortoiseGit Settings → Network
  2. Change SSH client to: `C:\Windows\System32\OpenSSH\ssh.exe`
  3. Or use: `C:\Program Files\Git\usr\bin\ssh.exe`
  4. Apply and retry

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
4. **Check GitHub Access** - Verify you can access GitHub web interface
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

### STEP2_testGithubConnection.ps1
- No parameters required

### STEP3-5_setup-*-repo.ps1
- `-RemoteUrl <string>`: Git repository URL
- `-BranchName <string>`: Target branch name
- `-FolderName <string>`: Local folder name

### DailyUpdate.ps1
- No parameters - configuration via script editing

---

**Happy coding!** 🚀 