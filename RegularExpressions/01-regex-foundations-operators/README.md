# Module 01 — Notes: Regex Foundations & PowerShell Operators

---

## 1. What Is a Regular Expression?

A regular expression (regex) is a **pattern** used to search, match, and manipulate text.

Think of it like a search tool — but much more powerful than a simple "Find" (Ctrl+F). With regex, you can search for patterns like "any 3 digits followed by a hyphen" instead of searching for exact text.

PowerShell uses the **.NET regex engine**, which is one of the most powerful regex engines in the world.

### Where Do We Use Regex?

- Searching inside log files for errors
- Validating user input (emails, phone numbers, IP addresses)
- Extracting data from text (pulling dates, numbers, names)
- Replacing text in bulk
- Splitting strings on complex separators

---

## 2. Literal Matching

Literal matching means the pattern matches **exactly what you type**. No magic, no special behavior.

```powershell
'The Server is running' -match 'Server'
# Result: True
# Why: The word "Server" exists in the string exactly as written.

'Hello World' -match 'World'
# Result: True

'Hello World' -match 'Goodbye'
# Result: False
# Why: "Goodbye" does not exist in the string.
```

---

## 3. Metacharacters — Characters With Special Meaning

There are **14 special characters** in regex. They do NOT match themselves — they have special behavior:

```
.  ^  $  *  +  ?  {  }  [  ]  (  )  |  \
```

Here is what each one does:

| Character | What It Does | Simple Example |
|---|---|---|
| `.` | Matches **any single character** | `c.t` matches cat, cot, c9t |
| `^` | Matches the **start** of the string | `^Hello` matches "Hello World" |
| `$` | Matches the **end** of the string | `World$` matches "Hello World" |
| `*` | Previous character appears **zero or more** times | `ab*c` matches ac, abc, abbc |
| `+` | Previous character appears **one or more** times | `ab+c` matches abc, abbc (NOT ac) |
| `?` | Previous character appears **zero or one** time | `colou?r` matches color, colour |
| `\` | Makes the next special character **literal** | `\.` matches an actual dot |
| `\|` | Means **OR** | `cat\|dog` matches cat or dog |
| `()` | **Groups** characters together | `(ab)+` matches ab, abab, ababab |
| `[]` | Matches **any one character** from the list | `[aeiou]` matches any vowel |
| `{}` | Specifies **exact number** of repetitions | `a{3}` matches aaa |

### The Dot (`.`) — Most Common Metacharacter

The dot matches **any single character** except a newline:

```powershell
'cat' -match 'c.t'     # True  — dot matched 'a'
'cot' -match 'c.t'     # True  — dot matched 'o'
'c9t' -match 'c.t'     # True  — dot matched '9'
'ct'  -match 'c.t'     # False — dot NEEDS exactly one character
'cart' -match 'c.t'    # False — 'ar' is two characters, dot matches only one
```

> **Remember:** The dot always matches exactly **one** character. Not zero, not two — exactly one.

---

## 4. PowerShell Regex Operators

### 4.1 — `-match` (Default, Case-Insensitive)

The `-match` operator checks if a string contains the pattern. It returns `True` or `False`.

```powershell
'Hello World' -match 'hello'
# Result: True
# Why: -match ignores case by default. 'hello' matches 'Hello'.
```

After a successful match, PowerShell fills the `$Matches` variable (explained in Section 5).

### 4.2 — `-notmatch` (Opposite of -match)

Returns `True` when the pattern is **NOT found**:

```powershell
'Hello World' -notmatch 'Goodbye'
# Result: True — "Goodbye" was not found

'Hello World' -notmatch 'Hello'
# Result: False — "Hello" was found, so NOT-match is False
```

### 4.3 — `-cmatch` (Case-Sensitive Match)

The "c" stands for **case-sensitive**. It checks case strictly:

```powershell
'Hello' -cmatch 'hello'
# Result: False — lowercase 'h' does not match uppercase 'H'

'Hello' -cmatch 'Hello'
# Result: True — exact case match

'PowerShell' -cmatch 'powershell'
# Result: False
```

### 4.4 — `-imatch` (Case-Insensitive Match, Explicit)

This is the same as `-match`. It just makes the case-insensitive behavior **explicit**:

```powershell
'Hello' -imatch 'hello'
# Result: True — same as -match

'POWERSHELL' -imatch 'powershell'
# Result: True
```

### Summary Table

| Operator | Case Behavior | With String | With Array |
|---|---|---|---|
| `-match` | Ignores case | Returns True/False | Returns matching items |
| `-notmatch` | Ignores case | Returns True/False | Returns non-matching items |
| `-cmatch` | Checks case | Returns True/False | Returns matching items |
| `-imatch` | Ignores case | Returns True/False | Returns matching items |
| `-cnotmatch` | Checks case | Returns True/False | Returns non-matching items |

> **Key Point:** PowerShell is **case-insensitive by default**. This is different from most other languages where regex is case-sensitive by default. Use `-cmatch` when case matters.

---

## 5. The `$Matches` Variable

Every time `-match` **succeeds**, PowerShell saves the match details in a special variable called `$Matches`.

### Basic Usage

```powershell
'Error: Disk full on Drive C' -match 'Error: (.+)'

$Matches[0]   # 'Error: Disk full on Drive C'  — the FULL match
$Matches[1]   # 'Disk full on Drive C'          — first capture group
```

- `$Matches[0]` = the **entire matched text**
- `$Matches[1]`, `$Matches[2]`, etc. = **captured groups** (text inside parentheses)

### Important Rules (Common Mistakes)

**Rule 1: `$Matches` does NOT clear when a match fails.**

```powershell
'abc' -match 'abc'     # True
$Matches[0]            # 'abc'

'xyz' -match '123'     # False — no match found
$Matches[0]            # STILL 'abc' — the old value is still there!
```

**Rule 2: `$Matches` gets overwritten on every successful match.**

```powershell
'first' -match 'first'
$Matches[0]            # 'first'

'second' -match 'second'
$Matches[0]            # 'second' — the old value is gone
```

**Rule 3: Always check the match result before using `$Matches`.**

```powershell
# CORRECT way to use $Matches:
if ('Log: Error 404' -match 'Error (\d+)') {
    Write-Host "Found error code: $($Matches[1])"
}
else {
    Write-Host "No error code found"
}
```

> **Warning:** Never trust `$Matches` without first checking if `-match` returned `True`. A failed match does NOT clear `$Matches`.

---

## 6. Escaping Special Characters

When you want to match a metacharacter **as a literal character**, put a backslash `\` before it.

### Manual Escaping with `\`

```powershell
# Problem: dot matches ANY character
'config-json' -match 'config.json'
# Result: True — WRONG! The dot matched the hyphen.

# Solution: escape the dot
'config-json' -match 'config\.json'
# Result: False — correct! Only a literal dot will match now.

'config.json' -match 'config\.json'
# Result: True — correct!
```

### Common Escapes

| What You Write | What It Matches |
|---|---|
| `\.` | A literal dot |
| `\*` | A literal asterisk |
| `\+` | A literal plus sign |
| `\?` | A literal question mark |
| `\$` | A literal dollar sign |
| `\^` | A literal caret |
| `\(` and `\)` | Literal parentheses |
| `\[` and `\]` | Literal square brackets |
| `\{` and `\}` | Literal curly braces |
| `\|` | A literal pipe |
| `\\` | A literal backslash |

### Automatic Escaping with `[regex]::Escape()`

When you are building a pattern from a **variable** or **user input**, use `[regex]::Escape()` to escape all special characters automatically:

```powershell
$userInput = 'Price is $49.99 (USD)'
$escaped = [regex]::Escape($userInput)
$escaped
# Output: Price\ is\ \$49\.99\ \(USD\)

# Now it is safe to use in a pattern
'The Price is $49.99 (USD) today' -match $escaped
# Result: True
```

> **Tip:** Always use `[regex]::Escape()` when the pattern contains text from a variable or user input. This prevents unexpected behavior.

---

## 7. Using `-match` with Arrays

When you use `-match` on a **single string**, it returns `True` or `False`.
When you use `-match` on an **array**, it returns **all matching items** (works like a filter).

### Single String — Returns True/False

```powershell
'WinRM' -match 'Win'
# Result: True (boolean)
```

### Array — Returns Matching Items

```powershell
$services = @('WinRM', 'W32Time', 'Spooler', 'WinDefend', 'BITS')

$services -match 'Win'
# Result: @('WinRM', 'WinDefend') — only items containing 'Win'

$services -notmatch 'Win'
# Result: @('W32Time', 'Spooler', 'BITS') — items NOT containing 'Win'
```

### Case-Sensitive with Arrays

```powershell
$names = @('ADMIN', 'admin', 'Admin', 'USER', 'user')

$names -cmatch '^[A-Z]+$'
# Result: @('ADMIN', 'USER') — only fully uppercase items
```

> **Key Point:** With arrays, `-match` acts as a **filter** and returns matching elements. With a single string, it returns **True/False** and fills `$Matches`.

---

## 8. Quick Reference

```
OPERATORS:
  'text' -match 'pattern'      Case-insensitive match → True/False
  'text' -cmatch 'pattern'     Case-sensitive match → True/False
  'text' -notmatch 'pattern'   Inverse match → True/False
  @array -match 'pattern'      Filter → matching items

METACHARACTERS:
  .     Any one character           ^     Start of string
  $     End of string               *     Zero or more
  +     One or more                 ?     Zero or one
  \     Escape next character       |     OR
  ()    Group and capture           []    Character class
  {}    Repetition count

ESCAPING:
  Use \  before any metacharacter:  \.  \$  \(  \\
  Use [regex]::Escape('text')  for automatic escaping

$Matches:
  $Matches[0]    Full matched text
  $Matches[1]    First capture group
  Does NOT clear on failed match — always check the result first
```

---

> **Next Step:** Complete the exercises in the separate exercises file, then send me your quiz answers!
