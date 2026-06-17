# Module 07 — Challenge

> **Instructions:** Replace `____` blanks. Run in PowerShell and verify against Expected Output.

---

## Challenge 1 — Extract Number Before Unit

**Scenario:** Extract only the numeric value from measurements — without the unit.

```powershell
$measurements = @('14px', '200ms', '3.5GB', '100%')

foreach ($m in $measurements) {
    if ($m -match '\d+(?:\.\d+)?(?=____)') {
        Write-Host "$($Matches[0]) from $m"
    }
}
```

Wait — each has a different unit. Let me adjust:

```powershell
$measurements = @('14px', '200ms', '3.5GB', '100%')

foreach ($m in $measurements) {
    if ($m -match '[\d.]+(?=[a-zA-Z%]+)') {
        Write-Host "Number: $($Matches[0])  from: $m"
    }
}
```

**Expected Output:**
```
Number: 14    from: 14px
Number: 200   from: 200ms
Number: 3.5   from: 3.5GB
Number: 100   from: 100%
```

This challenge has no blanks — run it, understand how lookahead keeps the unit out of the match.

---

## Challenge 2 — Extract Value After Label

**Scenario:** Extract values that appear after specific labels using lookbehind.

```powershell
$lines = @(
    'Username: admin',
    'Password: Secret123',
    'Server: prod-web-01',
    'Port: 8080'
)

foreach ($line in $lines) {
    if ($line -match '(?<=____).+$') {
        Write-Host "Value: $($Matches[0])"
    }
}
```

**Expected Output:**
```
Value: admin
Value: Secret123
Value: prod-web-01
Value: 8080
```

> **Hint:** All values come after `: ` (colon space). Use `(?<=: )` as your lookbehind.

---

## Challenge 3 — Skip Backup Files

**Scenario:** Find all `.zip` files that are NOT backup files (not preceded by `backup_`).

```powershell
$files = @('archive.zip', 'backup_data.zip', 'logs.zip', 'backup_config.zip', 'release.zip')

$nonBackup = $files -match '^(?!backup_).+\.zip$'
$nonBackup
```

**Expected Output:**
```
archive.zip
logs.zip
release.zip
```

This has no blanks — run it and explain in a comment why `(?!backup_)` works here.

---

## Challenge 4 — Dollar Amount Without the Sign

**Scenario:** Extract price numbers without including the `$` sign.

```powershell
$prices = @('$19.99', '$5.00', '$1499.00', '$0.99')

foreach ($p in $prices) {
    if ($p -match '(?<=\$)____') {
        Write-Host "Amount: $($Matches[0])"
    }
}
```

**Expected Output:**
```
Amount: 19.99
Amount: 5.00
Amount: 1499.00
Amount: 0.99
```

> **Hint:** Use lookbehind `(?<=\$)` then match digits and a dot: `\d+\.\d+`.

---

## Challenge 5 — Negative Lookbehind: Skip Prefixed Values

**Scenario:** Extract port numbers that are NOT preceded by `ssl:`.

```powershell
$configs = @('port:8080', 'ssl:443', 'port:3000', 'ssl:8443', 'port:80')

foreach ($c in $configs) {
    if ($c -match '(?<!ssl:)\d+$') {
        Write-Host "Non-SSL port: $($Matches[0])"
    }
}
```

**Expected Output:**
```
Non-SSL port: 8080
Non-SSL port: 3000
Non-SSL port: 80
```

No blanks — run it and understand how negative lookbehind filters based on what came before.

---

## Challenge 6 — Between Two Markers

**Scenario:** Extract content between `[START]` and `[END]` markers without including the markers.

```powershell
$text = 'Data: [START]important-value-here[END] done'

$text -match '(?<=\[START\])____(?=\[END\])'
Write-Host "Extracted: $($Matches[0])"
```

**Expected Output:**
```
Extracted: important-value-here
```

> **Hint:** Use lookbehind `(?<=\[START\])` and lookahead `(?=\[END\])`. The `[` and `]` need to be escaped.

---

## Challenge 7 — Password Strength Checker

**Scenario:** Build a password validator that checks all 4 requirements using lookaheads.

```powershell
$passwords = @('weak', 'Better1', 'G00dPass!', 'NoSpecial1', 'short!A1', 'ValidP@ss1')

foreach ($p in $passwords) {
    $valid = $p -match '^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[____]).{8,}$'
    
    if ($valid) {
        Write-Host "STRONG:   $p"
    }
    else {
        Write-Host "WEAK:     $p"
    }
}
```

**Expected Output:**
```
WEAK:     weak
WEAK:     Better1
STRONG:   G00dPass!
WEAK:     NoSpecial1
WEAK:     short!A1
STRONG:   ValidP@ss1
```

> **Hint:** Fill in `____` with a character class for special characters like `[^a-zA-Z0-9]`.

---

## Challenge 8 — Extract Key from Key=Value

**Scenario:** Extract only the KEY from `key=value` pairs (the part before `=`).

```powershell
$pairs = @('username=admin', 'port=8080', 'host=localhost', 'timeout=30')

foreach ($pair in $pairs) {
    if ($pair -match '\w+(?====)') {
        Write-Host "Key: $($Matches[0])"
    }
}
```

Wait — `(?===)` has three `=`. Let me correct:

```powershell
foreach ($pair in $pairs) {
    if ($pair -match '(\w+)(?==)') {
        Write-Host "Key: $($Matches[1])"
    }
}
```

**Expected Output:**
```
Key: username
Key: port
Key: host
Key: timeout
```

No blanks — run it, observe that `(?==)` is a positive lookahead for `=`.

---

## Challenge 9 — Find Words Not at End of Sentence

**Scenario:** Match words that are NOT followed by a sentence-ending punctuation mark (`.`, `!`, `?`).

```powershell
$sentence = 'The quick brown fox jumps over the lazy dog.'

$words = [regex]::Matches($sentence, '\b\w+\b(?![.!?])')
Write-Host "Non-terminal words:"
foreach ($w in $words) {
    Write-Host "  $($w.Value)"
}
```

**Expected Output:**
```
Non-terminal words:
  The
  quick
  brown
  fox
  jumps
  over
  the
  lazy
```

No blanks — `dog` is excluded because it is followed by `.`. Run and understand.

---

## Challenge 10 — Credential Log Scrubber (Mini Project)

**Scenario:** A log file contains lines with passwords. Scrub all password values while keeping the key. Use `-replace` with lookaround.

```powershell
$logs = @(
    'Connecting with username=admin password=Secret123',
    'Auth: password=P@ssw0rd! user=svc_account',
    'Config loaded: port=8080 password=AdminPass1!',
    'Info: no credentials here'
)

foreach ($log in $logs) {
    # Replace the VALUE after "password=" with "****"
    $scrubbed = $log -replace '(?<=password=)\S+', '____'
    Write-Host $scrubbed
}
```

Fill in `____` with what you want to replace the password with.

**Expected Output:**
```
Connecting with username=admin password=****
Auth: password=**** user=svc_account
Config loaded: port=8080 password=****
Info: no credentials here
```

> **Hint:** `-replace` with a lookbehind matches only the VALUE part. Replace it with the string `'****'`.

---
