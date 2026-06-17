# Module 11 — Performance, Optimization & Regex Pitfalls

---

## 1. Why Performance Matters

Most regex patterns run in milliseconds. But some patterns on large inputs can take **seconds, minutes, or even forever** to complete. This is called **catastrophic backtracking**.

Understanding why it happens — and how to avoid it — makes you a regex expert, not just a user.

---

## 2. Catastrophic Backtracking — The Biggest Pitfall

### What Causes It

Catastrophic backtracking happens when a pattern has **multiple quantifiers** that overlap and the pattern ultimately fails. The regex engine tries every possible combination before giving up.

### A Classic Example

```powershell
# This pattern looks fine:
$pattern = '^(a+)+$'

# Works fast on a match:
'aaaaaaaaaa' -match $pattern   # Fast — True

# CATASTROPHIC on a near-match (extra character at end):
'aaaaaaaaaab' -match $pattern  
# This can take seconds or minutes! The engine tries:
# (a)(a)(a)(a)...(a) then finds 'b' — fail
# (aa)(a)(a)...(a) then finds 'b' — fail
# (a)(aa)(a)...(a) then finds 'b' — fail
# ... exponential combinations!
```

### Why It Happens

`(a+)+` means "one or more a's, one or more times." For a string of n a's, there are **2^(n-1)** ways to split them into groups. Each split is tried on failure.

### Patterns That Cause It

Look out for these anti-patterns:

```
(a+)+     # Nested quantifiers on same character
(a|aa)+   # Overlapping alternatives with quantifiers
(a*)*     # Nested star quantifiers
```

---

## 3. How to Fix It — Atomic Groups

An **atomic group** `(?>...)` tells the regex engine: once matched, **never backtrack into this group**. This prevents the exponential explosion.

```powershell
# Catastrophic:
$pattern = '^(a+)+$'

# Fixed with atomic group:
$pattern = '^(?>a+)+$'

# Or more naturally, just rewrite to avoid nesting:
$pattern = '^a+$'   # Much simpler and no backtracking issue
```

```powershell
# Another example:
# Catastrophic:
'".*"'

# Fixed (using lazy quantifier):
'".*?"'

# Or using a negated class (fastest):
'"[^"]*"'   # Match everything that's NOT a quote, inside quotes
```

### Use Negated Classes Instead of Dot

```powershell
# SLOW — greedy dot can backtrack a lot:
'"(.+)"'

# FAST — negated class cannot match the delimiter, so no backtracking:
'"([^"]*)"'

# Same approach for other delimiters:
# Between tags:     <([^>]*)>  instead of <(.+?)>
# Between parens:   \(([^)]*)\) instead of \((.+?)\)
```

---

## 4. Compiled Regex — Faster Repeated Use

By default, PowerShell compiles a regex pattern the first time it is used and caches it. For patterns used **many thousands of times**, explicitly compiling gives better performance.

```powershell
# Without compilation — interpreted each time context changes
$pattern = '\d{1,3}(?:\.\d{1,3}){3}'

# With explicit compilation — faster for repeated heavy use
$rx = [regex]::new($pattern, [System.Text.RegularExpressions.RegexOptions]::Compiled)

# Reuse the compiled object
1..10000 | ForEach-Object {
    $rx.IsMatch("192.168.$_.1")
}
```

> **When to compile:** If you run the same pattern on **thousands of strings** in a loop. For occasional matches, the default caching is sufficient.

---

## 5. Benchmarking with `Measure-Command`

Always benchmark before and after optimization:

```powershell
# Generate test data
$testData = 'a' * 20 + 'b'   # 20 a's followed by b (near-miss)

# Measure catastrophic pattern
Measure-Command {
    1..100 | ForEach-Object { $testData -match '^(a+)+$' }
} | Select-Object TotalSeconds

# Measure safe pattern
Measure-Command {
    1..100 | ForEach-Object { $testData -match '^a+$' }
} | Select-Object TotalSeconds
```

---

## 6. Common Mistakes

### Mistake 1 — Forgetting Anchors (Partial Match Accepted)

```powershell
# Goal: validate the string is ONLY digits
# WRONG — partial match succeeds
'123abc' -match '\d+'    # True! But we wanted False

# CORRECT — anchors enforce full string match
'123abc' -match '^\d+$'  # False — correct!
```

### Mistake 2 — Over-Escaping

```powershell
# Unnecessary escaping (still works but confusing)
'test' -match '\t\e\s\t'   # Don't do this

# \e is an escape character, \s is whitespace shorthand
# The correct literal is just:
'test' -match 'test'
```

### Mistake 3 — Using Dot When You Mean a Specific Character

```powershell
# WRONG — dot matches any character
'192.168.1.1' -match '192.168.1.1'    # True, but so is:
'192X168X1X1' -match '192.168.1.1'    # True! ← Not what you want

# CORRECT — escape the literal dots
'192.168.1.1' -match '192\.168\.1\.1'
'192X168X1X1' -match '192\.168\.1\.1'  # False — correct!
```

### Mistake 4 — Greedy Trap

```powershell
# WRONG — greedy match consumes too much
'<b>text</b> and <i>more</i>' -match '<.+>'
$Matches[0]   # '<b>text</b> and <i>more</i>'  ← too much

# CORRECT — lazy or negated class
'<b>text</b> and <i>more</i>' -match '<[^>]+>'
$Matches[0]   # '<b>'  ← just the first tag
```

### Mistake 5 — Trusting `$Matches` Without Checking `-match` Result

```powershell
# WRONG
ProcessLog($line)
Write-Host $Matches[1]   # May be from a previous match!

# CORRECT
if ($line -match 'Error (\d+)') {
    Write-Host $Matches[1]
}
```

### Mistake 6 — Case Sensitivity Assumption

```powershell
# Assuming case-sensitive (like other languages) — WRONG in PowerShell
'HELLO' -match 'hello'    # True! PowerShell is case-insensitive by default

# When case matters — be explicit
'HELLO' -cmatch 'hello'   # False — correct case-sensitive check
```

---

## 7. When NOT to Use Regex

Regex is not always the right tool. Use simpler alternatives when possible:

| Task | Simpler Alternative |
|---|---|
| Exact string match | `$str -eq 'value'` |
| Contains substring | `$str.Contains('value')` |
| Starts with | `$str.StartsWith('prefix')` |
| Ends with | `$str.EndsWith('suffix')` |
| Parse structured data | `ConvertFrom-Json`, `Import-Csv`, `[xml]` |
| Parse HTML/XML | Use `[xml]` or a proper parser |
| Arithmetic on extracted numbers | Extract first, then calculate |

```powershell
# DON'T use regex for simple string checks
if ($filename -match 'log') { ... }         # Overkill

# DO use simple string methods
if ($filename.Contains('log')) { ... }      # Clearer and faster
if ($filename.EndsWith('.log')) { ... }     # Even more specific
```

---

## 8. Quick Reference — Do's and Don'ts

```
DO:
  ✅ Anchor patterns when you want full-string validation (^...$)
  ✅ Use negated classes [^x] instead of dot for delimited content
  ✅ Use lazy quantifiers +? when matching between delimiters
  ✅ Use [regex]::Escape() for user-supplied search terms
  ✅ Check -match return value before using $Matches
  ✅ Compile patterns used thousands of times
  ✅ Benchmark with Measure-Command when performance matters

DON'T:
  ❌ Use (a+)+ or similar nested quantifiers
  ❌ Use .+ when [^delimiter]+ would work
  ❌ Trust $Matches without checking -match returned True
  ❌ Use regex for exact equality or simple contains checks
  ❌ Use regex to parse JSON, HTML, or XML
  ❌ Forget -cmatch when case-sensitivity is required
  ❌ Over-escape characters that don't need escaping

PERFORMANCE ORDER (fastest to slowest):
  1. Literal string methods (.Contains, .StartsWith, -eq)
  2. Anchored regex (^pattern$)
  3. Negated class [^x]+
  4. Lazy quantifier +?
  5. Greedy .+  (avoid for delimited content)
  6. Nested quantifiers (a+)+ ← AVOID
```
