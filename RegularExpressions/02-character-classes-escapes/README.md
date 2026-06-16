# Module 02 — Character Classes & Shorthand Escapes

---

## 1. What Is a Character Class?

A character class lets you match **any one character** from a set of characters. You write them inside square brackets `[]`.

```powershell
# Match any vowel
'hello' -match '[aeiou]'
# Result: True — matched 'e' (the first vowel found)

$Matches[0]   # 'e'
```

The key idea: `[aeiou]` means "match **one** character that is a, e, i, o, OR u."

---

## 2. Basic Character Classes

### Simple List

```powershell
# Match any one of these specific characters
'cat' -match '[cbr]at'    # True  — 'c' is in [cbr]
'bat' -match '[cbr]at'    # True  — 'b' is in [cbr]
'rat' -match '[cbr]at'    # True  — 'r' is in [cbr]
'fat' -match '[cbr]at'    # False — 'f' is NOT in [cbr]
```

### Character Ranges

Use a hyphen `-` to define a range:

```powershell
# Match any lowercase letter
'hello' -match '[a-z]'        # True

# Match any uppercase letter
'Hello' -match '[A-Z]'        # True — matched 'H'

# Match any digit
'Room 404' -match '[0-9]'     # True — matched '4'

# Multiple ranges in one class
'File_v2' -match '[a-zA-Z0-9]'  # True — matches letters and digits
```

### Common Ranges

| Range | What It Matches |
|---|---|
| `[a-z]` | Any lowercase letter |
| `[A-Z]` | Any uppercase letter |
| `[0-9]` | Any digit |
| `[a-zA-Z]` | Any letter (upper or lower) |
| `[a-zA-Z0-9]` | Any letter or digit |

---

## 3. Negated Character Classes

Put a caret `^` as the **first character** inside the brackets to negate the class. This means "match any character that is NOT in this set."

```powershell
# Match any character that is NOT a digit
'hello' -match '[^0-9]'    # True — 'h' is not a digit

# Match any character that is NOT a vowel
'xyz' -match '[^aeiou]'    # True — 'x' is not a vowel

# Match any character that is NOT a letter
'hello 123' -match '[^a-zA-Z]'  # True — matched the space ' '
$Matches[0]   # ' '
```

> **Important:** The `^` only means "not" when it is the **first character** inside `[]`. Outside brackets, `^` means "start of string" — completely different meaning!

---

## 4. Special Characters Inside Character Classes

Most metacharacters **lose their special meaning** inside `[]`. They become literal:

```powershell
# The dot is literal inside []
'file.txt' -match '[.]'     # True — matches the literal dot

# The asterisk is literal inside []
'2*3=6' -match '[*]'        # True — matches the literal *

# The plus is literal inside []
'1+2=3' -match '[+]'        # True — matches the literal +
```

### Characters That ARE Special Inside `[]`

Only these characters need special treatment inside a character class:

| Character | Rule |
|---|---|
| `]` | Escape it `\]` or put it **first**: `[]abc]` |
| `\` | Escape it: `[\\]` |
| `^` | Only special if it is the **first** character |
| `-` | Only special **between** characters. Put it first or last to make it literal: `[-abc]` or `[abc-]` |

```powershell
# Match a literal hyphen — put it first or last
'well-done' -match '[-a-z]'     # True — hyphen is literal here (it's first)
'well-done' -match '[a-z-]'     # True — hyphen is literal here (it's last)
```

---

## 5. Shorthand Character Escapes

Regex provides shortcuts for the most common character classes:

| Shorthand | Meaning | Equivalent Class |
|---|---|---|
| `\d` | Any **digit** | `[0-9]` |
| `\D` | Any **non-digit** | `[^0-9]` |
| `\w` | Any **word character** (letter, digit, underscore) | `[a-zA-Z0-9_]` |
| `\W` | Any **non-word character** | `[^a-zA-Z0-9_]` |
| `\s` | Any **whitespace** (space, tab, newline) | `[ \t\n\r\f]` |
| `\S` | Any **non-whitespace** | `[^ \t\n\r\f]` |

### Examples

```powershell
# \d — Match digits
'Order 12345' -match '\d+'
$Matches[0]   # '12345'

# \D — Match non-digits
'Order 12345' -match '\D+'
$Matches[0]   # 'Order '

# \w — Match word characters
'user_name@email.com' -match '\w+'
$Matches[0]   # 'user_name'

# \W — Match non-word characters
'hello world!' -match '\W'
$Matches[0]   # ' ' (the space)

# \s — Match whitespace
"line1`nline2" -match '\s'
$Matches[0]   # the newline character

# \S — Match non-whitespace
'  hello  ' -match '\S+'
$Matches[0]   # 'hello'
```

### Uppercase = Opposite

Easy way to remember:
- **Lowercase** (`\d`, `\w`, `\s`) = matches the character type
- **Uppercase** (`\D`, `\W`, `\S`) = matches the **opposite**

---

## 6. The Dot (`.`) — Revisited

The dot matches **any single character except newline** by default.

```powershell
'abc' -match 'a.c'        # True — dot matched 'b'
'a c' -match 'a.c'        # True — dot matched space
'a9c' -match 'a.c'        # True — dot matched '9'
"a`nc" -match 'a.c'       # False — dot does NOT match newline by default
```

### Making Dot Match Newlines Too

Use the singleline flag `(?s)` to make dot match newlines:

```powershell
"a`nc" -match '(?s)a.c'   # True — now dot matches the newline too
```

> **When to use dot:** Use `.` when you truly want "any character". If you want specific characters, use a character class like `[a-z]` or `\d` instead. Dot is too broad for most real-world patterns.

---

## 7. Unicode Category Escapes

The .NET regex engine supports Unicode categories with `\p{...}` and `\P{...}`:

| Pattern | What It Matches |
|---|---|
| `\p{L}` | Any letter (any language) |
| `\p{Lu}` | Uppercase letter |
| `\p{Ll}` | Lowercase letter |
| `\p{N}` | Any number (any script) |
| `\p{P}` | Any punctuation |
| `\p{S}` | Any symbol |
| `\p{Z}` | Any separator (spaces) |

```powershell
# Match any letter from any language
'café' -match '\p{L}+'
$Matches[0]   # 'caf' or 'café' depending on context

# Match non-ASCII letters
'über' -match '\p{L}+'
$Matches[0]   # 'über'

# Match any Unicode number
'Price: ₹500' -match '\p{N}+'
$Matches[0]   # '500'
```

The negated version uses uppercase `P`:
- `\P{L}` = any character that is NOT a letter

---

## 8. Combining Character Classes

You can combine ranges and shorthand escapes inside `[]`:

```powershell
# Letters, digits, and underscore — same as \w
'test_123' -match '[a-zA-Z0-9_]+'
$Matches[0]   # 'test_123'

# Hexadecimal characters
'Color: #FF00AA' -match '[0-9A-Fa-f]+'
$Matches[0]   # 'FF00AA'  (or 'olor' depending on position — be specific!)

# Better: anchor to get the hex code
'Color: #FF00AA' -match '#[0-9A-Fa-f]+'
$Matches[0]   # '#FF00AA'
```

---

## 9. Quick Reference

```
CHARACTER CLASSES:
  [abc]         Match a, b, or c
  [a-z]         Match any lowercase letter
  [A-Z]         Match any uppercase letter
  [0-9]         Match any digit
  [a-zA-Z0-9]   Match any letter or digit
  [^abc]        Match any character EXCEPT a, b, c
  [^0-9]        Match any non-digit

SHORTHAND ESCAPES:
  \d  digit         \D  non-digit
  \w  word char     \W  non-word char
  \s  whitespace    \S  non-whitespace

DOT:
  .       Any character except newline
  (?s).   Any character including newline

UNICODE:
  \p{L}   Any letter        \P{L}   Non-letter
  \p{N}   Any number        \P{N}   Non-number
  \p{P}   Punctuation       \p{S}   Symbol

INSIDE [] RULES:
  Most metacharacters become literal
  - is special only between characters
  ^ is special only as the first character
  ] needs escaping or put first
  \ always needs escaping
```
