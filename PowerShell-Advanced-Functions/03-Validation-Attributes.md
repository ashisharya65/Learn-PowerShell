# 03 — Validation Attributes (Complete Reference)

Every validation attribute with real-world scenarios.

---

## 1. `[ValidateNotNull()]`

Prevents `$null` from being passed. Allows empty strings.

```powershell
function Set-Configuration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$ConfigObject
    )
    $ConfigObject | ConvertTo-Json | Set-Content "config.json"
}

Set-Configuration -ConfigObject $null    # ❌ Error
Set-Configuration -ConfigObject @{}      # ✅ Works (empty hashtable is not null)
```

---

## 2. `[ValidateNotNullOrEmpty()]`

Prevents `$null`, empty string `""`, and empty array `@()`.

```powershell
function Send-Alert {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Recipients,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )
    foreach ($r in $Recipients) {
        Write-Output "Sending to $r : $Message"
    }
}

Send-Alert -Recipients @() -Message "Test"    # ❌ Error: empty array
Send-Alert -Recipients "" -Message ""          # ❌ Error: empty string
Send-Alert -Recipients "admin@co.com" -Message "Server Down"  # ✅ Works
```

---

## 3. `[ValidateSet()]`

Restricts to a predefined list of values. Provides **tab-completion**.

```powershell
function Deploy-Application {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("Development", "Staging", "Production", IgnoreCase = $false)]
        [string]$Environment,

        [Parameter(Mandatory)]
        [ValidateSet("IIS", "Apache", "Nginx")]
        [string]$WebServer
    )
    Write-Output "Deploying to $Environment on $WebServer"
}

Deploy-Application -Environment "production"  # ❌ Error (case-sensitive)
Deploy-Application -Environment "Production" -WebServer "IIS"  # ✅
# Tab-completion works for both parameters!
```

### Dynamic ValidateSet with Class (PS 6.1+)

```powershell
class AvailableServices : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return (Get-Service).Name
    }
}

function Restart-ManagedService {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateSet([AvailableServices])]
        [string]$ServiceName
    )
    if ($PSCmdlet.ShouldProcess($ServiceName, "Restart")) {
        Restart-Service $ServiceName
    }
}
# Tab-completion shows LIVE service names from the system!
```

---

## 4. `[ValidateRange()]`

Restricts numeric values to a range.

```powershell
function Set-RetryPolicy {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateRange(1, 10)]
        [int]$MaxRetries = 3,

        [Parameter()]
        [ValidateRange(100, 30000)]
        [int]$TimeoutMs = 5000,

        [Parameter()]
        [ValidateRange("Positive")]    # PS 6.1+: Positive, NonNegative, Negative, NonPositive
        [double]$Multiplier = 1.5
    )

    [PSCustomObject]@{
        MaxRetries = $MaxRetries
        TimeoutMs  = $TimeoutMs
        Multiplier = $Multiplier
    }
}

Set-RetryPolicy -MaxRetries 0       # ❌ Error: below range
Set-RetryPolicy -MaxRetries 15      # ❌ Error: above range
Set-RetryPolicy -MaxRetries 5       # ✅ Works
Set-RetryPolicy -Multiplier -2      # ❌ Error: not positive
```

---

## 5. `[ValidateLength()]`

Validates **string length**.

```powershell
function New-UserAccount {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateLength(3, 20)]
        [string]$Username,

        [Parameter(Mandatory)]
        [ValidateLength(8, 128)]
        [string]$Password
    )
    Write-Output "Creating account: $Username"
}

New-UserAccount -Username "ab" -Password "pass"         # ❌ Both too short
New-UserAccount -Username "ashish" -Password "SecureP@ss1"  # ✅ Works
```

---

## 6. `[ValidateCount()]`

Validates the **number of elements in an array**.

```powershell
function Set-DNSServers {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateCount(1, 4)]
        [ipaddress[]]$DNSServers,

        [Parameter(Mandatory)]
        [string]$InterfaceName
    )
    Write-Output "Setting $($DNSServers.Count) DNS servers on $InterfaceName"
}

Set-DNSServers -DNSServers @() -InterfaceName "Ethernet"                    # ❌ Needs at least 1
Set-DNSServers -DNSServers "8.8.8.8","8.8.4.4","1.1.1.1","1.0.0.1","9.9.9.9" -InterfaceName "Ethernet"  # ❌ Max 4
Set-DNSServers -DNSServers "8.8.8.8","1.1.1.1" -InterfaceName "Ethernet"   # ✅ Works
```

---

## 7. `[ValidatePattern()]`

Validates against a **regex pattern**.

```powershell
function New-ServerEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[A-Z]{2,3}-[A-Z]+-\d{2,3}$',
            ErrorMessage = "'{0}' is not valid. Use format: DC-PROD-01")]
        [string]$ServerName,

        [Parameter(Mandatory)]
        [ValidatePattern('^\d{1,3}(\.\d{1,3}){3}$')]
        [string]$IPAddress,

        [Parameter()]
        [ValidatePattern('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            ErrorMessage = "'{0}' is not a valid email address")]
        [string]$OwnerEmail
    )
    [PSCustomObject]@{
        Server = $ServerName
        IP     = $IPAddress
        Owner  = $OwnerEmail
    }
}

New-ServerEntry -ServerName "myserver" -IPAddress "10.0.0.1"      # ❌ Bad name format
New-ServerEntry -ServerName "DC-PROD-01" -IPAddress "10.0.0.1"    # ✅ Works
```

---

## 8. `[ValidateScript()]`

Runs a **custom script block** for validation. Must return `$true`.

```powershell
function Import-DataFile {
    [CmdletBinding()]
    param(
        # Validate: file must exist AND be a .csv
        [Parameter(Mandatory)]
        [ValidateScript({
            if (-not (Test-Path $_)) {
                throw "File '$_' does not exist."
            }
            if ($_ -notmatch '\.csv$') {
                throw "File '$_' must be a .csv file."
            }
            $true
        })]
        [string]$FilePath,

        # Validate: date must be in the past
        [Parameter()]
        [ValidateScript({
            if ($_ -gt (Get-Date)) {
                throw "Date must be in the past. Got: $_"
            }
            $true
        })]
        [datetime]$StartDate = (Get-Date).AddDays(-7)
    )
    Import-Csv $FilePath | Where-Object { [datetime]$_.Date -ge $StartDate }
}
```

### Complex Validation Example

```powershell
function Connect-Database {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({
            $uri = [System.Uri]::new($_)
            if ($uri.Scheme -notin 'tcp', 'sqlserver') {
                throw "Invalid scheme '$($uri.Scheme)'. Use 'tcp' or 'sqlserver'."
            }
            if ([string]::IsNullOrEmpty($uri.Host)) {
                throw "Host is required in the connection string."
            }
            $true
        })]
        [string]$ConnectionString
    )
    Write-Output "Connecting to: $ConnectionString"
}
```

---

## 9. `[ValidateDrive()]`

Restricts to specific PSDrive names.

```powershell
function Set-RegistryValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateDrive("HKLM", "HKCU")]
        [string]$RegistryPath,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [object]$Value
    )
    Set-ItemProperty -Path $RegistryPath -Name $Name -Value $Value
}

Set-RegistryValue -RegistryPath "C:\NotRegistry" -Name "X" -Value 1     # ❌ Not a registry drive
Set-RegistryValue -RegistryPath "HKLM:\SOFTWARE\MyApp" -Name "X" -Value 1  # ✅ Works
```

---

## 10. `[ValidateUserDrive()]`

Restricts paths to the **User** PSDrive (JEA scenarios).

```powershell
function Save-UserReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateUserDrive()]
        [string]$Path
    )
    Get-Process | Export-Csv $Path
}
# Only allows paths in User: drive (JEA constrained sessions)
```

---

## 11. `[ValidateTrustedData()]`

Marks parameter as requiring trusted data (constrained language mode).

```powershell
function Invoke-SafeScript {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateTrustedData()]
        [scriptblock]$ScriptBlock
    )
    & $ScriptBlock
}
```

---

## 12. `[AllowNull()]`

Overrides `Mandatory` to **allow $null**.

```powershell
function Set-UserManager {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$UserName,

        [Parameter(Mandatory)]
        [AllowNull()]
        [string]$ManagerName    # Mandatory but can be $null (to clear manager)
    )
    if ($null -eq $ManagerName) {
        Write-Output "Clearing manager for $UserName"
    } else {
        Write-Output "Setting manager of $UserName to $ManagerName"
    }
}
```

---

## 13. `[AllowEmptyString()]`

Allows empty string `""` on a Mandatory parameter.

```powershell
function Set-Description {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Description    # Can be "" to clear the description
    )
    Set-ADComputer -Identity $ComputerName -Description $Description
}
```

---

## 14. `[AllowEmptyCollection()]`

Allows empty array `@()` on a Mandatory parameter.

```powershell
function Set-GroupMembers {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$GroupName,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$Members    # Empty = clear all members
    )
    if ($Members.Count -eq 0) {
        Write-Output "Removing all members from $GroupName"
    } else {
        Write-Output "Setting $($Members.Count) members in $GroupName"
    }
}
```

---

## Combining Multiple Validations

```powershell
function New-ServiceAccount {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(5, 20)]
        [ValidatePattern('^svc-[a-z]+-\d{2}$',
            ErrorMessage = "Must follow pattern: svc-appname-01")]
        [string]$AccountName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Standard", "Managed", "GroupManaged")]
        [string]$AccountType,

        [Parameter()]
        [ValidateScript({
            $ou = [adsi]"LDAP://$_"
            if (-not $ou.Path) { throw "OU '$_' not found in AD" }
            $true
        })]
        [string]$OrganizationalUnit = "OU=ServiceAccounts,DC=corp,DC=com"
    )

    [PSCustomObject]@{
        Name = $AccountName
        Type = $AccountType
        OU   = $OrganizationalUnit
    }
}
```

---

## Quick Reference Table

| Attribute | Validates | Example |
|-----------|-----------|---------|
| `[ValidateNotNull()]` | Not `$null` | Objects that must exist |
| `[ValidateNotNullOrEmpty()]` | Not `$null`, `""`, `@()` | Required strings/arrays |
| `[ValidateSet()]` | Predefined values | Environment names |
| `[ValidateRange()]` | Numeric range | Port numbers, retry counts |
| `[ValidateLength()]` | String length | Usernames, passwords |
| `[ValidateCount()]` | Array element count | DNS servers, IP list |
| `[ValidatePattern()]` | Regex match | Server names, emails |
| `[ValidateScript()]` | Custom logic | File exists, AD lookup |
| `[ValidateDrive()]` | PSDrive type | Registry paths only |
| `[AllowNull()]` | Permit `$null` on Mandatory | Clearable fields |
| `[AllowEmptyString()]` | Permit `""` on Mandatory | Clearable descriptions |
| `[AllowEmptyCollection()]` | Permit `@()` on Mandatory | Clearable group members |

---

> **💡 Interview Tip**: Validation attributes run **before** the function body executes. This means invalid input is rejected immediately with a clear error, without you writing any manual validation code. Always prefer declarative validation over manual `if` checks.
