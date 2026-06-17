# Module 12 — Capstone Challenge: PowerShell Log Analyzer

## Overview

This is the **final challenge** of the PowerShell Regular Expression Mastery curriculum.

You will build a real, working PowerShell script that:
- Parses **three different log formats** in one run
- Extracts structured data using regex patterns
- Produces a **summary report** with statistics
- Detects **security anomalies** automatically
- Exports clean data to a CSV file

This is not a fill-in-the-blanks exercise. This is a **production-style script** that combines every concept you have learned across Modules 01 to 11.

---

## What You Will Build

```
PowerShell Log Analyzer
│
├── Parser 1 ── IIS Web Logs         (IP, method, path, status code, bytes)
├── Parser 2 ── Syslog Format        (host, process, PID, message, source IP)
├── Parser 3 ── Custom App Logs      (ISO timestamp, level, source, message)
│
├── Report   ── Summary statistics   (counts by format, counts by level)
├── Report   ── Top client IPs       (most active sources)
├── Report   ── Errors by service    (which service failed most)
│
├── Detect   ── Brute force IPs      (3+ failed login attempts)
├── Detect   ── SSH failures         (repeated failures from same IP)
├── Detect   ── Repeated errors      (same app error message 2+ times)
│
└── Export   ── CSV file             (all parsed entries in clean format)
```

---

## The Three Log Formats

### Format 1 — IIS Style
```
YYYY-MM-DD HH:MM:SS ClientIP Method Path StatusCode BytesSent
```
**Example:**
```
2025-06-15 08:00:01 192.168.1.10 GET /index.html 200 1523
2025-06-15 08:00:05 192.168.1.11 POST /api/login 401 340
```

### Format 2 — Syslog Style
```
Mon DD HH:MM:SS hostname process[pid]: message
```
**Example:**
```
Jun 15 08:01:00 webserver01 sshd[1234]: Accepted password for admin from 10.0.0.1 port 22
Jun 15 08:01:10 webserver01 sshd[1234]: Failed password for root from 203.0.113.5 port 22
```

### Format 3 — Custom App Style
```
[ISO-Timestamp] [LEVEL] [SOURCE] Message
```
**Example:**
```
[2025-06-15T08:02:00Z] [INFO] [AuthService] User 'admin' authenticated successfully
[2025-06-15T08:02:05Z] [ERROR] [DiskService] Disk usage at 95% on volume C:\
```

---

## Challenge Structure (7 Parts)

| Part | Task | Key Concept Used |
|---|---|---|
| **Part 1** | Parse IIS log lines into objects | Named captures, free-spacing `(?x)` |
| **Part 2** | Parse Syslog lines into objects | Named captures, `switch -Regex` |
| **Part 3** | Parse custom App log lines | Named captures, `-match` |
| **Part 4** | Combine all parsed entries | Array operations |
| **Part 5** | Build summary report | `Group-Object`, counts |
| **Part 6** | Detect anomalies | Filtering, grouping, thresholds |
| **Part 7** | Export to CSV | `Export-Csv` |

---

## Regex Concepts Applied

Every module from 01 to 11 is used in this challenge:

| Concept | Module | Where Applied |
|---|---|---|
| `-match` operator & `$Matches` | 01 | All three parsers |
| Character classes `[A-Za-z]` | 02 | Month names, HTTP methods |
| Shorthand `\d` `\s` `\w` `\S` | 02 | Timestamps, IPs, words |
| Quantifiers `{n}` `+` `*` `?` | 03 | All patterns |
| Anchors `^` and `$` | 04 | All patterns |
| Named captures `(?<name>)` | 05 | All three parsers |
| Non-capturing groups `(?:)` | 06 | IP octet pattern |
| Lookbehind `(?<=)` | 07 | Extracting source IPs |
| `[regex]::Matches()` | 08 | Collecting all entries |
| `switch -Regex` | 09 | Classifying syslog levels |
| `-replace` | 09 | Cleaning ISO timestamps |
| Real-world patterns (IPs, paths) | 10 | IIS and syslog parsing |
| Free-spacing mode `(?x)` | 11 | Readable complex patterns |
| Avoiding greedy traps | 11 | `[^>]` `[^\]]+` patterns |

---

## How to Run

### Step 1 — Open the challenge file
Open `Challenge.md` and read through all 7 parts.

### Step 2 — Create your script
Create a new file called `log_analyzer.ps1` in your working directory.

### Step 3 — Fill in the blanks
Each part has `____` blanks to complete. Use your notes from Modules 01–11 to fill them in.

### Step 4 — Run the script
```powershell
.\log_analyzer.ps1
```

### Step 5 — Verify the output
Your output should match the **Expected Final Output** section in the challenge file.

### Step 6 — Check the CSV export
```powershell
Import-Csv .\log_analysis_report.csv | Format-Table
```

---

## What Success Looks Like

Your completed script will:

- ✅ Parse all 18 log entries without errors
- ✅ Correctly classify each entry as INFO, WARN, or ERROR
- ✅ Identify `203.0.113.5` as a brute force attacker (3 failed IIS logins)
- ✅ Identify `203.0.113.5` as a repeated SSH failure source
- ✅ Detect the repeated `Connection to db-01:5432 timed out` app error
- ✅ Export 18 rows to `log_analysis_report.csv`
- ✅ Print the full report to the console

---

## Skills Checklist

Before starting, you should be comfortable with:

- [ ] Writing named capture groups `(?<name>pattern)`
- [ ] Using `$Matches['name']` to access captured values
- [ ] Using `[regex]::Matches()` to find all occurrences
- [ ] Using `switch -Regex` for multi-pattern dispatch
- [ ] Using `-replace` with `$1`/`${name}` substitutions
- [ ] Using `Group-Object` to count and group results
- [ ] Writing free-spacing patterns with `(?x)`
- [ ] Avoiding greedy traps using negated classes

If any of the above feel unfamiliar, revisit the corresponding module notes before starting.

---

## Files in This Module

| File | Purpose |
|---|---|
| `README.md` | This file — project overview and instructions |
| `Challenge.md.md` | The full challenge with all 7 parts and blanks to fill |

---

## Tips Before You Start

> **Tip 1:** Read all 7 parts before writing any code. Understanding the full picture helps you write better patterns.

> **Tip 2:** Test each parser function individually before combining them in Part 4.

> **Tip 3:** Use `$Matches | Format-List` after a match to see all captured groups — useful for debugging.

> **Tip 4:** The free-spacing `(?x)` patterns in Part 1 and Part 2 look long but are easy to read line by line. Don't be intimidated.

> **Tip 5:** If a pattern is not matching, use `[regex]::Escape()` on your test string to check for special characters you might have missed.

---
