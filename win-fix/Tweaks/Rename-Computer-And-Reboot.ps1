# Auto-elevate if not running as Administrator
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 1. Show current computer name
$currentName = (Get-ComputerInfo -Property CsName).CsName
Write-Host "Current computer name: $currentName"

# 2. Set new name via script variable
#    Change this value to whatever hostname you want.
$newName = "windows"
Write-Host "New computer name will be: $newName"

if ($currentName -eq $newName) {
    Write-Host "New name is the same as the current name. Skipping rename."
} else {
    Write-Host "Renaming computer..."
    Rename-Computer -NewName $newName -Force
    Write-Host "Computer renamed. A reboot is required for changes to take effect."
}

# 3. Ask Y/N to reboot
$answer = Read-Host "Reboot now? (Y/N)"

if ($answer -match '^[Yy]') {
    Write-Host "Rebooting..."
    Restart-Computer
} else {
    Write-Host "Reboot skipped. Remember to restart later for the name change to apply."
}
