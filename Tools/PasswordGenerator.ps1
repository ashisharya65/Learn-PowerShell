<#
.SYNOPSIS
    This function generates ramdom passwords.
.DESCRIPTION
    Generate-Password generates a randomly generated password. 
    Password Length can be specified and it will be stored to the clipboard.
.EXAMPLE
    Generate-Password -Length 14
.NOTES
    Ashish Arya 
    Github: @AshishArya_In
#>

function New-Password {

    [CmdletBinding()]
     
    param
    (      
        [Parameter()]
        $Length = '12'
    )
    Clear-Host
    $alphabetu = [char[]](65..90)
    $alphabetl = [char[]](97..122)
    $character = '+#()%$:,?!&'.ToCharArray()
    $digits = 1..10
    
    $password = ($alphabetu, $alphabetl, $character, $digits | Get-Random -Count $Length) -join ''
    
    $null | Set-Clipboard
    $password | Set-Clipboard -Append
    
    Write-Output "Your $length charachter password`n$password"
    Write-Warning "Password saved to clipboard."
    
}