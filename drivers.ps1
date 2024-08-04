New-Item -Path "$ENV:USERPROFILE" -Name "build" -ItemType "directory" -Force | Out-Null
Start-Transcript -path "$ENV:USERPROFILE/build/drivers.txt" -append

# ===
# install drivers
# ===

# enable qemu guest-agent
Start-Process msiexec -ArgumentList "/I F:\drivers\guest-agent\qemu-ga-x86_64.msi /qn /norestart" -Wait -NoNewWindow

# enable all qemu drivers from cd
Get-ChildItem F:\drivers\ -Recurse -Filter "*.inf" | ForEach-Object {
    Start-Process pnputil.exe -ArgumentList "/add-driver $($_.FullName) /install" -Wait -NoNewWindow
}

# enable virtualbox
Get-ChildItem "F:\drivers\cert\" -Recurse -Filter "*.cer" | ForEach-Object {
    Start-Process -FilePath "F:\drivers\cert\VBoxCertUtil.exe" -ArgumentList "add-trusted-publisher $($_.FullName) --root $($_.FullName)" -Wait -NoNewWindow
}
Start-Process -FilePath "F:\drivers\guest-agent\VBoxWindowsAdditions-amd64.exe" -ArgumentList "/S" -Wait -NoNewWindow

# wait until everything settles down
Write-Output "Waiting for 1min to let everything settle down."
sleep 60

# multiple times as one time only seems to be not enough apparently
Get-ChildItem F:\drivers\ -Recurse -Filter "*.inf" | ForEach-Object {
    Start-Process pnputil.exe -ArgumentList "/add-driver $($_.FullName) /install" -Wait -NoNewWindow
}

# wait again until everything settles down
Write-Output "Waiting for 1min to let everything settle down."
sleep 60

# ===
# Exit
# ===

Stop-Transcript
exit 0
