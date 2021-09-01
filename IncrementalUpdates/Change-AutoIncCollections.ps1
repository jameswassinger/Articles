<#
.SYNOPSIS
    Updates the collection refresh schedule for the specified Sccm collection names in the provided csv file.
.DESCRIPTION
    Updates the collection refresh schedule for the specified Sccm collection names in the provided csv file. Refresh schedule changed to Occurs every 1 day effective todays date and time.
.PARAMETER Path
    Sets the path to the CSV file containing Sccm collections names.
.EXAMPLE
    .\Update-CMAutoIncCollections.ps1 -Path C:\SampleCol.txt
#>

#Requires -Version 5.1
#Requires -RunAsAdministrator


[CmdletBinding()]
Param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [String]$Path
)

try {
    Write-Verbose "Load Configuration Manager PowerShell Module"
    Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1') -ErrorAction Stop

    Write-Verbose "Get SiteCode"
    $SiteCode = Get-PSDrive -PSProvider CMSITE -ErrorAction Stop
    Set-location $SiteCode":" -ErrorAction Stop
} catch {
    Write-Output $_.Exception.Message
}

Write-Verbose "Read the collection names from the file."
$CollectionNames = Get-Content -Path $Path

Write-Verbose "Keep count of processed collections"
$count = 0

Write-Verbose "Change the collection schedule."
$CollectionNames | ForEach-Object {
    Write-Output "Applying new settings to $($_)"
    $Date = Get-Date -Format g
    $Schedule = New-CMSchedule -Start $Date -RecurInterval Days -RecurCount 1
    Set-CMDeviceCollection -Name $_ -RefreshType Periodic -RefreshSchedule $Schedule
    $count += 1
}

Write-Verbose "Write out how many collections the script disable the 'use incremental updates for this collection' option for."
Write-Output "Set new schedule for $count device(s)"

Write-Verbose "Set location to start"
Set-Location $PSScriptRoot
