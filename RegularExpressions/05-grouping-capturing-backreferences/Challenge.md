# Module 05 — Challenge

> **Instructions:** Replace `____` blanks. Run in PowerShell and verify against Expected Output.

---

## Challenge 1 — Group + Quantifier

**Scenario:** Match a string made of repeating `"ab"` pairs (like `ababab`).

```powershell
$inputs = @('ab', 'ababab', 'abab', 'aabb', 'ba')

foreach ($i in $inputs) {
    if ($i -match '^(____)____$') {
        Write-Host "MATCH: $i"
    }
    else {
        Write-Host "NO MATCH: $i"
    }
}
```

**Expected Output:**
```
MATCH: ab
MATCH: ababab
MATCH: abab
NO MATCH: aabb
NO MATCH: ba
```

> **Hint:** Group `ab` with `()` and apply `+` to it. Anchor with `^` and `$`.

---

## Challenge 2 — Extract Three Fields

**Scenario:** Parse a CSV-like line and extract three fields into separate variables.

```powershell
$line = 'john.doe@company.com,John Doe,Administrator'

$line -match '^(____),(____),(____)'

$email = $Matches[1]
$name  = $Matches[2]
$role  = $Matches[3]

Write-Host "Email: $email"
Write-Host "Name:  $name"
Write-Host "Role:  $role"
```

**Expected Output:**
```
Email: john.doe@company.com
Name:  John Doe
Role:  Administrator
```

---

## Challenge 3 — Named Capture Groups

**Scenario:** Parse a log entry using named groups so the code is easy to read.

```powershell
$log = '2025-06-15 10:30:00 ERROR Service crashed'

$log -match '^(?<____>\d{4}-\d{2}-\d{2}) (?<____>\d{2}:\d{2}:\d{2}) (?<____>\w+) (?<____>.+)$'

Write-Host "Date:    $($Matches['date'])"
Write-Host "Time:    $($Matches['time'])"
Write-Host "Level:   $($Matches['level'])"
Write-Host "Message: $($Matches['message'])"
```

**Expected Output:**
```
Date:    2025-06-15
Time:    10:30:00
Level:   ERROR
Message: Service crashed
```

> **Hint:** Replace each `____` with the group name: `date`, `time`, `level`, `message`.

---

## Challenge 4 — Find Duplicate Words

**Scenario:** Detect lines that have a repeated word (like `"the the"`).

```powershell
$sentences = @(
    'the the quick brown fox',
    'hello world',
    'error error found',
    'PowerShell is great',
    'this this is odd'
)

foreach ($s in $sentences) {
    if ($s -match '\b(____) ____\b') {
        Write-Host "DUPLICATE WORD '$($Matches[1])' in: $s"
    }
}
```

**Expected Output:**
```
DUPLICATE WORD 'the' in: the the quick brown fox
DUPLICATE WORD 'error' in: error error found
DUPLICATE WORD 'this' in: this this is odd
```

> **Hint:** Capture a word with `(\w+)`, then use `\1` to backreference it.

---

## Challenge 5 — Validate Matching HTML Tags

**Scenario:** Check if an HTML snippet has matching open and close tags.

```powershell
$snippets = @(
    '<b>bold text</b>',
    '<b>bold text</i>',
    '<title>My Page</title>',
    '<div>content</span>',
    '<p>paragraph</p>'
)

foreach ($s in $snippets) {
    if ($s -match '<(______)>.+</______>') {
        Write-Host "VALID:   $s"
    }
    else {
        Write-Host "INVALID: $s"
    }
}
```

**Expected Output:**
```
VALID:   <b>bold text</b>
INVALID: <b>bold text</i>
VALID:   <title>My Page</title>
INVALID: <div>content</span>
VALID:   <p>paragraph</p>
```

> **Hint:** Capture the tag name in group 1 with `(\w+)`, then use `\1` in the closing tag.

---

## Challenge 6 — IP Address with Named Parts

**Scenario:** Parse an IP address and extract each octet by name.

```powershell
$ip = '192.168.10.55'

$ip -match '^(?<a>\d{1,3})\.(?<b>\d{1,3})\.(?<c>\d{1,3})\.(?<d>\d{1,3})$'

Write-Host "First Octet:  $($Matches['____'])"
Write-Host "Second Octet: $($Matches['____'])"
Write-Host "Third Octet:  $($Matches['____'])"
Write-Host "Fourth Octet: $($Matches['____'])"
```

**Expected Output:**
```
First Octet:  192
Second Octet: 168
Third Octet:  10
Fourth Octet: 55
```

---

## Challenge 7 — Nested Group Numbering

**Scenario:** Understand which group number maps to which part of the match.

```powershell
$date = '2025-06-15'

$date -match '((\d{4})-(\d{2})-(\d{2}))'

# Fill in what each group returns
Write-Host "Group 0: $($Matches[0])"   # ____
Write-Host "Group 1: $($Matches[1])"   # ____
Write-Host "Group 2: $($Matches[2])"   # ____
Write-Host "Group 3: $($Matches[3])"   # ____
Write-Host "Group 4: $($Matches[4])"   # ____
```

**Expected Output:**
```
Group 0: 2025-06-15
Group 1: 2025-06-15
Group 2: 2025
Group 3: 06
Group 4: 15
```

---

## Challenge 8 — Optional Group

**Scenario:** Parse a URL that may or may not have a port number.

```powershell
$urls = @(
    'http://server.local:8080',
    'http://server.local',
    'https://api.example.com:443',
    'https://example.com'
)

foreach ($url in $urls) {
    if ($url -match '^(https?)://([^:/]+)(?::(\d+))?$') {
        $scheme = $Matches[1]
        $host   = $Matches[2]
        $port   = if ($Matches[3]) { $Matches[3] } else { 'default' }
        Write-Host "Scheme: $scheme | Host: $host | Port: $port"
    }
}
```

**Expected Output:**
```
Scheme: http  | Host: server.local | Port: 8080
Scheme: http  | Host: server.local | Port: default
Scheme: https | Host: api.example.com | Port: 443
Scheme: https | Host: example.com | Port: default
```

This one has no blanks — just run it and understand how `(?:(\d+))?` makes the port optional.

---

## Challenge 9 — Named Backreference

**Scenario:** Validate that an XML tag's opening and closing names match, using a named backreference.

```powershell
$tags = @(
    '<config>value</config>',
    '<name>Alice</title>',
    '<server>WEB-01</server>',
    '<port>8080</ports>'
)

foreach ($t in $tags) {
    if ($t -match '<(?<tag>\w+)>.+</\k<____>>') {
        Write-Host "VALID:   $t"
    }
    else {
        Write-Host "INVALID: $t"
    }
}
```

**Expected Output:**
```
VALID:   <config>value</config>
INVALID: <name>Alice</title>
VALID:   <server>WEB-01</server>
INVALID: <port>8080</ports>
```

> **Hint:** Use `\k<tag>` to refer back to the named group `tag`.

---

## Challenge 10 — Structured Log Parser (Mini Project)

**Scenario:** Parse a log file where each line has format:
`[TIMESTAMP] [LEVEL] [SOURCE] MESSAGE`

Extract all fields using named captures and build a report.

```powershell
$logs = @(
    '[2025-06-15 10:00:00] [INFO] [AuthService] User logged in: admin',
    '[2025-06-15 10:05:00] [ERROR] [DiskService] Disk full: C:\ only 2GB left',
    '[2025-06-15 10:10:00] [WARN] [MemService] Memory at 92%',
    '[2025-06-15 10:15:00] [ERROR] [NetService] Connection timeout after 30s'
)

$pattern = '^\[(?<timestamp>[^\]]+)\] \[(?<level>[^\]]+)\] \[(?<source>[^\]]+)\] (?<message>.+)$'

Write-Host "=== PARSED LOG REPORT ===`n"

foreach ($log in $logs) {
    if ($log -match $pattern) {
        Write-Host "Timestamp : $($Matches['____'])"
        Write-Host "Level     : $($Matches['____'])"
        Write-Host "Source    : $($Matches['____'])"
        Write-Host "Message   : $($Matches['____'])"
        Write-Host ""
    }
}
```

**Expected Output:**
```
=== PARSED LOG REPORT ===

Timestamp : 2025-06-15 10:00:00
Level     : INFO
Source    : AuthService
Message   : User logged in: admin

Timestamp : 2025-06-15 10:05:00
Level     : ERROR
Source    : DiskService
Message   : Disk full: C:\ only 2GB left

Timestamp : 2025-06-15 10:10:00
Level     : WARN
Source    : MemService
Message   : Memory at 92%

Timestamp : 2025-06-15 10:15:00
Level     : ERROR
Source    : NetService
Message   : Connection timeout after 30s
```

---
