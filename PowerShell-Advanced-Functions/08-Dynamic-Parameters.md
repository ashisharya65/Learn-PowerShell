# 08 — Dynamic Parameters

## What Are Dynamic Parameters?

Parameters that are **created at runtime** based on conditions — they only appear when specific criteria are met.

---

## Basic Dynamic Parameter

```powershell
function Get-Data {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("File", "Database", "API")]
        [string]$Source
    )

    dynamicparam {
        $paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

        # Only show -FilePath when Source is "File"
        if ($Source -eq 'File') {
            $attr = [System.Management.Automation.ParameterAttribute]@{
                Mandatory = $true
                HelpMessage = "Path to the data file"
            }
            $validateAttr = [System.Management.Automation.ValidateScriptAttribute]::new({
                Test-Path $_
            })
            $attrCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
            $attrCollection.Add($attr)
            $attrCollection.Add($validateAttr)

            $param = [System.Management.Automation.RuntimeDefinedParameter]::new(
                'FilePath', [string], $attrCollection
            )
            $paramDictionary.Add('FilePath', $param)
        }

        # Only show -ConnectionString when Source is "Database"
        if ($Source -eq 'Database') {
            $attr = [System.Management.Automation.ParameterAttribute]@{ Mandatory = $true }
            $attrCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
            $attrCollection.Add($attr)

            $param = [System.Management.Automation.RuntimeDefinedParameter]::new(
                'ConnectionString', [string], $attrCollection
            )
            $paramDictionary.Add('ConnectionString', $param)
        }

        # Only show -Endpoint when Source is "API"
        if ($Source -eq 'API') {
            $attr = [System.Management.Automation.ParameterAttribute]@{ Mandatory = $true }
            $attrCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
            $attrCollection.Add($attr)

            $param = [System.Management.Automation.RuntimeDefinedParameter]::new(
                'Endpoint', [uri], $attrCollection
            )
            $paramDictionary.Add('Endpoint', $param)
        }

        return $paramDictionary
    }

    process {
        # Access dynamic params via $PSBoundParameters
        switch ($Source) {
            'File'     { Get-Content $PSBoundParameters['FilePath'] }
            'Database' { Write-Output "Connecting: $($PSBoundParameters['ConnectionString'])" }
            'API'      { Invoke-RestMethod -Uri $PSBoundParameters['Endpoint'] }
        }
    }
}

# Tab-completion shows different params based on -Source!
Get-Data -Source File -FilePath "C:\data.csv"
Get-Data -Source Database -ConnectionString "Server=SQL01;DB=MyDB"
Get-Data -Source API -Endpoint "https://api.example.com/data"
```

---

## Helper Function (Cleaner Syntax)

```powershell
function New-DynamicParam {
    param(
        [string]$Name,
        [type]$Type = [string],
        [bool]$Mandatory = $false,
        [string[]]$ValidateSet,
        [System.Management.Automation.RuntimeDefinedParameterDictionary]$Dictionary
    )

    $attr = [System.Management.Automation.ParameterAttribute]@{ Mandatory = $Mandatory }
    $attrCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
    $attrCollection.Add($attr)

    if ($ValidateSet) {
        $setAttr = [System.Management.Automation.ValidateSetAttribute]::new($ValidateSet)
        $attrCollection.Add($setAttr)
    }

    $param = [System.Management.Automation.RuntimeDefinedParameter]::new($Name, $Type, $attrCollection)
    $Dictionary.Add($Name, $param)
}

# Usage in a function:
function Deploy-App {
    [CmdletBinding()]
    param(
        [ValidateSet("Windows", "Linux")]
        [string]$Platform = "Windows"
    )

    dynamicparam {
        $dict = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

        if ($Platform -eq 'Windows') {
            New-DynamicParam -Name 'IISSite' -Mandatory $true -Dictionary $dict
            New-DynamicParam -Name 'AppPool' -Mandatory $true -Dictionary $dict
        }
        if ($Platform -eq 'Linux') {
            New-DynamicParam -Name 'ServiceUnit' -Mandatory $true -Dictionary $dict
            New-DynamicParam -Name 'NginxConfig' -Dictionary $dict
        }

        return $dict
    }

    process {
        Write-Output "Deploying on $Platform with params: $($PSBoundParameters | Out-String)"
    }
}
```

---

## When to Use Dynamic Parameters

| Use Case | Example |
|----------|---------|
| Context-dependent params | Different options for File vs DB source |
| Provider-aware functions | Different params for Registry vs FileSystem |
| Feature flags | Show advanced params only with `-Advanced` switch |
| Environment-based | Load param options from config at runtime |

## When NOT to Use

- When `[ValidateSet()]` is sufficient
- For simple conditional logic (use parameter sets instead)
- When it makes the function hard to understand

---

> **💡 Interview Tip**: Dynamic parameters are powerful but **complex**. In interviews, mention you know they exist and cite `Get-ChildItem` as an example (`-File`, `-Directory` only appear for FileSystem provider). Recommend **parameter sets** for simpler scenarios.
