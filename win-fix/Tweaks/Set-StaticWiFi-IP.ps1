# Auto-elevate if not running as Administrator
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$iface = "Wi-Fi"
$newIPAdress = "192.168.1.60"
$prefixLength = 24
$gateway = "192.168.1.1"
$dnsServers = @("9.9.9.9", "1.1.1.1")

Write-Host "Configuring static IP for: $iface"

# Disable DHCP
Set-NetIPInterface -InterfaceAlias $iface -Dhcp Disabled

# Apply static IP + gateway
New-NetIPAddress `
    -InterfaceAlias $iface `
    -IPAddress $newIPAdress `
    -PrefixLength $prefixLength `
    -DefaultGateway $gateway `
    -ErrorAction SilentlyContinue

# Set DNS servers
Set-DnsClientServerAddress -InterfaceAlias $iface -ServerAddresses $dnsServers

Write-Host ""
Write-Host "Verifying..."
Get-NetIPAddress -InterfaceAlias $iface
Get-DnsClientServerAddress -InterfaceAlias $iface
ipconfig /all
