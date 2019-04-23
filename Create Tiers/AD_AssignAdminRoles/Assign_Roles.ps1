<#
.SYNOPSIS
              
    Script to configure system settings on a newly built server


.LINK


.DESCRIPTION
    Script creates out the three roles, T1, T2 and help, for each department/center/lab.
    Adds the predefined groups to that role per in order to inforce the Tier model.

.INPUTS
    None

.OUTPUTS
    None


.NOTES
    Version:            1.0
    Creation Date:      04/09/2018
    Purpose/Change:     Initial script
    Author:             Joel Nentwich 

Script needs Roles.ini file.  This ini file defines the differnet department groups and what roles these groups should be added to.

.EXAMPLE
#>

#======================
#Global Varables
$strADDomain = (Get-ADDomain).distinguishedname
#$strADForest = (Get-ADDomain).Forest

#Update needed before script goes live
#========================================
#Directory variables of were the script is running and other needed text files
$strScriptPath =  Split-Path -Parent $PSCommandPath
$adplatformsourcedir = split-path -Path $strscriptPath -Parent
#=====================================
#3 letter affiliate codes here
$3LetterCodeCSV = $adplatformsourcedir + '\AD_OU_CreateStructure\3lettercodes.csv'


#ini files the defines what groups go into which roles
$iniFile =  $adplatformsourcedir + '\AD_AssignAdminRoles\Roles.ini'


#An array for the different schools/departments/centers that need to be processed.
$arryOrganization = Import-Csv $3LetterCodeCSV

   foreach($strOrg in $arryOrganization)
    {
        switch -Regex -File $iniFile
        #Obtained below code from Microsoft's Script Guy Blog
        #https://blogs.technet.microsoft.com/heyscriptingguy/2011/08/20/use-powershell-to-work-with-any-ini-file/
        {
            "^\[(.+)\]" # Section
            {
                
                If($_ -eq '[T1A]') 
                { 
                    $strType = 'T1' 
                    $strGroupName = $strOrg.Name + "_" + $strType + "_Administrators"
                    Write-host -ForegroundColor Green ("INFORMATION: Creating Department Security Group: " + $strGroupName)
                    New-ADGroup -Name $strGroupName -GroupCategory Security -GroupScope Global -Path "OU=T1-Roles,OU=Tier 1,OU=Admin,$strADDomain"
                }
                If($_ -eq '[T1_User]') 
                { 
                    $strType = 'T1_User' #set once for creating a group name
                    $strGroupName = $strOrg.Name + "_" + $strType + "_Administrators"
                    Write-host -ForegroundColor Green ("INFORMATION: Creating Department Security Group: " + $strGroupName)
                    New-ADGroup -Name $strGroupName -GroupCategory Security -GroupScope Global -Path "OU=T1-Roles,OU=Tier 1,OU=Admin,$strADDomain"
                    #$strType = 'T1' #reset to the tier name to add the correct group to the members of
                }
                If($_ -eq '[T1_Computer]') 
                { 
                    $strType = 'T1_Computer'
                    $strGroupName = $strOrg.Name + "_" + $strType + "_Administrators"
                    Write-host -ForegroundColor Green ("INFORMATION: Creating Department Security Group: " + $strGroupName)
                    New-ADGroup -Name $strGroupName -GroupCategory Security -GroupScope Global -Path "OU=T1-Roles,OU=Tier 1,OU=Admin,$strADDomain"
                    #$strType = 'T1'
                }
                If($_ -eq '[T1_Group]') 
                { 
                    $strType = 'T1_Group'
                    $strGroupName = $strOrg.Name + "_" + $strType + "_Administrators"
                    Write-host -ForegroundColor Green ("INFORMATION: Creating Department Security Group: " + $strGroupName)
                    New-ADGroup -Name $strGroupName -GroupCategory Security -GroupScope Global -Path "OU=T1-Roles,OU=Tier 1,OU=Admin,$strADDomain"
                    #$strType = 'T1'
                }
                If($_ -eq '[T1_OU]') 
                { 
                    $strType = 'T1_OU'
                    $strGroupName = $strOrg.Name + "_" + $strType + "_Administrators"
                    Write-host -ForegroundColor Green ("INFORMATION: Creating Department Security Group: " + $strGroupName)
                    New-ADGroup -Name $strGroupName -GroupCategory Security -GroupScope Global -Path "OU=T1-Roles,OU=Tier 1,OU=Admin,$strADDomain"
                    #$strType = 'T1'
                }
                If($_ -eq '[T1_GPO]') 
                { 
                    $strType = 'T1_GPO'
                    $strGroupName = $strOrg.Name + "_" + $strType + "_Administrators"
                    Write-host -ForegroundColor Green ("INFORMATION: Creating Department Security Group: " + $strGroupName)
                    New-ADGroup -Name $strGroupName -GroupCategory Security -GroupScope Global -Path "OU=T1-Roles,OU=Tier 1,OU=Admin,$strADDomain"
                    #$strType = 'T1'
                }
                If($_ -eq '[T1_Printer]') 
                { 
                    $strType = 'T1_Printer'
                    $strGroupName = $strOrg.Name + "_" + $strType + "_Administrators"
                    Write-host -ForegroundColor Green ("INFORMATION: Creating Department Security Group: " + $strGroupName)
                    New-ADGroup -Name $strGroupName -GroupCategory Security -GroupScope Global -Path "OU=T1-Roles,OU=Tier 1,OU=Admin,$strADDomain"
                    #$strType = 'T1'
                }
                If($_ -eq '[T2A]') 
                { 
                    $strType = 'T2'
                    $strGroupName = $strOrg.Name + "_" + $strType + "_Administrators"
                    Write-host -ForegroundColor Green ("INFORMATION: Creating Department Security Group: " + $strGroupName)
                    New-ADGroup -Name $strGroupName -GroupCategory Security -GroupScope Global -Path "OU=T2-Roles,OU=Tier 2,OU=Admin,$strADDomain"
                }
                If($_ -eq '[T2_User]') 
                { 
                    $strType = 'T2_User'
                    $strGroupName = $strOrg.Name + "_" + $strType + "_Administrators"
                    Write-host -ForegroundColor Green ("INFORMATION: Creating Department Security Group: " + $strGroupName)
                    New-ADGroup -Name $strGroupName -GroupCategory Security -GroupScope Global -Path "OU=T2-Roles,OU=Tier 2,OU=Admin,$strADDomain"
                    #$strType = 'T2'
                }
                If($_ -eq '[T2_Computer]') 
                { 
                    $strType = 'T2_Computer'
                    $strGroupName = $strOrg.Name + "_" + $strType + "_Administrators"
                    Write-host -ForegroundColor Green ("INFORMATION: Creating Department Security Group: " + $strGroupName)
                    New-ADGroup -Name $strGroupName -GroupCategory Security -GroupScope Global -Path "OU=T2-Roles,OU=Tier 2,OU=Admin,$strADDomain"
                    #$strType = 'T2'
                }
                If($_ -eq '[T2_Group]') 
                { 
                    $strType = 'T2_Group'
                    $strGroupName = $strOrg.Name + "_" + $strType + "_Administrators"
                    Write-host -ForegroundColor Green ("INFORMATION: Creating Department Security Group: " + $strGroupName)
                    New-ADGroup -Name $strGroupName -GroupCategory Security -GroupScope Global -Path "OU=T2-Roles,OU=Tier 2,OU=Admin,$strADDomain"
                    #$strType = 'T2'
                }
                If($_ -eq '[T2_OU]') 
                { 
                    $strType = 'T2_OU'
                    $strGroupName = $strOrg.Name + "_" + $strType + "_Administrators"
                    Write-host -ForegroundColor Green ("INFORMATION: Creating Department Security Group: " + $strGroupName)
                    New-ADGroup -Name $strGroupName -GroupCategory Security -GroupScope Global -Path "OU=T2-Roles,OU=Tier 2,OU=Admin,$strADDomain"
                    #$strType = 'T2'
                }
                If($_ -eq '[T2_GPO]') 
                { 
                    $strType = 'T2_GPO'
                    $strGroupName = $strOrg.Name + "_" + $strType + "_Administrators"
                    Write-host -ForegroundColor Green ("INFORMATION: Creating Department Security Group: " + $strGroupName)
                    New-ADGroup -Name $strGroupName -GroupCategory Security -GroupScope Global -Path "OU=T2-Roles,OU=Tier 2,OU=Admin,$strADDomain"
                    #$strType = 'T2'
                }
                If($_ -eq '[T2_Printer]') 
                { 
                    $strType = 'T2_Printer'
                    $strGroupName = $strOrg.Name + "_" + $strType + "_Administrators"
                    Write-host -ForegroundColor Green ("INFORMATION: Creating Department Security Group: " + $strGroupName)
                    New-ADGroup -Name $strGroupName -GroupCategory Security -GroupScope Global -Path "OU=T2-Roles,OU=Tier 2,OU=Admin,$strADDomain"
                    #$strType = 'T2'
                }
                If($_ -eq '[T2HDK]') 
                { 
                    $strType = 'T2'
                    $strGroupName = $strOrg.Name + "_" + $strType + "_HelpDesk"
                    Write-host -ForegroundColor Green ("INFORMATION: Creating Department Security Group: " + $strGroupName)
                    New-ADGroup -Name $strGroupName -GroupCategory Security -GroupScope Global -Path "OU=T2-Roles,OU=Tier 2,OU=Admin,$strADDomain"
                }
                
            }
            "^(;.*)$" # Comment
            {
                #Do nothing and just ignore.
            }
            default
            {
                
                #$strRoleName = $strOrg.Name + "_" + $strType + "_" + $_
                $strRoleName = $strOrg.Name + "_" + $_
                Add-ADGroupMember -Identity $strRoleName -Members $strGroupName
                #Add-ADGroupMember -Identity $strGroupName -Members $strRoleName #old way
                #Write-Host $_
                
            }
        }    
    }
