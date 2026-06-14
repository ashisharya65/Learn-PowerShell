# Module 1 - Exercises

## Objective

Use the concepts learned in Module 1 to solve real-world PowerShell pattern matching problems.

---

# Exercise 1 - Basic Match

You have the following text:

```powershell
$text = "PowerShell is awesome"
```

Write a PowerShell expression that returns `True`.

Expected pattern to find:

```text
PowerShell
```

---

# Exercise 2 - No Match

You have:

```powershell
$text = "Azure Virtual Machine"
```

Write a PowerShell expression that returns `False`.

Pattern to search:

```text
AWS
```

---

# Exercise 3 - Partial Match

You have:

```powershell
$text = "Server01"
```

Write a PowerShell expression that confirms the string contains:

```text
Server
```

---

# Exercise 4 - Case Insensitive Matching

You have:

```powershell
$text = "POWERSHELL"
```

Write a PowerShell expression that matches:

```text
powershell
```

Expected result:

```text
True
```

---

# Exercise 5 - Case Sensitive Matching

You have:

```powershell
$text = "POWERSHELL"
```

Write a PowerShell expression that performs a case-sensitive match against:

```text
powershell
```

Expected result:

```text
False
```

---

# Exercise 6 - Log File Analysis

A log line contains:

```text
[ERROR] Resource deployment failed
```

Write a PowerShell expression that confirms the line contains an error.

---

# Exercise 7 - Deployment Validation

Deployment output:

```text
Deployment completed successfully
```

Write a PowerShell expression that validates the deployment succeeded.

---

# Exercise 8 - Service Status Check

You receive:

```text
Service Status: Running
```

Write a PowerShell expression that verifies the service is running.

---

# Exercise 9 - Detect Failed Login

Security log entry:

```text
User login failed for user John
```

Write a PowerShell expression that detects a failed login.

---

# Exercise 10 - Azure Resource Validation

Azure deployment output:

```text
Storage Account Created Successfully
```

Write a PowerShell expression that verifies the resource creation was successful.

---

# Bonus Challenge

For each exercise above:

1. Write the PowerShell command.
2. Predict whether the result will be `True` or `False`.
3. Explain why.

Example:

```powershell
$text = "PowerShell is awesome"

$text -match "PowerShell"
```

Result:

```text
True
```

Reason:

The pattern exists in the string.
