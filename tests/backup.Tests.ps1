# tests/backup.Tests.ps1
BeforeAll {
    . "$PSScriptRoot/../scripts/backup.ps1"
}

Describe "Invoke-Backup" {
    BeforeEach {
        Mock Invoke-Native { }
        Mock Get-DevRepos { @("$TestDrive/meta", "$TestDrive/ops/demo-api") }
        Mock Test-Path { $true }
    }
    It "does nothing destructive under -WhatIf" {
        Invoke-Backup -WhatIf
        Should -Invoke Invoke-Native -Times 0
    }
    It "bundles each repo and age-encrypts the archive" {
        Invoke-Backup -Yes
        Should -Invoke Invoke-Native -ParameterFilter { $File -eq 'git' -and $Arguments -contains 'bundle' }
        Should -Invoke Invoke-Native -ParameterFilter { $File -eq 'age' }
    }
}
