[CmdletBinding()]
param(
    [string]$CommitMessage,
    [switch]$SkipPush,
    [switch]$AllowDirtyPull
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Sync-Skills {
    <#
    .SYNOPSIS
    Sync project-level skills to user-level Claude skills directory.

    .DESCRIPTION
    Copies skills from ./skills/ to ~/.claude/skills/ so Claude Code can discover them.
    This bridges the gap between git-trackable storage and actual skill discovery.
    #>

    $projectSkillsDir = Join-Path $repoRoot "skills"
    $userSkillsDir = Join-Path $env:USERPROFILE ".claude" "skills"

    if (-not (Test-Path $projectSkillsDir)) {
        Write-Host "No project skills directory found." -ForegroundColor Yellow
        return
    }

    # Ensure user skills directory exists
    if (-not (Test-Path $userSkillsDir)) {
        New-Item -ItemType Directory -Path $userSkillsDir -Force | Out-Null
        Write-Host "Created user skills directory: $userSkillsDir" -ForegroundColor Green
    }

    # Get all project skills
    $projectSkills = Get-ChildItem -Path $projectSkillsDir -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") }

    $synced = 0
    $skipped = 0

    foreach ($skillDir in $projectSkills) {
        $skillName = $skillDir.Name
        $targetDir = Join-Path $userSkillsDir $skillName

        # Check if skill exists and is identical (by comparing SKILL.md hash)
        $sourceSkillMd = Join-Path $skillDir.FullName "SKILL.md"
        $targetSkillMd = Join-Path $targetDir "SKILL.md"

        $needSync = -not (Test-Path $targetDir)

        if (-not $needSync -and (Test-Path $targetSkillMd)) {
            $sourceHash = (Get-FileHash $sourceSkillMd -Algorithm MD5).Hash
            $targetHash = (Get-FileHash $targetSkillMd -Algorithm MD5).Hash
            $needSync = $sourceHash -ne $targetHash
        }

        if ($needSync) {
            # Remove old version if exists
            if (Test-Path $targetDir) {
                Remove-Item -Path $targetDir -Recurse -Force
            }

            # Copy new version
            Copy-Item -Path $skillDir.FullName -Destination $targetDir -Recurse -Force
            Write-Host "  Synced: $skillName" -ForegroundColor Cyan
            $synced++
        } else {
            $skipped++
        }
    }

    Write-Host ""
    Write-Host "Skills sync complete: $synced updated, $skipped unchanged." -ForegroundColor Green
    Write-Host "Skills are now available in Claude Code." -ForegroundColor Green
}

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

function Try-GetGitLine {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & git @Arguments 2>$null
    if ($LASTEXITCODE -ne 0) {
        return ""
    }

    $lines = @($output)
    if ($lines.Length -eq 0) {
        return ""
    }

    return $lines[0].ToString().Trim()
}

$insideRepo = Get-GitLine @("rev-parse", "--is-inside-work-tree")
if ($insideRepo -ne "true") {
    throw "Current directory is not inside a git repository."
}

# Avoid relying on git's path output for Set-Location in non-ASCII paths.
# When this script lives in repo/tools/, the parent directory is the repo root.
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
Set-Location -LiteralPath $repoRoot

$currentBranch = Get-GitLine @("branch", "--show-current")
if ([string]::IsNullOrWhiteSpace($currentBranch)) {
    throw "Could not determine the current branch."
}

$syncRemote = "origin"
$syncRemoteBranch = "$syncRemote/$currentBranch"
$trackingBranch = Try-GetGitLine @("rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}")
$configuredRemote = Try-GetGitLine @("config", "--get", "branch.$currentBranch.remote")
$configuredMergeRef = Try-GetGitLine @("config", "--get", "branch.$currentBranch.merge")
$configuredMergeBranch = ""
if ($configuredMergeRef.StartsWith("refs/heads/")) {
    $configuredMergeBranch = $configuredMergeRef.Substring("refs/heads/".Length)
}

$statusLines = @(Get-GitOutput -Arguments @("status", "--porcelain"))
$hasLocalChanges = $statusLines.Count -gt 0

Write-Host "Repository : $repoRoot"
Write-Host "Branch     : $currentBranch"
Write-Host "Sync target: $syncRemoteBranch"
if ([string]::IsNullOrWhiteSpace($trackingBranch)) {
    Write-Host "Tracking   : (none configured)" -ForegroundColor Yellow
}
else {
    Write-Host "Tracking   : $trackingBranch"
}

if (-not [string]::IsNullOrWhiteSpace($configuredRemote) -and -not [string]::IsNullOrWhiteSpace($configuredMergeBranch)) {
    Write-Host "Configured : $configuredRemote/$configuredMergeBranch"
}

Write-Host "Has changes: $hasLocalChanges"

if (($configuredRemote -and $configuredRemote -ne $syncRemote) -or ($configuredMergeBranch -and $configuredMergeBranch -ne $currentBranch)) {
    Write-Host "Warning    : current branch tracking does not match this script's sync target ($syncRemoteBranch)." -ForegroundColor Yellow
}

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
Write-Host "Synchronized remote/branch: $syncRemoteBranch"
Write-Host "You can now continue from another computer after pulling branch '$currentBranch'."

# Sync skills to user-level directory
Write-Host ""
Write-Host "Syncing skills to user-level..." -ForegroundColor Magenta
Sync-Skills
