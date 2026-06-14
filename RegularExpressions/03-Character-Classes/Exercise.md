# Module 03 - Character Classes

## Objective

Practice using Character Classes (`[]`) to identify digits, uppercase letters, lowercase letters, and combinations of characters in real-world PowerShell scenarios.

For every exercise:

1. Write the PowerShell command.
2. Predict the output.
3. Explain why.

Do not use online Regex testers or AI assistance while solving.

---

# Exercise 1 - Detect Digits in a Server Name

Server Name:

```text
Server01
```

Write a PowerShell expression that verifies the string contains at least one digit.

Expected Regex:

```regex
[0-9]
```

---

# Exercise 2 - Detect Digits in an Azure Resource

Resource Name:

```text
StorageAccount99
```

Write a PowerShell expression that confirms the resource name contains numbers.

---

# Exercise 3 - Validate Build Number

Build Version:

```text
Build-2026
```

Write a PowerShell expression that confirms the string contains digits.

---

# Exercise 4 - Detect Lowercase Letters

Username:

```text
ashish
```

Write a PowerShell expression that verifies the string contains lowercase letters.

Expected Regex:

```regex
[a-z]
```

---

# Exercise 5 - Detect Uppercase Letters

Username:

```text
ASHISH
```

Write a PowerShell expression that verifies the string contains uppercase letters.

Expected Regex:

```regex
[A-Z]
```

---

# Exercise 6 - Mixed Case Validation

Application Name:

```text
PowerShell
```

Write two PowerShell expressions:

1. One that confirms lowercase letters exist.
2. One that confirms uppercase letters exist.

---

# Exercise 7 - Active Directory User Validation

User:

```text
IND-Ashish-Arya
```

Write a PowerShell expression that confirms the username contains uppercase letters.

---

# Exercise 8 - Log Analysis

Log Entry:

```text
User ID: 45892
```

Write a PowerShell expression that confirms the log entry contains numbers.

---

# Exercise 9 - Azure Subscription Validation

Subscription Reference:

```text
SUB-12345
```

Write a PowerShell expression that verifies the string contains digits.

---

# Exercise 10 - Detect Letters

Input:

```text
123ABC456
```

Write a PowerShell expression that confirms the string contains uppercase letters.

---

# Exercise 11 - Predict the Output

```powershell
"Server01" -match "[0-9]"
```

What will be the output?

---

# Exercise 12 - Predict the Output

```powershell
"Server" -match "[0-9]"
```

What will be the output?

---

# Exercise 13 - Predict the Output

```powershell
"ASHISH" -match "[A-Z]"
```

What will be the output?

---

# Exercise 14 - Predict the Output

```powershell
"ashish" -match "[A-Z]"
```

What will be the output?

Important:

Remember that PowerShell regex matching is case-insensitive by default.

Explain your answer.

---

# Exercise 15 - Understanding Character Classes

Given:

```regex
[ABC]
```

Which of the following match?

```text
A
B
C
D
```

Explain why.

---

# Exercise 16 - Understanding Ranges

Given:

```regex
[0-9]
```

Which of the following match?

```text
5
9
0
A
#
```

Explain why.

---

# Exercise 17 - Cloud Engineering Scenario

Deployment Output:

```text
VM01 deployed successfully
```

Write a PowerShell expression that confirms the deployment output contains at least one digit.

---

# Exercise 18 - Platform Engineering Scenario

Host Name:

```text
PLATFORM-SRV-07
```

Write a PowerShell expression that confirms the hostname contains numbers.

---

# Exercise 19 - Security Monitoring Scenario

Security Event:

```text
User123 failed authentication
```

Write a PowerShell expression that confirms the event contains digits.

---

# Exercise 20 - Challenge

You have the following machine names:

```text
APP01
APP02
APP03
APP04
APP05
```

Using Character Classes, explain why:

```regex
[0-9]
```

is more scalable than writing:

```regex
APP01
APP02
APP03
APP04
APP05
```

individually.

---

# Bonus Challenge 1

Predict the output:

```powershell
"AzureVM01" -match "[A-Z]"
```

---

# Bonus Challenge 2

Predict the output:

```powershell
"12345" -match "[a-z]"
```

---

# Bonus Challenge 3

Predict the output:

```powershell
"Azure123" -match "[0-9]"
```

---

# Submission Format

Reply using:

```text
Exercise 1:
<PowerShell Command>

Output:
<True/False>

Explanation:
...

Exercise 2:
...
```
