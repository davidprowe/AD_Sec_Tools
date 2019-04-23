#Initialize common variables
$OUSearch=$null
$searchBase=$null
$OUNames = $null
$GPOName = $null

#Dynamic variables
$date = Get-Date -Format yyyy-MM-dd_HH_mm
$domain = Get-ADDomain
$forest = ($domain).Forest.Split('.')
$PDC = ($domain).PDCEmulator
#Build OU search path for domain
for ($i = 0;$i -lt $forest.count; $i++)
{
    $OUSearch+= ",DC=" + $forest[$i]
}

#Defined variables
$logPath = "C:\Logs\$date-Create-Delegated-OU-Controls.log"
$Tiers = ("Tier 1","Tier 2")
#AdminGroups are AD Group name suffixes to add to Restricted Groups thereby adding members to local administrators on devices in the linked OU
#Scripted loop assumes Admin Groups are prefixed with: 'OU_T#_' where # is a Tier 1 OR 2
$adminGroups = ("_Administrators","_Computer_Administrators") 


### Used Funcitons #################################
function Pause
{
   Read-Host 'Press Enter to continue…' | Out-Null
}

function Write-Log 
{ 
    [CmdletBinding()] 
    Param 
    ( 
        [Parameter(Mandatory=$true, 
                   ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [Alias("LogContent")] 
        [string]$Message, 
 
        [Parameter(Mandatory=$false)] 
        [Alias('LogPath')] 
        [string]$Path="C:\Logs\Script.log", 
         
        [Parameter(Mandatory=$false)] 
        [ValidateSet("Error","Warn","Info")] 
        [string]$Level="Info", 
         
        [Parameter(Mandatory=$false)] 
        [switch]$NoClobber 
    ) 
 
    Begin 
    { 
        # Set VerbosePreference to Continue so that verbose messages are displayed. 
        $VerbosePreference = 'Continue' 
    } 
    Process 
    { 
         
        # If the file already exists and NoClobber was specified, do not write to the log. 
        if ((Test-Path $Path) -AND $NoClobber) { 
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name." 
            Return 
            } 
 
        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path. 
        elseif (!(Test-Path $Path)) { 
            Write-Verbose "Creating $Path." 
            $NewLogFile = New-Item $Path -Force -ItemType File 
            } 
 
        else { 
            # Nothing to see here yet. 
            } 
 
        # Format Date for our Log File 
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
 
        # Write message to error, warning, or verbose pipeline and specify $LevelText 
        switch ($Level) { 
            'Error' { 
                Write-Error $Message 
                $LevelText = 'ERROR:' 
                } 
            'Warn' { 
                Write-Warning $Message 
                $LevelText = 'WARNING:' 
                } 
            'Info' { 
                Write-Verbose $Message 
                $LevelText = 'INFO:' 
                } 
            } 
         
        # Write log entry to $Path 
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append 
    } 
    End 
    { 
    } 
}
### End Used Funcitons #################################

Write-Log -Path $logPath -Message "$date`_Delegated-OU-Control.log" -Level Info
### Begin Script #######################################

if (!(Get-Gpo -name "_Delegated-Control-Template")){
Write-Log -Path $logPath -Message "SCRIPT STOP - NO _Delegated-Control-Template GPO FOUND Please create template GPO and run again" -Level Error
break}

#Tier iteration logic
foreach ($Tier in $Tiers)
{
    $n = 1
    Write-Log -Path $logPath -Message "Targeting Tiers" -Level Info      
    #Generate searchbase
    $searchBase = "OU=" + $tier + $OUSearch
    #Get OUs in searchbase
    $OUNames = Get-ADOrganizationalUnit -Filter * -SearchBase $searchBase -SearchScope OneLevel | Select-Object -ExpandProperty Name
    $count = $ounames.Count
    #OU iteration logic
    foreach ($OUName in $OUNames)
    {
        $newGPO = 0

        Write-Progress -Activity "Targeting Tiers" -Status "OU $n of $count" -PercentComplete (($n / $count) * 100)
        Write-Log -Path $logPath -Message "Targeting: $OUName" -Level Info      
        $SIDS =@()
        #Create a new GPO for each OU
        $GPOName = "ENT-"+$OUName+"-"+$Tier+" Devices"
        if (!(Get-GPO -Name $GPOName -ErrorAction SilentlyContinue)){
            Write-Log -Path $logPath -Message "Creating NEW GPO: $GPOName" -Level Info      
            Copy-GPO -SourceName "_Delegated-Control-Template" -TargetName $GPOName -SourceDomainController $PDC -TargetDomainController $PDC
            Get-GPO -Name $GPOName -Server $PDC | New-GPLink -Target ("OU="+$OUName+","+$searchBase) -LinkEnabled Yes -Enforced Yes -Server $PDC
            $newGPO = 1
        }
        
        $GPOS = Get-GPO -Name $GPOName -Server $PDC
        if ($GPOS.GpoStatus -ne "UserSettingsDisabled"){
            Write-Log -Path $logPath -Message "Changing GPO Status (disable user settings) on: $GPOName" -Level Info      
            $GPOS.gpostatus = "UserSettingsDisabled"
        }
        
        
        if ($newGPO -eq 1){
            $tierShort = $tier[0] + $tier[$tier.Length-1]
            #Get SIDS for groups
            foreach ($adminGroup in $adminGroups)
            {
                $OUAdminName = $OUName +"_"+ $tierShort + $adminGroup
                $objGroup = New-Object System.Security.Principal.NTAccount((Get-ADDomain).domain,$OUAdminName)
                $strSID = $objGroup.Translate([System.Security.Principal.SecurityIdentifier]).value
                $SIDS += $strSID
                Write-Log -Path $logPath -Message "Found Group/SID mapping: $OuAdminName : $strSID" -Level Info
            }

        
            #Restricted Groups Template
            $gptTemplateINF = "[Unicode]
Unicode=yes
[Version]
signature=`"`$CHICAGO$`"
Revision=1
[Group Membership]
*$($SIDS[0])__Memberof = *S-1-5-32-544
*$($SIDS[0])__Members =
*$($SIDS[1])__Memberof = *S-1-5-32-544
*$($SIDS[1])__Members ="
        
            #Versioned INI file template
            $gptiniFile ="[General]
Version=1"
            
        
        
            #Build SYSVOL GPO Paths from new GPO 
            do 
            {
                Write-Log -Path $logPath -Message "Searching for GPO Path..." -Level Info
                $GPOSecEditpath = Join-Path -Path $((New-Object adsisearcher([adsi]"LDAP://$PDC/CN=Policies,CN=System,$(([adsi]"LDAP://RootDSE").rootDomainNamingContext)","(displayname=$GPOName)")).findone().properties.gpcfilesyspath) -ChildPath 'Machine\Microsoft\Windows NT\SecEdit' -ErrorAction SilentlyContinue
                $RootGPOpath = $GPOSecEditpath.TrimEnd('Machine\Microsoft\Windows NT\SecEdit')
                start-sleep 1
            }
            until (Test-Path $RootGPOpath)

            Write-Log -Path $logPath -Message "GPO Path Found" -Level Info
            #Test for and backup prior GptTmpl.inf
            #if (Test-Path "$GPOSecEditpath\GptTmpl.inf"){
            #    Write-Log -Path $logPath -Message "Backing up OLD GptTmpl.inf to: $GPOSecEditpath\$date`-GptTmpl.bak" -Level Info
            #    Copy-Item "$GPOSecEditpath\GptTmpl.inf" -Destination "$GPOSecEditpath\$date`-GptTmpl.bak"
            #}
        
            #Create GPO Folder structures
            If (!(test-path $GPOSecEditpath)){
                Write-Log -Path $logPath -Message "Creating GPO Folder Structures: $GPOSecEditpath" -Level Info
                New-Item  $GPOSecEditpath -Force -ItemType Directory |Out-Null
            }
        
            #Write out Restricted groups file
            Write-Log -Path $logPath -Message "Writing Restricted Groups GptTmpl.inf to: $GPOSecEditpath\GptTmpl.inf" -Level Info
            $gptTemplateINF | Out-File "$GPOSecEditpath\GptTmpl.inf" -Force
            #Write out updated version gpt.ini indicating update for sysvol
            Write-Log -Path $logPath -Message "Writing GPO root .INI to: $RootGPOpath\gpt.ini"
            #$gptiniFile | Out-File "$RootGPOpath\gpt.ini"
            $n++
        }else{Write-Log -Path $logPath -Message "GPO: $GPOName EXISTS" -Level Warn;$n++} 
        
        #Pause used in development to stop between loops
        #Pause
    }
}