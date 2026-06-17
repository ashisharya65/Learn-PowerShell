# Module 12 — Capstone: PowerShell Log Analyzer

> This is your final challenge. You will build a complete, working PowerShell Log Analyzer that uses everything you have learned across all 11 modules.
>
> There is no separate notes file for this module — the capstone IS the challenge.

---

## Your Mission

Build a script that:
1. Parses **three different log formats** (IIS-style, Syslog-style, Custom App)
2. Extracts structured data from each (timestamp, level, source, IP, message)
3. Produces a **summary statistics report**
4. Detects **anomalies** (repeated IPs, error spikes, suspicious usernames)
5. Exports clean, structured data

---

## The Log Data

```powershell
# ============================================================
# SAMPLE LOG DATA — three different formats in one block
# ============================================================

$rawLogs = @"
--- IIS FORMAT ---
2025-06-15 08:00:01 192.168.1.10 GET /index.html 200 1523
2025-06-15 08:00:05 192.168.1.11 POST /api/login 401 340
2025-06-15 08:00:10 10.0.0.5 GET /admin 403 120
2025-06-15 08:00:15 192.168.1.10 GET /dashboard 200 4200
2025-06-15 08:00:20 203.0.113.5 POST /api/login 401 340
2025-06-15 08:00:25 203.0.113.5 POST /api/login 401 340
2025-06-15 08:00:30 203.0.113.5 POST /api/login 401 340

--- SYSLOG FORMAT ---
Jun 15 08:01:00 webserver01 sshd[1234]: Accepted password for admin from 10.0.0.1 port 22
Jun 15 08:01:05 webserver01 sudo[5678]: admin : TTY=pts/0 ; USER=root ; COMMAND=/bin/bash
Jun 15 08:01:10 webserver01 sshd[1234]: Failed password for root from 203.0.113.5 port 22
Jun 15 08:01:15 webserver01 sshd[1234]: Failed password for root from 203.0.113.5 port 22
Jun 15 08:01:20 webserver01 kernel: [UFW BLOCK] SRC=203.0.113.5 DST=192.168.1.1

--- APP FORMAT ---
[2025-06-15T08:02:00Z] [INFO] [AuthService] User 'admin' authenticated successfully
[2025-06-15T08:02:05Z] [ERROR] [DiskService] Disk usage at 95% on volume C:\
[2025-06-15T08:02:10Z] [WARN] [MemService] Available memory: 512MB (below threshold)
[2025-06-15T08:02:15Z] [ERROR] [NetService] Connection to db-01:5432 timed out after 30s
[2025-06-15T08:02:20Z] [ERROR] [NetService] Connection to db-01:5432 timed out after 30s
[2025-06-15T08:02:25Z] [INFO] [BackupService] Backup of C:\Data completed: 4.2GB
"@
```

---

## Part 1 — Parse IIS Format Logs

Build a function that parses IIS log lines and returns objects.

```powershell
# IIS Format: YYYY-MM-DD HH:MM:SS ClientIP Method Path StatusCode BytesSent
$iisPattern = @'
(?x)
^(?<date>\d{4}-\d{2}-\d{2})
\ (?<time>\d{2}:\d{2}:\d{2})
\ (?<clientip>\d{1,3}(?:\.\d{1,3}){3})
\ (?<method>[A-Z]+)
\ (?<path>\S+)
\ (?<status>\d{3})
\ (?<bytes>\d+)$
'@

function Parse-IISLog {
    param([string[]]$lines)
    
    $results = @()
    foreach ($line in $lines) {
        if ($line -match $iisPattern) {
            $results += [PSCustomObject]@{
                Format    = 'IIS'
                DateTime  = "$($Matches['____']) $($Matches['____'])"
                ClientIP  = $Matches['____']
                Method    = $Matches['____']
                Path      = $Matches['____']
                Status    = [int]$Matches['____']
                Bytes     = [int]$Matches['____']
                Level     = if ([int]$Matches['status'] -ge 400) { 'ERROR' } else { 'INFO' }
                Message   = "$($Matches['method']) $($Matches['path']) → $($Matches['status'])"
            }
        }
    }
    return $results
}
```

> **Fill:** Replace each `____` in the named group references with: `date`, `time`, `clientip`, `method`, `path`, `status`, `bytes`.

---

## Part 2 — Parse Syslog Format Logs

```powershell
# Syslog Format: Mon DD HH:MM:SS hostname process[pid]: message
$syslogPattern = @'
(?x)
^(?<month>[A-Za-z]{3})
\ (?<day>\d{1,2})
\ (?<time>\d{2}:\d{2}:\d{2})
\ (?<host>\S+)
\ (?<process>[^\[]+)\[(?<pid>\d+)\]:
\ (?<message>.+)$
'@

function Parse-SysLog {
    param([string[]]$lines)
    
    $results = @()
    foreach ($line in $lines) {
        if ($line -match $syslogPattern) {
            $level = switch -Regex ($Matches['message']) {
                'Failed|BLOCK|error' { 'ERROR'; break }
                'warn|high|low'      { 'WARN';  break }
                default              { 'INFO' }
            }
            
            # Extract source IP if present
            $sourceIP = ''
            if ($Matches['message'] -match 'from (\d{1,3}(?:\.\d{1,3}){3})') {
                $sourceIP = $Matches[____]
            }
            
            $results += [PSCustomObject]@{
                Format   = 'Syslog'
                DateTime = "2025-06-$($Matches['day'].PadLeft(2,'0')) $($Matches['time'])"
                Host     = $Matches['host']
                Process  = $Matches['process']
                Level    = $level
                ClientIP = $sourceIP
                Message  = $Matches['message']
            }
        }
    }
    return $results
}
```

> **Fill:** Replace `$Matches[____]` with `1` (the capture group for the IP).

---

## Part 3 — Parse Custom App Format Logs

```powershell
# App Format: [ISO-Timestamp] [LEVEL] [SOURCE] Message
$appPattern = '^\[(?<ts>[^\]]+)\] \[(?<level>[^\]]+)\] \[(?<source>[^\]]+)\] (?<message>.+)$'

function Parse-AppLog {
    param([string[]]$lines)
    
    $results = @()
    foreach ($line in $lines) {
        if ($line -match ____) {
            $results += [PSCustomObject]@{
                Format   = 'App'
                DateTime = $Matches['ts'] -replace 'T', ' ' -replace 'Z', ''
                Source   = $Matches['source']
                Level    = $Matches['level']
                ClientIP = ''
                Message  = $Matches['message']
            }
        }
    }
    return $results
}
```

> **Fill:** Replace `____` with `$appPattern`.

---

## Part 4 — Process All Logs Together

```powershell
# Split the raw log into sections
$iisLines    = $rawLogs -split '\n' | Where-Object { $_ -match '^\d{4}-\d{2}-\d{2}' }
$syslogLines = $rawLogs -split '\n' | Where-Object { $_ -match '^[A-Za-z]{3} \d{1,2}' }
$appLines    = $rawLogs -split '\n' | Where-Object { $_ -match '^\[20\d{2}' }

# Parse each format
$iisEntries    = Parse-IISLog    $iisLines
$syslogEntries = Parse-SysLog    $syslogLines
$appEntries    = Parse-AppLog    $appLines

# Combine all entries
$allEntries = @($iisEntries) + @($syslogEntries) + @($appEntries)
```

---

## Part 5 — Summary Report

```powershell
Write-Host ""
Write-Host "╔══════════════════════════════════════════╗"
Write-Host "║         LOG ANALYSIS REPORT              ║"
Write-Host "╚══════════════════════════════════════════╝"
Write-Host ""

# Total counts
Write-Host "── TOTALS ──"
Write-Host "Total log entries : $($allEntries.____)"
Write-Host "IIS entries       : $($iisEntries.____)"
Write-Host "Syslog entries    : $($syslogEntries.____)"
Write-Host "App entries       : $($appEntries.____)"
Write-Host ""

# Count by level
Write-Host "── BY LEVEL ──"
$allEntries | Group-Object Level | Sort-Object Name | ForEach-Object {
    Write-Host "$($_.Name.PadRight(8)): $($_.Count)"
}
Write-Host ""

# Top IPs (from IIS logs)
Write-Host "── TOP CLIENT IPs ──"
$iisEntries |
    Where-Object { $_.ClientIP -ne '' } |
    Group-Object ClientIP |
    Sort-Object Count -Descending |
    Select-Object -First 5 |
    ForEach-Object { Write-Host "$($_.Name.PadRight(20)): $($_.Count) request(s)" }
Write-Host ""

# Error count by source (App logs)
Write-Host "── ERRORS BY SOURCE (App Logs) ──"
$appEntries |
    Where-Object { $_.Level -eq '____' } |
    Group-Object Source |
    Sort-Object Count -Descending |
    ForEach-Object { Write-Host "$($_.Name.PadRight(20)): $($_.Count) error(s)" }
```

> **Fill:** `Count` for array length, `'ERROR'` for the level filter.

---

## Part 6 — Anomaly Detection

```powershell
Write-Host ""
Write-Host "── ANOMALY DETECTION ──"

# Detect IPs with 3+ 401 errors (brute force attack)
$bruteForce = $iisEntries |
    Where-Object { $_.Status -eq ____ } |
    Group-Object ClientIP |
    Where-Object { $_.Count -ge ____ }

if ($bruteForce) {
    Write-Host "⚠️  POTENTIAL BRUTE FORCE:"
    $bruteForce | ForEach-Object {
        Write-Host "   IP $($_.Name) had $($_.Count) failed login attempts"
    }
}

# Detect repeated syslog failures from same IP
$syslogFails = $syslogEntries |
    Where-Object { $_.Level -eq 'ERROR' -and $_.ClientIP -ne '' } |
    Group-Object ClientIP |
    Where-Object { $_.Count -ge 2 }

if ($syslogFails) {
    Write-Host "⚠️  REPEATED SSH FAILURES:"
    $syslogFails | ForEach-Object {
        Write-Host "   IP $($_.Name) had $($_.Count) SSH failures"
    }
}

# Detect repeated app errors (same message 2+ times)
$repeatedErrors = $appEntries |
    Where-Object { $_.Level -eq 'ERROR' } |
    Group-Object Message |
    Where-Object { $_.Count -ge 2 }

if ($repeatedErrors) {
    Write-Host "⚠️  REPEATED ERROR MESSAGES:"
    $repeatedErrors | ForEach-Object {
        Write-Host "   [$($_.Count)x] $($_.Name)"
    }
}
```

> **Fill:** `401` for status code, `3` for the threshold count.

---

## Part 7 — Export Report

```powershell
# Export all parsed entries to CSV
$exportPath = '.\log_analysis_report.csv'

$allEntries |
    Select-Object Format, DateTime, Level, Source, ClientIP, Message |
    Export-Csv -Path $exportPath -NoTypeInformation

Write-Host ""
Write-Host "── EXPORT ──"
Write-Host "Report saved to: $exportPath"
Write-Host "Total rows exported: $($allEntries.Count)"
```

---

## Expected Final Output

```
╔══════════════════════════════════════════╗
║         LOG ANALYSIS REPORT              ║
╚══════════════════════════════════════════╝

── TOTALS ──
Total log entries : 18
IIS entries       : 7
Syslog entries    : 5
App entries       : 6

── BY LEVEL ──
ERROR   : 9
INFO    : 6
WARN    : 3

── TOP CLIENT IPs ──
203.0.113.5         : 3 request(s)
192.168.1.10        : 2 request(s)
192.168.1.11        : 1 request(s)
10.0.0.5            : 1 request(s)

── ERRORS BY SOURCE (App Logs) ──
NetService          : 2 error(s)
DiskService         : 1 error(s)

── ANOMALY DETECTION ──
⚠️  POTENTIAL BRUTE FORCE:
   IP 203.0.113.5 had 3 failed login attempts
⚠️  REPEATED SSH FAILURES:
   IP 203.0.113.5 had 2 SSH failures
⚠️  REPEATED ERROR MESSAGES:
   [2x] Connection to db-01:5432 timed out after 30s

── EXPORT ──
Report saved to: .\log_analysis_report.csv
Total rows exported: 18
```

---

## Regex Concepts Used in This Capstone

| Concept | Where Used |
|---|---|
| Named captures `(?<name>)` | All three parsers |
| Anchors `^` `$` | All patterns |
| Character classes `[A-Za-z]` | Syslog month, method |
| Shorthand `\d` `\S` `\w` | Timestamps, IPs, hosts |
| Quantifiers `{n}` `+` `*` | All patterns |
| Non-capturing `(?:...)` | IP octet repetition |
| Free-spacing `(?x)` | IIS and syslog patterns |
| Multiline parsing | Section splitting |
| `switch -Regex` | Syslog level classifier |
| `-match` with `$Matches` | All parsers |
| `[regex]::Matches()` | All match collections |
| Array filtering with `-match` | Section splitting |

---
