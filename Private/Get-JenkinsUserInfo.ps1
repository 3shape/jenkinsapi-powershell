function Get-JenkinsUserInfo {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String] $UsernameToLookup = "me",
        [String] $Username = $script:apiUsername,
        [SecureString] $Password = $script:apiPassword
    )

    if (!$script:allUserInfo) {
        $script:allUserInfo = [hashtable]::new()
    }

    if ($UsernameToLookup -eq "me" ) {
        $UsernameToLookup = $Username
    }
    if ($userInfo = $script:allUserInfo[$UsernameToLookup]) {
        return $userInfo
    } else {
        $response = Invoke-JenkinsRequest -Resource "/user/$UsernameToLookup/api/json" -Username $Username -Password $Password
        $script:allUserInfo[$UsernameToLookup] = $response.Content | ConvertFrom-Json
        return $script:allUserInfo[$UsernameToLookup]
    }
}
