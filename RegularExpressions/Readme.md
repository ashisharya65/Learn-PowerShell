# 🎯 PowerShell Regular Expression Mastery

Welcome to the ultimate repository for mastering Regular Expressions (Regex) specifically tailored for **PowerShell** and the **.NET regex engine**. 

Whether you are automating cloud infrastructure parsing, auditing security logs, or sanitizing complex data streams, this repository serves as your structured, hands-on guide to evolving from a regex novice to an enterprise-grade pattern engineer.

## 🚀 Why PowerShell Regex?

PowerShell doesn't just use standard regex—it leverages the incredibly robust **.NET Regular Expression Engine**. This gives you advanced capabilities out of the box, such as:
* **Variable-length lookbehinds** (a rare superpower compared to other engines).
* Seamless integration via native operators (`-match`, `-replace`, `-split`).
* Direct access to the accelerated `[regex]` accelerator and underlying .NET classes.
* Deep integration with `switch -Regex` for high-performance multi-pattern dispatching.

---

## 📚 Module Details

### Module 01 — Regex Foundations & PowerShell Operators
* What is a regular expression and why it matters
* Literal matching vs. metacharacter matching
* PowerShell regex operators: `-match`, `-notmatch`, `-cmatch`, `-imatch`
* The automatic `$Matches` hashtable
* Case sensitivity in PowerShell regex (default case-insensitive)
* Escaping special characters with `\` and `[regex]::Escape()`

### Module 02 — Character Classes & Shorthand Escapes
* Character classes: `[abc]`, `[a-z]`, `[0-9]`
* Negated classes: `[^abc]`
* POSIX-style vs. .NET-style classes
* Shorthand escapes: `\d`, `\D`, `\w`, `\W`, `\s`, `\S`
* The dot `.` metacharacter and its behavior
* Unicode category escapes: `\p{L}`, `\p{N}`, etc.

### Module 03 — Quantifiers — Greedy, Lazy & Possessive
* `*` (zero or more), `+` (one or more), `?` (zero or one)
* Exact repetition: `{n}`, `{n,}`, `{n,m}`
* Greedy vs. lazy quantifiers (`*?`, `+?`, `??`, `{n,m}?`)
* Understanding backtracking
* When and why greedy causes unexpected results

### Module 04 — Anchors, Boundaries & Multiline Mode
* `^` (start of string) and `$` (end of string)
* `\A` (absolute start) and `\Z` / `\z` (absolute end)
* Word boundaries: `\b` and `\B`
* Multiline mode: `(?m)` — how `^` and `$` change behavior
* Singleline mode: `(?s)` — how `.` changes behavior

### Module 05 — Grouping, Capturing & Backreferences
* Parentheses `()` for grouping
* Captured groups and `$Matches[1]`, `$Matches[2]`, etc.
* Backreferences: `\1`, `\2` inside the pattern
* Named captures: `(?<name>pattern)` and `$Matches['name']`
* Nested groups and group numbering rules

### Module 06 — Alternation & Non-Capturing Groups
* The pipe `|` for alternation (OR logic)
* Order matters in alternation
* Non-capturing groups: `(?:pattern)`
* Combining alternation with quantifiers
* Inline modifiers: `(?i)`, `(?s)`, `(?m)`, `(?x)`
* Free-spacing mode `(?x)` for readable patterns

### Module 07 — Lookahead & Lookbehind Assertions
* Positive lookahead: `(?=pattern)`
* Negative lookahead: `(?!pattern)`
* Positive lookbehind: `(?<=pattern)`
* Negative lookbehind: `(?<!pattern)`
* Combining lookarounds for complex assertions
* Variable-length lookbehind in .NET (unique advantage)

### Module 08 — The `[regex]` .NET Class & Named Captures
* `[regex]::Match()` and `[regex]::Matches()` — single vs. all matches
* `[regex]::Replace()` with match evaluators / script blocks
* `[regex]::Split()`
* `[regex]::IsMatch()` — boolean test
* `RegexOptions` flags: `IgnoreCase`, `Multiline`, `Singleline`, `Compiled`, etc.
* `Match` object properties: `.Value`, `.Index`, `.Length`, `.Groups`, `.Success`

### Module 09 — `switch -Regex`, `-replace`, and `-split`
* `switch -Regex` for multi-pattern dispatching
* `-replace` operator with capture-group substitution (`$1`, `${name}`)
* `-replace` with script block evaluators (PowerShell 6+)
* `-split` operator with regex delimiters
* `-split` with capture groups to keep delimiters
* Combining operators in pipelines

### Module 10 — Real-World Patterns — Logs, IPs, Emails, Paths
* Parsing Windows Event Logs with regex
* Validating and extracting IPv4 / IPv6 addresses
* Extracting email addresses and URLs
* Parsing file paths (UNC, drive-letter, Linux)
* Parsing structured text: CSV edge cases, INI files, registry exports
* Building a reusable pattern library

### Module 11 — Performance, Optimization & Regex Pitfalls
* Catastrophic backtracking and how to avoid it
* Atomic groups: `(?>pattern)`
* Compiled regex: `[regex]::new($pattern, 'Compiled')`
* Benchmarking regex with `Measure-Command`
* Common mistakes: over-escaping, greedy traps, anchoring failures
* When NOT to use regex (and what to use instead)

### Module 12 — Capstone — Build a PowerShell Log Analyzer
* Parse multi-format log files (IIS, Syslog, custom)
* Extract timestamps, severity, source, and message
* Build summary statistics with `Group-Object`
* Export clean, structured data
* Full code review and optimization pass

---

## 🛠️ How to Use This Repo
1.  **Navigate By Module:** Each directory contains an `README.md` breakdown of the concept, a `.ps1` file containing runnable syntax examples, and a challenge lab.
2.  **Run Examples:** Open your terminal or VS Code, load up the module scripts, and run the snippets natively to see how the `$Matches` engine behaves in real-time.

> [!NOTE]
> Each module strictly builds on the foundation of the previous one. We go deep on mechanics, not just quick copy-paste hacks. Try to complete the practice challenges before checking the solutions!
