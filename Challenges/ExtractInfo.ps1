
<#

.SYNOPSIS 
PowerShell script to generate a report that shows the count of email addresses by domain.

.DESCRIPTION
You have a text file containing information about individuals, including their country and email addresses. Each line in the text file contains data in the below format: 

    Johnetta,Abdallah,Orange,USA,NC,johnetta_abdallah@aol.com
    Louvenia,Abney,SK,Canada,S6V 6A4,louvenia_abney@hotmail.com
    
The goal is to process this file and generate a report that shows the count of email addresses by domain (Gmail, Hotmail, Yahoo, Others) for specific countries (UK, USA, Canada).

    Country Gmail Hotmail Yahoo Others
    ------- ----- ------- ----- ------
    Canada     63      60    57    302
    UK        122     105   116    130
    USA        66      70    84    267

.PARAMETER FilePath
The path to the text file containing the input data.

.OUTPUTS
Displays a formatted table with the count of email addresses by domain for each specified country.

.EXAMPLE
.\ExtractInfo.ps1

.NOTES
    Author : Ashish Arya
    Date   : 09-July-2024

#>

param(
    $Filepath = "$($PSScriptRoot)\InputFile.txt"
)

Get-Content -path $Filepath | ForEach-Object {
    $line = $_
    [pscustomobject]@{
        Country = $line.ToString().split(",")[3]
        domain  = $line.ToString().split(",")[5].split("@")[1].split(".")[0]
    } 
} | Where-Object { $_.Country -in @("USA", "UK", "Canada") } | Group-Object Country | ForEach-Object {

    $Country, $Others = $_.Name, 0
    $_.Group | Group-Object Domain | ForEach-Object {
        if ($_.Name -eq "Gmail") {
            $Gmail = $_.Count
        }
        elseif ($_.Name -eq "Hotmail") {
            $Hotmail = $_.Count
        }
        elseif ($_.Name -eq "Yahoo") {
            $Yahoo = $_.Count
        }
        else {
            $Others += $_.Count
        }
    }

    [pscustomobject]@{
        Country = $_.Name
        Gmail   = $Gmail
        Hotmail = $Hotmail
        Yahoo   = $Yahoo
        Others  = $Others
    }

} | Format-Table -AutoSize

