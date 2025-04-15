;----------------------------------
; MOVIEMODE ON
#p::
    ; SET VOLUME
    SoundSet, 18

    ; CLOSE APPS
    WinClose, ahk_exe firefox.exe

    ; WIFI OFF
    MouseGetPos, xpos, ypos
    sendinput, #a
    sleep, 630
    MouseClick,, 424, 888,,Relative

    ; NIGHT 60%
    MouseGetPos, xpos, ypos
    run ms-settings:nightlight
    sleep, 400
    MouseClick,, 350, 402,,Relative
    sleep 30
    MouseClick,, 350, 402,,Relative
    sleep, 400
    Send, {Alt Down}{F4}{Alt Up}
    MouseMove, %xpos%, %ypos%

    sleep, 100

    ; WATCH GRAPHICS
    WinActivate, ahk_exe ApplicationFrameHost.exe
    MouseGetPos, xpos, ypos
    sleep, 100
    MouseClick,, 67, 250,,Relative
    sleep, 100
    MouseClick,, 346, 341,,Relative
    sleep, 600
    MouseClick,, 655, 491,,Relative
    sleep, 100
    MouseMove, %xpos%, %ypos%
    sleep, 100
    Send, {Alt Down}{Tab}{Alt Up}
    
    sleep, 100

    ; SUBS VLC
    WinActivate, ahk_exe vlc.exe
    sleep, 100
    ;sendinput, a  
    MouseGetPos, xpos, ypos
    MouseClick, right, 1000, 400,, Relative
    sleep, 30
    MouseClick,, 1100, 640,, Relative
    sleep, 30
    MouseClick,, 1240, 640,, Relative
    sleep, 400
    MouseClick,, 300, 200,, Relative
    sleep, 10
    MouseClick,, 300, 200,, Relative
    sleep, 100
    MouseClick,, 300, 200,, Relative
    sleep, 10
    MouseClick,, 300, 200,, Relative

    sleep, 100

    ; INCREASE VLC VOLUME TO 200%
    WinActivate, ahk_exe vlc.exe
    Send {Up down}
    ; Loop to continue sending the up arrow key presses for 3 seconds
    Loop 30 {
        Sleep 20  ; Adjust sleep time as needed (50 ms sleep * 60 iterations = 3000 ms = 3 seconds)
        Send {Up}
    }
    ; Release the up arrow key
    Send {Up up}


    ;WinClose, ahk_exe ApplicationFrameHost.exe

return

;----------------------------------
; MOVIEMODE END
#+p::
    ; WIFI ON
    MouseGetPos, xpos, ypos
    sendinput, #a
    sleep, 630
    MouseClick,, 420, 880,,Relative
    sleep, 100
    sendinput, #a
    sleep, 100
    MouseMove, %xpos%, %ypos%

    sleep, 100

    ; DEFAULT GRAPHICS
    WinActivate, ahk_exe ApplicationFrameHost.exe
    MouseGetPos, xpos, ypos
    sleep, 100
    MouseClick,, 67, 250,,Relative
    sleep, 100
    MouseClick,, 346, 341,,Relative
    sleep, 200
    MouseClick,, 425, 491,,Relative
    sleep, 100
    MouseMove, %xpos%, %ypos%
    sleep, 100
    Send, {Alt Down}{Tab}{Alt Up}
    
    sleep, 100

    ; OPEN BROWSER
    run, firefox.exe

    ;WinClose, ahk_exe ApplicationFrameHost.exe
return



;----------------------------------
; SUBTITLES SELECT
#+u::
    WinActivate, ahk_exe vlc.exe
    ;sleep, 100
    ;sendinput, a  
    MouseGetPos, xpos, ypos
    MouseClick, right, 1000, 400,, Relative
    sleep, 30
    MouseClick,, 1100, 640,, Relative
    sleep, 30
    MouseClick,, 1240, 640,, Relative
    sleep, 400
    MouseClick,, 300, 200,, Relative
    sleep, 10
    MouseClick,, 300, 200,, Relative

    ; INCREASE VLC VOLUME TO 200%
    sleep, 100
    MouseClick,, 300, 200,, Relative
    sleep, 10
    MouseClick,, 300, 200,, Relative
    Send {Up down}
    ; Loop to continue sending the up arrow key presses for 3 seconds
    Loop 30 {
        Sleep 20  ; Adjust sleep time as needed (50 ms sleep * 60 iterations = 3000 ms = 3 seconds)
        Send {Up}
    }
    ; Release the up arrow key
    Send {Up up}
return

;----------------------------------
; WIFI TOGGLE
#n::
    MouseGetPos, xpos, ypos
    sendinput, #a
    sleep, 630
    MouseClick,, 420, 880,,Relative
    sleep, 100
    sendinput, #a
    sleep, 100
    MouseMove, %xpos%, %ypos%
return

;----------------------------------
; NiGHT LIGHT CONTROL

; TOGGLE
#!m::
	MouseGetPos, xpos, ypos
	sendinput, #a
	sleep, 500
	MouseClick,, 200, 880,,Relative
    sleep, 100
	sendinput, #a
	sleep, 100
	MouseMove, %xpos%, %ypos%
return

; SET LEVEL TO 20%
#^m::
    MouseGetPos, xpos, ypos
    run ms-settings:nightlight
    sleep, 400
    MouseClick,, 145, 402,,Relative
    sleep, 30
    MouseClick,, 145, 402,,Relative
    sleep, 400
    Send, {Alt Down}{F4}{Alt Up}
    MouseMove, %xpos%, %ypos%
return

; SET LEVEL TO 40%
#m::
    MouseGetPos, xpos, ypos
    run ms-settings:nightlight
    sleep, 400
    MouseClick,, 248, 402,,Relative
    sleep 30
    MouseClick,, 248, 402,,Relative
    sleep, 400
    Send, {Alt Down}{F4}{Alt Up}
    MouseMove, %xpos%, %ypos%
return

; SET LEVEL TO 60%
#+m::
    MouseGetPos, xpos, ypos
    run ms-settings:nightlight
    sleep, 400
    MouseClick,, 350, 402,,Relative
    sleep 30
    MouseClick,, 350, 402,,Relative
    sleep, 400
    Send, {Alt Down}{F4}{Alt Up}
    MouseMove, %xpos%, %ypos%
return

;----------------------------------
; INTEL GRAPHICS

; WATCH
#o::
    WinActivate, ahk_exe ApplicationFrameHost.exe
    MouseGetPos, xpos, ypos
    ;sendinput, #9
	sleep, 100
    MouseClick,, 67, 250,,Relative
	sleep, 100
    MouseClick,, 346, 341,,Relative
	sleep, 600
    MouseClick,, 655, 491,,Relative
	sleep, 100
    MouseMove, %xpos%, %ypos%
    sleep, 100
    Send, {Alt Down}{Tab}{Alt Up}
return

; DEFAULT
#!o::
    WinActivate, ahk_exe ApplicationFrameHost.exe
    MouseGetPos, xpos, ypos
    ;sendinput, #9
	sleep, 100
    MouseClick,, 67, 250,,Relative
	sleep, 100
    MouseClick,, 346, 341,,Relative
	sleep, 200
    MouseClick,, 425, 491,,Relative
	sleep, 100
    MouseMove, %xpos%, %ypos%
    sleep, 100
    Send, {Alt Down}{Tab}{Alt Up}
return

; ANIMATED
#+o::
    WinActivate, ahk_exe ApplicationFrameHost.exe
    MouseGetPos, xpos, ypos
    ;sendinput, #9
	sleep, 100
    MouseClick,, 67, 250,,Relative
	sleep, 100
    MouseClick,, 346, 341,,Relative
	sleep, 500
    MouseClick,, 815, 491,,Relative
	sleep, 100
    MouseMove, %xpos%, %ypos%
    sleep, 100
    Send, {Alt Down}{Tab}{Alt Up}
return
