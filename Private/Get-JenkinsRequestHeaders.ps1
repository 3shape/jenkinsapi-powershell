#Requires -PSEdition Core -Version 6

function Get-JenkinsRequestHeaders {
    param (
        [Parameter(Mandatory)]
        [string]
        $Username,
        [Parameter(Mandatory)]
        [securestring]
        $password
    )

    $basicAuthCreds = ConvertTo-BasicAuth   -Username $Username `
                                            -Password $password
    $crumbHeader = Get-CrumbHeader          -Username $Username `
                                            -Password $password

    $headers = @{ 'Authorization' = "Basic $basicAuthCreds" }
    $headers += ($crumbHeader | ConvertFrom-StringData)

    return $headers
}
