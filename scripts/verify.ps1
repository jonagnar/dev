#requires -Version 7
<# .SYNOPSIS  Read-only health check of the dev-environment. #>
param([switch]$Help)

. "$PSScriptRoot/lib/common.ps1"

function Invoke-Verify {
    $root = Get-DevRoot
    Reset-Checks

    foreach ($tool in @('git', 'mise', 'sops', 'age', 'chezmoi')) {
        Add-Check -Name "tool: $tool" -Ok ([bool](Get-Command $tool -ErrorAction SilentlyContinue)) -Detail "not on PATH"
    }

    $keyPath = Get-AgeKeyPath
    Add-Check -Name "age key present" -Ok (Test-Path $keyPath) -Detail "$keyPath missing — run init"

    foreach ($d in @('ops', 'tools/bin', 'backups')) {
        Add-Check -Name "folder: $d" -Ok (Test-Path (Join-Path $root $d)) -Detail "missing"
    }

    # sops round-trip (only if the key exists)
    $sopsOk = $false
    if (Test-Path $keyPath) {
        try {
            $tmp = New-TemporaryFile
            "probe: ok`n" | Set-Content $tmp
            $env:SOPS_AGE_KEY_FILE = $keyPath
            $pubKey = "$( Invoke-Native -File 'age-keygen' -Arguments @('-y', $keyPath) )".Trim()
            Invoke-Native -File 'sops' -Arguments @('--encrypt', '--age', $pubKey, $tmp) | Out-Null
            $sopsOk = $true
            Remove-Item $tmp -Force -ErrorAction SilentlyContinue
        } catch { $sopsOk = $false }
    }
    Add-Check -Name "sops round-trip" -Ok $sopsOk -Detail "encrypt failed"

    $taskOk = [bool](Get-ScheduledTask -TaskName 'devenv-backup' -ErrorAction SilentlyContinue)
    Add-Check -Name "backup task registered" -Ok $taskOk -Detail "devenv-backup not found — run init"

    return (Write-CheckSummary)
}

if ($Help) { Get-Help $PSCommandPath -Detailed; return }
if ($MyInvocation.InvocationName -ne '.') { exit (Invoke-Verify) }
