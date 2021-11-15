# PowerShell: Get a List of Installed Applications

## Don't Do...

Do you need to get a list of installed applications from a computer don't use Win32_Product, and here is why:

*"The **Win32_product** class is not query optimized. Queries such as “select * from Win32_Product where (name like ‘Sniffer%’)” require WMI to use the MSI provider to enumerate all of the installed products and then parse the full list sequentially to handle the “where” clause:,*

- *This process initiates a consistency check of packages installed, and then verifying and repairing the installations.*
- *If you have an application that makes use of the **Win32_Product** class, you should contact the vendor to get an updated version that does not use this class.*

*On Windows Server 2003, Windows Vista, and newer operating systems, querying **Win32_Product** will trigger Windows Installer to perform a consistency check to verify the health of the application. This consistency check could cause a repair installation to occur. You can confirm this by checking the Windows Application Event log. You will see the following events each time the class is queried and for each product installed"*

## Reference

> [Use PowerShell to Quickly Find Installed Software](https://devblogs.microsoft.com/scripting/use-powershell-to-quickly-find-installed-software/)
