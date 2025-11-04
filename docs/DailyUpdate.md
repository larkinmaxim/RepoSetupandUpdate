# DailyUpdate.ps1 — Multi-Repository Updater with Progress Tracking

Updates all configured repositories to their designated branches and displays rich progress output.

## Synopsis

```powershell
./DailyUpdate.ps1
```

## Configuration

Defined inline at the top of the script:

```powershell
$RepositoryConfig = @(
    @{ FolderPath = "INT";  BranchName = "stage-in"; DisplayColor = [System.ConsoleColor]::Cyan;    Description = "Integration Environment" },
    @{ FolderPath = "TEST"; BranchName = "stage-ac"; DisplayColor = [System.ConsoleColor]::Magenta; Description = "Acceptance Environment" },
    @{ FolderPath = "PROD"; BranchName = "stage-pd"; DisplayColor = [System.ConsoleColor]::Yellow;  Description = "Production Environment" }
)
$StartingDirectory = "INT"
```

- FolderPath: local directory name of the repo to update.
- BranchName: static branch name to use (e.g., `stage-in`, `stage-ac`, `stage-pd`).
- DisplayColor: console color used for messages.
- Description: human-friendly label.
- StartingDirectory: path where the script begins.

## Internal Functions

- Invoke-GitCommand(Command: string)
  - Executes a git command and filters out "unable to connect to cache daemon" noise.

- Update-Repository(FolderPath: string, BranchName: string, Color: ConsoleColor, RepoIndex: int, TotalRepos: int, Description: string)
  - Checks out or creates the branch and force-syncs to remote with `reset --hard`.
  - Displays hierarchical progress bars for multi-repo updates.

## Behavior

- Disables git credential caching during the run; restores at the end.
- Iterates through all configured repositories.
- For each repo: fetch, checkout/create branch, and hard reset to remote.
- Displays a final summary and a 10-second completion countdown.

## Examples

```powershell
# Standard daily update across INT, TEST, and PROD as configured
./DailyUpdate.ps1

# Customize repositories by editing $RepositoryConfig
# Example: add a QA repo
# @{ FolderPath = "QA"; BranchName = "stage-qa"; DisplayColor = [System.ConsoleColor]::Blue; Description = "QA Environment" }
```

## Output

- Rich progress via `Write-Progress`.
- Final success banner and per-repo branch summary.

## Notes

- Ensure repos (folders) already exist and are valid Git repositories.
- Branch names are now static (no version detection needed).
- This script is designed for GitHub with fixed branch names: `stage-in`, `stage-ac`, `stage-pd`.
