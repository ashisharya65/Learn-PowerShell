<#
    Accessing elements of a Two Dimensional Array
#>

#Defining Array of Arrays
$AllUserdetails = 
@(@("Ashish","Arya","30"),@("Karan","Singh","20"),@("Naveen","Arya","29"))

write-host "Accessing Elements of the array" -forground "Green"
for ($i = 0; $i -lt ($AllUserdetails.Length); $i++) {
    for ($j = 0; $j -lt ($AllUserdetails.Length); $j++) {
       
        write-host "Element at $($i) row and $($j) column in the array is : $($AllUserdetails[$i][$j])" -ForegroundColor Green
       
    }
}

