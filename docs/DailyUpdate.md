# DailyUpdate.ps1 — Multi-Repository Updater with Progress Tracking

Updates all configured repositories to the latest detected version branch and displays rich progress output.

## Synopsis

```powershell
./DailyUpdate.ps1
```

## Configuration

Defined inline at the top of the script:

```powershell
$RepositoryConfig = @(
    @{ FolderPath = "INT";  BranchSuffix = "in"; DisplayColor = [System.ConsoleColor]::Cyan;    Description = "Integration Environment" },
    @{ FolderPath = "TEST"; BranchSuffix = "ac"; DisplayColor = [System.ConsoleColor]::Magenta; Description = "Acceptance Environment" },
    @{ FolderPath = "PROD"; BranchSuffix = "pd"; DisplayColor = [System.ConsoleColor]::Yellow;  Description = "Production Environment" }
)
$StartingDirectory = "INT"
```

- FolderPath: local directory name of the repo to update.
- BranchSuffix: branch suffix combined with latest version (e.g., `3.100/in`).
- DisplayColor: console color used for messages.
- Description: human-friendly label.
- StartingDirectory: path where the script begins and discovers version info.

## Internal Functions

- Invoke-GitCommand(Command: string)
  - Executes a git command and filters out "unable to connect to cache daemon" noise.

- Get-LatestVersionNumber(): string
  - Fetches remote branches, extracts semantic versions, returns the latest (e.g., `3.100`).

- Update-Repository(FolderPath: string, VersionNumber: string, BranchSuffix: string, Color: ConsoleColor, RepoIndex: int, TotalRepos: int, Description: string)
  - Checks out or creates `<Version>/<BranchSuffix>` and force-syncs to remote with `reset --hard`.
  - Displays hierarchical progress bars for multi-repo updates.

## Behavior

- Disables git credential caching during the run; restores at the end.
- Determines the latest version once, then iterates repositories.
- For each repo: fetch, checkout/create branch, and hard reset to remote.
- Displays a final summary and a 10-second completion countdown.

## Examples

```powershell
# Standard daily update across INT, TEST, and PROD as configured
./DailyUpdate.ps1

# Customize repositories by editing $RepositoryConfig
# Example: add a QA repo
# @{ FolderPath = "QA"; BranchSuffix = "qa"; DisplayColor = [System.ConsoleColor]::Blue; Description = "QA Environment" }
```

## Output

- Rich progress via `Write-Progress`.
- Final success banner and per-repo branch summary.

## Notes

- Ensure repos (folders) already exist and are valid Git repositories.
- `StartingDirectory` should be a valid repo with remote tracking to detect versions.