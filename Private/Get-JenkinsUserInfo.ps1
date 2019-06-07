function Get-JenkinsUserInfo {
    [CmdletBinding()]
    param (
        [String] $Username = $script:apiUsername,
        [SecureString] $Password = $script:apiPassword,
        [String] $TargetUsername = "me"
    )

    if (!$script:AllUserInfo) {
        $script:AllUserInfo = [hashtable]::new()
    }

    if ($TargetUsername -eq "me" ) {
        $TargetUsername = $Username
    }
    if ($userInfo = $AllUserInfo[$TargetUsername]) {
        return $userInfo
    } else {
        $response = Invoke-JenkinsRequest -Resource "/user/$TargetUsername/api/json" -Username $Username -Password $Password
        $script:AllUserInfo[$TargetUsername] = $response.Content
        return $AlluserInfo[$TargetUsername]
    }
}
