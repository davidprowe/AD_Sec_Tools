Enable-PSRemoting -Force
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTS Connections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1
Rename-Computer -ComputerName (hostname) -newname "TEMP-DC"
#netsh winhttp set proxy 1.3.5.2:8080 #removed
Set-TimeZone -Name "Eastern Standard Time"

Import-Module ServerManager
Install-windowsfeature -name AD-Domain-Services –IncludeManagementTools
Install-WindowsFeature –Name GPMC
shutdown /f /r /t 1



$domainname = "temp.University.edu"
$NTDPath = "C:\Windows\ntds"
$logPath = "C:\Windows\ntds"
$sysvolPath = "C:\Windows\Sysvol"
$domainmode = "win2012R2"
$forestmode = "win2012R2"



Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath $NTDPath -DomainMode $domainmode -DomainName $domainname -ForestMode $forestmode -InstallDns:$true -LogPath $logPath -NoRebootOnCompletion:$false -SysvolPath $sysvolPath -Force:$true