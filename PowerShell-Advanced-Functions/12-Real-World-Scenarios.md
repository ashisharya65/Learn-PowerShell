# 12 — Real-World Scenarios (Production-Grade Examples)

## Scenario 1: User Onboarding Automation

```powershell
function New-EmployeeOnboarding {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(2, 50)]
        [string]$FullName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet("IT", "HR", "Finance", "Sales", "Engineering")]
        [string]$Department,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidatePattern('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            ErrorMessage = "Invalid email format")]
        [string]$Email,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({
            if ($_ -lt (Get-Date)) { throw "Start date must be in the future" }
            $true
        })]
        [datetime]$StartDate = (Get-Date).AddDays(1),

        [Parameter()]
        [ValidateSet("Standard", "Developer", "Manager", "Executive")]
        [string]$LicenseType = "Standard",

        [Parameter()]
        [PSCredential]$AdminCredential
    )

    begin {
        $results = [System.Collections.Generic.List[PSObject]]::new()
        $departmentOUs = @{
            IT          = "OU=IT,OU=Users,DC=corp,DC=com"
            HR          = "OU=HR,OU=Users,DC=corp,DC=com"
            Finance     = "OU=Finance,OU=Users,DC=corp,DC=com"
            Sales       = "OU=Sales,OU=Users,DC=corp,DC=com"
            Engineering = "OU=Engineering,OU=Users,DC=corp,DC=com"
        }
        Write-Verbose "Employee onboarding batch started"
    }

    process {
        $sam = ($FullName -split ' ')[0][0] + ($FullName -split ' ')[-1]
        $sam = $sam.ToLower()

        if ($PSCmdlet.ShouldProcess($FullName, "Create AD account and assign resources")) {
            try {
                # Step 1: Create AD Account
                $userParams = @{
                    Name              = $FullName
                    SamAccountName    = $sam
                    UserPrincipalName = $Email
                    Department        = $Department
                    Path              = $departmentOUs[$Department]
                    Enabled           = $true
                    AccountPassword   = ConvertTo-SecureString "TempP@ss123!" -AsPlainText -Force
                    ChangePasswordAtLogon = $true
                }
                New-ADUser @userParams -ErrorAction Stop
                Write-Verbose "Created AD account: $sam"

                # Step 2: Add to department group
                Add-ADGroupMember -Identity "$Department-Users" -Members $sam
                Write-Verbose "Added to group: $Department-Users"

                # Step 3: Create home folder
                $homePath = "\\FileServer\Homes\$sam"
                New-Item -Path $homePath -ItemType Directory -Force | Out-Null

                $results.Add([PSCustomObject]@{
                    Name       = $FullName
                    SAM        = $sam
                    Email      = $Email
                    Department = $Department
                    Status     = 'Success'
                    Error      = $null
                })
            }
            catch {
                $results.Add([PSCustomObject]@{
                    Name       = $FullName
                    SAM        = $sam
                    Email      = $Email
                    Department = $Department
                    Status     = 'Failed'
                    Error      = $_.Exception.Message
                })
                Write-Warning "Failed to onboard $FullName : $($_.Exception.Message)"
            }
        }
    }

    end {
        $success = ($results | Where-Object Status -eq 'Success').Count
        $failed  = ($results | Where-Object Status -eq 'Failed').Count
        Write-Verbose "Onboarding complete: $success succeeded, $failed failed"
        $results
    }
}

# Usage:
Import-Csv "new_employees.csv" | New-EmployeeOnboarding -Verbose -WhatIf
```

---

## Scenario 2: Certificate Expiry Monitor

```powershell
function Get-ExpiringCertificate {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("CN", "Server")]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName,

        [Parameter()]
        [ValidateRange(1, 365)]
        [int]$DaysThreshold = 30,

        [Parameter()]
        [ValidateSet("LocalMachine", "CurrentUser")]
        [string]$StoreLocation = "LocalMachine",

        [Parameter()]
        [PSCredential]$Credential
    )

    begin {
        Write-Verbose "Scanning for certificates expiring within $DaysThreshold days"
        $cutoffDate = (Get-Date).AddDays($DaysThreshold)
    }

    process {
        foreach ($computer in $ComputerName) {
            Write-Verbose "Checking: $computer"
            try {
                $icmParams = @{
                    ComputerName = $computer
                    ScriptBlock  = {
                        param($storeLoc, $cutoff)
                        Get-ChildItem "Cert:\$storeLoc\My" |
                            Where-Object { $_.NotAfter -lt $cutoff -and $_.NotAfter -gt (Get-Date) } |
                            Select-Object Subject, Thumbprint, NotAfter, Issuer
                    }
                    ArgumentList = $StoreLocation, $cutoffDate
                    ErrorAction  = 'Stop'
                }
                if ($PSBoundParameters.ContainsKey('Credential')) {
                    $icmParams['Credential'] = $Credential
                }

                $certs = Invoke-Command @icmParams

                foreach ($cert in $certs) {
                    [PSCustomObject]@{
                        Computer    = $computer
                        Subject     = $cert.Subject
                        Thumbprint  = $cert.Thumbprint
                        ExpiresOn   = $cert.NotAfter
                        DaysLeft    = [math]::Round(($cert.NotAfter - (Get-Date)).TotalDays)
                        Issuer      = $cert.Issuer
                        Urgency     = if (($cert.NotAfter - (Get-Date)).TotalDays -le 7) { "CRITICAL" }
                                      elseif (($cert.NotAfter - (Get-Date)).TotalDays -le 14) { "HIGH" }
                                      else { "MEDIUM" }
                    }
                }
            }
            catch {
                Write-Warning "$computer : $($_.Exception.Message)"
                [PSCustomObject]@{
                    Computer   = $computer
                    Subject    = 'ERROR'
                    Thumbprint = 'N/A'
                    ExpiresOn  = $null
                    DaysLeft   = -1
                    Issuer     = 'N/A'
                    Urgency    = 'UNREACHABLE'
                }
            }
        }
    }
}

# Usage
Get-ADComputer -Filter { OperatingSystem -like "*Server*" } |
    Select-Object -ExpandProperty Name |
    Get-ExpiringCertificate -DaysThreshold 60 -Verbose |
    Sort-Object DaysLeft |
    Format-Table -AutoSize
```

---

## Scenario 3: Structured Logging Function

```powershell
function Write-StructuredLog {
    [CmdletBinding(DefaultParameterSetName = 'Message')]
    param(
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'Message')]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory, ParameterSetName = 'ErrorRecord')]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,

        [Parameter()]
        [ValidateSet("DEBUG", "INFO", "WARN", "ERROR", "FATAL")]
        [string]$Level = "INFO",

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Component = $MyInvocation.ScriptName,

        [Parameter()]
        [ValidateScript({ Test-Path (Split-Path $_ -Parent) })]
        [string]$LogPath = "C:\Logs\automation.log",

        [Parameter()]
        [hashtable]$AdditionalData,

        [switch]$PassThru
    )

    $logEntry = [ordered]@{
        Timestamp = (Get-Date -Format "o")
        Level     = $Level
        Component = $Component
        PID       = $PID
        Machine   = $env:COMPUTERNAME
        User      = "$env:USERDOMAIN\$env:USERNAME"
    }

    switch ($PSCmdlet.ParameterSetName) {
        'Message' {
            $logEntry['Message'] = $Message
        }
        'ErrorRecord' {
            $logEntry['Level']    = 'ERROR'
            $logEntry['Message']  = $ErrorRecord.Exception.Message
            $logEntry['ErrorId']  = $ErrorRecord.FullyQualifiedErrorId
            $logEntry['Line']     = $ErrorRecord.InvocationInfo.ScriptLineNumber
            $logEntry['Stack']    = $ErrorRecord.ScriptStackTrace
        }
    }

    if ($AdditionalData) {
        $logEntry['Data'] = $AdditionalData
    }

    $json = $logEntry | ConvertTo-Json -Compress
    $json | Add-Content -Path $LogPath -Encoding UTF8

    if ($PassThru) { [PSCustomObject]$logEntry }
}

# Usage
Write-StructuredLog "Deployment started" -Level INFO -Component "Deploy-App"
Write-StructuredLog "Disk space low" -Level WARN -AdditionalData @{ FreeGB = 2.1; Drive = "C:" }

try { Get-Item "X:\" -ErrorAction Stop }
catch { Write-StructuredLog -ErrorRecord $_ }
```

---

## Scenario 4: Software Deployment with Parameter Sets

```powershell
function Install-Software {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'MSI')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName,

        [Parameter(Mandatory, ParameterSetName = 'MSI')]
        [ValidateScript({ $_ -match '\.msi$' -and (Test-Path $_) })]
        [string]$MsiPath,

        [Parameter(ParameterSetName = 'MSI')]
        [string]$MsiArguments = "/qn /norestart",

        [Parameter(Mandatory, ParameterSetName = 'EXE')]
        [ValidateScript({ $_ -match '\.exe$' -and (Test-Path $_) })]
        [string]$ExePath,

        [Parameter(ParameterSetName = 'EXE')]
        [string]$ExeArguments = "/S",

        [Parameter(Mandatory, ParameterSetName = 'Chocolatey')]
        [ValidateNotNullOrEmpty()]
        [string]$PackageName,

        [Parameter(ParameterSetName = 'Chocolatey')]
        [string]$PackageVersion,

        [Parameter()]
        [ValidateRange(30, 3600)]
        [int]$TimeoutSeconds = 600,

        [Parameter()]
        [PSCredential]$Credential
    )

    process {
        foreach ($computer in $ComputerName) {
            if ($PSCmdlet.ShouldProcess($computer, "Install software ($($PSCmdlet.ParameterSetName))")) {
                Write-Verbose "Installing on $computer via $($PSCmdlet.ParameterSetName)"

                $installScript = switch ($PSCmdlet.ParameterSetName) {
                    'MSI' {
                        { param($path, $args) Start-Process msiexec -ArgumentList "/i `"$path`" $args" -Wait -PassThru }
                    }
                    'EXE' {
                        { param($path, $args) Start-Process $path -ArgumentList $args -Wait -PassThru }
                    }
                    'Chocolatey' {
                        { param($pkg, $ver) choco install $pkg --version=$ver -y }
                    }
                }

                try {
                    $icmParams = @{
                        ComputerName = $computer
                        ScriptBlock  = $installScript
                        ErrorAction  = 'Stop'
                    }
                    if ($PSBoundParameters.ContainsKey('Credential')) {
                        $icmParams['Credential'] = $Credential
                    }

                    Invoke-Command @icmParams
                    $status = 'Success'
                }
                catch {
                    $status = "Failed: $($_.Exception.Message)"
                }

                [PSCustomObject]@{
                    Computer = $computer
                    Method   = $PSCmdlet.ParameterSetName
                    Status   = $status
                    Time     = Get-Date
                }
            }
        }
    }
}

# Three different ways to install:
Install-Software -ComputerName "PC01","PC02" -MsiPath "\\share\app.msi" -WhatIf
Install-Software -ComputerName "PC01" -ExePath "\\share\setup.exe" -ExeArguments "/silent"
Install-Software -ComputerName "PC01" -PackageName "notepadplusplus" -Verbose
```

---

## Key Patterns Summary

| Pattern | When to Use |
|---------|-------------|
| `[CmdletBinding()]` | Every production function |
| `SupportsShouldProcess` | Any state-changing operation |
| `ValueFromPipelineByPropertyName` | CSV/object pipeline processing |
| `begin/process/end` | Pipeline-aware functions |
| `$PSBoundParameters` | Parameter forwarding, conditional logic |
| `ValidateSet` + `ValidateScript` | Input safety |
| Parameter Sets | Multiple execution modes |
| `[OutputType()]` | Better IntelliSense for consumers |
| `Generic.List<T>` | Collecting results (not array `+=`) |
| `try/catch` per item | Don't let one failure stop the batch |

---

> **🎯 Final Interview Tip**: When asked "write a production-quality function," always include:
> 1. `[CmdletBinding()]`
> 2. Comment-based help
> 3. Parameter validation
> 4. `begin/process/end`
> 5. Proper error handling
> 6. `Write-Verbose` for observability
> 7. `ShouldProcess` if modifying state
> 8. `[OutputType()]`
