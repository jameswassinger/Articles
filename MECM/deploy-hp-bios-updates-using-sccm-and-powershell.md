# Deploy HP BIOs Updates Using SCCM and PowerShell

Have you been tasked to apply bios upgrades to a large quantity of HP workstations? Well, here is a solution that may work for you. In this post, I will walk you through a method for deploying HP BIOS updates to HP workstations using SCCM and PowerShell. Excited? You should be 😊.

I will tell you up front that the PowerShell script included in this article is written for upgrading one device model at a time. I will discuss how to easily adapt the script to include other device models in a later post.

## Setup

Here is a list of things you will need to successfully implement this in your environment:

- SCCM, 1710 or higher
- PowerShell
- HP BIOS files for the device(s) you would like to upgrade.
- The latest [HP BIOS Configuration Utility](http://ftp.hp.com/pub/caps-softpaq/cmit/HP_BCU.html).
- PowerShell editor, i.e., VSCode or the PowerShell ISE
- FileShare accessible by SCCM (for deployments). This should already be set up.

## The Folder

At this time go ahead and create a new folder in your file share, name the folder HP BIOS Upgrades. This folder is where you will be storing the source information for the SCCM package that will be built.

## The Utility

If you have not done so already go to  [http://ftp.hp.com/pub/caps-softpaq/cmit/HP_BCU.html](http://ftp.hp.com/pub/caps-softpaq/cmit/HP_BCU.html) and download the latest HP BIOS Configuration Utility. Once the download is complete, head over to where you saved the download and copy the file (at the time of this writing the package was  [sp93030.exe](https://ftp.hp.com/pub/softpaq/sp93001-93500/sp93030.exe)) to the file share folder that was just created (folder should be named HP BIOs Upgrades).

After the file is copied to the folder in the file share, unzip the executable file using 7zip or a similar program. Ensure that you extract all the files in the current location.

Let's move on to the script.

## The Script

The PowerShell script is the important part. I will discuss the script and explain what is happening.  A copy of the full script can be downloaded from [Github](https://github.com/jameswassinger/Articles/tree/main/DeployHpBiosUpdates).

## Running the Script

To run the script the following needs to be entered into the command line filed of the SCCM package.

```powershell
.\Upgrade-HpBios.ps1 -LogFileName "HpBiosUpgrade.log"
```

> **Warning** As the script is currently written, the script will upgrade one specified HP model type.

## Explanation of the Script

The first part of the HP BIOS upgrade script is the logging function. The log is written to the 'C:\Windows\Temp\' folder.

```powershell
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
```

Next, the script determines if the device is a laptop and sets the '$isLaptop' variable as necessary.

```powershell
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
```

If the device is a laptop the script then checks the device's battery life. The script will not successfully continue if the device's battery life is less then 30%.

```powershell
# If the device is a laptop and not plugged in exit. 
if(Detect-Laptop) {
    Write-LogEntry -Value "Laptop detected, checking battery life."
    if((Get-WmiObject -Class Win32_Battery).EstimatedChargeRemaining -le 30) {
        Write-LogEntry -FileName $LogFileName -Value "Battery below 30%, canceling BIOS Upgrade...this time."
        exit
    }
}
```

Now, the OS Version is set using a variable and the BitLocker status of the device will be determined. If the device is currently encrypted with BitLocker, BitLocker will be suspended. BitLocker will automatically be reactivated after the device is restarted.

```powershell
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
```

A few more variables are set. The following variables are obtained from the device.

- The device's model is obtained and set using the '$CurrentComputerModel' variable.
- The device's current BIOS version is obtained and set using the '$CurrentBiosVersion' variable.
- For the '$LatestVersion' variable enter in the BIOS version, the device's BIOS should be upgraded to.
- The '$FlashUtil' variable holds the HP BIOS upgrade program.
- The '$binFile' variable holds the HP bin file/upgrade file for the BIOS upgrade file.

```powershell
#Get Device Specific Information
$CurrentComputerModel = (Get-CimInstance -ClassName Win32_ComputerSystem).Model

#Get Bios information from device. 
$CurrentBiosVersion = (Get-WmiObject Win32_Bios).smbiosbiosversion

#Latest update version
$LatestVersion = "Updated_Bios_Version"

$FlashUtil = "$PSScriptRoot\HPBIOSUPDREC64.exe"
$binfile = "$PSSCriptRoot\P80_0125.bin"
```

Finally, the script will determine if the device's BIOS is already at the latest version. If the BIOS is not at the latest version the script will kick off the upgrade.

```powershell
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
```

Hopefully, this article helps with upgrading the BIOS on your HP workstations.

If you are interested in upgrading the BIOS on multiple workstations please stay tuned for the follow-up post on adapting this script to check and upgrade multiple workstations.
