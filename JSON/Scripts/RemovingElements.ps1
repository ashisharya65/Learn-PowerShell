<#
  .SYNOPSIS
    Removing few elements of JSON data
  .DESCRIPTION
    This script demonstrate how we can remove some of the elements from the JSON object
  .NOTES
    Author : Ashish Arya (@ashisharya65)
    Date   : 22-Sept-2022
#>


# Converting the JSON data to a PSCustom Object using ConvertFrom-JSON cmdlet
$JSON = @"
{
  "First Name" : "Rishabh",
  "Last Name" : "Gupta",
  "Date of Birth" : "05 April 1989",
  "Marital Status" : "Single",
  "Company" : "XYZCorp",
  "Designation" : "Analyst - IT Ops",
  "Experience" : "8 years",
  "Primary Skills" : "PowerShell",
  "Secondary Skills" : "Bash",
  "DOJ" : "16 August 2022",
  "Location" : "Mumbai",
  "Home Address" : "Lajpat Nagar UP",
  "Asset Build" : "Dell Laptop"
}
"@ | ConvertFrom-Json

# elements which are required to be deleted from the JSON data
$elements = @("Secondary Skills", "Asset Build")

# Looping over all the element in the JSON data and removing the concerned elements.
foreach ($key in ($JSON.Psobject.Properties.Name)) {
  foreach ($element in $elements) {
    if ($element -eq $key) {
      $JSON.Psobject.Properties.Remove($element)
    }
  }
}

# Converting the data again to JSON format
$JSON | ConvertTo-Json



### Output ######

<#
 "First Name": "Rishabh",
  "Last Name": "Gupta",
  "Date of Birth": "05 April 1989",
  "Marital Status": "Single",
  "Company": "XYZCorp",
  "Designation": "Analyst - IT Ops",
  "Experience": "8 years",
  "Primary Skills": "PowerShell",
  "DOJ": "16 August 2022",
  "Location": "Mumbai",
  "Home Address": "Lajpat Nagar UP"
 #>
