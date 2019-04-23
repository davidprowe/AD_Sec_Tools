$debug=$false
$groups = $null
$OUsearch =$null
$dc = (Get-ADDomain).PDCEmulator
$forest = (Get-ADDomain).Forest.Split('.')

$OUSearch = "OU=Admin"

for ($i = 0;$i -lt $forest.count; $i++)
{
    $OUSearch+= ",DC=" + $forest[$i]
}
if ($debug){$OUSearch}

$TLGs = ("Tier 1","Tier 2")
foreach ($tlg in $TLGs){
    #Define  Top Level Admin Group for Tier
    $tlgAdminGroup = $TLG + "Admins" -replace '\s+'
    #Extract leading and trailing char from top level group for use in OU search
    $OUNode = $tlg[0] + $tlg[$tlg.Length-1]

    
    #Get all groups in relevant OU for addition to master Admin group
    $groups = Get-ADGroup -Filter {Name -notlike "$tlg*"} -SearchBase "OU=$OUNode-Roles,OU=$Tlg,$ousearch" | Select-Object -ExpandProperty name
    if ($debug){
        "`n-------------`n$tlgAdminGroup`n$OUNode`nFound: " +$groups.count + " Delegated Admin Groups"
    }

    foreach ($group in $groups){
        if ($debug){
            $group
            Add-ADGroupMember -Identity $tlgAdminGroup  -Members $group -server $dc -WhatIf
        }else{Add-ADGroupMember -Identity $tlgAdminGroup  -Members $group -Server $dc}

    }
}