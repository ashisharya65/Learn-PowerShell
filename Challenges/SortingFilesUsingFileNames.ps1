<#
    Write a script to sort the file names (with below mentioned filenames) based on the numbers in an incrementing way:
    K1__test_process.js","K3__process.js","K2__qa_testing.js","K10__dimensions.js","K5__closed_loop_testing.js

#>

$Files = @("K1__test_process.js","K3__process.js","K2__qa_testing.js","K10__dimensions.js","K5__closed_loop_testing.js")
#################################################################################################################
# First Method : MY WAY
###############################

$Files | ForEach-Object {[PSCustomObject]@{
    Name = $_
    SortingProperty = [int] ($_ | ForEach-Object {($_.ToString().Split("__")[0]) -replace "[^0-9]"}) 
}
} | Sort-Object -Property SortingProperty | Select-object Name

#################################################################################################################

# Second Method
###############################

$Files = @("K1__test_process.js","K3__process.js","K2__qa_testing.js","K10__dimensions.js","K5__closed_loop_testing.js")
$Files | sort-object {if ($_ -match '(\d+)'){[int]$matches[1]}}

#################################################################################################################

# Third Method
###############################

$Files | Sort-Object { $_ -replace 'K|_.+' -as [int] }


#################################################################################################################

<#
Output

K1__test_process.js
K2__qa_testing.js
K3__process.js
K5__closed_loop_testing.js
K10__dimensions.js

#>
