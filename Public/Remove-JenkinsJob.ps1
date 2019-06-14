function Remove-JenkinsJob {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String] $Job
    )

    $response = Invoke-Jenkins -Resource "job/$Job/doDelete" -Method "POST"
    Write-Debug "Response for Remove-JenkinsJob: StatusCode : $($response.StatusCode), Headers: $($response.Headers), Content: $($response.Content)"

}
