

Function Get-UptimeFormatted {
    if (Get-Command Get-Uptime -ErrorAction SilentlyContinue) {
        # PowerShell 6+ (Cross-platform: Windows, Linux, macOS)
        $uptime = Get-Uptime
    } else {
        # Fallback for Windows PowerShell 5.1
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $uptime = (Get-Date) - $os.LastBootUpTime
    }
    
    return "$($uptime.Days) Days, $($uptime.Hours) Hours, $($uptime.Minutes) Minutes"
}
