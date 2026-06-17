# Module 03 — Challenge

---

## 1. What Is a Quantifier?

A quantifier tells regex **how many times** the previous character or group should appear.

Without a quantifier, a character matches exactly **once**. Quantifiers let you say "match this 0 times, 3 times, or as many times as possible."

```powershell
'aaa' -match 'a'      # True — matches exactly one 'a'
'aaa' -match 'a+'     # True — matches one or more 'a' (all three)
$Matches[0]           # 'aaa'
```

---

## 2. The Four Basic Quantifiers

| Quantifier | Meaning | Example Pattern | Matches |
|---|---|---|---|
| `*` | **Zero or more** | `ab*c` | ac, abc, abbc, abbbc |
| `+` | **One or more** | `ab+c` | abc, abbc (NOT ac) |
| `?` | **Zero or one** | `colou?r` | color, colour |
| `{n}` | **Exactly n times** | `\d{4}` | 1234, 2025 |
| `{n,}` | **n or more times** | `\d{2,}` | 12, 123, 1234 |
| `{n,m}` | **Between n and m times** | `\d{2,4}` | 12, 123, 1234 |

### `*` — Zero or More

```powershell
# * means the previous item can appear 0 or more times
'ac'    -match 'ab*c'   # True — 'b' appears 0 times
'abc'   -match 'ab*c'   # True — 'b' appears 1 time
'abbbc' -match 'ab*c'   # True — 'b' appears 3 times
```

### `+` — One or More

```powershell
# + means the previous item MUST appear at least once
'ac'    -match 'ab+c'   # False — 'b' must appear at least once
'abc'   -match 'ab+c'   # True  — 'b' appears 1 time
'abbbc' -match 'ab+c'   # True  — 'b' appears 3 times
```

### `?` — Zero or One (Optional)

```powershell
# ? makes the previous item optional (0 or 1 time)
'color'  -match 'colou?r'  # True — 'u' appears 0 times
'colour' -match 'colou?r'  # True — 'u' appears 1 time
'colouur' -match 'colou?r' # True — but only matches "colour" part (u? matched 1 u)
```

### `{n}` — Exact Count

```powershell
# Match exactly 4 digits
'2025'    -match '^\d{4}$'   # True
'202'     -match '^\d{4}$'   # False — only 3 digits
'20255'   -match '^\d{4}$'   # False — 5 digits
```

### `{n,}` — At Least n Times

```powershell
# Match 2 or more digits
'5'       -match '\d{2,}'    # False — only 1 digit
'55'      -match '\d{2,}'    # True
'55555'   -match '\d{2,}'    # True
```

### `{n,m}` — Between n and m Times

```powershell
# Match 2 to 4 digits
'5'       -match '^\d{2,4}$'   # False — too few
'55'      -match '^\d{2,4}$'   # True
'5555'    -match '^\d{2,4}$'   # True
'55555'   -match '^\d{2,4}$'   # False — too many
```

---

## 3. Greedy vs Lazy — The Most Important Concept

By default, all quantifiers are **greedy**. This means they try to match **as much as possible**.

### Greedy Behavior (Default)

```powershell
$text = '<b>bold</b> and <i>italic</i>'

$text -match '<.+>'
$Matches[0]
# Result: '<b>bold</b> and <i>italic</i>'
# Why? The greedy + consumed EVERYTHING between the first < and the LAST >
```

The greedy `+` kept expanding until it found the **last possible** `>` in the string.

### Lazy Behavior (Add `?` after the Quantifier)

To make a quantifier **lazy** (match as little as possible), add `?` after it:

| Greedy | Lazy | Meaning |
|---|---|---|
| `*` | `*?` | Zero or more, as **few** as possible |
| `+` | `+?` | One or more, as **few** as possible |
| `?` | `??` | Zero or one, prefer **zero** |
| `{n,m}` | `{n,m}?` | Between n and m, as **few** as possible |

```powershell
$text = '<b>bold</b> and <i>italic</i>'

$text -match '<.+?>'
$Matches[0]
# Result: '<b>'
# Why? The lazy +? stopped as soon as it found the first possible >
```

### Side by Side Comparison

```powershell
$html = '<b>hello</b>'

# GREEDY — matches as much as possible
$html -match '<.+>'
$Matches[0]   # '<b>hello</b>'  ← everything from first < to last >

# LAZY — matches as little as possible
$html -match '<.+?>'
$Matches[0]   # '<b>'  ← stops at the first >
```

---

## 4. How Backtracking Works (Simple Explanation)

When regex uses a greedy quantifier, it works in two phases:

1. **Expand phase:** The quantifier grabs as many characters as it can.
2. **Backtrack phase:** If the rest of the pattern fails, it gives back one character at a time until the full pattern succeeds.

### Example — Step by Step

```
Pattern: \d+0
String:  12300
```

1. `\d+` greedily grabs all 5 characters: `12300`
2. Now regex needs to match `0` — but there is nothing left. **Fail.**
3. Backtrack: `\d+` gives back one character. Now it holds `1230`.
4. Now regex tries `0` against `0` — **Success!**
5. Full match: `12300`

```powershell
'12300' -match '\d+0'
$Matches[0]   # '12300'
```

This backtracking process happens automatically. You do not need to code it — regex does it for you. But knowing it exists helps you understand **why greedy patterns sometimes give unexpected results**.

---

## 5. Greedy Trap — A Common Mistake

```powershell
# Goal: Extract what is inside the quotes
$text = 'Name: "Alice" and "Bob"'

# GREEDY — wrong result
$text -match '"(.+)"'
$Matches[1]   # 'Alice" and "Bob'  ← too much!

# LAZY — correct result
$text -match '"(.+?)"'
$Matches[1]   # 'Alice'  ← just the first quoted word
```

> **Rule of Thumb:** When matching content **between** two delimiters (quotes, tags, brackets), use a **lazy** quantifier `+?` or `*?` to avoid over-matching.

---

## 6. Practical Examples

### Match an IP Address Octet

```powershell
# Each octet is 1 to 3 digits
'192.168.1.1' -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
# Result: True
$Matches[0]   # '192.168.1.1'
```

### Match Optional Protocol in URL

```powershell
# https:// is optional — some URLs start with just //
'https://example.com' -match 'https?://.+'
# Result: True — 's' in https matched by s?

'http://example.com' -match 'https?://.+'
# Result: True — s? matched 0 times (s is optional)
```

### Extract Content Between Tags

```powershell
$html = '<title>My PowerShell Guide</title>'

$html -match '<title>(.+?)</title>'
$Matches[1]   # 'My PowerShell Guide'
```

### Match a Year (Exactly 4 digits)

```powershell
$dates = @('2025', '99', '10000', '1999')

$dates -match '^\d{4}$'
# Result: '2025', '1999'
```

---

## 7. Quick Reference

```
BASIC QUANTIFIERS:
  *        Zero or more (greedy)
  +        One or more (greedy)
  ?        Zero or one (greedy)
  {n}      Exactly n times
  {n,}     At least n times
  {n,m}    Between n and m times

LAZY VERSIONS (add ? after):
  *?       Zero or more (as few as possible)
  +?       One or more (as few as possible)
  ??       Zero or one (prefer zero)
  {n,m}?   Between n and m (as few as possible)

REMEMBER:
  Greedy  = grab as MUCH as possible, then give back
  Lazy    = grab as LITTLE as possible, then take more
  
  Use lazy (+? *?) when matching between delimiters
  Use greedy (+  *) when you want the full extent of a match
```
