# Module 02 — Challenge

> **Instructions:** Replace the `____` blanks with the correct regex pattern or code. Run in PowerShell and verify against the Expected Output.

---

## Challenge 1 — Vowel Detector

**Scenario:** Check if a given word contains any vowel.

```powershell
$word = 'rhythm'

if ($word -match '[____]') {
    Write-Host "Contains a vowel: $($Matches[0])"
}
else {
    Write-Host "No vowels found!"
}
```

**Expected Output:**
```
No vowels found!
```

Now test with `$word = 'hello'` — it should print `Contains a vowel: e`.

---

## Challenge 2 — Hex Color Validator

**Scenario:** Check if a string is a valid 6-digit hex color code (like `#FF00AA`).

```powershell
$colors = @('#FF00AA', '#123xyz', '#ABCDEF', 'FF0000', '#00GG11')

foreach ($color in $colors) {
    if ($color -cmatch '^#[____]{6}$') {
        Write-Host "VALID:   $color"
    }
    else {
        Write-Host "INVALID: $color"
    }
}
```

**Expected Output:**
```
VALID:   #FF00AA
INVALID: #123xyz
VALID:   #ABCDEF
INVALID: FF0000
INVALID: #00GG11
```

> **Hint:** Hex characters are 0-9, A-F, and a-f.

---

## Challenge 3 — Extract All Digits

**Scenario:** Extract the phone number digits from a formatted string.

```powershell
$phone = 'Call us: (555) 123-4567'

# Use the correct shorthand to match all consecutive digits
$phone -match '____'
$firstGroup = $Matches[0]

Write-Host "First digit group found: $firstGroup"
```

**Expected Output:**
```
First digit group found: 555
```

> **Hint:** Which shorthand matches "one or more digits"?

---

## Challenge 4 — Find the Non-Word Characters

**Scenario:** Given a string, find the first character that is NOT a letter, digit, or underscore.

```powershell
$text = 'user@domain.com'

$text -match '____'
Write-Host "First non-word character: '$($Matches[0])'"
```

**Expected Output:**
```
First non-word character: '@'
```

> **Hint:** Which shorthand matches non-word characters?

---

## Challenge 5 — Clean Whitespace Check

**Scenario:** Check if a string contains any whitespace characters (spaces, tabs, newlines).

```powershell
$strings = @(
    'NoSpacesHere',
    'Has Spaces',
    "Has`tTab",
    'Clean_String_123'
)

foreach ($s in $strings) {
    if ($s -match '____') {
        Write-Host "WHITESPACE FOUND: '$s'"
    }
    else {
        Write-Host "CLEAN:            '$s'"
    }
}
```

**Expected Output:**
```
CLEAN:            'NoSpacesHere'
WHITESPACE FOUND: 'Has Spaces'
WHITESPACE FOUND: 'Has	Tab'
CLEAN:            'Clean_String_123'
```

---

## Challenge 6 — Negated Class Filter

**Scenario:** From a list of passwords, find the ones that contain a character that is NOT a letter or digit (meaning they have a special character — which is good for security).

```powershell
$passwords = @('password', 'P@ssw0rd!', 'admin123', 'S3cur3#Key', 'simple')

$strong = $passwords -match '[____]'
Write-Host "Passwords with special characters:"
$strong
```

**Expected Output:**
```
Passwords with special characters:
P@ssw0rd!
S3cur3#Key
```

> **Hint:** Use a negated character class `[^...]` to match characters that are NOT letters or digits.

---

## Challenge 7 — Username Validator

**Scenario:** A valid username must contain ONLY letters, digits, and underscores (word characters). No spaces, no special characters.

```powershell
$usernames = @('john_doe', 'admin 01', 'user@name', 'valid_user_123', 'bad!name')

foreach ($u in $usernames) {
    if ($u -match '____') {
        Write-Host "VALID:   $u"
    }
    else {
        Write-Host "INVALID: $u"
    }
}
```

**Expected Output:**
```
VALID:   john_doe
INVALID: admin 01
INVALID: user@name
VALID:   valid_user_123
INVALID: bad!name
```

> **Hint:** Use `\w` with anchors `^` and `$` and a quantifier to match the entire string.

---

## Challenge 8 — Extract Words Only

**Scenario:** Extract the first word (only letters) from a log entry that starts with a timestamp.

```powershell
$log = '2025-06-15 10:30:00 ERROR: Disk full'

# Match one or more letters only (not digits, not punctuation)
$log -match '[____]+'
Write-Host "First word: $($Matches[0])"
```

**Expected Output:**
```
First word: ERROR
```

> **Hint:** You need a range that matches ONLY letters. Digits appear before "ERROR" so `\w` won't work here.

---

## Challenge 9 — IP Address Rough Match

**Scenario:** Check if a string looks like an IP address (4 groups of 1-3 digits separated by dots).

```powershell
$inputs = @('192.168.1.1', 'hello.world', '10.0.0.255', '999.999.999.999', 'not-an-ip')

foreach ($input in $inputs) {
    if ($input -match '^____$') {
        Write-Host "LOOKS LIKE IP: $input"
    }
    else {
        Write-Host "NOT AN IP:     $input"
    }
}
```

**Expected Output:**
```
LOOKS LIKE IP: 192.168.1.1
NOT AN IP:     hello.world
LOOKS LIKE IP: 10.0.0.255
LOOKS LIKE IP: 999.999.999.999
NOT AN IP:     not-an-ip
```

> **Hint:** Use `\d{1,3}` for 1-3 digits and `\.` for the dots. Repeat the pattern for all 4 groups. (Note: 999.999.999.999 will match because we are only checking the format, not the value range.)

---

## Challenge 10 — Log Entry Classifier (Mini Project)

**Scenario:** Parse log entries and classify each part using different character classes.

```powershell
$logEntries = @(
    '2025-06-15 08:30:00 [INFO] User admin_01 logged in from 10.0.0.5',
    '2025-06-15 09:15:30 [ERROR] Failed login for user test@user from 192.168.1.100',
    '2025-06-15 10:00:00 [WARN] Disk usage at 85% on /dev/sda1'
)

foreach ($entry in $logEntries) {
    Write-Host "--- Entry ---"
    
    # Extract the date (digits and hyphens)
    if ($entry -match '(____) ') {
        Write-Host "  Date: $($Matches[1])"
    }
    
    # Extract the severity level (letters inside square brackets)
    if ($entry -match '\[([____]+)\]') {
        Write-Host "  Level: $($Matches[1])"
    }
    
    # Extract all IP addresses (digit groups with dots)
    if ($entry -match '(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})') {
        Write-Host "  IP: $($Matches[1])"
    }
    else {
        Write-Host "  IP: None"
    }
    
    Write-Host ""
}
```

**Expected Output:**
```
--- Entry ---
  Date: 2025-06-15
  Level: INFO
  IP: 10.0.0.5

--- Entry ---
  Date: 2025-06-15
  Level: ERROR
  IP: 192.168.1.100

--- Entry ---
  Date: 2025-06-15
  Level: WARN
  IP: None
```

---
