<#
    Playing with Array of PSCustomObjects.
#>

#Array of Custom Objects to display user details 
$AllUserdetails = 
@([PSCustomObject]@{
        FirstName = "Ashish"
        LastName  = "Arya"
        Age       = "30"
    },
    [PSCustomObject]@{
        FirstName = "Karan"
        LastName  = "Singh"
        Age       = "20"
    },
    [PSCustomObject]@{
        FirstName = "Naveen"
        LastName  = "Arya"
        Age       = "29"
    }
)

#Displaying the elements of the array
for ($i = 0; $i -lt ($AllUserdetails.Length); $i++) {
    
        $AllUserdetails[$i] | Select-Object FirstName, LastName, Age
    
  
}


######################################################################################

<#
Output
########

FirstName LastName Age
--------- -------- ---
Ashish    Arya     30
Karan     Singh    20
Naveen    Arya     29

#>
