# 01 — CmdletBinding & Common Parameters

## What is `[CmdletBinding()]`?

`[CmdletBinding()]` transforms a basic function into an **advanced function** — giving it the same capabilities as a compiled C# cmdlet.

```powershell
# ❌ Basic Function — no common parameters, no pipeline support
function Get-Data {
    param([string]$Name)
    "Hello $Name"
}

# ✅ Advanced Function — full cmdlet behavior
function Get-Data {
    [CmdletBinding()]
    param([string]$Name)
    "Hello $Name"
}
```

## What You Get with `[CmdletBinding()]`

| Feature | Without | With |
|---------|---------|------|
| `-Verbose` | ❌ | ✅ |
| `-Debug` | ❌ | ✅ |
| `-ErrorAction` | ❌ | ✅ |
| `-ErrorVariable` | ❌ | ✅ |
| `-WarningAction` | ❌ | ✅ |
| `-WarningVariable` | ❌ | ✅ |
| `-InformationAction` | ❌ | ✅ |
| `-OutVariable` | ❌ | ✅ |
| `-OutBuffer` | ❌ | ✅ |
| `-PipelineVariable` | ❌ | ✅ |
| `$PSCmdlet` object | ❌ | ✅ |
| `$PSBoundParameters` | ❌ | ✅ |

## `[CmdletBinding()]` Properties

### 1. `SupportsShouldProcess`
Enables `-WhatIf` and `-Confirm` parameters.

```powershell
function Remove-OldLogs {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Path = "C:\Logs",
        [int]$DaysOld = 30
    )

    $files = Get-ChildItem $Path -Filter "*.log" |
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$DaysOld) }

    foreach ($file in $files) {
        if ($PSCmdlet.ShouldProcess($file.FullName, "Delete log file")) {
            Remove-Item $file.FullName
            Write-Verbose "Deleted: $($file.Name)"
        }
    }
}

# Usage
Remove-OldLogs -WhatIf           # Preview what would happen
Remove-OldLogs -Confirm          # Ask before each deletion
Remove-OldLogs -Verbose          # Show detailed output
```

### 2. `ConfirmImpact`
Controls when `-Confirm` triggers automatically.

```powershell
function Remove-AllData {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param([string]$Database)

    # Auto-prompts because ConfirmImpact = High and $ConfirmPreference = High (default)
    if ($PSCmdlet.ShouldProcess($Database, "DROP ALL TABLES")) {
        Write-Output "Dropping all tables in $Database..."
    }
}
```

| ConfirmImpact | Behavior |
|---------------|----------|
| `Low` | Never auto-confirms |
| `Medium` (default) | Confirms when `$ConfirmPreference ≤ Medium` |
| `High` | Confirms by default (recommended for destructive ops) |

### 3. `DefaultParameterSetName`
Sets the default when multiple parameter sets exist.

```powershell
function Connect-Server {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param(
        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [string]$ComputerName,

        [Parameter(ParameterSetName = 'ByIP', Mandatory)]
        [ipaddress]$IPAddress
    )
    Write-Output "Using parameter set: $($PSCmdlet.ParameterSetName)"
}
```

### 4. `SupportsPaging`
Adds `-First`, `-Skip`, `-IncludeTotalCount` parameters.

```powershell
function Get-LogEntry {
    [CmdletBinding(SupportsPaging)]
    param([string]$LogPath)

    $entries = Get-Content $LogPath
    $totalCount = $entries.Count

    if ($PSCmdlet.PagingParameters.IncludeTotalCount) {
        $PSCmdlet.PagingParameters.NewTotalCount($totalCount, 1.0)
    }

    $entries |
        Select-Object -Skip $PSCmdlet.PagingParameters.Skip |
        Select-Object -First $PSCmdlet.PagingParameters.First
}

# Usage
Get-LogEntry -LogPath "C:\app.log" -First 10 -Skip 20
```

### 5. `PositionalBinding`
Controls whether parameters can be passed by position.

```powershell
# Disable positional binding — forces named parameters
function Set-Config {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [string]$Key,
        [string]$Value
    )
    Write-Output "$Key = $Value"
}

Set-Config "Name" "Test"           # ❌ Error — positional not allowed
Set-Config -Key "Name" -Value "Test"  # ✅ Works
```

## Using Write-* Cmdlets Correctly

```powershell
function Invoke-Deployment {
    [CmdletBinding()]
    param([string]$Environment)

    Write-Verbose   "Starting deployment to $Environment"    # -Verbose to see
    Write-Debug     "Debug: Connection string loaded"        # -Debug to see
    Write-Warning   "This will restart services!"            # Always visible
    Write-Information "Deployment started at $(Get-Date)" -Tags "Audit"  # -InformationAction
    Write-Output    "Deployment Complete"                    # Pipeline output

    # ❌ AVOID Write-Host in functions — bypasses pipeline
    # Write-Host "Done" -ForegroundColor Green
}

Invoke-Deployment -Environment "Production" -Verbose -Debug
```

## Common Mistake

```powershell
# ❌ Wrong: CmdletBinding MUST be the first attribute and param MUST be first statement
function Bad-Function {
    Write-Output "something"     # ← Code before param block breaks CmdletBinding
    [CmdletBinding()]
    param()
}

# ✅ Correct
function Good-Function {
    [CmdletBinding()]
    param()
    Write-Output "something"
}
```

---

> **💡 Interview Tip**: Always mention that `[CmdletBinding()]` is what makes a function "advanced" — it provides common parameters, `$PSCmdlet` access, and makes your function behave like a native cmdlet.
