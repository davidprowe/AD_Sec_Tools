# Framework for the Cleanup Built-in group Account Operators Stage #1 Support
Framework stored in AD_User_AccountOpsCleanup folder set
For info on the permissions the account operators groups has on a domain, please read https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/appendix-b--privileged-accounts-and-groups-in-active-directory
This goal is to remove the vast amount of permissions granted on the domain by default to the account operators group.

Prerequisites
ADDS
Active directory powershell modules
Also import the Tiered model using the deploy script found in the Createtiers Folder
I usually store the files in c:\scripts as noted in the $scriptpath variable in the "Create User Perm Roles Alt to Acct Ops.ps1" files

Workflow
Scripts must be run as outlined in step 1
Then Scripts in step 2 must be modified to grant the permissions to the appropriate OUs
The scripts in step two refer to $permissionset files that grant appropriate permissions.  
Use the files referenced in the $permissionset variable to understand the permissions granted with this script

Getting Started - Step 1
This code is written in PowerShell and requires the AD commandlets to run.  The current scripts in the repo: create a tiered structured in an active directory environment, create tiered groups with very granular permissions on the domain and create ACL permissions on the OUs based on the name of the group.
Three scripts help the user by finding users, groups, and computers in the domain.  
FindAllOUsWithComputers.ps1
FindAllOUsWithGroups.ps1
FindAllOUsWithUsers.ps1
Store the output
Manually run these scripts to get an output of OUs on the domain with computers Groups and Users

Step 2
Use the output of these three scrips to load the $OUArray variable with the needed OUs into the following files
User: AD_User_AccountOpsCleanup\RoleCreation\Create User Perm Roles Alt To Acct Ops.ps1
Computer: AD_User_AccountOpsCleanup\RoleCreation\Create Computer Perm Roles Alt To Acct Ops.ps1
	Computer LAPS: Create LAPS Perm Roles Alt To Acct Ops.ps1
	Computer LAPS - Servers: Create LAPS Perm Roles Alt To Acct Ops - Servers.ps1
Groups: AD_User_AccountOpsCleanup\RoleCreation\Create Groups Perm Roles Alt To Acct Ops.ps1

Functions in This Folder
No specific functions yet. There are still a large number of manual steps

Authors
David Rowe - Initial work - AD admin creation and Tiered group management


License
This project is licensed under the MIT License - see the LICENSE.md file for details


