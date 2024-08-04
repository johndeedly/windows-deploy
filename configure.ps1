# For reference:
# https://github.com/luciusbono/Packer-Windows10
# https://github.com/joefitzgerald/packer-windows
# https://twitter.com/jonasLyk/status/1293815234805760000

New-Item -Path "$ENV:USERPROFILE" -Name "build" -ItemType "directory" -Force | Out-Null
Start-Transcript -path "$ENV:USERPROFILE/build/configure.txt" -append

Set-ExecutionPolicy -ExecutionPolicy Bypass -Force
C:/Windows/SysWOW64/cmd.exe /c powershell -Command "Set-ExecutionPolicy -ExecutionPolicy Bypass -Force"

# ===
# Network
# ===

# Supress network location Prompt
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force

# ===
# System settings
# ===

# disable hibernation
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\" -Name "HiberFileSizePercent" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\" -Name "HibernateEnabled" -Value 0 -Force

# disable password expiration
wmic useraccount where "name='user'" set PasswordExpires=FALSE

# disable windows updates
net stop wuauserv
New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Force
New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 1 -PropertyType DWORD -Force
$pause = (Get-Date).AddDays(35);
$pause = $pause.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ");
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'PauseUpdatesExpiryTime' -Value $pause -Force

# disable telemetry
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost\" -Name "EnableWebContentEvaluation" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo\" -Name "Enabled" -Value 0 -Force
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo\" -Name "Id" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection\" -Name "AllowTelemetry" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection\" -Name "MaxTelemetryAllowed" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration\" -Name "Status" -Value 0 -Force

# disable microsoft defender
New-Item -Path "C:\ProgramData\Microsoft" -Name "Windows Defender" -ItemType "directory" -Force | Out-Null
C:/Windows/System32/cmd.exe /c mklink "C:\ProgramData\Microsoft\Windows Defender:omgwtfbbq" "\??\NUL"
New-Item -Path "C:\ProgramData\Microsoft" -Name "Windows Defender Advanced Threat Protection" -ItemType "directory" -Force | Out-Null
C:/Windows/System32/cmd.exe /c mklink "C:\ProgramData\Microsoft\Windows Defender Advanced Threat Protection:omgwtfbbq" "\??\NUL"
New-Item -Path "C:\ProgramData\Microsoft" -Name "Microsoft Defender" -ItemType "directory" -Force | Out-Null
C:/Windows/System32/cmd.exe /c mklink "C:\ProgramData\Microsoft\Microsoft Defender:omgwtfbbq" "\??\NUL"
New-Item -Path "C:\ProgramData\Microsoft" -Name "Microsoft Defender Advanced Threat Protection" -ItemType "directory" -Force | Out-Null
C:/Windows/System32/cmd.exe /c mklink "C:\ProgramData\Microsoft\Microsoft Defender Advanced Threat Protection:omgwtfbbq" "\??\NUL"
Write-Output "Microsoft Windows Defender disabled."

# enable system bios utc time
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation\" -Name "RealTimeIsUniversal" -Value 1 -Force

# ===
# Exit
# ===

Stop-Transcript
exit 0
