# Module 08 — Challenge

> **Instructions:** Replace `____` blanks. Run in PowerShell and verify against Expected Output.

---

## Challenge 1 — IsMatch vs -match

**Scenario:** Use `[regex]::IsMatch()` to validate that a string is a valid IPv4 address format.

```powershell
$inputs = @('192.168.1.1', 'hello', '10.0.0.255', '999.x.1.1', '127.0.0.1')
$pattern = '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$'

foreach ($i in $inputs) {
    if ([regex]::____($i, $pattern)) {
        Write-Host "VALID IP:   $i"
    }
    else {
        Write-Host "INVALID IP: $i"
    }
}
```

**Expected Output:**
```
VALID IP:   192.168.1.1
INVALID IP: hello
VALID IP:   10.0.0.255
INVALID IP: 999.x.1.1
VALID IP:   127.0.0.1
```

---

## Challenge 2 — Match Object Properties

**Scenario:** Find the first number in a string and print its value, position, and length.

```powershell
$text = 'Server uptime: 99.9% for 365 days'

$m = [regex]::Match($text, '\d+')

Write-Host "Value:    $($m.____)"
Write-Host "Position: $($m.____)"
Write-Host "Length:   $($m.____)"
```

**Expected Output:**
```
Value:    99
Position: 15
Length:   2
```

> **Hint:** The properties are `.Value`, `.Index`, `.Length`.

---

## Challenge 3 — Find ALL Matches

**Scenario:** Extract all numbers from a log summary line.

```powershell
$summary = 'Processed: 1523 records, 47 errors, 12 warnings in 300 seconds'

$numbers = [regex]::____($summary, '\d+')

Write-Host "Numbers found:"
foreach ($n in $numbers) {
    Write-Host "  $($n.Value)"
}
```

**Expected Output:**
```
Numbers found:
  1523
  47
  12
  300
```

> **Hint:** Use `::Matches()` (plural) to get all matches.

---

## Challenge 4 — Simple Replace

**Scenario:** Redact all numeric values in a config string.

```powershell
$config = 'port=8080 timeout=30 maxconn=500 retry=3'

$redacted = [regex]::____($config, '\d+', 'REDACTED')
Write-Host $redacted
```

**Expected Output:**
```
port=REDACTED timeout=REDACTED maxconn=REDACTED retry=REDACTED
```

---

## Challenge 5 — Replace with Capture Group Reference

**Scenario:** Convert `LastName, FirstName` format to `FirstName LastName`.

```powershell
$names = @('Smith, John', 'Doe, Jane', 'Kumar, Ashish', 'Brown, Charlie')

foreach ($name in $names) {
    $converted = $name -replace '(\w+), (\w+)', '____'
    Write-Host $converted
}
```

**Expected Output:**
```
John Smith
Jane Doe
Ashish Kumar
Charlie Brown
```

> **Hint:** Use `$2 $1` to reference the captured groups in the replacement string.

---

## Challenge 6 — Script Block Replacement

**Scenario:** Convert all words in a sentence to Title Case (first letter uppercase, rest lowercase).

```powershell
$text = 'hELLO wOrLd pOwErShElL iS aWeSoMe'

$result = [regex]::Replace($text, '\w+', {
    param($match)
    $word = $match.Value
    $word[0].ToString().ToUpper() + $word.Substring(1).____()
})

Write-Host $result
```

**Expected Output:**
```
Hello World Powershell Is Awesome
```

> **Hint:** Fill `____` with `ToLower` to lowercase the rest of the word.

---

## Challenge 7 — Split on Multiple Delimiters

**Scenario:** Split a data string that uses `,`, `;`, or `|` as delimiters.

```powershell
$data = 'Alice,Bob;Charlie|Dave,Eve;Frank'

$parts = [regex]::____($data, '[,;|]')

Write-Host "Names found:"
$parts | ForEach-Object { Write-Host "  $_" }
```

**Expected Output:**
```
Names found:
  Alice
  Bob
  Charlie
  Dave
  Eve
  Frank
```

---

## Challenge 8 — Case-Insensitive via RegexOptions

**Scenario:** Count occurrences of the word `error` (any case) in a log using `RegexOptions`.

```powershell
$log = 'Error found. ERROR again. No error here. CRITICAL Error!'

$opts = [System.Text.RegularExpressions.RegexOptions]::____

$count = [regex]::Matches($log, '\berror\b', $opts).Count
Write-Host "Total 'error' occurrences: $count"
```

**Expected Output:**
```
Total 'error' occurrences: 4
```

> **Hint:** Use `IgnoreCase` as the option.

---

## Challenge 9 — Reusable Compiled Regex Object

**Scenario:** You need to parse 1000 log lines with the same pattern. Create a compiled regex object and use it efficiently.

```powershell
# Create once — compiled for performance
$pattern = [regex]::new(
    '^(?<date>\d{4}-\d{2}-\d{2}) (?<level>\w+) (?<msg>.+)$',
    [System.Text.RegularExpressions.RegexOptions]::____
)

$logs = @(
    '2025-06-15 INFO Service started',
    '2025-06-15 ERROR Disk full',
    '2025-06-15 WARN Memory low'
)

foreach ($log in $logs) {
    $m = $pattern.Match($log)
    if ($m.Success) {
        Write-Host "[$($m.Groups['level'].Value)] $($m.Groups['msg'].Value)"
    }
}
```

**Expected Output:**
```
[INFO] Service started
[ERROR] Disk full
[WARN] Memory low
```

> **Hint:** Pass `Compiled` as the RegexOptions value.

---

## Challenge 10 — Log Analyzer (Mini Project)

**Scenario:** Analyze a log file. Find ALL error lines, extract their error codes and messages, and print a summary report.

```powershell
$log = @"
2025-06-15 10:00 INFO  System started
2025-06-15 10:05 ERROR [E1001] Disk space critical
2025-06-15 10:10 WARN  Memory at 85%
2025-06-15 10:15 ERROR [E2034] Service timeout
2025-06-15 10:20 INFO  Backup completed
2025-06-15 10:25 ERROR [E1001] Disk space critical
2025-06-15 10:30 ERROR [E9999] Unknown failure
"@

# Step 1: Find all ERROR lines
$errorPattern = '(?m)^.+ERROR \[(?<code>\w+)\] (?<msg>.+)$'
$errorMatches = [regex]::Matches($log, $errorPattern)

# Step 2: Build report
Write-Host "=== ERROR REPORT ==="
Write-Host "Total errors: $($errorMatches.____)"
Write-Host ""

foreach ($e in $errorMatches) {
    Write-Host "Code: $($e.Groups['____'].Value)  |  Message: $($e.Groups['____'].Value)"
}

# Step 3: Count unique error codes
Write-Host ""
Write-Host "=== ERROR CODE FREQUENCY ==="
$errorMatches | 
    ForEach-Object { $_.Groups['code'].Value } |
    Group-Object |
    ForEach-Object { Write-Host "$($_.Name): $($_.Count) occurrence(s)" }
```

**Expected Output:**
```
=== ERROR REPORT ===
Total errors: 4

Code: E1001  |  Message: Disk space critical
Code: E2034  |  Message: Service timeout
Code: E1001  |  Message: Disk space critical
Code: E9999  |  Message: Unknown failure

=== ERROR CODE FREQUENCY ===
E1001: 2 occurrence(s)
Code: E2034: 1 occurrence(s)
E9999: 1 occurrence(s)
```

> **Hint:** Fill `.____` with `Count` and the group names with `code` and `msg`.

---
