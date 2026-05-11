
Function Get-SystemInfo {
    [CmdletBinding()]
    param()

    $uptime = Get-UptimeFormatted
    
    # $PSVersionTable.OS is available in PS 6+. For PS 5.1, we query CimInstance
    $osName = if ($PSVersionTable.OS) { 
        $PSVersionTable.OS 
    } else { 
        (Get-CimInstance -ClassName Win32_OperatingSystem).Caption 
    }

    [PSCustomObject]@{ 
        ComputerName = [Environment]::MachineName
        OS           = $osName
        Uptime       = $uptime
    }
}
