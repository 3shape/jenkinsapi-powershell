. "$PSScriptRoot\..\Private\Get-CrumbHeader.ps1"
. "$PSScriptRoot\..\Private\Get-JenkinsRequestHeaders.ps1"
. "$PSScriptRoot\..\Private\ConvertTo-BasicAuth.ps1"

Describe 'Get-JenkinsRequestHeaders method' {

    Context 'Given a username and password' {
        It 'Creates an array of headers for making Jenkins requests' {
            Mock -CommandName Get-CrumbHeader { return "crumb=crumb" }
            $user = "Bob Bobbelhead"
            $pass = "1Password"  | ConvertTo-SecureString -AsPlainText -Force
            $headers = Get-JenkinsRequestHeaders -UserName $user -Password $pass
            $headers.Count | Should -BeExactly 2
        }
    }


}
