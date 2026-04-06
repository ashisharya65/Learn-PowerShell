# 🚀 PowerShell Development — Interview Preparation Guide

> **Interview in: 2 Days | Created: April 6, 2026**

---

## 📋 Table of Contents

1. [PowerShell Fundamentals](#1-powershell-fundamentals)
2. [Variables, Data Types & Operators](#2-variables-data-types--operators)
3. [Control Flow & Loops](#3-control-flow--loops)
4. [Functions & Parameters](#4-functions--parameters)
5. [Pipeline & Objects](#5-pipeline--objects)
6. [Error Handling](#6-error-handling)
7. [Modules & Script Structure](#7-modules--script-structure)
8. [PowerShell Remoting](#8-powershell-remoting)
9. [File System & Registry Operations](#9-file-system--registry-operations)
10. [Regular Expressions & String Manipulation](#10-regular-expressions--string-manipulation)
11. [Working with APIs & Web Requests](#11-working-with-apis--web-requests)
12. [DSC (Desired State Configuration)](#12-dsc-desired-state-configuration)
13. [PowerShell & Active Directory](#13-powershell--active-directory)
14. [Best Practices & Code Quality](#14-best-practices--code-quality)
15. [Top 50 Interview Q&A](#15-top-50-interview-qa)

---

## 1. PowerShell Fundamentals

### What is PowerShell?
- **Object-oriented** shell and scripting language built on **.NET**
- Unlike Bash (text-based), PowerShell passes **objects** through the pipeline
- Two editions: **Windows PowerShell (5.1)** and **PowerShell Core (7.x)** (cross-platform)

### Key Differences: PowerShell 5.1 vs 7.x

| Feature | Windows PS 5.1 | PowerShell 7.x |
|---|---|---|
| Runtime | .NET Framework | .NET (Core) |
| Platform | Windows only | Cross-platform |
| Ternary Operator | ❌ | ✅ `$x ? 'yes' : 'no'` |
| Pipeline Chain | ❌ | ✅ `&&` and `||` |
| Null Coalescing | ❌ | ✅ `$x ?? 'default'` |
| ForEach-Object -Parallel | ❌ | ✅ |

### Cmdlet Naming Convention
```
Verb-Noun
Get-Process, Set-Item, New-Object, Remove-Item
```
Use `Get-Verb` to see approved verbs.

### Getting Help
```powershell
Get-Help Get-Process -Full
Get-Help Get-Process -Examples
Get-Command -Verb Get -Noun *Service*
Get-Member  # Inspect object properties/methods
```

---

## 2. Variables, Data Types & Operators

### Variable Declaration
```powershell
$name = "Ashish"                    # String
[int]$age = 28                      # Strongly typed
[string[]]$servers = @("S1","S2")   # Array
$hash = @{ Key = "Value" }          # Hashtable
[datetime]$date = Get-Date          # DateTime
```

### Special Variables
```powershell
$null           # Null value
$true / $false  # Boolean
$_              # Current pipeline object
$PSVersionTable # PS version info
$ErrorActionPreference  # Default error action
$LASTEXITCODE   # Last native command exit code
$?              # Success/failure of last command
$PSScriptRoot   # Script's directory
$PSCommandPath  # Script's full path
$env:COMPUTERNAME  # Environment variable
```

### Operators
```powershell
# Comparison (case-insensitive by default)
-eq, -ne, -gt, -lt, -ge, -le
-ceq    # Case-sensitive equal
-like   # Wildcard match
-match  # Regex match
-contains, -in, -notin

# Logical
-and, -or, -not, !

# Type
-is, -isnot, -as
"123" -as [int]  # Type conversion

# String
-replace, -split, -join
"Hello" -replace "l","r"  # "Herro"

# Redirection
>, >>, 2>, 2>&1
```

### Arrays & Hashtables
```powershell
# Array
$arr = @(1, 2, 3)
$arr += 4                    # Add element (creates new array!)
$arr[0..2]                   # Slicing
$arr | Where-Object { $_ -gt 2 }

# ArrayList (better performance for add/remove)
$list = [System.Collections.ArrayList]::new()
$list.Add("item") | Out-Null

# Hashtable
$ht = @{ Name = "Ashish"; Role = "Engineer" }
$ht["Name"]                  # Access
$ht.Add("Dept", "IT")       # Add
$ht.Keys                    # Get all keys

# Ordered Hashtable
$ordered = [ordered]@{ First = 1; Second = 2 }
```

---

## 3. Control Flow & Loops

```powershell
# If/ElseIf/Else
if ($x -gt 10) { "Big" }
elseif ($x -gt 5) { "Medium" }
else { "Small" }

# Switch
switch ($status) {
    "Running"  { "Active" }
    "Stopped"  { "Inactive" }
    default    { "Unknown" }
}

# Switch with -Regex / -Wildcard
switch -Regex ($input) {
    '^\d+$'    { "Number" }
    '^[a-z]+$' { "Letters" }
}

# For Loop
for ($i = 0; $i -lt 10; $i++) { $i }

# ForEach Loop
foreach ($server in $servers) { Test-Connection $server }

# ForEach-Object (Pipeline)
$servers | ForEach-Object { Test-Connection $_ }

# While / Do-While / Do-Until
while ($x -lt 10) { $x++ }
do { $x++ } while ($x -lt 10)
do { $x++ } until ($x -ge 10)

# ForEach-Object -Parallel (PS 7+)
1..10 | ForEach-Object -Parallel { Start-Sleep 1; $_ } -ThrottleLimit 5
```

---

## 4. Functions & Parameters

### Basic Function
```powershell
function Get-Greeting {
    param(
        [string]$Name = "World"
    )
    "Hello, $Name!"
}
```

### Advanced Function (Production-Grade)
```powershell
function Get-ServerHealth {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName,

        [Parameter()]
        [ValidateSet("Basic", "Full")]
        [string]$ReportType = "Basic",

        [Parameter()]
        [ValidateRange(1, 100)]
        [int]$ThrottleLimit = 10,

        [Parameter()]
        [PSCredential]$Credential
    )

    begin {
        Write-Verbose "Starting health check..."
        $results = @()
    }

    process {
        foreach ($computer in $ComputerName) {
            if ($PSCmdlet.ShouldProcess($computer, "Health Check")) {
                # ... logic here
            }
        }
    }

    end {
        Write-Verbose "Completed. Checked $($results.Count) servers."
        return $results
    }
}
```

### Parameter Validation Attributes
```powershell
[ValidateNotNullOrEmpty()]      # Cannot be null or empty
[ValidateSet("A","B","C")]      # Must be one of these values
[ValidateRange(1,100)]          # Numeric range
[ValidatePattern('^\d{3}$')]    # Regex pattern
[ValidateScript({ Test-Path $_ })]  # Custom validation
[ValidateLength(1,50)]          # String length
[ValidateCount(1,5)]            # Array element count
[AllowNull()]                   # Override mandatory null check
[AllowEmptyString()]            # Allow empty string
```

### Parameter Sets
```powershell
function Connect-Server {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param(
        [Parameter(ParameterSetName = 'ByName', Mandatory)]
        [string]$Name,

        [Parameter(ParameterSetName = 'ByIP', Mandatory)]
        [ipaddress]$IPAddress
    )
    # $PSCmdlet.ParameterSetName tells which set was used
}
```

### Splatting
```powershell
$params = @{
    Path        = "C:\Logs"
    Filter      = "*.log"
    Recurse     = $true
    ErrorAction = "SilentlyContinue"
}
Get-ChildItem @params
```

---

## 5. Pipeline & Objects

### Pipeline Fundamentals
```powershell
# Objects flow through the pipeline, NOT text
Get-Process | Where-Object CPU -gt 100 | Sort-Object CPU -Descending | Select-Object -First 5

# Creating Custom Objects
[PSCustomObject]@{
    Name   = "Server01"
    Status = "Online"
    CPU    = 45.2
}

# Select-Object: Choose/Rename properties
Get-Process | Select-Object Name, @{N='MemMB'; E={[math]::Round($_.WS/1MB,2)}}

# Group-Object
Get-Service | Group-Object Status

# Measure-Object
Get-Process | Measure-Object CPU -Sum -Average -Maximum

# Tee-Object: Split pipeline
Get-Process | Tee-Object -Variable procs | Export-Csv procs.csv
```

### Where-Object Simplified Syntax
```powershell
# Full syntax
Get-Service | Where-Object { $_.Status -eq 'Running' }

# Simplified (PS 3+)
Get-Service | Where-Object Status -eq 'Running'
```

### ForEach-Object vs foreach
```powershell
# ForEach-Object: Pipeline-based, streaming, slower per item
1..1000 | ForEach-Object { $_ * 2 }

# foreach: Statement, loads all to memory first, faster
foreach ($n in 1..1000) { $n * 2 }
```

> [!IMPORTANT]
> **Key Interview Point**: `ForEach-Object` processes one object at a time (streaming), while `foreach` loads the entire collection first. For large datasets from pipeline, `ForEach-Object` uses less memory.

---

## 6. Error Handling

### Error Types
- **Terminating Errors**: Stop execution (throw, cmdlet with -ErrorAction Stop)
- **Non-Terminating Errors**: Logged but execution continues (default for most cmdlets)

### Try/Catch/Finally
```powershell
try {
    Get-Content "C:\nonexistent.txt" -ErrorAction Stop
    # -ErrorAction Stop converts non-terminating to terminating
}
catch [System.IO.FileNotFoundException] {
    Write-Warning "File not found: $($_.Exception.Message)"
}
catch [System.UnauthorizedAccessException] {
    Write-Warning "Access denied!"
}
catch {
    Write-Error "Unexpected error: $($_.Exception.Message)"
    Write-Error "Line: $($_.InvocationInfo.ScriptLineNumber)"
}
finally {
    Write-Verbose "Cleanup complete"
}
```

### ErrorAction Preference
```powershell
# Per-command
Get-Item "X:\" -ErrorAction SilentlyContinue

# Script-wide
$ErrorActionPreference = 'Stop'  # Makes ALL errors terminating

# Values: Continue (default), Stop, SilentlyContinue, Inquire, Ignore
```

### $Error Variable
```powershell
$Error[0]                    # Most recent error
$Error[0].Exception.Message  # Error message
$Error[0].InvocationInfo     # Where it happened
$Error.Clear()               # Clear error log
```

### Trap Statement
```powershell
trap [System.DivideByZeroException] {
    Write-Warning "Division by zero!"
    continue  # Resume after the error
}
```

---

## 7. Modules & Script Structure

### Module Basics
```powershell
Get-Module                  # Loaded modules
Get-Module -ListAvailable   # Installed modules
Import-Module ActiveDirectory
Remove-Module MyModule
Install-Module PSReadLine -Scope CurrentUser
```

### Creating a Script Module
```
MyModule/
├── MyModule.psd1    # Module manifest
├── MyModule.psm1    # Module script (functions)
├── Public/          # Exported functions
├── Private/         # Internal helper functions
└── Tests/           # Pester tests
```

```powershell
# MyModule.psm1
$Public  = Get-ChildItem "$PSScriptRoot\Public\*.ps1"
$Private = Get-ChildItem "$PSScriptRoot\Private\*.ps1"

foreach ($file in @($Public + $Private)) {
    . $file.FullName    # Dot-source each file
}

Export-ModuleMember -Function $Public.BaseName
```

### Module Manifest (psd1)
```powershell
New-ModuleManifest -Path MyModule.psd1 `
    -RootModule MyModule.psm1 `
    -ModuleVersion '1.0.0' `
    -Author 'Ashish' `
    -FunctionsToExport @('Get-Something','Set-Something')
```

### Script Structure Best Practice
```powershell
#Requires -Version 5.1
#Requires -Modules ActiveDirectory
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Brief description
.DESCRIPTION
    Detailed description
.PARAMETER Name
    Parameter description
.EXAMPLE
    Example-Usage -Name "Test"
.NOTES
    Author: Ashish
    Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Name
)

# Script body...
```

---

## 8. PowerShell Remoting

### Enabling & Using Remoting
```powershell
Enable-PSRemoting -Force    # Enable on target

# 1:1 Interactive Session
Enter-PSSession -ComputerName Server01 -Credential $cred

# 1:Many (Fan-out)
Invoke-Command -ComputerName S1,S2,S3 -ScriptBlock {
    Get-Service WinRM
} -Credential $cred

# Persistent Sessions (reuse connection)
$session = New-PSSession -ComputerName Server01
Invoke-Command -Session $session -ScriptBlock { Get-Process }
# Later...
Invoke-Command -Session $session -ScriptBlock { Get-Service }
Remove-PSSession $session
```

### Implicit Remoting
```powershell
# Import remote module as if local
$s = New-PSSession -ComputerName DC01
Import-PSSession -Session $s -Module ActiveDirectory
# Now AD cmdlets run on DC01 but appear local
```

### Double-Hop Problem
```powershell
# Problem: Server A → Server B → Server C (credentials don't pass)
# Solution 1: CredSSP (security risk)
Enable-WSManCredSSP -Role Client -DelegateComputer Server02
# Solution 2: Constrained Delegation (recommended)
# Solution 3: Pass credentials explicitly
```

> [!WARNING]
> **Interview Favorite**: Always mention the Double-Hop problem and recommend **Resource-Based Kerberos Constrained Delegation** as the secure solution.

---

## 9. File System & Registry Operations

### File Operations
```powershell
# Files & Folders
New-Item -Path "C:\Logs" -ItemType Directory
Copy-Item -Path ".\file.txt" -Destination "C:\Backup\" -Recurse
Move-Item, Remove-Item, Rename-Item, Test-Path

# Reading/Writing
Get-Content file.txt                          # Read all lines
Get-Content file.txt -Tail 10                 # Last 10 lines
Set-Content file.txt -Value "Hello"           # Overwrite
Add-Content file.txt -Value "New line"        # Append
Get-Content large.log -ReadCount 1000         # Batch read

# CSV
Import-Csv users.csv | ForEach-Object { $_.Name }
$data | Export-Csv report.csv -NoTypeInformation

# JSON
$json = Get-Content config.json | ConvertFrom-Json
$obj | ConvertTo-Json -Depth 5 | Set-Content out.json

# XML
[xml]$xml = Get-Content config.xml
$xml.root.element.attribute
```

### Registry
```powershell
# Read
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"

# Write
Set-ItemProperty -Path "HKLM:\SOFTWARE\MyApp" -Name "Setting1" -Value "Enabled"
New-Item -Path "HKLM:\SOFTWARE\MyApp"              # Create key
New-ItemProperty -Path "HKLM:\SOFTWARE\MyApp" -Name "Version" -Value "1.0"

# Test
Test-Path "HKLM:\SOFTWARE\MyApp"
```

---

## 10. Regular Expressions & String Manipulation

```powershell
# -match (returns $true/$false, populates $Matches)
"Server-DC01" -match 'Server-(\w+)'
$Matches[1]  # "DC01"

# -replace with regex
"2026-04-06" -replace '(\d{4})-(\d{2})-(\d{2})', '$3/$2/$1'
# Output: 06/04/2026

# Select-String (grep equivalent)
Select-String -Path "*.log" -Pattern "ERROR" -CaseSensitive

# String methods
$str = "Hello World"
$str.ToUpper()
$str.Substring(0, 5)
$str.Split(" ")
$str.Contains("World")
$str.Replace("World", "PowerShell")

# Here-Strings
$multiline = @"
Line 1
Variable: $name
Line 3
"@

# Format strings
"User {0} logged in at {1}" -f $user, (Get-Date)
"{0:N2}" -f 3.14159  # "3.14"
```

---

## 11. Working with APIs & Web Requests

```powershell
# GET Request
$response = Invoke-RestMethod -Uri "https://api.github.com/users/octocat"
$response.name

# POST with Body
$body = @{
    username = "admin"
    password = "secret"
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://api.example.com/login" `
    -Method Post `
    -Body $body `
    -ContentType "application/json"

# With Headers/Authentication
$headers = @{
    Authorization = "Bearer $token"
    Accept        = "application/json"
}
Invoke-RestMethod -Uri $uri -Headers $headers

# Download File
Invoke-WebRequest -Uri $url -OutFile "file.zip"

# Microsoft Graph API Example
$token = (Get-MsalToken -ClientId $appId -TenantId $tenantId).AccessToken
$users = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users" `
    -Headers @{ Authorization = "Bearer $token" }
```

---

## 12. DSC (Desired State Configuration)

```powershell
# DSC Configuration
Configuration WebServerSetup {
    param([string[]]$ComputerName = "localhost")

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $ComputerName {
        WindowsFeature IIS {
            Name   = "Web-Server"
            Ensure = "Present"
        }

        File WebContent {
            DestinationPath = "C:\inetpub\wwwroot\index.html"
            Contents        = "<h1>Hello from DSC</h1>"
            Ensure          = "Present"
            DependsOn       = "[WindowsFeature]IIS"
        }

        Service W3SVC {
            Name      = "W3SVC"
            State     = "Running"
            DependsOn = "[WindowsFeature]IIS"
        }
    }
}

# Compile & Apply
WebServerSetup -OutputPath ".\MOF"
Start-DscConfiguration -Path ".\MOF" -Wait -Verbose
Test-DscConfiguration  # Check compliance
```

> [!NOTE]
> DSC uses **Push** (manual apply) or **Pull** (server-based, periodic check) modes. Pull mode is preferred for enterprise.

---

## 13. PowerShell & Active Directory

```powershell
# User Management
Get-ADUser -Identity "jdoe" -Properties *
New-ADUser -Name "John Doe" -SamAccountName "jdoe" -Enabled $true
Set-ADUser -Identity "jdoe" -Title "Engineer"
Disable-ADAccount -Identity "jdoe"

# Group Management
Get-ADGroupMember -Identity "IT-Admins" -Recursive
Add-ADGroupMember -Identity "IT-Admins" -Members "jdoe"

# Bulk Operations
Import-Csv users.csv | ForEach-Object {
    New-ADUser -Name $_.Name -SamAccountName $_.SAM `
               -Path $_.OU -Enabled $true `
               -AccountPassword (ConvertTo-SecureString $_.Pass -AsPlainText -Force)
}

# Search
Get-ADUser -Filter { Enabled -eq $false } -SearchBase "OU=Users,DC=corp,DC=com"
Get-ADComputer -Filter { OperatingSystem -like "*Server*" }
```

---

## 14. Best Practices & Code Quality

### Coding Standards
```powershell
# ✅ DO
- Use approved verbs (Get-Verb)
- Use PascalCase for functions, camelCase for local vars
- Use full cmdlet names (not aliases) in scripts
- Use [CmdletBinding()] on all functions
- Add comment-based help
- Use Write-Verbose, Write-Debug (not Write-Host)
- Handle errors with try/catch
- Use splatting for long parameter lists

# ❌ DON'T
- Use aliases in scripts (gci, %, ?, fl, ft)
- Use Write-Host for output (it bypasses the pipeline)
- Use backtick line continuation (use splatting instead)
- Hardcode paths or credentials
- Use $global: scope unnecessarily
```

### Pester Testing
```powershell
Describe "Get-ServerHealth" {
    Context "When server is reachable" {
        BeforeAll {
            Mock Test-Connection { return $true }
        }

        It "Should return status Online" {
            $result = Get-ServerHealth -ComputerName "Server01"
            $result.Status | Should -Be "Online"
        }

        It "Should accept pipeline input" {
            { "Server01" | Get-ServerHealth } | Should -Not -Throw
        }
    }

    Context "When server is unreachable" {
        BeforeAll {
            Mock Test-Connection { throw "Unreachable" }
        }

        It "Should return status Offline" {
            $result = Get-ServerHealth -ComputerName "BadServer"
            $result.Status | Should -Be "Offline"
        }
    }
}
```

### Performance Tips
```powershell
# Use ArrayList instead of += on arrays
$list = [System.Collections.Generic.List[string]]::new()
$list.Add("item")

# Use -Filter parameter instead of Where-Object
Get-ADUser -Filter { Department -eq "IT" }      # ✅ Server-side filter
Get-ADUser -Filter * | Where-Object { $_.Department -eq "IT" }  # ❌ Client-side

# Use runspaces or ForEach-Object -Parallel for concurrency
# Avoid excessive pipeline usage for tight loops
```

---

## 15. Top 50 Interview Q&A

### 🔹 Fundamentals (Q1-Q10)

**Q1: What is PowerShell and how is it different from CMD?**
> PowerShell is an object-oriented automation framework built on .NET. CMD is text-based and limited. PowerShell passes **objects** through the pipeline, has rich scripting capabilities, and can manage .NET, COM, WMI, and REST APIs natively.

**Q2: Explain the PowerShell pipeline.**
> Objects are passed from one cmdlet to the next. Each cmdlet receives, processes, and outputs objects. E.g., `Get-Process | Where-Object CPU -gt 50 | Stop-Process`. The key is **objects, not text**.

**Q3: What is the difference between `Write-Host` and `Write-Output`?**
> `Write-Output` sends objects to the pipeline (can be captured/piped). `Write-Host` writes directly to the console, bypassing the pipeline. In scripts, prefer `Write-Output` or implicit output.

**Q4: Explain PowerShell providers and PSDrives.**
> Providers expose data stores as file systems. PSDrives are mapped paths. Examples: `FileSystem`, `Registry`, `Certificate`, `Environment`, `Variable`. You navigate registry like: `cd HKLM:\SOFTWARE`.

**Q5: What are PowerShell profiles?**
> Scripts that run at session start. Levels: AllUsersAllHosts, AllUsersCurrentHost, CurrentUserAllHosts, CurrentUserCurrentHost. Path: `$PROFILE`.

**Q6: Explain execution policies.**
> Security feature controlling script execution. Values: `Restricted` (no scripts), `AllSigned`, `RemoteSigned` (default on servers), `Unrestricted`, `Bypass`. **Not a security boundary** — it's a safety net.

**Q7: What is CIM vs WMI?**
> WMI (Windows Management Instrumentation) is older, DCOM-based. CIM uses WSMAN (standards-based). `Get-CimInstance` is preferred over `Get-WmiObject` (deprecated in PS 7). CIM is faster and firewall-friendly.

**Q8: Explain `$_` and `$PSItem`.**
> Both represent the **current object** in the pipeline. `$PSItem` is the formal name (PS 3+), `$_` is the shorthand. Used in `Where-Object`, `ForEach-Object`, etc.

**Q9: What is dot-sourcing vs call operator?**
> Dot-sourcing (`. .\script.ps1`) runs a script in the **current scope** — variables/functions persist. Call operator (`& .\script.ps1`) runs in a **child scope** — variables are discarded after.

**Q10: What are PowerShell scopes?**
> `Global` → `Script` → `Local` → `Private`. Child scopes can **read** parent variables but not **modify** them unless using `$script:` or `$global:` prefix.

---

### 🔹 Scripting & Functions (Q11-Q20)

**Q11: Explain `[CmdletBinding()]`.**
> Makes a function behave like a compiled cmdlet. Provides: `-Verbose`, `-Debug`, `-ErrorAction`, `-WhatIf`, `-Confirm` parameters automatically. Enables `$PSCmdlet` object access.

**Q12: What is `Begin`, `Process`, `End` in a function?**
> `Begin`: Runs once before pipeline input. `Process`: Runs for **each** pipeline object. `End`: Runs after all pipeline input. Critical for pipeline-aware functions.

**Q13: What is splatting?**
> Passing parameters as a hashtable using `@` instead of `$`. Improves readability for cmdlets with many parameters: `Get-ChildItem @params`.

**Q14: Explain `ValueFromPipeline` vs `ValueFromPipelineByPropertyName`.**
> `ValueFromPipeline`: Binds the **entire pipeline object** to the parameter. `ValueFromPipelineByPropertyName`: Binds based on **matching property name**. The latter allows multiple parameters to bind from one object.

**Q15: What is the difference between `return` and output in PowerShell?**
> `return $value` outputs the value AND exits the function. But in PS, **any unassigned expression** is implicit output. `return` is mostly for flow control. Avoid mixing `return` with pipeline output.

**Q16: How do you handle mandatory parameters with defaults?**
> You can't — `Mandatory` and default values are mutually exclusive. If `Mandatory` is set, PS prompts for the value. Use `Mandatory` when a value is required; use defaults when a fallback makes sense.

**Q17: What are dynamic parameters?**
> Parameters added at runtime based on conditions (e.g., another parameter's value, provider context). Defined in a `dynamicparam {}` block. Example: `Get-ChildItem`'s `-File`/`-Directory` only appear for the filesystem provider.

**Q18: Explain `#Requires` statement.**
> Pre-execution checks: `#Requires -Version 5.1`, `#Requires -Modules Az`, `#Requires -RunAsAdministrator`. Script won't run if requirements aren't met.

**Q19: What is a proxy function?**
> A wrapper around an existing cmdlet to modify its behavior. Created using `[System.Management.Automation.ProxyCommand]::Create()`. Useful for adding logging or default parameters to standard cmdlets.

**Q20: What are script blocks and how are they used?**
> Code blocks enclosed in `{}`. Used as: parameters to cmdlets, callbacks, Invoke-Command scriptblocks, Where-Object filters, event handlers. They're like anonymous functions.

---

### 🔹 Error Handling & Debugging (Q21-Q27)

**Q21: Terminating vs Non-Terminating errors?**
> **Terminating**: Stop execution (throw, -ErrorAction Stop, mandatory parameter missing). **Non-Terminating**: Logged to $Error, execution continues (file not found on one of many items). Use `-ErrorAction Stop` to promote.

**Q22: How do you debug PowerShell scripts?**
> `Set-PSBreakpoint` (line, variable, command), `Write-Debug`, VS Code debugger, `$DebugPreference`, `Set-StrictMode -Version Latest` (catches undefined variables).

**Q23: What is `Set-StrictMode`?**
> Enforces coding rules: `-Version 1` catches undefined variables. `-Version 2` also catches undefined properties and functions. `-Version Latest` for maximum strictness.

**Q24: Explain `$ErrorActionPreference` values.**
> `Continue` (default: show error, continue), `Stop` (terminate), `SilentlyContinue` (suppress, log to $Error), `Ignore` (suppress completely), `Inquire` (prompt user).

**Q25: How to create custom error records?**
> Use `Write-Error` with `-ErrorId`, `-Category`, `-TargetObject` or create `[System.Management.Automation.ErrorRecord]` directly for rich error info.

**Q26: What is `-ErrorVariable`?**
> Captures errors into a named variable: `Get-Item "X:\" -ErrorAction SilentlyContinue -ErrorVariable myErr`. Use `+myErr` to append instead of overwrite.

**Q27: Explain transcript logging.**
> `Start-Transcript -Path "log.txt"` captures all console output. `Stop-Transcript` ends it. Useful for auditing. Can be enforced via GPO.

---

### 🔹 Remoting & Security (Q28-Q35)

**Q28: What protocol does PS Remoting use?**
> **WinRM** (Windows Remote Management) over HTTP (5985) or HTTPS (5986). Based on WS-Management standard. Uses SOAP messages.

**Q29: `Invoke-Command` vs `Enter-PSSession`?**
> `Enter-PSSession`: Interactive 1:1 session. `Invoke-Command`: Non-interactive, supports 1:many (fan-out), better for automation. Invoke-Command runs in parallel by default (up to 32 throttle).

**Q30: Explain the Double-Hop problem.**
> When remoting from A→B, your credentials are available on B. But B cannot forward them to C (second hop). Solutions: CredSSP (not recommended), Kerberos constrained delegation, pass credentials explicitly.

**Q31: What are JEA (Just Enough Administration)?**
> Role-based access for PS remoting. Limits users to specific cmdlets/parameters. Uses session configuration files (.pssc) and role capability files (.psrc). Runs as virtual admin account.

**Q32: How to handle credentials securely?**
> Use `Get-Credential` (prompts securely), `[PSCredential]` type. Store encrypted: `ConvertTo-SecureString | Export-Clixml`. **Never** store plain-text passwords. Use Azure Key Vault or Secret Management module in production.

**Q33: What is `SecretManagement` module?**
> Microsoft's universal secret store abstraction. Supports multiple vaults (Azure KV, LastPass, KeePass, local). `Get-Secret`, `Set-Secret`, `Register-SecretVault`.

**Q34: How to sign PowerShell scripts?**
> Use `Set-AuthenticodeSignature` with a code-signing certificate. Required when execution policy is `AllSigned`. The signature is appended as a comment block at the end of the script.

**Q35: What are constrained language mode?**
> Limits PowerShell to basic operations: no .NET types, COM objects, or type conversions. Used with AppLocker/WDAC. Check: `$ExecutionContext.SessionState.LanguageMode`.

---

### 🔹 Advanced & Real-World (Q36-Q50)

**Q36: How to schedule PowerShell scripts?**
> Task Scheduler: `Register-ScheduledTask`. Use `-Action (New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-File C:\script.ps1')`. Always use `-NoProfile -ExecutionPolicy Bypass`.

**Q37: Explain PowerShell classes (PS 5+).**
```powershell
class Server {
    [string]$Name
    [string]$Status
    Server([string]$name) { $this.Name = $name; $this.Status = "Unknown" }
    [string] GetInfo() { return "$($this.Name): $($this.Status)" }
}
$s = [Server]::new("DC01")
```

**Q38: What are PowerShell runspaces?**
> Lightweight threads for parallel execution. Faster than jobs. Use `RunspacePool` for throttled parallel operations. `ForEach-Object -Parallel` in PS 7 uses runspaces internally.

**Q39: PowerShell Jobs vs Runspaces vs ThreadJobs?**
> **Jobs** (`Start-Job`): Separate process, heavy, serialized output. **ThreadJobs** (`Start-ThreadJob`): Same process, lighter. **Runspaces**: Lowest level, fastest, most control. For PS 7: use `ForEach-Object -Parallel`.

**Q40: How to interact with REST APIs?**
> `Invoke-RestMethod` for JSON APIs (auto-parses). `Invoke-WebRequest` for raw HTTP (returns headers, status code, etc.). Use `-Authentication Bearer` in PS 7.

**Q41: Explain PowerShell workflows.**
> PS 5.1 feature (removed in PS 7). Long-running, resumable, parallel tasks. Used `workflow` keyword. **Replaced by** `ForEach-Object -Parallel` and orchestrators.

**Q42: How do you handle large data efficiently?**
> Stream with pipeline (don't collect all to memory), use `-ReadCount` on `Get-Content`, use `[System.IO.StreamReader]`, use `ArrayList` or `Generic.List` instead of array `+=`, filter server-side.

**Q43: Explain Windows Event Log management.**
```powershell
Get-EventLog -LogName System -Newest 50  # Legacy
Get-WinEvent -LogName System -MaxEvents 50  # Modern (preferred)
Get-WinEvent -FilterHashtable @{LogName='System'; Level=2; StartTime=(Get-Date).AddDays(-1)}
```

**Q44: How to manage Windows Services?**
```powershell
Get-Service -Name "WinRM"
Start-Service, Stop-Service, Restart-Service
Set-Service -Name "Spooler" -StartupType Disabled
```

**Q45: What is the PowerShell Gallery?**
> Public repository for PS modules/scripts. `Find-Module`, `Install-Module`, `Publish-Module`. Use `PSResourceGet` in PS 7.4+ as the modern replacement for `PowerShellGet`.

**Q46: Explain CIM Sessions.**
> Persistent connection to remote WMI/CIM. More efficient than per-query connections. `New-CimSession -ComputerName S1`. Supports DCOM fallback for older systems.

**Q47: How to handle JSON, XML, CSV in automation?**
> JSON: `ConvertTo-Json`/`ConvertFrom-Json` (set `-Depth` for nested). CSV: `Import-Csv`/`Export-Csv -NoTypeInformation`. XML: Cast `[xml]` or use `Select-Xml` with XPath.

**Q48: What are calculated properties?**
```powershell
Get-Process | Select-Object Name, @{
    Name       = 'MemoryMB'
    Expression = { [math]::Round($_.WorkingSet64 / 1MB, 2) }
}
```

**Q49: How do you create a GUI with PowerShell?**
> Use `Windows Forms` or `WPF` (XAML). Load assemblies: `Add-Type -AssemblyName System.Windows.Forms`. For enterprise, consider `ImportExcel` module for Excel reports instead.

**Q50: What would you automate first in a new environment?**
> User onboarding/offboarding, server health checks, log collection, patch compliance reports, AD cleanup (stale accounts/computers), certificate expiry monitoring. Always start with **repetitive, error-prone, high-impact** tasks.

---

## 🎯 Quick Revision Cheat Sheet

```
Cmdlet Naming     → Verb-Noun (Get-Process)
Pipeline          → Objects, not text
$_                → Current pipeline object
[CmdletBinding()] → Makes advanced function
Begin/Process/End → Pipeline processing blocks
Splatting         → @params instead of $params
-ErrorAction Stop → Convert to terminating error
Try/Catch         → Only catches terminating errors
Invoke-Command    → 1:many remoting
Enter-PSSession   → 1:1 interactive
WinRM             → Port 5985 (HTTP) / 5986 (HTTPS)
Double-Hop        → Use Kerberos Delegation
$PSScriptRoot     → Script's directory
$PSCmdlet         → Advanced function context
Pester            → Unit testing framework
PSDrive           → Virtual filesystem drives
JEA               → Restrict remoting capabilities
SecretManagement  → Secure credential storage
ForEach -Parallel → PS 7 only, uses runspaces
```

---

> [!TIP]
> **Day 1 Focus**: Sections 1-8 (Fundamentals through Remoting)
> **Day 2 Focus**: Sections 9-15 (File ops, APIs, DSC, AD, Q&A)
> **Before Interview**: Read the Quick Revision Cheat Sheet and Q&A section

Good luck, Ashish! 🚀
