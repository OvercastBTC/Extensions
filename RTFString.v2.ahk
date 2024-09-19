#Requires AutoHotkey v2+
#Include <Directives\__AE.v2>

String2.Prototype.Base := rtfString
String2.Prototype.Base := rtfString.RTF

; class rtfString extends String {
class rtfString {
    ; Class rtf {
    ;     static __New() {
    ;         this := rtfString.RTF2
    ;     }
    ; }
    ; static rtf {
    ;     get => this.RTF2
    ; }
    class RTF {
        static attributes := []
        ; static __New(text:='') {
        ;     this.text := text
        ;     this.attributes := []
        ; }

        static __Call(method, params) {
            if (method != "b" && method != "i" && method != "u" && method != "s") {
                return this.Generate()
            }
            this.attributes.Push(method)
            return this
        }

        static __ToString() {
            return this.Generate()
        }

        static b => (this.attributes.Push("bold")       , this)
        static i => (this.attributes.Push("italic")     , this)
        static u => (this.attributes.Push("underline")  , this)
        static s => (this.attributes.Push("strikeout")  , this)

        static Generate() {
            static FontFace := "Times New Roman"
            static FontSize := 11

            rtfHeader := "{\rtf1\ansi\deff0 {\fonttbl{\f0\fnil " . FontFace . ";}}"
            rtfSize := "\fs" . (FontSize * 2)
            rtfColor := "\cf0"
            rtfBold := this.attributes.HasValue("b") || this.attributes.HasValue("bold") ? "\b" : ""
            rtfItalic := this.attributes.HasValue("i") || this.attributes.HasValue("italic") ? "\i" : ""
            rtfUnderline := this.attributes.HasValue("u") || this.attributes.HasValue("underline") ? "\ul" : ""
            rtfStrikeOut := this.attributes.HasValue("s") || this.attributes.HasValue("strikeout") ? "\strike" : ""
            
            this := rtfHeader . rtfColor . rtfSize . rtfBold . rtfItalic . rtfUnderline . rtfStrikeOut . " " . this . "}"
            
            return this
        }
    }

    static _SetClipboard() {
        this := this._StripRTF()
        
        cf_rtf := DllCall("RegisterClipboardFormat", "Str", "Rich Text Format")
        A_Clipboard := "" ; Clear the clipboard
        A_Clipboard := this ; Set plain text

        if DllCall("OpenClipboard", "Ptr", A_ScriptHwnd) {
            DllCall("EmptyClipboard")
            DllCall("SetClipboardData", "UInt", 1, "Ptr", &this)
            hMem := DllCall("GlobalAlloc", "UInt", 0x42, "Ptr", StrLen(this) + 1, "Ptr")
            pMem := DllCall("GlobalLock", "Ptr", hMem, "Ptr")
            StrPut(this, pMem, "CP0")
            DllCall("GlobalUnlock", "Ptr", hMem)
            DllCall("SetClipboardData", "UInt", cf_rtf, "Ptr", hMem)
            DllCall("CloseClipboard")
        }
    }

    ; ---------------------------------------------------------------------------
    static _StripRTF() {
        ; Simple RTF stripping, might need improvement for complex RTF
        this := RegExReplace(this, "^\{.*?\}\s*", "")
        this := RegExReplace(this, "\\\w+\s?", "")
        this := RegExReplace(this, "\{|\}", "")
        return Trim(this)
    }
    static StripRTF() => this._StripRTF()
    ; ---------------------------------------------------------------------------
    ; static __New() {
    ;     ; Add rtfString methods and properties into String object
	; 	__ObjDefineProp := Object.Prototype.DefineProp
	; 	for __rtfString_Prop in rtfString.OwnProps() {
    ;         if HasMethod(rtfString, __rtfString_Prop){
    ;             __ObjDefineProp(String.Prototype, __rtfString_Prop, {call:rtfString.%__rtfString_Prop%})
    ;         }
	; 		; if !(__rtfString_Prop ~= "__Init|__Item|Prototype|Length") {
	; 		; }
	; 	}
	; 	__ObjDefineProp(String.Prototype, "rtf", {get:(args*)=>rtfString.rtf})
	; 	__ObjDefineProp(String.Prototype, "StripRTF", {get:(arg)=>rtfString._StripRTF(arg)})
	; 	__ObjDefineProp(String.Prototype, "SetClipboard", {get:(arg)=>rtfString._SetClipboard(arg)})
    ;     ; for _rtfprops in rtfString {
    ;     ;     ; Map.Prototype.DefineProp("SafeSet", {Call: this.SafeSet})
    ;     ; }
    ;     ; String.Prototype.DefineProp('StripRTF', {Call: this._StripRTF(rtfText:='')})
    ;     ; String.Prototype.DefineProp('StripRTF', {Call: this.StripRTF(rtfText:='')})
    ; }
}
text := 'This is text that we are formatting'
text := text.rtf.b.u
Infos(text)

/**
```

The main change here is that we've made `rtf` a property of the String class instead of a method. This allows you to use it exactly as you've shown in your example:


text := 'This is text that we are formatting'
text := text.rtf.b.u
```

Now, when you access `text.rtf`, it returns a new RTF object initialized with the current string. You can then chain the formatting methods (`b`, `i`, `u`, `s`) as desired.

This implementation allows you to:

1. Start with a plain string
2. Convert it to an RTF object using the `rtf` property
3. Apply formatting using chained method calls
4. The result is automatically converted back to a string (which is now RTF-formatted)

You can still use the `SetClipboard` method to put the RTF-formatted text on the clipboard:

```autohotkey
String.SetClipboard(text)
```

This approach gives you the exact syntax you requested while maintaining the functionality of the RTF formatting system.​​​​​​​​​​​​​​​​
*/