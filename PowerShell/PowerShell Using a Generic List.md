# PowerShell Using a Generic List

If you are currently using ArrayLists in your PowerShell scripts you should probably change them to Generic Lists. Microsoft no longer recommends the use of ArrayList in new deployments, See [ArrayList Class](https://docs.microsoft.com/en-us/dotnet/api/system.collections.arraylist?view=net-5.0#remarks).

There are some added benefits to using a Generic List, The first benefit I found was that you no longer need to cast to void or pipe to $null to remove the index reference produced from the ArrayList output 👍. Generic Lists are also faster then ArrayList. Using Generic Lists will increase your script's performance.

How does using a Generic List increase performance verse using an ArrayList?

The primary difference is boxing and unboxing. So what is boxing? Boxing is implicitly converting a value type (int, string, etc.) to an object or interface. Unboxing is the explicit conversion of type object to a value type.

What does this mean? It means that at compile time a List of type is created, which does not need to boxed for the list items to be used. Not needing to box list items significantly saves memory when working with large amounts of data.

If you are creating a small lists of elements you may not care and would be fine with using an ArrayList. However, using a Generic List will be in line with good practice.

Generic Lists can be accessed by index and have built-in methods to maintain and manage the list.

### Examples

Create a new list of type String

```powershell
$GenList = New-Object 'System.Collections.Generic.List[String]'
```

Adding Strings to the list

```powershell
$GenList.Add("Orange")
$GenList.Add("Apple")
$GenList.Add("Grape")
```

Accessing the list

```powershell
$GenList | ForEach-Object {
    	Write-Output $_
    }
```

## Convert an ArrayList to a Generic List<T>

The below is from the article [Create an ArrayList of Custom Type using PowerShell](https://www.notion.so/Create-an-ArrayList-of-Custom-Type-using-PowerShell-1cf5f045707c48f4acf53c5d285621ea)

```powershell
class Paper {
    [String]$_name
    [String]$_color
    [Int]$_count
    [bool]$_printer

    Paper([String]$name,[String]$color,[Int]$count,[bool]$printer) {
        $this._name = $name
        $this._color = $color
        $this._count = $count
        $this._printer = $printer
    }

}

#[System.Collections.ArrayList]$paperInformation = @()
$paperInformation = New-Object 'System.Collections.Generic.List[Paper]'

$constructionpaper = [Paper]::new("Construction", "Red", 100, $false)
$legalpaper = [Paper]::new("Legal", "Yellow", 150, $true)
$collegepaper = [Paper]::new("College", "White", 50, $false)
$notepaper = [Paper]::new("Note", "Blue", 25, $false)

$paperInformation.Add($constructionpaper)
$paperInformation.Add($legalpaper)
$paperInformation.Add($collegepaper)
$paperInformation.Add($notepaper)

$paperInformation | ForEach-Object {

    $_
}
```