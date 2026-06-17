# Module 09 — Challenge

> **Instructions:** Replace `____` blanks. Run in PowerShell and verify against Expected Output.

---

## Challenge 1 — Log Level Dispatcher

**Scenario:** Route log lines to different handlers based on their level using `switch -Regex`.

```powershell
$logs = @(
    'ERROR: Disk full',
    'INFO: Service started',
    'WARN: High memory',
    'DEBUG: Connection opened',
    'ERROR: Auth failed'
)

switch -Regex ($logs) {
    '____' { Write-Host "[ALERT]  $_"; ____ }
    '____' { Write-Host "[NOTICE] $_"; break }
    '____' { Write-Host "[LOG]    $_"; break }
    default  { Write-Host "[SKIP]   $_" }
}
```

**Expected Output:**
```
[ALERT]  ERROR: Disk full
[LOG]    INFO: Service started
[NOTICE] WARN: High memory
[SKIP]   DEBUG: Connection opened
[ALERT]  ERROR: Auth failed
```

> **Hint:** Match `^ERROR`, `^WARN`, `^INFO`. Use `break` after each block.

---

## Challenge 2 — switch with $Matches

**Scenario:** Use `switch -Regex` with capture groups to extract error codes and messages.

```powershell
$events = @(
    'ERROR [E1042]: Disk full',
    'ERROR [E2001]: Connection refused',
    'INFO: System healthy',
    'ERROR [E9999]: Unknown error'
)

switch -Regex ($events) {
    '^ERROR \[([^\]]+)\]: (.+)$' {
        Write-Host "Code: $($Matches[____])  Message: $($Matches[____])"
        break
    }
    '^INFO: (.+)$' {
        Write-Host "Info: $($Matches[____])"
        break
    }
}
```

**Expected Output:**
```
Code: E1042  Message: Disk full
Code: E2001  Message: Connection refused
Info: System healthy
Code: E9999  Message: Unknown error
```

---

## Challenge 3 — Date Format Converter

**Scenario:** Convert dates from `YYYY-MM-DD` to `DD/MM/YYYY` using `-replace`.

```powershell
$dates = @('2025-06-15', '1999-12-31', '2000-01-01')

foreach ($d in $dates) {
    $converted = $d -replace '____', '____'
    Write-Host "$d → $converted"
}
```

**Expected Output:**
```
2025-06-15 → 15/06/2025
1999-12-31 → 31/12/1999
2000-01-01 → 01/01/2000
```

> **Hint:** Capture year, month, day as groups 1, 2, 3. In replacement: `$3/$2/$1`.

---

## Challenge 4 — Redact Sensitive Data

**Scenario:** Redact passwords from connection strings. Keep the key but replace the value.

```powershell
$connStrings = @(
    'Server=prod;User=admin;Password=SuperSecret123',
    'host=db01;pwd=P@ssw0rd!;port=5432',
    'Server=local;Password=Test123;DB=mydb'
)

foreach ($cs in $connStrings) {
    $redacted = $cs -replace '(?i)(password|pwd)=\S+', '____'
    Write-Host $redacted
}
```

**Expected Output:**
```
Server=prod;User=admin;Password=****
host=db01;pwd=****;port=5432
Server=local;Password=****;DB=mydb
```

> **Hint:** Use `$1=****` in the replacement string to keep the key name.

---

## Challenge 5 — Double Every Number

**Scenario:** Double every number found in a string using `-replace` with a script block.

```powershell
$text = 'Retry after 5 seconds, max 10 attempts, timeout 30s'

$result = $text -replace '\d+', { ____ }
Write-Host $result
```

**Expected Output:**
```
Retry after 10 seconds, max 20 attempts, timeout 60s
```

> **Hint:** In the script block, `$args[0].Value` is the matched text. Cast to int, multiply by 2, convert back to string.

---

## Challenge 6 — Split on Multiple Delimiters

**Scenario:** Parse a data line that uses `,`, `;`, or `|` as separators.

```powershell
$line = 'Alice,30;Engineer|New York,USA'

$parts = $line -split '____'

Write-Host "Parts found: $($parts.Count)"
$parts | ForEach-Object { Write-Host "  - $_" }
```

**Expected Output:**
```
Parts found: 5
  - Alice
  - 30
  - Engineer
  - New York
  - USA
```

---

## Challenge 7 — Limited Split

**Scenario:** Split a log line into exactly 3 parts: timestamp, level, and the rest of the message.

```powershell
$log = '2025-06-15 10:30:00 ERROR Disk full on C:\ drive'

$parts = $log -split '\s+', ____

Write-Host "Timestamp: $($parts[0]) $($parts[1])"
Write-Host "Level:     $($parts[2])"
Write-Host "Message:   $($parts[3])"
```

**Expected Output:**
```
Timestamp: 2025-06-15 10:30:00
Level:     ERROR
Message:   Disk full on C:\ drive
```

> **Hint:** Split into 4 parts (limit = 4) so the message stays together.

---

## Challenge 8 — Keep Delimiter in Split

**Scenario:** Split a sentence at punctuation but keep the punctuation marks in the output.

```powershell
$text = 'Hello. How are you? Fine! Great.'

$parts = $text -split '(____)'

$parts | Where-Object { $_ -ne '' } | ForEach-Object {
    Write-Host "'$_'"
}
```

**Expected Output:**
```
'Hello'
'.'
' How are you'
'?'
' Fine'
'!'
' Great'
'.'
```

> **Hint:** Use `([.!?])` — wrapping the delimiter in `()` keeps it in the results.

---

## Challenge 9 — Text Normalizer

**Scenario:** Clean up messy log lines using a pipeline of `-replace` operations.

```powershell
$messyLogs = @(
    '  ERROR :  disk   full  ',
    'WARN:memory  HIGH  ',
    '  INFO : server   started  '
)

foreach ($log in $messyLogs) {
    $clean = $log
    $clean = $clean -replace '^\s+|\s+$', ''       # trim whitespace
    $clean = $clean -replace '\s*:\s*', ': '        # normalize colon spacing
    $clean = $clean -replace '\s{2,}', ' '          # collapse multiple spaces
    Write-Host $clean
}
```

Run this as-is — no blanks. Understand each `-replace` step.

**Expected Output:**
```
ERROR: disk full
WARN: memory HIGH
INFO: server started
```

---

## Challenge 10 — Config File Processor (Mini Project)

**Scenario:** Read a config-style string. Use `switch -Regex` to classify each line (comment, blank, section header, key-value). Then build a hashtable from the key-value lines.

```powershell
$config = @"
# Database settings
[Database]
host = prod-db-01
port = 5432
name = appdb

# Web settings
[Web]
port = 8080
debug = false
"@

$lines = $config -split '\n'
$currentSection = 'General'
$settings = @{}

switch -Regex ($lines) {
    '^\s*#'             { continue }                           # skip comments
    '^\s*$'             { continue }                           # skip blank lines
    '^\[(.+)\]$'        { $currentSection = $Matches[____]; break }
    '^(\w+)\s*=\s*(.+)$' {
        $key   = "$currentSection.$($Matches[____])"
        $value = $Matches[____]
        $settings[$key] = $value
        break
    }
}

Write-Host "=== PARSED CONFIG ==="
$settings.GetEnumerator() | Sort-Object Name | ForEach-Object {
    Write-Host "$($_.Key) = $($_.Value)"
}
```

**Expected Output:**
```
=== PARSED CONFIG ===
Database.debug = false
Database.host = prod-db-01
Database.name = appdb
Database.port = 5432
Web.debug = false
Web.port = 8080
```

> **Hint:** Fill `$Matches[____]` with group numbers `1` and `2` in the right places.

---
