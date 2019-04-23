function Get-ScriptDirectory {
    Split-Path -Parent $PSCommandPath
}
$basescriptPath = Get-ScriptDirectory
$totalscripts = 8
$i = 1
Write-Progress -Activity "Deploying Tiered Structure" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)


.($basescriptPath + '\AD_LAPS_Install\InstallLAPSSchema.ps1')
Write-Progress -Activity "Deploying Tiered Structure" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
$I++
.($basescriptPath + '\AD_OU_CreateStructure\CreateOUStructure_v5.ps1')
Write-Progress -Activity "Deploying Tiered Structure" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
$I++
.($basescriptPath + '\AD_Group_CreateAdminGroups\Create Admin Groups_v2.ps1')
Write-Progress -Activity "Deploying Tiered Structure" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
$I++
.($basescriptPath + '\AD_Group_CreateAdminRoles\Create_All_Inclusive_Admin_Groups.ps1')
Write-Progress -Activity "Deploying Tiered Structure" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
$I++
.($basescriptPath + '\AD_Group_CreateAdminRoles\Make-SuperGroups.ps1')
Write-Progress -Activity "Deploying Tiered Structure" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
$I++
.($basescriptPath + '\AD_AssignAdminRoles\Assign_Roles.ps1')
Write-Progress -Activity "Populating Administrator Roles for Departments" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)

$I++
.($basescriptPath + '\AD_GPO_Migration\Export-Import-WMI-Filters.ps1')
Write-Progress -Activity "Deploying Tiered Structure Creating WMI filters" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
$I++
.($basescriptPath + '\AD_GPO_Migration\Call-GPOImport.ps1')
