New-Item -Path "$ENV:USERPROFILE" -Name "build" -ItemType "directory" -Force | Out-Null
Start-Transcript -path "$ENV:USERPROFILE/build/winrm.txt" -append

# ===
# WinRM
# ===

# Set current network to private
$ifaceinfo = Get-NetConnectionProfile
Set-NetConnectionProfile -InterfaceIndex $ifaceinfo.InterfaceIndex -NetworkCategory Private 

# Set up WinRM and configure some things
winrm quickconfig -q
winrm s "winrm/config" '@{MaxTimeoutms="1800000"}'
winrm s "winrm/config/winrs" '@{MaxMemoryPerShellMB="2048"}'
winrm s "winrm/config/service" '@{AllowUnencrypted="true"}'
winrm s "winrm/config/service/auth" '@{Basic="true"}'

sc.exe config winrm start= auto

# ===
# Exit
# ===

Stop-Transcript
exit 0
