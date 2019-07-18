#import scripts
function Get-ScriptDirectory {
    Split-Path -Parent $PSCommandPath
}
$scriptPath = Get-ScriptDirectory
$adplatformsourcedir = split-path -Path $scriptPath -Parent

$ACLScriptspath = $adplatformsourcedir + "\AD_OU_SetACL"
   <#
   cd $ACLScriptspath
    #import all ACL functions from files with the name *permissions.ps1
    $files = Get-ChildItem $ACLScriptspath -Name "*permissions.ps1"
    foreach ($file in $files){
    . ((".\")+$file)
    #Get the function type name from the filename ex User or  Computer
    
    $prefix = ($file.Split( ))[0]
    #make a new variable with the objectypefunctions as prefix and _functions as suffix.  then add all functions to that functionlist
    $ObjectTypeFunctions = $prefix + "_functionlist"
    New-Variable -Name $ObjectTypeFunctions -Value @()
    $functionList = Select-String -Path $file -Pattern "function"
        # Iterate through all of the returned lines
        foreach ($functionDef in $functionList)
        {
            # Get index into string where function definition is and skip the space
            $funcIndex = ($functionDef.line.Split(" ("))[1]
             $($ObjectTypeFunctions).add($funcIndex +",")
        }
    
    }
    #>
$Permissions = @()
$row = @()

#===================================================================
#Full Control PERMISSIONS
$FunctionSet = "Full Control Permissions"
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'FullControl';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'FullControlUsers';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'FullControlGroups';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'FullControlComputers';APPLY = 'FALSE'}

#===================================================================
#USER PERMISSIONS
$FunctionSet = "User Control Permissions"
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateUserAccount';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteUserAccount';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'RenameUserAccount';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DisableUserAccount';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'UnlockUserAccount';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'EnableDisabledUserAccount';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ResetUserPasswords';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ForcePasswordChangeAtLogon';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyUserGroupMembership';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyUserProperties';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DenyModifyLogonScript';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DenySetUserSPN';APPLY = 'FALSE'}

#END USER PERMISSIONS 
#===================================================================
#COMPUTER PERMISSIONS
$FunctionSet = "Computer Control Permissions"
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateComputerAccount';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteComputerAccount';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'RenameComputerAccount';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DisableComputerAccount';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'EnableDisabledComputerAccount';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyComputerProperties';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ResetComputerAccount';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyComputerGroupMembership';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'SetComputerSPN';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ReadComputerTPMBitLockerInfo';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ReadComputerAdmPwd';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ResetComputerAdmPwd';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DomainJoinComputers';APPLY = 'FALSE'}
#END COMPUTER PERMISSIONS
#===================================================================
#GROUP PERMISSIONS
$FunctionSet = "Group Control Permissions"
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateGroup';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteGroup';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'RenameGroup';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyGroupProperties';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyGroupMembership';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyGroupGroupMembership';APPLY = 'FALSE'}

#END GROUP PERMISSIONS
#===================================================================
#OU PERMISSIONS
$FunctionSet = "OU Control Permissions"
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateOU';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteOU';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'RenameOU';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyOUProperties';APPLY = 'FALSE'}
#END OU PERMISSIONS
#===================================================================
# GPO PERMISSIONS
$FunctionSet = "OU Control Permissions"
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'LinkGPO';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'GenerateRsopPlanning';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'GenerateRsopLogging';APPLY = 'FALSE'}
#END GPO PERMISSIONS
#===================================================================
# PRINTER PERMISSIONS
$FunctionSet = "Printer Control Permissions"
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreatePrintQueue';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeletePrintQueue';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'RenamePrintQueue';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyPrintQueueProperties';APPLY = 'FALSE'}
#END PRINTER PERMISSIONS
#===================================================================
# Replication  PERMISSIONS
$FunctionSet = "Replication Control Permissions"
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ManageReplicationTopology';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ReplicatingDirectoryChanges';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ReplicatingDirectoryChangesAll';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ReplicatingDirectoryChangesInFilteredSet';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ReplicationSynchronization';APPLY = 'FALSE'}
#END Replication PERMISSIONS
#===================================================================
# Site and Subnet  PERMISSIONS
$FunctionSet = "Site and Subnet Control Permissions"
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateSiteObjects';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteSiteObjects';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifySiteProperties';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateSubnetObjects';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteSubnetObjects';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifySubnetProperties';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateSiteLinkObjects';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteSiteLinkObjects';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifySiteLinkProperties';APPLY = 'FALSE'}

#===========================================
#ADD ALL PARAMETERS TO $PERMISSIONS
$Permissions += $row
$permissions