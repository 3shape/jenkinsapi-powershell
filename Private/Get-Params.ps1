function Get-Params
{
    param (
        [hashtable] $Query
    )

    $Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    foreach ($Item in $query.GetEnumerator()) {
        if ($Item.Value.Count -gt 1) {
            foreach ($Value in $Item.Value) {
                $ParameterName = $Item.Key
                $Parameters.Add($ParameterName, $Value)
            }
        } else {
            $Parameters.Add($Item.Key,$Item.Value)
        }
    }

    return $Parameters.ToString()
}
