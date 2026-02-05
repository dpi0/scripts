# Auto-elevate if not running as Administrator
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {

    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Enabling Group Policy Editor (gpedit.msc)..."

# Paths to the *.mum packages
$packages1 = Get-ChildItem "$env:SystemRoot\servicing\Packages" -Filter "Microsoft-Windows-GroupPolicy-ClientTools-Package~*.mum"
$packages2 = Get-ChildItem "$env:SystemRoot\servicing\Packages" -Filter "Microsoft-Windows-GroupPolicy-ClientExtensions-Package~*.mum"

# Install the packages
foreach ($pkg in $packages1 + $packages2) {
    Write-Host "Adding package: $($pkg.FullName)"
    DISM /Online /NoRestart /Add-Package:"$($pkg.FullName)"
}
