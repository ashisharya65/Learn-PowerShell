# 04 — Parameter Sets

## What Are Parameter Sets?

Parameter sets allow a function to have **mutually exclusive groups** of parameters — like method overloading in C#.

```
Connect-Server -ComputerName "DC01"       # Set 1: ByName
Connect-Server -IPAddress "10.0.0.5"      # Set 2: ByIP
# Cannot use -ComputerName AND -IPAddress together!
```

---

## Basic Parameter Set

```powershell
function Find-User {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$Name,

        [Parameter(Mandatory, ParameterSetName = 'ByEmail')]
        [string]$Email,

        [Parameter(Mandatory, ParameterSetName = 'ByEmployeeId')]
        [int]$EmployeeId,

        # This parameter is available in ALL sets (no ParameterSetName)
        [Parameter()]
        [switch]$IncludeDisabled
    )

    Write-Verbose "Using parameter set: $($PSCmdlet.ParameterSetName)"

    switch ($PSCmdlet.ParameterSetName) {
        'ByName'       { Get-ADUser -Filter "Name -like '*$Name*'" }
        'ByEmail'      { Get-ADUser -Filter "EmailAddress -eq '$Email'" }
        'ByEmployeeId' { Get-ADUser -Filter "EmployeeNumber -eq '$EmployeeId'" }
    }
}



# Usage — only ONE set at a time
Find-User -Name "Ashish"              # ByName set
Find-User -Email "a@corp.com"         # ByEmail set
Find-User -EmployeeId 12345           # ByEmployeeId set
Find-User -Name "Ashish" -Email "x"   # ❌ Error: ambiguous parameter set
```

---

## Parameter in Multiple Sets

A parameter can belong to **more than one** set.

```powershell
function Export-Report {
    [CmdletBinding(DefaultParameterSetName = 'Screen')]
    param(
        [Parameter(Mandatory)]
        [string]$ReportName,

        # -Path is needed for both File and Email sets, but not Screen
        [Parameter(Mandatory, ParameterSetName = 'File')]
        [Parameter(Mandatory, ParameterSetName = 'Email')]
        [string]$Path,

        [Parameter(Mandatory, ParameterSetName = 'File')]
        [ValidateSet("CSV", "JSON", "XML")]
        [string]$Format,

        [Parameter(Mandatory, ParameterSetName = 'Email')]
        [string[]]$Recipients
    )

    $data = Get-Process | Select-Object Name, CPU, WS

    switch ($PSCmdlet.ParameterSetName) {
        'Screen' {
            $data | Format-Table
        }
        'File' {
            switch ($Format) {
                'CSV'  { $data | Export-Csv $Path -NoTypeInformation }
                'JSON' { $data | ConvertTo-Json | Set-Content $Path }
                'XML'  { $data | Export-Clixml $Path }
            }
        }
        'Email' {
            $data | Export-Csv $Path -NoTypeInformation
            Send-MailMessage -To $Recipients -Attachments $Path -Subject $ReportName
        }
    }
}

# Three distinct ways to call:
Export-Report -ReportName "CPU"                               # Screen
Export-Report -ReportName "CPU" -Path ".\report.csv" -Format CSV   # File
Export-Report -ReportName "CPU" -Path ".\r.csv" -Recipients "a@b.com"  # Email
```

---

## Real-World Scenario: Multi-Mode Server Connection

```powershell
function Connect-Server {
    [CmdletBinding(DefaultParameterSetName = 'Interactive')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Interactive')]
        [Parameter(Mandatory, ParameterSetName = 'Credential')]
        [Parameter(Mandatory, ParameterSetName = 'Certificate')]
        [string]$ComputerName,

        [Parameter(ParameterSetName = 'Interactive')]
        [switch]$UseCurrentUser,

        [Parameter(Mandatory, ParameterSetName = 'Credential')]
        [PSCredential]$Credential,

        [Parameter(Mandatory, ParameterSetName = 'Certificate')]
        [string]$CertificateThumbprint,

        [Parameter()]    # Common to all sets
        [int]$Port = 5985
    )

    switch ($PSCmdlet.ParameterSetName) {
        'Interactive' {
            Write-Output "Connecting to $ComputerName as current user on port $Port"
            Enter-PSSession -ComputerName $ComputerName -Port $Port
        }
        'Credential' {
            Write-Output "Connecting to $ComputerName with explicit credentials on port $Port"
            Enter-PSSession -ComputerName $ComputerName -Credential $Credential -Port $Port
        }
        'Certificate' {
            Write-Output "Connecting to $ComputerName with certificate on port $Port"
            Enter-PSSession -ComputerName $ComputerName -CertificateThumbprint $CertificateThumbprint -Port $Port
        }
    }
}
```

---

## Detecting the Active Parameter Set

```powershell
# Inside the function, use:
$PSCmdlet.ParameterSetName    # Returns the name of the active set

# List all parameter sets of any command:
(Get-Command Find-User).ParameterSets | ForEach-Object {
    [PSCustomObject]@{
        SetName    = $_.Name
        IsDefault  = $_.IsDefault
        Parameters = ($_.Parameters | Where-Object { $_.Name -notin [System.Management.Automation.PSCmdlet]::CommonParameters }).Name -join ', '
    }
}
```

---

## Common Mistakes

```powershell
# ❌ Mistake 1: Forgetting DefaultParameterSetName
# If user provides no exclusive params, PS can't determine which set → error
function Bad-Example {
    [CmdletBinding()]  # No default! Ambiguous when no params given
    param(
        [Parameter(ParameterSetName = 'A')]
        [string]$ParamA,
        [Parameter(ParameterSetName = 'B')]
        [string]$ParamB
    )
}

# ✅ Fix: Always set DefaultParameterSetName

# ❌ Mistake 2: Making ALL parameters set-specific
# If every param is in a set, there's no "common" param → no shared behavior

# ❌ Mistake 3: Too many parameter sets
# More than 3-4 sets → function is doing too much. Consider splitting.
```

---

> **💡 Interview Tip**: Real-world example — `Get-Process` has parameter sets for getting by Name, ID, or InputObject. `Get-EventLog` has sets for List vs Log mode. Always cite native cmdlets as examples.
