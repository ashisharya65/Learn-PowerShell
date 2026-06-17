# Module 04 — Anchors, Boundaries & Multiline Mode

---

## 1. What Are Anchors?

Anchors do not match any character. They match a **position** in the string — like "the start" or "the end."

They help you say: "the pattern must appear at the beginning" or "the pattern must appear at the end" — not just anywhere in the string.

---

## 2. `^` — Start of String

`^` matches the **position at the very beginning** of a string.

```powershell
'Hello World' -match '^Hello'    # True  — 'Hello' is at the start
'Say Hello'   -match '^Hello'    # False — 'Hello' is NOT at the start

# Without ^ the pattern matches anywhere
'Say Hello'   -match 'Hello'     # True — found anywhere in the string
```

---

## 3. `$` — End of String

`$` matches the **position at the very end** of a string.

```powershell
'error.log'  -match '\.log$'    # True  — '.log' is at the end
'logfile.txt' -match '\.log$'   # False — '.log' is NOT at the end

# Common use: validate file extension
$file = 'report.csv'
$file -match '\.csv$'           # True
```

---

## 4. Using `^` and `$` Together

When you use both together, you force the pattern to match the **entire string** — not just a part of it.

```powershell
# Without anchors — partial match is fine
'abc123' -match '\d+'     # True — found digits somewhere inside

# With anchors — entire string must be digits
'abc123' -match '^\d+$'   # False — has letters before the digits
'123456' -match '^\d+$'   # True  — entire string is digits
```

This is the most common way to **validate** input (email format, phone number, etc.)

---

## 5. `\A` and `\Z` / `\z` — Absolute Anchors

In .NET regex, these are stricter versions of `^` and `$`:

| Anchor | Meaning |
|---|---|
| `\A` | Absolute start of the string (ignores multiline mode) |
| `\Z` | End of string, but allows an optional final newline |
| `\z` | Absolute end of string — no exceptions |

```powershell
# \A — always means start of the whole string
"line1`nline2" -match '\Aline1'   # True  — line1 is at the very start
"line1`nline2" -match '\Aline2'   # False — line2 is NOT at the absolute start

# \z — must be the absolute end (no trailing newline allowed)
"hello`n" -match 'hello\z'    # False — there is a newline after hello
"hello"   -match 'hello\z'    # True
```

> **When to use `\A` and `\z`:** When processing multiline text and you want to anchor to the entire string regardless of multiline mode. In normal single-string usage, `^` and `$` work fine.

---

## 6. `\b` — Word Boundary

`\b` matches the **boundary between a word character (`\w`) and a non-word character (`\W`)**. In simple terms — it matches the edge of a word.

```powershell
# Match the word 'cat' only as a whole word
'the cat sat' -match '\bcat\b'    # True  — 'cat' is a standalone word
'catch'       -match '\bcat\b'    # False — 'cat' is part of 'catch'
'tomcat'      -match '\bcat\b'    # False — 'cat' is at the end of 'tomcat'

# Without \b — matches inside words too
'catch'  -match 'cat'    # True — matched inside 'catch'
'tomcat' -match 'cat'    # True — matched inside 'tomcat'
```

### Word Boundary Positions

`\b` fires at these positions:
- Between a word character and the **start of the string**
- Between a word character and the **end of the string**
- Between a word character and a **non-word character** (space, dot, comma, etc.)

```powershell
# Find the exact word 'error' in log lines (not 'errors' or 'terrible')
$logs = @('1 error found', '5 errors found', 'terrible issue', 'error: disk full')

$logs -match '\berror\b'
# Result: '1 error found', 'error: disk full'
```

---

## 7. `\B` — Non-Word Boundary

`\B` is the **opposite of `\b`** — it matches a position that is NOT a word boundary (i.e., inside a word).

```powershell
# Match 'cat' only when it is INSIDE a larger word
'catch'       -match '\Bcat\B'    # False — need characters on both sides inside
'concatenate' -match '\Bcat\B'    # True  — 'cat' is surrounded by word chars

# Match 'pass' only inside a word (not standalone)
'password'  -match '\Bpass\B'    # True  — inside 'password'
'pass'      -match '\Bpass\B'    # False — standalone word
```

---

## 8. Multiline Mode — `(?m)`

By default, `^` and `$` match the **start and end of the entire string**. With multiline mode `(?m)`, they match the start and end of **each line**.

```powershell
$text = @"
ERROR: Disk full
INFO: Server running
ERROR: Network down
"@

# Without multiline — ^ matches only the start of the whole string
[regex]::Matches($text, '^ERROR.+') | ForEach-Object { $_.Value }
# Result: only 'ERROR: Disk full' (only the first line starts the string)

# With multiline (?m) — ^ matches start of EACH line
[regex]::Matches($text, '(?m)^ERROR.+') | ForEach-Object { $_.Value }
# Result:
# ERROR: Disk full
# ERROR: Network down
```

---

## 9. Singleline Mode — `(?s)`

By default, `.` does NOT match newline characters. With singleline mode `(?s)`, `.` matches **everything including newlines**.

```powershell
$text = "Start`nMiddle`nEnd"

# Default — dot does not cross newlines
$text -match 'Start.+End'      # False — dot can't match newline

# Singleline mode — dot matches everything
$text -match '(?s)Start.+End'  # True
$Matches[0]                     # "Start`nMiddle`nEnd"
```

---

## 10. Combining Modes

You can combine flags:

```powershell
# (?ms) = multiline AND singleline together
# (?im) = case-insensitive AND multiline
$text -match '(?im)^error.+'
```

---

## 11. Quick Reference

```
ANCHORS:
  ^       Start of string (or line in (?m) mode)
  $       End of string (or line in (?m) mode)
  \A      Absolute start of string (ignores (?m))
  \Z      End of string, allows trailing newline
  \z      Absolute end of string

WORD BOUNDARIES:
  \b      Boundary between word and non-word character
  \B      NOT a word boundary (inside a word)

FLAGS (inline):
  (?m)    Multiline — ^ and $ match each line
  (?s)    Singleline — . matches newlines too
  (?i)    Case-insensitive
  (?ms)   Combine: multiline + singleline

COMMON PATTERNS:
  ^\d+$         Entire string is digits
  ^\s*$         Empty or whitespace-only line
  \bword\b      Match whole word only
  (?m)^ERROR    Match lines starting with ERROR
```
