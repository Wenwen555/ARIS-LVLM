[CmdletBinding()]
param(
    [string]$CommitMessage,
    [switch]$SkipPush,
    [switch]$AllowDirtyPull
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    Write-Host ("> git " + ($Arguments -join " ")) -ForegroundColor Cyan
    & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }
}

function Get-GitOutput {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }

    return @($output)
}

function Get-GitLine {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = @(Get-GitOutput -Arguments $Arguments)
    if ($output.Length -eq 0) {
        return ""
    }

    return $output[0].ToString().Trim()
}

$insideRepo = Get-GitLine @("rev-parse", "--is-inside-work-tree")
if ($insideRepo -ne "true") {
    throw "Current directory is not inside a git repository."
}

$repoRoot = Get-GitLine @("rev-parse", "--show-toplevel")
Set-Location $repoRoot

$currentBranch = Get-GitLine @("branch", "--show-current")
if ([string]::IsNullOrWhiteSpace($currentBranch)) {
    throw "Could not determine the current branch."
}

$statusLines = @(Get-GitOutput -Arguments @("status", "--porcelain"))
$hasLocalChanges = $statusLines.Count -gt 0

Write-Host "Repository : $repoRoot"
Write-Host "Branch     : $currentBranch"
Write-Host "Has changes: $hasLocalChanges"

if ($CommitMessage) {
    if (-not $hasLocalChanges) {
        Write-Host "No local changes to commit." -ForegroundColor Yellow
    }
    else {
        Invoke-Git @("add", "-A")
        Invoke-Git @("commit", "-m", $CommitMessage)
        $statusLines = @()
        $hasLocalChanges = $false
    }
}

if ($hasLocalChanges -and -not $AllowDirtyPull) {
    Write-Host "Working tree is dirty. Commit or stash changes before syncing." -ForegroundColor Yellow
    Write-Host "Tip: run this script with -CommitMessage `"your message`" to save and sync in one step." -ForegroundColor Yellow
    exit 1
}

Invoke-Git @("fetch", "origin", $currentBranch)

if (-not $hasLocalChanges) {
    Invoke-Git @("pull", "--rebase", "origin", $currentBranch)
}
else {
    Write-Host "Skipping pull because the working tree has local changes." -ForegroundColor Yellow
}

if (-not $SkipPush) {
    Invoke-Git @("push", "origin", $currentBranch)
}

Write-Host ""
Write-Host "Sync complete." -ForegroundColor Green
Write-Host "You can now continue from another computer after pulling branch '$currentBranch'."
