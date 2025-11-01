# AutoHotkey Scripts

Moved from: <https://github.com/dpi0/ahk_scripts>

Entrypoint `main.ahk` runs `binds.ahk` and `battery_alarm.ahk`

User only has to run `main.ahk` in the background.

It is recommended to place `main.ahk` in `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup` to make sure it runs at startup.

Either manually copy it there OR use this powershell command `Copy-Item "C:\path\to\main.ahk" "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\main.ahk"`

`binds.ahk` contains various keybinds.

`battery_alarm.ahk` is to trigger an annoying audio beep and a visual message box when battery hits a certain threshold percentage.

`binds.ahk` triggers `toggle_system_theme.ahk` via a keybind.

`toggle_system_theme.ahk` toggles b/w light and dark windows system theme.
