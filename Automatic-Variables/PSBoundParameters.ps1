function Invoke-PSBoundParametersAction {
    [cmdletbinding()]
    param(
        $ParamOne,
        $ParamTwo,
        $ParamThree
    )

    Begin {
        #setup our return object
        $result = [PSCustomObject]@{
            SuccessOne = $false
            SuccessTwo = $false
        }        
    }
    
    Process {
        #use a switch statement to take actions based on passed in parameters
        switch ($PSBoundParameters.Keys) {

            'ParamOne' {
                #perform actions if ParamOne is used
                $result.SuccessOne = $true
            }
            
            'ParamTwo' {  
                #perform logic if ParamTwo is used
                $result.SuccessTwo = $true

            }
            Default {   
                Write-Warning "Unhandled parameter -> [$($_)]"
            }
        }        
    }
    
    End {
        return $result
    }
}

# Calling the function with no parameters
Invoke-PSBoundParametersAction 

# Calling the function with parameter paramone
Invoke-PSBoundParametersAction -paramone 'Ashish'

# Calling the function with both parameters paramone & paramtwo
Invoke-PSBoundParametersAction -paramone 'Ashish' -paramtwo 'Arya'

# Calling the function with third parameter paranthree
Invoke-PSBoundParametersAction -ParamThree 'Ashish Arya'

##########################OUTPUT##################################
<#
Invoke-PSBoundParametersAction

SuccessOne SuccessTwo
---------- ----------
     False      False
   
Invoke-PSBoundParametersAction -paramone 'Ashish'                                                                                               pwsh   96  20:20:11  

SuccessOne SuccessTwo
---------- ----------
      True      False

Invoke-PSBoundParametersAction -paramone 'Ashish' -paramtwo 'Arya'                                                                              pwsh   96  20:22:06  

SuccessOne SuccessTwo
---------- ----------
      True       True
      
Invoke-PSBoundParametersAction -ParamThree 'Ashish Arya'                                                                                        pwsh   96  20:22:31  
WARNING: Unhandled parameter -> [ParamThree]

SuccessOne SuccessTwo
---------- ----------
     False      False

#>
##########################OUTPUT##################################
