[CmdletBinding()]
param()

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

$repoRoot = (& git rev-parse --show-toplevel).Trim()
if ($LASTEXITCODE -ne 0) {
    throw "Current directory is not inside a git repository."
}

Set-Location $repoRoot

$syncScript = Join-Path $repoRoot "tools\git_sync_research.ps1"
if (-not (Test-Path $syncScript)) {
    throw "Could not find sync script at $syncScript"
}

Invoke-Git @("config", "--local", "pull.rebase", "true")
Invoke-Git @("config", "--local", "rebase.autoStash", "true")
Invoke-Git @("config", "--local", "fetch.prune", "true")
Invoke-Git @("config", "--local", "alias.ll", "log --oneline --graph --decorate --all -20")
Invoke-Git @("config", "--local", "alias.sync-research", "!powershell -ExecutionPolicy Bypass -File tools/git_sync_research.ps1")

Write-Host ""
Write-Host "Dual-machine git settings are ready for this repository." -ForegroundColor Green
Write-Host "Alias available: git sync-research"
Write-Host "Useful log view  : git ll"
