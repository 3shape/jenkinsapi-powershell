#Requires -PSEdition Core -Version 6

function ConvertTo-BasicAuth {
    param (
        [String] $Username,
        [SecureString] $Password
    )

    $creds = [System.Management.Automation.PSCredential]::new($Username,$Password).GetNetworkCredential()
    $credPair = "$($creds.UserName):$($creds.Password)"
    $encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credPair))
    return $encodedCredentials
}
