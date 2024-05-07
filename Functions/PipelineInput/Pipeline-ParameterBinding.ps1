
######################################################################################################################################################

                                                # Accepting Pipeline Input (Parameter Binding) ByPropertyName #                                                          

######################################################################################################################################################



function Get-Something {
    [cmdletbinding()]
    param(
        $value
    )

    Write-Host "You passed the value $value to the function"
}

"PowerShell is awesome" | Get-Something

function Get-Something{
    [CmdletBinding()]
    param(
        [Parameter]
        $value
    )
    Write-Host "You passed the value $value to the function."
}

"PowerShell is awesome" | Get-Something


function Get-Something{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        $value
    )
    Write-Host "You passed the value $value to the function."
}

Get-Service -Name wuauserv | Get-Something


function Get-Something{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        $name
    )
    Write-Host "You passed the value $name to the function."
}

Get-Service -Name wuauserv | Get-Something


######################################################################################################################################################

                                                # Accepting Pipeline Input (Parameter Binding) ByValue #                                                          

######################################################################################################################################################

function Get-Something{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $Service
    )
    Write-Host "You passed the value $($Service.Name) to the function."
}

Get-Service -Name wuauserv | Get-Something