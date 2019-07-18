$privGroupSIDS = @{}
$privGroupSIDS.Add(500, "Administrator")
$privGroupSIDS.Add(502, "KRBTGT")
$privGroupSIDS.Add(512, "Domain Admins")
$privGroupSIDS.Add(516, "Domain Controllers")
$privGroupSIDS.Add(517, "Cert Publishers")
$privGroupSIDS.Add(518, "Schema Admins")
$privGroupSIDS.Add(519, "Enterprise Admins")
$privGroupSIDS.Add(520, "GPO Creator Owners")
$privGroupSIDS.Add(521, "RODCs")
$privGroupSIDS.Add(527, "Enterprise Key Admins")
$privGroupSIDS.Add(544, "Builtin Admins")
$privGroupSIDS.Add(547, "Power Users")
$privGroupSIDS.Add(548, "Account Operators")
$privGroupSIDS.Add(549, "Server Operators")
$privGroupSIDS.Add(550, "Printer Operators")
$privGroupSIDS.Add(551, "Backup Operators")
$privGroupSIDS.Add(552, "Replicator")
$privGroupSIDS.Add(555, "Remote Desktop")
$privGroupSIDS.Add(557, "Incoming Forest Trust Builders")
$privGroupSIDS.Add(562, "DCOM Users")
$privGroupSIDS.Add(578, "HyperV Admins")
$privGroupSIDS.Add(579, "ACCESS_CONTROL_ASSISTANCE_OPS")
$privGroupSIDS.Add(580, "Remote Management Users")
$privGroupSIDS.Add(0, "Creator_Owner")
$privGroupSIDS.Add(5555555, "TESTMATCH-Group") #pick a random group on your domain get-adgroup "nameofgroup", results return the group and use the last digits of the SID for the value


,,,,,,,,,,,,,,
#source: https://msdn.microsoft.com/en-us/library/cc980032.aspx

$sidguys = Get-ADObject -Filter {objectclass -eq "user"} -Properties sidhistory|Where-Object objectclass -eq user
$sidcomps = Get-ADObject -Filter {objectclass -eq "Computer"} -Properties sidhistory|Where-Object objectclass -eq computer
$sidgroups = Get-ADObject -Filter {objectclass -eq "Group"} -Properties sidhistory

$history = $sidguys |Where {$_.sidhistory.count -ge 1}
#cycle through users
foreach ($user in $history){
#get last part of sid to parse
#write-host on $user.name
#cycle through sidhistory
foreach ($item in $user.SIDHistory.value.value){
    #write-host on $item of $user.name
    #$ID = ($user.SIDHistory -split "-")[(($user.SIDHistory -split "-").count)-1]
    $ID = ($item -split "-")[(($item -split "-").count)-1]
    #if id matches priv group
    if ($privGroupSIDS.Keys -contains $id){
    write-host $user.DistinguishedName is in the Privileged group $privGroupSIDS[$id]
    }
}

}

$history = $sidcomps |Where {$_.sidhistory.count -ge 1}
#cycle through users
foreach ($user in $history){
#get last part of sid to parse
#write-host on $user.name
#cycle through sidhistory
foreach ($item in $user.SIDHistory.value.value){
   # write-host on $item of $user.name
    #$ID = ($user.SIDHistory -split "-")[(($user.SIDHistory -split "-").count)-1]
    $ID = ($item -split "-")[(($item -split "-").count)-1]
    #if id matches priv group
    if ($privGroupSIDS.Keys -contains $id){
    write-host $user.DistinguishedName is in the Privileged group $privGroupSIDS[$id]
    }
}

}


$history = $sidgroups |Where {$_.sidhistory.count -ge 1}
#cycle through users
foreach ($user in $history){
#get last part of sid to parse
#write-host on $user.name
#cycle through sidhistory
foreach ($item in $user.SIDHistory.value.value){
    #write-host on $item of $user.name
    #$ID = ($user.SIDHistory -split "-")[(($user.SIDHistory -split "-").count)-1]
    $ID = ($item -split "-")[(($item -split "-").count)-1]
    #if id matches priv group
    if ($privGroupSIDS.Keys -contains $id){
    write-host $user.DistinguishedName is in the Privileged group $privGroupSIDS[$id]
    }
}

}