# Module 04 — Challenge

> **Instructions:** Replace `____` blanks with the correct pattern. Run in PowerShell and verify against Expected Output.

---

## Challenge 1 — Starts With Check

**Scenario:** From a list of server names, find all that start with `WEB`.

```powershell
$servers = @('WEB-01', 'DB-01', 'WEB-PROD', 'APP-02', 'WEBAPP-01')

$webServers = $servers -match '____'
$webServers
```

**Expected Output:**
```
WEB-01
WEB-PROD
```

> **Hint:** Use `^` to anchor the match to the start. `WEBAPP-01` should NOT match.

---

## Challenge 2 — File Extension Validator

**Scenario:** Filter only PowerShell script files (`.ps1`) from a file list.

```powershell
$files = @('script.ps1', 'data.csv', 'module.ps1', 'ps1backup.txt', 'run.ps1x')

$psFiles = $files -match '____'
$psFiles
```

**Expected Output:**
```
script.ps1
module.ps1
run.ps1
```

> **Hint:** Use `$` to anchor to the end. `ps1backup.txt` and `run.ps1x` should NOT match. Also remember to escape the dot.

---

## Challenge 3 — Exact String Validation

**Scenario:** Validate that a string is ONLY digits — no letters, no spaces, nothing else.

```powershell
$inputs = @('123456', '123 456', '12abc', '000', '9')

foreach ($i in $inputs) {
    if ($i -match '____') {
        Write-Host "VALID:   $i"
    }
    else {
        Write-Host "INVALID: $i"
    }
}
```

**Expected Output:**
```
VALID:   123456
INVALID: 123 456
INVALID: 12abc
VALID:   000
VALID:   9
```

---

## Challenge 4 — Whole Word Match

**Scenario:** Find log lines that contain the exact word `error` — not `errors`, not `terrible`.

```powershell
$logs = @(
    'An error occurred',
    'Multiple errors found',
    'This is terrible',
    'error: disk full',
    'No errors today',
    'Critical error!'
)

$errorLogs = $logs -match '____'
$errorLogs
```

**Expected Output:**
```
An error occurred
error: disk full
Critical error!
```

> **Hint:** Use `\b` on both sides of `error`.

---

## Challenge 5 — Word Inside a Larger Word

**Scenario:** Find strings where `port` appears inside a larger word (not as a standalone word).

```powershell
$words = @('import', 'port', 'transport', 'export', 'portal', 'the port', 'support')

$words -match '\B____\B'
```

**Expected Output:**
```
import
transport
export
support
```

> **Hint:** `\B` is a non-word boundary — use it to match only when `port` is inside a larger word. `portal` won't match because `port` starts at a word boundary there.

---

## Challenge 6 — Multiline Line Starter

**Scenario:** From a multi-line log, extract all lines that start with `ERROR`.

```powershell
$log = @"
INFO: System started
ERROR: Disk full on C:\
WARN: Memory usage high
ERROR: Service timeout
INFO: Backup complete
"@

$matches = [regex]::Matches($log, '____')
foreach ($m in $matches) {
    Write-Host $m.Value
}
```

**Expected Output:**
```
ERROR: Disk full on C:\
ERROR: Service timeout
```

> **Hint:** Use `(?m)` to enable multiline mode so `^` matches the start of each line.

---

## Challenge 7 — Whole Line Must Be Empty

**Scenario:** Count how many empty or whitespace-only lines are in a multiline string.

```powershell
$text = @"
Line one
   
Line three

Line five
  
"@

$emptyLines = [regex]::Matches($text, '(?m)^____$')
Write-Host "Empty/whitespace lines found: $($emptyLines.Count)"
```

**Expected Output:**
```
Empty/whitespace lines found: 3
```

> **Hint:** `^\s*$` matches a line with only whitespace (or nothing).

---

## Challenge 8 — Singleline Dot Fix

**Scenario:** You want to extract everything between `<START>` and `<END>` tags, but the content spans multiple lines.

```powershell
$text = @"
<START>
This is the
multiline content
<END>
"@

# Version A — does NOT work (default mode)
$text -match '<START>(.+)<END>'
Write-Host "Default: $($Matches[1])"

# Version B — fill in the flag to make it work
$text -match '____<START>(____)<END>'
Write-Host "Fixed:   $($Matches[1])"
```

**Expected Output:**
```
Default: 
Fixed:   
This is the
multiline content

```

> **Hint:** Use `(?s)` to make `.` match newlines.

---

## Challenge 9 — Validate Username Format

**Scenario:** A valid username must:
- Start with a letter
- Contain only letters, digits, and underscores
- End with a letter or digit (not underscore)

```powershell
$usernames = @('john_doe', '_admin', 'user123', 'bad_', 'a', 'valid_user_1', '123user')

foreach ($u in $usernames) {
    if ($u -match '^____$') {
        Write-Host "VALID:   $u"
    }
    else {
        Write-Host "INVALID: $u"
    }
}
```

**Expected Output:**
```
VALID:   john_doe
INVALID: _admin
VALID:   user123
INVALID: bad_
VALID:   a
VALID:   valid_user_1
INVALID: 123user
```

> **Hint:** Start with `[a-zA-Z]`, middle with `[a-zA-Z0-9_]*`, end with `[a-zA-Z0-9]`. But handle single-char case!

---

## Challenge 10 — Log Report Builder (Mini Project)

**Scenario:** Parse a multiline log file. Count lines per log level (INFO, WARN, ERROR) and list all ERROR messages.

```powershell
$log = @"
2025-06-15 INFO Service started
2025-06-15 ERROR Disk full
2025-06-15 WARN Memory at 80%
2025-06-15 INFO Backup started
2025-06-15 ERROR Connection refused
2025-06-15 WARN CPU spike detected
2025-06-15 ERROR Auth failed
"@

# Count each level
$infoCount  = ([regex]::Matches($log, '(?m)^\d{4}-\d{2}-\d{2} ____')).Count
$warnCount  = ([regex]::Matches($log, '(?m)^\d{4}-\d{2}-\d{2} ____')).Count
$errorCount = ([regex]::Matches($log, '(?m)^\d{4}-\d{2}-\d{2} ____')).Count

Write-Host "=== LOG SUMMARY ==="
Write-Host "INFO:  $infoCount"
Write-Host "WARN:  $warnCount"
Write-Host "ERROR: $errorCount"
Write-Host ""

# List all ERROR messages
Write-Host "=== ERRORS ==="
$errors = [regex]::Matches($log, '(?m)^.+\bERROR\b (.+)$')
foreach ($e in $errors) {
    Write-Host "  >> $($e.Groups[1].Value)"
}
```

**Expected Output:**
```
=== LOG SUMMARY ===
INFO:  2
WARN:  2
ERROR: 3

=== ERRORS ===
  >> Disk full
  >> Connection refused
  >> Auth failed
```

---
