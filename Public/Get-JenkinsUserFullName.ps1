. "$PSScriptRoot\..\Private\Get-JenkinsUserInfo.ps1"

function Get-JenkinsUserFullName {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String] $UsernameToLookup = "me",
        [String] $Username = $script:apiUsername,
        [SecureString] $Password = $script:apiPassword
    )

    $userInfo = Get-JenkinsUserInfo -Username $Username -Password $Password -UsernameToLookup $UsernameToLookup
    $fullName = if ($null -ne $userInfo) { $userInfo.fullName } else { $null }
    return $fullName
}
