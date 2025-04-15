#NoEnv
#Persistent
#SingleInstance, Force
SendMode Input
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode 2
SetTimer, CheckBattery, 60000  ; Check battery every 60 seconds

; Configurable settings
threshold := 20  ; Battery percentage threshold
alarmFreq := 750  ; Frequency of beep (Hz)
alarmDuration := 500  ; Duration of beep (ms)
msgBoxDelay := 5000  ; Delay before repeating message (ms)

CheckBattery:
    batteryPercent := GetBatteryLevel()
    pluggedIn := IsChargerConnected()
    
    if (batteryPercent < threshold && !pluggedIn) {
        Loop {
            SoundBeep, %alarmFreq%, %alarmDuration%
            MsgBox, 48, Battery Low, WARNING! Battery level is at %batteryPercent%`. Plug in your charger!
            Sleep, %msgBoxDelay%
            
            batteryPercent := GetBatteryLevel()
            pluggedIn := IsChargerConnected()
            if (batteryPercent >= threshold || pluggedIn)
                break
        }
    }
return

GetBatteryLevel() {
    RunWait, %ComSpec% /C "WMIC Path Win32_Battery Get EstimatedChargeRemaining /Value > %A_Temp%\battery.txt",, Hide
    FileRead, batteryStatus, %A_Temp%\battery.txt
    return ExtractNumber(batteryStatus)
}

IsChargerConnected() {
    RunWait, %ComSpec% /C "WMIC Path Win32_Battery Get BatteryStatus /Value > %A_Temp%\power.txt",, Hide
    FileRead, powerStatus, %A_Temp%\power.txt
    return (ExtractNumber(powerStatus) = 2)  ; 2 means charging
}

ExtractNumber(str) {
    return RegExReplace(str, "[^0-9]", "")
}
