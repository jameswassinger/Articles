# Upgrade-HpBios
## Short Description
Updates HP BIOs for specified model. 
## Syntax
```
Upgrade-HpBios
  [-LogFilePath] <string>
```

## Long Description
See,  [Deploy HP BIOs Updates Using SCCM and PowerShell](https://jameswassinger.com/69d9fb2a4ca54e619e6a7e3ae6021a67)
## Examples
### Example 1: Update HP Bios
This example upgrades the bios to the version specified within the script.
```
PS> Upgrade-HpBios -LogFilePath "c:\windows\temp\upgrade.log"
```
## Parameters
```
-LogFilePath
```
Specifies the file system path and file name for the logging file. 
## Input
None
## Output
None
