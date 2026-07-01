# tests/init.Tests.ps1
BeforeAll {
    . "$PSScriptRoot/../scripts/init.ps1"
}

Describe "Invoke-Init" {
    BeforeEach {
        Mock Invoke-Native { }                       # never touch the system
        Mock Test-HasCommand { $true }               # pretend scoop/git present
        Mock Install-Scoop { }                        # never actually bootstrap scoop
        Mock Get-WslDistro { "Ubuntu" }
        Mock New-DevAgeKey { }                        # secrets phase (defined in init.ps1)
        Mock Register-BackupTask { }
        Mock Invoke-Verify { 0 }                      # Phase 6 (from dot-sourced verify.ps1)
        Mock Test-Path { $true }                      # pretend key/tools exist
    }

    It "runs no native commands under -WhatIf" {
        Invoke-Init -WhatIf
        Should -Invoke Invoke-Native -Times 0
    }

    It "installs scoop essentials then mise-installs the core" {
        Invoke-Init -Yes
        Should -Invoke Invoke-Native -ParameterFilter { $File -eq 'scoop' -and $Arguments -contains 'git' }
        Should -Invoke Invoke-Native -ParameterFilter { $File -eq 'mise' -and $Arguments -contains 'install' }
    }

    It "bootstraps scoop when it is missing" {
        Mock Test-HasCommand { $false } -ParameterFilter { $Name -eq 'scoop' }
        Invoke-Init -Yes
        Should -Invoke Install-Scoop -Times 1
    }

    It "does NOT bootstrap scoop when it is already present" {
        Mock Test-HasCommand { $true } -ParameterFilter { $Name -eq 'scoop' }
        Invoke-Init -Yes
        Should -Invoke Install-Scoop -Times 0
    }

    It "does not require administrator (scoop refuses to run elevated)" {
        { Invoke-Init -Yes } | Should -Not -Throw
    }
}
