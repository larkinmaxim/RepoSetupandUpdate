# STEP4_setup-test-repo.ps1 — TEST Repository Setup

Bootstraps the Test/Acceptance environment by cloning the specified branch into the `TEST` folder and configuring repository settings.

## Synopsis

```powershell
./STEP4_setup-test-repo.ps1 [-RemoteUrl <string>] [-BranchName <string>] [-FolderName <string>]
```

## Parameters

- RemoteUrl <string>
  - Git repository URL. Default: `https://gitlab.office.transporeon.com/Development/portfolio.git`

- BranchName <string>
  - Branch to clone. Default: `3.100/ac`

- FolderName <string>
  - Target folder name. Default: `TEST`

## Behavior

- Uses `$PSScriptRoot` as the base directory by default.
- Prompts to proceed and, if folder exists, to remove it before cloning.
- Runs `git clone -b <branch> --progress <url> <target>` with real-time output.
- Configures repository defaults and TortoiseGit-friendly settings.
- Switches remote to SSH (`git@gitlab.office.transporeon.com:Development/portfolio.git`).

## Examples

```powershell
# Standard TEST setup
./STEP4_setup-test-repo.ps1

# Use a different branch
./STEP4_setup-test-repo.ps1 -BranchName "3.101/ac"

# Clone into a different folder name
./STEP4_setup-test-repo.ps1 -FolderName "ACCEPTANCE"

# Clone from a custom remote URL
./STEP4_setup-test-repo.ps1 -RemoteUrl "https://gitlab.example.com/Dev/portfolio.git"
```

## Output

- Console status with timing summary.
- Exit codes: `0` success, `1` failure, `0` cancel.