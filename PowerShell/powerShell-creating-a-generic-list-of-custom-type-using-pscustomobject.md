# PowerShell Creating a Generic List of Custom Type Using PSCustomObject

In a previous article I showed how to [Create an ArrayList of Custom Type using PowerShell.](https://www.notion.so/Create-an-ArrayList-of-Custom-Type-using-PowerShell-1cf5f045707c48f4acf53c5d285621ea) In this article I will show you how to create a Generic list of PSCustomObject.

## PSCustomObject

In the previous article I used a [Class](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_classes?view=powershell-7.1) to create a custom object. If you are familiar with C# you know that one way you can create a custom object is by using a Class. PowerShell has a quick an easy way to create a custom object on the fly by using PSCustomObject.

### Example

```powershell
$Car = [PsCustomObject]@{
    Make = "Ford"
    Model = "Ranger"
    Color = "Blue"
}

Make Model  Color
---- -----  -----
Ford Ranger Blue
```

The syntax of a PSCustomObject may be familiar if you regularly use HashTables. You can also convert a HashTable to a PSCustomObject.

### Example

```powershell
$Table = @{
    Make = "Chevy"
    Model = "Silverado"
    Color = "Red"
}

$Car = [PSCustomObject]$Table

Color Make  Model
----- ----  -----
Red   Chevy Silverado
```

This is all great information, but what about the information that I came for? No worries, here its...

## Create the Generic List

Let's create the Generic List that will fold are custom object.

```powershell
$CustomObj = New-Object 'System.Collections.Generic.List[PSObject]
```

Notice that the Generic list type is of PSObject. This will allow us to use the PSCustomObject.

## Adding PSCustomObjects

After creating the Generic List we can now add items of a custom type using the PSCustomObject.

```powershell
$CustomObj.Add([PSCustomObject]@{
User = "Sam"
Email = "sam@contoso.com"
})
```

Let's take a look at what was just added.

```powershell
$CustomObj

User Email
---- -----
Sam  sam@contoso.com
```

You can see how using this method of creating a custom type can become beneficial pretty quickly. Using this method is not only faster for development, but will also increase performance since the process does not need to compile and hold the Class data.

Want to learn more about the use of PSCustomObject? You can learn more about PSCustomObject [here](https://powershellexplained.com/2016-10-28-powershell-everything-you-wanted-to-know-about-pscustomobject/).
