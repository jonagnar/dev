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
    It "returns 0 when all checks pass (round-trip decrypts to the probe)" {
        Mock Test-Path { $true }
        Mock Get-Command { $true }
        Mock Get-ScheduledTask { @{ TaskName = 'devenv-backup' } }
        Mock Invoke-Native { }
        Mock Invoke-Native { 'age1fakeRecipient' } -ParameterFilter { $File -eq 'age-keygen' }
        Mock Invoke-Native { 'devenv-roundtrip-probe' } -ParameterFilter { $File -eq 'age' -and ($Arguments -contains '-d') }
        Invoke-Verify | Should -Be 0
    }
    It "fails the round-trip (exit 1) when decrypt returns the wrong plaintext" {
        Mock Test-Path { $true }
        Mock Get-Command { $true }
        Mock Get-ScheduledTask { @{ TaskName = 'devenv-backup' } }
        Mock Invoke-Native { }
        Mock Invoke-Native { 'age1fakeRecipient' } -ParameterFilter { $File -eq 'age-keygen' }
        Mock Invoke-Native { 'WRONG' } -ParameterFilter { $File -eq 'age' -and ($Arguments -contains '-d') }
        Invoke-Verify | Should -Be 1
    }
}
