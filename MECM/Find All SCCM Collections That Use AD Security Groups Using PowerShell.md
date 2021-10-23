Does your organization use Active Directory Security Groups with SCCM collections?

If you didn't already know, you can fill an SCCM collection by adding an AD Security Group to a membership rule.

Using a security group with an SCCM collection allows you to create a dynamic collection, and it also allows others to place members in an SCCM collection without the SCCM Administrator needing to grant rights to SCCM.

Even though there are benefits to using an AD Security Group to dynamically administer an SCCM collection, a possible issue that may occur is not knowing exactly what security groups have been assigned to collections.

A good practice when associating a security group with an SCCM collection is to name the collection the same or similar to the security group, allowing easy identification.

## Example

**Secuity Group Name:** Contoso Marketing Boards

**SCCM Device Collection Name:** Contoso Marketing Boards

**Security Group Name:** Contoso HR Section

**SCCM Device Collection Name:** Contoso HR Section

Yes, I know in an ideal world this would happen, and all naming conventions and best practices would be followed, but this is not an ideal world so...

Here is an example of an issue that may arise from using security groups with SCCM collections:

In a large environment, you may have multiple SCCM Administrators. Administrators may come and go, but the collections they created still remain. Some of those collections may contain security groups, but which ones? 🤔

Given the following questions create a PowerShell script to query SCCM for the requested information.

1. How many collections in SCCM currently use security groups, and what are the collection names
2. Are SCCM collections using security group X?

> **Helpful Hint:** Before proceeding see if you can brainstorm some ideas on how these answer can be obtain using PowerShell.

I will go through solving each question one at a time. I will be using the Connect via Windows PowerShell function in the SCCM Admin Console to make this easier to following along in your own environment, and so that you can plug this information directly into the console 😁.

### Q: How many collections in SCCM currently use security groups, and what are the collection names?

Add a PowerShell variable to collect and store all collections and associated information.

```
PS SITE:\> $AllCollections  = Get-CMCollection
```

With the collection information now stored in a variable, use the Get-Member on the $AllCollections variable to see what methods and properties are available.

```
PS SITE:\> $AllCollections | Get-Member | Select Name, MemberType
```

Running the above script will produce a large list of methods and properties that can be use. For this script the following two members will be used, CollectionRules and Name.

| Name | MemberType |  
|-----------|:-----------:| 
| CollectionRules | Property | 
| Name | Property |

Why use the CollectionRules property? SCCM collections are filled using collections rules. The script will need to look at the query expression within the collection rule to determine if a security group exists. This will be done using key terms.

Why use the Name property? The name property contains the collection name. If the script finds a collection that is using a security group the script will need to output the name of the collection found.

Run the Get-Member on the CollectionRules to see what methods and properties are available.

```
PS SITE:\> $($AllCollections).CollectionRules | Get-Member
```

Running the above will output another large list of methods and properties available to use. For this script the following member will be used, QueryExpression.

### IResultObject#SMS_CollectionRuleQuery

| Name | MemberType |  
|-----------|:-----------:| 
| QueryExpression | Property | 
| Name | Property |

The QueryExpression property will be used to search the collection query for a key term. The two key terms that the script will need to search for will be 'SecurityGroupName' and 'SystemGroupName'.

Create an array named found. This found array will store information of found collections.

```
$found = @()
```

Create an array named terms and fill the array with the two terms previously mentioned, the SecurityGroupName and SystemGroupName.

```
$terms = @(
"SecurityGroupName",
"SystemGroupName"
)
```

Why use an array with the terms? Using an array will help prevent duplicate code and will provide one location to make edits to the terms.

Create a ForEach loop to iterate through $AllCollections. Inside the ForEach loop create a variable called $collection with the value of $_. The $_ references the current collection that is accessed by the loop. The $_ is needed because the script will use another ForEach loop to iterate through the key terms array.

```
$AllCollections | ForEach {
	$collection = $_
}
```

After the $collection variable add a ForEach loop for the $terms.

```
$terms | ForEach-Object {

}
```

The logic that ties this together will be placed inside of the $terms ForEach loop. To start, add a variable named $termExist.

```
$termExist = $($collection.CollectionRules.QueryExpression -like "*($_)*")
```

The value of the $termExist variable is checking to see if any of the key terms exist.

Below the $termExist variable create an if statement that checks if the $termExist variable contains a value. If the $termExist variable contains a value then the if statement evaluates the statement as $true.

```
if($termExist) {

}
```

If the term exists ($true) the collection will be added to the $found array and collection name will be displayed in Green to to the console.

```
$found += $_
Write-Host "Collection: $($collection.Name)" -ForegroundColor Green
```

Once the loops have finished, a Write-Host displays the count of collections found.

```
Write-Host "Found $($found.Count) collections that contain a 
security group."
```

With the above information, the script should now have what it needs to query SCCM to answer the questions in set 1.

Here is the entire script...

```
$AllCollections = Get-CMCollection
Write-Host "$($AllCollections.Count) found."

# holds collection information
$found = @()

# key terms to search for
$terms = @(
    "SecurityGroupName",
    "SystemGroupName"
)

$AllCollections | ForEach-Object {

    $collection = $_

    $terms | ForEach-object {

        $termExist = $($collection.CollectionRules.QueryExpression -like "*$($_)*")

        if($termExist) {
        
            $found += $collection
            Write-Host "Collection : $($collection.Name)" -ForegroundColor Green           
        }
    }
}

Write-Host "Found $($found.Count) collections that contain a security group."
```

### Q: Are SCCM collections using security group X?

This question can be answered using this one-liner …

```
Get-CMCollection | Where-Object { $_.CollectionRules.QueryExpression -like "*SECURITY-GROUP-NAME-*" } | Select Name
```

The command will display the collection names of those collections using the security group name specified in the query expression of the collection rules.

## What are your thoughts?

Does your organization uses AD Security Groups with SCCM? How do you track AD Security Group usage with SCCM collections?