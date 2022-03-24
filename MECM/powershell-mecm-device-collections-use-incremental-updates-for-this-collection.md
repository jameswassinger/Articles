# PowerShell: MECM Device Collections Use Incremental Updates for this Collection

If you are a System Center Configuration Manager Administrator and you have delegated rights to the SCCM environment to other IT personnel to create collections you should complete regular checks on device collections within your environment.

A majority of the device collections should update on a schedule and should not use incremental updates. As a best practice for device collections in System Center 2012 Configuration Manager, there should not be a large number of collections using incremental updates.

Enabling "Use incremental updates for this collection" may cause evaluation delays when you enable this option for may collections.

Microsoft recommends enabling this option for 200 or fewer device collections within System Center 2012 Configuration Manager. Below are two scripts that can help you determine what collections have the "Use incremental updates for this collection" option enabled and to disable the option and place the device collection on a schedule instead.

## .\Get-CMAutoIncCollections.ps1

```powershell
# state the path and file name where you would like to store the output.
# file is written to csv.
Param ( [string]$Path )

#Load Configuration Manager PowerShell Module
Import-module  ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5)+  '\ConfigurationManager.psd1')

#Get SiteCode
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-location $SiteCode":"

# The following refresh types exist for ConfigMgr collections
# 6 = Incremental and Periodic Updates
# 4 = Incremental Updates Only
# 2 = Periodic Updates only
# 1 = Manual Update only

$refreshtypes = "4","6"

# Get the collections from sccm
$CollectionsWithIncrement = Get-CMDeviceCollection | Where-Object {$_.RefreshType  -in $refreshtypes}

# Store the collections with the "use incremental updates for this collection"  option enabled.
$Collections = @()

# Add device collection names to the collections array.
foreach ($collection in $CollectionsWithIncrement) {
    $object = New-Object -TypeName PSobject
    $object| Add-Member -Name CollectionName -value $collection.Name -MemberType  NoteProperty
    #$object| Add-Member -Name CollectionID -value $collection.CollectionID  -MemberType NoteProperty
    #$object| Add-Member -Name MemberCount -value $collection.LocalMemberCount  -MemberType NoteProperty
    $collections += $object
}

# get total count found.
$total = $Collections.Count

# immediately display the count of collections with the option enabled.
Write-Host "`n`nFound $total Collections with the auto incremental checked.`n`n"

# Write the collections names to a file.
$Collections | Export-Csv $Path -NoTypeInformation
```

## .\Change-AutoIncCollections.ps1

```powershell
# Specify the path where the csv of collections names is stored.
# Specify the date you would like the schedule to start. Ex. "09/27/2018 9:00 AM"
Param (
[string]$Path
)

#Load Configuration Manager PowerShell Module
Import-module  ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5)+  '\ConfigurationManager.psd1')

#Get SiteCode
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-location $SiteCode":"

# Read the collection names from the file.
$CollectionNames = Get-Content -Path $Path

# Keeps count of processed collections
$count = 0

# Change the collection schedule.
foreach($collection in $CollectionNames) {
    Write-Host "Applying new settings to $collection"
        $Date = Get-Date -Format g
    $Schedule = New-CMSchedule -Start $Date -RecurInterval Days -RecurCount 1  
    Set-CMDeviceCollection -Name $collection -RefreshType Periodic  -RefreshSchedule $Schedule
    $count += 1      
}

# Write out how many collections the script disable the "use incremental updates  for this collection" option for.
Write-Host "Set new schedule for $count device(s)"
```

## How to use

You can download each script from [GitHub](https://github.com/jameswassinger/PowerShell/tree/main/SCRIPTS/MECM)

## Example Use

```powershell
.\Get-AutoIncCollections.ps1 -Path C:\CollectionNames.csv
```

After the script completes open CollectionNames.csv and remove the "" from the collection names and remove any collection names you do not want to modify the schedule for.

Save and close the file.

```powershell
.\Change-AutoIncCollections.ps1 -Path C:\CollectionNames.csv
```

After running the above, the collection's schedule is now changed to check for updates once daily. 😀
