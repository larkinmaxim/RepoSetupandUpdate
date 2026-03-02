# GitHub Repository Setup and Management (HTTPS)

This repository contains PowerShell scripts for setting up and managing multiple GitHub repository environments (INT, TEST, PROD) with HTTPS authentication and automated daily updates.

## 🌐 Why HTTPS Instead of SSH? 

This setup uses **HTTPS authentication** because:
- ✅ **Port 22 (SSH) is blocked** by Netskope on most user computers
- ✅ **HTTPS (port 443) works** through corporate firewalls and proxies
- ✅ **Simpler setup** - no SSH key generation needed
- ✅ **Works with SSO/SAML** - integrates with company authentication
- ✅ **More reliable** for corporate environments

## 📥 Getting Started

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
   - You should now see several `.ps1` files

</details>

<details>
<summary><strong>Option 2: Using Right-Click Context Menu (Easiest Visual Method)</strong></summary>

1. **Create your development folder:**
   - Open File Explorer (Windows key + E)
   - Navigate to your C: drive
   - Create a new folder called `DEV` (Right-click → New → Folder)
   - **Double-click** to open the `C:\DEV` folder

2. **Open terminal from right-click menu:**
   - **Right-click** on empty space inside the `C:\DEV` folder
   - Look for **"Open in Terminal"** (Windows 11) or **"Git Bash Here"** (older systems)
   - Click on the terminal option

3. **Clone the repository:**
   - Copy and paste this command:
   ```bash
   git clone https://github.com/larkinmaxim/RepoSetupandUpdate.git .
   ```
   - Press Enter and wait for completion

4. **Check your folder:**
   - Look in your `C:\DEV` folder - you should see all the `.ps1` files

</details>

### What You Should See After Cloning

After successful cloning, your `C:\DEV` folder should contain:
- `STEP0_test-https-connection.ps1`
- `STEP1_setup-netskope-certificate-https.ps1`
- `STEP2_setup-int-repo.ps1`
- `STEP3_setup-test-repo.ps1`
- `STEP4_setup-prod-repo.ps1`
- `DailyUpdate.ps1`
- `README.md`

## ▶️ How to Run PowerShell Scripts

<details>
<summary><strong>Method 1: Right-Click (Easiest for Beginners)</strong></summary>

1. **Navigate** to the folder where you cloned the repository
2. **Right-click** on any `.ps1` script file
3. **Select** "Run with PowerShell" from the context menu
4. **Follow** the on-screen prompts

</details>

<details>
<summary><strong>Method 2: PowerShell Command Line</strong></summary>

1. **Open** PowerShell
2. **Navigate** to the repository folder: `cd C:\DEV`
3. **Run** the script: `.\STEP0_test-https-connection.ps1`

> **💡 Tip:** If you get an execution policy error, run:
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

</details>

## 📋 Overview

The setup process consists of 4 main steps:
0. **[OPTIONAL] Test HTTPS Connection** - Verify HTTPS connectivity to GitHub
1. **Certificate Setup** - Configure Netskope certificate for HTTPS
2. **INT Repository Setup** - Clone Integration environment (stage-in)
3. **TEST Repository Setup** - Clone Test/Acceptance environment (stage-ac)
4. **PROD Repository Setup** - Clone Production environment (stage-pd)

⚡ **Performance:** All clone scripts use shallow cloning (--depth 1) to download only the latest commit, making cloning faster (2-5 minutes) and more reliable.

## 🚀 Step-by-Step Setup Instructions

### Step 0: Test HTTPS Connection (Optional but Recommended)

Verify your HTTPS setup before cloning:
- **Run:** Right-click on `STEP0_test-https-connection.ps1` → "Run with PowerShell"

<details>
<summary><strong>What it does</strong></summary>

**This test checks:**
- Git installation
- SSL certificate configuration
- HTTPS connectivity to GitHub
- Authentication status

**Expected outputs:**
- ✅ **Success:** "HTTPS Connection Working!"
- ⚠️ **Warning:** "Authentication Required" (normal - you'll authenticate during clone)
- ❌ **Error:** Certificate or network issues (follow troubleshooting steps shown)

</details>

### Step 1: Setup Netskope Certificate

Configure the Netskope SSL certificate for HTTPS access:
- **Run:** Right-click on `STEP1_setup-netskope-certificate-https.ps1` → "Run with PowerShell"

<details>
<summary><strong>What it does</strong></summary>

**This script:**
- Locates Netskope certificate in your certificate store
- Exports it to a `.crt` file
- Configures Git to use this certificate
- Verifies the configuration

**Important:**
- ⚠️ You may need to run PowerShell as **Administrator**
- The certificate is required for HTTPS Git operations through Netskope

**After this step:**
- Git will trust the Netskope certificate
- HTTPS connections to GitHub will work properly

</details>

### Step 2: Setup INT Repository

Clone the Integration environment:
- **Run:** Right-click on `STEP2_setup-int-repo.ps1` → "Run with PowerShell"

<details>
<summary><strong>What it does</strong></summary>

**This script:**
- Clones branch `stage-in` to `INT/` folder
- Uses shallow clone (--depth 1) for faster download
- Configures Git settings for optimal performance
- Sets up TortoiseGit integration

⏱️ **Time:** 2-5 minutes typical

**Authentication:**
- You'll be prompted to authenticate via:
  - Web browser (GitHub OAuth/SSO)
  - Or Personal Access Token
- This is normal and only happens once

</details>

### Step 3: Setup TEST Repository

Clone the Test/Acceptance environment:
- **Run:** Right-click on `STEP3_setup-test-repo.ps1` → "Run with PowerShell"

<details>
<summary><strong>What it does</strong></summary>

**This script:**
- Clones branch `stage-ac` to `TEST/` folder
- Uses shallow clone (--depth 1)
- Configures for TortoiseGit

⏱️ **Time:** 2-5 minutes typical

</details>

### Step 4: Setup PROD Repository

Clone the Production environment:
- **Run:** Right-click on `STEP4_setup-prod-repo.ps1` → "Run with PowerShell"

<details>
<summary><strong>What it does</strong></summary>

**This script:**
- Clones branch `stage-pd` to `PROD/` folder
- Uses shallow clone (--depth 1)
- Completes the three-environment setup

⏱️ **Time:** 2-5 minutes typical

</details>

## 📅 Daily Updates

Keep all repositories synchronized with the latest changes:
- **Run:** Right-click on `DailyUpdate.ps1` → "Run with PowerShell"

**What it does:**
- Pulls latest changes from all configured repositories (INT, TEST, PROD)
- Shows progress bars for each operation
- Handles branch switching automatically
- Provides detailed completion summary

**Configuration:**
Edit the `$RepositoryConfig` section to customize:

```powershell
$RepositoryConfig = @(
    @{ 
        FolderPath = "INT"
        BranchName = "stage-in"
        DisplayColor = [System.ConsoleColor]::Cyan 
        Description = "Integration Environment"
    },
    # Add or remove repositories as needed
)
```

## 📁 Folder Structure

After setup completion:

```
C:\DEV\
├── README.md
├── STEP0_test-https-connection.ps1
├── STEP1_setup-netskope-certificate-https.ps1
├── STEP2_setup-int-repo.ps1
├── STEP3_setup-test-repo.ps1
├── STEP4_setup-prod-repo.ps1
├── DailyUpdate.ps1
├── INT/                    # Integration (stage-in)
├── TEST/                   # Acceptance (stage-ac)
└── PROD/                   # Production (stage-pd)
```

## 🔄 Certificate Maintenance

### When to Update Certificates

The Netskope certificate needs refreshing when:
- ⚠️ Netskope software is updated by IT
- ⚠️ Git HTTPS operations suddenly fail with SSL errors
- ⚠️ Certificate bundle is over 1 year old
- ⚠️ After switching computers or user profiles

### Signs You Need to Re-run STEP1

```
❌ SSL certificate problem: certificate has expired
❌ SSL: certificate verification failed
❌ unable to get local issuer certificate
```

### Solution: Re-run Certificate Setup

Simply re-run STEP1 to extract fresh certificates:

```powershell
.\STEP1_setup-netskope-certificate-https.ps1
```

This takes 30-60 seconds and automatically:
- ✅ Extracts latest certificates from Windows
- ✅ Includes any Netskope updates
- ✅ Overwrites old bundle with fresh one
- ✅ No manual cleanup needed

### Check Certificate Health

Run the health check script periodically:

```powershell
.\Check-Certificates.ps1
```

This checks:
- Certificate file exists
- Bundle age (warns if > 1 year old)
- Git configuration is correct
- GitHub HTTPS connection works

---

## ❓ Frequently Asked Questions

### What is HTTPS authentication?
HTTPS uses standard web protocols (port 443) for Git operations. It works through corporate firewalls and integrates with your company's SSO/SAML authentication.

### Do I need SSH keys?
**No!** SSH keys are not needed with HTTPS. Authentication happens via:
- GitHub web login (OAuth)
- Personal Access Token
- SSO/SAML (company authentication)

### What is a shallow clone?
A shallow clone (`--depth 1`) downloads only the latest commit instead of full history:
- ✅ Much faster (2-5 minutes vs 20+ minutes)
- ✅ Smaller download size
- ✅ More reliable on unstable connections
- ⚠️ No commit history (only latest files)

### Do I need the full git history?
For most work, no. You can still:
- Make commits and push changes
- Create branches
- Pull updates
- Use TortoiseGit

To get full history later: `git fetch --unshallow`

### Why Netskope certificate?
Netskope inspects HTTPS traffic for security. Git needs to trust the Netskope certificate to allow these inspections.

## ❗ Troubleshooting

### Certificate Issues

**Problem:** "SSL certificate problem" errors
**Solution:**
1. Run `STEP1_setup-netskope-certificate-https.ps1` as Administrator
2. Verify certificate: `git config --global http.sslcainfo`
3. Restart PowerShell
4. Run `STEP0_test-https-connection.ps1` to verify

### Authentication Issues

**Problem:** Authentication fails or keeps prompting
**Solution:**
1. Clear credential cache: `git credential-cache exit`
2. Check GitHub SSO authorization: https://github.com/settings/connections/applications
3. Generate Personal Access Token if needed: https://github.com/settings/tokens
4. Verify organization SSO is authorized

### Network Issues

**Problem:** Connection timeouts or failures
**Solution:**
1. Check VPN connection
2. Verify internet connectivity
3. Test: `git ls-remote --heads https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git`
4. Check corporate proxy settings

### Clone Failures

**Problem:** Clone fails or gets stuck
**Solution:**
1. Press Ctrl+C to cancel
2. Check available disk space (need ~5GB per repository)
3. Try running `STEP0_test-https-connection.ps1` first
4. Delete partial folder and retry

### TortoiseGit Integration

**Problem:** TortoiseGit doesn't work
**Solution:**
- Repositories are pre-configured for TortoiseGit
- Right-click in repository folder to access TortoiseGit menu
- HTTPS requires no special TortoiseGit configuration

## 🔧 Advanced Configuration

### Repository URLs
All scripts default to HTTPS:
```
https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git
```

Override with `-RemoteUrl` parameter if needed.

### Branch Names
Default branches:
- INT: `stage-in`
- TEST: `stage-ac`
- PROD: `stage-pd`

Override with `-BranchName` parameter.

### Script Parameters

**STEP0_test-https-connection.ps1**
- No parameters

**STEP1_setup-netskope-certificate-https.ps1**
- No parameters (auto-detects certificate)

**STEP2-4_setup-*-repo.ps1**
- `-RemoteUrl <string>`: Git repository URL
- `-BranchName <string>`: Target branch name
- `-FolderName <string>`: Local folder name

**DailyUpdate.ps1**
- No parameters - configuration via script editing

## 🔄 Daily Workflow

1. **Morning:**
   - Run `DailyUpdate.ps1` to sync all repositories

2. **Development:**
   - Work in appropriate folder (INT/TEST/PROD)
   - Use TortoiseGit or command line

3. **End of Day:**
   - Commit and push changes
   - Optional: Run `DailyUpdate.ps1` again

## 🔐 Security Notes

- HTTPS uses your GitHub credentials (OAuth/SSO)
- Credentials are managed by Git Credential Manager
- Netskope certificate enables secure traffic inspection
- Always use official Netskope certificate from your IT department

## 📞 Support

If you encounter issues:
1. Run `STEP0_test-https-connection.ps1` for diagnostics
2. Check certificate setup with STEP1
3. Verify VPN and network access
4. Review error messages - scripts provide detailed troubleshooting

## 🎯 Quick Start Summary

```powershell
# 1. Test connection (optional)
.\STEP0_test-https-connection.ps1

# 2. Setup certificate
.\STEP1_setup-netskope-certificate-https.ps1

# 3. Clone all environments
.\STEP2_setup-int-repo.ps1
.\STEP3_setup-test-repo.ps1
.\STEP4_setup-prod-repo.ps1

# 4. Daily updates
.\DailyUpdate.ps1
```

---

**Happy coding!** 🚀

*This setup uses HTTPS because SSH (port 22) is blocked by Netskope on corporate networks.*
