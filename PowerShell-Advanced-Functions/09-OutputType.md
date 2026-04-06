# 09 — OutputType & Return Patterns

## `[OutputType()]` Attribute

Declares what **type** the function outputs. It's informational (not enforced) — helps with IntelliSense and documentation.

```powershell
function Get-ServerStatus {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName
    )

    [PSCustomObject]@{
        Computer = $ComputerName
        Status   = 'Online'
        CheckedAt = Get-Date
    }
}

# IntelliSense now knows the output has .Computer, .Status, .CheckedAt
$result = Get-ServerStatus -ComputerName "DC01"
$result.  # ← Tab completion works!
```

## OutputType Per Parameter Set

```powershell
function Get-Report {
    [CmdletBinding(DefaultParameterSetName = 'Summary')]
    [OutputType([string], ParameterSetName = 'Summary')]
    [OutputType([PSCustomObject], ParameterSetName = 'Detailed')]
    param(
        [Parameter(ParameterSetName = 'Summary')]
        [switch]$Summary,

        [Parameter(ParameterSetName = 'Detailed')]
        [switch]$Detailed
    )

    if ($Detailed) {
        [PSCustomObject]@{ Name = "Report"; Items = 42; Date = Get-Date }
    } else {
        "Report: 42 items"
    }
}
```

---

## Return Patterns

### Pattern 1: Implicit Output (Preferred)

```powershell
function Get-DiskInfo {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param([string]$ComputerName)

    # Any expression NOT assigned to a variable is output
    [PSCustomObject]@{
        Computer = $ComputerName
        FreeGB   = 125.5
    }
    # ↑ This object is automatically sent to the pipeline
}
```

### Pattern 2: Explicit Return

```powershell
function Find-User {
    [CmdletBinding()]
    param([string]$Name)

    $user = Get-ADUser -Filter "Name -eq '$Name'" -ErrorAction SilentlyContinue
    if (-not $user) {
        Write-Warning "User not found: $Name"
        return    # Exits function, outputs nothing
    }
    $user    # Implicit output
}
```

### Pattern 3: Collecting Then Outputting

```powershell
function Get-StaleAccounts {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param([int]$DaysInactive = 90)

    begin { $results = [System.Collections.Generic.List[PSObject]]::new() }

    process {
        $cutoff = (Get-Date).AddDays(-$DaysInactive)
        $users = Get-ADUser -Filter { LastLogonDate -lt $cutoff -and Enabled -eq $true } -Properties LastLogonDate

        foreach ($user in $users) {
            $results.Add([PSCustomObject]@{
                Name          = $user.Name
                SAM           = $user.SamAccountName
                LastLogon     = $user.LastLogonDate
                InactiveDays  = [math]::Round(((Get-Date) - $user.LastLogonDate).TotalDays)
            })
        }
    }

    end { $results | Sort-Object InactiveDays -Descending }
}
```

---

## Common Pitfall: Accidental Output

```powershell
# ❌ WRONG: ArrayList.Add() returns the index — pollutes output!
function Get-Names {
    [CmdletBinding()]
    param()
    $list = [System.Collections.ArrayList]::new()
    $list.Add("Alice")    # Returns 0 ← THIS GOES TO OUTPUT!
    $list.Add("Bob")      # Returns 1 ← THIS TOO!
    return $list
}
Get-Names
# Output: 0, 1, Alice, Bob   ← WRONG!

# ✅ FIX: Suppress with Out-Null or [void]
function Get-Names {
    [CmdletBinding()]
    param()
    $list = [System.Collections.ArrayList]::new()
    [void]$list.Add("Alice")           # Suppress with [void]
    $list.Add("Bob") | Out-Null        # Suppress with Out-Null
    $null = $list.Add("Charlie")       # Suppress with $null =
    return $list
}
# Or better: use Generic.List (Add returns void)
$list = [System.Collections.Generic.List[string]]::new()
$list.Add("Alice")    # Returns nothing — safe!
```

---

> **💡 Interview Tip**: In PowerShell, **every unassigned expression is output**. This is the #1 source of bugs. Always use `[void]`, `Out-Null`, or `$null =` to suppress unwanted output. Prefer `Generic.List<T>` over `ArrayList`.
