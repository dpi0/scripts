#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode("Input")
SetWorkingDir(A_ScriptDir)
SetTitleMatchMode(2)
SetTimer(CheckBattery, 90000)  ; Check battery every 90 seconds

threshold := 35          ; Battery percentage threshold
alarmFreq := 750         ; Frequency of beep (Hz)
alarmDuration := 500     ; Duration of beep (ms)
msgBoxDelay := 5000      ; Delay before repeating message (ms)

CheckBattery() {
    global threshold, alarmFreq, alarmDuration, msgBoxDelay
    batteryPercent := GetBatteryLevel()
    pluggedIn := IsChargerConnected()

    if (batteryPercent < threshold && !pluggedIn) {
        Loop {
            SoundBeep(alarmFreq, alarmDuration)
            MsgBox("WARNING! Battery level is at " batteryPercent "%. Plug in your charger!", "Battery Low", 48)
            Sleep(msgBoxDelay)

            batteryPercent := GetBatteryLevel()
            pluggedIn := IsChargerConnected()
            if (batteryPercent >= threshold || pluggedIn)
                break
        }
    }
}

GetBatteryLevel() {
    tmpFile := A_Temp "\battery.txt"
    RunWait(A_ComSpec " /C WMIC Path Win32_Battery Get EstimatedChargeRemaining /Value > " tmpFile,, "Hide")
    batteryStatus := FileRead(tmpFile)
    return ExtractNumber(batteryStatus)
}

IsChargerConnected() {
    tmpFile := A_Temp "\power.txt"
    RunWait(A_ComSpec " /C WMIC Path Win32_Battery Get BatteryStatus /Value > " tmpFile,, "Hide")
    powerStatus := FileRead(tmpFile)
    return (ExtractNumber(powerStatus) = 2)
}

ExtractNumber(str) {
    return RegExReplace(str, "[^0-9]")
}