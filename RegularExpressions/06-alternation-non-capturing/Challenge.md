# Module 06 — Challenge

> **Instructions:** Replace `____` blanks. Run in PowerShell and verify against Expected Output.

---

## Challenge 1 — Basic OR Match

**Scenario:** Filter a list to find only cat or dog entries.

```powershell
$animals = @('cat', 'dog', 'bird', 'catfish', 'bulldog', 'snake')

$animals -match '^(cat|____)$'
```

**Expected Output:**
```
cat
dog
```

> **Hint:** Anchor with `^` and `$` so you get exact matches only.

---

## Challenge 2 — Log Level Filter

**Scenario:** Find all lines that are either ERROR or CRITICAL level.

```powershell
$logs = @(
    'INFO: System started',
    'ERROR: Disk full',
    'WARN: High memory',
    'CRITICAL: Service down',
    'DEBUG: Connection attempt',
    'ERROR: Auth failed'
)

$critical = $logs -match '^(____):' 
$critical
```

**Expected Output:**
```
ERROR: Disk full
CRITICAL: Service down
ERROR: Auth failed
```

---

## Challenge 3 — Order of Alternatives (Fix the Bug)

**Scenario:** This pattern should match the whole word `foreach` but it matches `for` instead. Fix it.

```powershell
$keyword = 'foreach'

# BUGGY
$keyword -match 'for|foreach'
Write-Host "Buggy match: $($Matches[0])"

# FIXED — swap the order
$keyword -match '____'
Write-Host "Fixed match: $($Matches[0])"
```

**Expected Output:**
```
Buggy match: for
Fixed match: foreach
```

---

## Challenge 4 — PowerShell File Types

**Scenario:** Check if a filename is a PowerShell file (`.ps1`, `.psm1`, or `.psd1`).

```powershell
$files = @('module.psm1', 'script.ps1', 'data.csv', 'manifest.psd1', 'readme.txt', 'run.ps1x')

$psFiles = $files -match '____'
$psFiles
```

**Expected Output:**
```
module.psm1
script.ps1
manifest.psd1
```

> **Hint:** Use `\.` to escape the dot, group the extensions with `(ps1|psm1|psd1)`, and anchor with `$`.

---

## Challenge 5 — Non-Capturing Group for Quantifier

**Scenario:** Match strings that are made of repeating `"ab"` but do NOT capture the group (we only need the full match).

```powershell
$inputs = @('ababab', 'ab', 'abab', 'ba', 'aabb')

foreach ($i in $inputs) {
    if ($i -match '^(?:____)__$') {
        Write-Host "MATCH: $i  | Group 1: '$($Matches[1])'"
    }
}
```

**Expected Output:**
```
MATCH: ababab  | Group 1: ''
MATCH: ab      | Group 1: ''
MATCH: abab    | Group 1: ''
```

> **Hint:** Use `(?:ab)+` so the repetition group doesn't create `$Matches[1]`.

---

## Challenge 6 — Capture Domain, Skip Scheme

**Scenario:** Extract only the domain from a URL. The scheme (`http` or `https`) should not be captured.

```powershell
$urls = @(
    'http://example.com',
    'https://api.server.local',
    'http://192.168.1.1',
    'https://company.org'
)

foreach ($url in $urls) {
    if ($url -match '^(?:https?)://(.+)$') {
        Write-Host "Domain: $($Matches[____])"
    }
}
```

**Expected Output:**
```
Domain: example.com
Domain: api.server.local
Domain: 192.168.1.1
Domain: company.org
```

> **Hint:** `(?:https?)` is a non-capturing group — so the first real capture is `$Matches[1]`.

---

## Challenge 7 — Inline Case-Insensitive Flag

**Scenario:** Use `-cmatch` (case-sensitive) but make a specific part of the pattern case-insensitive using an inline flag.

```powershell
$inputs = @('ERROR', 'error', 'Error', 'WARN', 'warn')

foreach ($i in $inputs) {
    if ($i -cmatch '^(?i)(error|warn)$') {
        Write-Host "MATCHED (any case): $i"
    }
}
```

Run this as-is and verify all 5 match. Then explain in a comment why `-cmatch` didn't block the match.

**Expected Output:**
```
MATCHED (any case): ERROR
MATCHED (any case): error
MATCHED (any case): Error
MATCHED (any case): WARN
MATCHED (any case): warn
```

> **Answer to document:** `(?i)` inside the pattern overrides the `-cmatch` operator's case-sensitive behavior.

---

## Challenge 8 — Free-Spacing Mode

**Scenario:** Rewrite this hard-to-read pattern using `(?x)` free-spacing mode with comments.

```powershell
# Hard to read version
$pattern = '^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$'

# Rewrite using (?x) free-spacing mode
$readable = @'
(?x)
^
____   # first octet
____   # dot separator
____   # second octet
____   # dot separator
____   # third octet
____   # dot separator
____   # fourth octet
$
'@

'192.168.1.1' -match $readable
$Matches[0]
```

**Expected Output:**
```
True
192.168.1.1
```

---

## Challenge 9 — Alternate Date Formats

**Scenario:** Accept dates in multiple formats: `YYYY-MM-DD`, `MM/DD/YYYY`, or `DD.MM.YYYY`.

```powershell
$dates = @(
    '2025-06-15',
    '06/15/2025',
    '15.06.2025',
    '2025/06/15',
    'June 15 2025'
)

foreach ($d in $dates) {
    if ($d -match '^(?:\d{4}-\d{2}-\d{2}|____|\____)$') {
        Write-Host "VALID DATE:   $d"
    }
    else {
        Write-Host "INVALID DATE: $d"
    }
}
```

**Expected Output:**
```
VALID DATE:   2025-06-15
VALID DATE:   06/15/2025
VALID DATE:   15.06.2025
INVALID DATE: 2025/06/15
INVALID DATE: June 15 2025
```

---

## Challenge 10 — Config File Parser (Mini Project)

**Scenario:** Parse a config file that uses `=` or `:` as delimiters. Extract key-value pairs using non-capturing groups for the delimiter, and support both styles.

```powershell
$config = @"
server_name = web-prod-01
port: 8080
max_connections = 500
timeout: 30
environment = production
"@

$lines = $config -split "`n"

Write-Host "=== CONFIG VALUES ===`n"

foreach ($line in $lines) {
    $line = $line.Trim()
    if ($line -match '^(\w+)\s*(?:____)\s*(.+)$') {
        $key   = $Matches[1]
        $value = $Matches[2]
        Write-Host "$key => $value"
    }
}
```

**Expected Output:**
```
=== CONFIG VALUES ===

server_name => web-prod-01
port => 8080
max_connections => 500
timeout => 30
environment => production
```

> **Hint:** The delimiter is `=` or `:`. Use `(?:=|:)` as a non-capturing group so it doesn't take up a capture slot.

---

