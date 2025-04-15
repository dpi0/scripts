#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

psScript =
(
    param($flagLightMode)
    New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value $flagLightMode -Type Dword -Force
    New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value $flagLightMode -Type Dword -Force
)

; Function to restart Explorer and close any new windows
RestartExplorerAndCloseWindow() {
    ; Close explorer process
    Process, Close, explorer.exe
    Sleep, 1000  ; Wait for process to fully close
    
    ; Start explorer.exe
    Run, explorer.exe
    
    ; Wait for explorer to initialize
    Sleep, 1000
    
    ; Look for and close any newly opened Explorer windows
    WinClose, ahk_class CabinetWClass
    WinClose, ahk_class ExploreWClass
}

; Windows + Shift + d - Dark Mode
#+d::
    RunWait PowerShell.exe -Command &{%psScript%} '0',, hide
    RestartExplorerAndCloseWindow()
return

; Windows + Shift + l - Light Mode
#+l::
    RunWait PowerShell.exe -Command &{%psScript%} '1',, hide
    RestartExplorerAndCloseWindow()
return

; Windows + t - Toggle Mode
#t::
    ; Read current theme mode from registry
    RegRead, currentMode, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize, AppsUseLightTheme
    if (currentMode = 1)  ; if currently light mode...
    {
        ; Switch to dark mode (value 0)
        RunWait PowerShell.exe -Command &{%psScript%} '0',, hide
    }
    else  ; Otherwise (assumed dark mode), switch to light mode (value 1)
    {
        RunWait PowerShell.exe -Command &{%psScript%} '1',, hide
    }
    RestartExplorerAndCloseWindow()
return
