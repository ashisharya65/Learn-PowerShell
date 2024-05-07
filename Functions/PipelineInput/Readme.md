# PowerShell ParameterBinding

- The task of figuring out which parameter to use when a command receives input via the pipeline is known as parameter binding.
- To successfully bind an object coming from the pipeline to a parameter, the incoming command's parameter must support it.

<br/>


## Types of Parameter Binding:

<br/>

 ### ByValue

- <b>ByValue</b> means that the command's (after the pipeline) parameter accepts the entire incoming object as the parameter value.
- A <b>ByValue</b> parameter looks for an object of a specific type in incoming objects. If that object type is a match, PowerShell assumes that the object is meant to be bound to that parameter and accepts it.

        'C:\Windows' | Get-ChildItem

    The <b>Get-ChildItem</b>cmdlet has a parameter called Path that accepts a string object type and pipeline input via <b>ByValue</b>. Because of this, running something like <b>'C:\Windows' | Get-ChildItem</b> returns all files in the C:\Windows directory because C:\Windows is a string.

<br/>

### ByPropertyName

- The command parameter doesn’t accept an entire object but a single property of that object. It does this not by looking at the object type but the property name.

        [pscustomobject]@{Name='firefox'} | Get-Process

    The <b>Get-Process</b> cmdlet has a Name parameter that’s set up to accept pipeline input <b>ByPropertyName</b>. When you pass an object with a Name property to the Get-Process cmdlet like <b>[pscustomobject]@{Name='firefox'} | Get-Process </b>, PowerShell matches or binds the Name property on the incoming object to the Name parameter and uses that value.
