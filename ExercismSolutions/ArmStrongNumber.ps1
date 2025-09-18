Function Invoke-ArmstrongNumbers {
    <#
    .SYNOPSIS
    Determine if a number is an Armstrong number.

    .DESCRIPTION
    An Armstrong number is a number that is the sum of its own digits each raised to the power of the number of digits.

    .PARAMETER Number
    The number to check.

    .EXAMPLE
    Invoke-ArmstrongNumbers -Number 153
    This should result in True as 1^3 + 5^3 + 3^3 = 3 + 125 + 27 = 153
    #>
    [CmdletBinding()]
    Param(
        [Int64]$Number
    )

    $digits = [int64[]]($Number.ToString().ToCharArray() | ForEach-Object { [int64]::Parse($_) })
    $length = $digits.Length
    
    $Sum = 0
    foreach ($digit in $digits) {
        $sum += $([Math]::Pow($digit, $length))
    }

    return ($sum -eq $Number)
}
