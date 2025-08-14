# Enhanced Git Repository Update Script with Progress Bars

# =============================================================================
# CONFIGURATION SECTION - Customize these paths for your environment
# =============================================================================

# Define your local folder structure here
# Each entry contains: FolderPath, BranchSuffix, DisplayColor
$RepositoryConfig = @(
    @{ 
        FolderPath = "INT"     # Local folder name
        BranchSuffix = "in"    # Git branch suffix (e.g., 3.100/in)
        DisplayColor = [System.ConsoleColor]::Cyan 
        Description = "Integration Environment"
    },
    @{ 
        FolderPath = "TEST"    # Local folder name  
        BranchSuffix = "ac"    # Git branch suffix (e.g., 3.100/ac)
        DisplayColor = [System.ConsoleColor]::Magenta 
        Description = "Acceptance Environment"
    },
    @{ 
        FolderPath = "PROD"    # Local folder name
        BranchSuffix = "pd"    # Git branch suffix (e.g., 3.100/pd)
        DisplayColor = [System.ConsoleColor]::Yellow 
        Description = "Production Environment"
    }
)

# Starting directory (where to look for version branches)
$StartingDirectory = "INT"

# =============================================================================
# INSTRUCTIONS FOR OTHER USERS:
# 
# To adapt this script for your environment, modify the $RepositoryConfig above:
# 
# Example for different folder names:
# $RepositoryConfig = @(
#     @{ FolderPath = "MyIntegration"; BranchSuffix = "in"; DisplayColor = [System.ConsoleColor]::Cyan; Description = "Integration" },
#     @{ FolderPath = "MyAcceptance"; BranchSuffix = "ac"; DisplayColor = [System.ConsoleColor]::Magenta; Description = "Acceptance" },
#     @{ FolderPath = "MyProduction"; BranchSuffix = "pd"; DisplayColor = [System.ConsoleColor]::Yellow; Description = "Production" }
# )
# 
# You can add or remove repositories as needed!
# =============================================================================

# Function to handle Git operations and suppress specific errors
function Invoke-GitCommand {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Command
    )
    
    # Execute the git command
    $output = Invoke-Expression $Command 2>&1
    
    # Filter out the cache daemon error
    $output | Where-Object { $_ -notmatch "fatal: unable to connect to cache daemon" }
}

# Function to get the latest version number once with progress tracking
function Get-LatestVersionNumber {
    Write-Progress -Id 1 -Activity "Initializing Repository Updates" -Status "Fetching remote branches..." -PercentComplete 10
    
    # Get all remote branches
    Invoke-GitCommand "git fetch origin"
    
    Write-Progress -Id 1 -Activity "Initializing Repository Updates" -Status "Analyzing remote branches..." -PercentComplete 50
    
    $branches = git branch -r | ForEach-Object { $_.ToString().Trim() }
    
    Write-Progress -Id 1 -Activity "Initializing Repository Updates" -Status "Processing version information..." -PercentComplete 80
    
    # Create objects with version and branch name for proper sorting
    $versionObjects = $branches | ForEach-Object {
        if ($_ -match "origin/(\d+\.\d+)/") {
            [PSCustomObject]@{
                Version = [System.Version]$matches[1]
            }
        }
    } | Where-Object { $_.Version -ne $null }
    
    # Sort by version and get the latest unique version
    $latestVersion = $versionObjects | Sort-Object Version -Unique | Select-Object -Last 1
    
    Write-Progress -Id 1 -Activity "Initializing Repository Updates" -Status "Version detection complete" -PercentComplete 100
    Start-Sleep -Milliseconds 500  # Brief pause to show completion
    Write-Progress -Id 1 -Activity "Initializing Repository Updates" -Completed
    
    return $latestVersion.Version.ToString()
}

# Function to update a repository with force pull using known version and progress tracking
function Update-Repository {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FolderPath,
        
        [Parameter(Mandatory = $true)]
        [string]$VersionNumber,
        
        [Parameter(Mandatory = $true)]
        [string]$BranchSuffix,
        
        [Parameter(Mandatory = $false)]
        [System.ConsoleColor]$Color = [System.ConsoleColor]::Cyan,
        
        [Parameter(Mandatory = $true)]
        [int]$RepoIndex,
        
        [Parameter(Mandatory = $true)]
        [int]$TotalRepos,
        
        [Parameter(Mandatory = $false)]
        [string]$Description = ""
    )
    
    $overallPercent = [math]::Round((($RepoIndex - 1) / $TotalRepos) * 100)
    $displayName = if ($Description) { "$FolderPath ($Description)" } else { $FolderPath }
    Write-Progress -Id 2 -Activity "Updating All Repositories" -Status "Processing $displayName ($RepoIndex of $TotalRepos)" -PercentComplete $overallPercent
    
    # Step 1: Change directory
    Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Status "Changing directory..." -PercentComplete 10
    
    Write-Host "Changing directory to $FolderPath..." -ForegroundColor $Color
    
    if ($FolderPath -ne $StartingDirectory) {
        cd "../$FolderPath"
    } else {
        # Make sure we're in the starting directory
        $currentDir = (Get-Location).Path
        if (-not $currentDir.EndsWith($StartingDirectory)) {
            cd $StartingDirectory
        }
    }
    
    # Step 2: Fetch latest changes
    Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Status "Fetching latest changes from remote..." -PercentComplete 30
    Invoke-GitCommand "git fetch origin"
    
    # Step 3: Prepare branch information
    Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Status "Preparing branch information..." -PercentComplete 50
    $branchName = "$VersionNumber/$BranchSuffix"
    $remoteBranch = "origin/$VersionNumber/$BranchSuffix"
    
    Write-Host "Working with branch: $branchName" -ForegroundColor $Color
    
    # Step 4: Check out branch
    Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Status "Checking out branch $branchName..." -PercentComplete 70
    
    git checkout $branchName 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Creating local branch for $branchName..." -ForegroundColor $Color
        Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Status "Creating new local branch..." -PercentComplete 80
        Invoke-GitCommand "git checkout -b $branchName $remoteBranch"
    } else {
        # Step 5: Force update the local branch
        Write-Host "Resetting local branch to match remote (force pull)..." -ForegroundColor $Color
        Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Status "Performing force pull (reset --hard)..." -PercentComplete 90
        Invoke-GitCommand "git reset --hard $remoteBranch"
    }
    
    # Step 6: Complete
    Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Status "$displayName update completed successfully!" -PercentComplete 100
    Start-Sleep -Milliseconds 800  # Brief pause to show completion
    Write-Progress -Id 3 -ParentId 2 -Activity "Updating $displayName Repository" -Completed
}

# Main script execution with progress tracking
Write-Host "=== Git Repository Update Script with Progress Tracking ===" -ForegroundColor White
Write-Host "Starting repository update process..." -ForegroundColor Green

# Initial setup
Write-Progress -Id 1 -Activity "Initializing Repository Updates" -Status "Setting up Git configuration..." -PercentComplete 5

# Set global git config to avoid credential cache
Write-Host "Disabling git credential cache globally for this session..."
Invoke-GitCommand "git config --global credential.helper ''"

# Change directory to starting directory
Write-Host "Changing directory to $StartingDirectory..."
cd $StartingDirectory

# Get the latest version number once
Write-Host "Determining latest version number..."
$latestVersion = Get-LatestVersionNumber
Write-Host "Latest version detected: $latestVersion" -ForegroundColor Yellow

$totalRepos = $RepositoryConfig.Count

# Add spacing before displaying configuration to avoid overlap with progress bars
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "Repository Configuration:" -ForegroundColor White
for ($i = 0; $i -lt $totalRepos; $i++) {
    $repo = $RepositoryConfig[$i]
    Write-Host "  $($i + 1). $($repo.FolderPath) -> $latestVersion/$($repo.BranchSuffix) ($($repo.Description))" -ForegroundColor $repo.DisplayColor
}

# Update all repositories with progress tracking
for ($i = 0; $i -lt $totalRepos; $i++) {
    $repo = $RepositoryConfig[$i]
    Update-Repository -FolderPath $repo.FolderPath -VersionNumber $latestVersion -BranchSuffix $repo.BranchSuffix -Color $repo.DisplayColor -RepoIndex ($i + 1) -TotalRepos $totalRepos -Description $repo.Description
}

# Final cleanup with progress
Write-Progress -Id 2 -Activity "Updating All Repositories" -Status "Finalizing updates..." -PercentComplete 90
Write-Progress -Id 4 -ParentId 2 -Activity "Cleanup" -Status "Resetting Git configuration..." -PercentComplete 50

# Reset git config to default
Write-Host "`nResetting git credential helper..."
Invoke-GitCommand "git config --global --unset credential.helper"

Write-Progress -Id 4 -ParentId 2 -Activity "Cleanup" -Status "Cleanup completed" -PercentComplete 100
Write-Progress -Id 2 -Activity "Updating All Repositories" -Status "All repositories updated successfully!" -PercentComplete 100

# Clean up all progress bars
Start-Sleep -Milliseconds 1000
Write-Progress -Id 4 -ParentId 2 -Activity "Cleanup" -Completed
Write-Progress -Id 2 -Activity "Updating All Repositories" -Completed

# Add confirmation messages with enhanced formatting
$separator = "=" * 60
Write-Host "`n$separator" -ForegroundColor White
Write-Host "*** ALL REPOSITORIES UPDATED SUCCESSFULLY! ***" -ForegroundColor Green
Write-Host "$separator" -ForegroundColor White
Write-Host "Update Summary:" -ForegroundColor White
for ($i = 0; $i -lt $totalRepos; $i++) {
    $repo = $RepositoryConfig[$i]
    Write-Host "  - $($repo.FolderPath) repository -> $latestVersion/$($repo.BranchSuffix)" -ForegroundColor $repo.DisplayColor
}
Write-Host "`nTarget Version: $latestVersion" -ForegroundColor Green
Write-Host "$separator" -ForegroundColor White

# Optional: Add a countdown before closing
Write-Host "`nScript completed successfully! Window will close in 10 seconds..." -ForegroundColor DarkYellow
for ($countdown = 10; $countdown -gt 0; $countdown--) {
    Write-Progress -Id 5 -Activity "Script Complete" -Status "Closing in $countdown seconds... (Press Ctrl+C to keep window open)" -PercentComplete ((10-$countdown)/10*100)
    Start-Sleep -Seconds 1
}
Write-Progress -Id 5 -Activity "Script Complete" -Completed

# This line is optional - if you want to automatically close the window
# exit