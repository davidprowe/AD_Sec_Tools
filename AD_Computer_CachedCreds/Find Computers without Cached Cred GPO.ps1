ImportSystemModules

$ErrorActionPreference = "silentlycontinue"
$WarningPreference = "silentlyContinue"

$date = ( get-date ).ToString('MM/dd/yyyy')

$GPOS = Get-GPO -All
$GPOS = $gpos |sort -Property displayname
<#
    Get guid of a gpo, set it to your test $g
    $search = 'SPH - Desktop Test'
    $i = 0
    foreach($g in $GPOS){if($g.DisplayName -eq $search){write-host "$search id equals $($g.id) `n I value $i"
    $z = $i
    }$i++}
    $g = $gpos[$z]
#>
$i = 0
$cached = @()
$cachedname = @()
$cachedsetting = @()
<#The following gets all the GPOs on the domain that have cached credential policies applied to them.#>
foreach ($g in $GPOS){
 write-progress -activity "Checking all GPOS for cached creds" -PercentComplete ($i/$gpos.count*100)
    
    $report = Get-GPOReport -Guid $g.Id -ReportType xml
    #Get-GPOReport -Guid $g.Id -ReportType html
    
    [xml]$report = $report
    #report on settings such as cached logons
    $c = $null
	$c = ($report.GPO.Computer.ExtensionData.extension.securityoptions.KeyName) -like "*cachedlogons*"
	if ($c){
	write-host $g.DisplayName -nonewline
    write-host "`t`tcached logons set to `t`t" -NoNewline
    <#
    $g = get-gpo -Guid '6FF900A7-AAAA-48C2-EEEE-525252523F73'
    $report = Get-GPOReport -Guid $g.Id -ReportType xml
    [xml]$report = $report
    ($report.GPO.Computer.ExtensionData.extension.securityoptions|Where-Object -Property keyname -EQ 'MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\CachedLogonsCount').settingstring
    #>
    write-host ($report.GPO.Computer.ExtensionData.extension.securityoptions|Where-Object -Property keyname -EQ 'MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\CachedLogonsCount').settingstring -ForegroundColor Green
    $cached += $g.id
	$cachedname += $g.DisplayName
    $cachedsetting += ($report.GPO.Computer.ExtensionData.extension.securityoptions|Where-Object -Property keyname -EQ 'MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\CachedLogonsCount').settingstring 
	#$report.GPO.Computer.ExtensionData.extension.securityoptions|Where-Object -Property keyname -EQ 'MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\CachedLogonsCount'
	}

    else{}
        $I++
    }

#list GPOs and their cached settings
<#
$i=0
foreach ($c  in $cachedname){
$cs = $cachedsetting[$i]
write-host "$c cached setting equals $cs"
$I++
}   
#>


$blocked = @()
$DN = (Get-ADDomain).distinguishedname
#univ cached creds
#$CachedCredsGPOs = @('{7E92C3F9-34DB-4386-8654-373B3A28DA54}','{744E6023-0244-42A1-8824-165D13BCAD1D}','{9AA7B9C5-7252-47E4-98E2-45BD6D222969}','{985A39B5-05E8-4CA1-BEF9-0484AB9CEBF0}')
#fas cached creds
#$CachedCredsGPOs = @('{656FEBD7-4BCF-42CD-AD29-99B825CE21D5}','{4FDACAA6-6E99-47E7-9324-064031E02AAE}','{9DB04A63-FE55-4415-918D-C8C4AF14A326}','{F697892C-5E34-4ED2-9096-F83C9ACAA06C}')
$ous = Get-ADOrganizationalUnit -Filter *
$i = 0
foreach ($OU IN $ous){
write-progress -activity "Checking all OUS for Blocked Inheritance" -PercentComplete ($i/$ous.count*100)
$I++
$a = Get-GPInheritance -Target $ou
    if ($a.GpoInheritanceBlocked -eq $true){
    $blocked += $ou
    }
}
$blockedcount= $blocked.count
#$Blocked now shows ous with Inheritance disabled

<#
Attempt a workflow
Workflow GetOUBlockedInheritance {
param(
[string[]]$AllOUs
)
Import-Module activedirectory
foreach -parallel ($OU IN $ous){
$a = Get-GPInheritance -Target $ou
    if ($a.GpoInheritanceBlocked -eq $true){
    $blocked += $ou
    }
}

}
#>


#end attempted workflow
$ousMissingGPOs = @()
$i= 0
foreach ($b in $blocked){
write-progress -activity "Checking all Blocked Inheritance OUs for cached credential policy" -PercentComplete ($i/$blocked.count*100)
$I++

$b.DistinguishedName
$z = 0
    foreach ($c in $cached){
        if ($c -eq $false){}
        else{
       #write-host c does not equal false
        
        $gpo = "cn={"+$c + '},cn=policies,cn=system,'+$dn
        
        if (($b.linkedgrouppolicyobjects) -contains $gpo){
        write-host $b.distinguishedname contains $gpo -ForegroundColor Green
        $z++
        }
        else {write-host $b.distinguishedname does not contains $gpo -ForegroundColor red
        
                if ($z -eq 4){
                $noCachedSettings += $b 
        
                }
        }
        
        }
        
}
if($z -eq 0){$ousMissingGPOs += $B.DistinguishedName}
else{}
}

write-host "`n"
write-host "`n"
write-host The following OUS are missing cached credential policies and have inheritance disabled
write-host "`n"

$ousMissingGPOs
$ousMissingGPOscount = $ousMissingGPOs.count
# $ousMissingGPOs now equals OUs with inheritance disabled and no cached credentials added to the OU

$ouswithcomps = @()
$i = 0
foreach ($ou in $ousMissingGPOs){
write-progress -activity "Checking all OUs missing GPOs for computers" -PercentComplete ($i/$ousMissingGPOs.count*100)
$I++
$count = Get-ADComputer -SearchBase $ou -f *
if ($count.Count -ge 1){
$ouswithcomps += $ou
}
else {}

}
write-host "`n"
write-host "`n"
write-host The following OUs have computers with no cached credential policies
write-host "`n"

$ouswithcomps
$ouswithcompscount = $ouswithcomps.count
# $ouswithcomps now equals OUs that have computers that have no cached credential policies

function writecachedgpos{
$i=0
$a = @()
foreach ($c  in $cachedname){
$cs = $cachedsetting[$i]
$a += "$c cached setting equals $cs <br>"
$I++
}
$a 
}
$cgpos = writecachedgpos

function ousMissingGPOs{
$a = @()
foreach ($o in $ousMissingGPOs){
$a += "$o <br>"
}
$a

}
$ousMissingGPOsHTML = ousMissingGPOs

function OUsWithComps {

$a = @()
foreach ($o in $ouswithcomps){
$a += "$o <br>"
}
$a
}
$ouswithcompsHTML = OUsWithComps

Function SendMail
{

$BodyStyle = "<style>"

$BodyStyle = $BodyStyle + "BODY{font-family:Calibri; background-color:White;}"

$BodyStyle = $BodyStyle + "TABLE{border-width: 1px;border-style: solid;
border-color: black;border-collapse: collapse;}"

$BodyStyle = $BodyStyle + "TH{border-width: 1px;padding: 0px;
border-style: solid;border-color: black;background-color:White}"

$BodyStyle = $BodyStyle + "TD{border-width: 1px;padding: 0px;
border-style: solid;border-color: black;background-color:White}"

$BodyStyle = $BodyStyle + "</style>"


$Body1 = "<br><b>GPOs with cached credentials and # of cached stored</b></td><br>"
$body2 = $cgpos 
$Body3 = "<br><b>OUs with Blocked inheritance: $blockedcount</b></td><br>"
$Body4 = $blocked | select distinguishedname | ConvertTo-Html -Head $BodyStyle
$Body5 = "<br><b>OUs missing cached credential policies: $ousMissingGPOscount</b></td><br>"
$Body6 = $ousMissingGPOsHTML
$Body7 = "<br><b>OUs missing the cached crential policies that contain computers: $ouswithcompscount</b></td><br>"
$Body8 = $ouswithcompsHTML 


$Msg = new-object system.net.mail.MailMessage

$msg.IsBodyHtml = $True
$msg.Body =  $Body7 + $Body8 + $Body1 + $Body2 + $Body3 + $Body4 + $body5 + $Body6 
$msg.Subject = "OUs with blocked inheritance, and that are missing cached credential policies : "  + $Date

$msg.To.add("david_rowe@domain.com")

$msg.From = "administrator@domain.com"

$SmtpClient = new-object system.net.mail.smtpClient

$smtpclient.Host = 'mailhub.domain.com'

$smtpclient.Send($msg)
}

SendMail