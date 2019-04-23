<#
T0 GPO - {5311226D-6E0C-4505-BB53-4C71B9E910F5} - '*- Tier 0 Servers' - Folder: {86CF4E85-19BB-4F36-AED9-E9CBF7F2837D} 
    linked to OU = /Admin/Tier 0/T0-Servers
T1 GPO - {713EE0A6-6A23-4055-AED9-594C42F3B80C} - '*- Tier 1 Servers' - Folder: {838EAD6A-88C7-4A43-A407-A0451EFE74EF}
    linked to OU = /Tier 1 Servers
T2 GPO - {B94AD796-F426-48CF-BB3E-6ECC11BA40CA} - '*- Tier 2 Workstations' - Folder: {6EAC8EB3-D729-4991-B718-FB1067593C69}
    linked to OU = /Devices
#>

<#
Changes to the tier 0 GPO:
lines 156, removed breakglassadmins from deny batch logon - no such group
Lines 210 removed tier0serveroperators from interactivelogonright
Lines 217, removed tier0sserveroperators from network logon right
Line 229 - removed admin domain join from network logon right
Line 235 - removed tier0serveroperators from remote interactive logon rights
Line 246 - removed tier 0 application operators from remote interactive logon rights
#>

<#
Changes to tier1 GPO:
line157 - removed Tier2HelpdeskOperators from deny batch logon rights
line 160 - removed tier1operators from deny batch logon rights
line 168 - removed breakglass admins from deny batch logon rights
line 192 - removed t2operators from deny batch logon rights
line 222 - removed tier2operators from deny interactive logon rights
line 242 - removed break glass admin from deny interactive logon rights
line 255 - removed tier2 helpdesk operators from deny interactive logon rights
line 288 - removed tier2operators from dey remote interactive logon
line 307 - removed breakglassadmins from deny remote interactive logon
line 321 - removed Tier2HelpdeskOperators from deny remote interactive logon
line 338 - removed t2helpdesk from deny service logon right
line 343 - removed tier1operators from deny service logon
line 350 - removed breakglassadmins from deny service logon
line 374 - removed tier 2 op from deny service logon
line 400 - removed tier1 server ops from remote interactive logon
line 406 - tier1 server ops from remote interactive logon
#>

<#
changes to tier2 GPO
    Deny batch logon
line 156 - removed tier t2 helpdesk operators
line 160 - tier 1 operators
Line 168 break glass admin
line 192 - removed tier 2 operators
    deny interactive logon
line 230 - remove tier 1 operators
line 238 - remove break glass admins
line 258 - removed tier 2 operators
    deny remote interactive
line 295 - tier1 operators
line 303 - break glass admins
line 323 - tier 2 operators
    deny service logon
line 338 - tier2 helpdesk operators
line 343 - tier 1 operators
line 350 - break glass admin
line 374 - tier 2 operators
line 402- tier 2 device operators
#>

<#TODO:
Update OU location on GPOs
Loop for 3 files to go through and replace info in file with  info stored in array.
Get output list of all inclusive admin groups from previous script, get sid on groups, edit files
#>
$GPOList = @('{86CF4E85-19BB-4F36-AED9-E9CBF7F2837D}','{838EAD6A-88C7-4A43-A407-A0451EFE74EF}','{6EAC8EB3-D729-4991-B718-FB1067593C69}')
$scriptPath = Get-ScriptDirectory
#TODO Copy from GPO_Tier_deploy o GPO
#after copy happens then do an import of 3 gpos in GPO to manipulate them
$GPODir = ($scriptPath + '\GPO')

#i still havent done a get content yet to sift through the files
#make hash table with all the values that I need to change. Search through each file for contains,
#Replace XML file domain info
$xmlToReplace = @{}
$newDomainSID = (Get-addomain).domainSID.value
$NewDomainInfoToReplace = (get-addomain).netbiosname

#this line is the domain info that shows the domain \ groupname
$adatumInfoToReplace = '<Name xmlns="http://www.microsoft.com/GroupPolicy/Types">ADATUM'
$NewDomainInfo = $adatumInfoToReplace -replace 'ADATUM', $NewDomainInfoToReplace
$xmlToReplace.add($adatumInfoToReplace,$NewDomainInfo)



#replace domain admin group sid value on files

$AdatumSidToReplace = 'S-1-5-21-4196981819-2594977862-728305200-512'
$newdomainSidtoReplace = $AdatumSidToReplace -replace 'S-1-5-21-4196981819-2594977862-728305200',$NewDomainSID
$xmlToReplace.add($AdatumSidToReplace,$newdomainSidtoReplace)

#replace administrator sid value on files
$AdatumSidToReplace = 'S-1-5-21-4196981819-2594977862-728305200-500'
$newdomainSidtoReplace = $AdatumSidToReplace -replace 'S-1-5-21-4196981819-2594977862-728305200',$NewDomainSID
$xmlToReplace.add($AdatumSidToReplace,$newdomainSidtoReplace)

#replace domain controller group sid value on files
$AdatumSidToReplace = 'S-1-5-21-4196981819-2594977862-728305200-516'
$newdomainSidtoReplace = $AdatumSidToReplace -replace 'S-1-5-21-4196981819-2594977862-728305200',$NewDomainSID
$xmlToReplace.add($AdatumSidToReplace,$newdomainSidtoReplace)

#replace ReadOnly domain controller group sid value on files
$AdatumSidToReplace = 'S-1-5-21-4196981819-2594977862-728305200-521'
$newdomainSidtoReplace = $AdatumSidToReplace -replace 'S-1-5-21-4196981819-2594977862-728305200',$NewDomainSID
$xmlToReplace.add($AdatumSidToReplace,$newdomainSidtoReplace)

#replace domain computers group sid value on files
$AdatumSidToReplace = 'S-1-5-21-4196981819-2594977862-728305200-515'
$newdomainSidtoReplace = $AdatumSidToReplace -replace 'S-1-5-21-4196981819-2594977862-728305200',$NewDomainSID
$xmlToReplace.add($AdatumSidToReplace,$newdomainSidtoReplace)

#replace enterprise admin sid
$AdatumSidToReplace = 'S-1-5-21-4196981819-2594977862-728305200-519'
$newdomainSidtoReplace = $AdatumSidToReplace -replace 'S-1-5-21-4196981819-2594977862-728305200',$NewDomainSID
$xmlToReplace.add($AdatumSidToReplace,$newdomainSidtoReplace)

#replace schema admin sid
$AdatumSidToReplace = 'S-1-5-21-4196981819-2594977862-728305200-518'
$newdomainSidtoReplace = $AdatumSidToReplace -replace 'S-1-5-21-4196981819-2594977862-728305200',$NewDomainSID
$xmlToReplace.add($AdatumSidToReplace,$newdomainSidtoReplace)

#replace group policy creator owners admin sid
$AdatumSidToReplace = 'S-1-5-21-4196981819-2594977862-728305200-520'
$newdomainSidtoReplace = $AdatumSidToReplace -replace 'S-1-5-21-4196981819-2594977862-728305200',$NewDomainSID
$xmlToReplace.add($AdatumSidToReplace,$newdomainSidtoReplace)

#END BUILTINGROUPS, Now to Custom domain groups
#END BUILTINGROUPS, Now to Custom domain groups
#END BUILTINGROUPS, Now to Custom domain groups
#these groups I will have to query the new domain to get the names of the groups, and the sids of the groups.  
#Then adjust the final 4 digits to the custom group final 4 sid values 
#replace AdminDomainJoin
$AdatumSidToReplace = 'S-1-5-21-4196981819-2594977862-728305200-1116'
$newdomainSidtoReplace = $AdatumSidToReplace -replace 'S-1-5-21-4196981819-2594977862-728305200',$NewDomainSID
$xmlToReplace.add($AdatumSidToReplace,$newdomainSidtoReplace)

#replace Tier0ServerOperators
$AdatumSidToReplace = 'S-1-5-21-4196981819-2594977862-728305200-1121'
$newdomainSidtoReplace = $AdatumSidToReplace -replace 'S-1-5-21-4196981819-2594977862-728305200',$NewDomainSID
$xmlToReplace.add($AdatumSidToReplace,$newdomainSidtoReplace)

#replace Tier 0 Application Operators
$AdatumSidToReplace = 'S-1-5-21-4196981819-2594977862-728305200-1117'
$newdomainSidtoReplace = $AdatumSidToReplace -replace 'S-1-5-21-4196981819-2594977862-728305200',$NewDomainSID
$xmlToReplace.add($AdatumSidToReplace,$newdomainSidtoReplace)

#replace tier 1 admins
$AdatumSidToReplace = 'S-1-5-21-4196981819-2594977862-728305200-1104'
$newdomainSidtoReplace = $AdatumSidToReplace -replace 'S-1-5-21-4196981819-2594977862-728305200',$NewDomainSID
$xmlToReplace.add($AdatumSidToReplace,$newdomainSidtoReplace)

#replace tier 2 admins
$AdatumSidToReplace = 'S-1-5-21-4196981819-2594977862-728305200-1108'
$newdomainSidtoReplace = $AdatumSidToReplace -replace 'S-1-5-21-4196981819-2594977862-728305200',$NewDomainSID
$xmlToReplace.add($AdatumSidToReplace,$newdomainSidtoReplace)
#End replace XML file domain info
$i = 0
Foreach($gpo in $GPOList){
$path = $GPODir + "\" +$gpo+ "\" + "gpreport.xml"
$content = get-content -path $($path)
    do{ 
    $oldinfo = ($xmlToReplace.GetEnumerator()|select -index $i).key
    $newinfo = ($xmlToReplace.GetEnumerator()|select -index $i).value
    $lineNumber = 0
    $i++
    $z = 0
        foreach($line in $gpo){
        if ($line -like "*$oldinfo*"){
        $content[$z] -replace $oldinfo, $newinfo
        write-host on line $z of content file
        $z++
        }
        else{}
        }
    }
    while($i -lt ($xmlToReplace.count -1))
   
#$xmlToReplace.GetEnumerator() |select -Index 1
} #gpo array loop