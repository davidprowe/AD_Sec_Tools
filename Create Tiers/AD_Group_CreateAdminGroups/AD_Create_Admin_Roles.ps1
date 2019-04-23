$addomain = (get-addomain).distinguishedname
#where the script puts the role groups
$LocationForT1Roles = "OU=ADM-Roles,OU=Tier 1,OU=Admin,"
$locationforT2Roles = "OU=ADM-Roles,OU=Tier 2,OU=Admin,"
# this makes the name of the group
$tierGroupPrefix = @('Tier1','Tier2')
$tierGroupObjects = @('Accounts','Groups','Devices')
$tierGroupSuffix = "Admins"
$helpdesksuffix = "Helpdesk"

function Get-ScriptDirectory {
    Split-Path -Parent $PSCommandPath
}
$scriptPath = Get-ScriptDirectory
$adplatformsourcedir = split-path -Path $scriptPath -Parent
$permissionset = & $adplatformsourcedir + "\AD_Group_CreateAdminGroups\AD Permissions for Group Granular Access.ps1"
#=====================================
<#
Old import method
$affiliatesCSV = $adplatformsourcedir + '\AD_OU_CreateStructure\3lettercodeaff.csv'
$DepartmentsCSV = $adplatformsourcedir + '\AD_OU_CreateStructure\3lettercodedepts.csv'
$CentralAdministrationCSV = $adplatformsourcedir + '\AD_OU_CreateStructure\3lettercodecent.csv'
$schoolsCSV = $adplatformsourcedir + '\AD_OU_CreateStructure\3lettercodeschools.csv'
#>
#3 letter affiliate codes here
$3LetterCodeCSV = $scriptPath + '\3lettercodes.csv'

$csvlist = @()
$csvlist = import-csv $3LetterCodeCSV
<#
Olde import method
$csvlist += Import-Csv $CentralAdministrationCSV
$csvlist += import-csv $schoolsCSV
$csvlist += Import-Csv $affiliatesCSV
$csvlist += import-csv $DepartmentsCSV
#>

foreach ($code in $csv){
    #======================================================================
    #tier 1 group creations
        #set ou location with groupdestination
        $groupdestination = $LocationForT1Roles + $addomain
        foreach ($objecttype in $tierGroupObjects){
            $groupname = $code.name + "_" + $tierGroupPrefix[0] + "_" + $tierGroupObjects +"_" + $tierGroupSuffix
            New-ADGroup -Name $groupname -Path $groupdestination -GroupCategory Security -GroupScope Global
        }
        #Create Helpdesk group in tier
        $groupname = $code.name + "_" + $tierGroupPrefix[0] + "_" + $helpdesksuffix
        New-ADGroup -Name $groupname -Path $groupdestination -GroupCategory Security -GroupScope Global
    #=====================================================================
    #tier 2 group creations
    $groupdestination = $LocationForT2Roles + $addomain
    foreach ($objecttype in $tierGroupObjects){
        $groupname = $code.name + "_" + $tierGroupPrefix[1] + "_" + $tierGroupObjects +"_" + $tierGroupSuffix
        New-ADGroup -Name $groupname -Path $groupdestination -GroupCategory Security -GroupScope Global
    }
        #Create Helpdesk group in tier
        $groupname = $code.name + "_" + $tierGroupPrefix[1] + "_" + $helpdesksuffix
        New-ADGroup -Name $groupname -Path $groupdestination -GroupCategory Security -GroupScope Global
    

}