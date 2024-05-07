# Efficient Lists in PowerShell


By default, PowerShell uses simple “object arrays” when you define lists, when commands return more than one result, or when you otherwise need to store more than one thing in a variable.

Default object arrays are OK but they cannot grow once you created them. When you still try by using the operator “+=”, your script may suddenly take forever or never completes:

```ps1
# default array
$array = @()

1..100000 | ForEach-Object {
    # += is actually creating a new array each time with one more entry
    # this is very slow
    $array += "adding $_"
}

$array.count
```

That’s because “+=” is really a lie, and PowerShell actually needs to create a new larger array and copy the contents from the old to the new array. This works well with just a few additions but causes exponential delays once you need to add more than just a few new elements.

The most common workaround is using the System.Collections.ArrayList type, which can grow dynamically. You can simply cast a default array to this type.

Here is an approach commonly used that is a lot faster:

```ps1
# use a dynamically extensible array
$array = [System.Collections.ArrayList]@()

1..100000 | ForEach-Object {
    # use the Add() method instead of "+="
    # discard the return value provided by Add()
    $null = $array.Add("adding $_")
}

$array.count
```

Note how it uses the Add() method instead of the “+=” operator.

System.Collections.ArrayList has two disadvantages, though: its Add() method returns the position at which the new element was added, and since this information isn’t useful, it needs to be discarded manually, i.e. by assigning it to $null. And ArrayLists are not type-specific. They can store any data type which makes them flexible but not very efficient.

Generic lists are so much better, and using them is just a matter of using a different type instead. For one, generic lists can be restricted to a given type, so they can store data in the most efficient way and provide type safety. Here is an example for a string list:

```ps1
# use a typed list for more efficiency
$array = [System.Collections.Generic.List[string]]@()

1..100000 | ForEach-Object {
    # typed lists support Add() as well but there is no
    # need to discard a return value
    $array.Add("adding $_")
}

$array.count
```

If you needed a list of integers instead, simply replace the type inside the type name of the generic list:

```ps1
[System.Collections.Generic.List[int]]
```

Strong type restriction is just a “can”, not a “must”. If you want generic lists to be just as flexible as the ArrayList and accept any type, use the “object” type:

```ps1
[System.Collections.Generic.List[object]]
```