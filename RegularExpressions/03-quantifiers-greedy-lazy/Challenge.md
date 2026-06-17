# Module 03 — Quantifiers: Greedy & Lazy

> **Instructions:** Replace `____` blanks with the correct pattern. Run in PowerShell and verify against Expected Output.

---

## Challenge 1 — Optional Character

**Scenario:** Match both American spelling `color` and British spelling `colour`.

```powershell
$words = @('color', 'colour', 'colouur', 'clr')

$words -match '^colou____r$'
```

**Expected Output:**
```
color
colour
```

> **Hint:** `?` makes the previous character optional (0 or 1 time). Anchor with `^` and `$`.

---

## Challenge 2 — Year Validator

**Scenario:** Validate that a string is exactly a 4-digit year.

```powershell
$inputs = @('2025', '99', '10000', '1999', 'abcd', '202')

foreach ($input in $inputs) {
    if ($input -match '^____$') {
        Write-Host "VALID YEAR:   $input"
    }
    else {
        Write-Host "INVALID YEAR: $input"
    }
}
```

**Expected Output:**
```
VALID YEAR:   2025
INVALID YEAR: 99
INVALID YEAR: 10000
VALID YEAR:   1999
INVALID YEAR: abcd
INVALID YEAR: 202
```

> **Hint:** Use `\d{4}` to match exactly 4 digits.

---

## Challenge 3 — Port Number Range

**Scenario:** A valid port number is 1 to 5 digits long. Match strings that are valid port numbers.

```powershell
$ports = @('80', '8080', '65535', '0', '123456', '443')

foreach ($p in $ports) {
    if ($p -match '^____$') {
        Write-Host "VALID PORT:   $p"
    }
    else {
        Write-Host "INVALID PORT: $p"
    }
}
```

**Expected Output:**
```
VALID PORT:   80
VALID PORT:   8080
VALID PORT:   65535
VALID PORT:   0
INVALID PORT: 123456
VALID PORT:   443
```

> **Hint:** Use `\d{1,5}` for 1 to 5 digits.

---

## Challenge 4 — Greedy vs Lazy (Spot the Difference)

**Scenario:** You are extracting the content inside HTML tags. Run both versions and observe the difference.

```powershell
$html = '<b>bold text</b> and <i>italic</i>'

# Version A — Greedy
$html -match '<(.+)>'
Write-Host "Greedy match: $($Matches[1])"

# Version B — Lazy
$html -match '<(.____?)>'
Write-Host "Lazy match:   $($Matches[1])"
```

**Expected Output:**
```
Greedy match: b>bold text</b> and <i>italic</i
Lazy match:   b
```

Fill in the `____` to make Version B lazy.

---

## Challenge 5 — Fix the Greedy Bug

**Scenario:** This script should extract each quoted name individually. But the greedy pattern is broken — fix it.

```powershell
$text = 'Users: "Alice", "Bob", "Charlie"'

# BUGGY — Greedy, extracts too much
# $text -match '"(.+)"'
# $Matches[1]  →  'Alice", "Bob", "Charlie'  ← WRONG

# FIX: Use a lazy quantifier
$text -match '"(____)"'
$Matches[1]
```

**Expected Output:**
```
Alice
```

---

## Challenge 6 — One or More Words

**Scenario:** Extract the first "word" (letters only, no spaces or symbols) from a messy string.

```powershell
$strings = @(
    '  hello world',
    '123abc test',
    'PowerShell rocks!'
)

foreach ($s in $strings) {
    if ($s -match '[a-zA-Z]____') {
        Write-Host "First word chars: $($Matches[0])"
    }
}
```

**Expected Output:**
```
First word chars: hello
First word chars: abc
First word chars: PowerShell
```

> **Hint:** `[a-zA-Z]+` matches one or more letters.

---

## Challenge 7 — Zero or More Spaces

**Scenario:** Match a key-value pair where there may or may not be spaces around the `=` sign.

```powershell
$configs = @(
    'name=Alice',
    'name = Bob',
    'name  =  Charlie',
    'name:Dave'
)

foreach ($config in $configs) {
    if ($config -match '^(\w+)\s____=\s____(\w+)$') {
        Write-Host "Key: $($Matches[1])  Value: $($Matches[2])"
    }
    else {
        Write-Host "NO MATCH: $config"
    }
}
```

**Expected Output:**
```
Key: name  Value: Alice
Key: name  Value: Bob
Key: name  Value: Charlie
NO MATCH: name:Dave
```

> **Hint:** `\s*` means "zero or more whitespace characters".

---

## Challenge 8 — Extract All HTML Tags

**Scenario:** Use `[regex]::Matches()` to extract ALL tags from an HTML string (not just the first one).

```powershell
$html = '<html><head><title>Test</title></head><body><p>Hello</p></body></html>'

$pattern = '<____?>'   # Use lazy to match each tag individually

$tags = [regex]::Matches($html, $pattern)

foreach ($tag in $tags) {
    Write-Host $tag.Value
}
```

**Expected Output:**
```
<html>
<head>
<title>
</title>
</head>
<body>
<p>
</p>
</body>
</html>
```

---

## Challenge 9 — Flexible Date Format

**Scenario:** Match dates that can have 1 or 2 digit days and months (e.g., `1/5/2025` or `01/05/2025`).

```powershell
$dates = @('1/5/2025', '01/05/2025', '12/31/2025', '1/1/25', '2025-01-01')

foreach ($d in $dates) {
    if ($d -match '^____/____/\d{4}$') {
        Write-Host "VALID DATE: $d"
    }
    else {
        Write-Host "NO MATCH:   $d"
    }
}
```

**Expected Output:**
```
VALID DATE: 1/5/2025
VALID DATE: 01/05/2025
VALID DATE: 12/31/2025
NO MATCH:   1/1/25
NO MATCH:   2025-01-01
```

> **Hint:** `\d{1,2}` matches 1 or 2 digits.

---

## Challenge 10 — Log Line Parser (Mini Project)

**Scenario:** Parse log lines that may or may not have an optional error code. Extract the timestamp, log level, and optional error code.

```powershell
$logs = @(
    '2025-06-15 10:00:00 INFO Service started',
    '2025-06-15 10:05:30 ERROR [E1042] Disk full',
    '2025-06-15 10:10:00 WARN Low memory',
    '2025-06-15 10:15:00 ERROR [E2001] Connection refused'
)

foreach ($log in $logs) {
    # Pattern: timestamp, level, optional [Exxxx] error code
    if ($log -match '^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) (\w+)( \[____\])____(.+)$') {
        $timestamp = $Matches[1]
        $level     = $Matches[2]
        $errorCode = if ($Matches[3]) { $Matches[3].Trim() } else { 'None' }
        $message   = $Matches[4].Trim()

        Write-Host "Time:    $timestamp"
        Write-Host "Level:   $level"
        Write-Host "ErrCode: $errorCode"
        Write-Host "Message: $message"
        Write-Host ""
    }
}
```

**Expected Output:**
```
Time:    2025-06-15 10:00:00
Level:   INFO
ErrCode: None
Message: Service started

Time:    2025-06-15 10:05:30
Level:   ERROR
ErrCode: [E1042]
Message: Disk full

Time:    2025-06-15 10:10:00
Level:   WARN
ErrCode: None
Message: Low memory

Time:    2025-06-15 10:15:00
Level:   ERROR
ErrCode: [E2001]
Message: Connection refused
```

> **Hint:** The error code group is optional — use `?` after the group. The code inside is like `E\d{4}`.

---

