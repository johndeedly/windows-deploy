New-Item -Path "$ENV:USERPROFILE" -Name "build" -ItemType "directory" -Force | Out-Null
Start-Transcript -path "$ENV:USERPROFILE/build/stage1.txt" -append

# ===
# Chocolatey
# ===

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# ===
# WSL (stage 1)
# ===
Write-Output "Enable WSL (stage 1)"
Write-Output "[#] Microsoft-Windows-Subsystem-Linux"
Start-Process dism.exe -ArgumentList "/online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart" -Wait -NoNewWindow
Write-Output "[#] VirtualMachinePlatform"
Start-Process dism.exe -ArgumentList "/online /enable-feature /featurename:VirtualMachinePlatform /all /norestart" -Wait -NoNewWindow

# ===
# Exit
# ===

Stop-Transcript
exit 0
