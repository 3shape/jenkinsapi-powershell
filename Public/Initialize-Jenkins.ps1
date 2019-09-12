#Requires -PSEdition Core -Version 6

function Initialize-Jenkins {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String] $JenkinsUrl,
        [Parameter(Mandatory=$true)]
        [String] $ApiUsername,
        [Parameter(Mandatory=$true)]
        [SecureString] $ApiPassword
    )

    $script:jenkinsUrl = $JenkinsUrl
    $script:apiUsername = $ApiUsername
    $script:apiPassword = $ApiPassword
}
