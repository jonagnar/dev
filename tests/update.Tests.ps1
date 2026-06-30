# tests/update.Tests.ps1
BeforeAll {
    . "$PSScriptRoot/../scripts/update.ps1"
}

Describe "Invoke-Update" {
    BeforeEach {
        Mock Invoke-Native { }
        Mock Confirm-Action { $true }
        Mock Invoke-Verify { 0 }   # provided by verify.ps1 dot-source in update
    }
    It "does nothing under -WhatIf" {
        Invoke-Update -WhatIf
        Should -Invoke Invoke-Native -Times 0
    }
    It "pulls the repo, reconciles mise, updates scoop, applies chezmoi" {
        Invoke-Update -Yes
        Should -Invoke Invoke-Native -ParameterFilter { $File -eq 'git' -and $Arguments -contains 'pull' }
        Should -Invoke Invoke-Native -ParameterFilter { $File -eq 'mise' -and $Arguments -contains 'install' }
        Should -Invoke Invoke-Native -ParameterFilter { $File -eq 'scoop' -and $Arguments -contains 'update' }
        Should -Invoke Invoke-Native -ParameterFilter { $File -eq 'chezmoi' -and $Arguments -contains 'apply' }
    }
    It "prompts before changing tools unless -Yes" {
        Mock Confirm-Action { $false }
        Invoke-Update
        Should -Invoke Invoke-Native -ParameterFilter { $File -eq 'mise' } -Times 0
    }
    It "continues to chezmoi apply when git pull fails" {
        Mock Confirm-Action { $true }
        Mock Invoke-Verify { 0 }
        Mock Invoke-Native { }
        Mock Invoke-Native { throw "network down" } -ParameterFilter { $File -eq 'git' -and ($Arguments -contains 'pull') }
        { Invoke-Update -Yes } | Should -Not -Throw
        Should -Invoke Invoke-Native -ParameterFilter { $File -eq 'chezmoi' -and ($Arguments -contains 'apply') }
    }
}
