# STEP3_setup-int-repo.ps1 — INT Repository Setup

Bootstraps the Integration environment by cloning the specified branch into the `INT` folder and configuring repository settings.

## Synopsis

```powershell
./STEP3_setup-int-repo.ps1 [-RemoteUrl <string>] [-BranchName <string>] [-FolderName <string>]
```

## Parameters

- RemoteUrl <string>
  - Git repository URL. Default: `https://github.com/trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git`

- BranchName <string>
  - Branch to clone. Default: `stage-in`

- FolderName <string>
  - Target folder name. Default: `INT`

## Behavior

- Uses `$PSScriptRoot` as the base directory by default.
- Prompts to proceed and, if folder exists, to remove it before cloning.
- Runs `git clone -b <branch> --progress <url> <target>` with real-time output.
- Configures repository defaults and TortoiseGit-friendly settings.
- Switches remote to SSH (`git@github.com:trimble-transport/ttc-ctp-custint-exchange-platform-monolith.git`).

## Examples

```powershell
# Standard INT setup
./STEP3_setup-int-repo.ps1

# Use a different branch
./STEP3_setup-int-repo.ps1 -BranchName "stage-dev"

# Clone into a different folder name
./STEP3_setup-int-repo.ps1 -FolderName "INTEGRATION"

# Clone from a custom remote URL
./STEP3_setup-int-repo.ps1 -RemoteUrl "https://github.com/example-org/repo.git"
```

## Output

- Console status with timing summary.
- Exit codes: `0` success, `1` failure, `0` cancel.
