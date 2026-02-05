# Auto-elevate if not running as Administrator (HKCU usually doesn't need it, but consistent behavior)
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Hide Recycle Bin icon on desktop (fixed Explorer path)
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" `
    -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 1 -PropertyType DWORD -Force
