# Module 02 - Exercises

## Objective

Practice Literal Matching using PowerShell Regex.

For each exercise:

1. Write the PowerShell command.
2. Predict the output.
3. Explain why the result occurs.

Do not use Google or any Regex cheat sheet.

---

# Exercise 1 - Application Log Monitoring

You receive the following log entry:

```text
[ERROR] Database connection failed
```

Write a PowerShell expression that verifies the log contains:

```text
ERROR
```

---

# Exercise 2 - Azure Deployment Validation

Deployment Output:

```text
Deployment completed successfully
```

Write a PowerShell expression that confirms the deployment was successful.

---

# Exercise 3 - Windows Service Monitoring

Service Status:

```text
Service Status: Running
```

Write a PowerShell expression that confirms the service is running.

---

# Exercise 4 - VM Health Check

Machine Name:

```text
AzureVM01
```

Write a PowerShell expression that verifies the machine name contains:

```text
VM
```

---

# Exercise 5 - Storage Account Validation

Azure Resource:

```text
StorageAccount01
```

Write a PowerShell expression that verifies the text contains:

```text
Account
```

---

# Exercise 6 - Detect Failed Login

Security Event:

```text
User login failed for user Ashish
```

Write a PowerShell expression that detects the word:

```text
failed
```

---

# Exercise 7 - CI/CD Pipeline Verification

Pipeline Output:

```text
Build completed successfully
```

Write a PowerShell expression that validates the build succeeded.

---

# Exercise 8 - Kubernetes Deployment Check

Deployment Message:

```text
Pod deployment completed
```

Write a PowerShell expression that confirms the deployment completed.

---

# Exercise 9 - Active Directory User Validation

User Name:

```text
IND-Ashish-Arya
```

Write a PowerShell expression that confirms the username contains:

```text
Ashish
```

---

# Exercise 10 - File Processing

File Name:

```text
ServerInventory.csv
```

Write a PowerShell expression that verifies the file name contains:

```text
Inventory
```

---

# Exercise 11 - Predict the Output

Predict the output:

```powershell
"AzureVM01" -match "VM"
```

---

# Exercise 12 - Predict the Output

Predict the output:

```powershell
"AzureVM01" -match "AWS"
```

---

# Exercise 13 - Predict the Output

Predict the output:

```powershell
"PowerShell" -match "Shell"
```

---

# Exercise 14 - Predict the Output

Predict the output:

```powershell
"StorageAccount01" -match "Storage"
```

---

# Exercise 15 - Predict the Output

Predict the output:

```powershell
"StorageAccount01" -match "VirtualMachine"
```

---

# Exercise 16 - Understanding $Matches

Execute:

```powershell
"AzureVM01" -match "VM"
```

What value will be stored in:

```powershell
$Matches[0]
```

---

# Exercise 17 - Understanding $Matches

Execute:

```powershell
"StorageAccount01" -match "Account"
```

What value will be stored in:

```powershell
$Matches[0]
```

---

# Exercise 18 - Troubleshooting

A colleague wrote:

```powershell
"PowerShell" -match "AWS"
```

But expected the result to be True.

Explain why the result is incorrect.

---

# Exercise 19 - Real World Challenge

You are validating deployment logs.

The deployment output contains:

```text
Storage Account Created Successfully
```

Write a PowerShell expression to verify resource creation succeeded.

---

# Exercise 20 - Challenge

You have the following server names:

```text
Server01
Server02
Server03
Server04
Server05
```

Explain why writing separate literal matches for each server is not scalable.

(Hint: This question prepares you for Character Classes in the next module.)

---
