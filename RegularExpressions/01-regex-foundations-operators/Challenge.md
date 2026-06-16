# Module 01 — Challenge

> **Instructions:**
> - Each challenge gives you a **scenario** and **requirements**.
> - Write your solution in the provided code block (replace the `____` blanks).
> - Run it in PowerShell and verify your output matches the **Expected Output**.
> - Do NOT look at the hints unless you are stuck.

---

## Challenge 1 — Find the Intruder

**Scenario:** You have a server name. Check if it contains the word "prod" (any case).

**Requirements:**
- Use the correct operator to do a case-insensitive match.
- Print "Production server detected!" if it matches.

```powershell
$serverName = 'DC-PROD-01'

if ($serverName ____ '____') {
    Write-Host "Production server detected!"
}
else {
    Write-Host "Not a production server."
}
```

**Expected Output:**
```
Production server detected!
```

---

## Challenge 2 — Strict Case Check

**Scenario:** Your security policy says usernames must be all lowercase. Check if the given username violates the policy.

**Requirements:**
- Use a case-sensitive operator.
- The pattern should match only if the string contains an uppercase letter.

```powershell
$username = 'John.Doe'

if ($username ____ '[A-Z]') {
    Write-Host "VIOLATION: Username contains uppercase letters."
}
else {
    Write-Host "Username is compliant."
}
```

**Expected Output:**
```
VIOLATION: Username contains uppercase letters.
```

---

## Challenge 3 — Extract the Error Code

**Scenario:** A log line contains an error code. Extract just the number.

**Requirements:**
- Use `-match` with a pattern that captures the digits after "Error".
- Use `$Matches` to print only the error code number.

```powershell
$logLine = 'Application Error 5021: Connection timeout'

if ($logLine -match '____') {
    Write-Host "Error Code: $($Matches[____])"
}
```

**Expected Output:**
```
Error Code: 5021
```

> **Hint:** Use parentheses `()` to create a capture group around `\d+`. The captured group goes into `$Matches[1]`.

---

## Challenge 4 — The Dot Trap

**Scenario:** You want to check if a filename is exactly `report.csv`. But your current pattern has a bug — it also matches `reportXcsv`.

**Requirements:**
- Fix the pattern so it ONLY matches a literal dot, not any character.

```powershell
# BUG: This matches 'reportXcsv' too!
# 'reportXcsv' -match 'report.csv'  → True (WRONG!)

$fileName = 'report.csv'

# Fix the pattern below:
$pattern = '____'

if ($fileName -match $pattern) {
    Write-Host "Valid filename: $($Matches[0])"
}
```

**Expected Output:**
```
Valid filename: report.csv
```

**Verify your fix works by also testing:**
```powershell
'reportXcsv' -match $pattern
# This MUST return False
```

---

## Challenge 5 — Filter the File List

**Scenario:** You have an array of filenames. Return only the `.log` files.

**Requirements:**
- Use `-match` on the array to filter.
- The pattern must match `.log` at the end of the filename.
- Make sure it does not match files like `blog.txt` or `logfile.csv`.

```powershell
$files = @(
    'system.log',
    'blog.txt',
    'error.log',
    'logfile.csv',
    'access.log',
    'readme.md'
)

$logFiles = $files -match '____'
$logFiles
```

**Expected Output:**
```
system.log
error.log
access.log
```

---

## Challenge 6 — Escape the User Input

**Scenario:** A user searches for the text `Price: $9.99 (each)`. Build a safe regex pattern from this input and find it in a log.

**Requirements:**
- Use `[regex]::Escape()` to make the search term safe.
- Match it against the log line.

```powershell
$searchTerm = 'Price: $9.99 (each)'
$safePattern = ____

$logEntry = 'Item sold — Price: $9.99 (each) — Qty: 5'

if ($logEntry -match $safePattern) {
    Write-Host "Found: $($Matches[0])"
}
else {
    Write-Host "Not found."
}
```

**Expected Output:**
```
Found: Price: $9.99 (each)
```

---

## Challenge 7 — The $Matches Trap

**Scenario:** Your colleague wrote this code but it has a bug. Sometimes it prints the wrong error code. Find and fix the bug.

**Requirements:**
- Read the code carefully. Understand why it might print wrong results.
- Fix it so it only prints when a match is actually found.

```powershell
# BUGGY CODE — Fix this:
$lines = @(
    'Error 404: Page not found',
    'Info: Server started successfully',
    'Error 500: Internal server error'
)

foreach ($line in $lines) {
    $line -match 'Error (\d+)'
    Write-Host "Line: $line → Error Code: $($Matches[1])"
}
```

**Current (Wrong) Output:**
```
Line: Error 404: Page not found → Error Code: 404
Line: Info: Server started successfully → Error Code: 404    ← BUG! No error here!
Line: Error 500: Internal server error → Error Code: 500
```

**Expected (Fixed) Output:**
```
Error Code Found: 404 in line: Error 404: Page not found
No error code in line: Info: Server started successfully
Error Code Found: 500 in line: Error 500: Internal server error
```

> **Hint:** `$Matches` does not clear on a failed match. You need to check the return value of `-match`.

---

## Challenge 8 — Exclude the Unwanted

**Scenario:** You have a list of processes. Return all processes that do NOT start with "svc".

**Requirements:**
- Use the correct operator to get non-matching items from an array.
- The pattern should match strings starting with "svc" (case-insensitive).

```powershell
$processes = @('svchost', 'explorer', 'svcnet', 'chrome', 'svctask', 'notepad')

$filtered = $processes ____ '____'
$filtered
```

**Expected Output:**
```
explorer
chrome
notepad
```

---

## Challenge 9 — Multi-Part Extraction

**Scenario:** Extract both the date and the severity level from a log entry.

**Requirements:**
- Write a single pattern that captures the date and the severity in separate groups.
- Print both using `$Matches`.

```powershell
$log = '2025-06-15 [CRITICAL] Disk space low on Drive D'

if ($log -match '____') {
    Write-Host "Date: $($Matches[1])"
    Write-Host "Severity: $($Matches[2])"
}
```

**Expected Output:**
```
Date: 2025-06-15
Severity: CRITICAL
```

> **Hint:** Dates look like `\d{4}-\d{2}-\d{2}`. Severity is inside square brackets — remember to escape `[` and `]`.

---

## Challenge 10 — Server Health Report (Mini Project)

**Scenario:** You have server status messages. Write a complete script that:
1. Filters only the servers that are DOWN.
2. Extracts the server name from each DOWN message.
3. Prints a clean report.

**Requirements:**
- Use array filtering with `-match`.
- Use `-match` on each result to extract the server name.
- Server names follow the pattern: letters, hyphens, and numbers (e.g., `WEB-01`).

```powershell
$statusMessages = @(
    'Server WEB-01 is UP — Response time: 45ms',
    'Server DB-03 is DOWN — Error: Connection refused',
    'Server APP-02 is UP — Response time: 120ms',
    'Server CACHE-01 is DOWN — Error: Out of memory',
    'Server WEB-02 is UP — Response time: 38ms',
    'Server AUTH-01 is DOWN — Error: Certificate expired'
)

# Step 1: Filter only DOWN servers
$downServers = $statusMessages -match '____'

# Step 2: Extract and report each server name
Write-Host "=== DOWN SERVER REPORT ===" -ForegroundColor Red
Write-Host ""

foreach ($msg in $downServers) {
    if ($msg -match '____') {
        Write-Host "  [DOWN] $($Matches[1])" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Total down: $($downServers.Count)" -ForegroundColor Red
```

**Expected Output:**
```
=== DOWN SERVER REPORT ===

  [DOWN] DB-03
  [DOWN] CACHE-01
  [DOWN] AUTH-01

Total down: 3
```

---

## Submission

Once you complete all 10 challenges, send me:
1. Any challenges where you got stuck.
2. Your quiz answers (Q1–Q10 from the exercises file).

I will review your work, explain any mistakes, and we move to **Module 02**! 🚀
