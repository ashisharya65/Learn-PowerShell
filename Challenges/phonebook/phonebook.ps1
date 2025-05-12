<#
.SYNOPSIS
    A simple in-memory phonebook using a hashtable.

.DESCRIPTION
    Initializes an empty hashtable to store contacts, and provides cmdlets to add,
    remove, retrieve, and list contacts. Each contact is stored as a nested hashtable
    with Phone and Email properties.

.NOTES
    Author: Ashish Arya
    Date  : 2025-05-12
#>

# Hashtable to store the phonebook details
$phonebook = @{}

#region Add contact funtion
Function Add-Contact {
    <#
    .SYNOPSIS
        Adds a new contact to the phonebook.

    .DESCRIPTION
        Adds a contact under the specified name. Uses the global $phonebook hashtable
        to store a nested hashtable containing Phone and Email. Warns if the name already exists.

    .PARAMETER Name
        The unique name of the contact to add.

    .PARAMETER Phone
        The phone number for the new contact.

    .PARAMETER Email
        The email address for the new contact.

    .EXAMPLE
        Add-Contact -Name "Alice Smith" -Phone "555-1234" -Email "alice@example.com"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $Phone,

        [Parameter(Mandatory)]
        [string] $Email
    )

    if ($phonebook.ContainsKey($Name)) {
        Write-Warning "Name '$Name' exists already."
    }
    else {
        $phonebook[$Name] = @{
            Phone = $Phone
            Email = $Email
        }
        Write-Host "Added the contact for '$Name'."
    }
}
#endregion

#region Remove contact function
Function Remove-Contact {
    <#
    .SYNOPSIS
        Removes an existing contact from the phonebook.

    .DESCRIPTION
        Deletes the contact entry matching the given name from the global $phonebook hashtable.
        Warns if no such contact exists.

    .PARAMETER Name
        The name of the contact to remove.

    .EXAMPLE
        Remove-Contact -Name "Alice Smith"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Name
    )

    if (-not $phonebook.ContainsKey($Name)) {
        Write-Warning "The contact '$Name' does not exist."
    }
    else {
        $phonebook.Remove($Name) | Out-Null
        Write-Host "The contact '$Name' has been removed successfully."
    }
}
#endregion

#region Get contact function
Function Get-Contact {
    <#
    .SYNOPSIS
        Retrieves details for a single contact.

    .DESCRIPTION
        Looks up the given name in the global $phonebook hashtable. If found, outputs
        a custom object with Name, Phone, and Email properties. Otherwise warns the user.

    .PARAMETER Name
        The name of the contact to retrieve.

    .EXAMPLE
        Get-Contact -Name "Alice Smith"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Name
    )

    if ($phonebook.ContainsKey($Name)) {
        $entry = $phonebook[$Name]
        [PSCustomObject]@{
            Name  = $Name
            Phone = $entry.Phone
            Email = $entry.Email
        }
    }
    else {
        Write-Warning "The contact '$Name' does not exist."
    }
}
#endregion

#region List phonebook function
Function List-Phonebook {
    <#
    .SYNOPSIS
        Lists all contacts in the phonebook.

    .DESCRIPTION
        Outputs all entries in the global $phonebook hashtable as a formatted table,
        showing Name, Phone, and Email. Warns if the phonebook is empty.

    .EXAMPLE
        List-Phonebook
    #>
    [CmdletBinding()]
    param()

    if ($phonebook.Count -eq 0) {
        Write-Warning "The list has no contact details."
    }
    else {
        $phonebook.GetEnumerator() |
            Sort-Object Name |
            ForEach-Object {
                [PSCustomObject]@{
                    Name  = $_.Key
                    Phone = $_.Value.Phone
                    Email = $_.Value.Email
                }
            } |
            Format-Table -AutoSize
    }
}
#endregion

#region Sample usage
Add-Contact   -Name "John Doe"      -Phone "123-456-7890" -Email 'jdoe@example.com'
Add-Contact   -Name "Karen Johnson" -Phone "123-456-7890" -Email 'kjohnson@example.com'
Add-Contact   -Name "Jeff Hardy"    -Phone "123-456-7890" -Email 'jhardy@example.com'

Get-Contact   -Name "John Doe"
Remove-Contact -Name "Karen Johnson"

List-Phonebook

Add-Contact   -Name "Alex Watson"   -Phone "123-672-3313" -Email 'awatson@example.com'
List-Phonebook
#endregion
