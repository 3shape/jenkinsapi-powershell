function New-JenkinsJob {
    [CmdletBinding()]
    param (
        [String] $Folder = "",
        [Parameter(Mandatory=$true)]
        [String] $Job,
        [Parameter(Mandatory=$true)]
        [String] $jobConfigXML
    )

    if ($Folder) { $resource = "job/$Folder/" } else { $resource = "" }
    $resource = $resource + "createItem"
    Invoke-Jenkins -Resource $resource -Method "POST" -Body $jobConfigXML -Query @{name=$Job} -ContentType "application/xml"
}
