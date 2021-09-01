# Install BIOS updates for HP Elitebook x360 G2 1012 base

[CmdletBinding()]
param(
    # Log file name
    [Parameter(Mandatory=$true, HelpMessage="Enter a file name for the log file. Example, BiosUpgrade.log")]
    [string]
    $LogFileName
)

#Logging
function Write-LogEntry {
    param(
        [parameter(Mandatory=$true, HelpMessage="Value added to the log file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [parameter(Mandatory=$false, HelpMessage="Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "BiosUpgradeDefualt.log"
    )

    if(!(Test-Path -Path "C:\Windows\Temp")) {
        New-Item -Path "C:\Windows\Temp" -ItemType Directory -Force
    }

    # Determine log file location
    $LogFilePath = Join-Path -Path $env:windir -ChildPath "Temp\$($FileName)"

    # Add value to log file
    try {
        Add-Content -Value "$(Get-Date)     $Value" -LiteralPath $LogFilePath -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to $FileName file"
    }
}

# Determine wheather a machine is a laptop or not. 
# Source: https://blogs.technet.microsoft.com/heyscriptingguy/2010/05/15/hey-scripting-guy-weekend-scripter-how-can-i-use-wmi-to-detect-laptops/
function Detect-Laptop {
    
    Param ( [string]$computer = "localhost" )
    
    $isLaptop = $false
    if(Get-WmiObject -Class win32_systemenclosure -ComputerName $computer | Where-Object { $_.ChassisTypes -eq 9 -or $_.ChassisTypes -eq 10 -or $_.ChassisTypes -eq 14 }) {
        
        $isLaptop = $true

    }

    if(Get-WmiObject -Class Win32_Battery -ComputerName $computer) {
        
        $isLaptop = $true
    }

    $isLaptop    
}

$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# Start Main
$erroractionpreference = "SilentlyContinue"

Write-LogEntry -FileName $LogFileName -Value "ConfigMgr detected No User Logged In, Starting BIOS Upgrade Script."

# If the device is a laptop and not plugged in exit. 
if(Detect-Laptop) {
    Write-LogEntry -Value "Laptop detected, checking battery life."
    if((Get-WmiObject -Class Win32_Battery).EstimatedChargeRemaining -le 30) {
        Write-LogEntry -FileName $LogFileName -Value "Battery below 30%, canceling BIOS Upgrade...this time."
        exit
    }
}

# Get the device's current OS version number. 
$OSVersion = (Get-CimInstance -ClassName Win32_OperatingSystem).Version
$BaseWinVersion = 6.1.7601

if($OSVersion -ge $BaseWinVersion) {
     $drive = Get-BitLockerVolume | where { $_.ProtectionStatus -eq "On" -and $_.VolumeType -eq "OperatingSystem" }
    if ($drive) {
        Write-LogEntry -FileName $LogFileName -Value "Attempting to Suspend Bitlocker on drive $drive."
        Suspend-BitLocker -Mountpoint $drive -RebootCount 1
        if (Get-BitLockerVolume -MountPoint $drive | where ProtectionStatus -eq "On") {
            #Bitlocker Suspend Failed, Exit Script
            Write-LogEntry -FileName $LogFileName -Value "Failed to Suspend Bitlocker on drive $drive , Exiting." -Process FAILED
            exit
        }
    }
} else {
    $drive = manage-bde.exe -status c:
    if ($drive -match "    Protection Status:    Protection On") {
        Write-LogEntry -FileName $LogFileName -Value "Attempting to Suspend Bitlocker on drive C: ."
        manage-bde.exe -protectors -disable c:
        $verifydrive = manage-bde.exe -status c:
        if ($verifydrive -match "    Protection Status:    Protection On") {
            #Bitlocker Suspend Failed, Exit Script
            Write-LogEntry -FileName $LogFileName -Value "Failed to Suspend Bitlocker on drive C: , Exiting."
            exit
        }
      
        # Create a Scheduled Task to resume Bitlocker on startup, then remove
        cmd /c schtasks /create /f /tn "Bitlock" /XML $currentDirectory\sTask_Details.xml
     }
}

#Get Device Specific Information
$CurrentComputerModel = (Get-CimInstance -ClassName Win32_ComputerSystem).Model

#Get Bios information from device. 
$CurrentBiosVersion = (Get-WmiObject Win32_Bios).smbiosbiosversion

#Latest update version
$LatestVersion = "Updated_Bios_Version"

$FlashUtil = "$PSScriptRoot\HPBIOSUPDREC64.exe"
$binfile = "$PSSCriptRoot\P80_0125.bin"

if([string]::IsNullOrEmpty($CurrentComputerModel) -or [string]::IsNullOrEmpty($CurrentBiosVersion)) {
  Write-LogEntry -FileName $LogFileName -Value "The computer's model and/or Bios version could not be detected."
  exit
} else {
    Write-LogEntry -FileName $LogFileName -Value "Model $currentComputerModel found and $CurrentBiosVersion detected."
    #Install BIOS Update
    if($CurrentComputerModel -like "Enter_HP_Model") {
        if($CurrentBiosVersion -ne $LatestVersion) {
            Write-LogEntry -FileName $LogFileName -Value "Configmgr starting BIOS Update and rebooting." -Process SETUP
            $args = "-s -f$binfile -b"
            $install = Start-Process $FlashUtil -ArgumentList $args -Wait
        } else {
            Write-LogEntry -FileName $LogFileName -Value "The device's bios version is $CurrentBiosVersion, which is the latest bios version, $LatestVersion."
        }   
    }else{
        Write-LogEntry -FileName $LogFileName -Value "The workstation model number is $CurrentComputerModel and not an HP EliteBook x360 1030 G2. The bios update cannot run on this device."
    }
}
