# Auto-elevate if not running as Administrator
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Remove built-in / bundled apps
Get-AppxPackage *windowsmaps*              | Remove-AppxPackage
Get-AppxPackage *phone*                    | Remove-AppxPackage
Get-AppxPackage *zune*                     | Remove-AppxPackage
Get-AppxPackage *Microsoft.WindowsCamera*  | Remove-AppxPackage
Get-AppxPackage -AllUsers Microsoft.549981C3F5F10 | Remove-AppxPackage
Get-AppxPackage *bing*                     | Remove-AppxPackage
Get-AppxPackage *officehub*                | Remove-AppxPackage
Get-AppxPackage *gethelp*                  | Remove-AppxPackage
Get-AppxPackage *3dbuilder*                | Remove-AppxPackage
Get-AppxPackage *soundrecorder*            | Remove-AppxPackage
Get-AppxPackage *solitaire*                | Remove-AppxPackage
Get-AppxPackage *Microsoft.Getstarted*     | Remove-AppxPackage
Get-AppxPackage Microsoft.YourPhone -AllUsers | Remove-AppxPackage
Get-AppxPackage Microsoft.GetHelp -AllUsers   | Remove-AppxPackage
Get-AppxPackage Microsoft.XboxGamingOverlay   | Remove-AppxPackage
Get-AppxPackage Microsoft.MSPaint             | Remove-AppxPackage
Get-AppxPackage *Xbox*                        | Remove-AppxPackage
Get-AppxPackage *xboxapp*                     | Remove-AppxPackage
Get-AppxPackage *windowscommunicationsapps*   | Remove-AppxPackage
Get-AppxPackage *3DBuilder*                   | Remove-AppxPackage
Get-AppxPackage *MicrosoftOfficeHub*          | Remove-AppxPackage
Get-AppxPackage *OneNote*                     | Remove-AppxPackage
Get-AppxPackage *people*                      | Remove-AppxPackage
Get-AppxPackage *SkypeApp*                    | Remove-AppxPackage
Get-AppxPackage *solit*                       | Remove-AppxPackage
Get-AppxPackage *WindowsSoundRecorder*        | Remove-AppxPackage
Get-AppxPackage *CommsPhone*                  | Remove-AppxPackage
Get-AppxPackage *ConnectivityStore*           | Remove-AppxPackage
Get-AppxPackage *Microsoft.Messaging*         | Remove-AppxPackage
Get-AppxPackage *Facebook*                    | Remove-AppxPackage
Get-AppxPackage *Twitter*                     | Remove-AppxPackage
Get-AppxPackage *Drawboard PDF*               | Remove-AppxPackage
Get-AppxPackage *bingfinance*                 | Remove-AppxPackage
Get-AppxPackage *bingsports*                  | Remove-AppxPackage
Get-AppxPackage *bingweather*                 | Remove-AppxPackage
Get-AppxPackage *Todos*                       | Remove-AppxPackage
Get-AppxPackage *Teams*                       | Remove-AppxPackage
Get-AppxPackage *OneDriveSync*                | Remove-AppxPackage
Get-AppxPackage *phototastic*                 | Remove-AppxPackage
Get-AppxPackage *SpotifyMusic*                | Remove-AppxPackage
Get-AppxPackage *MicrosoftStickyNotes*        | Remove-AppxPackage
Get-AppxPackage *picsart*                     | Remove-AppxPackage
Get-AppxPackage *ScreenSketch*                | Remove-AppxPackage
Get-AppxPackage *WindowsFeedbackHub*          | Remove-AppxPackage

# Kill OneDrive process if running
taskkill /f /im OneDrive.exe
