. "$PSScriptRoot\..\Private\Get-CrumbHeader.ps1"
. "$PSScriptRoot\..\Private\ConvertTo-BasicAuth.ps1"

Describe 'Get-CrumbHeader method' {

    AfterEach {
        $script:crumbsByUser = $null
    }

    Context 'When a crumb-header is initially requested' {

        It 'It is looked up, cached and re-used' {
            Mock -CommandName Invoke-RestMethod { return "requestfield:headerdata" } -Verifiable
            $user = "Bob Bobbels"
            $pass = "test" | ConvertTo-SecureString -AsPlainText -Force

            $crumbHeader = Get-CrumbHeader -UserName $user -Password $pass
            Assert-MockCalled -CommandName Invoke-RestMethod -Exactly 1
            $crumbHeader | Should -BeExactly "requestfield=headerdata"            
        }
    }

    Context 'When a crumb-header is returned' {

        It 'It transforms the returned header to a format appropriate for arrays' {
            Mock -CommandName Invoke-RestMethod { return "requestfield:headerdata" } -Verifiable
            $user = "Bob Bobbels"
            $pass = "test" | ConvertTo-SecureString -AsPlainText -Force

            $crumbHeader = Get-CrumbHeader -UserName $user -Password $pass
            $emptyArray = @{}
            $arrayWithCrumbHeader = $emptyArray + ($crumbHeader | ConvertFrom-StringData)
            $crumbHeader | Should -BeExactly "requestfield=headerdata"
            $arrayWithCrumbHeader.Count | Should -BeExactly 1
        }
    }

    Context 'When a crumb is requested at least twice but for different users' {

        It 'It is looked up and returned' {
            Mock -CommandName Invoke-RestMethod { return "requestfield:headerdata" } -Verifiable
            $userBob = "Bob Bobbels"
            $userDavid = "David Davidson"
            $pass = "test" | ConvertTo-SecureString -AsPlainText -Force
            Get-CrumbHeader -UserName $userBob -Password $pass
            Get-CrumbHeader -UserName $userDavid -Password $pass

            Assert-MockCalled -CommandName Invoke-RestMethod -Exactly 2
        }
    }

}
