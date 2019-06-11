Import-Module -Name (Get-ChildItem $PSScriptRoot\..\*.psm1 | Select-Object -first 1).FullName -Force
. "$PSScriptRoot\..\Public\Get-JenkinsUserFullName.ps1"
. "$PSScriptRoot\..\Private\Get-JenkinsUserInfo.ps1"

Describe 'Get-JenkinsUserFullName method' {

    AfterEach {
        $script:allUserInfo = $null
    }

    $Fullname1 = "Robot"
    $UserInfo1 = @"
{
        "_class": "hudson.model.User",
        "absoluteUrl": "https://localhost/jenkins/user/nothuman",
        "description": null,
        "fullName": "$Fullname1",
        "id": "nothuman",
        "property": [
            {
                "_class": "hudson.tasks.Mailer`$UserProperty",
                "address": "nothuman@localhost"
            }
        ]
}
"@ | ConvertFrom-Json

    $Fullname2 = "praise the sun"
    $UserInfo2 = @"
{
        "_class": "hudson.model.User",
        "absoluteUrl": "https://localhost/jenkins/user/delsol",
        "description": null,
        "fullName": "$Fullname2",
        "id": "delsol",
        "property": [
            {
                "_class": "hudson.tasks.Mailer`$UserProperty",
                "address": "delsol@localhost"
            }
        ]
}
"@ | ConvertFrom-Json

    $user1 = $UserInfo1.id
    $user2 = $UserInfo2.id
    $pass = "changeme"  | ConvertTo-SecureString -AsPlainText -Force


    Context 'When a fullname is initially requested' {

        It 'Retrieves the fullname of the user' {
            Mock -CommandName Get-JenkinsUserInfo { return $UserInfo1 } -Verifiable
            $result = Get-JenkinsUserFullName -UserName $user -Password $pass
            $result | Should -BeExactly $Fullname1
            Assert-MockCalled -CommandName Get-JenkinsUserInfo -Exactly 1
        }

        It 'It is looked up, cached and re-used' {
            Mock -CommandName Get-JenkinsUserInfo { return $UserInfo2 } -Verifiable
            $result = Get-JenkinsUserFullName -UserName $user2 -Password $pass
            $result | Should -BeExactly $Fullname2
            Assert-MockCalled -CommandName Get-JenkinsUserInfo -Exactly 2
        }
    }

    Context 'When fullname is requested at least twice for the same user, against itself
        1st time from lookup, 2nd time from cache' {

        It '1st user gets own fullname returned' {
            Mock -CommandName Invoke-JenkinsRequest { return @{Content = $UserInfo1 } } -Verifiable
            $result1 = Get-JenkinsUserFullName -UserName $user1 -Password $pass
            $result2 = Get-JenkinsUserFullName -UserName $user1 -Password $pass -UsernameToLookup $user1
            $result1 | Should -BeExactly $result2
            $result2 | Should -BeExactly $Fullname1
            Assert-MockCalled -CommandName Invoke-JenkinsRequest -Exactly 1
        }

        It '2nd user gets own fullname returned' {
            Mock -CommandName Invoke-JenkinsRequest { return @{Content = $UserInfo2 } } -Verifiable
            $result1 = Get-JenkinsUserFullName -UserName $user2 -Password $pass
            $result2 = Get-JenkinsUserFullName -UserName $user2 -Password $pass -UsernameToLookup $user2
            $result1 | Should -BeExactly $result2
            $result2 | Should -BeExactly $Fullname2
            Assert-MockCalled -CommandName Invoke-JenkinsRequest -Exactly 2
        }
    }

    Context 'When fullname is requested at least twice for different users, against different users
        1st time from lookup, 2nd time from cache' {

        It '1st user looks up fullname of 2nd user' {
            Mock -CommandName Invoke-JenkinsRequest { return @{Content = $UserInfo2 } } -Verifiable
            $result2 = Get-JenkinsUserFullName -UserName $user1 -Password $pass -UsernameToLookup $user2
            $result2 | Should -BeExactly $Fullname2
            Assert-MockCalled -CommandName Invoke-JenkinsRequest -Exactly 1
        }

        It '2nd user looks up fullname of 1st user' {
            Mock -CommandName Invoke-JenkinsRequest { return @{Content = $UserInfo1 } } -Verifiable
            $result1 = Get-JenkinsUserFullName -UserName $user2 -Password $pass -UsernameToLookup $user2
            $result1 | Should -BeExactly $Fullname1
            Assert-MockCalled -CommandName Invoke-JenkinsRequest -Exactly 2
        }
    }

}
