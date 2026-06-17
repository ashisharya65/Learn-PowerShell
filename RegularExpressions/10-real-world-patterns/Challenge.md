# Module 10 — Challenge

> **Instructions:** Replace `____` blanks. Run in PowerShell and verify against Expected Output.

---

## Challenge 1 — IP Address Validator

**Scenario:** Validate a list of strings — identify which ones are valid IPv4 format.

```powershell
$inputs = @('192.168.1.1', 'hello', '10.0.0.255', '192.168.1', '0.0.0.0', '256.1.1.1.1')

$pattern = '^\d{1,3}(?:\.\d{1,3}){____}$'

foreach ($i in $inputs) {
    if ($i -match $pattern) {
        Write-Host "VALID:   $i"
    }
    else {
        Write-Host "INVALID: $i"
    }
}
```

**Expected Output:**
```
VALID:   192.168.1.1
INVALID: hello
VALID:   10.0.0.255
INVALID: 192.168.1
VALID:   0.0.0.0
INVALID: 256.1.1.1.1
```

> **Hint:** `(?:\.\d{1,3})` repeated exactly `3` times gives 4 octets total.

---

## Challenge 2 — Extract All IPs from a Log

**Scenario:** Extract every IP address found anywhere in a block of log text.

```powershell
$log = @"
Client 192.168.1.50 connected
Request from 10.0.0.1 to 172.16.5.100
Blocked: 192.168.1.200
"@

$ipPattern = '\b\d{1,3}(?:\.\d{1,3}){3}\b'
$ips = [regex]::Matches($log, ____)

Write-Host "IPs found:"
foreach ($ip in $ips) {
    Write-Host "  $($ip.Value)"
}
```

**Expected Output:**
```
IPs found:
  192.168.1.50
  10.0.0.1
  172.16.5.100
  192.168.1.200
```

---

## Challenge 3 — Email Validator

**Scenario:** Validate email addresses from a list.

```powershell
$emails = @(
    'user@example.com',
    'first.last@company.co.uk',
    'noatsign.com',
    'user@',
    'admin+tag@mail.org',
    '@domain.com'
)

$emailPattern = '^[a-zA-Z0-9._%+\-]+____[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$'

foreach ($e in $emails) {
    if ($e -match $emailPattern) {
        Write-Host "VALID:   $e"
    }
    else {
        Write-Host "INVALID: $e"
    }
}
```

**Expected Output:**
```
VALID:   user@example.com
VALID:   first.last@company.co.uk
INVALID: noatsign.com
INVALID: user@
VALID:   admin+tag@mail.org
INVALID: @domain.com
```

> **Hint:** Fill `____` with the `@` symbol.

---

## Challenge 4 — Parse a URL into Parts

**Scenario:** Decompose a URL into its scheme, host, port, path, and query.

```powershell
$url = 'https://api.example.com:8443/v1/users?limit=10&page=2'

$url -match '^(?<scheme>https?)://(?<host>[^:/]+)(?::(?<port>\d+))?(?<path>/[^?]*)?(?:\?(?<query>.+))?$'

Write-Host "Scheme: $($Matches['____'])"
Write-Host "Host:   $($Matches['____'])"
Write-Host "Port:   $($Matches['____'])"
Write-Host "Path:   $($Matches['____'])"
Write-Host "Query:  $($Matches['____'])"
```

**Expected Output:**
```
Scheme: https
Host:   api.example.com
Port:   8443
Path:   /v1/users
Query:  limit=10&page=2
```

---

## Challenge 5 — Windows vs UNC Path Classifier

**Scenario:** Classify paths as Windows drive paths, UNC network paths, or invalid.

```powershell
$paths = @(
    'C:\Users\Admin\file.txt',
    '\\SERVER\Share\data',
    'relative\path\file',
    'D:\Data\',
    '\\192.168.1.1\backup'
)

foreach ($p in $paths) {
    if ($p -match '^[A-Za-z]:\\') {
        Write-Host "DRIVE: $p"
    }
    elseif ($p -match '^____') {
        Write-Host "UNC:   $p"
    }
    else {
        Write-Host "OTHER: $p"
    }
}
```

**Expected Output:**
```
DRIVE: C:\Users\Admin\file.txt
UNC:   \\SERVER\Share\data
OTHER: relative\path\file
DRIVE: D:\Data\
UNC:   \\192.168.1.1\backup
```

> **Hint:** UNC paths start with `\\`. Escape both backslashes: `^\\\\`.

---

## Challenge 6 — Extract Filename and Extension

**Scenario:** Extract the filename (without path) and the extension from a full path.

```powershell
$paths = @(
    'C:\Users\Admin\report.csv',
    'D:\Backups\server.bak',
    '\\Share\docs\readme.txt'
)

foreach ($p in $paths) {
    if ($p -match '____') {
        Write-Host "File: $($Matches[1])  Extension: $($Matches[2])"
    }
}
```

**Expected Output:**
```
File: report       Extension: csv
File: server       Extension: bak
File: readme       Extension: txt
```

> **Hint:** Match the last segment: `([^\\]+)\.([^.\\]+)$`

---

## Challenge 7 — ISO Date Validator

**Scenario:** Validate that dates follow `YYYY-MM-DD` format with valid month and day ranges.

```powershell
$dates = @('2025-06-15', '2025-13-01', '2025-06-32', '1999-12-31', '2000-02-30')

# Month: 01-12, Day: 01-31 (approximate)
$datePattern = '^\d{4}-(____)-(____)$'

foreach ($d in $dates) {
    if ($d -match $datePattern) {
        Write-Host "VALID:   $d"
    }
    else {
        Write-Host "INVALID: $d"
    }
}
```

**Expected Output:**
```
VALID:   2025-06-15
INVALID: 2025-13-01
INVALID: 2025-06-32
VALID:   1999-12-31
VALID:   2000-02-30
```

> **Hint:** Month = `0[1-9]|1[0-2]`, Day = `0[1-9]|[12]\d|3[01]`

---

## Challenge 8 — INI File Parser

**Scenario:** Parse an INI-style config string into a hashtable with `Section.Key = Value` structure.

```powershell
$ini = @"
[Server]
host=web-prod-01
port=443

[Database]
host=db-01
port=5432
"@

$config = @{}
$currentSection = ''

foreach ($line in ($ini -split '\n')) {
    $line = $line.Trim()
    if ($line -match '^\[(.+)\]$') {
        $currentSection = $Matches[____]
    }
    elseif ($line -match '^(\w+)=(.+)$') {
        $config["$currentSection.$($Matches[____])"] = $Matches[____]
    }
}

$config.GetEnumerator() | Sort-Object Name | ForEach-Object {
    Write-Host "$($_.Key) = $($_.Value)"
}
```

**Expected Output:**
```
Database.host = db-01
Database.port = 5432
Server.host = web-prod-01
Server.port = 443
```

---

## Challenge 9 — GUID Extractor

**Scenario:** Extract all GUIDs from a system output string.

```powershell
$sysOutput = @"
PolicyId: {A3B4C5D6-1234-5678-ABCD-000000000001}
TaskId: {FFFFFFFF-FFFF-FFFF-FFFF-000000000002}
No GUID here: random text
GroupId: {12345678-ABCD-EF01-2345-6789ABCDEF03}
"@

$guidPattern = '\{[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}\}'
$guids = [regex]::Matches($sysOutput, ____)

Write-Host "GUIDs found: $($guids.Count)"
foreach ($g in $guids) {
    Write-Host "  $($g.Value)"
}
```

**Expected Output:**
```
GUIDs found: 3
  {A3B4C5D6-1234-5678-ABCD-000000000001}
  {FFFFFFFF-FFFF-FFFF-FFFF-000000000002}
  {12345678-ABCD-EF01-2345-6789ABCDEF03}
```

---

## Challenge 10 — Security Log Audit (Mini Project)

**Scenario:** Parse a security log. Extract and report all failed login attempts with username, source IP, and timestamp.

```powershell
$secLog = @"
2025-06-15 08:01:00 INFO  User admin logged in from 10.0.0.5
2025-06-15 08:15:00 WARN  Failed login for user hacker from 192.168.1.200
2025-06-15 08:16:00 WARN  Failed login for user admin from 192.168.1.200
2025-06-15 08:30:00 INFO  User svc_account logged in from 10.0.0.1
2025-06-15 08:31:00 WARN  Failed login for user root from 203.0.113.5
2025-06-15 09:00:00 INFO  Backup started
"@

$failPattern = '^(?<ts>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) WARN\s+Failed login for user (?<user>\S+) from (?<ip>\d{1,3}(?:\.\d{1,3}){3})$'

$failures = [regex]::Matches($secLog, $failPattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)

Write-Host "=== FAILED LOGIN REPORT ==="
Write-Host "Total attempts: $($failures.Count)"
Write-Host ""

foreach ($f in $failures) {
    Write-Host "Time: $($f.Groups['____'].Value)"
    Write-Host "User: $($f.Groups['____'].Value)"
    Write-Host "From: $($f.Groups['____'].Value)"
    Write-Host ""
}

# Group by IP
Write-Host "=== ATTACKS BY IP ==="
$failures |
    ForEach-Object { $_.Groups['ip'].Value } |
    Group-Object |
    ForEach-Object { Write-Host "$($_.Name): $($_.Count) attempt(s)" }
```

**Expected Output:**
```
=== FAILED LOGIN REPORT ===
Total attempts: 3

Time: 2025-06-15 08:15:00
User: hacker
From: 192.168.1.200

Time: 2025-06-15 08:16:00
User: admin
From: 192.168.1.200

Time: 2025-06-15 08:31:00
User: root
From: 203.0.113.5

=== ATTACKS BY IP ===
192.168.1.200: 2 attempt(s)
203.0.113.5: 1 attempt(s)
```

---
