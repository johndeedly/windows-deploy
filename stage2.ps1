New-Item -Path "$ENV:USERPROFILE" -Name "build" -ItemType "directory" -Force | Out-Null
Start-Transcript -path "$ENV:USERPROFILE/build/stage2.txt" -append

Write-Output "Enable Global Confirmation in Chocolatey"
choco feature enable -n allowGlobalConfirmation

Write-Output "Installing Microsoft Visual C++ Runtime"
choco install vcredist-all
Write-Output "Installing Notepad++"
choco install notepadplusplus
Write-Output "Installing 7zip"
choco install 7zip
Write-Output "Installing Mozilla Firefox"
choco install firefox
Write-Output "Installing Visual Studio Code"
choco install vscode

# ===
# Exit
# ===

Stop-Transcript
exit 0
