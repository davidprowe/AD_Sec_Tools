#not used because admin users will be granted to the top groups "UNIV_T2_full_fullcontrol*"
$T2AdminOULocation = "OU=T2-Permissions,OU=Tier 2,OU=Admin" + "," + $dn
cd ad:
$dc = (get-addomain).PDCEmulator
$admintype = @('User','Group','Computer')

foraech ($g in $admintype){

$grpname = "LegacyOUs "+$g+ " UserAdmins"

New-ADGroup -Description "Full Control administrators on legacy OUs for $g objects" -Name $grpname -Path $T2AdminOULocation -GroupCategory Security -GroupScope Global -Server $dc 
        $adgroup = get-adgroup $t2groupname -Server $dc
        $adgroup |Set-ADGroup -replace @{info = "Check memberof tab for permissions granted to this group"}


}
