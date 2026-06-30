# tests/verify.Tests.ps1
BeforeAll {
    . "$PSScriptRoot/../scripts/verify.ps1"
}

Describe "Invoke-Verify" {
    It "reports a failed check (exit 1) when the age key is missing" {
        Mock Test-Path { $false } -ParameterFilter { $Path -like "*keys.txt" }
        Mock Test-Path { $true }
        Mock Invoke-Native { }
        Mock Get-Command { $true }
        Invoke-Verify | Should -Be 1
    }
    It "returns 0 when all checks pass" {
        Mock Test-Path { $true }
        Mock Invoke-Native { }
        Mock Get-Command { $true }
        Mock Get-ScheduledTask { @{ TaskName = 'devenv-backup' } }
        Invoke-Verify | Should -Be 0
    }
}
