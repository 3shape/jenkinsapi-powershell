
function Invoke-Jenkins {
    param (
        [Parameter(Mandatory=$true)]
        [String] $Resource,
        [String] $Method = "GET",
        [Object] $Body,
        [Hashtable] $Query = @{},
        [String] $ContentType = "application/json",
        [Int] $MaximumRedirectionCount = 0,
        [String] $Username = $script:apiUsername,
        [SecureString] $Password = $script:apiPassword,
        [int] $MaximumAttempts = 3,
        [bool] $TreatRedirectAsSucces = $true
    )

    if ($MaximumAttempts -lt 1) {
        throw "-MaxiumAttemps value must be greater than 0"
    }

    $basicAuthCreds = ConvertTo-BasicAuth -Username $Username -Password $Password

    $request = [System.UriBuilder] "$($env:JENKINS_VALIDATE_URL)/$Resource"
    $request.Query = Get-Params -Query $Query

    $Headers = @{
        'Authorization' = "Basic $basicAuthCreds"
        "$($crumbrequestfield)" = "$crumbData"
    }

    $attempts = 0

    while ($attempts -lt $MaximumAttempts) {

        try {
            $attempts += 1
            $response = Invoke-WebRequest -Uri $Request.Uri `
            -Headers $Headers `
            -Method $Method `
            -Body $body `
            -ContentType $ContentType `
            -UseBasicParsing `
            -TimeoutSec 30 `
            -ErrorAction SilentlyContinue `
            -MaximumRedirection $MaximumRedirectionCount
            Write-Debug "Response for Invoke-Jenkins: StatusCode : $($response.StatusCode), Headers: $($response.Headers), Content: $($response.Content)"
            return $response
        } catch [System.Net.Http.HttpRequestException] {
            $response = $_.Exception.Response
            if (!$response)
            {
                continue
            }

            $statusCode = $response.StatusCode.Value__
            Write-Debug "Response for Invoke-Jenkins: $($response)"
            if ($TreatRedirectAsSucces -eq $true -and $statusCode -ge 300 -and $statusCode -lt 400) {
                return $response
            } else {
                throw
            }
        }
    }
}


