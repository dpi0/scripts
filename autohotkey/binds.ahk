nircmd := EnvGet("USERPROFILE") "\scoop\apps\nircmd\current\nircmd.exe"
everything := EnvGet("USERPROFILE") "\scoop\apps\everything-alpha\current\Everything.exe"
#Include toggle_system_theme.ahk

Numpad0::     Send("!{Tab}")                      								; Switch window (ALT + Tab)
Numpad1::     Send("{Volume_Down}")               								; Volume Down
Numpad2::     Send("{Media_Play_Pause}")          								; Play/Pause media
Numpad3::     Send("{Volume_Up}")                 								; Volume Up
Numpad4::     Send("{Media_Prev}")                								; Previous media track
Numpad6::     Send("{Media_Next}")                								; Next media track
Numpad7::     Send("#^{Left}")                    								; Switch to previous virtual desktop (WIN + CTRL + Left)
Numpad8::     Send("#{Tab}")                      								; Open Task View (WIN + Tab)
Numpad9::     Send("#^{Right}")                   								; Switch to next virtual desktop (WIN + CTRL + Right)
NumpadAdd::   Run(nircmd " changebrightness +5")  								; Increase screen brightness by 5%
NumpadEnter:: Run(nircmd " changebrightness -5")  								; Decrease screen brightness by 5%

!End::   DllCall("PowrProf\SetSuspendState", "Int", 1, "Int", 0, "Int", 0)      ; ALT+End, Hibernate
#^End::  Run("shutdown /s /t 0")                                                ; WIN+CTRL+End, Shutdown
#+End::  Run("shutdown /r /t 0")                                                ; WIN+SHIFT+End, Restart
#End::   Run("shutdown /l")                                                     ; WIN+End, Log off
#t::     ToggleTheme()                                                          ; WIN+T, Toggle light/dark mode
#s::     Run(everything)                                                        ; WIN+S, Launch Everything search
#z::     Run("taskmgr.exe")                                                     ; WIN+Z, Open Task Manager
#c:: Run(EnvGet("USERPROFILE") "\AppData\Local\Packages\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\TempState\ScreenClip")  ; Win+C, Open Snipping Tool screenshots folder
#Left::  Send("#^{Left}")                                                       ; WIN+Left, Switch to previous virtual desktop
#Right:: Send("#^{Right}")                                                      ; WIN+Right, Switch to next virtual desktop