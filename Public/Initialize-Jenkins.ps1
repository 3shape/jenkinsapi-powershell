function Initialize-Jenkins {
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

    $uri = "$JenkinsUrl//crumbIssuer/api/xml?xpath=concat(//crumbRequestField,`":`",//crumb)"
    $basicAuthCreds = ConvertTo-BasicAuth -Username $ApiUsername -Password $ApiPassword
    $headers = @{ Authorization = "Basic $basicAuthCreds" }
    $crumbHeader = Invoke-RestMethod -Uri $uri -Method "Get" -Headers $headers -UseBasicParsing
    $script:crumbrequestfield = $crumbHeader.Split(":")[0]
    $script:crumbData = $crumbHeader.Split(":")[1]
    Write-Debug "Init-Jenkins crumb-header : $($crumbHeader)"
}
