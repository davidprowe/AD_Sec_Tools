#Create admin groups so that tiered groups are added to these to prevent cross tiered access
<#
Tier2Admins@adatum.com ---check
Tier2DeviceOperators@adatum.com ---check
Tier2HelpdeskOperators@adatum.com ---check
Tier1Operators@adatum.com ---check
Tier 2 Computer Quarantine Operators@adatum.com ---check
Tier 0 HGS Admins@adatum.com ---check
BreakGlassAdmins@adatum.com ---check
Tier1ServerOperators@adatum.com--- check
Tier 0 Application Operators@adatum.com ---check
Tier1Admins@adatum.com ---check
Tier2Operators@adatum.com ---check 
AdminDomainJoin@adatum.com ---check
Tier0ServerOperators@adatum.com ---check
Tier0Operators@adatum.com ---check
Tier0Admins@adatum.com ---check
#>


#=============================================
#Vars
$T0adminOU = 'OU=T0-Roles,OU=Tier 0,OU=Admin'
$T0AllAdminGroupName = 'Tier0Admins'
$T0AppAdminGroupName = 'Tier 0 Application Operators'
$T0HGSAdminGroupName = 'Tier 0 HGS Admins'
$T0opsAdminGroupName = 'Tier0Operators'
$T0SRVAdminGroupName = 'Tier0ServerOperators'
$AdminDomainJoinGroupName = 'AdminDomainJoin'
$AdminBTGGroupName = 'BreakGlassAdmins'


$T1adminOU = 'OU=T1-Roles,OU=Tier 1,OU=Admin'
$T1AllAdminGroupName = 'Tier1Admins'
$T1OPSAdminGroupName = 'Tier1Operators'
$T1SRVAdminGroupName = 'Tier1ServerOperators'

#microsoft groups include : Tier1serveroperators, tier1operators, Tier1admins
$T2AdminOU = 'OU=T2-Roles,OU=Tier 2,OU=Admin'
$T2AllAdminGroupName = 'Tier2Admins'
$T2DevAdminGroupName = 'Tier2DeviceOperators'
$T2HDAdminGroupName = 'Tier2HelpdeskOperators'
$T2QuarAdminGroupName = 'Tier 2 Computer Quarantine Operators'
$T2OpsAdminGroupName = 'Tier2Operators'
#microsot t2 groups include: Tier2admins, tier2helpdeskoperators, tier2operators,

#=============================================


$dn = (get-addomain).distinguishedname
$dc = (get-addomain).PDCEmulator
$t0adminou = $t0adminou +','+ $dn
$t1adminou = $t1adminou +','+ $dn
$t2adminou = $t2adminou +',' + $dn

#create the tiered admin  group buckets
#-------------------------------------------------------------Tier 0 Admin Groups
New-ADGroup -Description "Tier 0 group that contains all T0 administrators" -Name $T0AllAdminGroupName -Path $t0adminou -GroupCategory Security -GroupScope Global -Server $dc
New-ADGroup -Description "Tier 0 group that manages T0 applications" -Name $T0AppAdminGroupName -Path $t0adminou -GroupCategory Security -GroupScope Global -Server $dc
New-ADGroup -Description "Tier 0 group that manages T0 HGS" -Name $T0HGSAdminGroupName -Path $t0adminou -GroupCategory Security -GroupScope Global -Server $dc
New-ADGroup -Description "Tier 0 group that contains T0 Server operators" -Name $T0opsAdminGroupName -Path $t0adminou -GroupCategory Security -GroupScope Global -Server $dc
New-ADGroup -Description "Tier 0 group that contains T0 Server Admins" -Name $T0SRVAdminGroupName -Path $t0adminou -GroupCategory Security -GroupScope Global -Server $dc
New-ADGroup -Description "Tier 0 group that contains T0 Break the glass admins" -Name $AdminBTGGroupName -Path $t0adminou -GroupCategory Security -GroupScope Global -Server $dc
New-ADGroup -Description "Admin group that contains users who can add machines to admin OUs" -Name $AdminDomainJoinGroupName -Path $t0adminou -GroupCategory Security -GroupScope Global -Server $dc

#-------------------------------------------------------------Tier 1 Admin Groups
New-ADGroup -Description "Tier 1 group that contains all T1 administrators" -Name $T1AllAdminGroupName -Path $t1adminou -GroupCategory Security -GroupScope Global -Server $dc
New-ADGroup -Description "Tier 1 group that contains all T1 operators" -Name $T1OPSAdminGroupName -Path $t1adminou -GroupCategory Security -GroupScope Global -Server $dc
New-ADGroup -Description "Tier 1 group that contains all T1 server operators" -Name $T1SRVAdminGroupName -Path $t1adminou -GroupCategory Security -GroupScope Global -Server $dc
#New Group as of 7/2/18 which will hold service accounts which will be blocked denied logon local on tiered assets
New-ADGroup -Description "Denys local logon and RDP access to Service Accounts" -Name 'GPO-Deny-Accounts-Interactive-Logon' -Path $T1adminOU -GroupCategory Security -GroupScope Global -Server $dc

#-------------------------------------------------------------Tier 2 Admin Groups
$T2DevAdminGroupName = 'Tier2DeviceOperators'
$T2HDAdminGroupName = 'Tier2HelpdeskOperators'
$T2QuarAdminGroupName = 'Tier 2 Computer Quarantine Operators'
$T2OpsAdminGroupName = 'Tier2Operators'
New-ADGroup -Description "Tier 2 group that contains all T2 administrative users" -Name $T2AllAdminGroupName -Path $t2adminou -GroupCategory Security -GroupScope Global -Server $dc
New-ADGroup -Description "Tier 2 group that contains all T2 device operators users" -Name $T2DevAdminGroupName -Path $t2adminou -GroupCategory Security -GroupScope Global -Server $dc
New-ADGroup -Description "Tier 2 group that contains all T2 HelpDesk users" -Name $T2HDAdminGroupName -Path $t2adminou -GroupCategory Security -GroupScope Global -Server $dc
New-ADGroup -Description "Tier 2 group that manages all T2 Computer Quarantine" -Name $T2QuarAdminGroupName -Path $t2adminou -GroupCategory Security -GroupScope Global -Server $dc
New-ADGroup -Description "Tier 2 group that contains all T2 operator role users" -Name $T2OpsAdminGroupName -Path $t2adminou -GroupCategory Security -GroupScope Global -Server $dc



<#
$T0group = get-adgroup -Identity $T0AllAdminGroupName
$T1group = get-adgroup -Identity $T1AllAdminGroupName
$T2group = get-adgroup -Identity $T2AllAdminGroupName
#>
<# I dont think i need to output the data of the new groups.  The groups configured match the microsoft group names so that the migtable
#created in the gpo import should match the new groups on this new domain.
Get-adgroup -SearchBase $t0adminou -f {Name -ne $T0AllAdminGroupName} |ForEach-Object{ Add-ADGroupMember -Identity $t0group -Members $_}
Get-adgroup -SearchBase $t1adminou -f {Name -ne $T1AllAdminGroupName} |ForEach-Object{ Add-ADGroupMember -Identity $t1group -Members $_}
get-adgroup -SearchBase $T2AdminOU -f {Name -ne $T2AllAdminGroupName} |ForEach-Object{ Add-ADGroupMember -Identity $t2group -Members $_}

$output = @()
$outputOBJ = new-object psobject
$outputOBJ | Add-Member -MemberType NoteProperty -name "Tier" -value "Tier 0 Servers"
$outputOBJ | Add-Member -MemberType NoteProperty -name "Name" -value $T0AllAdminGroupName
$output += $outputOBJ

$outputOBJ = new-object psobject
$outputOBJ | Add-Member -MemberType NoteProperty -name "Tier" -value "Tier 0 Apps"
$outputOBJ | Add-Member -MemberType NoteProperty -name "Name" -value $T0AppAdminGroupName
$output += $outputOBJ


$outputOBJ = new-object psobject
$outputOBJ | Add-Member -MemberType NoteProperty -name "Tier" -value "Tier 1"
$outputOBJ | Add-Member -MemberType NoteProperty -name "Name" -value $T1AllAdminGroupName
$output += $outputOBJ

$outputOBJ = new-object psobject
$outputOBJ | Add-Member -MemberType NoteProperty -name "Tier" -value "Tier 2"
$outputOBJ | Add-Member -MemberType NoteProperty -name "Name" -value $T2AllAdminGroupName
$output += $outputOBJ

$outputOBJ = new-object psobject
$outputOBJ | Add-Member -MemberType NoteProperty -name "Tier" -value "Admin Domain Join"
$outputOBJ | Add-Member -MemberType NoteProperty -name "Name" -value $AdminDomainJoinGroupName
$output += $outputOBJ

#output information to use in the chaining of scripts.  Info on group names needs to be imported into the GPO modification script.
$output

#>