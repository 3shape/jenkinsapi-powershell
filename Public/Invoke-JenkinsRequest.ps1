function Invoke-JenkinsRequest {
    [CmdletBinding()]
    param (
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

    Invoke-Jenkins  -Resource $Resource `
                    -Method $Method `
                    -Body $Body `
                    -Query $Query `
                    -Form $Form `
                    -ContentType $ContentType `
                    -MaximumRedirectionCount $MaximumRedirectionCount `
                    -Username $Username `
                    -Password $Password `
                    -MaximumAttempts $MaximumAttempts `
                    -TreatRedirectAsSucces $TreatRedirectAsSucces

}
