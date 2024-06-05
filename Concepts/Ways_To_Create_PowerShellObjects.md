# Ways to create PowerShell Objects 

## Typecasting the **hashtable** to pscustomobject type accelerator.

This method involves creating a hashtable with the desired properties and typecasting it to `[PSCustomObject]`. A hashtable in PowerShell is a collection of key-value pairs. By casting the hashtable to `[PSCustomObject]`, PowerShell converts it into a custom object where each key in the hashtable becomes a property of the object, and the corresponding value is assigned to that property. This method is concise and straightforward, often used due to its simplicity and readability.

```ps
# Create an object using a hashtable and typecasting it to [PSCustomObject]

[pscustomobject]@{
    Name = 'Ashish Arya'
    Age  = 32
}
```

## Using **Select-Object** cmdlet.

`Select-Object` cmdlet is typically used to select specific properties of an object. However, it can also be used to create a new object by specifying the properties you want to add. In this method, you can initialize an empty string and add properties to it. This method can be done in two ways:

- First way:

    ```ps
    # Create an object using Select-Object and specifying properties
    '' | Select-Object -Property @{Name="Name"; Expression={"Ashish Arya"}}, @{Name="Age"; Expression={32}}
    ```

- Second way:

    ```ps
    # Create an object using Select-Object with the -InputObject parameter
    Select-Object -Property @{Name="Name"; Expression={"Ashish Arya"}}, @{Name="Age"; Expression={32}} -InputObject ''
    ```

## Using **Add-Member** cmdlet.

`Add-Member` cmdlet allows you to add members (properties or methods) to an existing object. This method starts by creating an empty `psobject` using `New-Object`. Properties are then added to this object using `Add-Member`, where `-MemberType` specifies the type of member (e.g., `NoteProperty`), `-Name` specifies the property name, and `-Value` specifies the property value. This approach provides flexibility in dynamically adding members to objects.

```ps
# Create an empty object
$object = New-Object -TypeName psobject

# Add properties to the object
$object | Add-Member -MemberType NoteProperty -Name "Name" -Value "Ashish Arya"
$object | Add-Member -MemberType NoteProperty -Name "Age" -Value 32

# Display the object
$object
```

## Using hashtable with **New-Object** cmdlet.

This method involves defining a hashtable with the desired properties and values, and then creating an object using `New-Object` cmdlet by passing the hashtable as the `-Property` parameter. The `New-Object` cmdlet creates a new instance of a specified .NET type, and in this case, `psobject` is used as the type. The hashtable's keys become the properties of the object, and the corresponding values are assigned to those properties.

```ps
# Define a hashtable with properties
$properties = @{
    Name = "Ashish Arya"
    Age  = 30
}

# Create the object using the hashtable
$object = New-Object -TypeName psobject -Property $properties

# Display the object
$object
```

## Using PowerShell classes.

PowerShell classes, introduced in PowerShell 5.0, allow you to define custom types with properties and methods. In this method, a class named `Person` is defined with two properties: `Name` and `Age`. The class also includes a constructor method that initializes these properties. An instance of the `Person` class is then created using `[Person]::new()`, passing the necessary arguments to the constructor. This approach is more structured and supports object-oriented programming principles.

```ps
# Define a class with properties and a constructor
class Person {
   [string]$Name
    [int]$Age

   Person ([string]$name, [int]$age) {
        $this.Name = $name
        $this.Age = $age
   }
}

# Create an instance of the class
$object = [Person]::new("Ashish Arya", 32)

# Display the object
$object
```

## Using **New-Object** with a Custom Type.

This method involves defining a custom .NET type (class) using `Add-Type`. The `Add-Type` cmdlet dynamically defines a new .NET class, in this case, `Person`, with properties `Name` and `Age` and a constructor to initialize them. An instance of this custom type is then created using `New-Object`, passing the constructor arguments through the `-ArgumentList` parameter. This approach is useful for defining complex types and leveraging the full power of .NET in PowerShell.

```ps
# Define a custom type using Add-Type
Add-Type -TypeDefinition @"
    public class Person {
        public string Name { get; set; }
        public int Age { get; set; }

        public Person(string name, int age) {
            this.Name = name;
            this.Age = age;
        }
    }
"@

# Create an instance of the custom type
$object = New-Object Person -ArgumentList "Ashish Arya", 32

# Display the object
$object
```

## Using **[PSObject]::new()**

`[PSObject]::new()` creates a new, empty `PSObject`. This method is a more direct way to instantiate a `PSObject` without specifying a type name as with `New-Object`. Once the empty object is created, properties are added using `Add-Member`, similarly to the previous `Add-Member` method. This approach is useful for quickly creating and populating custom objects in PowerShell scripts.

```ps
# Create an empty object using [PSObject]::new()
$object = [PSObject]::new()

# Add properties to the object
$object | Add-Member -MemberType NoteProperty -Name "Name" -Value "Ashish Arya"
$object | Add-Member -MemberType NoteProperty -Name "Age" -Value 32

# Display the object
$object
```
