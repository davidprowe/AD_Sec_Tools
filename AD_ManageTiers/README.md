# Microsoft ESAE Stage #1 Support
Stage 1 is defined as:
Separate Admin accounts for Workstations
Separate Admin accounts for Servers
Separate Admin accounts for Domain Controllers
Import New-TierAdminUser.ps1

New-TierAdminUser -SourceAcct 'samaccountname' -Tier 0,1 or 2 

Getting Started
This code is written in PowerShell and requires the AD commandlets to run.  The current scripts in the repo: create a tiered structured in an active directory environment, create tiered groups with very granular permissions on the domain and create ACL permissions on the OUs based on the name of the group.
Create accounts wit the new-tieradminuser.ps1 file
Manage user groups using the scripts in TieredAdmin_GroupMembership.ps1
Each function found in the group membership ps1 file has examples 


Prerequisites
ADDS
Active directory powershell modules
Also import the Tiered model using the deploy script found in the createtiers Folder

Functions in This Folder
New-TierAdminUser
Add-TierAdminToGroup
Remove-TierAdminFromGroup
Clone-TierAdminGroups
Add-TierAdmintoSubGroup

Authors
David Rowe - Initial work - AD admin creation and Tiered group management


License
This project is licensed under the MIT License - see the LICENSE.md file for details


