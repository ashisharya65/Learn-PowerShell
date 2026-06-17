# Module 06 — Alternation & Non-Capturing Groups

---

## 1. Alternation — The `|` Operator

The pipe `|` means **OR** in regex. It lets you match one pattern OR another.

```powershell
'cat' -match 'cat|dog'    # True — matched 'cat'
'dog' -match 'cat|dog'    # True — matched 'dog'
'bird' -match 'cat|dog'   # False — neither matched
```

Alternation applies to **everything on each side** of the `|`. That means it can be very broad:

```powershell
# This means "gray" OR "grey" — correct
'gray' -match 'gray|grey'   # True
'grey' -match 'gray|grey'   # True

# But be careful — without grouping, | has very low precedence
'I love cats' -match 'I love cats|dogs'
# Means: ("I love cats") OR ("dogs") — not "I love (cats OR dogs)"
```

---

## 2. Grouping Alternation with `()`

To control what `|` applies to, wrap the alternatives in parentheses:

```powershell
# Without grouping — ambiguous
'I love dogs' -match 'I love cats|dogs'   # True — matched "dogs"

# With grouping — clear intent
'I love dogs' -match 'I love (cats|dogs)' # True — matched "I love dogs"
'I love birds' -match 'I love (cats|dogs)' # False

$Matches[0]   # 'I love dogs'
$Matches[1]   # 'dogs'  ← the captured alternative
```

### Practical Examples

```powershell
# Match log levels
'ERROR: disk full' -match '^(INFO|WARN|ERROR|DEBUG):'
$Matches[1]   # 'ERROR'

# Match file extensions
'script.ps1' -match '\.(ps1|psm1|psd1)$'
$Matches[1]   # 'ps1'

# Match yes/no/maybe
'yes' -match '^(yes|no|maybe)$'   # True
'yep' -match '^(yes|no|maybe)$'   # False
```

---

## 3. Order Matters in Alternation

Regex tries each alternative **from left to right** and stops at the first match:

```powershell
# Shorter alternative first — can cause problems
'foreach' -match 'for|foreach'
$Matches[0]   # 'for'  ← stopped too early! 'for' matched inside 'foreach'

# Longer alternative first — correct
'foreach' -match 'foreach|for'
$Matches[0]   # 'foreach'  ← correct full match
```

> **Rule:** When alternatives overlap (one is a prefix of another), put the **longer one first**.

---

## 4. Non-Capturing Groups — `(?:pattern)`

Sometimes you need to group characters (to apply a quantifier or scope an alternation) but you do NOT want to capture the result into `$Matches`.

Use `(?:...)` — it groups without capturing.

```powershell
# Capturing group — creates $Matches[1]
'2025-06-15' -match '(\d{4})-(\d{2})-(\d{2})'
$Matches[1]   # '2025'  ← captured

# Non-capturing group — used just for grouping
'2025-06-15' -match '(?:\d{4})-(?:\d{2})-(?:\d{2})'
$Matches[1]   # empty — nothing was captured
```

### When to Use Non-Capturing Groups

1. **Applying quantifiers to a group without polluting `$Matches`:**

```powershell
# You want to repeat "ha" but don't need to capture it
'hahaha' -match '^(?:ha)+$'   # True
$Matches[1]                    # empty — no capture needed
```

2. **Scoping alternation without capturing:**

```powershell
# Match http or https, but only capture the domain
'https://example.com' -match '^(?:https?)://(.+)$'
$Matches[1]   # 'example.com'  ← only the domain, not the scheme
```

3. **Keeping group numbers clean:**

```powershell
# If you only care about group 1 being the date
# Use (?:) for groups you don't need
'ERROR 2025-06-15 Disk full' -match '^\w+ (?:(\d{4})-(\d{2})-(\d{2})) .+$'
$Matches[1]   # '2025'
$Matches[2]   # '06'
$Matches[3]   # '15'
```

---

## 5. Inline Mode Flags

You can turn on regex modes inside the pattern itself using `(?flag)`:

| Flag | What It Does |
|---|---|
| `(?i)` | Case-insensitive (even when using `-cmatch`) |
| `(?s)` | Singleline — dot matches newlines |
| `(?m)` | Multiline — `^` and `$` match each line |
| `(?x)` | Free-spacing mode — ignore whitespace and allow comments |

```powershell
# (?i) inside the pattern — makes just part case-insensitive
'PowerShell' -cmatch '(?i)powershell'   # True — (?i) overrides -cmatch

# Flags can be placed at the start or anywhere they apply from
'hello' -match '(?i)HELLO'             # True
```

### Turning Off a Flag

Add `-` before the flag letter to turn it OFF:

```powershell
'(?i)hello(?-i)WORLD'
# Case-insensitive for 'hello' part, case-sensitive for 'WORLD' part
```

---

## 6. Free-Spacing Mode — `(?x)`

Complex patterns are hard to read. The `(?x)` flag lets you add **spaces and comments** to your pattern for readability. All whitespace and `#` comments are ignored.

```powershell
# Without free-spacing — hard to read
$pattern = '^(\d{4})-(\d{2})-(\d{2})$'

# With free-spacing — easy to understand
$pattern = @'
(?x)
^
(\d{4})   # year
-
(\d{2})   # month
-
(\d{2})   # day
$
'@

'2025-06-15' -match $pattern
$Matches[1]   # '2025'
$Matches[2]   # '06'
$Matches[3]   # '15'
```

> **Note:** In free-spacing mode, if you actually need to match a literal space, use `\ ` (backslash space) or `\s`.

---

## 7. Quick Reference

```
ALTERNATION:
  cat|dog           Match 'cat' or 'dog'
  I love (cat|dog)  Group the alternatives
  Order matters!    Put longer alternatives first

NON-CAPTURING GROUPS:
  (?:pattern)   Group without capturing
  Use when you need grouping but don't need $Matches[n]

INLINE FLAGS:
  (?i)   Case-insensitive
  (?s)   Dot matches newlines
  (?m)   ^ and $ match each line
  (?x)   Free-spacing + comments
  (?-i)  Turn OFF case-insensitive

COMBINING FLAGS:
  (?im)  Multiline + case-insensitive
  (?sx)  Singleline + free-spacing

COMMON PATTERNS:
  ^(INFO|WARN|ERROR):    Match a log level at start
  \.(?:ps1|psm1|psd1)$  Match PS file extensions (non-capturing)
  (?:https?)://(.+)      Capture domain, not scheme
```
