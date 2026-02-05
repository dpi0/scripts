# Auto-elevate if not running as Administrator
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# List of services to stop and disable
$services = @(
    "WSearch"                                  # Windows Search
    "SysMain"                                  # SysMain (Superfetch)
    "PcaSvc"                                   # Program Compatibility Assistant Service
    "TabletInputService"                       # Touch Keyboard & Handwriting Panel

    "CertPropSvc"                              # Certificates Propagation Service
    "diagnosticshub.standardcollector.service" # Diagnostics Hub Standard Collector
    "DiagTrack"                                # Diagnostics Tracking Service
    "DPS"                                      # Diagnostic Policy Service
    "dmwappushservice"                         # WAP Push Message Routing Service
    "iphlpsvc"                                 # IP Helper
    "lfsvc"                                    # Geolocation Service
    "lmhosts"                                  # TCP/IP NetBIOS Helper
    "MapsBroker"                               # Downloaded Maps Manager
    "MSiSCSI"                                  # Microsoft iSCSI Initiator Service
    "Netlogon"                                 # NetLogon Service
    "RemoteRegistry"                           # Remote Registry
    "RemoteAccess"                             # Routing and Remote Access
    "RpcLocator"                               # RPC Locator
    "SCardSvr"                                 # Smart Card
    "SCPolicySvc"                              # Smart Card Removal Policy
    "SharedAccess"                             # Internet Connection Sharing (ICS)
    "SNMPTRAP"                                 # SNMP Trap
    "Spooler"                                  # Print Spooler
    "stisvc"                                   # Windows Image Acquisition (WIA)
    "TrkWks"                                   # Distributed Link Tracking Client
    "WbioSrvc"                                 # Windows Biometric Service
    "WMPNetworkSvc"                            # Windows Media Player Network Sharing Service
)

foreach ($service in $services) {
    Write-Output "Processing service: $service"

    try {
        # Try to stop the service if it is running
        $svc = Get-Service -Name $service -ErrorAction Stop

        if ($svc.Status -ne 'Stopped') {
            Write-Output "Stopping $service..."
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        }

        Write-Output "Disabling $service startup..."
        Set-Service -Name $service -StartupType Disabled -ErrorAction Stop

        Write-Output "$service successfully set to Disabled."
    }
    catch {
        # FIXED: use ${service} so the colon is treated as a literal
        Write-Output "Could not process ${service}: $($_.Exception.Message)"
        # Alternative would be:
        # Write-Output ("Could not process {0}: {1}" -f $service, $_.Exception.Message)
    }

    Write-Output "-------------------------------------------"
}

Read-Host "Done. Press ENTER to exit"

# Inspired by: <https://gist.github.com/iamjonny/cad47c59f6427be27d05d568b078edf4>
# and <https://www.makeuseof.com/disable-these-useless-windows-services/>
