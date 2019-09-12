#Requires -PSEdition Core -Version 6

function Invoke-Jenkins {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String] $Resource,
        [String] $Method = "GET",
        [Object] $Body,
        [Hashtable] $Form,
        [Hashtable] $Query = @{},
        [String] $ContentType = "application/json",
        [ValidateRange("NonNegative")]
        [Int] $MaximumRedirectionCount = 0,
        [String] $Username = $script:apiUsername,
        [SecureString] $Password = $script:apiPassword,
        [ValidateRange("NonNegative")]
        [int] $MaximumAttempts = 3,
        [bool] $TreatRedirectAsSucces = $true
    )
    $headers = Get-JenkinsRequestHeaders -Username $Username -Password $Password
    $request = [System.UriBuilder] "$($script:jenkinsUrl)/$Resource"
    $request.Query = Get-Params -Query $Query

    $attempts = 0

    Write-Debug "---- Invoke-Jenkins ----"
    Write-Debug "Resource: $Resource"
    Write-Debug "Request: $request"
    Write-Debug "Method: $Method"
    Write-Debug "Body: $Body"
    Write-Debug "Query: $Query"

    while ($attempts -lt $MaximumAttempts) {

        try {
            $attempts += 1
            if($null -ne $Form){
                $response = Invoke-WebRequest -Uri $Request.Uri `
                -Headers $headers `
                -Method $Method `
                -Form $Form `
                -UseBasicParsing `
                -TimeoutSec 30 `
                -ErrorAction SilentlyContinue `
                -MaximumRedirection $MaximumRedirectionCount
            }
            else {
                $response = Invoke-WebRequest -Uri $Request.Uri `
                -Headers $headers `
                -Method $Method `
                -Body $body `
                -ContentType $ContentType `
                -UseBasicParsing `
                -TimeoutSec 30 `
                -ErrorAction SilentlyContinue `
                -MaximumRedirection $MaximumRedirectionCount
            }
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


