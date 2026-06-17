# Module 07 — Lookahead & Lookbehind Assertions

---

## 1. What Are Lookaround Assertions?

Lookaround assertions are patterns that check what is **around** a position without consuming any characters. They match a **position**, not a character.

There are four types:

| Type | Syntax | Meaning |
|---|---|---|
| Positive Lookahead | `(?=pattern)` | "followed by pattern" |
| Negative Lookahead | `(?!pattern)` | "NOT followed by pattern" |
| Positive Lookbehind | `(?<=pattern)` | "preceded by pattern" |
| Negative Lookbehind | `(?<!pattern)` | "NOT preceded by pattern" |

The key idea: the text inside a lookaround **must match** (or must not match) but is NOT included in `$Matches[0]`.

---

## 2. Positive Lookahead — `(?=pattern)`

"Match this position only if what follows is `pattern`."

```powershell
# Match digits only if they are followed by 'px'
'font-size: 14px' -match '\d+(?=px)'
$Matches[0]   # '14'  — the 'px' is NOT included in the match

# Without lookahead
'font-size: 14px' -match '\d+px'
$Matches[0]   # '14px'  — 'px' IS included
```

```powershell
# Practical: Extract price numbers without the dollar sign
'Total: $59.99 each' -match '(?<=\$)\d+\.\d+'
# (see lookbehind section below for this one)

# Lookahead: get the number before USD
'Amount: 500 USD' -match '\d+(?= USD)'
$Matches[0]   # '500'
```

---

## 3. Negative Lookahead — `(?!pattern)`

"Match this position only if what follows is NOT `pattern`."

```powershell
# Match 'file' only if NOT followed by '.bak'
$files = @('file.txt', 'file.bak', 'file.log')

foreach ($f in $files) {
    if ($f -match 'file(?!\.bak)') {
        Write-Host "Not a backup: $f"
    }
}
# Output:
# Not a backup: file.txt
# Not a backup: file.log
```

```powershell
# Match a word not followed by 'ing'
'running walking talk' -match '\b\w+(?!ing)\b'
$Matches[0]   # Complex result — see practical use below

# Practical: Find user names that are not disabled (not followed by " [DISABLED]")
$users = @('alice [DISABLED]', 'bob', 'charlie [DISABLED]', 'dave')
$users -match '^(?!.*\[DISABLED\]).+'
# Result: 'bob', 'dave'
```

---

## 4. Positive Lookbehind — `(?<=pattern)`

"Match this position only if what precedes it is `pattern`."

```powershell
# Extract the number after a dollar sign, without including the $
'Price: $49.99' -match '(?<=\$)\d+\.\d+'
$Matches[0]   # '49.99'  — the '$' is NOT in the match

# Extract values after '=' signs
'port=8080' -match '(?<==)\d+'
$Matches[0]   # '8080'

# Extract the word after "Hello "
'Hello World' -match '(?<=Hello )\w+'
$Matches[0]   # 'World'
```

---

## 5. Negative Lookbehind — `(?<!pattern)`

"Match this position only if what precedes it is NOT `pattern`."

```powershell
# Match a digit NOT preceded by a dollar sign
'Items: 5, Price: $10' -match '(?<!\$)\d+'
$Matches[0]   # '5'  — the 5 is not preceded by $

# Match 'port' not preceded by 'air' (so not 'airport')
'import airport export' -match '(?<!air)\bport\b'
$Matches[0]   # Matches standalone 'port' but complex — see challenge for practical use

# Practical: Find filenames not preceded by a path separator
'backup.zip' -match '(?<![\\/])\w+\.zip'
$Matches[0]   # 'backup'
```

---

## 6. .NET's Variable-Length Lookbehind

Most regex engines require the lookbehind pattern to be a **fixed length**. The .NET engine (used by PowerShell) allows **variable-length lookbehinds** — a major advantage.

```powershell
# This works in .NET — variable-length lookbehind
'admin_password' -match '(?<=\w+_)\w+'
$Matches[0]   # 'password'

# Would FAIL in Python/JavaScript — their lookbehind requires fixed length
# Python: (?<=\w+_) would throw an error
# .NET:   Works fine!
```

---

## 7. Combining Lookarounds

You can use multiple lookarounds together:

```powershell
# Match a word that is between 'START-' and '-END'
'START-hello-END' -match '(?<=START-)\w+(?=-END)'
$Matches[0]   # 'hello'

# Validate a password: must have at least one digit AND one uppercase
$password = 'SecureP4ss'

$hasUpper  = $password -match '(?=.*[A-Z])'
$hasDigit  = $password -match '(?=.*\d)'

if ($hasUpper -and $hasDigit) {
    Write-Host "Password is strong"
}
```

```powershell
# All conditions in one pattern using multiple lookaheads
$password = 'SecureP4ss'
$password -match '^(?=.*[A-Z])(?=.*\d)(?=.*[^a-zA-Z0-9]).{8,}$'
# Checks: uppercase, digit, special char, min 8 length — all at once
```

---

## 8. Lookaround Does NOT Consume Characters

This is the crucial point. After a lookaround succeeds, the regex engine stays at the **same position** — it hasn't moved forward.

```powershell
# Each lookahead checks from the same starting position
'abc123' -match '(?=.*[a-z])(?=.*[0-9]).+'
# Both lookaheads check from position 0
# Then .+ actually consumes the whole string

$Matches[0]   # 'abc123'
```

---

## 9. Quick Reference

```
LOOKAHEAD:
  (?=pattern)   Positive — followed by pattern
  (?!pattern)   Negative — NOT followed by pattern

LOOKBEHIND:
  (?<=pattern)  Positive — preceded by pattern
  (?<!pattern)  NOT preceded by pattern

KEY RULES:
  - Lookarounds do NOT consume characters
  - They match a POSITION, not text
  - $Matches[0] will NOT include lookaround text
  - .NET allows variable-length lookbehind (unique!)

COMMON PATTERNS:
  \d+(?=px)         Number before 'px'
  (?<=\$)\d+        Number after '$'
  (?<=\bUser: )\w+  Word after 'User: '
  (?<!\.bak)$       Filename not ending in .bak

PASSWORD VALIDATION:
  (?=.*[A-Z])   Has uppercase
  (?=.*[a-z])   Has lowercase
  (?=.*\d)      Has digit
  (?=.*\W)      Has special char
  .{8,}         At least 8 characters
```
