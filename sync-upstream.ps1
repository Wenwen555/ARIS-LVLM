[CmdletBinding()]
param(
    [switch]$AllowDirty
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Fail {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    throw "sync-upstream.ps1: $Message"
}

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [string]$ErrorMessage = ''
    )

    Write-Host ("> git " + ($Arguments -join ' ')) -ForegroundColor Cyan
    & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        if ([string]::IsNullOrWhiteSpace($ErrorMessage)) {
            Fail("git $($Arguments -join ' ') failed with exit code $LASTEXITCODE.")
        }

        Fail($ErrorMessage)
    }
}

function Get-GitLine {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & git @Arguments 2>$null
    if ($LASTEXITCODE -ne 0) {
        return ''
    }

    if ($null -eq $output) {
        return ''
    }

    return (@($output)[0].ToString().Trim())
}

function Get-GitLines {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & git @Arguments 2>$null
    if ($LASTEXITCODE -ne 0) {
        return @()
    }

    return @($output | ForEach-Object { $_.ToString().Trim() } | Where-Object { $_ })
}

function Ensure-Remote {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $remoteUrl = Get-GitLine @('remote', 'get-url', $Name)
    if ([string]::IsNullOrWhiteSpace($remoteUrl)) {
        Fail("remote '$Name' is not configured.")
    }
}

function Restore-LocalReadmes {
    $args = @('restore', '--source=HEAD', '--staged', '--worktree', '--', 'README.md', 'README_CN.md')
    Invoke-Git -Arguments $args -ErrorMessage 'restoring local README files failed.'
}

$repoRoot = Get-GitLine @('rev-parse', '--show-toplevel')
if ([string]::IsNullOrWhiteSpace($repoRoot)) {
    Fail('current directory is not inside a git repository.')
}

$originalLocation = Get-Location
try {
    Set-Location -LiteralPath $repoRoot

    Ensure-Remote -Name 'origin'
    Ensure-Remote -Name 'upstream'

    $currentBranch = Get-GitLine @('branch', '--show-current')
    if ([string]::IsNullOrWhiteSpace($currentBranch)) {
        Fail('could not determine the current branch.')
    }

    $statusLines = @(Get-GitLines @('status', '--porcelain'))
    if (-not $AllowDirty -and $statusLines.Count -gt 0) {
        Fail('working tree is dirty; stash or commit changes first, or rerun with -AllowDirty.')
    }

    Invoke-Git -Arguments @('fetch', 'upstream') -ErrorMessage 'git fetch upstream failed.'

    if ($currentBranch -ne 'main') {
        Write-Host "Switching from '$currentBranch' to 'main'..." -ForegroundColor Yellow
        Invoke-Git -Arguments @('checkout', 'main') -ErrorMessage 'git checkout main failed.'
    }

    $mergeHeadPath = Join-Path $repoRoot '.git\MERGE_HEAD'

    Write-Host 'Merging upstream/main while preserving local README.md and README_CN.md...' -ForegroundColor Yellow
    & git merge --no-commit --no-ff upstream/main
    $mergeExitCode = $LASTEXITCODE
    $mergeInProgress = Test-Path -LiteralPath $mergeHeadPath

    if ($mergeInProgress) {
        Restore-LocalReadmes

        $unmergedPaths = @(Get-GitLines @('diff', '--name-only', '--diff-filter=U'))
        if ($unmergedPaths.Count -gt 0) {
            Write-Host 'Unresolved merge conflicts remain:' -ForegroundColor Red
            $unmergedPaths | ForEach-Object {
                Write-Host ("  " + $_) -ForegroundColor Red
            }

            Fail("merge requires manual conflict resolution. Review the files above, then continue or run 'git merge --abort'.")
        }

        if ($mergeExitCode -ne 0) {
            Write-Host 'Merge reported conflicts, but README files were restored successfully. Continuing with the merge commit.' -ForegroundColor Yellow
        }

        Invoke-Git -Arguments @('commit', '-m', 'Merge upstream/main and keep local README files') -ErrorMessage 'git commit failed after merge.'
    }
    elseif ($mergeExitCode -ne 0) {
        Fail("git merge upstream/main failed before a merge state was created. Inspect 'git status' and retry.")
    }
    else {
        Write-Host 'upstream/main is already merged into local main; nothing to commit.' -ForegroundColor Green
    }

    Invoke-Git -Arguments @('push', 'origin', 'main') -ErrorMessage 'git push origin main failed.'
    Write-Host 'Sync complete.' -ForegroundColor Green
}
finally {
    Set-Location -LiteralPath $originalLocation
}
