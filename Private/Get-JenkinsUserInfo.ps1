function Get-JenkinsUserInfo {
    [CmdletBinding()]
    param (
        [String] $Username = $script:apiUsername,
        [SecureString] $Password = $script:apiPassword
    )

    if (!$script:AllUserInfo) {
        $script:AllUserInfo = [hashtable]::new()
    }

    if ($userInfo = $AllUserInfo[$Username]) {
        return $userInfo
    } else {
        $response = Invoke-JenkinsRequest -Resource "/user/me/api/json" -Username $Username -Password $Password
        $script:AllUserInfo[$Username] = $response.Content
        return $AlluserInfo[$Username]
    }
}
