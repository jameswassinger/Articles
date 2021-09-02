# Change-AutoIncCollections

## Short Description
SCCM Can only have 200 device collections set for incremental updating. This function helps to maintain this number. 

## Syntax
```
Change-AutoIncCollections
  [-Path] <string>
```

## Long Description
See, [PowerShell, SCCM Device Collections Use Incremental Updates for this Collection](https://jameswassinger.com/d5af943a5bec43a0bbc65d8705a21a82)

## Examples

### Example 1: Removes auto Increment and adds scheduled update for the listed devices found in the provided csv file. 
```
PS> .\Change-AutoIncCollections.ps1 -Path C:\CollectionNames.csv
```
## Parameters
```
  -Path
```
Specifies the file path to the csv containing the collection names that need to be converted from incremental to scheduled. 
  
## Input
None

## Ouptput
None
  
# Get-AutoIncCollections

## Short Description
SCCM Can only have 200 device collections set for incremental updating. This function helps to maintain this number.

## Syntax
```
Get-AutoIncCollections
  [-Path] <string>
```
  
## Long Description
See, [PowerShell, SCCM Device Collections Use Incremental Updates for this Collection](https://jameswassinger.com/d5af943a5bec43a0bbc65d8705a21a82)

## Examples

### Example 1: Gets and stores all collections found using Incremental.
```
PS> .\Get-AutoIncCollections -Path C:\CollectionNames.csv
```

## Input
None

## Output
None

  
