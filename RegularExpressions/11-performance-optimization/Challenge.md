# Module 11 — Challenge

> **Instructions:** Replace `____` blanks. Run in PowerShell and verify against Expected Output.

---

## Challenge 1 — Spot the Missing Anchor Bug

**Scenario:** This validation function always returns `$true` even for invalid input. Find and fix it.

```powershell
function Test-IsDigitsOnly {
    param($input)
    return $input -match '\d+'
}

# BUGGY: These should be False but return True
Test-IsDigitsOnly '123abc'   # Should be False
Test-IsDigitsOnly 'abc456'   # Should be False
Test-IsDigitsOnly '12 34'    # Should be False

# Fix the pattern by adding anchors:
function Test-IsDigitsOnly-Fixed {
    param($input)
    return $input -match '____'
}

Test-IsDigitsOnly-Fixed '123456'  # True
Test-IsDigitsOnly-Fixed '123abc'  # False
Test-IsDigitsOnly-Fixed 'abc456'  # False
```

**Expected Output:**
```
True
False
False
```

---

## Challenge 2 — Fix the Dot Trap

**Scenario:** This pattern should only match proper IP-format strings but it matches invalid ones. Fix it.

```powershell
$pattern = '192.168.1.1'   # BUGGY — dot matches any character

# These all return True (wrong!):
'192.168.1.1' -match $pattern   # True — correct
'192X168X1X1' -match $pattern   # True — WRONG

# Fix the pattern:
$fixedPattern = '____'

'192.168.1.1' -match $fixedPattern   # Should be True
'192X168X1X1' -match $fixedPattern   # Should be False
```

**Expected Output:**
```
True
False
```

---

## Challenge 3 — Greedy vs Negated Class

**Scenario:** Compare performance and correctness of three approaches to match content inside double quotes.

```powershell
$text = '"first" and "second" and "third"'

# Approach 1: Greedy (gets last to last)
$text -match '"(.+)"'
Write-Host "Greedy:        '$($Matches[1])'"

# Approach 2: Lazy (correct but slower)
$text -match '"(.+?)"'
Write-Host "Lazy:          '$($Matches[1])'"

# Approach 3: Negated class (correct AND fastest)
$text -match '"([____]*)"'
Write-Host "Negated class: '$($Matches[1])'"
```

**Expected Output:**
```
Greedy:        'first" and "second" and "third'
Lazy:          'first'
Negated class: 'first'
```

> **Hint:** The negated class should match anything that is NOT a double quote.

---

## Challenge 4 — Benchmark Two Patterns

**Scenario:** Measure the performance difference between a safe and a risky pattern.

```powershell
$safeInput  = 'a' * 15             # 15 a's — matches
$riskyInput = 'a' * 15 + 'b'      # 15 a's + b — near miss (no match)

# Safe pattern
$safe = Measure-Command {
    1..500 | ForEach-Object { $riskyInput -match '^____$' }
} | Select-Object -ExpandProperty TotalMilliseconds

# Risky pattern (catastrophic backtracking)
$risky = Measure-Command {
    1..____| ForEach-Object { $riskyInput -match '^(a+)+$' }
} | Select-Object -ExpandProperty TotalMilliseconds

Write-Host "Safe pattern:  ${safe}ms for 500 runs"
Write-Host "Risky pattern: ${risky}ms for 500 runs"
```

Fill `____` in the safe pattern with `a+` and the second `____` with `5` (use a small number for risky — it may be very slow!).

> **Note:** The risky time will be dramatically higher. That's the point!

---

## Challenge 5 — Fix the $Matches Trust Bug

**Scenario:** This code prints wrong error codes. Fix it by checking the match result first.

```powershell
$lines = @(
    'WARN: High memory',
    'ERROR 5001: Disk full',
    'INFO: All good',
    'ERROR 9999: Unknown'
)

# BUGGY:
foreach ($line in $lines) {
    $line -match 'ERROR (\d+)'   # result not checked!
    Write-Host "Error code: $($Matches[1])"
}

# FIXED:
foreach ($line in $lines) {
    if ($line ____ 'ERROR (\d+)') {
        Write-Host "Error code: $($Matches[1])"
    }
    else {
        Write-Host "No error in: $line"
    }
}
```

**Expected Output (Fixed):**
```
No error in: WARN: High memory
Error code: 5001
No error in: INFO: All good
Error code: 9999
```

---

## Challenge 6 — Choose the Right Tool

**Scenario:** For each task below, decide: use Regex or use a simpler string method?

```powershell
$filename = 'report_2025.csv'
$logLine  = 'ERROR: Something failed'
$json     = '{"name":"Alice","age":30}'

# Task 1: Does filename end with .csv?
# Simpler method:
$filename.____('.csv')   # Fill with the right method name

# Task 2: Does logLine start with ERROR?
# Simpler method:
$logLine.____('ERROR')

# Task 3: Does logLine contain the word 'failed'?
# Simpler method:
$logLine.____('failed')    # Case-sensitive

# Task 4: Parse the JSON name field
# Use proper tool:
($json | ConvertFrom-Json).____
```

**Expected Output:**
```
True
True
True
Alice
```

> **Hint:** Methods are `EndsWith`, `StartsWith`, `Contains`. JSON field access is just `.name`.

---

## Challenge 7 — Rewrite Slow Pattern as Fast Pattern

**Scenario:** Rewrite each problematic pattern to be safe and fast.

```powershell
# Pattern 1: Extract content between ( and )
# Slow:    \((.+)\)
# Rewrite: \(([^)]*)\)

$text = 'function(arg1, arg2) and another(test)'
$text -match '\(([^)]*)\)'
Write-Host "Fast match: $($Matches[1])"

# Pattern 2: Extract content between < and >
# Slow:    <(.+?)>
# Rewrite using negated class:
$html = '<b>bold</b>'
$html -match '<([____]*)>'
Write-Host "Tag match: $($Matches[1])"

# Pattern 3: Match quoted string
# Slow:    "(.+?)"
# Rewrite:
$s = '"hello world"'
$s -match '"([____]*)"'
Write-Host "Quoted: $($Matches[1])"
```

**Expected Output:**
```
Fast match: arg1, arg2
Tag match: b
Quoted: hello world
```

> **Hint:** Use `[^>]` and `[^"]` as negated classes.

---

## Challenge 8 — Compiled Regex Benchmark

**Scenario:** Benchmark compiled vs non-compiled regex over many iterations.

```powershell
$pattern = '(?<date>\d{4}-\d{2}-\d{2}) (?<level>\w+)'
$testLine = '2025-06-15 ERROR Disk full'
$iterations = 10000

# Non-compiled
$time1 = Measure-Command {
    1..$iterations | ForEach-Object {
        $testLine -match $pattern
    }
} | Select-Object -ExpandProperty TotalMilliseconds

# Compiled
$rx = [regex]::new($pattern, [System.Text.RegularExpressions.RegexOptions]::____)
$time2 = Measure-Command {
    1..$iterations | ForEach-Object {
        $rx.IsMatch($testLine)
    }
} | Select-Object -ExpandProperty TotalMilliseconds

Write-Host "Non-compiled: ${time1}ms"
Write-Host "Compiled:     ${time2}ms"
Write-Host "Compiled is faster: $($time2 -lt $time1)"
```

> **Hint:** The RegexOptions value is `Compiled`.

---

## Challenge 9 — Case Sensitivity Trap

**Scenario:** Fix this security check that incorrectly allows ADMIN access.

```powershell
# BUGGY — allows 'ADMIN', 'Admin', 'admin' all through
function Test-IsAdmin {
    param($username)
    # Supposed to be case-sensitive (only lowercase 'admin' blocked)
    return $username -match '^admin$'
}

Test-IsAdmin 'ADMIN'   # Should be False (not blocked)
Test-IsAdmin 'admin'   # Should be True (blocked)
Test-IsAdmin 'Admin'   # Should be False

# FIXED — use case-sensitive operator
function Test-IsAdmin-Fixed {
    param($username)
    return $username ____ '^admin$'
}

Write-Host "ADMIN blocked: $(Test-IsAdmin-Fixed 'ADMIN')"
Write-Host "admin blocked: $(Test-IsAdmin-Fixed 'admin')"
Write-Host "Admin blocked: $(Test-IsAdmin-Fixed 'Admin')"
```

**Expected Output:**
```
ADMIN blocked: False
admin blocked: True
Admin blocked: False
```

---

## Challenge 10 — Pattern Audit (Mini Project)

**Scenario:** You are auditing a set of patterns written by a junior developer. Identify and fix ALL the bugs (wrong/missing anchors, dot traps, greedy traps, case assumptions).

```powershell
# ORIGINAL BUGGY PATTERNS — fix each one:

# Bug 1: Should validate entire string is a phone: 555-123-4567
$buggy1 = '\d{3}-\d{3}-\d{4}'
$fixed1 = '____'

# Bug 2: Should match literal file.txt only (not fileXtxt)
$buggy2 = 'file.txt'
$fixed2 = '____'

# Bug 3: Should extract first quoted value — not everything to last quote
$buggy3 = '"(.+)"'
$fixed3 = '"([^"]*)"'   # This one is done as an example

# Bug 4: Should ONLY match exact word "error" (not "errors" or "terrored")
$buggy4 = 'error'
$fixed4 = '____'

# Bug 5: Should be case-sensitive match for "Root"
$buggy5_test = 'ROOT' -match '^Root$'     # WRONG — returns True
$fixed5_test  = 'ROOT' ____ '^Root$'      # Fill operator

# Test all fixes:
Write-Host "Bug 1 fixed: $('555-123-4567' -match $fixed1 -and '555-123' -notmatch $fixed1)"
Write-Host "Bug 2 fixed: $('file.txt' -match $fixed2 -and 'fileXtxt' -notmatch $fixed2)"
Write-Host "Bug 4 fixed: $('error found' -match $fixed4 -and 'errors found' -notmatch $fixed4)"
Write-Host "Bug 5 fixed: $('ROOT' -cnotmatch '^Root$' -and 'Root' -cmatch '^Root$')"
```

**Expected Output:**
```
Bug 1 fixed: True
Bug 2 fixed: True
Bug 4 fixed: True
Bug 5 fixed: True
```

---
