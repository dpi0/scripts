# Auto-elevate if not running as Administrator
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Output "=== Before enabling hibernation ==="
powercfg /a
Get-Item -Path C:\hiberfil.sys -Force -ErrorAction SilentlyContinue | Out-Null

# Enable hibernation
Write-Output "Enabling hibernation..."
powercfg /hibernate on

Write-Output "=== After enabling hibernation ==="
powercfg /a
Get-Item -Path C:\hiberfil.sys -Force -ErrorAction SilentlyContinue | Out-Null
Write-Output "If hiberfil.sys exists and 'Hibernate' is listed as available, configuration is OK."
