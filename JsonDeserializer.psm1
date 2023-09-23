using namespace System.Collections
if ($PSEdition -eq "Desktop") {
    Add-Type -AssemblyName System.Web.Extensions
    $JsonSerializer = [System.Web.Script.Serialization.JavaScriptSerializer]::new()

    function ConvertFrom-Dictionary ([IDictionary] $dict) {
        $resultHash = [ordered]@{}
        foreach ($entry in $dict.GetEnumerator()) {
            if ($entry.Value -is [array]) {
                $resultHash.Add($entry.Key, (ConvertFrom-Array $entry.Value))
            } elseif ($entry.Value -is [IDictionary]) {
                $resultHash.Add($entry.Key, (ConvertFrom-Dictionary $entry.Value))
            } else {
                $resultHash.Add($entry.Key, $entry.Value)
            }
        }
        return $resultHash
    }
    function ConvertFrom-Array ([array] $array) {
        $length = $array.Count
        $resultArray = New-Object Object[] -ArgumentList $length
        for ($index = 0; $index -lt $length; $index++) {
            $item = $array[$index]
            if ($item -is [array]) {
                $resultArray[$index] = ConvertFrom-Array $item
            } elseif ($item -is [IDictionary]) {
                $resultArray[$index] = ConvertFrom-Dictionary $item
            } else {
                $resultArray[$index] = $item
            }
        }
        return $resultArray
    }

}
function ConvertFrom-JsonAsHashTable {
    <#
        .SYNOPSIS
        Deserialize JSON string to Hashtable

        .DESCRIPTION
        Like `ConvertFrom-Json -AsHashtable` on PowerShell Core,
        deserialize JSON string to Hashtable on PowerShell Desktop(v5.1).
    #>
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Json
    )
    begin {
        $str = [System.Text.StringBuilder]::new()
    }
    process {
        $str.Append($Json) | Out-Null
    }
    end {
        if ($PSEdition -eq "Desktop") {
            $obj = $JsonSerializer.DeserializeObject($str.ToString())
            if ($obj -is [array]) {
                return ConvertFrom-Array $obj
            } elseif ($obj -is [IDictionary]) {
                return ConvertFrom-Dictionary $obj
            }
            return $obj
        }
        return $str.ToString() | ConvertFrom-Json -AsHashtable
    }
}
