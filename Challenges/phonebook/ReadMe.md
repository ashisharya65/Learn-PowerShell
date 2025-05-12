## Problem Statement

You are tasked with developing a simple in-memory Phonebook Manager in PowerShell that demonstrates your understanding of hashtables, functions (cmdlets), and comment-based help. Your solution will allow users to add, remove, retrieve, and list contacts—each identified by a unique name and storing a phone number and email address. You will also document each function using PowerShell’s standard comment-based help syntax.

---

### Requirements

1. **Data Structure**  
   - Use a single top-level hashtable named `$Phonebook`  
   - **Keys**: contact names (strings)  
   - **Values**: nested hashtables containing two properties:  
     - `Phone` (string)  
     - `Email` (string)  

2. **Cmdlets / Functions**  
   Implement the following functions with proper parameter validation and error handling:
   - **`Add-Contact`**  
     - Adds a new entry to `$Phonebook`  
     - Warns if the contact name already exists  
   - **`Remove-Contact`**  
     - Removes an entry by name  
     - Warns if the contact does not exist  
   - **`Get-Contact`**  
     - Retrieves and displays a single contact’s details as a `PSCustomObject`  
     - Warns if the contact does not exist  
   - **`List-Phonebook`**  
     - Lists all entries in a formatted table sorted by name  
     - Warns if the phonebook is empty  

3. **Comment-Based Help**  
   For each function, include:
   - A `<# .SYNOPSIS ... #>` section  
   - A `<# .DESCRIPTION ... #>` section  
   - `<# .PARAMETER ... #>` blocks for each parameter  
   - At least one `<# .EXAMPLE ... #>` block  
   - Script-level help with `.SYNOPSIS`, `.DESCRIPTION`, and `.NOTES`

4. **Sample Usage**  
   - Demonstrate in the script adding at least three contacts  
   - Retrieve one contact  
   - Remove one contact  
   - List all contacts  

---
