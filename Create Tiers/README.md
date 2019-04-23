# Create-Tiers in AD
Project Title
Active Directory Auto Deployment of Tiers in any environment

Getting Started
This code is written in PowerShell and requires the AD commandlets to run.  The current scripts in the repo: create a tiered structured in an active directory environment, create tiered groups with very granular permissions on the domain and create ACL permissions on the OUs based on the name of the group.

Prerequisites
ADDS
Active directory powershell modules

Installing
Update the CSV to contain the proper 3 letter codes for your environment \AD_OU_CreateStructure\3lettercodes.csv.
    Open this file with a text editor and edit the top lines 
	
Run DeployADStructure.ps1 to create a tiered OU structure, install LAPS, create admin groups and set permissions on the tiers, and import microsoft secure standard GPOs

Authors
David Rowe - Initial work - OU structure, LAPS, Roles & permissions, set acl, gpo migration
Joel Nentwich - Create admin roles under AD_AssignAdminRoles
See also the list of contributors who participated in this project.

License
This project is licensed under the MIT License - see the LICENSE.md file for details

Acknowledgments
Microsoft technet scripts and gpos used.  Much appreciation.
