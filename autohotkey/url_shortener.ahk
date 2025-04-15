Gui, New,, URL shortener
Gui, Margin, 15, 15
Gui, Font, s10
Gui, Add, Radio, Checked, TinyURL
Gui, Add, Radio, x+10 yp, Is.Gd
GuiControlGet, RadioPos, Pos, Button2
Gui, Add, Text, xm, Enter URL to shorten:
Gui, Add, Edit, y+5 w200
Gui, Add, Button, x+5 yp hp, Shorten
GuiControlGet, ButtonPos, Pos, Button3
Gui, Add, Text, xm y+10, Shortened URL:
Gui, Add, Edit, xm y+5 w200
Gui, Add, Button, x+5 yp w%ButtonPosW% hp, Copy

offset := (ButtonPosX + ButtonPosW - RadioPosX - RadioPosW)//2
GuiControl, Move, Button1, % "x" . 15 + offset
GuiControl, Move, Button2, % "x" . RadioPosX + offset
Gui, Show
Return

ButtonShorten() {
   static apiTiny := "https://tinyurl.com/api-create.php?url="
        , apiIs   := "https://is.gd/create.php?format=simple&url="
   GuiControlGet, Button1
   GuiControlGet, Edit1
   url := (Button1 ? apiTiny : apiIs) . EncodeDecodeURI(Edit1)
   GuiControl,, Edit2, % HttpQuery(url)
}

ButtonCopy() {
   GuiControlGet, Clipboard,, Edit2
}

EncodeDecodeURI(str, encode := true, component := true) {
   static Doc, JS
   if !Doc {
      Doc := ComObjCreate("htmlfile")
      Doc.write("<meta http-equiv=""X-UA-Compatible"" content=""IE=9"">")
      JS := Doc.parentWindow
   }
   Return JS[ (encode ? "en" : "de") . "codeURI" . (component ? "Component" : "") ](str)
}

HttpQuery(url) {
   whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
   whr.Open("GET", url, true)
   whr.Send()
   whr.WaitForResponse()
   status := whr.status
   if (status != 200)
      throw "HttpQuery error, status: " . status
   Return whr.ResponseText
}

GuiClose() {
   ExitApp
}