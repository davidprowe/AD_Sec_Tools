Import-Module activedirectory
#Set-Location ad:
# Report directory
$logdir = 'C:\Reports'
$logprefix = "Group_permissions"
$logsuffix = ".csv"
$logfilename = $logprefix + $logsuffix
$fileBIG = 2
$testspecificGroup = $true
$specificgroup = 'server operators'
if ($testspecificgroup -eq $true) {$g = (Get-ADGroup $specificgroup).distinguishedname}
else{}
$drive = 'ad'
#Add-HarADDrives 0 $account f
#======================================================================================
#test for path and create folder if not exist
if((Test-Path $logdir) -eq 0)
{
mkdir $logdir
}
$logfile    = Join-Path $logdir ($logfilename)


# This array will hold the report output.
$report = @()

# Build a lookup hash table that holds all of the string names of the
# ObjectType GUIDs referenced in the security descriptors.
# See the Active Directory Technical Specifications:
#  3.1.1.2.3 Attributes
#    http://msdn.microsoft.com/en-us/library/cc223202.aspx
#  3.1.1.2.3.3 Property Set
#    http://msdn.microsoft.com/en-us/library/cc223204.aspx
#  5.1.3.2.1 Control Access Rights
#    http://msdn.microsoft.com/en-us/library/cc223512.aspx
#  Working with GUID arrays
#    http://blogs.msdn.com/b/adpowershell/archive/2009/09/22/how-to-find-extended-rights-that-apply-to-a-schema-class-object.aspx
# Hide the errors for a couple duplicate hash table keys.
$schemaIDGUID = @{}
### NEED TO RECONCILE THE CONFLICTS ###
$ErrorActionPreference = 'SilentlyContinue'
Get-ADObject -SearchBase (Get-ADRootDSE).schemaNamingContext -LDAPFilter '(schemaIDGUID=*)' -Properties name, schemaIDGUID |
 ForEach-Object {$schemaIDGUID.add([System.GUID]$_.schemaIDGUID,$_.name)}
Get-ADObject -SearchBase "CN=Extended-Rights,$((Get-ADRootDSE).configurationNamingContext)" -LDAPFilter '(objectClass=controlAccessRight)' -Properties name, rightsGUID |
 ForEach-Object {$schemaIDGUID.add([System.GUID]$_.rightsGUID,$_.name)}
$ErrorActionPreference = 'Continue'


# Get a list of all groups.  
$groups  = get-adgroup -f *

################################################################################################
if ($testspecificGroup -eq $true){
$g = Get-ADGroup $specificgroup
#$group = get-adgroup $specificgroup
#$groupsid = $group.SID.value
#$groupdispname = $group.Name
#$ou = 'OU=Administrators,OU=Administrative_Accounts,DC=CHOA,DC=ORG'
#$acl = get-acl $ou
#$groupaccess = $acl.access|where-object {($_.identityreference -eq $groupsid -or $_.identityreference -eq $groupname)}
#foreach ($access in $groupaccess){
#$guid = $access.objecttype

#testing: $OUs  = Get-ADOrganizationalUnit -Identity 'OU=Administrators,OU=Administrative_Accounts,DC=CHOA,DC=ORG'

    $report += Get-Acl -Path "$drive`:\\$g" |
     Select-Object -ExpandProperty Access |where-object {($_.IsInherited -eq 0)} |
     Select-Object @{name='GroupName';expression={$g}}, `
                   @{name='objectTypeName';expression={if ($_.objectType.ToString() -eq '00000000-0000-0000-0000-000000000000') {'All'} Else {$schemaIDGUID.Item($_.objectType)}}}, `
                   @{name='inheritedObjectTypeName';expression={$schemaIDGUID.Item($_.inheritedObjectType)}}, `
                   *
                   $report | Export-Csv -Path $logfile -NoTypeInformation
}

else
{
$i = 1
$C = $groups.count
ForEach ($group in $groups) {


            if ($i.ToString() -like "*00")
                {
                    write-host $i of $c --- ([System.Math]::Round(($i/$c*100),2))% of Groups Completed
                }

    $report = Get-Acl -Path "$drive`:\\$group" |
     Select-Object -ExpandProperty Access |where-object {($_.IsInherited -eq 0)} |
     Select-Object @{name='Groupname';expression={$group}}, `
                   @{name='objectTypeName';expression={if ($_.objectType.ToString() -eq '00000000-0000-0000-0000-000000000000') {'All'} Else {$schemaIDGUID.Item($_.objectType)}}}, `
                   @{name='inheritedObjectTypeName';expression={$schemaIDGUID.Item($_.inheritedObjectType)}}, `
                   *
if ($i -eq 1){$report | Export-Csv -Path $logfile -NoTypeInformation} 
else {
if ((get-item $logfile).length -gt 100mb) {
$logprefix = "Group_permissions"
$logsuffix = ".csv"
$logfilename = $logprefix + $filebig+ $logsuffix
$fileBIG++
$logfile    = Join-Path $logdir ($logfilename)
$report | Export-Csv -Path $logfile -NoTypeInformation
   
   }
else{$report | Export-Csv -Path $logfile -append}

}

$i++
}


}
# Dump the raw report out to a CSV file for analysis in Excel.

Start-Process $logfile
