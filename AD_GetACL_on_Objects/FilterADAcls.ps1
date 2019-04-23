Function Filter-ADAcls {
    [CmdletBinding()] 
    Param 
    (   [Parameter(Mandatory=$true)] 
        [string]$ACLReport, # $ACLReport = 'C:\Reports\adOU_permissions_2019-02-28T10_59_10.csv'
        [Parameter(Mandatory=$true)] 
        [string]$ACLMapping, # $ACLMapping = 'C:\Users\xxx\Documents\GitHub\ad-operations\AD_GetACL_on_Objects\ACLMapToAction.csv'
        [string]$outputfile #$outputfile = 'C:\reports\ACLTest.csv'
                
    )



    Begin{

        

        if(!$outputfile){
        $logpostfix = (Get-Date -Format s).Replace(":","_")
        $logsuffix = ".csv"
        $filename = 'ADACL_SHADOWADMINS_' + $logpostfix + $logsuffix

        $outputfile = 'c:\reports\'+$filename
        }

        $logdir = split-path -Path $outputfile -Parent
        if((Test-Path $logdir) -eq 0)
            {
            mkdir $logdir
            }
            $logfile    = Join-Path $logdir ($logfilename)
            write-host "File will be saved at $logfile"


        if((Test-path $ACLReport) -eq 0)
            {write-host "$ACLReport not found. Existing Script"
            break
            }
            

        if((Test-path $ACLMapping) -eq 0)
            {write-host "$ACLMapping not found. Existing Script"
            break
            }
    
    
    
    $ACLReport = import-csv $ACLReport
    $ACLMapping = import-csv $ACLMapping
    
    #creation of file
    if ((test-path $outputfile) -eq 1) {write-warning "$outputfile exists. Any new info will be appended to the current file"}
    else {New-Item $outputfile -ItemType File
    Add-Content $outputfile "Object,Action,WhoCanPerformIt,SourceOfPermission, SourceObjectType, SourceInheritedObjectType"
    }


    }

    $ct = $aclmapping.count 
    $i = 1
    Process{
    
        foreach ( $permissionset in $ACLMapping){
        Write-Progress -Activity "Filtering in progress" -Status "$I of $ct Complete" -PercentComplete ($i / $ct * 100)

        #object maps to objecttypename in aclreport
        $adrightsstring = "*"+$permissionset.ActiveDirectoryRights+"*"
        $permissionsetrights = $aclreport|where-object -Property objecttypename -eq $permissionset.'Object Type'|where-object -Property inheritedobjecttypename -eq $permissionset.inheritedObjectTypeName|where-object -Property ActiveDirectoryRights -like $adrightsstring|where-object -Property AccessControlType -eq "Allow"
        
        foreach ($p in $permissionsetrights){
            $object = new-object psobject
            $object |Add-member noteproperty Object $permissionset.Object
            $object |Add-member noteproperty Action $permissionset.'Allowed Action'
            $object |Add-member noteproperty WhoCanPerformIt $p.identityreference
            $object | Add-member noteproperty SourceOfPermission $p.organizationalUnit
            $object | add-member noteproperty SourceObjectType $P.objectTypeName
            $object |Add-member noteproperty SourceInheritedObjectType $p.inheritedObjectTypeName

            $o = $permissionset.Object
            $A = $permissionset.'Allowed Action'
            $who = $p.identityreference
            $src = $p.organizationalUnit
            #$report | Export-Csv -Path $logfile -append
            $object| export-csv -Path $outputfile -append
            

        }
         
         $I++
        
        }

    
    }
}