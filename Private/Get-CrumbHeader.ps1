#Requires -PSEdition Core -Version 6

function Get-CrumbHeader {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $Username,
        [Parameter(Mandatory=$true)]
        [securestring] $Password
    )

    if (!$script:crumbsByUser) {
        $script:crumbsByUser = [hashtable]::new()
    }

    if ($crumbHeader = $crumbsByUser[$Username]) {
        return $crumbHeader
    } else {
        $uri = "$script:jenkinsUrl/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,`":`",//crumb)"
        $basicAuthCreds = ConvertTo-BasicAuth -Username $Username -Password $Password
        $requestHeaders = @{ Authorization = "Basic $basicAuthCreds" }
        $crumbHeader = Invoke-RestMethod -Uri $uri -Method "Get" -Headers $requestHeaders -UseBasicParsing
        $script:crumbsByUser[$Username] = $crumbHeader.Replace(":", "=")
        return $crumbsByUser[$Username]
    }
}
