
<#
    .SYNOPSIS
        Tool built using PowerShell & WPF to modify users membership in an Azure AD group.
    
    .DESCRIPTION
        This tool will help you to Add/Remove users from an Azure AD group using the Microsoft Graph API in the backend.
        
        Pre-requisite for using this tool are :
            [ ] - An app registered in your Azure AD tenant.
            [ ] - Latest version of Microsoft Graph PowerShell module installed on your local machine.
            [ ] - Setting the Windows Environment variables in your local machine
            [ ] - A CSV file containing the users UPN details. One template for CSV file is attached in the repo.

        This tool will be checking whether the Environment variables for your Azure AD app are set or not. If not then it will be asking you to provide the
        credentials of your Azure AD app like Client id, Client secret and tenant id.
        
        This tool will also check if you have the latest version of Microsoft.Graph PowerShell module installed or not. If not, then it will be trying to install the module 
        on your local machine.
    
    .NOTES
        Author : Ashish Arya
        Date   : 04-April-2023
#>

#Load Assembly and Library
Add-Type -AssemblyName PresentationFramework

#Function definition for Adding user to the group
Function Add-UserToAADGroup{
    param(
        $UPN,
        $AADGroup
    )

    #Getting User id 
    $UserId = (Get-MgUser -Filter "userprincipalname eq '$($UPN)'").id
    
    #Getting the Group id
    $AADGroupID = (Get-MgGroup -Filter "displayName eq '$($AADGroup)'").id

    #Preparing the Json payload
    $params = @{
      "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/{$($UserId)}"
    }

    #Adding the user to the group
    New-MgGroupMemberByRef -GroupId $AADGroupID -BodyParameter $params -erroraction 'Stop'
    $ResultBox.Text = "The user $UPN was added to the $AADGroup group."
}

#Function definition for Removing user from the group
Function Remove-UserFromAADGroup{
    param(
        $UPN,
        $AADGroup
    )

    #Getting User id 
    $UserId = (Get-MgUser -Filter "userprincipalname eq '$($UPN)'").id
        
    #Getting the Group id
    $AADGroupID = (Get-MgGroup -Filter "displayName eq '$($AADGroup)'").id

    #Adding the user to the group
    Remove-MgGroupMemberByRef -GroupId $AADGroupID -DirectoryObjectId $UserId -erroraction 'Stop'

}

#Function definition for Clearing all the text boxes
Function Clear-Text {
    $CSVFilePathBox.Text = ''
    $AADGroupBox.Text = ''
    $ResultBox.Text = ''
}

#Function definition for Setting Environment Variables
Function Set-EnvtVariables {
    <#
    .SYNOPSIS
    Function set the environment variables in user context.
    .DESCRIPTION
    This script will help you to create the user environment variables on the device where you are executing this script.
    This script will ask you to provide the Clientid, ClientSecret and Tenantid from your Azure AD app created for PowerShell-Graph API integration.
    .EXAMPLE
    Set-EnvtVariables
    .NOTES
    Name: Set-EnvtVariables
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [string] $ClientId,
        [Parameter(Mandatory)]
        [string] $ClientSecret,
        [Parameter(Mandatory)]
        [string] $TenantId
    )

    $EnvtVariables = @(
        [PSCustomObject]@{
            Name  = "AZURE_CLIENT_ID"
            Value = $ClientId
        },
        [PSCustomObject]@{
            Name  = "AZURE_CLIENT_SECRET"
            Value = $ClientSecret
        },
        [PSCustomObject]@{
            Name  = "AZURE_TENANT_ID"
            Value = $TenantId
        }
    )

    Foreach ($EnvtVar in $EnvtVariables) {
        
        Try {
            [System.Environment]::SetEnvironmentVariable($EnvtVar.Name, $EnvtVar.Value, [System.EnvironmentVariableTarget]::User)
        }
        Catch {
            Write-Host "Unable to set the $($EnvtVar.Name) environment value and due to this the tool will not work." -foreground 'Red'
            Exit
        }
        
    }
}

#Checking if the environment variables for the Azure AD app are created or not
if ($null -eq (Get-ChildItem env: | Where-Object { $_.Name -like "Azure_*" })) {
    Write-Host "`nThe environment variables for Azure AD app are not created. Hence creating..." -ForegroundColor "Yellow"

    Set-EnvtVariables

}

#Checking and Verifying if the latest Microsoft.Graph Module is installed or not
$latest = Find-Module -Name Microsoft.Graph -AllVersions -AllowPrerelease | select-Object -First 1
$current = Get-InstalledModule | Where-Object { $_.Name -eq "Microsoft.Graph" }
If ($latest.version -gt $current.version) {
    Try {
        Update-Module -Name Microsoft.Graph -RequiredVersion $latest.version -AllowPrerelease
        Write-Host "Microsoft Graph PowerShell module updated successfully to" $latest.Version -ForegroundColor Green
    }
    Catch {
        Write-Host "Unable to update Microsoft Graph PowerShell module" -ForegroundColor Red
    }
}
Elseif ($null -eq $current.version) {
    Try {
        Write-Host "The Microsoft Graph PowerShell module is not installed. Hence, installing it..." -ForegroundColor "Yellow"
        Install-Module Microsoft.Graph -scope CurrentUser -force
    }
    Catch {
        Write-Host "Unable to install the Microsoft Graph PowerShell module."
    }

}
Else {
    Write-Host "Latest version of Microsoft Graph is not newer than the installed one." -ForegroundColor yellow
}

#Azure AD App details
$ApplicationId = [System.Environment]::GetEnvironmentVariable("Azure_CLIENT_ID")
$TenantID = [System.Environment]::GetEnvironmentVariable("Azure_TENANT_ID")
$ClientSecret = [System.Environment]::GetEnvironmentVariable("Azure_CLIENT_SECRET") | ConvertTo-SecureString -AsPlainText -Force
$ClientSecretCredential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList $ApplicationId, $ClientSecret

#Connecting to Microsoft Graph
Connect-MgGraph -TenantId $TenantID -ClientSecretCredential $ClientSecretCredential | Out-Null

#XAML form designed using Vistual Studio
[xml]$Form = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Modifying Users Membership in Azure AD Group" WindowStartupLocation="CenterScreen" Height="300" Width="500" Background="#022555" ResizeMode="NoResize">
    <Grid>
        <Label Name="PathToCSV" Content="Path" HorizontalAlignment="Left" Margin="25,22,0,0" VerticalAlignment="Top" Height="33" Width="130" FontFamily="Calibri" FontSize="14" FontWeight="Bold" Foreground="#ffffff"/>
        <Label Name="AzureADGroupName" Content="Group" HorizontalAlignment="Left" Margin="25,55,0,0" VerticalAlignment="Top" Height="33" Width="145" FontFamily="Calibri" FontSize="14" FontWeight="Bold" Foreground="#ffffff"/>
        <Label Name="Result" Content="Result" HorizontalAlignment="Left" Margin="25,155,0,0" VerticalAlignment="Top" Height="33" Width="145" FontFamily="Calibri" FontSize="14" FontWeight="Bold" Foreground="#ffffff"/>
        <TextBox Name="PathToCSVBox" HorizontalAlignment="Left" Height="20" Margin="80,28,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="250" ToolTip="type the correct path of CSV file" AutomationProperties.HelpText="type the correct path of CSV file"/>
        <TextBox Name="AADGroupBox" HorizontalAlignment="Left" Height="20" Margin="80,60,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="250" ToolTip="Type valid Azure AD Group Name" AutomationProperties.HelpText="Type valid Azure AD Group Name"/>
        <Button Name="BrowseButton" Content="Browse" HorizontalAlignment="Left" Margin="350,28,0,0" VerticalAlignment="Top" Height="22" Width="75" Foreground="#ffffff" Background="#417505" FontSize="14" FontWeight="Bold" RenderTransformOrigin="2,1.227" ToolTip="Browse to the path of CSV file" AutomationProperties.HelpText="Browse to the path of CSV file"/>
        <Button Name="AddButton" Content="Add" HorizontalAlignment="Left" Margin="60,110,0,0" VerticalAlignment="Top" Height="33" Width="75" Foreground="#ffffff" Background="#417505" FontSize="14" FontWeight="Bold" RenderTransformOrigin="2,1.227" ToolTip="add users to the specified group" AutomationProperties.HelpText="add users to the specified group"/>
        <Button Name="RemoveButton" Content="Remove" HorizontalAlignment="Left" Margin="195,110,0,0" VerticalAlignment="Top" Height="33" Width="75" Foreground="#ffffff" Background="#417505" FontSize="14" FontWeight="Bold" RenderTransformOrigin="2,1.227" ToolTip="remove users from the specified group" AutomationProperties.HelpText="remove users from the specified group"/>
        <Button Name="ClearButton" Content="Clear" HorizontalAlignment="Left" Margin="330,110,0,0" VerticalAlignment="Top" Height="33" Width="75" Foreground="#ffffff" Background="#417505" FontSize="14" FontWeight="Bold" RenderTransformOrigin="2,1.227" ToolTip="clear all the fields" AutomationProperties.HelpText="clear all the fields"/>
        <TextBox Name="ResultBox" HorizontalAlignment="Left" Height="61" Width="408" Margin="30,180,0,0" TextWrapping="Wrap" VerticalAlignment="Top" ToolTip="show the result of the selected operation" AutomationProperties.HelpText="show the result of the selected operation"/>
    </Grid>
</Window>
"@

#Create a form
$XMLReader = (New-Object System.Xml.XmlNodeReader $Form)
$XMLForm = [Windows.Markup.XamlReader]::Load($XMLReader)

#Load Controls
$CSVFilePathBox = $XMLForm.FindName('PathToCSVBox')
$AADGroupBox = $XMLForm.FindName('AADGroupBox')
$BrowseButton = $XMLForm.FindName('BrowseButton')
$AddButton = $XMLForm.FindName('AddButton')
$RemoveButton = $XMLForm.FindName('RemoveButton')
$ClearButton = $XMLForm.FindName('ClearButton')
$ResultBox = $XMLForm.FindName('ResultBox')

#Browse Button Action
$BrowseButton.add_click({

    $openFile = [Microsoft.Win32.OpenFileDialog]@{
                DefaultExt = '.csv'
                Filter = 'CSV files (.csv)|*.csv'
            }
    $result = $openFile.ShowDialog()
    
    if ($result) {
        $CSVFilePathBox.Text = $openFile.FileName
    }
})

#Add Button Action
$AddButton.add_click({
    $ResultBox.Text = ''
    $CSVFilePath = $CSVFilePathBox.Text
    $AADGroup = $AADGroupBox.Text
    $Users = Import-Csv $CSVFilePath
    Foreach($User in $Users){
        Try{ 
            Add-UserToAADGroup -UPN $User.UPN -AADGroup $AADGroup
        }
        Catch {
            $ResultBox.Text = $_.Exception.Message
            break
        }
    }
    $ResultBox.Text = "All users were successfully added to $AADGroup group."
})

#Remove Button Action
$RemoveButton.add_click({
    $ResultBox.Text = ''
    $CSVFilePath = $CSVFilePathBox.Text
    $AADGroup = $AADGroupBox.Text
    $Users = Import-Csv $CSVFilePath
    Foreach($User in $Users){
        Try{ 
            Remove-UserFromAADGroup -UPN $User.UPN -AADGroup $AADGroup
        }
        Catch {
            $ResultBox.Text = $_.Exception.Message
            break
        }
    }
    $ResultBox.Text = "All users were successfully removed from $AADGroup group."
})

#Clear Button Action
$ClearButton.add_click({Clear-Text})

#Show XMLform
$XMLForm.ShowDialog()
