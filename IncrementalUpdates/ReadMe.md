See [SCCM Incremental Updates Collection Maintenance](https://jameswassinger.com/d5af943a5bec43a0bbc65d8705a21a82)

<p>SCCM Can only have 200 device collections set for incremental updating. This repo contains scripts to maintain this number.</p>

<p>note: schedule in Update-CMAutoIncCollections.ps1 is set to occur once a day.</p>

<p>How To</p>
<p>Run Get-CMAutoIncCollections.ps1, specify the location where you want the CSV file saved to and the name of the CSV file. After you run the Get-CMAutoIncCollections open the CSV file and remove all the collections found that you DO NOT want to change the schedule for. After review, save and close the CSV file and run Update-CMAutoIncCollections.ps1</p>

* .\Get-CMAutoIncCollections.ps1 [-Path] <string> <CommonParameters>
* .\Update-CMAutoIncCollections.ps1 [-Path] <string> <CommonParameters>

<p>Examples</p>

* .\Get-CMAutoIncCollections -Path "C:\CollectionNames.csv"
* .\Update-CMAutoIncCollections -Path "C:\CollectionNames.csv"
