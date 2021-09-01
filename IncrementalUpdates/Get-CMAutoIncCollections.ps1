<#
.SYNOPSIS
    Gets all SCCM collections that currently have the Use incremental updates for this collection checked, and outputs the found collection names to a specified CSV file.
.DESCRIPTION
    Gets all SCCM collections that currently have the Use incremental updates for this collection checked, and outputs the found collection names to a specified CSV file.
.PARAMETER Path
    Sets the path to the CSV file to output results to.
.EXAMPLE
    .\Get-CMAutoIncCollections.ps1 -Path C:\SampleCol.csv
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator

[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String]$Path

)

try {
    Write-Verbose "Load Configuration Manager PowerShell Module"
    Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1') -ErrorAction Stop

    $SiteCode = Get-PSDrive -PSProvider CMSITE -ErrorAction Stop
    Set-location $SiteCode":" -ErrorAction Stop
} catch {
    Write-Output $_.Exception.Message
}


<#
    The following refresh types exist for ConfigMgr collections
        6 = Incremental and Periodic Updates
        4 = Incremental Updates Only
        2 = Periodic Updates only
        1 = Manual Update only
#>

$refreshtypes = "4","6"

Write-Output "Please wait. Getting collection information from SCCM. This may take some time."
$CollectionsWithIncrement = Get-CMDeviceCollection | Where-Object {$_.RefreshType -in $refreshtypes}

Write-Verbose "Store the collections with the "use incremental updates for this collection option enabled."
$Collections = @()
Write-Verbose "Add device collection names to the collections array."
$CollectionsWithIncrement | ForEach-Object {
    $object = New-Object -TypeName PSobject
    $object | Add-Member -Name CollectionName -value $_.Name -MemberType NoteProperty
    Write-Output "$($_.Name)"
    $collections += $object
}
Write-Verbose "get total count found."
$total = $Collections.Count
Write-Verbose "immediately display the count of collections with the option enabled."
Write-output "`n`nFound $total Collections with the auto incremental checked.`n`n"
Write-Verbose "Write the collections names to a file."
$Collections | Export-Csv $Path -NoTypeInformation
Write-Verbose "Set location back to start."
Set-Location $PSScriptRoot
