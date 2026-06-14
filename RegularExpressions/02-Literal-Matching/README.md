# Module 2 - Literal Matching

## Learning Objectives

By the end of this module, you will be able to:

- Understand what literal matching is.
- Match exact text using Regex.
- Use literal matching with PowerShell's `-match` operator.
- Understand how Regex scans text.
- Recognize the limitations of literal matching.
- Prepare for Character Classes in the next module.

---

# What is Literal Matching?

Literal matching means:

> Match the exact characters as they appear.

Example:

Text:

```text
PowerShell
```

Regex:

```regex
PowerShell
```

Result:

```text
Match Found
```

The Regex engine looks for the exact sequence of characters.

---

# Visual Explanation

Text:

```text
AzureVirtualMachine
```

Pattern:

```regex
Virtual
```

Regex Engine:

```text
Azure[Virtual]Machine
```

Match Found.

---

# PowerShell Example

```powershell
"PowerShell" -match "Shell"
```

Output:

```powershell
True
```

Because the text contains the exact sequence:

```text
Shell
```

---

# Literal Matching Is Not Whole Word Matching

Many beginners assume:

```powershell
"PowerShell" -match "Shell"
```

should return False because the entire word isn't matched.

Wrong.

Regex searches for the pattern anywhere in the string.

Result:

```powershell
True
```

---

# More Examples

Example 1

```powershell
"AzureVM01" -match "VM"
```

Output:

```powershell
True
```

---

Example 2

```powershell
"AzureVM01" -match "AWS"
```

Output:

```powershell
False
```

---

Example 3

```powershell
"StorageAccount" -match "Account"
```

Output:

```powershell
True
```

---

# Real-World Example: Log Monitoring

Log Entry:

```text
[ERROR] Deployment Failed
```

Check whether the line contains ERROR.

```powershell
$logLine -match "ERROR"
```

Output:

```powershell
True
```

---

# Real-World Example: Azure Deployments

Deployment Output:

```text
Deployment completed successfully
```

Validation:

```powershell
$output -match "successfully"
```

Result:

```powershell
True
```

Many deployment validation scripts start exactly like this.

---

# Understanding Successful Matches

When a match succeeds:

```powershell
"AzureVM01" -match "VM"
```

PowerShell automatically creates:

```powershell
$Matches
```

Contents:

```powershell
Name  Value
----  -----
0     VM
```

The matched text is stored.

---

# Limitation of Literal Matching

Suppose you have:

```text
Server01
Server02
Server03
Server04
```

Literal matching can find:

```regex
Server01
```

But it cannot easily express:

```text
Any server number
```

For that, we need Character Classes.

That is what we'll learn next.

---

# Common Beginner Mistakes

## Mistake 1

Expecting exact string equality.

```powershell
"PowerShell" -match "Shell"
```

Returns:

```powershell
True
```

because Regex searches inside strings.

---

## Mistake 2

Using Regex when simple equality would work.

Instead of:

```powershell
$name -match "John"
```

Sometimes:

```powershell
$name -eq "John"
```

is cleaner.

Use Regex only when pattern matching is required.

---

# Interview Notes

## What is Literal Matching?

Matching an exact sequence of characters.

---

## Does Regex Require Special Symbols?

No.

A Regex can be as simple as:

```regex
PowerShell
```

---

## What Does This Return?

```powershell
"AzureVM01" -match "VM"
```

Answer:

```powershell
True
```

because the pattern exists in the string.

---

# Module Summary

You learned:

- What literal matching is
- How Regex finds exact text
- How `-match` performs literal matching
- How PowerShell populates `$Matches`
- Real-world uses in logs and cloud automation
- Why literal matching alone is not enough

Next Module:

## Module 3 - Character Classes

This is where Regex becomes truly powerful.

You'll learn patterns like:

```regex
[0-9]
[a-z]
[A-Z]
```

and start matching categories of characters instead of exact text.
