# 02 — Parameter Declaration & Attributes

## Basic Parameter Declaration

```powershell
function Get-UserInfo {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$UserName
    )
    Get-ADUser -Identity $UserName
}
```

## Parameter Attribute Properties

### Complete `[Parameter()]` Syntax

```powershell
[Parameter(
    Mandatory = $true,
    Position = 0,
    ValueFromPipeline = $true,
    ValueFromPipelineByPropertyName = $true,
    ValueFromRemainingArguments = $true,
    HelpMessage = "Enter the server name",
    ParameterSetName = "ByName",
    DontShow = $false
)]
```

---

### 1. `Mandatory`

Forces the user to provide a value. PowerShell prompts if missing.

```powershell
function New-Employee {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]           # Short form (PS 3+)
        [string]$Name,

        [Parameter(Mandatory = $true)]   # Explicit form
        [string]$Department,

        [string]$Title = "Associate"     # Optional with default
    )
    [PSCustomObject]@{
        Name       = $Name
        Department = $Department
        Title      = $Title
    }
}

# Scenario: HR automation script
New-Employee -Name "Rahul" -Department "IT"
# Title defaults to "Associate"
```

### 2. `Position`

Allows passing parameters **without naming them**. Order matters.

```powershell
function Copy-ServerFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Source,

        [Parameter(Mandatory, Position = 1)]
        [string]$Destination,

        [Parameter()]
        [switch]$Force
    )
    Copy-Item -Path $Source -Destination $Destination -Force:$Force
}

# Both work:
Copy-ServerFile "C:\data.txt" "\\Server\Share\"        # Positional
Copy-ServerFile -Source "C:\data.txt" -Destination "\\Server\Share\"  # Named
```

### 3. `ValueFromPipeline`

Binds the **entire pipeline object** to this parameter.

```powershell
function Test-ServerConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$ComputerName
    )

    process {
        $result = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet
        [PSCustomObject]@{
            Server = $ComputerName
            Online = $result
        }
    }
}

# Scenario: Check multiple servers from pipeline
"Server01", "Server02", "DC01" | Test-ServerConnection
```

### 4. `ValueFromPipelineByPropertyName`

Binds based on **matching property name** from pipeline object.

```powershell
function Disable-InactiveUser {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$SamAccountName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$DisplayName
    )

    process {
        if ($PSCmdlet.ShouldProcess("$DisplayName ($SamAccountName)", "Disable Account")) {
            Disable-ADAccount -Identity $SamAccountName
            Write-Verbose "Disabled: $DisplayName"
        }
    }
}

# Scenario: Disable all users inactive for 90 days
$cutoff = (Get-Date).AddDays(-90)
Get-ADUser -Filter { LastLogonDate -lt $cutoff } -Properties LastLogonDate, DisplayName |
    Disable-InactiveUser -WhatIf
# SamAccountName and DisplayName bind automatically by property name!
```

### 5. `ValueFromRemainingArguments`

Captures all unbound positional arguments into one parameter.

```powershell
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet("INFO", "WARN", "ERROR")]
        [string]$Level,

        [Parameter(Mandatory, Position = 1, ValueFromRemainingArguments)]
        [string[]]$Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $msg = $Message -join " "
    "[$timestamp] [$Level] $msg"
}

# All remaining args become $Message
Write-Log INFO "Server" "started" "successfully"
# Output: [2026-04-06 09:42:51] [INFO] Server started successfully
```

### 6. `HelpMessage`

Shows hint when user is prompted for a Mandatory parameter.

```powershell
function Get-Report {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, HelpMessage = "Enter the report type (Daily, Weekly, Monthly)")]
        [string]$ReportType
    )
    "Generating $ReportType report..."
}
# When prompted, user can type !? to see the help message
```

### 7. `DontShow`

Hides the parameter from tab-completion (but still usable).

```powershell
function Get-InternalData {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Name,

        [Parameter(DontShow)]
        [switch]$IncludeDebugData    # Hidden from IntelliSense
    )
    if ($IncludeDebugData) { "Secret debug info..." }
}
```

---

## Other Parameter Attributes

### `[Alias()]`

Provide alternate names for a parameter.

```powershell
function Get-ServerInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Alias("CN", "Server", "Host", "MachineName")]
        [string]$ComputerName
    )
    Get-CimInstance Win32_OperatingSystem -ComputerName $ComputerName
}

# All of these work:
Get-ServerInfo -ComputerName "DC01"
Get-ServerInfo -CN "DC01"
Get-ServerInfo -Server "DC01"
```

### `[SupportsWildcards()]`

Documents that the parameter accepts wildcards (informational only).

```powershell
function Get-ConfigFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [SupportsWildcards()]
        [string]$Path
    )
    Get-ChildItem -Path $Path
}
Get-ConfigFile -Path "C:\Config\*.json"
```

### `[PSDefaultValue()]`

Documents the default value in help text.

```powershell
function Get-Log {
    [CmdletBinding()]
    param(
        [PSDefaultValue(Help = "Current directory")]
        [string]$Path = (Get-Location).Path
    )
    Get-ChildItem $Path -Filter "*.log"
}
```

### `[Credential()]` Transformation

Auto-prompts for password if only username is given.

```powershell
function Connect-RemoteServer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName,

        [Parameter()]
        [System.Management.Automation.Credential()]
        [PSCredential]$Credential = [PSCredential]::Empty
    )
    Enter-PSSession -ComputerName $ComputerName -Credential $Credential
}

Connect-RemoteServer -ComputerName "DC01" -Credential "DOMAIN\admin"
# ↑ Automatically prompts for password!
```

---

## Switch Parameters

```powershell
function Export-Report {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [switch]$AsCSV,
        [switch]$IncludeTimestamp,
        [switch]$Force
    )

    $data = Get-Process | Select-Object Name, CPU, WS

    if ($IncludeTimestamp) {
        $Path = $Path -replace '\.', "_$(Get-Date -Format 'yyyyMMdd')."
    }

    if ($AsCSV) {
        $data | Export-Csv $Path -NoTypeInformation -Force:$Force
    } else {
        $data | ConvertTo-Json | Set-Content $Path -Force:$Force
    }
}

Export-Report -Path "C:\report.csv" -AsCSV -IncludeTimestamp -Force
```

> **💡 Interview Tip**: Know the difference:
> - `ValueFromPipeline` → binds the **whole object** (use when param IS the object)
> - `ValueFromPipelineByPropertyName` → binds by **property match** (use when object HAS a matching property)
> - You CAN use both together for maximum flexibility
