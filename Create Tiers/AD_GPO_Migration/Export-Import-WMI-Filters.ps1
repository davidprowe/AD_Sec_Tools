<#
http://www.jhouseconsulting.com/2014/06/09/script-to-create-import-and-export-group-policy-wmi-filters-1354
http://gallery.technet.microsoft.com/scriptcenter/f1491111-9f5d-4c83-b436-537eca9e8d94
http://blogs.technet.com/b/manny/archive/2012/02/04/perform-a-full-export-and-import-of-wmi-filters-with-powershell.aspx
http://blogs.technet.com/b/manny/archive/2012/02/05/exporting-and-importing-wmi-filters-with-powershell-part-2-import.aspx
#>

Function Create-WMIFilters 
{ 
    # Importing or adding a WMI Filter object into AD is a system only operation.  
    # You need to enable system only changes on a domain controller for a successful import.  
    # To do this, on the domain controller you are using for importing, open the registry editor and create the following registry value. 
    # 
    # Key: HKLM\System\CurrentControlSet\Services\NTDS\Parameters  
    # Value Name: Allow System Only Change  
    # Value Type: REG_DWORD  
    # Value Data: 1 (Binary) 
    # 
    # Put this somewhere in your master code: new-itemproperty "HKLM:\System\CurrentControlSet\Services\NTDS\Parameters" -name "Allow System Only Change" -value 1 -propertyType dword 
 
 
    # Name,Query,Description 
    $WMIFilters = @(   ('Virtual Machines', 'SELECT * FROM Win32_ComputerSystem WHERE Model = "Virtual Machine"', 'Hyper-V'), #WORKS
                    ('Workstation 32-bit', 'Select * from WIN32_OperatingSystem where ProductType=1 Select * from Win32_Processor where AddressWidth = "32"', ''), #WORKS 
                    ('Workstation 64-bit', 'Select * from WIN32_OperatingSystem where ProductType=1 Select * from Win32_Processor where AddressWidth = "64"', ''), #WORKS 
                    ('Workstations', 'SELECT * FROM Win32_OperatingSystem WHERE ProductType = "1"', ''), #WORKS 
                    ('Domain Controllers', 'SELECT * FROM Win32_OperatingSystem WHERE ProductType = "2"', ''), #WORKS 
                    ('Servers', 'SELECT * FROM Win32_OperatingSystem WHERE ProductType = "3"', ''), #WORKS 
                    ('Resources', 'Select * from Win32_LogicalDisk where FreeSpace > 629145600 AND Description <> "Network Connection"', 'Target only machines that have at least 600 megabytes (MB) available.'), 
                    ('Hotfix', 'Select * from Win32_QuickFixEngineering where HotFixID = "q147222"', 'Apply a policy on computers that have a specific hotfix.'), 
                    ('Time zone', 'Select * from win32_timezone where bias =120', 'Apply policy on all servers located in the South of Africa.'), 
                    ('Configuration', 'Select * from Win32_NetworkProtocol where SupportsMulticasting = true', 'Avoid turning on netmon on computers that can have multicasting turned on.'), 
                    ('Windows 2000', 'select * from Win32_OperatingSystem where Version like "5.0%"', 'This is used to filter out GPOs that are only meant for Windows 2000 systems and should not apply to newer OSes eventhough Windows 2000 does not support WMI filtering'), 
                    ('Windows XP', 'select * from Win32_OperatingSystem where (Version like "5.1%" or Version like "5.2%") and ProductType = "1"', ''), 
                    ('Windows Vista', 'select * from Win32_OperatingSystem where Version like "6.0%" and ProductType = "1"', ''), 
                    ('Windows 7', 'select * from Win32_OperatingSystem where Version like "6.1%" and ProductType = "1"', ''), 
                    ('Windows Server 2003', 'select * from Win32_OperatingSystem where Version like "5.2%" and ProductType = "3"', ''), 
                    ('Windows Server 2008', 'select * from Win32_OperatingSystem where Version like "6.0%" and ProductType = "3"', ''), 
                    ('Windows Server 2008 R2', 'select * from Win32_OperatingSystem where Version like "6.1%" and ProductType = "3"', ''), 
                    ('Windows Vista and Windows Server 2008', 'select * from Win32_OperatingSystem where Version like "6.0%" and ProductType<>"2"', ''), 
                    ('Windows Server 2003 and Windows Server 2008', 'select * from Win32_OperatingSystem where (Version like "5.2%" or Version like "6.0%") and ProductType="3"', ''), 
                    ('Windows 2000, XP and 2003', 'select * from Win32_OperatingSystem where Version like "5.%" and ProductType<>"2"', ''), 
                    ('Manufacturer Dell', 'Select * from WIN32_ComputerSystem where Manufacturer = "DELL"', ''), 
                    ('Installed Memory > 1Gb', 'Select * from WIN32_ComputerSystem where TotalPhysicalMemory >= 1073741824', ''), 
                    ('Build Value','Select * from Microsoft_BDD_Info where(BuildValue !="NewBuild")', ''),
                    ('Windows 10 or WIndows Server 2016', 'select * from Win32_OperatingSystem WHERE Version like "10.%"',''),
                    ('Windows Server 2012 R2 Operating System', 'select * from Win32_OperatingSystem WHERE Version like ""6.3%"" AND ProductType=""3""',''),
                    ('Windows Server 2016 Operating System','select * from Win32_OperatingSystem WHERE Version like "10.%" AND ProductType="3"','')

                ) 
 
    $defaultNamingContext = (get-adrootdse).defaultnamingcontext  
    $configurationNamingContext = (get-adrootdse).configurationNamingContext  
    $msWMIAuthor = "MicrosoftTieredImport@" + [System.DirectoryServices.ActiveDirectory.Domain]::getcurrentdomain().name 
     
    for ($i = 0; $i -lt $WMIFilters.Count; $i++)  
    { 
        $WMIGUID = [string]"{"+([System.Guid]::NewGuid())+"}"    
        $WMIDN = "CN="+$WMIGUID+",CN=SOM,CN=WMIPolicy,CN=System,"+$defaultNamingContext 
        $WMICN = $WMIGUID 
        $WMIdistinguishedname = $WMIDN 
        $WMIID = $WMIGUID 
 
        $now = (Get-Date).ToUniversalTime() 
        $msWMICreationDate = ($now.Year).ToString("0000") + ($now.Month).ToString("00") + ($now.Day).ToString("00") + ($now.Hour).ToString("00") + ($now.Minute).ToString("00") + ($now.Second).ToString("00") + "." + ($now.Millisecond * 1000).ToString("000000") + "-000" 
 
        $msWMIName = $WMIFilters[$i][0] 
        $msWMIParm1 = $WMIFilters[$i][2] + " " 
        $msWMIParm2 = "1;3;10;" + $WMIFilters[$i][1].Length.ToString() + ";WQL;root\CIMv2;" + $WMIFilters[$i][1] + ";" 
 
        $Attr = @{"msWMI-Name" = $msWMIName;"msWMI-Parm1" = $msWMIParm1;"msWMI-Parm2" = $msWMIParm2;"msWMI-Author" = $msWMIAuthor;"msWMI-ID"=$WMIID;"instanceType" = 4;"showInAdvancedViewOnly" = "TRUE";"distinguishedname" = $WMIdistinguishedname;"msWMI-ChangeDate" = $msWMICreationDate; "msWMI-CreationDate" = $msWMICreationDate} 
        $WMIPath = ("CN=SOM,CN=WMIPolicy,CN=System,"+$defaultNamingContext) 
     
        New-ADObject -name $WMICN -type "msWMI-Som" -Path $WMIPath -OtherAttributes $Attr 
    } 
 
} 
 
Create-WMIFilters 
 