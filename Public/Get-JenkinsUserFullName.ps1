function Get-JenkinsUserFullName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $Username,
        [Parameter(Mandatory=$true)]
        [securestring] $Password
    )

    if (!$script:fullNamesByUser) {
        $script:fullNamesByUser = [hashtable]::new()
    }

    if ($fullName = $fullNamesByUser[$Username]) {
        return $fullName
    } else {
        $response = Invoke-JenkinsRequest -Resource "/user/me/api/json"
        $script:fullNamesByUser[$Username] = $response.Content.fullName
        return $fullNamesByUser[$Username]
    }
}
