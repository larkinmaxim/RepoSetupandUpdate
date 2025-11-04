# STEP5_setup-prod-repo.ps1 — PROD Repository Setup

Bootstraps the Production environment by cloning the specified branch into the `PROD` folder and configuring repository settings.

## Synopsis

```powershell
./STEP5_setup-prod-repo.ps1 [-RemoteUrl <string>] [-BranchName <string>] [-FolderName <string>]
```

## Parameters

- RemoteUrl <string>
  - Git repository URL. Default: `https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git`

- BranchName <string>
  - Branch to clone. Default: `stage-pd`

- FolderName <string>
  - Target folder name. Default: `PROD`

## Behavior

- Uses `$PSScriptRoot` as the base directory by default.
- Prompts to proceed and, if folder exists, to remove it before cloning.
- Runs `git clone -b <branch> --progress <url> <target>` with real-time output.
- Configures repository defaults and TortoiseGit-friendly settings.
- Switches remote to SSH (`git@github.com:trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git`).

## Examples

```powershell
# Standard PROD setup
./STEP5_setup-prod-repo.ps1

# Use a different branch
./STEP5_setup-prod-repo.ps1 -BranchName "stage-prod"

# Clone into a different folder name
./STEP5_setup-prod-repo.ps1 -FolderName "PRODUCTION"

# Clone from a custom remote URL
./STEP5_setup-prod-repo.ps1 -RemoteUrl "https://github.com/example-org/repo.git"
```

## Output

- Console status with timing summary.
- Exit codes: `0` success, `1` failure, `0` cancel.
