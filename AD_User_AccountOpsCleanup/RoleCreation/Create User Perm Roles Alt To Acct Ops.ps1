#import config file of group types to create
Import-Module ActiveDirectory
$dn = (Get-ADDomain).distinguishedname
$OUArray = @(("OU=Service Accounts,OU=People"+ $DN),`
("OU=!Pre-Production,"+ $DN),`
("OU=Common,"+ $DN),`
("OU=Users,OU=MAIL,"+ $DN),`
("OU=Testing,"+ $DN)
)

function Get-ScriptDirectory {
    Split-Path -Parent $PSCommandPath
}
#$scriptPath = Get-ScriptDirectory
$scriptpath = 'C:\scripts\AD_User_AccountOpsCleanup\RoleCreation'
$adplatformsourcedir = split-path -Path $scriptPath -Parent
$permissionset = .($scriptPath + "\AD Permissions for Group Granular Access.ps1")
#=====================================


#=============================================
#import ACL function files
$ACLScriptspath = $adplatformsourcedir + "\AD_OU_SetACL"

$files = Get-ChildItem $ACLScriptspath -Name "*permissions.ps1"
    foreach ($file in $files){
    .($aclscriptspath + "\"+$file)
    }

#=============================================
#Tier 1 removing tier 1 access for this deployment
#$Tier1GroupLocation = "OU=T1-Permissions,OU=Tier 1,OU=Admin" + ","+ $dn
#Tier 2
$Tier1GroupLocation = "OU=T1-Permissions,OU=Tier 1,OU=Admin" + "," + $dn
cd ad:
$dc = (get-addomain).PDCEmulator
#=============================================
       
        #Get a reference to the RootDSE of the current domain
        $schemaPath = (Get-ADRootDSE)
        #$schemaobjects = Get-ADObject -filter * -SearchBase $schemaPath.defaultNamingContext -Properties * 
        #Get a reference to the current domain
        $domain = Get-ADDomain
        #============================
        #Create a hashtable to store the GUID value of each schema class and attribute
        $guidmap = @{}
        Get-ADObject -SearchBase ($schemaPath.SchemaNamingContext) -LDAPFilter  `
        "(schemaidguid=*)" -Properties lDAPDisplayName,schemaIDGUID | 
        % {$guidmap[$_.lDAPDisplayName]=[System.GUID]$_.schemaIDGUID}

        #Create a hashtable to store the GUID value of each extended right in the forest
        $extendedrightsmap = @{}
        Get-ADObject -SearchBase ($schemaPath.ConfigurationNamingContext) -LDAPFilter `
        "(&(objectclass=controlAccessRight)(rightsguid=*))" -Properties displayName,rightsGuid | 
        % {$extendedrightsmap[$_.displayName]=[System.GUID]$_.rightsGuid}

#=============================================
#Permission set to OU names
#The function names in the formulas that grant acl permissions do not match our OU naming structure
$PermissionsToOUMapping = @{}
$PermissionsToOUMapping.Add('Full','Full')
$PermissionsToOUMapping.Add('User','ServiceAccounts')
#$PermissionsToOUMapping.Add('Computer','Devices')
#$PermissionsToOUMapping.Add('Group','Groups')
#$PermissionsToOUMapping.Add('OU','OU') #this mapping doesnt entirely matter since on line 94 OU permissions are applied directly to the OU containing the affiliate code
#$PermissionsToOUMapping.Add('Printer', 'Devices')
#=============================================
#BEGIN MAKING GROUPS AND SETTING ACLS

   # Write-Progress -Activity "Deploying OU Structure" -Status "Affiliate Permissions Set Deploy Status:" -PercentComplete ($x/$CSVCount*100)

    foreach ($permission in $permissionset){
        if ($permission.APPLY -eq 'TRUE'){
        
        #BEGIN T2 Group creation and ACLs
        $t1groupname = ("UNIV_T1_" +($permission.FunctionSet.Split( ))[0] +"_" + $permission.FunctionName)
            #generate notes field for each group for details on the permissions
            $notesfield = @()
            foreach ($ou in  $OUArray){
                $notesfield += $permission.Functionname + " Perms on OU " + $ou
                }
            $notesfield = [string]::Join(" || ",$notesfield) -replace $dn, "" -replace "OU=", ""

        New-ADGroup -Description ($permission.Functionset + " " + $permission.FunctionName) -Name $t1groupname -Path $Tier1GroupLocation -GroupCategory Security -GroupScope Global -Server $dc 
        $adgroup = get-adgroup $t1groupname -Server $dc
        $adgroup |Set-ADGroup -replace @{info = $notesfield}
        #================================================================================
        #SET ACLS if first word of functionset equals a value in $permissionstoOUmapping
            if ($PermissionsToOUMapping.keys -contains ($permission.FunctionSet.Split( ))[0]){
                
                    foreach ($topOU in $OUArray){
                    $t1OU = Get-ADOrganizationalUnit $topOU
                    try{iex ($permission.FunctionName + " -objgroup " + '$adgroup' + " -objou " + '$t1OU' + " -inheritanceType `'Descendents`'")}
                    catch{write-host unable to grant permissions for $adgroup.name on OU $t1ou.Name}

                    }

            }
        }
    }
    #$x++

    <#
    foreach ($topOU in $OUArray){
    $topOU
    Test-Path $topou
    }

    $notesfield = @()
    foreach ($ou in  $OUArray){
        $notesfield += $permission.Functioname + "Permissions granted on the OU " + $ou
    
    }

     New-ADGroup -Description ($permission.Functionset + " " + $permission.FunctionName) -Name $t2groupname -Path $Tier2GroupLocation -GroupCategory Security -GroupScope Global -Server $dc  -OtherAttributes @{info="Owner: User1`r`nCo-Owner: User2"}
    
    #>
       