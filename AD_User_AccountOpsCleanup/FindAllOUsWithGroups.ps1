$ous = Get-ADOrganizationalUnit -SearchScope OneLevel -f *
$ToplevelUsers = @()
$onemoredown = @()
foreach ($ou in $ous){
$onemoredown += Get-ADOrganizationalUnit -SearchBase $ou -SearchScope OneLevel -f *


}
foreach ($ou in $onemoredown){
$ToplevelUsers += Get-adgroup -ResultSetSize 10 -SearchBase $ou -f *|select distinguishedname


}

$array = @()

foreach ($user in $ToplevelUsers){

$arraytemp = ($user.distinguishedname -split ",")
$arraytemp =  $arraytemp[1..($arraytemp.count-1)]
$array += $arraytemp -join ","

}

$array = $array|select -Unique
$array