#requires -Version 7
<# .SYNOPSIS  Produce an age-encrypted snapshot of all repos into backups/. #>
param([switch]$WhatIf, [switch]$Yes, [string]$BackupDir, [switch]$Help)

. "$PSScriptRoot/lib/common.ps1"

function Get-DevRepos {
    param([string]$Root)
    $repos = @()
    if (Test-Path (Join-Path $Root '.git')) { $repos += $Root }
    $opsDir = Join-Path $Root 'ops'
    if (Test-Path $opsDir) {
        Get-ChildItem $opsDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            if (Test-Path (Join-Path $_.FullName '.git')) { $repos += $_.FullName }
        }
    }
    return $repos
}

function Invoke-Backup {
    param([switch]$WhatIf, [switch]$Yes, [string]$BackupDir)
    $script:DryRun = [bool]$WhatIf
    $script:AssumeYes = [bool]$Yes
    $root = Get-DevRoot
    if (-not $BackupDir) { $BackupDir = Join-Path $root 'backups' }

    $stamp = (Get-Date -Format 'yyyyMMdd-HHmmss')
    $staging = Join-Path ([IO.Path]::GetTempPath()) "devbackup-$stamp"
    $tar = Join-Path $BackupDir "dev-backup-$stamp.tar"
    $enc = "$tar.age"
    $keyPath = Get-AgeKeyPath

    Write-Phase "Backup -> $enc"
    Invoke-Step -Name "bundle repos" -Action {
        New-Item -ItemType Directory -Force -Path $staging | Out-Null
        foreach ($repo in (Get-DevRepos -Root $root)) {
            $name = Split-Path $repo -Leaf
            Invoke-Native -File 'git' -Arguments @('-C', $repo, 'bundle', 'create', (Join-Path $staging "$name.bundle"), '--all')
        }
    }
    Invoke-Step -Name "tar staging" -Action {
        if (-not (Test-Path $BackupDir)) { New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null }
        Invoke-Native -File 'tar' -Arguments @('-cf', $tar, '-C', $staging, '.')
    }
    Invoke-Step -Name "age-encrypt + clean up" -Action {
        $pub = "$( Invoke-Native -File 'age-keygen' -Arguments @('-y', $keyPath) )".Trim()
        Invoke-Native -File 'age' -Arguments @('-r', $pub, '-o', $enc, $tar)
        Remove-Item $tar -Force -ErrorAction SilentlyContinue
        Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Info "Backup written: $enc"
}

if ($Help) { Get-Help $PSCommandPath -Detailed; return }
if ($MyInvocation.InvocationName -ne '.') { Invoke-Backup -WhatIf:$WhatIf -Yes:$Yes -BackupDir:$BackupDir }
