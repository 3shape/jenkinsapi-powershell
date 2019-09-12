#Requires -PSEdition Core -Version 6

function Invoke-JenkinsForm {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String] $Resource,
        [String] $Method = "POST",
        [Hashtable] $Form,
        [Hashtable] $Query = @{},
        [Int] $MaximumRedirectionCount = 0,
        [String] $Username = $script:apiUsername,
        [SecureString] $Password = $script:apiPassword,
        [int] $MaximumAttempts = 3,
        [bool] $TreatRedirectAsSucces = $true
    )

    Invoke-Jenkins  -Resource $Resource `
                    -Method $Method `
                    -Body $Body `
                    -Form $Form `
                    -Query $Query `
                    -MaximumRedirectionCount $MaximumRedirectionCount `
                    -Username $Username `
                    -Password $Password `
                    -MaximumAttempts $MaximumAttempts `
                    -TreatRedirectAsSucces $TreatRedirectAsSucces

}
