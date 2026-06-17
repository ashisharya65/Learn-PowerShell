# Module 05 — Grouping, Capturing & Backreferences

---

## 1. What Is Grouping?

Parentheses `()` serve two purposes in regex:

1. **Grouping** — treat multiple characters as a single unit (so you can apply quantifiers to them)
2. **Capturing** — save the matched text so you can use it later

---

## 2. Grouping — Apply Quantifiers to Multiple Characters

Without grouping, a quantifier only applies to the single character before it:

```powershell
'ababab' -match 'ab+'     # True — matches 'ab', then b+
$Matches[0]               # 'ab'  ← only one b repeated, not "ab"

# With grouping — quantifier applies to the whole group
'ababab' -match '(ab)+'   # True — matches "ab" repeated
$Matches[0]               # 'ababab' ← the entire "ab" group repeated
```

More examples:

```powershell
# Match "ha" repeated one or more times
'hahaha' -match '(ha)+'    # True
$Matches[0]                # 'hahaha'

# Optional group
'color'  -match 'col(ou)?r'  # True — 'ou' group is optional
'colour' -match 'col(ou)?r'  # True
```

---

## 3. Capturing — Saving Matched Text

When a group matches, its content is saved in `$Matches`:

- `$Matches[0]` = the **full match**
- `$Matches[1]` = **first** `()` group
- `$Matches[2]` = **second** `()` group
- and so on...

```powershell
'John Smith, Age 30' -match '(\w+) (\w+), Age (\d+)'

$Matches[0]   # 'John Smith, Age 30'  — full match
$Matches[1]   # 'John'                — first group
$Matches[2]   # 'Smith'               — second group
$Matches[3]   # '30'                  — third group
```

### Practical: Parse a Log Entry

```powershell
$log = '2025-06-15 ERROR Disk full'

$log -match '^(\d{4}-\d{2}-\d{2}) (\w+) (.+)$'

$date    = $Matches[1]   # '2025-06-15'
$level   = $Matches[2]   # 'ERROR'
$message = $Matches[3]   # 'Disk full'

Write-Host "Date: $date | Level: $level | Message: $message"
```

---

## 4. Named Captures — `(?<name>pattern)`

Instead of numbered groups, you can give groups a **name**. This makes your code much more readable.

Syntax: `(?<groupname>pattern)`

Access with: `$Matches['groupname']`

```powershell
$log = '2025-06-15 ERROR Disk full'

$log -match '^(?<date>\d{4}-\d{2}-\d{2}) (?<level>\w+) (?<message>.+)$'

$Matches['date']      # '2025-06-15'
$Matches['level']     # 'ERROR'
$Matches['message']   # 'Disk full'
```

Named groups are especially useful when:
- Your pattern has many groups and numbered indexes get confusing
- Someone else reads your code — names make the intent clear

```powershell
# Parsing an IP address with named groups
'192.168.1.100' -match '^(?<octet1>\d+)\.(?<octet2>\d+)\.(?<octet3>\d+)\.(?<octet4>\d+)$'

$Matches['octet1']   # '192'
$Matches['octet4']   # '100'
```

---

## 5. Backreferences — Referring to a Captured Group

A **backreference** lets you refer back to what a group already captured — inside the same pattern.

- `\1` refers to what group 1 captured
- `\2` refers to what group 2 captured
- `\k<name>` refers to a named group

### Common Use: Find Repeated Words

```powershell
# Match a word that appears twice in a row
'the the dog' -match '\b(\w+) \1\b'
$Matches[1]   # 'the'  ← the repeated word

'hello world' -match '\b(\w+) \1\b'
# False — no word repeats
```

### Common Use: Validate Matching Tags

```powershell
# Make sure the closing tag matches the opening tag
'<b>text</b>' -match '<(\w+)>.+</\1>'    # True  — both are 'b'
'<b>text</i>' -match '<(\w+)>.+</\1>'    # False — 'b' ≠ 'i'
```

### Named Backreference

```powershell
# Same as above but with a named group
'<b>text</b>' -match '<(?<tag>\w+)>.+</\k<tag>>'    # True
```

---

## 6. Group Numbering Rules

When you have multiple groups, they are numbered **left to right** by their **opening parenthesis**:

```
Pattern: (a(b(c)))
         1 2 3

Match: 'abc'
  Group 1 → 'abc'   (outermost group)
  Group 2 → 'bc'    (middle group)
  Group 3 → 'c'     (innermost group)
```

```powershell
'2025-06-15' -match '((\d{4})-(\d{2})-(\d{2}))'

$Matches[1]   # '2025-06-15'  — group 1 (the full date group)
$Matches[2]   # '2025'        — group 2 (year)
$Matches[3]   # '06'          — group 3 (month)
$Matches[4]   # '15'          — group 4 (day)
```

> **Tip:** To avoid confusion with nested groups, prefer **named captures** — they are self-documenting.

---

## 7. Quick Reference

```
GROUPING & CAPTURING:
  (pattern)           Capture group — numbered automatically
  (?<name>pattern)    Named capture group
  $Matches[1]         Access group 1 content
  $Matches['name']    Access named group content

BACKREFERENCES:
  \1                  Refers to what group 1 captured
  \k<name>            Refers to what named group captured
  Used inside the SAME pattern to match repeated content

GROUP NUMBERING:
  Groups are numbered left to right by their opening (
  Group 0 = full match
  Nested groups count too

PRACTICAL USES:
  Parse structured text into named fields
  Find duplicate words with \1
  Validate matching open/close tags
  Extract date parts, IP octets, log fields
```
