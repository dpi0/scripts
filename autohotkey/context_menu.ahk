#NoEnv
#SingleInstance force
#MaxHotkeysPerInterval 9999
;-------------------------------------------------------------------------------
MenuDark()
MenuDark(Dark:=1) {
    static uxtheme := DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
    static SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
    static FlushMenuThemes := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")
    DllCall(SetPreferredAppMode, "int", Dark)
    DllCall(FlushMenuThemes)
}
;-------------------------------------------------------------------------------
;OPTION1
Menu, p, Add, Folders, MainMenuLabel
    Menu, cFolders, Add, wDownloads, cFoldersL
    Menu, cFolders, Add, Documents, cFoldersL
        Menu, gcDocuments, Add, Apps, gcDocumentsL
        Menu, gcDocuments, Add, Backup Settings & Files, gcDocumentsL
        Menu, gcDocuments, Add, College Stuff, gcDocumentsL
        Menu, gcDocuments, Add, go, gcDocumentsL
    Menu, cFolders, Add, Pictures, cFoldersL
        Menu, gcPictures, Add, Screenshots, gcPicturesL
        Menu, gcPictures, Add, Icons, gcPicturesL
        Menu, gcPictures, Add, dImp Docs, gcPicturesL
        Menu, gcPictures, Add, Presentation Backgrounds, gcPicturesL
    Menu, cFolders, Add, Local, cFoldersL
    Menu, cFolders, Add, Roaming, cFoldersL
    Menu, cFolders, Add, Program Files, cFoldersL

Menu, p, Add, Folders, :cFolders
Menu, cFolders, Add, Documents, :gcDocuments
Menu, cFolders, Add, Pictures, :gcPictures

cFoldersL:
switch A_ThisMenuItemPos {
    case 1:
        run C:\Users\%A_Username%\Downloads
    case 2:
        run C:\Users\%A_Username%\Documents
    case 3:
        run C:\Users\%A_Username%\Pictures
    case 4:
        run C:\Users\%A_Username%\Pictures\Screenshots
    case 5:
        run C:\Users\%A_Username%\Appdata\Local
    case 6:
        run C:\Users\%A_Username%\Appdata\Roaming
}

gcDocumentsL:
switch A_ThisMenuItemPos {
    case 1:
        run C:\Users\%A_Username%\Documents\Apps
}

gcPicturesL:
switch A_ThisMenuItemPos {
    case 1:
        run C:\Users\%A_Username%\Pictures\Screenshots
}

;----
;PARENT2
Menu, p, Add, Parent2, HasASubMenuLabel

;----
;PARENT3
Menu, p, Add, Parent3, MainMenuLabel
;----
;PARENT4
Menu, p, Add, Parent4, HasASubMenuLabel
    Menu, cvarParent4, Add, Child41, Child4Label
    Menu, cvarParent4, Add, Child42, Child4Label
    Menu, cvarParent4, Add, Child43, Child4Label

Menu, p, Add, Parent4, :cvarParent4
;----
return
;------------------------------------
;HOTKEY
!l::Menu, p, Show
return
;------------------------------------
;LABLES  MAINMENU
HasASubMenuLabel:
return

MainMenuLabel:
switch A_ThisMenuItemPos {
    case 1:
        ; task
    case 3:
        ; task
}
return
;------------------------------------
;LABLES  SUBMENUS


Child2Label:
switch A_ThisMenuItemPos {
    case 1:
        ; task
    case 2:
        ; task
    case 3:
        ; task
}
return

Child4Label:
switch A_ThisMenuItemPos {
    case 1:
        ; task
    case 2:
        ; task
    case 3:
        ; task
}
return

GrandChild22Label:
switch A_ThisMenuItemPos {
    case 1:
        ; task
    case 2:
        ; task
    case 3:
        ; task
}
return

GrandChild41Label:
switch A_ThisMenuItemPos {
    case 1:
        ; task
    case 2:
        ; task
    case 3:
        ; task
}
return


return
