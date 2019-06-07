Import-Module -Name (Get-ChildItem $PSScriptRoot\..\*.psm1 | Select-Object -first 1).FullName -Force
. "$PSScriptRoot\..\Public\Get-JenkinsUserFullName.ps1"
. "$PSScriptRoot\..\Private\Get-JenkinsUserInfo.ps1"

Describe 'Get-JenkinsUserFullName method' {

    AfterEach {
        $script:AllUserInfo = $null
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


    Context 'When a fullname is initially requested' {

        It 'Retrieves the fullname of the user' {
            $user = $UserInfo1.id
            $pass = "changeme"  | ConvertTo-SecureString -AsPlainText -Force

            Mock -CommandName Get-JenkinsUserInfo { return $UserInfo1 } -Verifiable
            $fullName = Get-JenkinsUserFullName -UserName $user -Password $pass
            $fullName | Should -BeExactly $Fullname1
        }

        It 'It is looked up, cached and re-used' {
            $user = $UserInfo2.id
            $pass = "changeme"  | ConvertTo-SecureString -AsPlainText -Force

            Mock -CommandName Get-JenkinsUserInfo { return $UserInfo2 } -Verifiable
            $fullName = Get-JenkinsUserFullName -UserName $user -Password $pass
            $fullName | Should -BeExactly $Fullname2
        }
    }

    Context 'When fullname is requested at least twice for the same user' {

        It 'Requests for fullname, then looked up from cache subsequently' {
            $user = $UserInfo1.id
            $pass = "changeme"  | ConvertTo-SecureString -AsPlainText -Force

            Mock -CommandName Invoke-JenkinsRequest { return @{Content = $UserInfo1 } } -Verifiable
            Get-JenkinsUserFullName -UserName $user -Password $pass
            Get-JenkinsUserFullName -UserName $user -Password $pass
            Assert-MockCalled -CommandName Invoke-JenkinsRequest -Exactly 1
        }
    }

    Context 'When fullname is requested at least twice but for different users' {

        It 'Requests for fullname, then looked up from cache subsequently' {
            $user1 = $UserInfo1.id
            $user2 = $UserInfo2.id
            $pass = "changeme"  | ConvertTo-SecureString -AsPlainText -Force

            Mock -CommandName Invoke-JenkinsRequest { return @{Content = $UserInfo1 } } -Verifiable
            $name1 = Get-JenkinsUserFullName -UserName $user1 -Password $pass
            Mock -CommandName Invoke-JenkinsRequest { return @{Content = $UserInfo2 } } -Verifiable
            $name2 = Get-JenkinsUserFullName -UserName $user2 -Password $pass
            $name3 = Get-JenkinsUserFullName -UserName $user2 -Password $pass

            $name1 | Should -Be $Fullname1
            $name2 | Should -Be $Fullname2
            $name3 | Should -Be $Fullname2
            Assert-MockCalled -CommandName Invoke-JenkinsRequest -Exactly 2
        }
    }

}
