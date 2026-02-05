# Auto-elevate if not running as Administrator
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent(
)).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {

    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Disabling WinDefend service dependency..."

$regPath  = "HKLM:\SYSTEM\CurrentControlSet\Services\WinDefend"
$regValue = "DependOnService"
$newData  = "RpcSs-DISABLED"

# Apply the modification
Set-ItemProperty -Path $regPath -Name $regValue -Value $newData -Type MultiString -Force

Write-Host "Registry key written:"
Write-Host "$regPath -> $regValue = $newData"
Write-Host ""
Write-Host "You must now reboot into Safe Mode and run this script again."
