# 11 — Proxy Functions

## What Is a Proxy Function?

A **wrapper** around an existing cmdlet that preserves ALL original functionality while adding/modifying behavior.

---

## Creating a Proxy Function

```powershell
# Step 1: Generate the proxy template
$cmdMeta = [System.Management.Automation.CommandMetadata]::new(
    (Get-Command Get-ChildItem)
)
[System.Management.Automation.ProxyCommand]::Create($cmdMeta)
# This outputs a complete function body — copy and modify
```

## Practical Example: Enhanced Get-ChildItem

```powershell
function Get-ChildItem {
    [CmdletBinding(DefaultParameterSetName='Items')]
    param(
        [string[]]$Path,
        [string]$Filter,
        [switch]$Recurse,
        # ... (all original params)

        # YOUR custom parameter
        [switch]$ShowHumanSize
    )

    begin {
        # Remove custom param before splatting to real cmdlet
        $null = $PSBoundParameters.Remove('ShowHumanSize')
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Get-ChildItem', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = { & $wrappedCmd @PSBoundParameters }
        $steppablePipeline = $scriptCmd.GetSteppablePipeline()
        $steppablePipeline.Begin($PSCmdlet)
    }

    process {
        $steppablePipeline.Process($_)
    }

    end {
        $steppablePipeline.End()
    }
}
```

## Simpler Wrapper Pattern (More Common)

```powershell
# Add default logging to Restart-Service
function Restart-ServiceWithLogging {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Name,

        [string]$ComputerName = $env:COMPUTERNAME,
        [switch]$Force
    )

    process {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Verbose "[$timestamp] Restarting $Name on $ComputerName"

        # Forward relevant params to the real cmdlet
        $params = @{ Name = $Name }
        if ($PSBoundParameters.ContainsKey('Force')) { $params['Force'] = $true }

        if ($PSCmdlet.ShouldProcess("$Name on $ComputerName", "Restart")) {
            Restart-Service @params
            "[$timestamp] SUCCESS: $Name restarted" | Add-Content "C:\Logs\service-restarts.log"
        }
    }
}
```

---

## Use Cases for Proxy Functions

| Use Case | Example |
|----------|---------|
| Add logging | Log every file deletion to audit trail |
| Add defaults | Always include `-NoTypeInformation` on `Export-Csv` |
| Add validation | Check permissions before running destructive cmdlets |
| Modify output | Add calculated properties to standard cmdlet output |
| Enforce policy | Block certain parameter values in production |

---

> **💡 Interview Tip**: Proxy functions use the **Steppable Pipeline** pattern to wrap existing cmdlets transparently. In practice, simple wrappers with `$PSBoundParameters` splatting are more common than full proxy functions.
