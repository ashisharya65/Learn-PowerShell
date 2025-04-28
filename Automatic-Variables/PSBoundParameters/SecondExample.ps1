
function Get-MyInfo {
    [CmdletBinding()]
    param(
        [string] $Name,
        [int]    $Age
    )

    switch ($true) {
        { $PSBoundParameters.Count -eq 0 } {
            Write-Host "No parameters were passed."
            break
        }
        { $PSBoundParameters.Count -eq 2 } {
            Write-Host "Both parameters were passed."
            break
        }
        { $PSBoundParameters.ContainsKey('Name') } {
            Write-Host "Name parameter was passed."
            break
        }
        { $PSBoundParameters.ContainsKey('Age') } {
            Write-Host "Age parameter was passed."
            break
        }
    }
}

# Tests
Get-MyInfo
Get-MyInfo -Name "Jack"
Get-MyInfo -Age 25
Get-MyInfo -Name "Jack" -Age 25

<# OUTPUT
  No parameters were passed.
  Name parameter was passed.
  Age parameter was passed.
  Both parameters were passed.
#>
