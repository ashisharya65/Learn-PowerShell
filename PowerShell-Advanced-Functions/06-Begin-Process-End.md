# 06 — Begin / Process / End Blocks

## The Three Pipeline Processing Blocks

```
Pipeline Input: Obj1 → Obj2 → Obj3
                  │       │       │
                  ▼       ▼       ▼
              ┌──────────────────────┐
              │  BEGIN  (runs once)   │  ← Setup: initialize variables, connections
              ├──────────────────────┤
              │  PROCESS (per object) │  ← Core logic: runs for EACH pipeline object
              │  PROCESS (per object) │
              │  PROCESS (per object) │
              ├──────────────────────┤
              │  END    (runs once)   │  ← Cleanup: close connections, output summary
              └──────────────────────┘
```

---

## When Each Block Runs

```powershell
function Show-Blocks {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [int]$Number
    )

    begin   { Write-Host "BEGIN: Initializing"  -ForegroundColor Green }
    process { Write-Host "PROCESS: Got $Number" -ForegroundColor Yellow }
    end     { Write-Host "END: Finishing up"     -ForegroundColor Cyan }
}

1, 2, 3 | Show-Blocks
# Output:
# BEGIN: Initializing       ← Once
# PROCESS: Got 1            ← Per object
# PROCESS: Got 2
# PROCESS: Got 3
# END: Finishing up          ← Once
```

---

## Real-World Scenario: Server Health Monitor

```powershell
function Get-ServerHealth {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$ComputerName,

        [Parameter()]
        [PSCredential]$Credential
    )

    begin {
        Write-Verbose "=== Health Check Started at $(Get-Date) ==="
        $results = [System.Collections.Generic.List[PSObject]]::new()
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    }

    process {
        Write-Verbose "Checking: $ComputerName"
        try {
            $os   = Get-CimInstance Win32_OperatingSystem -ComputerName $ComputerName -ErrorAction Stop
            $cpu  = (Get-CimInstance Win32_Processor -ComputerName $ComputerName).LoadPercentage
            $disk = Get-CimInstance Win32_LogicalDisk -ComputerName $ComputerName -Filter "DriveType=3"

            $obj = [PSCustomObject]@{
                Computer   = $ComputerName
                Status     = 'Online'
                OS         = $os.Caption
                UptimeDays = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalDays, 1)
                CPUPercent = $cpu
                DiskFreeGB = [math]::Round(($disk | Measure-Object FreeSpace -Sum).Sum / 1GB, 2)
            }
        }
        catch {
            $obj = [PSCustomObject]@{
                Computer   = $ComputerName
                Status     = 'Offline'
                OS         = 'N/A'
                UptimeDays = 0
                CPUPercent = 0
                DiskFreeGB = 0
            }
        }
        $results.Add($obj)
        $obj    # Output to pipeline immediately (streaming)
    }

    end {
        $stopwatch.Stop()
        $online  = ($results | Where-Object Status -eq 'Online').Count
        $offline = ($results | Where-Object Status -eq 'Offline').Count
        Write-Verbose "=== Completed in $($stopwatch.Elapsed.TotalSeconds)s ==="
        Write-Verbose "Online: $online | Offline: $offline | Total: $($results.Count)"
    }
}

# Usage
"DC01", "SQL01", "WEB01" | Get-ServerHealth -Verbose
```

---

## Scenario: CSV Processor with Summary

```powershell
function Import-EmployeeData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSObject]$InputObject
    )

    begin {
        $processed = 0
        $errors    = 0
        $errorList = @()
        Write-Verbose "Starting employee import..."
    }

    process {
        try {
            # Validate each record
            if ([string]::IsNullOrEmpty($InputObject.Name)) {
                throw "Name is empty for record at row $processed"
            }

            New-ADUser -Name $InputObject.Name `
                       -Department $InputObject.Department `
                       -Title $InputObject.Title `
                       -ErrorAction Stop

            $processed++
            Write-Verbose "Created: $($InputObject.Name)"
        }
        catch {
            $errors++
            $errorList += [PSCustomObject]@{
                Name  = $InputObject.Name
                Error = $_.Exception.Message
            }
            Write-Warning "Failed: $($InputObject.Name) — $($_.Exception.Message)"
        }
    }

    end {
        Write-Output ""
        Write-Output "===== IMPORT SUMMARY ====="
        Write-Output "Processed: $processed"
        Write-Output "Errors:    $errors"
        if ($errorList.Count -gt 0) {
            Write-Output "`nFailed Records:"
            $errorList | Format-Table -AutoSize
        }
    }
}

Import-Csv "employees.csv" | Import-EmployeeData -Verbose
```

---

## Without Pipeline (Direct Call)

When called directly (not via pipeline), all three blocks run once:

```powershell
# BEGIN → PROCESS (once) → END
Get-ServerHealth -ComputerName "DC01"
```

---

## Key Rules

| Rule | Detail |
|------|--------|
| No blocks specified | All code runs in **END** block |
| `process` is mandatory for pipeline | Otherwise only last object is processed |
| Output in `process` | Streams objects immediately (efficient) |
| Output in `end` | Waits until all input is processed (buffered) |
| `begin` for setup | DB connections, file handles, counters |
| `end` for cleanup | Close connections, output summaries |

---

> **💡 Interview Tip**: Explain that `begin/process/end` mirrors how compiled cmdlets work (`BeginProcessing`, `ProcessRecord`, `EndProcessing`). This is why advanced functions are "script cmdlets."
