Function Invoke-FlattenArray() {
    <#
    .SYNOPSIS
    Take a nested array and return a single flattened array with all values except null.

    .DESCRIPTION
    Given an array, flatten it and keep all values execept null.

    .PARAMETER Array
    The nested array to be flatten.

    .EXAMPLE
    Invoke-FlattenArray -Array @(1, @(2, 3, $null, 4), @($null), 5)
    Return: @(1, 2, 3, 4, 5)
    #>
    [CmdletBinding()]
    Param(
        [System.Object[]]$Array
    )

    process {
        $result = @()

        foreach($item in $Array){
            if($item -is [System.Array]){
                $result += Invoke-FlattenArray -array $item
            }
            elseif(!([string]::IsNullOrEmpty($item))){
                $result += $item
            }
        }

        return $result
    }
}

Invoke-FlattenArray -Array @(1, @(2, 3, $null, 4), @($null), 5)
