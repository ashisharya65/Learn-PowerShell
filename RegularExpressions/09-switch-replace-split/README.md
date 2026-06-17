# Module 09 — `switch -Regex`, `-replace`, and `-split`

---

## 1. `switch -Regex` — Multi-Pattern Dispatch

The `switch` statement in PowerShell supports `-Regex` mode. Instead of exact string matches, each case becomes a regex pattern test.

### Basic Syntax

```powershell
$input = 'ERROR: disk full'

switch -Regex ($input) {
    '^ERROR'    { Write-Host "This is an error"   }
    '^WARN'     { Write-Host "This is a warning"  }
    '^INFO'     { Write-Host "This is info"       }
    default     { Write-Host "Unknown log level"  }
}
# Output: This is an error
```

### Multiple Matches — By Default ALL Match

Unlike a normal `switch`, with `-Regex` **all matching cases execute** unless you use `break`:

```powershell
$text = 'ERROR: critical failure'

switch -Regex ($text) {
    'ERROR'     { Write-Host "Matched: ERROR pattern" }
    'critical'  { Write-Host "Matched: critical pattern" }
    'failure'   { Write-Host "Matched: failure pattern" }
}
# All three match! Output:
# Matched: ERROR pattern
# Matched: critical pattern
# Matched: failure pattern
```

Use `break` to stop after the first match:

```powershell
switch -Regex ($text) {
    '^ERROR'    { Write-Host "Error found"; break }
    '^WARN'     { Write-Host "Warning found"; break }
    default     { Write-Host "Other" }
}
# Output: Error found
```

### Processing Multiple Lines with switch

```powershell
$logs = @(
    'ERROR: disk full',
    'INFO: server started',
    'WARN: high memory',
    'ERROR: auth failed'
)

switch -Regex ($logs) {
    '^ERROR' { Write-Host "⚠️  ERROR — $_" }
    '^WARN'  { Write-Host "⚡ WARN  — $_" }
    '^INFO'  { Write-Host "ℹ️  INFO  — $_" }
}
```

Inside the block, `$_` is the current item being tested.

### Using `$Matches` in switch

```powershell
switch -Regex ($logs) {
    '^(ERROR|WARN): (.+)$' {
        Write-Host "Level: $($Matches[1]) | Msg: $($Matches[2])"
    }
}
```

---

## 2. `-replace` Operator

The `-replace` operator replaces text matching a regex pattern with a replacement string.

### Basic Replacement

```powershell
'Hello World' -replace 'World', 'PowerShell'
# Result: 'Hello PowerShell'

# Replace ALL occurrences (not just first — unlike some languages)
'aababba' -replace 'a', 'X'
# Result: 'XXbXbbX'
```

### Using Capture Groups in Replacement

In the replacement string, `$1`, `$2`, etc. refer to captured groups:

```powershell
# Reformat date from YYYY-MM-DD to DD/MM/YYYY
'2025-06-15' -replace '(\d{4})-(\d{2})-(\d{2})', '$3/$2/$1'
# Result: '15/06/2025'

# Swap first and last name
'Smith, John' -replace '(\w+), (\w+)', '$2 $1'
# Result: 'John Smith'
```

### Using Named Groups in Replacement

```powershell
'2025-06-15' -replace '(?<y>\d{4})-(?<m>\d{2})-(?<d>\d{2})', '${d}/${m}/${y}'
# Result: '15/06/2025'
```

### Case-Sensitive Replace

```powershell
# -replace is case-insensitive by default
'Hello HELLO hello' -replace 'hello', 'HI'
# Result: 'HI HI HI'  — all three replaced

# Use -creplace for case-sensitive
'Hello HELLO hello' -creplace 'hello', 'HI'
# Result: 'Hello HELLO HI'  — only lowercase 'hello' replaced
```

### `-replace` with Script Block (PowerShell 6+)

Pass a script block to transform each match:

```powershell
# Double every number in a string
'port 80 and 443' -replace '\d+', { [int]$args[0].Value * 2 }
# Result: 'port 160 and 886'

# Convert to uppercase
'hello world' -replace '\w+', { $args[0].Value.ToUpper() }
# Result: 'HELLO WORLD'
```

---

## 3. `-split` Operator

Split a string into an array using a regex as the delimiter.

### Basic Split

```powershell
# Split on one or more whitespace characters
'hello   world  PowerShell' -split '\s+'
# Result: @('hello', 'world', 'PowerShell')

# Split on comma or semicolon
'a,b;c,d' -split '[,;]'
# Result: @('a', 'b', 'c', 'd')
```

### Limiting the Number of Splits

Add a number as the third argument to limit splits:

```powershell
# Split into at most 2 parts
'one:two:three:four' -split ':', 2
# Result: @('one', 'two:three:four')
```

### Keeping the Delimiter (Capture Groups)

If your delimiter pattern has a capture group, the delimiter is **kept** in the results:

```powershell
# Without capture group — delimiter disappears
'one,two,three' -split ','
# Result: @('one', 'two', 'three')

# With capture group — delimiter is kept
'one,two,three' -split '(,)'
# Result: @('one', ',', 'two', ',', 'three')
```

### Case-Sensitive Split

```powershell
'aAbBaAbB' -split 'a'     # Case-insensitive — splits on A and a
'aAbBaAbB' -csplit 'a'    # Case-sensitive — splits only on lowercase a
```

---

## 4. Combining in Pipelines

```powershell
# Read a file, filter errors, extract messages, clean up
Get-Content .\app.log |
    Where-Object { $_ -match '^ERROR' } |
    ForEach-Object { $_ -replace '^ERROR: ', '' } |
    Sort-Object -Unique
```

```powershell
# Parse CSV-like data with split, then match
$data = 'user:admin,role:owner,status:active'

$data -split ',' |
    Where-Object { $_ -match '^status:(.+)' } |
    ForEach-Object { $Matches[1] }
# Result: 'active'
```

---

## 5. Quick Reference

```
switch -Regex ($var) {
    'pattern1' { action1 }
    'pattern2' { action2; break }
    default    { fallback }
}
# $_ = current item, $Matches = capture groups

-replace:
  'text' -replace 'pattern', 'replacement'
  'text' -replace 'pattern', '$1 $2'      # capture groups
  'text' -replace 'pattern', '${name}'    # named groups
  'text' -replace 'pattern', { block }    # script block
  'text' -creplace 'pattern', 'rep'       # case-sensitive

-split:
  'text' -split 'pattern'                 # basic split
  'text' -split 'pattern', n             # limit to n parts
  'text' -split '(pattern)'              # keep delimiter
  'text' -csplit 'pattern'               # case-sensitive

CAPTURE GROUP REFS IN REPLACEMENT:
  $1, $2, $3      Numbered groups
  ${name}         Named groups
  $0              Entire match
```
