function Get-ScriptDirectory {
    Split-Path -Parent $PSCommandPath
}
$scriptPath = Get-ScriptDirectory
$adplatformsourcedir = split-path -Path $scriptPath -Parent
import-module ($scriptPath+'.\gpomigration\gpomigration.psm1') -force

Function Restore-GroupPolicy($backupID, $path)
{
#       
#      .DESCRIPTION  
#         Restore group policies
#  
    $error.clear()
    $configXML = [xml](Get-Content ($SettingsFile))           
    $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
    $gpoPath = Join-Path $path -ChildPath "GPO"
    $manifestPath = Join-Path $gpoPath -ChildPath "manifest.xml"
	$manifestXML = [xml](Get-Content $manifestPath)  
    Foreach ($gpoName in $configXML.Configuration.GroupPolicies.Policy)
    {   
        $backupGuid = $manifestXML.Backups.BackupInst | where {$_.GPODisplayName."#cdata-section" -eq $gpoName.Name}       
        #If the GPO exists and Overwriting is enabled, or the GPO does not exist, import the GPO
        If(((Get-GPO -Name $gpoName.Name -ErrorAction SilentlyContinue) -and ($OverwriteExistingPolicies -eq $True)) -or (!(Get-GPO -name $gpoName.name -ErrorAction SilentlyContinue)))
        {
            $error.clear()   
        
            #Check for migration table, and run appropriate command
            If($migrationTable)
            {       
                try
                {                    
                    $MigTablePath= Join-Path $BackupFolder -ChildPath $MigrationTable
                    $MigFile = [System.IO.Path]::GetFileNameWithoutExtension($MigTablePath)
                    $newmt = $MigFile + "." + $domain + ".migtable"
                    $migTable = Join-Path $BackupFolder -ChildPath $newmt
                    Import-GPO -BackupGpoName ($backupGuid.GPODisplayName."#cdata-section") -TargetName $gpoName.Name -Path $gpoPath -MigrationTable $migTable -CreateIfNeeded | Out-Null
                }
                Catch
                {        
                    Write-Host -ForegroundColor Red ("ERROR: Unable to import the policy " + ($backupGuid.GPODisplayName."#cdata-section"))
                    If($error -match "The data is invalid")
                    {Write-Host -ForegroundColor Red ("ERROR: The data in the migration table is invalid. The policy has been created, but the settings have not been imported.")}               
                }
            }
            Else
            {
                try
                {
                    Import-GPO -BackupGpoName ($backupGuid.GPODisplayName."#cdata-section") -TargetName $gpoName.Name -Path $gpoPath -CreateIfNeeded | Out-Null
                }
                Catch
                {        
                    Write-Host -ForegroundColor Red ("ERROR: Unable to import the policy " + ($backupGuid.GPODisplayName."#cdata-section"))
                }
            }

            If(!$Error)
            {       
                 Write-Host -ForegroundColor Green ("INFORMATION: Restored the policy " + ($backupGuid.GPODisplayName."#cdata-section"))
                 If($gpoName.Permissions)
                 {
                    #Set permissions if defined
                    Foreach($group in $gpoName.Permissions)
                    {
                        If((Get-Group -groupName $group) -eq $True)
                        {
                            Set-GPOApplyPermissions -groupName $group -name $gpoName.Name
                        }
                    }
                 }
                 
            }
        }
        #If the GPO does exist and overwriting is disabled, continue without importing
        ElseIf((Get-GPO -Name $gpoName.Name) -and ($OverwriteExistingPolicies -eq $false))
        {
            Write-Host -ForegroundColor DarkGray ("INFORMATION: The Group Policy " + $gpoName.name + " already exists and the option to overwrite existing policies has not been specified. The policy will not be imported")
        }
    }

    #WMIFilter
    Set-GPWMIFilterFromBackup -BackupPath $gpoPath
}
