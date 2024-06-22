<#
.SYNOPSIS
    This script retrieves various system information and stores it in a custom PowerShell object.

.DESCRIPTION
    The script collects information about the computer name, operating system, CPU, architecture,
    logical disks with more than 80% free space, installed applications within a specified date range,
    IP address of a specified network adapter, and the count of hotfixes installed within a specified date range in the following format:
            
    Computer  : <Computer Name>
    OS        : <OS Name>
    CPU       : <Processor Name>
    Archi     : <Architecture [32/64 bit]>
    Memory    : <RAM Size>
    Disks     : <No. of HDDs with more than 80% free space>
    Apps      : [No. of Apps installed between May 2024 - June 2024]
    IPAddress : <1.1.1.1> [USE WMI]
    Patches   : [No. of patches installed between May 2024 - June 2024]

.EXAMPLE
    PS C:\> .\Solution.ps1

.NOTES
    Author : Ashish Arya
    Date   : 22-June-2024
#>

# Creating a custom PowerShell object with various system information
param(
    $NetworkAdapter = "MediaTek Wi-Fi 6 MT7921 Wireless LAN Card", # Parameter for specifying the network adapter name
    $startdate = "2024/05/01", # Parameter for the start date of the date range
    $enddate = "2024/07/01" # Parameter for the end date of the date range
)

[pscustomobject]@{
    # Retrieve and store the computer name
    Computername = (Get-Wmiobject -class Win32_ComputerSystem).Name
    
    # Retrieve and store the operating system name
    OS = (Get-WmiObject -class Win32_OperatingSystem).Name.Split("|")[0]
    
    # Retrieve and store the CPU name
    CPU = (Get-WmiObject -class Win32_Processor).Name
    
    # Retrieve and store the operating system architecture (32-bit or 64-bit)
    Arch = (Get-WmiObject -class Win32_OperatingSystem).OSArchitecture
    
    # Calculate and store the number of logical disks with more than 80% free space
    Memory = (Get-WmiObject -class Win32_LogicalDisk | where-Object {($_.Freespace/$_.Size)*100 -gt 80} | measure-Object).Count
    
    # Retrieve and store the count of installed applications within the specified date range
    InstalledApps = (Get-WmiObject -Class Win32_Product | ForEach-Object {
        $dateString = $_.InstallDate
        $appname = $_.Name
        # Check if InstallDate and Name are not null or empty
        if (![string]::IsNullOrWhiteSpace($dateString) -or ![string]::IsNullOrWhiteSpace($appname)) {
            try {
                # Parse the InstallDate
                $installDate = [datetime]::ParseExact($dateString, "yyyyMMdd", $null)
                # Check if the install date is within the specified date range
                if ($installDate -ge (Get-Date -date $startdate) -and $installDate -lt (Get-Date -Date $enddate)) {
                    # Return the application details as a custom object
                    [PSCustomObject]@{
                        Name = $appname
                        InstallDate = $installDate
                    }
                }
            } catch {
                # Handle the error if parsing fails
                Write-Verbose "Failed to parse date for $($app.Name) with InstallDate $dateString"
            }
        }
    }).Count
    
    # Retrieve and store the IP address of the specified network adapter, excluding IPv6 addresses
    IPadd = (Get-WmiObject Win32_NetworkAdapterConfiguration  | where-object {$_.Description -eq $NetworkAdapter}).IPAddress | 
            Where-Object {!($_.contains(":"))}
    
    # Retrieve and store the count of hotfixes installed within the specified date range
    Patches = (Get-Hotfix | Where-Object {($_.InstalledOn -ge (Get-Date -Date $startdate)) -and ($_.InstalledOn -lt (Get-Date -Date $enddate))}).Count
}
