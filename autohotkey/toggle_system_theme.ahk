#Requires AutoHotkey v2.0
SendMode("Input")
SetWorkingDir(A_ScriptDir)

psScript := "
(
param($flagLightMode)
New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value $flagLightMode -Type Dword -Force
New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value $flagLightMode -Type Dword -Force
)"


SetTheme(flagLightMode) {
    global psScript
    RunWait("PowerShell.exe -Command &{" psScript "} '" flagLightMode "'", , "Hide")
}

ToggleTheme() {
    currentMode := RegRead("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme", 1)
    newMode := !currentMode
    SetTheme(newMode)
}