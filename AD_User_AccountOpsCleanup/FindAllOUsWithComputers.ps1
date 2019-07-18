$ous = Get-ADOrganizationalUnit -SearchScope OneLevel -f *
$ToplevelComps = @()
$onemoredown1 = @()
$onemoredown2 = @()
foreach ($ou in $ous){
$onemoredown1 += Get-ADOrganizationalUnit -SearchBase $ou -SearchScope OneLevel -f *


}
foreach ($ou in $onemoredown1){
$onemoredown2 += Get-ADOrganizationalUnit -SearchBase $ou -SearchScope OneLevel -f *


}

foreach ($ou in $onemoredown2){
$ToplevelComps += Get-ADcomputer -ResultSetSize 10 -SearchBase $ou -f *|select distinguishedname


}

$array = @()

foreach ($comp in $ToplevelComps){

$arraytemp = ($comp.distinguishedname -split ",")
$arraytemp =  $arraytemp[1..($arraytemp.count-1)]
$array += $arraytemp -join ","

}

$array = $array|select -Unique
$array

