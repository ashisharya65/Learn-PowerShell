
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form = New-Object system.Windows.Forms.Form
$Form.ClientSize = New-Object System.Drawing.Point(400, 400)
$Form.text = "ADForm"
$Form.TopMost = $false

$UserName = New-Object system.Windows.Forms.Label
$UserName.text = "UserName"
$UserName.AutoSize = $true
$UserName.width = 40
$UserName.height = 10
$UserName.location = New-Object System.Drawing.Point(65, 160)
$UserName.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))

$LastPasswdSet = New-Object system.Windows.Forms.Label
$LastPasswdSet.text = "LastPasswordSet"
$LastPasswdSet.AutoSize = $true
$LastPasswdSet.width = 60
$LastPasswdSet.height = 10
$LastPasswdSet.location = New-Object System.Drawing.Point(235, 160)
$LastPasswdSet.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))


$UserNameTxtBox = New-Object system.Windows.Forms.TextBox
$UserNameTxtBox.multiline = $false
$UserNameTxtBox.width = 100
$UserNameTxtBox.height = 20
$UserNameTxtBox.location = New-Object System.Drawing.Point(52, 180)
$UserNameTxtBox.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)

$LastPwdSetTxtBox = New-Object system.Windows.Forms.TextBox
$LastPwdSetTxtBox.multiline = $false
$LastPwdSetTxtBox.width = 150
$LastPwdSetTxtBox.height = 20
$LastPwdSetTxtBox.location = New-Object System.Drawing.Point(220, 180)
$LastPwdSetTxtBox.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)

$Submit = New-Object system.Windows.Forms.Button
$Submit.text = "Submit"
$Submit.width = 60
$Submit.height = 30
$Submit.location = New-Object System.Drawing.Point(72, 220)
$Submit.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)

$Clear = New-Object system.Windows.Forms.Button
$Clear.text = "Clear"
$Clear.width = 60
$Clear.height = 30
$Clear.location = New-Object System.Drawing.Point(260, 221)
$Clear.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)

$Form.controls.AddRange(@($UserName, $LastPasswdSet, $UserNameTxtBox, $LastPwdSetTxtBox, $Submit, $Clear))


#region Submit Button logic 
$Submit.add_click({


    })
#endregion

#region Clear Button logic 
$Clear.add_click({
    
    })
#endregion

#Show form
[void]$Form.ShowDialog()
