# PowerShell Profile

## What is a PowerShell profile
PowerShell profile is a script that runs when PowerShell starts. You can use the profile as a startup script to customize your environment. You can add commands, aliases, functions, variables, modules, PowerShell drives and more.

## Profile types and locations
PowerShell supports several profile files that are scoped to users and PowerShell hosts. You can have any or all these profiles on your computer.

The PowerShell console supports the following basic profile files. These file paths are the default locations: 

- All Users, All Hosts
    - Windows - $PSHOME\Profile.ps1
    - Linux - /opt/microsoft/powershell/7/profile.ps1
    - macOS - /usr/local/microsoft/powershell/7/profile.ps1

<br/>

- All Users, Current Host
    - Windows - $PSHOME\Microsoft.PowerShell_profile.ps1
    - Linux - /opt/microsoft/powershell/7/Microsoft.PowerShell_profile.ps1
    - macOS - /usr/local/microsoft/powershell/7/Microsoft.PowerShell_profile.ps1

<br/>

- Current User, All Hosts
    - Windows - $HOME\Documents\PowerShell\Profile.ps1
    - Linux - ~/.config/powershell/profile.ps1
    - macOS - ~/.config/powershell/profile.ps1

<br/>

- Current user, Current Host
    - Windows - $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
    - Linux - ~/.config/powershell/Microsoft.PowerShell_profile.ps1
    - macOS - ~/.config/powershell/Microsoft.PowerShell_profile.ps1


<br/>

The profile scripts are executed in the same order as mentioned above. <br/>
This means changes made in the AllUsersAllHost profile can be overridden by any other profile scripts. <br/>
The CurrentUserCurrentHost profile always runs last.<br/>
In PowerShell Help, the <b>CurrentUserCurrentHost</b> profile is the profile most often referred to as your PowerShell profile.

Other programs that host PowerShell can support their own profiles. For example, Visual Studio Code (VS Code) supports the following host-specific profiles. <br/>

- All users, Current Host - $PSHOME\Microsoft.VSCode_profile.ps1
- Current user, Current Host - $HOME\Documents\PowerShell\Microsoft.VSCode_profile.ps1

<br/>

## $PROFILE variable 

The $PROFILE automatic variable stores the paths to the PowerShell profiles that are available in the current session.

To view a profile path, display the value of the $PROFILE variable. You can also use the $PROFILE variable in a command to represent a path.

The $PROFILE variable stores the path to the "Current User, Current Host" profile. The other profiles are saved in note properties of the $PROFILE variable.

For example, the $PROFILE variable has the following values in the Windows PowerShell console.

- Current User, Current Host - $PROFILE
- Current User, Current Host - $PROFILE.CurrentUserCurrentHost
- Current User, All Hosts - $PROFILE.CurrentUserAllHosts
- All Users, Current Host - $PROFILE.AllUsersCurrentHost
- All Users, All Hosts - $PROFILE.AllUsersAllHosts

<br/>

To see the current values of the $PROFILE variable, type:

```ps1
$PROFILE | Select-Object *
```