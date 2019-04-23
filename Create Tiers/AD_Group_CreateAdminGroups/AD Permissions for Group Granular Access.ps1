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
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'FullControlUsers';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'FullControlGroups';APPLY = 'FALSE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'FullControlComputers';APPLY = 'FALSE'}

#===================================================================
#USER PERMISSIONS
$FunctionSet = "User Control Permissions"
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateUserAccount';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteUserAccount';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'RenameUserAccount';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DisableUserAccount';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'UnlockUserAccount';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'EnableDisabledUserAccount';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ResetUserPasswords';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ForcePasswordChangeAtLogon';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyUserGroupMembership';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyUserProperties';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DenyModifyLogonScript';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DenySetUserSPN';APPLY = 'TRUE'}

#END USER PERMISSIONS 
#===================================================================
#COMPUTER PERMISSIONS
$FunctionSet = "Computer Control Permissions"
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateComputerAccount';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteComputerAccount';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'RenameComputerAccount';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DisableComputerAccount';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'EnableDisabledComputerAccount';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyComputerProperties';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ResetComputerAccount';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyComputerGroupMembership';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'SetComputerSPN';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ReadComputerTPMBitLockerInfo';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ReadComputerAdmPwd';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ResetComputerAdmPwd';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DomainJoinComputers';APPLY = 'TRUE'}
#END COMPUTER PERMISSIONS
#===================================================================
#GROUP PERMISSIONS
$FunctionSet = "Group Control Permissions"
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateGroup';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteGroup';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'RenameGroup';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyGroupProperties';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyGroupMembership';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyGroupGroupMembership';APPLY = 'TRUE'}

#END GROUP PERMISSIONS
#===================================================================
#OU PERMISSIONS
$FunctionSet = "OU Control Permissions"
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreateOU';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeleteOU';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'RenameOU';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyOUProperties';APPLY = 'TRUE'}
#END OU PERMISSIONS
#===================================================================
# GPO PERMISSIONS
$FunctionSet = "OU Control Permissions"
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'LinkGPO';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'GenerateRsopPlanning';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'GenerateRsopLogging';APPLY = 'TRUE'}
#END GPO PERMISSIONS
#===================================================================
# PRINTER PERMISSIONS
$FunctionSet = "Printer Control Permissions"
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'CreatePrintQueue';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'DeletePrintQueue';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'RenamePrintQueue';APPLY = 'TRUE'}
$row += new-object PSObject -Property @{FunctionSet = $FunctionSet;FunctionName = 'ModifyPrintQueueProperties';APPLY = 'TRUE'}
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