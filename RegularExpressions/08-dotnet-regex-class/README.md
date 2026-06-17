# Module 08 — The `[regex]` .NET Class

---

## 1. Why Use the `[regex]` Class Directly?

The `-match` operator is convenient but limited:
- It only finds the **first** match
- It gives you results through `$Matches` (a side effect)
- It doesn't support advanced options like compiled patterns

The `[regex]` .NET class gives you full control:
- Find **all** matches at once
- Get match position and length
- Use `Replace` with script block logic
- Set options like `Compiled`, `Multiline`, `IgnoreCase` explicitly

---

## 2. `[regex]::IsMatch()` — Simple True/False

The simplest method — just checks if a pattern matches. Same as `-match` but explicit.

```powershell
[regex]::IsMatch('hello world', 'world')    # True
[regex]::IsMatch('hello world', '^world')   # False

# Useful in conditions
if ([regex]::IsMatch($input, '^\d{4}$')) {
    Write-Host "Valid 4-digit code"
}
```

---

## 3. `[regex]::Match()` — First Match Object

Returns a **Match object** for the first match. The match object has properties you can use.

```powershell
$m = [regex]::Match('Error 404: Not Found', 'Error (\d+)')

$m.Success     # True
$m.Value       # 'Error 404'       — the full match
$m.Index       # 0                 — position in the string
$m.Length      # 9                 — how many characters matched
$m.Groups[1]   # '404'             — first capture group
```

### Match Object Properties

| Property | What It Contains |
|---|---|
| `.Success` | `True` if something matched |
| `.Value` | The matched text |
| `.Index` | Starting position (0-based) |
| `.Length` | Number of characters matched |
| `.Groups[0]` | Same as `.Value` (full match) |
| `.Groups[1]` | First capture group |
| `.Groups['name']` | Named capture group |

---

## 4. `[regex]::Matches()` — All Matches

This is the big difference from `-match`. It returns **all** matches, not just the first.

```powershell
$text = 'Errors: 404, 500, 503, 200'

$allMatches = [regex]::Matches($text, '\d+')

foreach ($m in $allMatches) {
    Write-Host "Found: $($m.Value) at position $($m.Index)"
}
# Output:
# Found: 404 at position 8
# Found: 500 at position 13
# Found: 503 at position 18
# Found: 200 at position 23
```

### Comparing `-match` vs `[regex]::Matches()`

```powershell
$text = 'cats dogs birds cats'

# -match — finds only the FIRST occurrence
$text -match 'cats'
$Matches[0]   # 'cats'  ← just the first one

# [regex]::Matches() — finds ALL occurrences
$allMatches = [regex]::Matches($text, 'cats')
$allMatches.Count    # 2
$allMatches[0].Index # 0  (first 'cats')
$allMatches[1].Index # 16 (second 'cats')
```

---

## 5. `[regex]::Replace()` — Find and Replace

Replace matched text with a string or the result of a script block.

### Simple Replacement

```powershell
# Replace all digits with #
[regex]::Replace('Phone: 555-1234', '\d', '#')
# Result: 'Phone: ###-####'

# Same as -replace operator
'Phone: 555-1234' -replace '\d', '#'
# Same result
```

### Replacement with Capture Groups

```powershell
# Swap first and last name
[regex]::Replace('Smith, John', '(\w+), (\w+)', '$2 $1')
# Result: 'John Smith'

# Same with -replace
'Smith, John' -replace '(\w+), (\w+)', '$2 $1'
```

### Replacement with Script Block (PowerShell 6+)

The real power: pass a script block to transform each match:

```powershell
# Convert all words to uppercase
$result = [regex]::Replace('hello world', '\w+', { $args[0].Value.ToUpper() })
$result   # 'HELLO WORLD'

# Convert hex color codes to uppercase
$css = 'color: #ff0000; background: #a3b4c5'
$result = [regex]::Replace($css, '#[0-9a-f]+', { $args[0].Value.ToUpper() })
$result   # 'color: #FF0000; background: #A3B4C5'
```

---

## 6. `[regex]::Split()` — Split on a Pattern

Split a string using a regex pattern as the delimiter.

```powershell
# Split on one or more spaces
[regex]::Split('hello   world   PowerShell', '\s+')
# Result: @('hello', 'world', 'PowerShell')

# Split on comma OR semicolon
[regex]::Split('a,b;c,d;e', '[,;]')
# Result: @('a', 'b', 'c', 'd', 'e')
```

Compared to `-split`:
```powershell
# -split operator does the same
'hello   world' -split '\s+'
# @('hello', 'world')
```

---

## 7. RegexOptions — Setting Flags

When using the `[regex]` class directly, you can pass options explicitly:

```powershell
# Using RegexOptions
$options = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase

[regex]::IsMatch('HELLO', 'hello', $options)   # True

# Multiple options combined with -bor
$opts = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor
        [System.Text.RegularExpressions.RegexOptions]::Multiline

[regex]::Matches($text, '^error', $opts)
```

### Common RegexOptions

| Option | What It Does |
|---|---|
| `IgnoreCase` | Case-insensitive matching |
| `Multiline` | `^` and `$` match each line |
| `Singleline` | `.` matches newlines |
| `IgnorePatternWhitespace` | Free-spacing mode (like `(?x)`) |
| `Compiled` | Compiles the pattern for faster repeated use |
| `ExplicitCapture` | Only named groups capture |

---

## 8. Creating a Reusable `[regex]` Object

If you use the same pattern many times, create a regex object once:

```powershell
# Create once
$ipPattern = [regex]::new('(?<octet>\d{1,3}\.){3}\d{1,3}',
    [System.Text.RegularExpressions.RegexOptions]::Compiled)

# Reuse many times — faster than recreating the pattern each time
$logLines | ForEach-Object {
    if ($ipPattern.IsMatch($_)) {
        $ipPattern.Match($_).Value
    }
}
```

---

## 9. Quick Reference

```
[regex]::IsMatch(string, pattern)          → True/False
[regex]::Match(string, pattern)            → First Match object
[regex]::Matches(string, pattern)          → All Match objects
[regex]::Replace(string, pattern, replace) → Replaced string
[regex]::Replace(string, pattern, {block}) → Script block replacement
[regex]::Split(string, pattern)            → Array of parts
[regex]::Escape(string)                    → Escaped pattern

MATCH OBJECT:
  .Success      True/False
  .Value        Matched text
  .Index        Start position (0-based)
  .Length       Character count
  .Groups[n]    Capture group n
  .Groups['name'] Named group

REGEX OPTIONS:
  IgnoreCase              Case-insensitive
  Multiline               ^ $ per line
  Singleline              . matches newline
  Compiled                Faster repeated use
  IgnorePatternWhitespace Free-spacing (?x)

CREATE REUSABLE:
  $rx = [regex]::new($pattern, $options)
  $rx.IsMatch($text)
  $rx.Matches($text)
```
