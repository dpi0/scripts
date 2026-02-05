# Auto-elevate if not running as Administrator
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$iface = "Wi-Fi"

Write-Host "Reverting Wi-Fi interface to DHCP..."

# Enable DHCP
Set-NetIPInterface -InterfaceAlias $iface -Dhcp Enabled

# Reset DNS
Set-DnsClientServerAddress -InterfaceAlias $iface -ResetServerAddresses

Write-Host ""
Write-Host "Verifying..."
Get-NetIPAddress -InterfaceAlias $iface
Get-DnsClientServerAddress -InterfaceAlias $iface
ipconfig /all
