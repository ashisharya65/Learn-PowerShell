# 07 — ShouldProcess & ShouldContinue

## Why ShouldProcess?

Any function that **modifies state** (deletes, creates, updates, restarts) should support `-WhatIf` and `-Confirm`.

---

## Basic ShouldProcess

```powershell
function Remove-StaleComputer {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$ComputerName
    )

    process {
        # ShouldProcess(Target, Action)
        if ($PSCmdlet.ShouldProcess($ComputerName, "Remove from Active Directory")) {
            Remove-ADComputer -Identity $ComputerName -Confirm:$false
            Write-Verbose "Removed: $ComputerName"
        }
    }
}

# Preview mode — NO changes made
Get-ADComputer -Filter { LastLogonDate -lt "2025-01-01" } |
    Select-Object -ExpandProperty Name |
    Remove-StaleComputer -WhatIf

# Output: What if: Performing the operation "Remove from Active Directory" on target "PC001".

# Confirmation mode — asks before EACH
Remove-StaleComputer -ComputerName "PC001" -Confirm
```

---

## ShouldProcess with ConfirmImpact

```powershell
function Clear-Database {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [string]$DatabaseName,

        [switch]$IncludeBackups
    )

    # Auto-prompts because ConfirmImpact = High
    if ($PSCmdlet.ShouldProcess($DatabaseName, "DELETE ALL DATA")) {
        Write-Output "Clearing database: $DatabaseName"
        if ($IncludeBackups) {
            if ($PSCmdlet.ShouldProcess("$DatabaseName backups", "DELETE ALL BACKUPS")) {
                Write-Output "Clearing backups too..."
            }
        }
    }
}

Clear-Database -DatabaseName "Production"
# Automatically prompts: Are you sure? [Y] Yes [A] Yes to All [N] No ...
```

---

## ShouldContinue — Extra Confirmation

Use `ShouldContinue` for **double-confirmation** on especially dangerous actions.

```powershell
function Remove-AllUserData {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$UserName
    )

    # First gate: ShouldProcess (respects -WhatIf and -Confirm)
    if ($PSCmdlet.ShouldProcess($UserName, "Remove all user data")) {

        # Second gate: ShouldContinue (ALWAYS prompts, ignores -Confirm)
        if ($PSCmdlet.ShouldContinue(
            "This will permanently delete ALL data for $UserName. This cannot be undone!",
            "Final Confirmation Required"
        )) {
            Write-Output "Deleting all data for $UserName..."
            # Actual deletion logic
        }
        else {
            Write-Output "Operation cancelled by user."
        }
    }
}
```

### ShouldProcess vs ShouldContinue

| Feature | ShouldProcess | ShouldContinue |
|---------|--------------|----------------|
| `-WhatIf` | ✅ Respects | ❌ Ignores |
| `-Confirm` | ✅ Respects | ❌ Always prompts |
| `$ConfirmPreference` | ✅ Respects | ❌ Ignores |
| Use case | Standard safety | Extra dangerous ops |
| Has "Yes to All" | Via -Confirm | Via `$yesToAll` ref |

---

## ShouldProcess Overloads

```powershell
# Overload 1: Target only (action = function name)
$PSCmdlet.ShouldProcess("Server01")
# Output: "Performing the operation 'Remove-StaleComputer' on target 'Server01'"

# Overload 2: Target + Action
$PSCmdlet.ShouldProcess("Server01", "Delete")
# Output: "Performing the operation 'Delete' on target 'Server01'"

# Overload 3: Verbose + WhatIf + Confirm messages (full control)
$PSCmdlet.ShouldProcess(
    "Deleting user 'jdoe' from Active Directory",    # Verbose message
    "Delete user 'jdoe'?",                           # Confirm prompt
    "User Deletion"                                   # Confirm caption
)
```

---

## Real-World: Service Restart with Safety

```powershell
function Restart-CriticalService {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$ServiceName,

        [Parameter()]
        [string]$ComputerName = $env:COMPUTERNAME,

        [Parameter()]
        [int]$TimeoutSeconds = 60
    )

    process {
        $svc = Get-Service -Name $ServiceName -ComputerName $ComputerName -ErrorAction Stop

        if ($svc.Status -ne 'Running') {
            Write-Warning "$ServiceName is not running on $ComputerName. Starting it."
            if ($PSCmdlet.ShouldProcess("$ServiceName on $ComputerName", "Start Service")) {
                Start-Service -Name $ServiceName
            }
            return
        }

        if ($PSCmdlet.ShouldProcess("$ServiceName on $ComputerName", "Restart Service")) {
            Write-Verbose "Stopping $ServiceName..."
            Stop-Service -Name $ServiceName -Force
            
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            while ((Get-Service $ServiceName).Status -ne 'Stopped') {
                if ($sw.Elapsed.TotalSeconds -gt $TimeoutSeconds) {
                    throw "Timeout waiting for $ServiceName to stop"
                }
                Start-Sleep -Milliseconds 500
            }

            Write-Verbose "Starting $ServiceName..."
            Start-Service -Name $ServiceName

            [PSCustomObject]@{
                Service     = $ServiceName
                Computer    = $ComputerName
                Status      = (Get-Service $ServiceName).Status
                RestartTime = "$([math]::Round($sw.Elapsed.TotalSeconds, 1))s"
            }
        }
    }
}

# Safe preview
"W3SVC", "WinRM" | Restart-CriticalService -WhatIf -Verbose
```

---

> **💡 Interview Tip**: Always explain the THREE-TIER safety model:
> 1. `-WhatIf` → Preview only, no changes
> 2. `-Confirm` → Ask before each action
> 3. `ConfirmImpact = 'High'` → Auto-prompt for dangerous operations
