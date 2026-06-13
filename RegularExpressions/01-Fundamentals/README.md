# Module 1 - Regex Fundamentals

## Learning Objectives

By the end of this module, you will be able to:

- Understand what Regular Expressions (Regex) are.
- Understand why Regex is important for PowerShell developers.
- Explain the difference between searching for text and searching for patterns.
- Use the PowerShell `-match` operator for basic pattern matching.
- Understand how PowerShell leverages the .NET Regex engine.
- Understand the purpose of the `$Matches` automatic variable.
- Recognize common beginner mistakes.

---

# What is Regex?

**Regex (Regular Expression)** is a pattern matching language used to search, extract, validate, replace, and manipulate text.

Think of Regex as a search language for text.

Just like SQL helps you find data in a database, Regex helps you find patterns in text.

---

# Why Learn Regex?

As a PowerShell developer, you will frequently work with:

- Log files
- Configuration files
- CSV files
- JSON files
- XML files
- Azure deployment outputs
- Active Directory exports
- Event logs
- User input validation

Regex allows you to process this data efficiently and with less code.

---

# Real-World Example

Imagine you have the following log entries:

```text
[INFO] Deployment Started
[INFO] Deployment Completed
[ERROR] Resource Creation Failed
[INFO] Retry Started
```

You want to identify error messages.

Using PowerShell:

```powershell
Get-Content .\application.log | Where-Object {
    $_ -match "ERROR"
}
```

Output:

```text
[ERROR] Resource Creation Failed
```

This is a simple example of Regex pattern matching.

---

# Text vs Pattern Matching

Most beginners think Regex searches for words.

That is not entirely true.

Regex searches for **patterns**.

Consider the following text:

```text
Server01
Server02
Server03
```

Searching for:

```regex
Server01
```

matches only:

```text
Server01
```

However, searching for a pattern can match multiple values.

Later in the course, you'll learn patterns that can match:

```text
Server01
Server02
Server03
Server99
```

using a single Regex expression.

---

# Your First Regex Match

PowerShell provides the `-match` operator.

Syntax:

```powershell
<string> -match <regex_pattern>
```

Example:

```powershell
"PowerShell is awesome" -match "PowerShell"
```

Output:

```powershell
True
```

Because the text contains the specified pattern.

---

# Another Example

```powershell
"Azure VM" -match "AWS"
```

Output:

```powershell
False
```

Because the pattern does not exist in the text.

---

# How the Regex Engine Works

PowerShell uses the .NET Regex engine.

When PowerShell encounters:

```powershell
"PowerShell" -match "Shell"
```

The Regex engine scans the string from left to right.

Visualization:

```text
PowerShell

Looking for:
Shell

Scan Process:

P -> No Match
o -> No Match
w -> No Match
e -> No Match
r -> No Match
S -> Match Start
h -> Match
e -> Match
l -> Match
l -> Match

Result: Match Found
```

---

# Understanding the `-match` Operator

The `-match` operator returns:

- `True` when a match is found
- `False` when no match is found

Example:

```powershell
"Server01" -match "Server"
```

Output:

```powershell
True
```

Example:

```powershell
"Server01" -match "Database"
```

Output:

```powershell
False
```

---

# The `$Matches` Automatic Variable

One of the most useful features of `-match` is the automatic `$Matches` variable.

Example:

```powershell
"Server01" -match "Server"

$Matches
```

Output:

```powershell
Name                           Value
----                           -----
0                              Server
```

Whenever a successful match occurs, PowerShell stores matching information inside `$Matches`.

We will explore this deeply in later modules.

For now, simply remember:

> Successful regex matches populate `$Matches`.

---

# Case Sensitivity

PowerShell Regex matching is case-insensitive by default.

Example:

```powershell
"PowerShell" -match "powershell"
```

Output:

```powershell
True
```

Example:

```powershell
"POWERSHELL" -match "powershell"
```

Output:

```powershell
True
```

---

# Case-Sensitive Matching

PowerShell provides `-cmatch` for case-sensitive matching.

Example:

```powershell
"POWERSHELL" -cmatch "powershell"
```

Output:

```powershell
False
```

Because the casing is different.

---

# Common Beginner Mistakes

## Mistake 1: Thinking Regex Searches Only Whole Words

Example:

```powershell
"PowerShell" -match "Shell"
```

Output:

```powershell
True
```

Regex can match part of a string.

---

## Mistake 2: Confusing `-like` with `-match`

### Using `-like`

```powershell
"Server01" -like "Server*"
```

Uses wildcard matching.

### Using `-match`

```powershell
"Server01" -match "Server"
```

Uses Regex matching.

These are different technologies and should not be confused.

---

# Where Regex Is Used in PowerShell

| Scenario | Example |
|-----------|----------|
| Log Analysis | Find error messages |
| Active Directory | Validate usernames |
| Azure Automation | Validate resource names |
| Security Monitoring | Detect suspicious patterns |
| File Processing | Extract data from files |
| CI/CD Pipelines | Validate deployment output |
| Reporting | Extract specific values |

---

# Interview Notes

## What is Regex?

A pattern matching language used for searching, extracting, validating, replacing, and manipulating text.

---

## Does PowerShell Have Its Own Regex Engine?

No.

PowerShell uses the .NET Regex engine.

---

## What Does `-match` Return?

A Boolean value:

- `True`
- `False`

---

## What Automatic Variable Is Populated After a Successful Match?

```powershell
$Matches
```

---

## Is PowerShell Regex Case-Sensitive By Default?

No.

Regex matching is case-insensitive by default.

Use `-cmatch` for case-sensitive matching.

---

# Module Summary

In this module, you learned:

- What Regex is
- Why Regex is important
- How Regex differs from simple text searching
- How the `-match` operator works
- How PowerShell uses the .NET Regex engine
- The purpose of `$Matches`
- Case-insensitive vs case-sensitive matching
- Common beginner mistakes

Before moving to the next module, ensure that you fully understand the concepts covered here, as every advanced Regex concept builds upon these fundamentals.
