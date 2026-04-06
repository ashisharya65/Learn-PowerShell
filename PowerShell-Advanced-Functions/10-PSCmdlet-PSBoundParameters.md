# 10 — $PSCmdlet & $PSBoundParameters

## `$PSCmdlet` — The Function's Context Object

Available only in advanced functions (`[CmdletBinding()]`). Provides access to the cmdlet runtime.

### Key Properties & Methods

```powershell
function Show-PSCmdlet {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Default')]
    param(
        [Parameter(ParameterSetName = 'Default')]
        [string]$Name
    )

    # Properties
    $PSCmdlet.ParameterSetName       # Active parameter set name
    $PSCmdlet.MyInvocation           # How the function was called
    $PSCmdlet.SessionState           # Session state access
    $PSCmdlet.CommandRuntime         # Command runtime (output channels)

    # Methods
    $PSCmdlet.ShouldProcess()        # WhatIf/Confirm support
    $PSCmdlet.ShouldContinue()       # Extra confirmation
    $PSCmdlet.ThrowTerminatingError()  # Throw terminating error
    $PSCmdlet.WriteError()           # Write non-terminating error
    $PSCmdlet.WriteVerbose()         # Same as Write-Verbose
    $PSCmdlet.WriteWarning()         # Same as Write-Warning
    $PSCmdlet.WriteDebug()           # Same as Write-Debug
    $PSCmdlet.WriteObject()          # Write to output pipeline
}
```

### Throwing Proper Terminating Errors

```powershell
function Get-Config {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            [System.IO.FileNotFoundException]::new("Config file not found: $Path"),
            'ConfigNotFound',                                    # Error ID
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,  # Category
            $Path                                                # Target object
        )
        $PSCmdlet.ThrowTerminatingError($errorRecord)
        # ↑ Better than 'throw' — provides structured error info
    }

    Get-Content $Path | ConvertFrom-Json
}
```

---

## `$PSBoundParameters` — What Was Actually Passed

A dictionary of parameters that the user **explicitly provided**. Does NOT include defaults.

```powershell
function New-ServerConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ServerName,

        [string]$Environment = "Development",   # Has default
        [int]$Port = 8080,                       # Has default
        [switch]$EnableSSL
    )

    # Show what was ACTUALLY passed
    Write-Verbose "Bound Parameters:"
    $PSBoundParameters.GetEnumerator() | ForEach-Object {
        Write-Verbose "  $($_.Key) = $($_.Value)"
    }
}

New-ServerConfig -ServerName "WEB01" -EnableSSL -Verbose
# Bound Parameters:
#   ServerName = WEB01
#   EnableSSL = True
# Note: Environment and Port are NOT listed (defaults, not explicitly passed)
```

### Use Case 1: Parameter Passthrough (Splatting)

```powershell
function Invoke-SafeCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName,

        [PSCredential]$Credential,
        [scriptblock]$ScriptBlock
    )

    # Remove our custom params, pass the rest to Invoke-Command
    $icmParams = @{} + $PSBoundParameters
    # Or selectively pass:
    Invoke-Command @PSBoundParameters
}
```

### Use Case 2: Check If Parameter Was Provided

```powershell
function Update-UserProfile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$UserName,
        [string]$Title,
        [string]$Department,
        [string]$Phone
    )

    $updates = @{}

    # Only update fields that were EXPLICITLY provided
    if ($PSBoundParameters.ContainsKey('Title'))      { $updates['Title'] = $Title }
    if ($PSBoundParameters.ContainsKey('Department')) { $updates['Department'] = $Department }
    if ($PSBoundParameters.ContainsKey('Phone'))      { $updates['telephoneNumber'] = $Phone }

    if ($updates.Count -eq 0) {
        Write-Warning "No fields to update."
        return
    }

    Set-ADUser -Identity $UserName @updates
    Write-Verbose "Updated $($updates.Count) fields for $UserName"
}

# Only updates Title — Department and Phone untouched
Update-UserProfile -UserName "jdoe" -Title "Senior Engineer"
```

### Use Case 3: Conditional Parameter Forwarding

```powershell
function Get-RemoteData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName,

        [PSCredential]$Credential,
        [switch]$UseSSL
    )

    $sessionParams = @{
        ComputerName = $ComputerName
    }

    # Only add Credential if it was explicitly passed
    if ($PSBoundParameters.ContainsKey('Credential')) {
        $sessionParams['Credential'] = $Credential
    }
    if ($UseSSL) {
        $sessionParams['UseSSL'] = $true
        $sessionParams['Port'] = 5986
    }

    $session = New-PSSession @sessionParams
    try {
        Invoke-Command -Session $session -ScriptBlock { Get-Process }
    }
    finally {
        Remove-PSSession $session
    }
}
```

---

## `$PSBoundParameters` vs Default Values

```powershell
function Test-Binding {
    [CmdletBinding()]
    param(
        [string]$A = "default_A",
        [string]$B
    )

    Write-Output "A = '$A'"
    Write-Output "B = '$B'"
    Write-Output "PSBoundParameters: $($PSBoundParameters.Keys -join ', ')"
}

Test-Binding -A "explicit"
# A = 'explicit'
# B = ''
# PSBoundParameters: A          ← Only A, not B

Test-Binding
# A = 'default_A'
# B = ''
# PSBoundParameters:            ← EMPTY! Nothing was explicitly passed
```

---

> **💡 Interview Tip**: `$PSBoundParameters` is essential for writing wrapper/proxy functions. It lets you know exactly what the user passed vs. what has a default value. Combined with splatting (`@PSBoundParameters`), it enables clean parameter forwarding.
