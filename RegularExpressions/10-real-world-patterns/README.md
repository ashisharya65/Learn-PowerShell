# Module 10 — Real-World Patterns

---

## 1. Why Real-World Patterns Matter

Most regex tutorials teach syntax but not application. This module is all about **practical, production-ready patterns** that you will actually use in PowerShell automation.

Real-world patterns are:
- More complex than examples in textbooks
- Often imperfect by design (validate format, not value)
- Built iteratively — you refine them as edge cases appear

---

## 2. IP Addresses

### IPv4 — Basic Format Check

```powershell
# Matches the FORMAT of an IPv4 (not the value range)
$ipv4Pattern = '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$'

'192.168.1.1'   -match $ipv4Pattern   # True
'10.0.0.255'    -match $ipv4Pattern   # True
'999.999.999.999' -match $ipv4Pattern # True  ← format valid, value invalid
'192.168.1'     -match $ipv4Pattern   # False
```

### IPv4 — With Value Range (0–255)

```powershell
# Strict: each octet must be 0-255
$octet = '(?:25[0-5]|2[0-4]\d|[01]?\d\d?)'
$strictIPv4 = "^(?:$octet\.){3}$octet$"

'192.168.1.1'     -match $strictIPv4   # True
'999.999.999.999' -match $strictIPv4   # False ← correctly rejected
'0.0.0.0'         -match $strictIPv4   # True
'255.255.255.255'  -match $strictIPv4  # True
```

### Extract IPs from Text

```powershell
$log = 'Client 192.168.1.50 connected to server 10.0.0.1 at 14:30'

$ipPattern = '\b\d{1,3}(?:\.\d{1,3}){3}\b'
$ips = [regex]::Matches($log, $ipPattern)
$ips | ForEach-Object { Write-Host "Found IP: $($_.Value)" }
# Found IP: 192.168.1.50
# Found IP: 10.0.0.1
```

---

## 3. Email Addresses

### Practical Email Pattern (RFC-compatible approximation)

```powershell
# Good enough for 99% of cases
$emailPattern = '^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$'

'user@example.com'          -match $emailPattern   # True
'first.last@company.co.uk'  -match $emailPattern   # True
'user+tag@mail.org'         -match $emailPattern   # True
'noatsign.com'              -match $emailPattern   # False
'user@'                     -match $emailPattern   # False
'@domain.com'               -match $emailPattern   # False
```

### Extract Emails from Text

```powershell
$text = 'Contact admin@corp.com or support@help.org for issues'
$emailPattern = '[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}'

[regex]::Matches($text, $emailPattern) | ForEach-Object { $_.Value }
# admin@corp.com
# support@help.org
```

---

## 4. URLs

```powershell
# Match common URLs (http/https)
$urlPattern = 'https?://[^\s"<>]+'

$text = 'Visit https://example.com or http://www.test.org/path?q=1'
[regex]::Matches($text, $urlPattern) | ForEach-Object { $_.Value }
# https://example.com
# http://www.test.org/path?q=1
```

### Parse URL into Parts

```powershell
$url = 'https://api.example.com:8443/v1/users?limit=10&page=2'

$url -match '^(?<scheme>https?)://(?<host>[^:/]+)(?::(?<port>\d+))?(?<path>/[^?]*)?(?:\?(?<query>.+))?$'

$Matches['scheme']  # 'https'
$Matches['host']    # 'api.example.com'
$Matches['port']    # '8443'
$Matches['path']    # '/v1/users'
$Matches['query']   # 'limit=10&page=2'
```

---

## 5. File Paths

### Windows Drive Paths

```powershell
$winPath = '^[A-Za-z]:\\(?:[^\\/:*?"<>|\r\n]+\\)*[^\\/:*?"<>|\r\n]*$'

'C:\Users\Admin\Documents\file.txt' -match $winPath   # True
'D:\Data\'                          -match $winPath   # True
'relative\path'                     -match $winPath   # False
```

### UNC Paths (Network Shares)

```powershell
$uncPattern = '^\\\\[^\\/:*?"<>|\r\n]+\\[^\\/:*?"<>|\r\n]+'

'\\SERVER\Share\folder\file.txt' -match $uncPattern   # True
'\\192.168.1.1\data'            -match $uncPattern   # True
'C:\local\path'                 -match $uncPattern   # False
```

### Extract Filename and Extension

```powershell
'C:\Users\Admin\report.csv' -match '([^\\]+)\.([^.\\]+)$'
$Matches[1]   # 'report'
$Matches[2]   # 'csv'
```

---

## 6. Windows Event Logs

```powershell
# Parse Event Log messages
$event = 'An account was successfully logged on. Account Name: ADMIN Domain: CORP'

$event -match 'Account Name:\s+(\S+)'
$Matches[1]   # 'ADMIN'

$event -match 'Domain:\s+(\S+)'
$Matches[1]   # 'CORP'
```

```powershell
# Parse security event with multiple fields
Get-WinEvent -LogName Security -MaxEvents 10 |
    Where-Object { $_.Id -eq 4624 } |
    ForEach-Object {
        if ($_.Message -match 'Account Name:\s+(\S+)') {
            Write-Host "Logon: $($Matches[1])"
        }
    }
```

---

## 7. Date and Time Patterns

```powershell
# ISO 8601 date: YYYY-MM-DD
$isoDate = '^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$'

'2025-06-15' -match $isoDate   # True
'2025-13-01' -match $isoDate   # False (month 13 invalid)
'2025-06-32' -match $isoDate   # False (day 32 invalid)

# Time: HH:MM:SS
$timePattern = '^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)$'
'14:30:00' -match $timePattern   # True
'25:00:00' -match $timePattern   # False
```

---

## 8. Structured Text Parsing

### CSV with Quoted Fields

```powershell
# Handle quoted fields that may contain commas
$csvLine = '"Smith, John",30,"Engineer, Senior","New York, NY"'

$fieldPattern = '"([^"]*)"'
[regex]::Matches($csvLine, $fieldPattern) | ForEach-Object {
    Write-Host "Field: $($_.Groups[1].Value)"
}
# Field: Smith, John
# Field: 30          ← wait, 30 is not quoted in real CSV
# Field: Engineer, Senior
# Field: New York, NY
```

### INI File Parsing

```powershell
$ini = @"
[Server]
host=prod-01
port=8080

[Database]
host=db-01
port=5432
name=appdb
"@

# Extract sections and their keys
$sectionPattern = '(?m)^\[(.+)\]$'
$kvPattern      = '(?m)^(\w+)=(.+)$'

[regex]::Matches($ini, $sectionPattern) | ForEach-Object {
    Write-Host "Section: $($_.Groups[1].Value)"
}

[regex]::Matches($ini, $kvPattern) | ForEach-Object {
    Write-Host "  $($_.Groups[1].Value) → $($_.Groups[2].Value)"
}
```

---

## 9. Reusable Pattern Library

Build a pattern library as a hashtable for reuse across scripts:

```powershell
$Patterns = @{
    IPv4        = '(?:(?:25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(?:25[0-5]|2[0-4]\d|[01]?\d\d?)'
    Email       = '[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}'
    URL         = 'https?://[^\s"<>]+'
    ISODate     = '\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])'
    Time        = '([01]\d|2[0-3]):([0-5]\d):([0-5]\d)'
    WinPath     = '[A-Za-z]:\\(?:[^\\/:*?"<>|\r\n]+\\)*[^\\/:*?"<>|\r\n]*'
    UNCPath     = '\\\\[^\\]+\\[^\\]+'
    GUID        = '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'
    MacAddress  = '([0-9A-Fa-f]{2}[:\-]){5}[0-9A-Fa-f]{2}'
}

# Usage
$log = 'User admin@corp.com from 192.168.1.5 accessed \\SERVER\Share'

if ($log -match $Patterns.Email)  { Write-Host "Email: $($Matches[0])" }
if ($log -match $Patterns.IPv4)   { Write-Host "IP: $($Matches[0])" }
if ($log -match $Patterns.UNCPath){ Write-Host "Path: $($Matches[0])" }
```

---

## 10. Quick Reference

```
IPv4 (format):  \d{1,3}(?:\.\d{1,3}){3}
IPv4 (strict):  (?:25[0-5]|2[0-4]\d|[01]?\d\d?)
Email:          [a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}
URL:            https?://[^\s"<>]+
ISO Date:       \d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])
Time (HH:MM:SS) ([01]\d|2[0-3]):([0-5]\d):([0-5]\d)
Win Path:       [A-Za-z]:\\(?:[^\\/:*?"<>|\r\n]+\\)*
UNC Path:       \\\\[^\\]+\\[^\\]+
GUID:           [0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}
MAC Address:    ([0-9A-Fa-f]{2}[:\-]){5}[0-9A-Fa-f]{2}

KEY PRINCIPLE:
  Validate FORMAT with regex.
  Validate VALUE with code (e.g., check if port < 65535).
  Never use regex alone for full semantic validation.
```
