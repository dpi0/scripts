# Auto-elevate if not running as Administrator
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Critical battery action -- on battery (DC) -- do nothing
powercfg -setdcvalueindex SCHEME_CURRENT SUB_BATTERY BATACTIONCRIT 0

# Critical battery action -- plugged in (AC) -- do nothing
powercfg -setacvalueindex SCHEME_CURRENT SUB_BATTERY BATACTIONCRIT 0

# Low battery action -- on battery (DC) -- do nothing
powercfg -setdcvalueindex SCHEME_CURRENT SUB_BATTERY BATACTIONLOW 0

# Low battery action -- plugged in (AC) -- do nothing
powercfg -setacvalueindex SCHEME_CURRENT SUB_BATTERY BATACTIONLOW 0

# Apply the changes to the current power scheme
powercfg /S SCHEME_CURRENT

# Optional diagnostics: query all values in the current scheme
powercfg /query SCHEME_CURRENT

# Optional diagnostics: get the critical battery action on AC
powercfg /query SCHEME_CURRENT SUB_BATTERY BATACTIONCRIT
