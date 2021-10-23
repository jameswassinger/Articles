# Create an ArrayList of Custom Type using PowerShell

> For an updated, and best practice method see, [PowerShell Creating a Generic List of Custom Type Using PSCustomObject](PowerShell%20Creating%20a%20Generic%20List%20of%20Custom%20Type%20Using%20PSCustomObject.md)

## What is a Custom Type?

PowerShell has many pre-written types that can be used to write a script, for example, String [string], Integer [int], and boolean [bool].

In some instances, you may need to create your own custom type to use in your script. A custom type is a type not already defined in PowerShell. A custom type allows you to store the data you need.

To define a custom type you can use a PowerShell Class. A class will allow you to create a custom type. The class acts like a blueprint that defines the data and behavior of your custom type.

## Creating a Class

Let's create a simple class named Paper. This will create a custom type named Paper that we will use later to fill an ArryList with.

Declare the class.

```powershell
class Paper {
 
   # Class body where the behavior of the class is defined.

}
```

Define the data and behavior of the class. In the below snippet we define the class properties of the Paper class by providing attributes of paper. Attributes that are universally known for a paper to have, e.g., Name, Count, Color, etc.

```powershell
class Paper {
  [String]$_name
  [String]$_color
  [Int]$_count
  [bool]$_printer
}
```

Define the class constructor. Class constructors have the same name as the class. Constructors are used for initializing the class with default values. A class can have multiple constructors that take different arguments. Below we will create a constructor for our Paper class. The constructor allows us to initialize the data of our class properties/attributes.

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
```

## Creating the ArrayList

ArrayList is depreciated, Microsoft recommends using Generic Lists. See, [PowerShell Using a Generic List](PowerShell%20Using%20a%20Generic%20List.md)

Now that we have created our custom type, let's create the ArrayList that will hold our custom type. After creating the ArrayList we will fill the ArrayList with the custom type. Each item added to the ArrayList will be an instance of class Paper that we will initialize with data using its constructor.

Declare a new ArrayList

```powershell
[System.Collections.ArrayList]$paperInformation = @()
```

Create a few new instances of class Paper initialized with data using the class constructor.

```powershell
$constructionpaper = [Paper]::new("Construction", "Red", 100, $false)
$legalpaper = [Paper]::new("Legal", "Yellow", 150, $true)
$collegepaper = [Paper]::new("College", "White", 50, $false)
$notepaper = [Paper]::new("Note", "Blue", 25, $false)
```

Add the class instances to the ArrayList.

```powershell
$paperInformation.Add($constructionpaper)
$paperInformation.Add($legalpaper)
$paperInformation.Add($collegepaper)
$paperInformation.Add($notepaper)
```

## Putting it Together

Alright, now that we have all of the components needed to complete our task. Let's put it together and run it. We will output the results of the ArrayList using the ForEach-Object cmdlet.

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

[System.Collections.ArrayList]$paperInformation = @()

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

Running the above should produce the following output:

[create-an-arrayList-of-custom-type-using-powerShell](../Media/create-an-arraylist-of-custom-type-using-powerShell/create-an-arrayList-of-custom-type-using-powerShell.png)

Wait? What is happening...🤔 Why are the indexes listed with the output?

We need to suppress the return value (index) of the System.Collections.ArrayList. We can do this by casting the ArrayList to void or by redirecting it to $null.

I prefer to cast to void, but some may prefer to redirect to $null for readability. Here are the options:

```powershell
[void]$paperInformation.Add($constructionpaper)
[void]$paperInformation.Add($legalpaper)
[void]$paperInformation.Add($collegepaper)
[void]$paperInformation.Add($notepaper)
```

or

```powershell
$paperInformation.Add($constructionpaper) > $null
$paperInformation.Add($legalpaper) > $null
$paperInformation.Add($collegepaper) > $null
$paperInformation.Add($notepaper) > $null
```

Both options produce the same output (no indexes):

[create-an-arrayList-of-custom-type-using-powerShell](../Media/create-an-arraylist-of-custom-type-using-powerShell/create-an-arrayList-of-custom-type-using-powerShell0.png)


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

[System.Collections.ArrayList]$paperInformation = @()

$constructionpaper = [Paper]::new("Construction", "Red", 100, $false)
$legalpaper = [Paper]::new("Legal", "Yellow", 150, $true)
$collegepaper = [Paper]::new("College", "White", 50, $false)
$notepaper = [Paper]::new("Note", "Blue", 25, $false)

# option 1
[void]$paperInformation.Add($constructionpaper)
[void]$paperInformation.Add($legalpaper)
[void]$paperInformation.Add($collegepaper)
[void]$paperInformation.Add($notepaper)

<# option 2
$paperInformation.Add($constructionpaper) > $null
$paperInformation.Add($legalpaper) > $null
$paperInformation.Add($collegepaper) > $null
$paperInformation.Add($notepaper) > $null
#>

$paperInformation | ForEach-Object {

    $_
}
```