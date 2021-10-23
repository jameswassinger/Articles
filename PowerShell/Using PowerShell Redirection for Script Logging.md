# Using PowerShell Redirection for Script Logging

If you have written a PowerShell script you may have wanted some type of script logging. Logging can be as simple as using the Write-* PowerShell Cmdlets to show output to the PowerShell console to keep track of the scripts progress, troubleshoot, etc.

However, the script may need to run in the background without a console, for example, if you write a PowerShell script for ConfigMgr to install an application, run a PowerShell script with a scheduled task, or for another automation operation the script will need some sort of logging, so that someone can verify that the script ran successfully, troubleshoot issues, or check progress.

## What has been done

If you do a search on the web for PowerShell Logging you can find some good articles written on how to write a PowerShell Logging function. I have used these functions in my scripts before, some of which are still in production. Take for example the below function.

```powershell
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
 
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information','Warning','Error')]
        [string]$Severity = 'Information'
    )
 
    [pscustomobject]@{
        Time = (Get-Date -f g)
        Message = $Message
        Severity = $Severity
    } | Export-Csv -Path "$env:Temp\LogFile.csv" -Append -NoTypeInformation
 }
```

The above example is not a reference to any particular online article. If you do a search for a PowerShell logging functions online you will see the above example used in several different online articles.

The issues I have with using a function like this is that you will need to call the function within other functions to write results to the log file, and there is not a way to write verbose entries to the log without heavily modifying the function.

```powershell
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
 
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information','Warning','Error')]
        [string]$Severity = 'Information'
    )
 
    [pscustomobject]@{
        Time = (Get-Date -f g)
        Message = $Message
        Severity = $Severity
    } | Export-Csv -Path "$env:WinDir\Temp\LogFile.csv" -Append -NoTypeInformation
 }
 
 function Get-ComputerSystemInfo {
 [CmdletBinding()]
 param(
     [Parameter()]
     [String]$ComputerName = "localhost"
 )
 
 try {
     
     $ComputerInfo = Get-WmiObject -Class win32_ComputerSystem
     Write-Log -Message $ComputerInfo
     
 } catch {
     Write-Log -Message "$($_.Exception.Message)" -Severity Error
 }
}

Get-ComputerSystemInfo
```

In an effort to find something better, something more versatile I started to experiment with PowerShell redirection, Get-Help about_Redirection.

## PowerShell Redirection

What is PowerShell Redirection? PowerShell sends output to the PowerShell host. Usually this is the console application. However, you can direct the output to a text file, and you can redirect error output to the regular output stream ([about_Redirection](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-7.1#:~:text=%20You%20can%20use%20the%20following%20methods%20to,redirection%20operator%20with%20a%20file%20target...%20More%20)).

When reviewing the use of PowerShell Redirection, I started by experimenting with the Out-File cmdlet. The Out-File cmdlet lets you redirect console output to a file specified in the -Path, for example C:\temp\logfile.txt, but this too became quickly evident that it would not work. I ran into the same issue as with using the custom logging function, and plus I would have to specify the path to the file for each function call😒.

```powershell
Write-Output "Some action..." | Out-File -Path "C:\temp\logfile.txt" -Append
```

## Redirection

Reviewing the Microsoft Help article [about_Redirection](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-7.1#:~:text=%20You%20can%20use%20the%20following%20methods%20to,redirection%20operator%20with%20a%20file%20target...%20More%20) I started to review the redirection operators, specifically the operator combinations to redirect all streams to a file.

```powershell
.\script.ps1 *> script.log
```

The above example shows how to redirect all '*' output from the script to a log file. If you only want to capture certain output streams to the log file you would only include the stream numbers you needed to log.

```powershell
&{
   Write-Warning "hello"
   Write-Error "hello"
   Write-Output "hi"
} 3>&1 2>&1 > P:\Temp\redirection.log
```

' operator to the '>>' so that I can append text to the log file. If the '>' was left the latest output would only be written to the log file. "]]]]}'>

The above example shows how to redirect Success, Warning, and Error streams to a file.

I started to test the combination of the two above examples and combining  the all '*' stream with the redirection block '&{}' effectively resolves what I was looking for. By simply adding the following snippet to any PowerShell script I could log output, to include verbose output, to a log file.

I did change the '>' operator to the '>>' so that I can append text to the log file. If the '>' was left the latest output would only be written to the log file.

```powershell
&{

  Your_code_here
  
} *>> C:\logfile.log
```

Here is the log script that was written early, written using the redirection operators for logging instead of using the logging function.

```powershell
function Get-ComputerSystemInfo {
 [CmdletBinding()]
 param(
     [Parameter()]
     [String]$ComputerName = "localhost"
 )
 
 try {
     
     $ComputerInfo = Get-WmiObject -Class win32_ComputerSystem
     Write-Output $ComputerInfo
     
 } catch {
     Write-Output "$($_.Exception.Message)"
 }
}

& {
    Get-ComputerSystemInfo
} *>> "$env:WinDir\Temp\Logfile.log"
```

What about the special formatting that was in the original logging function? Yes, with using the redirection operators you loses the fancy logging format that the logging function provides, but for me that is not a necessity, but in the future this could be an issue. How can this be resolved?

We can added similar formatted output to the log file by formatting the string for output. For example the below will output the current date and time with the string Test1 (00/00/0000 00:00:00 PM Test1)

```powershell
Write-Output "$("{0} {1}" -f (Get-Date).ToString(),"Test1")"
```

The script using the redirection operators and formatted strings.

```powershell
function Get-ComputerSystemInfo {
 [CmdletBinding()]
 param(
     [Parameter()]
     [String]$ComputerName = "localhost"
 )
 
 try {
     
     $ComputerInfo = Get-WmiObject -Class win32_ComputerSystem
     Write-Output "$("{0} {1}" -f (Get-Date).ToString(),$ComputerInfo)"
     
 } catch {
     Write-Output "$("{0} {1}" -f (Get-Date).ToString(),$_.Exception.Message)"
 }
}

& {
    Get-ComputerSystemInfo
} *>> "$env:WinDir\Temp\Logfile.log"
```