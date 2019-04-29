Function New-TierAdminUser{
    
	<#
    .SYNOPSIS
	    Creates a new administrator in the tiered environment.  Adds them to their affiliatecode admin group.
    .FUNCTIONALITY
        Active Directory tiered administration
    .DESCRIPTION
	    Specify a sam account a source user to create an administrator account for.  The tools verifies the user
		can be added to the group and then adds the user into the administrator group
    .PARAMETER SourceAcct
        MANDATORY: Samaccountname of the administrator you want to create an admin account for
    .PARAMETER Tier
	    MANDATORY: Tier # that the admin account will be created for
    .EXAMPLE
        new-tieradminuser -SourceAcct man555 -tier 1  
		Creates a new tiered administrator user for man555-t1 .  Admin account location is Root\Admin\Tier 1\T1-Accounts
   .EXAMPLE
       new-tieradminuser -SourceAcct man555 -tier 2
	   Creates a new tiered administrator user for man555-t2.  Admin account location is Root\Admin\Tier 2\T2-Accounts
    
    #>	
	
	[CmdletBinding()] 
    Param 
    (   [Parameter(Mandatory=$true)] 
        [string]$SourceAcct,
        [Parameter(Mandatory=$true)]
        [ValidateSet('2','1','0')] 
        [int]$Tier

         
    )
   


Begin{
    
        write-verbose -Message "using variable $SourceAcct"

     $ADUserCheck = $null
        try{
                write-verbose -Message "Checking for SAMACCOUNTNAME"
                $adusercheck = Get-aduser $SourceAcct -Properties *
                }
            Catch{ 
                    if (!$adusercheck){
                    write-warning "$SourceAcct not found in domain. Exiting script"
                    break
                    }
            }



    #BEGIN PARAMS
    #====================
    $d = (get-addomain)
    $dn = $d.distinguishedname
    $pdc = $d.PDCEmulator

    #===================
    $tierOU = 'OU=T'+$tier +'-Accounts,OU=Tier '+$tier +',OU=Admin,'+ $dn
    
    #Begin Functions Used ##############################################
    function New-SWRandomPassword {
        <#
        .Synopsis
           Generates one or more complex passwords designed to fulfill the requirements for Active Directory
        .DESCRIPTION
           Generates one or more complex passwords designed to fulfill the requirements for Active Directory
        .EXAMPLE
           New-SWRandomPassword
           C&3SX6Kn
    
           Will generate one password with a length between 8  and 12 chars.
        .EXAMPLE
           New-SWRandomPassword -MinPasswordLength 8 -MaxPasswordLength 12 -Count 4
           7d&5cnaB
           !Bh776T"Fw
           9"C"RxKcY
           %mtM7#9LQ9h
    
           Will generate four passwords, each with a length of between 8 and 12 chars.
        .EXAMPLE
           New-SWRandomPassword -InputStrings abc, ABC, 123 -PasswordLength 4
           3ABa
    
           Generates a password with a length of 4 containing atleast one char from each InputString
        .EXAMPLE
           New-SWRandomPassword -InputStrings abc, ABC, 123 -PasswordLength 4 -FirstChar abcdefghijkmnpqrstuvwxyzABCEFGHJKLMNPQRSTUVWXYZ
           3ABa
    
           Generates a password with a length of 4 containing atleast one char from each InputString that will start with a letter from 
           the string specified with the parameter FirstChar
        .OUTPUTS
           [String]
        .NOTES
           Written by Simon WÃ¥hlin, blog.simonw.se
           I take no responsibility for any issues caused by this script.
        .FUNCTIONALITY
           Generates random passwords
        .LINK
           http://blog.simonw.se/powershell-generating-random-password-for-active-directory/
       
        #>
        [CmdletBinding(DefaultParameterSetName='FixedLength',ConfirmImpact='None')]
        [OutputType([String])]
        Param
        (
            # Specifies minimum password length
            [Parameter(Mandatory=$false,
                       ParameterSetName='RandomLength')]
            [ValidateScript({$_ -gt 0})]
            [Alias('Min')] 
            [int]$MinPasswordLength = 12,
            
            # Specifies maximum password length
            [Parameter(Mandatory=$false,
                       ParameterSetName='RandomLength')]
            [ValidateScript({
                    if($_ -ge $MinPasswordLength){$true}
                    else{Throw 'Max value cannot be lesser than min value.'}})]
            [Alias('Max')]
            [int]$MaxPasswordLength = 20,
    
            # Specifies a fixed password length
            [Parameter(Mandatory=$false,
                       ParameterSetName='FixedLength')]
            [ValidateRange(1,2147483647)]
            [int]$PasswordLength = 8,
            
            # Specifies an array of strings containing charactergroups from which the password will be generated.
            # At least one char from each group (string) will be used.
            [String[]]$InputStrings = @('abcdefghijkmnpqrstuvwxyz', 'ABCEFGHJKLMNPQRSTUVWXYZ', '23456789', '!#%&'),
    
            # Specifies a string containing a character group from which the first character in the password will be generated.
            # Useful for systems which requires first char in password to be alphabetic.
            [String] $FirstChar,
            
            # Specifies number of passwords to generate.
            [ValidateRange(1,2147483647)]
            [int]$Count = 1
        )
        Begin {
            Function Get-Seed{
                # Generate a seed for randomization
                $RandomBytes = New-Object -TypeName 'System.Byte[]' 4
                $Random = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider'
                $Random.GetBytes($RandomBytes)
                [BitConverter]::ToUInt32($RandomBytes, 0)
            }
        }
        Process {
            For($iteration = 1;$iteration -le $Count; $iteration++){
                $Password = @{}
                # Create char arrays containing groups of possible chars
                [char[][]]$CharGroups = $InputStrings
    
                # Create char array containing all chars
                $AllChars = $CharGroups | ForEach-Object {[Char[]]$_}
    
                # Set password length
                if($PSCmdlet.ParameterSetName -eq 'RandomLength')
                {
                    if($MinPasswordLength -eq $MaxPasswordLength) {
                        # If password length is set, use set length
                        $PasswordLength = $MinPasswordLength
                    }
                    else {
                        # Otherwise randomize password length
                        $PasswordLength = ((Get-Seed) % ($MaxPasswordLength + 1 - $MinPasswordLength)) + $MinPasswordLength
                    }
                }
    
                # If FirstChar is defined, randomize first char in password from that string.
                if($PSBoundParameters.ContainsKey('FirstChar')){
                    $Password.Add(0,$FirstChar[((Get-Seed) % $FirstChar.Length)])
                }
                # Randomize one char from each group
                Foreach($Group in $CharGroups) {
                    if($Password.Count -lt $PasswordLength) {
                        $Index = Get-Seed
                        While ($Password.ContainsKey($Index)){
                            $Index = Get-Seed                        
                        }
                        $Password.Add($Index,$Group[((Get-Seed) % $Group.Count)])
                    }
                }
    
                # Fill out with chars from $AllChars
                for($i=$Password.Count;$i -lt $PasswordLength;$i++) {
                    $Index = Get-Seed
                    While ($Password.ContainsKey($Index)){
                        $Index = Get-Seed                        
                    }
                    $Password.Add($Index,$AllChars[((Get-Seed) % $AllChars.Count)])
                }
                Write-Output -InputObject $(-join ($Password.GetEnumerator() | Sort-Object -Property Name | Select-Object -ExpandProperty Value))
            }
        }
    }
    
    #End Functions Used ##############################################
     
     
            $pwd = (New-SWRandomPassword -MinPasswordLength 18 -MaxPasswordLength 20)
 
            $AdminGivenName = $adusercheck.givenname
            $adminsurname = $adusercheck.surname
            $adminsam = $adusercheck.SamAccountName


}     
Process{

           

        #========================
        #  If tier 0 specified, no need to do the Sub ou Check, or the tier 1 and tier 2 things
        #  Grant only to the admin OU and the appropriate group
        #========================

        if ($tier -eq 0){
             try{
            new-aduser -Description $("Tier "+ $tier +" Admin") -DisplayName ($AdminGivenName +" " + $adminsurname) -name ($adminsam +"_T"+ $tier +"_Admin") -SamAccountName ($adminsam +"-T" +$tier) -Surname $adminSurname -GivenName $AdminGivenName -Enabled $true -Path $tierOU -UserPrincipalName ($adminsam+"_T"+$tier+"_Admin@" + $dn) -AccountPassword (ConvertTo-SecureString ($pwd) -AsPlainText -force) -AccountNotDelegated $false -AllowReversiblePasswordEncryption $false -CannotChangePassword $false -PasswordNeverExpires $false -PasswordNotRequired $false -SmartcardLogonRequired $false -TrustedForDelegation $false -Server $pdc -Department $ADUserCheck.Department -OtherAttributes @{'mail'=$ADUserCheck.mail}
            write-host "User created successfully"
            write-host "$adminsam-T$tier"
            write-host "Current pwd: $pwd"
            Write-host "User is not added to any groups" -ForegroundColor Green

            }

            catch{
                    Write-Warning "Unable to create user for $SourceAcct in tier $tier"
                    $error[0]
                     if ($Error[0].Exception.message -eq "The specified account already exists"){
                            get-aduser ($adminsam +"-T" +$tier)
                            }
                    }

        
        }
                
                
        else{ 
            #=================================
            # IF no sub ou specified, grant permissions to user on the top level OU under the appropriate tier
            #==================================
            
            try{
            new-aduser -Description $("Tier "+ $tier +" Admin") -DisplayName ($AdminGivenName +" " + $adminsurname) -name ($adminsam +"_T"+ $tier +"_Admin") -SamAccountName ($adminsam +"-T" +$tier) -Surname $adminSurname -GivenName $AdminGivenName -Enabled $true -Path $tierOU -UserPrincipalName ($adminsam+"_T"+$tier+"_Admin@" + $dn) -AccountPassword (ConvertTo-SecureString ($pwd) -AsPlainText -force) -AccountNotDelegated $false -AllowReversiblePasswordEncryption $false -CannotChangePassword $false -PasswordNeverExpires $false -PasswordNotRequired $false -SmartcardLogonRequired $false -TrustedForDelegation $false -Server $pdc -Department $ADUserCheck.Department -OtherAttributes @{'mail'=$ADUserCheck.mail}
            
            write-host "User created successfully"
            write-host "$adminsam-T$tier"
            write-host "Current pwd: $pwd"

            
            #ABC_T1_Administrators, ABC_T1_Computer_Administrators
            }
            catch{
                    Write-Warning "Error Action for $SourceAcct in tier $tier"
                    $error[0]
                        if ($Error[0].Exception.message -eq "The specified account already exists"){
                            get-aduser ($adminsam +"-T" +$tier)
                            }
                    }

        
            
            
            
        }
       

}
End{}

}
