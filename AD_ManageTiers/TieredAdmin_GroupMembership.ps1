function Add-TierAdminToGroup{

	 <#
    .SYNOPSIS
	    Adds an administrator account to the specified group.
    .FUNCTIONALITY
        Active Directory tiered administration
    .DESCRIPTION
	    Specify a sam account of an admin and a group name.  The tools verifies the user
		can be added to the group and then adds the user into the administrator group
	
    .PARAMETER TierAdminSAM
        Samaccountname or HUID of the administrator you want to modify
    .PARAMETER Group
	    Name of the group that is in an administrative OU
	.PARAMETER Conf
	    Force an approval prior to enacting change
    .EXAMPLE
        #Add david's tier 1 account into the FIN T1 Administrator group
	    Add-TierAdminToGroup -TierAdminSAM 'David-t1' -group 'FIN_T1_Administrators'
   .EXAMPLE
        #Add Johns's tier 2 account into the FIN T2 helpdesk group, force confirmation confirm 
	    Add-TierAdminToGroup -TierAdminSAM 'John-t2' -group 'FIN_T2_Helpdesk' -conf
    
    #>	

     [CmdletBinding()] 
    Param 
    (   [Parameter(Mandatory=$true)] 
        [string]$TierAdminSAM,
        [Parameter(Mandatory=$true)] 
        [string]$Group, #FIn_T1_Administrators
        [switch]$Conf
                
    )


Begin{
    
        write-verbose -Message "using variable $TierAdminSAM"

        $ADUserCheck = $null
        try{
                write-verbose -Message "Checking for $TierAdminSAM"
                $adusercheck = Get-aduser $TierAdminSAM -Properties *
                }
            Catch{ 
                
                    if (!$adusercheck){
                    write-warning "$TierAdminSAM not found in domain. Exiting script"
                    break
                    }
            }
        

     $ADGroupCheck = $null
        try {
                Write-Verbose "Checking for GROUP $Group"
                $adgroupcheck = get-adgroup $group            
                }
        Catch{
        write-warning "$group not found in domain. Exiting Script"
        break
        }


    #BEGIN PARAMS
    #====================
    $d = (get-addomain)
    $dn = $d.distinguishedname
    $pdc = $d.PDCEmulator

    #===================
    #CHECK IF BOTH THE GROUP AND USER ARE IN THE ADMIN OU
    $usertier = ($ADUserCheck.DistinguishedName -split ",")|foreach {if($_ -like "OU=Tier*"){$_}}
    if(!$usertier){
     write-warning "$TierAdminSAM not in proper Admin ou. Exiting Script"
     write-warning $adusercheck.distinguishedname
     break
       
    }
    #Check if both the user and group are in the same TIER
    $grouptier = ($ADGroupCheck.DistinguishedName -split ",")|foreach {if($_ -like "OU=Tier*"){$_}}
    if (!$grouptier) {
     write-warning "$group not in proper Admin ou. Exiting Script"
     break
    }

    if ($usertier -ne $grouptier){
    write-warning "User and Group Not in same tier.  Exiting Script"
    break
    }
    

} 
Process{
    
    if ($Conf){Add-ADGroupMember -Identity $ADGroupCheck -Members $ADUserCheck  -Server $pdc -Confirm}
    else{Add-ADGroupMember -Identity $ADGroupCheck -Members $ADUserCheck  -Server $pdc} 

     $g = get-adgroup -Identity $adgroupcheck -Properties members
     $n = $g.name
     $ms = $g.Members
           write-verbose "$n"
           write-verbose "Members"
           foreach ($m in $ms){write-verbose "$m"}
            

}
End{}


}

Function Remove-TierAdminFromGroup{

<#
    .SYNOPSIS
	    Removes an administrator account to the specified group.
    .FUNCTIONALITY
        Active Directory tiered administration
    .DESCRIPTION
	    Specify a sam account of an admin and a group name.  Verifies the group specified is in the tiers and will remove the 
		user from the group
	
    .PARAMETER TierAdminSAM
        Samaccountname or HUID of the administrator you want to modify
    .PARAMETER Group
	    Name of the group that is in an administrative OU
	.PARAMETER Conf
	    Force an approval prior to enacting change
    .EXAMPLE
        #Remove david's tier 1 account into the FIN T1 Administrator group
	    Remove-TierAdminToGroup -TierAdminSAM 'David-t1' -group 'FIN_T1_Administrators'
   .EXAMPLE
        #Remove Johns's tier 2 account into the FIN T2 helpdesk group, force confirmation confirm 
	    Remove-TierAdminToGroup -TierAdminSAM 'John-t2' -group 'FIN_T2_Helpdesk' -conf
    
    #>	

 Param 
    (   [Parameter(Mandatory=$true)] 
        [string]$TierAdminSAM,
        [Parameter(Mandatory=$true)] 
        [string]$Group, #FIN_T1_Administrators
        [switch]$Conf
                
    )


    Begin{
    
        write-verbose -Message "using variable $TierAdminSAM"

        $ADUserCheck = $null
        try{
                write-verbose -Message "Checking for $TierAdminSAM"
                $adusercheck = Get-aduser $TierAdminSAM -Properties *
                }
            Catch{ 
                    if (!$adusercheck){
                    write-warning "$TierAdminSAM not found in domain. Exiting script"
                    break
                    }
            }
        

     $ADGroupCheck = $null
        try {
                Write-Verbose "Checking for GROUP $Group"
                $adgroupcheck = get-adgroup $group            
                }
        Catch{
        write-warning "$group not found in domain. Exiting Script"
        break
        }


    #BEGIN PARAMS
    #====================
    $d = (get-addomain)
    $dn = $d.distinguishedname
    $pdc = $d.PDCEmulator

    #===================
    
    

} 
Process{
    
    if ($Conf){Remove-ADGroupMember -Identity $ADGroupCheck -Members $ADUserCheck  -Server $pdc}
    else{Remove-ADGroupMember -Identity $ADGroupCheck -Members $ADUserCheck  -Server $pdc -confirm:$False} 

     $g = get-adgroup -Identity $adgroupcheck -Properties members
     $n = $g.name
     $ms = $g.Members
           write-verbose "$n"
           write-verbose "Remaining members"
           foreach ($m in $ms){write-verbose "$m"}
            

}
End{}

}

Function Clone-TierAdminGroups{
     
	 <#
    .SYNOPSIS
	    Copies tiered groups from an administrator account to another administrator.
    .FUNCTIONALITY
        Active Directory tiered administration
    .DESCRIPTION
	    Copies tiered groups from one user account to another.  Script will stop if there are non tiered groups added to the origin user
	
    .PARAMETER CloneToUser
        User you want the groups to be added to
    .PARAMETER CloneFromUser
	    User you want the grouips to be added from
	.PARAMETER Conf
	    Force an approval prior to enacting change
    .EXAMPLE
        #Clone all tier groups from John to David's tier group
	    Clone-TierAdminGroups -CloneToUser 'David-t2' -CloneFromUser 'John-t2'
  
    #>	
	
	 [CmdletBinding()] 
    Param 
    (   [Parameter(Mandatory=$true)] 
        [string]$CloneToUser, 
        [Parameter(Mandatory=$true)] 
        [string]$CloneFromUser, 
        [switch]$Conf
                
    )


    Begin{
    
        write-verbose -Message "using variable $CloneToUser"

        $ADCloneToCheck = $null
        try{
                write-verbose -Message "Checking for $CloneToUser"
                $ADCloneToCheck = Get-aduser $CloneToUser -Properties memberof
                }
            Catch{ write-verbose -Message "Checking for HUID"
                Try{$ADCloneToCheck = get-aduser -f{harvardEduADHUID -eq $CloneToUser} -Properties memberof} 
                    Catch{}
                    if (!$ADCloneToCheck){
                    write-warning "$CloneToUser not found in domain. Exiting script"
                    break
                    }
            }
        

     $ADCloneFromCheck = $null
         try{
                write-verbose -Message "Checking for $CloneFromUser"
                $ADCloneFromCheck = Get-aduser $CloneFromUser -Properties memberof
                }
            Catch{ write-verbose -Message "Checking for HUID"
                Try{$ADCloneFromCheck = get-aduser -f{harvardEduADHUID -eq $CloneFromUser} -Properties memberof} 
                    Catch{}
                    if (!$ADCloneFromCheck){
                    write-warning "$CloneFromUser not found in domain. Exiting script"
                    break
                    }
            }


    #BEGIN PARAMS
    #====================
    $d = (get-addomain)
    $dn = $d.distinguishedname
    $pdc = $d.PDCEmulator

    #===================
    
    $usertotier = ($ADCloneToCheck.DistinguishedName -split ",")|foreach {if($_ -like "OU=Tier*"){$_}}
    if(!$usertotier){
     write-warning "$ADCloneToCheck not in proper Admin ou. Exiting Script"
     write-warning $ADCloneToCheck.distinguishedname
     break
       
    }
    #Check if both the user and group are in the same TIER
    $userfromtier = ($ADCloneFromCheck.DistinguishedName -split ",")|foreach {if($_ -like "OU=Tier*"){$_}}
    if (!$userfromtier) {
     write-warning "$ADCloneFromCheck not in proper Admin ou. Exiting Script"
     break
    }

    #check if users are in the same tier.  If not, break script do nothing
    if ($usertotier -ne $userfromtier){
    write-warning "Users Not in same tier.  Exiting Script"
    break
    }
    

} 
Process{
    foreach ($group in $ADCloneFromCheck.memberof){
    write-host Adding $($ADCloneToCheck.samaccountname) to $group
    add-ADGroupMember -Identity $group -Members $ADCloneToCheck  -Server $pdc}
	
	Get-aduser $ADCloneToCheck -properties memberof|select distinguishedname,samaccountname,memberof|FL
    

            

}
End{}

}

function Add-TierAdmintoSubGroup {
 <#
    .SYNOPSIS
	    Automated assitant to add groups to an administrator account based on 3 letter code specified.  Assist admin by allowing them to specify subfolder and roles instead of specifying groups
    .FUNCTIONALITY
        Active Directory tiered administration
    .DESCRIPTION
	    By specifying a user and a role and 3letter code, this tool adds the proper group to the administrator.
		It figures out the correct group based on parameters
		This script requires the New-DynamicParam function to be in memory
    .PARAMETER AdminSAM
        User you want the groups to be added to
    .PARAMETER Role
	    Role for the user to be added to
	.PARAMETER SubOU
	    3 letter code for the administrator to admin
    .EXAMPLE
        #Add david's tier 1 computer administrator group that manages computer objects on Tier 1\FIN\Devices
	    Add-tieradmintogroupAuto -AdminSAM 'david-t1' -role 'Computer' -SubOU FIN
  
    #>	

[CmdletBinding()] 
    Param 
    (   [Parameter(Mandatory=$true)] 
        [string]$AdminSAM,
        [Parameter(Mandatory=$true)] 
        [ValidateSet('Admin','Computer','Group','User','Printer','OU','GPO')]
        [string]$Role, # do not add user to any groups if tier 1 or tier 2 admin
        # story for user already exists and add them to group
        [Parameter(Mandatory=$true)] 
        [string]$SubOU

         
    )



    Begin{
    write-host "sure"
    
        write-verbose -Message "using variable $AdminSAM"

        $ADUserCheck = $null
        try{
                write-verbose -Message "Checking for $AdminSAM"
                $adusercheck = Get-aduser $AdminSAM -Properties *
                }
            Catch{ 
                    if (!$adusercheck){
                    write-warning "$AdminSAM not found in domain. Exiting script"
                    break
                    }
            }
       #Check if both the user and group are in the same TIER
    #use variables to set group name AAD_T1_GPO_Administrators
   

    #BEGIN PARAMS
    #====================
    $d = (get-addomain)
    $dn = $d.distinguishedname
    $pdc = $d.PDCEmulator

    #===================
    #CHECK IF BOTH THE GROUP AND USER ARE IN THE ADMIN OU
    $usertier = ($ADUserCheck.DistinguishedName -split ",")|foreach {if($_ -like "OU=Tier*"){$_}}
    $usertier = ($usertier -split " ")[1]
    if(!$usertier){
     write-warning "$AdminSAM not in proper Admin ou. Exiting Script"
     write-warning $adusercheck.distinguishedname
     break
       
    }
    #Check if both the user and group are in the same TIER
    #use variables to set group name FIN_T1_GPO_Administrators
      $ADGroupCheck = $null
        try {
                Write-host "Checking for GROUP $subou`_T$usertier`_$role`_Administrators"

                if($role -eq "Admin"){
                $adgroupcheck = get-adgroup $subou`_T$usertier`_Administrators
                }
                else{
                $adgroupcheck = get-adgroup $subou`_T$usertier`_$role`_Administrators           
                }
                }
        Catch{
        write-warning "$subou`_T$usertier`_$role`_Administrators not found in domain. Exiting Script"
        break
        }

   
    

} 
Process{
    
    Add-ADGroupMember -Identity $ADGroupCheck -Members $ADUserCheck  -Server $pdc

     $g = get-adgroup -Identity $adgroupcheck -Properties members
     $n = $g.name
     $ms = $g.Members
           write-verbose "$n"
           write-verbose "Members"
           foreach ($m in $ms){write-verbose "$m"}
            

}
End{}


}