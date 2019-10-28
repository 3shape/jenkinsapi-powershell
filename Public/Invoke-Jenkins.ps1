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

    $req = @{
        Uri = $request.Uri
        Headers = $headers
        Method = $Method
        UseBasicParsing = $true
        TimeOutSec = 30
        ErrorAction = "SilentlyContinue"
        MaximumRedirection = $MaximumRedirectionCount
        WebSession = $script:sessionByUser[$Username]
    }
    if($null -ne $Form){
        $req.Form = $Form
    }
    else {
        $req.Body = $Body
        $req.ContentType = $ContentType
    }

    while ($attempts -lt $MaximumAttempts) {

        try {
            $attempts += 1
            $response = Invoke-WebRequest @req
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
