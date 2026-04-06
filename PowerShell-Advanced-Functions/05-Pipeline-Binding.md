# 05 — Pipeline Binding Deep Dive

## How Pipeline Binding Works

When you pipe objects, PowerShell tries to bind them to parameters in this order:

```
1️⃣ ValueFromPipeline (ByValue) — Match by TYPE
2️⃣ ValueFromPipelineByPropertyName — Match by PROPERTY NAME
```

---

## Step-by-Step Binding Process

```
"Server01" | Get-Info
     │
     ▼
Is there a parameter with [ValueFromPipeline] that accepts [string]?
     │
    YES → Bind to that parameter
    NO  → Is there a parameter with [ValueFromPipelineByPropertyName]
          whose NAME matches a property of the incoming object?
           │
          YES → Bind by property name
          NO  → Error: Input cannot be bound
```

---

## ByValue Binding — `ValueFromPipeline`

The **entire object** is bound to the parameter.

```powershell
function Get-DiskSpace {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$ComputerName
    )

    process {
        $disk = Get-CimInstance Win32_LogicalDisk -ComputerName $ComputerName -Filter "DriveType=3"
        foreach ($d in $disk) {
            [PSCustomObject]@{
                Computer  = $ComputerName
                Drive     = $d.DeviceID
                FreeGB    = [math]::Round($d.FreeSpace / 1GB, 2)
                TotalGB   = [math]::Round($d.Size / 1GB, 2)
                PctFree   = [math]::Round(($d.FreeSpace / $d.Size) * 100, 1)
            }
        }
    }
}

# Pipeline binding — each string binds as $ComputerName
"Server01", "Server02", "DC01" | Get-DiskSpace
```

---

## ByPropertyName Binding — `ValueFromPipelineByPropertyName`

Binds by **matching property names** from the piped object.

```powershell
function Set-ServerDescription {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias("CN", "MachineName")]     # Also match these property names
        [string]$ComputerName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Description,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Location
    )

    process {
        Write-Output "Setting $ComputerName : $Description ($Location)"
    }
}

# CSV has columns: ComputerName, Description, Location
Import-Csv "servers.csv" | Set-ServerDescription
# Each CSV row's properties auto-bind to matching parameters!

# Also works with custom objects
[PSCustomObject]@{
    ComputerName = "DC01"
    Description  = "Domain Controller"
    Location     = "Mumbai"
} | Set-ServerDescription
```

---

## Combining Both Binding Types

```powershell
function Update-Server {
    [CmdletBinding()]
    param(
        # Accepts BOTH: full object via pipeline OR property name match
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$ComputerName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$UpdateGroup = "Default"
    )

    process {
        Write-Output "Updating $ComputerName (Group: $UpdateGroup)"
    }
}

# Works with strings (ByValue)
"Server01", "Server02" | Update-Server

# Works with objects (ByPropertyName)
[PSCustomObject]@{ ComputerName = "DC01"; UpdateGroup = "Priority" } | Update-Server
```

---

## Process Block is CRITICAL for Pipeline

```powershell
# ❌ WRONG: Without process block, only LAST pipeline object is processed
function Test-Wrong {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$Name
    )
    # Code here runs in END block by default
    Write-Output "Got: $Name"
}
1..5 | Test-Wrong
# Output: Got: 5   ← Only last item!

# ✅ CORRECT: Process block runs for EACH pipeline object
function Test-Right {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$Name
    )
    process {
        Write-Output "Got: $Name"
    }
}
1..5 | Test-Right
# Output: Got: 1, Got: 2, Got: 3, Got: 4, Got: 5
```

---

## Array Parameters in Pipeline

```powershell
function Restart-TargetService {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # When array comes via parameter: all at once
        # When individual strings come via pipeline: one at a time
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$ServiceName
    )

    process {
        foreach ($svc in $ServiceName) {
            if ($PSCmdlet.ShouldProcess($svc, "Restart")) {
                Restart-Service -Name $svc
                Write-Verbose "Restarted: $svc"
            }
        }
    }
}

# Via parameter — $ServiceName = @("Spooler","WinRM") in ONE call
Restart-TargetService -ServiceName "Spooler","WinRM"

# Via pipeline — process block runs TWICE ($ServiceName = "Spooler", then "WinRM")
"Spooler","WinRM" | Restart-TargetService
```

---

## `-PipelineVariable` Common Parameter

Captures pipeline objects at any stage for use downstream.

```powershell
Get-Service -PipelineVariable svc |
    Where-Object Status -eq 'Running' |
    ForEach-Object {
        [PSCustomObject]@{
            Service     = $svc.Name          # From PipelineVariable
            DisplayName = $svc.DisplayName
            Status      = $svc.Status
        }
    }
```

---

## Debugging Pipeline Binding

```powershell
# See how parameters bind
Trace-Command -Name ParameterBinding -Expression {
    "Server01" | Get-DiskSpace
} -PSHost

# Check which parameters accept pipeline
(Get-Command Get-DiskSpace).Parameters.Values |
    Where-Object { $_.Attributes.ValueFromPipeline -or $_.Attributes.ValueFromPipelineByPropertyName } |
    Select-Object Name,
        @{N='ByValue'; E={$_.Attributes.ValueFromPipeline}},
        @{N='ByPropertyName'; E={$_.Attributes.ValueFromPipelineByPropertyName}}
```

---

> **💡 Interview Tip**: The #1 mistake is forgetting the `process` block. Without it, only the **last** pipeline object is processed. Always use `begin/process/end` when your function accepts pipeline input.
