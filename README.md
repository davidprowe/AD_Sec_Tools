# Create-Tiers in AD
Project Title
Active Directory Auto Deployment of Tiers in any environment

Getting Started
This code is written in PowerShell and requires the AD commandlets to run.  The current scripts in the repo: create a tiered structured in an active directory environment, create tiered groups with very granular permissions on the domain and create ACL permissions on the OUs based on the name of the group.

Prerequisites
ADDS
Active directory powershell modules

Installing
PLACEHOLDER FOR instructions.  
AD_Computer_CachedCreds - script description and instructions
AD_GetACL_on_OBJECTS - scripts descriptions and reading instructions
AD_LAPS_INSTALL - script - run as schema admin, and import GPO as found in pictures in the presentation folder.
CREATE TIERS - subfolder contains additional instructions

To learn more about Microsoft tiers, please start with: https://social.technet.microsoft.com/wiki/contents/articles/37509.active-directory-red-forest-design-aka-enhanced-security-administrative-environment-esae.aspx 

Authors
David Rowe - @customes
See also the list of contributors who participated in this project.

License
This project is licensed under the MIT License - see the LICENSE.md file for details

Acknowledgments
Microsoft technet scripts and gpos used.  Much appreciation.
