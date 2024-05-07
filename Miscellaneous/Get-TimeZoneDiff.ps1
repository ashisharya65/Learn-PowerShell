
<#
    .Synopsis
    Getting the Timezone differences. 
    
    .Description
    PowerShell script to determine the timezone difference between the local timezone and the remote location timezones.
    This script is developed by the Microsoft MVP Ravikant Chaganti and mentioned in his blog mentioned below :
    
    https://ravichaganti.com/blog/2023-03-20-determining-time-zone-differences-in-powershell-for-effective-meeting-planning/
    
    .Notes
    Author : Ravikant Chaganti
    Date   : 24-March-2023

#>

Function Get-TimeZoneDiff {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [String[]] $Timezone,

        [Parameter()]
        [Datetime] $Target
    )

    if (!$Target){
        # Get the local time as the target
        $Target = Get-Date
    }

    $tzObject = [System.Collections.Arraylist]::new()
    $tzObject.Add(
        [PSCustomObject]@{
            'Timezone' = 'Local'
            'Time' = $Target
            'DifferenceInHours' = 0
        }
    ) | Out-Null

    foreach ($tz in $Timezone) {

        # Get the timezone difference
        $localTz = [System.TimeZoneInfo]::Local
        $remoteTz = [System.TimeZoneInfo]::FindSystemTimeZoneById($tz)
        $tzDifference = [float]($remoteTz.BaseUtcOffset.TotalHours - $localTz.BaseUtcOffset.TotalHours)
        $remoteTime = [System.TimeZoneInfo]::ConvertTime($Target, $localTz, $remoteTz)
        $tzObject.Add(
            [PSCustomObject]@{
                'Timezone' = $tz
                'Time' = $remoteTime
                'DifferenceInHours' = $tzDifference
            }
        ) | Out-Null
    }

    return $tzObject
}

Get-TimeZoneDiff 

