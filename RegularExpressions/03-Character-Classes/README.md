
# Module 03 - Character Classes

## Learning Objectives

By the end of this module, you will be able to:

* Understand what Character Classes are.
* Match a single character from a set of characters.
* Match digits, letters, and combinations of characters.
* Use ranges such as `[0-9]`, `[a-z]`, and `[A-Z]`.
* Understand how Character Classes make Regex scalable.
* Apply Character Classes in PowerShell automation scenarios.

---

# The Problem with Literal Matching

Suppose you have the following server names:

```text
Server01
Server02
Server03
Server04
Server05
```

Using literal matching, you would need:

```regex
Server01
```

or

```regex
Server02
```

or

```regex
Server03
```

This quickly becomes difficult to maintain.

Regex provides a better solution.

---

# What is a Character Class?

A Character Class allows us to match **one character from a group of characters**.

Syntax:

```regex
[characters]
```

Example:

```regex
[ABC]
```

This means:

```text
Match either:
A
B
C
```

---

# Example

Text:

```text
B
```

Regex:

```regex
[ABC]
```

Result:

```text
Match Found
```

Because B exists in the character class.

---

# Matching Digits

One of the most common Character Classes:

```regex
[0-9]
```

Meaning:

```text
Match any single digit from 0 through 9
```

Examples:

```text
0
1
5
8
9
```

All match.

---

# PowerShell Example

```powershell
"Server01" -match "[0-9]"
```

Output:

```powershell
True
```

Because the string contains:

```text
0
1
```

which are digits.

---

# Understanding Character Ranges

Instead of writing:

```regex
[0123456789]
```

Regex allows:

```regex
[0-9]
```

Both mean the same thing.

The second version is cleaner.

---

# Lowercase Letters

Regex:

```regex
[a-z]
```

Meaning:

```text
Any lowercase letter
```

Examples:

```text
a
b
c
x
y
z
```

All match.

---

# PowerShell Example

```powershell
"Azure" -match "[a-z]"
```

Output:

```powershell
True
```

Because the string contains lowercase letters.

---

# Uppercase Letters

Regex:

```regex
[A-Z]
```

Meaning:

```text
Any uppercase letter
```

Example:

```powershell
"Azure" -match "[A-Z]"
```

Output:

```powershell
True
```

Because:

```text
A
```

is uppercase.

---

# Combining Character Classes

You can combine ranges.

Regex:

```regex
[A-Za-z]
```

Meaning:

```text
Any uppercase OR lowercase letter
```

Examples:

```text
A
Z
a
z
M
p
```

All match.

---

# Real-World Example: Server Names

Server Names:

```text
Server01
Server02
Server03
```

Regex:

```regex
[0-9]
```

allows you to identify whether a server name contains numbers.

PowerShell:

```powershell
"Server03" -match "[0-9]"
```

Output:

```powershell
True
```

---

# Real-World Example: Azure Resource Validation

Azure Resource:

```text
StorageAccount01
```

Check whether the name contains digits:

```powershell
"StorageAccount01" -match "[0-9]"
```

Output:

```powershell
True
```

---

# Real-World Example: User Validation

Username:

```text
Ashish123
```

Check whether the username contains numbers:

```powershell
"Ashish123" -match "[0-9]"
```

Output:

```powershell
True
```

---

# Character Classes Match One Character

This is extremely important.

Regex:

```regex
[0-9]
```

does NOT mean:

```text
Match all digits
```

It means:

```text
Match one digit
```

If at least one digit exists, a match is found.

---

# Common Beginner Mistakes

## Mistake 1

Thinking:

```regex
[0-9]
```

matches:

```text
12345
```

It doesn't.

It matches one digit at a time.

---

## Mistake 2

Thinking:

```regex
[A-Z]
```

matches an entire word.

It only matches a single uppercase character.

---

## Mistake 3

Confusing:

```regex
ABC
```

with:

```regex
[ABC]
```

### ABC

Matches:

```text
ABC
```

exactly.

### [ABC]

Matches:

```text
A
```

or

```text
B
```

or

```text
C
```

---

# Interview Notes

## What is a Character Class?

A Character Class matches one character from a specified set of characters.

---

## What does `[0-9]` mean?

Match any single digit from 0 through 9.

---

## What does `[a-z]` mean?

Match any lowercase letter.

---

## What does `[A-Z]` mean?

Match any uppercase letter.

---

## What does `[A-Za-z]` mean?

Match any uppercase or lowercase letter.

---

# Module Summary

You learned:

* What Character Classes are
* How to match digits
* How to match lowercase letters
* How to match uppercase letters
* How to combine ranges
* How Character Classes make Regex scalable
* Common mistakes beginners make

In the next module, you'll learn **Quantifiers**.

Quantifiers answer the question:

> How many times should a character appear?

Examples:

```regex
[0-9]+
[a-z]*
[A-Z]{3}
```

This is where Regex starts becoming significantly more powerful.
