ShowBatteryLevel() {
    ; Retrieve battery information
    power := ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Battery")
    for obj in power {
        BatteryLevel := obj.EstimatedChargeRemaining
    }

    ; Create a dark mode-themed GUI
    Gui, -Caption
    Gui, +AlwaysOnTop
    Gui, Color, 0x080808  ; Dark gray background
    Gui, Font, s16, Inter, Bold
    Gui, Add, Text, cWhite x24 y14, % BatteryLevel "%"
    Gui, Show
}

OpenWebsite(url) {
    Send, ^c
    sleep, 500
    ClipWait, 1 ; Wait for the clipboard to contain data
    Clipboard := Trim(Clipboard) ; Trim whitespace from clipboard contents
    Run, % url
    Return
}

DisplayWindowTitle() {
    WinGetTitle, Title, A
    MsgBox, TITLE IS --> "%Title%"
    Return
}

CloseAllWindows() {
    DetectHiddenWindows, Off
    WinGet, mylist, list
    Loop % mylist
        WinClose % "ahk_id" mylist%A_Index%
    Return
}

ToggleWindowOnTop() {
    Winset, Alwaysontop, , A 
    ToolTip, This window will now stay on top 
    SetTimer, RemoveTooltip, 1000
    Return
}

RemoveTooltip:
    SetTimer, RemoveTooltip, Off
    Tooltip
    Return

ToggleHiddenFiles() {
    GoSub, CheckActiveWindow
    Return
}

CheckActiveWindow:
    ID := WinExist("A")
    WinGetClass, Class, ahk_id %ID%
    WClasses := "CabinetWClass ExploreWClass"
    IfInString, WClasses, %Class%
        GoSub, Toggle_HiddenFiles_Display
    Return

Toggle_HiddenFiles_Display:
    RootKey = HKEY_CURRENT_USER
    SubKey = Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced

    RegRead, HiddenFiles_Status, %RootKey%, %SubKey%, Hidden

    if HiddenFiles_Status = 2
        RegWrite, REG_DWORD, %RootKey%, %SubKey%, Hidden, 1 
    else 
        RegWrite, REG_DWORD, %RootKey%, %SubKey%, Hidden, 2
    PostMessage, 0x111, 41504,,, ahk_id %ID%
    Return

OpenProgram(windowClass, programPath) {
    SetTitleMatchMode 2
    DetectHiddenWindows, On
    IfWinExist %windowClass%
    {
        IfWinActive %windowClass%
            send !{Tab}
        Else
            WinActivate %windowClass%
        Return
    }
    Run %programPath%
    Return
}

ToggleFileExtensions(valueName, regKeyPath) {
    RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, %regKeyPath%, %valueName%
    If HiddenFiles_Status = 1 
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, %regKeyPath%, %valueName%, 0
    Else 
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, %regKeyPath%, %valueName%, 1
    
    WinGetClass, eh_Class, A
    If (eh_Class = "#32770" OR A_OSVersion = "WIN_VISTA")
        Send, {F5}
    Else 
        PostMessage, 0x111, 28931,,, A
    Return
}