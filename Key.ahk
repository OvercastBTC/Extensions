#Requires AutoHotkey v2+
; #Include <Directives\__AE.v2>
#Include <Includes\ObjectTypeExtensions>

class HotkeyProcessor {
	static ProcessHotkey(hotkeyString) {
		; Remove ~, *, and $ from the left side of the string
		hotkeyString := RegExReplace(hotkeyString, "^[~*$]+")

		; Initialize variables
		modifiers := []
		keyName := ""
		
		; Extract modifiers
		while (hotkeyString != "") {
			if (SubStr(hotkeyString, 1, 1) = "<") {
				; Left version of modifier
				if (SubStr(hotkeyString, 2, 1) ~= "[!^+#]") {
					modifiers.SafePush(SubStr(hotkeyString, 2, 1))
					hotkeyString := SubStr(hotkeyString, 3)
				} else {
					break
				}
			} else if (SubStr(hotkeyString, 1, 1) = ">") {
				; Right version of modifier
				if (SubStr(hotkeyString, 2, 1) ~= "[!^+#]") {
					modifiers.SafePush("r" . SubStr(hotkeyString, 2, 1))
					hotkeyString := SubStr(hotkeyString, 3)
				} else {
					break
				}
			} else if (SubStr(hotkeyString, 1, 1) ~= "[!^+#]") {
				; Standard modifier
				modifiers.SafePush(SubStr(hotkeyString, 1, 1))
				hotkeyString := SubStr(hotkeyString, 2)
			} else {
				break
			}
		}

		; The remaining string is the key name
		keyName := hotkeyString

		return { km: modifiers, k: keyName }
	}
}

; Example usage:
; result := HotkeyProcessor.ProcessHotkey(A_ThisHotkey)
; MsgBox("Modifiers: " . JSON.Stringify(result.km) . "`nKey: " . result.k . "`nScan Code: " . result.scanCode)
; 
; If you want to get a KeyObject:
; keyObj := HotkeyProcessor.GetKeyObject(result.k)
; if (keyObj) {
;     ; Press modifiers
;     for modifier in result.km {
;         modObj := HotkeyProcessor.GetModifierObject(modifier)
;         if (modObj) {
;             modObj.down()
;         }
;     }
;     
;     ; Send the main key
;     keyObj.Send()
;     
;     ; Release modifiers in reverse order
;     for modifier in result.km.Reverse() {
;         modObj := HotkeyProcessor.GetModifierObject(modifier)
;         if (modObj) {
;             modObj.up()
;         }
;     }
; }

class key {
    class syntax extends key{
        static down := " down"
        static up := " up"
        static lb := "{"
        static rb := "}"
    }

    class sc {
        static esc := 'sc01'
        static 1 := 'sc02'
        static 2 := 'sc03'
        static 3 := 'sc04'
        static 4 := 'sc05'
        static 5 := 'sc06'
        static 6 := 'sc07'
        static 7 := 'sc08'
        static 8 := 'sc09'
        static 9 := 'sc0A'
        static 0 := 'sc0B'
        static minus := 'sc0C'
        static equal := 'sc0D'
        static backspace := 'sc0E'
        static tab := 'sc0F'
        static q := 'sc10'
        static w := 'sc11'
        static e := 'sc12'
        static r := 'sc13'
        static t := 'sc14'
        static y := 'sc15'
        static u := 'sc16'
        static i := 'sc17'
        static o := 'sc18'
        static p := 'sc19'
        static lbracket := 'sc1A'
        static rbracket := 'sc1B'
        static enter := 'sc1C'
        static ctrl := 'sc1D'
        static control := 'sc1D'
        static lctrl := 'sc1D'
        static a := 'sc1E'
        static s := 'sc1F'
        static d := 'sc20'
        static f := 'sc21'
        static g := 'sc22'
        static h := 'sc23'
        static j := 'sc24'
        static k := 'sc25'
        static l := 'sc26'
        static semicolon := 'sc27'
        static quote := 'sc28'
        static backtick := 'sc29'
        static shift := 'sc2A'
        static lshift := 'sc2A'
        static backslash := 'sc2B'
        static z := 'sc2C'
        static x := 'sc2D'
        static c := 'sc2E'
        static v := 'sc2F'
        static b := 'sc30'
        static n := 'sc31'
        static m := 'sc32'
        static comma := 'sc33'
        static period := 'sc34'
        static slash := 'sc35'
        static rshift := 'sc36'
        static numpadMult := 'sc37'
        static alt := 'sc38'
        static lalt := 'sc38'
        static space := 'sc39'
        static capslock := 'sc3A'
        static f1 := 'sc3B'
        static f2 := 'sc3C'
        static f3 := 'sc3D'
        static f4 := 'sc3E'
        static f5 := 'sc3F'
        static f6 := 'sc40'
        static f7 := 'sc41'
        static f8 := 'sc42'
        static f9 := 'sc43'
        static f10 := 'sc44'
        static numlock := 'sc45'
        static scrolllock := 'sc46'
        static numpad7 := 'sc47'
        static numpad8 := 'sc48'
        static numpad9 := 'sc49'
        static numpadMinus := 'sc4A'
        static numpad4 := 'sc4B'
        static numpad5 := 'sc4C'
        static numpad6 := 'sc4D'
        static numpadPlus := 'sc4E'
        static numpad1 := 'sc4F'
        static numpad2 := 'sc50'
        static numpad3 := 'sc51'
        static numpad0 := 'sc52'
        static numpadDot := 'sc53'
        static f11 := 'sc57'
        static f12 := 'sc58'
        static rctrl := 'sc9D'
        static numpadDiv := 'sc135'
        static printscreen := 'sc137'
        static ralt := 'sc138'
        static pause := 'sc145'
        static home := 'sc147'
        static scUp := 'sc148'
        static SC_UP := 'sc148'
        static pageup := 'sc149'
        static left := 'sc14B'
        static right := 'sc14D'
        static end := 'sc14F'
        static scDown := 'sc150'
        static SC_DOWN := 'sc150'
        static pagedown := 'sc151'
        static insert := 'sc152'
        static delete := 'sc153'
        static win := 'sc15B'
        static lwin := 'sc15B'
        static rwin := 'sc15C'
        static appskey := 'sc15D'
        static menu := 'sc15D'
    }

    class vk extends key {
		static __New() {
            this.SelectAll    := '^' this.sc.a
            this.SelectHome   := '^' this.sc.Home
            this.SelectEnd    := '^' this.sc.End
            ; this.italics      := '{' this.CONTROL ' Down}' '{' this.KEY_I '}' '{' this.CONTROL ' Up}'
            this.italics      := '^' this.sc.i
            this.bold         := '^' this.sc.b
            this.underline    := '^' this.sc.u
            this.AlignLeft    := '^' this.sc.l
            this.AlignRight   := '^' this.sc.r
            this.AlignCenter  := '^' this.sc.e
            this.Justified    := '^' this.sc.j
            this.Cut          := '^' this.sc.x
            this.Copy         := '^' this.sc.c
            this.Paste        := '^' this.sc.v
            this.Undo         := '^' this.sc.z
            this.Redo         := '^' this.sc.y
            this.pastespecial := '^!' this.sc.v
            this.BulletedList := '+' this.sc.f12
            this.InsertTable  := '^' this.sc.F12
            this.SuperScript  := '^='
            this.SubScript    := '^+='
            this.Search       := this.sc.F5 ; 'F5'
            this.Find         := '^' this.sc.f
            this.Replace      := '^' this.sc.h
            this.CtrlEnter    := '^' this.sc.enter
            this.Save         := '^' this.sc.s
            this.Open         := '^' this.sc.o
        }
		static LBUTTON 				:= 'vk01' 			; Left mouse button
		static RBUTTON 				:= 'vk02' 			; Right mouse button
		static CANCEL 				:= 'vk03' 			; Control-break processing
		static MBUTTON 				:= 'vk04' 			; Middle mouse button
		static XBUTTON1 			:= 'vk05' 			; X1 mouse button
		static XBUTTON2 			:= 'vk06' 			; X2 mouse button
		static BACK 				:= 'vk08' 			; BACKSPACE key
		static TAB 					:= 'vk09' 			; TAB key
		static CLEAR 				:= 'vk0C' 			; CLEAR key
		static RETURN 				:= 'vkD' 			; ENTER key
		static ENTER 				:= 'vkD' 			; ENTER key
		static SHIFT 				:= 'vk10' 			; SHIFT key
		static CONTROL 				:= 'vk11' 			; CTRL key
		static MENU 				:= 'vk12' 			; ALT key
		static PAUSE 				:= 'vk13' 			; PAUSE key
		static CAPITAL 				:= 'vk14' 			; CAPS LOCK key
		static KANA 				:= 'vk15' 			; IME Kana mode
		static HANGUEL 				:= 'vk15' 			; IME Hanguel mode (maintained for compatibility; use HANGUL)
		static HANGUL 				:= 'vk15' 			; IME Hangul mode
		static IME_ON 				:= 'vk16' 			; IME On
		static JUNJA 				:= 'vk17' 			; IME Junja mode
		static FINAL 				:= 'vk18' 			; IME final mode
		static HANJA 				:= 'vk19' 			; IME Hanja mode
		static KANJI 				:= 'vk19' 			; IME Kanji mode
		static IME_OFF 				:= 'vk1A' 			; IME Off
		static ESCAPE 				:= 'vk1B' 			; ESC key
		static CONVERT 				:= 'vk1C' 			; IME convert
		static NONCONVERT 			:= 'vk1D' 			; IME nonconvert
		static ACCEPT 				:= 'vk1E' 			; IME accept
		static MODECHANGE 			:= 'vk1F' 			; IME mode change request
		static SPACE 				:= 'vk20' 			; SPACEBAR
		static PRIOR 				:= 'vk21' 			; PAGE UP key
		static NEXT 				:= 'vk22' 			; PAGE DOWN key
		static END 					:= 'vk23' 			; END key
		static HOME 				:= 'vk24' 			; HOME key
		static LEFT 				:= 'vk25' 			; LEFT ARROW key
		static UP 					:= 'vk26' 			; UP ARROW key
		static RIGHT 				:= 'vk27' 			; RIGHT ARROW key
		static DOWN 				:= 'vk28' 			; DOWN ARROW key
		static SELECT 				:= 'vk29' 			; SELECT key
		static PRINT 				:= 'vk2A' 			; PRINT key
		static EXECUTE 				:= 'vk2B' 			; EXECUTE key
		static SNAPSHOT 			:= 'vk2C' 			; PRINT SCREEN key
		static INSERT 				:= 'vk2D' 			; INS key
		static DELETE 				:= 'vk2E' 			; DEL key
		static HELP 				:= 'vk2F' 			; HELP key
		static KEY_0 				:= 'vk30' 			; 0 key
		static KEY_1 				:= 'vk31' 			; 1 key
		static KEY_2 				:= 'vk32' 			; 2 key
		static KEY_3 				:= 'vk33' 			; 3 key
		static KEY_4 				:= 'vk34' 			; 4 key
		static KEY_5 				:= 'vk35' 			; 5 key
		static KEY_6 				:= 'vk36' 			; 6 key
		static KEY_7 				:= 'vk37' 			; 7 key
		static KEY_8 				:= 'vk38' 			; 8 key
		static KEY_9 				:= 'vk39' 			; 9 key
		static KEY_A 				:= 'vk41' 			; A key
		static KEY_B 				:= 'vk42' 			; B key
		static KEY_C 				:= 'vk43' 			; C key
		static KEY_D 				:= 'vk44' 			; D key
		static KEY_E 				:= 'vk45' 			; E key
		static KEY_F 				:= 'vk46' 			; F key
		static KEY_G 				:= 'vk47' 			; G key
		static KEY_H 				:= 'vk48' 			; H key
		static KEY_I 				:= 'vk49' 			; I key
		static KEY_J 				:= 'vk4A' 			; J key
		static KEY_K 				:= 'vk4B' 			; K key
		static KEY_L 				:= 'vk4C' 			; L key
		static KEY_M 				:= 'vk4D' 			; M key
		static KEY_N 				:= 'vk4E' 			; N key
		static KEY_O 				:= 'vk4F' 			; O key
		static KEY_P 				:= 'vk50' 			; P key
		static KEY_Q 				:= 'vk51' 			; Q key
		static KEY_R 				:= 'vk52' 			; R key
		static KEY_S 				:= 'vk53' 			; S key
		static KEY_T 				:= 'vk54' 			; T key
		static KEY_U 				:= 'vk55' 			; U key
		static KEY_V 				:= 'vk56' 			; V key
		static KEY_W 				:= 'vk57' 			; W key
		static KEY_X 				:= 'vk58' 			; X key
		static KEY_Y 				:= 'vk59' 			; Y key
		static KEY_Z 				:= 'vk5A' 			; Z key
		static LWIN 				:= 'vk5B' 			; Left Windows key
		static RWIN 				:= 'vk5C' 			; Right Windows key
		static APPS 				:= 'vk5D' 			; Applications key
		static SLEEP 				:= 'vk5F' 			; Computer Sleep key
		static NUMPAD0 				:= 'vk60' 			; Numeric keypad 0 key
		static NUMPAD1 				:= 'vk61' 			; Numeric keypad 1 key
		static NUMPAD2 				:= 'vk62' 			; Numeric keypad 2 key
		static NUMPAD3 				:= 'vk63' 			; Numeric keypad 3 key
		static NUMPAD4 				:= 'vk64' 			; Numeric keypad 4 key
		static NUMPAD5 				:= 'vk65' 			; Numeric keypad 5 key
		static NUMPAD6 				:= 'vk66' 			; Numeric keypad 6 key
		static NUMPAD7 				:= 'vk67' 			; Numeric keypad 7 key
		static NUMPAD8 				:= 'vk68' 			; Numeric keypad 8 key
		static NUMPAD9 				:= 'vk69' 			; Numeric keypad 9 key
		static MULTIPLY 			:= 'vk6A' 			; Multiply key
		static ADD 					:= 'vk6B' 			; Add key
		static SEPARATOR 			:= 'vk6C' 			; Separator key
		static SUBTRACT 			:= 'vk6D' 			; Subtract key
		static DECIMAL 				:= 'vk6E' 			; Decimal key
		static DIVIDE 				:= 'vk6F' 			; Divide key
		static F1 					:= 'vk70' 			; F1 key
		static F2 					:= 'vk71' 			; F2 key
		static F3 					:= 'vk72' 			; F3 key
		static F4 					:= 'vk73' 			; F4 key
		static F5 					:= 'vk74' 			; F5 key
		static F6 					:= 'vk75' 			; F6 key
		static F7 					:= 'vk76' 			; F7 key
		static F8 					:= 'vk77' 			; F8 key
		static F9 					:= 'vk78' 			; F9 key
		static F10 					:= 'vk79' 			; F10 key
		static F11 					:= 'vk7A' 			; F11 key
		static F12 					:= 'vk7B' 			; F12 key
		static F13 					:= 'vk7C' 			; F13 key
		static F14 					:= 'vk7D' 			; F14 key
		static F15 					:= 'vk7E' 			; F15 key
		static F16 					:= 'vk7F' 			; F16 key
		static F17 					:= 'vk80' 			; F17 key
		static F18 					:= 'vk81' 			; F18 key
		static F19 					:= 'vk82' 			; F19 key
		static F20 					:= 'vk83' 			; F20 key
		static F21 					:= 'vk84' 			; F21 key
		static F22 					:= 'vk85' 			; F22 key
		static F23 					:= 'vk86' 			; F23 key
		static F24 					:= 'vk87' 			; F24 key
		static NUMLOCK 				:= 'vk90' 			; NUM LOCK key
		static SCROLL 				:= 'vk91' 			; SCROLL LOCK key
		static LSHIFT 				:= 'vkA0' 			; Left SHIFT key
		static RSHIFT 				:= 'vkA1' 			; Right SHIFT key
		static LCONTROL 			:= 'vkA2' 			; Left CONTROL key
		static RCONTROL 			:= 'vkA3' 			; Right CONTROL key
		static LMENU 				:= 'vkA4' 			; Left MENU key
		static RMENU 				:= 'vkA5' 			; Right MENU key
		static BROWSER_BACK 		:= 'vkA6' 			; Browser Back key
		static BROWSER_FORWARD 		:= 'vkA7' 			; Browser Forward key
		static BROWSER_REFRESH 		:= 'vkA8' 			; Browser Refresh key
		static BROWSER_STOP 		:= 'vkA9' 			; Browser Stop key
		static BROWSER_SEARCH 		:= 'vkAA' 			; Browser Search key
		static BROWSER_FAVORITES 	:= 'vkAB' 			; Browser Favorites key
		static BROWSER_HOME 		:= 'vkAC' 			; Browser Start and Home key
		static VOLUME_MUTE 			:= 'vkAD' 			; Volume Mute key
		static VOLUME_DOWN 			:= 'vkAE' 			; Volume Down key
		static VOLUME_UP 			:= 'vkAF' 			; Volume Up key
		static MEDIA_NEXT_TRACK 	:= 'vkB0' 			; Next Track key
		static MEDIA_PREV_TRACK 	:= 'vkB1' 			; Previous Track key
		static MEDIA_STOP 			:= 'vkB2' 			; Stop Media key
		static MEDIA_PLAY_PAUSE 	:= 'vkB3' 			; Play/Pause Media key
		static LAUNCH_MAIL 			:= 'vkB4' 			; Start Mail key
		static LAUNCH_MEDIA_SELECT 	:= 'vkB5' 			; Select Media key
		static LAUNCH_APP1 			:= 'vkB6' 			; Start Application 1 key
		static LAUNCH_APP2 			:= 'vkB7' 			; Start Application 2 key
		static OEM_1 				:= 'vkBA' 			; Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the ';:' key
		static OEM_PLUS     		:= 'vkBB' 			; For any country/region, the '+' key 
		static OEM_EQUAL    		:= 'vkBB' 			; For any country/region, the '=' key 
		static OEM_COMMA    		:= 'vkBC' 			; For any country/region, the ',' key
		static OEM_MINUS    		:= 'vkBD' 			; For any country/region, the '-' key
		static OEM_PERIOD   		:= 'vkBE' 			; For any country/region, the '.' key
		static OEM_2 				:= 'vkBF' 			; Used for miscellaneous characters; it can vary by keyboard. US kybd, the '/?' key
		static OEM_3 				:= 'vkC0' 			; Used for miscellaneous characters; it can vary by keyboard. US kybd, the '`~' key
		static OEM_4 				:= 'vkDB' 			; Used for miscellaneous characters; it can vary by keyboard. US kybd, the '[{' key
		static OEM_5 				:= 'vkDC' 			; Used for miscellaneous characters; it can vary by keyboard. US kybd, the '\|' key
		static OEM_6 				:= 'vkDD' 			; Used for miscellaneous characters; it can vary by keyboard. US kybd, the ']}' key
		static OEM_7 				:= 'vkDE' 			; Used for miscellaneous characters; it can vary by keyboard. US kybd, the 'single-quote/double-quote' key
		static OEM_8 				:= 'vkDF' 			; Used for miscellaneous characters; it can vary by keyboard.
		static OEM_102 				:= 'vkE2' 			; Either the angle bracket key or the backslash key on the RT 102-key keyboard
		static PROCESSKEY 			:= 'vkE5' 			; IME PROCESS key
		static PACKET 				:= 'vkE7' 			; Used to pass Unicode characters as if they were keystrokes
		static ATTN 				:= 'vkF6' 			; Attn key
		static CRSEL 				:= 'vkF7' 			; CrSel key
		static EXSEL 				:= 'vkF8' 			; ExSel key
		static EREOF 				:= 'vkF9' 			; Erase EOF key
		static PLAY 				:= 'vkFA' 			; Play key
		static ZOOM 				:= 'vkFB' 			; Zoom key
		static NONAME 				:= 'vkFC' 			; Reserved
		static PA1 					:= 'vkFD' 			; PA1 key
		static OEM_CLEAR 			:= 'vkFE' 			; Clear key
        ; ---------------------------------------------------------------------------
        ; static SelectAll    := this.CONTROL ' & ' this.KEY_A
        ; static SelectHome   := this.CONTROL ' & ' this.HOME
        ; static SelectEnd    := this.CONTROL ' & ' this.END
        ; static italics		:= this.CONTROL ' & ' this.KEY_I
        ; static bold         := this.CONTROL ' & ' this.KEY_B
        ; static underline    := this.CONTROL ' & ' this.KEY_U
        ; static AlignLeft    := this.CONTROL ' & ' this.KEY_L
        ; static AlignRight   := this.CONTROL ' & ' this.KEY_R
        ; static AlignCenter  := this.CONTROL ' & ' this.KEY_E
        ; static Justified    := this.CONTROL ' & ' this.KEY_J
        ; static Cut          := this.CONTROL ' & ' this.KEY_X
        ; static Copy         := this.CONTROL ' & ' this.KEY_C
        ; static Paste        := this.CONTROL ' & ' this.KEY_V
        ; static Undo         := this.CONTROL ' & ' this.KEY_Z
        ; static Redo         := this.CONTROL ' & ' this.KEY_Y
        ; ; static pastespecial := '^!v'
        ; static SelectAll    := key.translateToVK('^a')
        ; static SelectHome   := key.translateToVK('^HOME')
        ; static SelectEnd    := key.translateToVK('^END')
        ; static italics		:= key.translateToVK('^i')
        ; static italics		:= '{' this.CONTROL ' Down}' '{' this.KEY_I '}' '{' this.CONTROL ' Up}'
        ; static bold         := key.translateToVK('^b')
        ; static underline    := key.translateToVK('^u')
        ; static AlignLeft    := key.translateToVK('^l')
        ; static AlignRight   := key.translateToVK('^r')
        ; static AlignCenter  := key.translateToVK('^e')
        ; static Justified    := key.translateToVK('^j')
        ; static Cut          := key.translateToVK('^x')
        ; static Copy         := key.translateToVK('^c')
        ; static Paste        := key.translateToVK('^v')
        ; static Undo         := key.translateToVK('^z')
        ; static Redo         := key.translateToVK('^y')
        ; static pastespecial := key.translateToVK('^!v')
        ; static BulletedList := key.translateToVK('+F12')
        ; static InsertTable  := key.translateToVK('^F12')
        ; static SuperScript  := key.translateToVK('^=')
        ; static SubScript    := key.translateToVK('^+=')
        ; static Search       := key.translateToVK('F5')
        ; static Find         := key.translateToVK('^f')
        ; static Replace      := key.translateToVK('^h')
        ; static CtrlEnter    := key.translateToVK('^Enter')
        ; static Save         := key.translateToVK('^s')
        ; static Open         := key.translateToVK('^o')

    }

	Class hotkeySC extends key {
		static Find 	:= '^' this.sc.f
		static Search 	:= this.sc.f5
		static Replace 	:= '^' this.sc.h
	}
	Class hotkeyVK extends key {
		static Find 	:= '^' this.vk.KEY_F
		static Search 	:= this.vk.F5
		static Replace 	:= '^' this.vk.KEY_H
	}

	/**
	 * @example Parse key string into an array of individual keys
	 * @param {String} keys 
	 * @returns {Array} 
	 */
    ; static parseKeys(keys) {
    ;     keyArray := [], buffer := ''
    ;     specialKeys := ['LWin', 'RWin', 'LAlt', 'RAlt', 'LCtrl', 'RCtrl', 'LShift', 'RShift', 
    ;                     'CapsLock', 'Tab', 'Enter', 'Esc', 'BS', 'Del', 'Ins', 'Home', 'End', 
    ;                     'PgUp', 'PgDn', 'Up', 'Down', 'Left', 'Right', 
    ;                     'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12']

    ;     Loop Parse, keys {
    ;         if (A_LoopField ~= '[+!^#]' || specialKeys.HasOwnProp(A_LoopField)) {
    ;             if (buffer) {
    ;                 keyArray.Push(buffer)
    ;                 buffer := ''
    ;             }
    ;             keyArray.Push(A_LoopField)
    ;         } else {
    ;             buffer .= A_LoopField
    ;         }
    ;     }
    ;     if (buffer) {
    ;         keyArray.Push(buffer)
    ;     }
    ;     return keyArray
    ; }

    ; static parseKeys(keys) {
    ;     keyArray := [], buffer := ''
    ;     specialKeys := ["LWin", "RWin", "LAlt", "RAlt", "LCtrl", "RCtrl", "LShift", "RShift", 
    ;                     "CapsLock", "Tab", "Enter", "Esc", "BS", "Del", "Ins", "Home", "End", 
    ;                     "PgUp", "PgDn", "Up", "Down", "Left", "Right", 
    ;                     "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12"]

    ;     Loop Parse, keys {
    ;         if (A_LoopField ~= "[+!^#]") {
    ;             if (buffer) {
    ;                 keyArray.Push(buffer)
    ;                 buffer := ""
    ;             }
    ;             keyArray.Push(A_LoopField)
    ;         } else if (specialKeys.HasOwnProp(A_LoopField)) {
    ;             if (buffer) {
    ;                 keyArray.Push(buffer)
    ;                 buffer := ""
    ;             }
    ;             keyArray.Push(A_LoopField)
    ;         } else {
    ;             buffer .= A_LoopField
    ;         }
    ;     }
    ;     if (buffer) {
    ;         keyArray.Push(buffer)
    ;     }
    ;     return keyArray
    ; }


	; static parseKeys(keys) {
	; 	keyArray := [], buffer := '', currentChar := ''
	; 	specialKeys := Map(
	; 		'lwin', 'LWin', 'rwin', 'RWin', 'lalt', 'LAlt', 'ralt', 'RAlt', 
	; 		'lctrl', 'LCtrl', 'rctrl', 'RCtrl', 'lshift', 'LShift', 'rshift', 'RShift', 
	; 		'capslock', 'CapsLock', 'tab', 'Tab', 'enter', 'Enter', 'esc', 'Esc', 
	; 		'bs', 'BS', 'del', 'Del', 'ins', 'Ins', 'home', 'Home', 'end', 'End', 
	; 		'pgup', 'PgUp', 'pgdn', 'PgDn', 'up', 'Up', 'down', 'Down', 'left', 'Left', 'right', 'Right', 
	; 		'f1', 'F1', 'f2', 'F2', 'f3', 'F3', 'f4', 'F4', 'f5', 'F5', 'f6', 'F6', 
	; 		'f7', 'F7', 'f8', 'F8', 'f9', 'F9', 'f10', 'F10', 'f11', 'F11', 'f12', 'F12'
	; 	)
	; 	Loop Parse, keys {
	; 		currentChar := A_LoopField
	; 		if (currentChar ~= '[+!^#]') {
	; 			if (buffer) {
	; 				keyArray.Push(specialKeys.Has(StrLower(buffer)) ? specialKeys[StrLower(buffer)] : buffer)
	; 				buffer := ''
	; 			}
	; 			keyArray.Push(currentChar)
	; 		} else if (buffer && specialKeys.Has(StrLower(buffer . currentChar))) {
	; 			buffer .= currentChar
	; 		} else if (buffer) {
	; 			keyArray.Push(specialKeys.Has(StrLower(buffer)) ? specialKeys[StrLower(buffer)] : buffer)
	; 			buffer := currentChar
	; 		} else {
	; 			buffer := currentChar
	; 		}
	; 	}
	; 	if (buffer) {
	; 		keyArray.Push(specialKeys.Has(StrLower(buffer)) ? specialKeys[StrLower(buffer)] : buffer)
	; 	}
	; 	return keyArray
	; }

	/**
	 * @example Check if a key is in VK format
	 * @param {String} key 
	 * @returns {Boolean} 
	 */
	; static isVKFormat(key) {
	; 	; return RegExMatch(key, 'i)^\{{0,1}vk[0-9A-F]{2}\}{0,1}$')
	; 	return RegExMatch(key, 'i)(\{{0,1}vk[\w\d]+\}{0,1})')
	; }
	; static isVKFormat(key) {
	; 	if (Type(key) == "Array") {
	; 		return key.Has((k) => RegExMatch(k, 'i)(\{{0,1}vk[\w\d]+\}{0,1})'))
	; 	}
	; 	return RegExMatch(key, 'i)(\{{0,1}vk[\w\d]+\}{0,1})')
	; }

	; static isVKFormat(key) {
    ;     return RegExMatch(key, 'i)^(\{vk[\w\d]+\}|\{?vk[\w\d]+\}?)+$')
    ; }

	static isSCFormat(key) {
		return RegExMatch(key, "i)^\{sc\w+\}$")
	}

	static isVKSCFormat(key) {
		return RegExMatch(key, "i)^\{VK \w+ sc\w+\}$")
	}

	/**
	 * @example Convert keys to Virtual Key
	 * @param {String} keys 
	 * @returns {String} 
	 */

	; static translateToVK(keys := '') {
    ;     static specialKeys := Map(
    ;         'Enter', 'vkD', 'Home', 'vk24', 'End', 'vk23',
    ;         'PgUp', 'vk21', 'PgDn', 'vk22', 'Ins', 'vk2D',
    ;         'Del', 'vk2E', 'Space', 'vk20', 'Tab', 'vk9',
    ;         'Backspace', 'vk8', 'Escape', 'vk1B'
    ;     )

    ;     if (this.isVKFormat(keys)) {
    ;         return keys
    ;     }

    ;     vkString := '', keyArray := this.parseKeys(keys)

    ;     for keyName in keyArray {
    ;         if (keyName ~= '[+!^#]') {
    ;             vkString .= keyName
    ;         } else {
    ;             switch true {
    ;                 case RegExMatch(keyName, '^F(\d+)$', &match):
    ;                     fNum := Integer(match[1])
    ;                     if (fNum >= 1 && fNum <= 24) {
    ;                         vkString .= Format('vk{:X}', 111 + fNum)
    ;                     } else {
    ;                         vkString .= keyName
    ;                     }
    ;                 case specialKeys.Has(keyName):
    ;                     vkString .= specialKeys[keyName]
    ;                 default:
    ;                     if (StrLen(keyName) = 1 && keyName ~= '[\w]+') {
    ;                         vkString .= Format('vk{:X}', Ord(StrUpper(keyName)))
    ;                     } else if (ObjHasOwnProp(this.vk, keyName)) {
    ;                         vkCode := this.vk.%keyName%
    ;                         vkString .= (Type(vkCode) = 'String' && SubStr(vkCode, 1, 2) = 'vk') 
    ;                             ? vkCode 
    ;                             : 'vk' . Format('{:02X}', vkCode)
    ;                     } else {
    ;                         vkString .= keyName
    ;                     }
    ;             }
    ;         }
    ;     }
    ;     return vkString
    ; }

	; static translateToVK(keys := '') {
	; 	vkCode := keyName := vkString := '', keyArray := []
	; 	if (this.isVKFormat(keys)) {
	; 		return keys
	; 	}
	; 	else if (Type(keys) == "Array") {
	; 		return keys.Map((k) => this.translateToVK(k))
	; 	}
	
	; 	keyArray := this.parseKeys(keys)
	; 	specialKeys := Map(
	; 		'Enter', 'vkD',
	; 		'Home', 'vk24',
	; 		'End', 'vk23',
	; 		'PgUp', 'vk21',
	; 		'PgDn', 'vk22',
	; 		'Ins', 'vk2D',
	; 		'Del', 'vk2E'
	; 	)
	
	; 	for keyName in keyArray {
	; 		if (keyName ~= '[+!^#]') {
	; 			vkString .= keyName
	; 		} else {
	; 			switch true {
	; 				case RegExMatch(keyName, '^F(\d+)$', &match):
	; 					fNum := Integer(match[1])
	; 					if (fNum >= 1 && fNum <= 24) {
	; 						vkCode := Format('vk{:X}', 111 + fNum)
	; 						vkString .= vkCode
	; 					} else {
	; 						vkString .= keyName
	; 					}
	; 				case specialKeys.Has(keyName):
	; 					vkString .= specialKeys[keyName]
	; 				default:
	; 					if (StrLen(keyName) = 1 && keyName ~= '[\w]+') {
	; 						vkCode := Format('vk{:X}', Ord(StrUpper(keyName)))
	; 						vkString .= vkCode
	; 					} else if (ObjHasOwnProp(this.vk, keyName)) {
	; 						vkCode := this.vk.%keyName%
	; 						if (Type(vkCode) = 'String') {
	; 							if (SubStr(vkCode, 1, 2) = 'vk') {
	; 								vkString .= vkCode
	; 							} else {
	; 								vkString .= this.translateToVK(vkCode)
	; 							}
	; 						} else {
	; 							vkString .= 'vk' . Format('{:02X}', vkCode)
	; 						}
	; 					} else {
	; 						vkString .= keyName
	; 					}
	; 			}
	; 		}
	; 	}
	; 	; OutputDebug(vkString '`n')
	; 	return vkString
	; }

	; static SendVK(keys) {
	; 	vkString := this.translateToVK(keys)
	; 	Send(vkString)
	; }

    static SendVK(keys) {
        vkString := this.translateToVK(keys)
        Send(vkString)
    }

    static translateToVK(keys := '') {
        static specialKeys := Map(
            'Space', 'vk20',
            'Enter', 'vkD',
            'Tab', 'vk9',
            'Esc', 'vk1B',
            'Backspace', 'vk8'
        )

        if (this.isVKFormat(keys)) {
            return keys
        }

        vkString := ''
        keyArray := this.parseKeys(keys)

        for keyName in keyArray {
            if (keyName ~= '[+!^#]') {
                vkString .= keyName
            } else if (SubStr(keyName, 1, 1) = '{' && SubStr(keyName, -1) = '}') {
                innerKey := SubStr(keyName, 2, -2)
                if (specialKeys.Has(innerKey)) {
                    vkString .= '{' . specialKeys[innerKey] . '}'
                } else {
                    vkString .= '{' . this.translateToVK(innerKey) . '}'
                }
            } else if (specialKeys.Has(keyName)) {
                vkString .= '{' . specialKeys[keyName] . '}'
            } else if (StrLen(keyName) = 1) {
                vkString .= '{' . Format('vk{:X}', Ord(StrUpper(keyName))) . '}'
            } else {
                vkString .= keyName  ; Keep as is if not recognized
            }
        }
        return vkString
    }

    static isVKFormat(key) {
        return RegExMatch(key, 'i)^(\{vk[\w\d]+\}|[+!^#]|\{.+\})+$')
    }

    static parseKeys(keys) {
        keyArray := []
        tempKey := ''
        inBraces := false

        Loop Parse, keys {
            if (A_LoopField = '{') {
                if (tempKey) {
                    keyArray.Push(tempKey)
                    tempKey := ''
                }
                inBraces := true
                tempKey .= A_LoopField
            } else if (A_LoopField = '}') {
                tempKey .= A_LoopField
                inBraces := false
                keyArray.Push(tempKey)
                tempKey := ''
            } else if (inBraces) {
                tempKey .= A_LoopField
            } else if (A_LoopField ~= '[+!^#]') {
                if (tempKey) {
                    keyArray.Push(tempKey)
                    tempKey := ''
                }
                keyArray.Push(A_LoopField)
            } else {
                tempKey .= A_LoopField
            }
        }

        if (tempKey) {
            keyArray.Push(tempKey)
        }

        return keyArray
    }

	static translateToSC(keys) {
		if (this.isSCFormat(keys)){
			return keys
		}

		scString := ""
		keyArray := StrSplit(keys, "+")
		for keyName in keyArray {
			if (this.isSCFormat(keyName))
				scString .= keyName
			else if (ObjHasOwnProp(this.sc, keyName))
				scString .= "{" . this.sc.%keyName% . "}"
			else
				scString .= keyName  ; Fallback to original key name if not found
		}
		return scString
	}
	/**
	 * @example Convert keys to Scan Code
	 * @param keys 
	 * @returns {String} 
	 */
	static SCConvert(keys) 	=> this.translateToSC(keys)
	static xSC(keys) 		=> this.translateToSC(keys)
	static SCx(keys) 		=> this.translateToSC(keys)

	static translateToVKSC(keys) {
		if (this.isVKSCFormat(keys))
			return keys

		vkscString := ""
		keyArray := StrSplit(keys, "+")
		for keyName in keyArray {
			if (this.isVKSCFormat(keyName))
				vkscString .= keyName
			else if (ObjHasOwnProp(this.vk, keyName) && ObjHasOwnProp(this.sc, keyName))
				; vkscString .= "{VK " . Format("0x{:X}", this.vk.%keyName%) . " " . this.sc.%keyName% . "}"
				vkscString .= "{VK " . Format("0x{:X}", this.vk.%keyName%) this.sc.%keyName% . "}"
			else
				vkscString .= keyName  ; Fallback to original key name if not found
		}
		return vkscString
	}

	static translateToVKCodes(keys) {
		vkCodes := []
		keyArray := StrSplit(keys, "+")
		for keyName in keyArray {
			if (RegExMatch(keyName, "i)^VK_(\w+)$", &match))
				vkCodes.SafePush(this.vk.%match[1]%)
			else if (ObjHasOwnProp(this.vk, keyName))
				vkCodes.SafePush(this.vk.%keyName%)
			else if (RegExMatch(keyName, "i)^0x[\da-f]+$"))
				vkCodes.SafePush(Integer(keyName))
		}
		return vkCodes
	}

	static translateToSCCodes(keys) {
		scCodes := []
		keyArray := StrSplit(keys, "+& ")
		for keyName in keyArray {
			if (RegExMatch(keyName, "i)^sc(\w+)$", &match))
				scCodes.SafePush(Integer("0x" . match[1]))
			else if (ObjHasOwnProp(this.sc, keyName))
				scCodes.SafePush(Integer("0x" . SubStr(this.sc.%keyName%, 3)))
			else if (RegExMatch(keyName, "i)^0x[\da-f]+$"))
				scCodes.SafePush(Integer(keyName))
		}
		return scCodes
	}

	static translateToVKSCCodes(keys) {
		vkscCodes := Map()
		keyArray := StrSplit(keys, "+& ")
		for keyName in keyArray {
			if (RegExMatch(keyName, "i)^VK_(\w+)$", &matchVK) && RegExMatch(keyName, "i)^sc(\w+)$", &matchSC))
				vkscCodes[key.vk.%matchVK[1]%] := Integer("0x" . matchSC[1])
			else if (ObjHasOwnProp(key.vk, keyName) && ObjHasOwnProp(key.sc, keyName))
				vkscCodes[key.vk.%keyName%] := Integer("0x" . SubStr(key.sc.%keyName%, 3))
			else if (RegExMatch(keyName, "i)^0x[\da-f]+$"))
				vkscCodes[Integer(keyName)] := 0  ; Set SC to 0 if only VK is provided
		}
		return vkscCodes
	}

	static Send(keys) => key.SendVK(keys)

	static cSend(keys) => key.ClipSendVK(keys)

	; static SendVK(keys) {
	; 	vkString := key.translateToVK(keys)
	; 	WinActive('ahk_exe Teams.exe') ? Send(vkString) : ClipSend(vkString)
	; 	; ClipSend(vkString)
	; }

	static sSend(keys) {

		DetectHiddenText(1)
		DetectHiddenWindows(1)
		SendMode('Event')
		vkString := key.translateToVK(keys)
		; Send(vkString)
		Send(vkString)
		; AE.Timer(-300)
		; AE.rSM_BISL(sm)
	}
	static ClipSendVK(keys) {
		vkString := key.translateToVK(keys)
		; Send(vkString)
		; vkString.cSend()
		Clip.Send(vkString)
		; A_Clipboard := vkString
		; Sleep(300)
		; Send(key.paste)
	}

	static ControlSendVK(keys, control:=ControlGetFocus('A'), title:='A') {
		vkString := this.translateToVK(keys)
		ControlSend(vkString, control, title)
	}

	static SendSC(keys) {
		scString := this.translateToSC(keys)
		Send(scString)
	}

	static SendVKSC(keys) {
		vkscString := this.translateToVKSC(keys)
		Send(vkscString)
	}

	static SendVKDll(keys) {
		vkCodes := this.translateToVKCodes(keys)
		for vkCode in vkCodes {
			DllCall("user32.dll\keybd_event", "UChar", vkCode, "UChar", 0, "UInt", 0, "Ptr", 0)
			DllCall("user32.dll\keybd_event", "UChar", vkCode, "UChar", 0, "UInt", 2, "Ptr", 0)
		}
	}

	static SendSCDll(keys) {
		scCodes := this.translateToSCCodes(keys)
		for scCode in scCodes {
			DllCall("user32.dll\keybd_event", "UChar", 0, "UChar", scCode, "UInt", 8, "Ptr", 0)
			DllCall("user32.dll\keybd_event", "UChar", 0, "UChar", scCode, "UInt", 10, "Ptr", 0)
		}
	}

	static SendVKSCDll(keys) {
		vkscCodes := this.translateToVKSCCodes(keys)
		for vkCode, scCode in vkscCodes {
			DllCall("user32.dll\keybd_event", "UChar", vkCode, "UChar", scCode, "UInt", 8, "Ptr", 0)
			DllCall("user32.dll\keybd_event", "UChar", vkCode, "UChar", scCode, "UInt", 10, "Ptr", 0)
		}
	}

	;! doesn't work in either form
	static dllpaste => (*) => DllCall("user32.dll\keybd_event"
									; , "char", 0x56  ; 'V' key
									, "char", WM_PASTE := 0x0302
									, "char", 0
									, "uint", 0x0001 | 0x0002  ; KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP
    								, "ptr", 0)

    Class vksc extends key{
        static italics := this.vk.CONTROL ' & ' this.sc.i
        static BulletedList := this.vk.SHIFT ' & ' this.sc.f12
    }
    ; static down := " down"
    ; static up := " up"
    static lb := "{"
    static rb := "}"
    static shift        := this.lb this.sc.shift this.rb
    static shiftup      := this.lb this.sc.shift this.syntax.up this.rb
    static shiftdown    := this.lb this.sc.shift this.syntax.down this.rb
    static lshift       := this.lb this.sc.lshift this.rb
    static lshiftup     := this.lb this.sc.lshift this.syntax.up this.rb
    static lshiftdown   := this.lb this.sc.lshift this.syntax.down this.rb
    static rshift       := this.lb this.sc.rshift this.rb
    static rshiftup     := this.lb this.sc.rshift this.syntax.up this.rb
    static rshiftdown   := this.lb this.sc.rshift this.syntax.down this.rb

    static ctrl         := this.lb this.sc.ctrl this.rb
    static control      := this.lb this.sc.ctrl this.rb
    static controldown  := this.lb this.sc.ctrl this.syntax.down this.rb
    static ctrldown     := this.lb this.sc.ctrl this.syntax.down this.rb
    static controlup    := this.lb this.sc.ctrl this.syntax.up this.rb
    static ctrlup       := this.lb this.sc.ctrl this.syntax.up this.rb
    static lctrl        := this.lb this.sc.lctrl this.rb
    static lctrldown    := this.lb this.sc.lctrl this.syntax.down this.rb
    static lctrlup      := this.lb this.sc.lctrl this.syntax.up this.rb
    static rctrl        := this.lb this.sc.rctrl this.rb
    static rctrldown    := this.lb this.sc.rctrl this.syntax.down this.rb
    static rctrlup      := this.lb this.sc.rctrl this.syntax.up this.rb

    static alt          := this.lb this.sc.alt this.rb
    static altup        := this.lb this.sc.alt this.syntax.up this.rb
    static altdown      := this.lb this.sc.alt this.syntax.down this.rb
    static lalt         := this.lb this.sc.lalt this.rb
    static laltup       := this.lb this.sc.lalt this.syntax.up this.rb
    static laltdown     := this.lb this.sc.lalt this.syntax.down this.rb
    static ralt         := this.lb this.sc.ralt this.rb
    static raltup       := this.lb this.sc.ralt this.syntax.up this.rb
    static raltdown     := this.lb this.sc.ralt this.syntax.down this.rb

    static win          := this.lb this.sc.win this.rb
    static winup        := this.lb this.sc.win this.syntax.up this.rb
    static windown      := this.lb this.sc.win this.syntax.down this.rb
    static lwin         := this.lb this.sc.lwin this.rb
    static lwinup       := this.lb this.sc.lwin this.syntax.up this.rb
    static lwindown     := this.lb this.sc.lwin this.syntax.down this.rb
    static rwin         := this.lb this.sc.rwin this.rb
    static rwinup       := this.lb this.sc.rwin this.syntax.up this.rb
    static rwindown     := this.lb this.sc.rwin this.syntax.down this.rb

    ; Define individual key properties for all keys in sc class
    static esc := this.lb this.sc.esc this.rb
    static escup := this.lb this.sc.esc this.syntax.up this.rb
    static escdown := this.lb this.sc.esc this.syntax.down this.rb

    static 1 := this.lb this.sc.1 this.rb
    static 1up := this.lb this.sc.1 this.syntax.up this.rb
    static 1down := this.lb this.sc.1 this.syntax.down this.rb

    static 2 := this.lb this.sc.2 this.rb
    static 2up := this.lb this.sc.2 this.syntax.up this.rb
    static 2down := this.lb this.sc.2 this.syntax.down this.rb

    static 3 := this.lb this.sc.3 this.rb
    static 3up := this.lb this.sc.3 this.syntax.up this.rb
    static 3down := this.lb this.sc.3 this.syntax.down this.rb

    static 4 := this.lb this.sc.4 this.rb
    static 4up := this.lb this.sc.4 this.syntax.up this.rb
    static 4down := this.lb this.sc.4 this.syntax.down this.rb

    static 5 := this.lb this.sc.5 this.rb
    static 5up := this.lb this.sc.5 this.syntax.up this.rb
    static 5down := this.lb this.sc.5 this.syntax.down this.rb

    static 6 := this.lb this.sc.6 this.rb
    static 6up := this.lb this.sc.6 this.syntax.up this.rb
    static 6down := this.lb this.sc.6 this.syntax.down this.rb

    static 7 := this.lb this.sc.7 this.rb
    static 7up := this.lb this.sc.7 this.syntax.up this.rb
    static 7down := this.lb this.sc.7 this.syntax.down this.rb

    static 8 := this.lb this.sc.8 this.rb
    static 8up := this.lb this.sc.8 this.syntax.up this.rb
    static 8down := this.lb this.sc.8 this.syntax.down this.rb

    static 9 := this.lb this.sc.9 this.rb
    static 9up := this.lb this.sc.9 this.syntax.up this.rb
    static 9down := this.lb this.sc.9 this.syntax.down this.rb

    static 0 := this.lb this.sc.0 this.rb
    static 0up := this.lb this.sc.0 this.syntax.up this.rb
    static 0down := this.lb this.sc.0 this.syntax.down this.rb

    static minus := this.lb this.sc.minus this.rb
    static minusup := this.lb this.sc.minus this.syntax.up this.rb
    static minusdown := this.lb this.sc.minus this.syntax.down this.rb

    static equal := this.lb this.sc.equal this.rb
    static equalup := this.lb this.sc.equal this.syntax.up this.rb
    static equaldown := this.lb this.sc.equal this.syntax.down this.rb

    static backspace := this.lb this.sc.backspace this.rb
    static backspaceup := this.lb this.sc.backspace this.syntax.up this.rb
    static backspacedown := this.lb this.sc.backspace this.syntax.down this.rb

    static tab := this.lb this.sc.tab this.rb
    static tabup := this.lb this.sc.tab this.syntax.up this.rb
    static tabdown := this.lb this.sc.tab this.syntax.down this.rb

    static q := this.lb this.sc.q this.rb
    static qup := this.lb this.sc.q this.syntax.up this.rb
    static qdown := this.lb this.sc.q this.syntax.down this.rb

    static w := this.lb this.sc.w this.rb
    static wup := this.lb this.sc.w this.syntax.up this.rb
    static wdown := this.lb this.sc.w this.syntax.down this.rb

    static e := this.lb this.sc.e this.rb
    static eup := this.lb this.sc.e this.syntax.up this.rb
    static edown := this.lb this.sc.e this.syntax.down this.rb

    static r := this.lb this.sc.r this.rb
    static rup := this.lb this.sc.r this.syntax.up this.rb
    static rdown := this.lb this.sc.r this.syntax.down this.rb

    static t := this.lb this.sc.t this.rb
    static tup := this.lb this.sc.t this.syntax.up this.rb
    static tdown := this.lb this.sc.t this.syntax.down this.rb

    static y := this.lb this.sc.y this.rb
    static yup := this.lb this.sc.y this.syntax.up this.rb
    static ydown := this.lb this.sc.y this.syntax.down this.rb

    static u := this.lb this.sc.u this.rb
    static uup := this.lb this.sc.u this.syntax.up this.rb
    static udown := this.lb this.sc.u this.syntax.down this.rb

    static i := this.lb this.sc.i this.rb
    static iup := this.lb this.sc.i this.syntax.up this.rb
    static idown := this.lb this.sc.i this.syntax.down this.rb

    static o := this.lb this.sc.o this.rb
    static oup := this.lb this.sc.o this.syntax.up this.rb
    static odown := this.lb this.sc.o this.syntax.down this.rb

    static p := this.lb this.sc.p this.rb
    static pup := this.lb this.sc.p this.syntax.up this.rb
    static pdown := this.lb this.sc.p this.syntax.down this.rb

    static lbracket := this.lb this.sc.lbracket this.rb
    static lbracketup := this.lb this.sc.lbracket this.syntax.up this.rb
    static lbracketdown := this.lb this.sc.lbracket this.syntax.down this.rb

    static rbracket := this.lb this.sc.rbracket this.rb
    static rbracketup := this.lb this.sc.rbracket this.syntax.up this.rb
    static rbracketdown := this.lb this.sc.rbracket this.syntax.down this.rb

    static enter := this.lb this.sc.enter this.rb
    static enterup := this.lb this.sc.enter this.syntax.up this.rb
    static enterdown := this.lb this.sc.enter this.syntax.down this.rb

    static a := this.lb this.sc.a this.rb
    static aup := this.lb this.sc.a this.syntax.up this.rb
    static adown := this.lb this.sc.a this.syntax.down this.rb

    static s := this.lb this.sc.s this.rb
    static sup := this.lb this.sc.s this.syntax.up this.rb
    static sdown := this.lb this.sc.s this.syntax.down this.rb

    static d := this.lb this.sc.d this.rb
    static dup := this.lb this.sc.d this.syntax.up this.rb
    static ddown := this.lb this.sc.d this.syntax.down this.rb

    static f := this.lb this.sc.f this.rb
    static fup := this.lb this.sc.f this.syntax.up this.rb
    static fdown := this.lb this.sc.f this.syntax.down this.rb

    static g := this.lb this.sc.g this.rb
    static gup := this.lb this.sc.g this.syntax.up this.rb
    static gdown := this.lb this.sc.g this.syntax.down this.rb

    static h := this.lb this.sc.h this.rb
    static hup := this.lb this.sc.h this.syntax.up this.rb
    static hdown := this.lb this.sc.h this.syntax.down this.rb

    static j := this.lb this.sc.j this.rb
    static jup := this.lb this.sc.j this.syntax.up this.rb
    static jdown := this.lb this.sc.j this.syntax.down this.rb

    static k := this.lb this.sc.k this.rb
    static kup := this.lb this.sc.k this.syntax.up this.rb
    static kdown := this.lb this.sc.k this.syntax.down this.rb

    static l := this.lb this.sc.l this.rb
    static lup := this.lb this.sc.l this.syntax.up this.rb
    static ldown := this.lb this.sc.l this.syntax.down this.rb

    static semicolon := this.lb this.sc.semicolon this.rb
    static semicolonup := this.lb this.sc.semicolon this.syntax.up this.rb
    static semicolondown := this.lb this.sc.semicolon this.syntax.down this.rb

    static quote := this.lb this.sc.quote this.rb
    static quoteup := this.lb this.sc.quote this.syntax.up this.rb
    static quotedown := this.lb this.sc.quote this.syntax.down this.rb

    static backtick := this.lb this.sc.backtick this.rb
    static backtickup := this.lb this.sc.backtick this.syntax.up this.rb
    static backtickdown := this.lb this.sc.backtick this.syntax.down this.rb

    static backslash := this.lb this.sc.backslash this.rb
    static backslashup := this.lb this.sc.backslash this.syntax.up this.rb
    static backslashdown := this.lb this.sc.backslash this.syntax.down this.rb

    static z := this.lb this.sc.z this.rb
    static zup := this.lb this.sc.z this.syntax.up this.rb
    static zdown := this.lb this.sc.z this.syntax.down this.rb

    static x := this.lb this.sc.x this.rb
    static xup := this.lb this.sc.x this.syntax.up this.rb
    static xdown := this.lb this.sc.x this.syntax.down this.rb

    static c := this.lb this.sc.c this.rb
    static cup := this.lb this.sc.c this.syntax.up this.rb
    static cdown := this.lb this.sc.c this.syntax.down this.rb

    static v := this.lb this.sc.v this.rb
    static vup := this.lb this.sc.v this.syntax.up this.rb
    static vdown := this.lb this.sc.v this.syntax.down this.rb

    static b := this.lb this.sc.b this.rb
    static bup := this.lb this.sc.b this.syntax.up this.rb
    static bdown := this.lb this.sc.b this.syntax.down this.rb

    static n := this.lb this.sc.n this.rb
    static nup := this.lb this.sc.n this.syntax.up this.rb
    static ndown := this.lb this.sc.n this.syntax.down this.rb

    static m := this.lb this.sc.m this.rb
    static mup := this.lb this.sc.m this.syntax.up this.rb
    static mdown := this.lb this.sc.m this.syntax.down this.rb

    static comma := this.lb this.sc.comma this.rb
    static commaup := this.lb this.sc.comma this.syntax.up this.rb
    static commadown := this.lb this.sc.comma this.syntax.down this.rb

    static period := this.lb this.sc.period this.rb
    static periodup := this.lb this.sc.period this.syntax.up this.rb
    static perioddown := this.lb this.sc.period this.syntax.down this.rb

    static slash := this.lb this.sc.slash this.rb
    static slashup := this.lb this.sc.slash this.syntax.up this.rb
    static slashdown := this.lb this.sc.slash this.syntax.down this.rb

    static numpadMult := this.lb this.sc.numpadMult this.rb
    static numpadMultup := this.lb this.sc.numpadMult this.syntax.up this.rb
    static numpadMultdown := this.lb this.sc.numpadMult this.syntax.down this.rb

    static space := this.lb this.sc.space this.rb
    static spaceup := this.lb this.sc.space this.syntax.up this.rb
    static spacedown := this.lb this.sc.space this.syntax.down this.rb

    static capslock := this.lb this.sc.capslock this.rb
    static capslockup := this.lb this.sc.capslock this.syntax.up this.rb
    static capslockdown := this.lb this.sc.capslock this.syntax.down this.rb

    static f1 := this.lb this.sc.f1 this.rb
    static f1up := this.lb this.sc.f1 this.syntax.up this.rb
    static f1down := this.lb this.sc.f1 this.syntax.down this.rb
    
    static f2 := this.lb this.sc.f2 this.rb
    static f2up := this.lb this.sc.f2 this.syntax.up this.rb
    static f2down := this.lb this.sc.f2 this.syntax.down this.rb

    static f3 := this.lb this.sc.f3 this.rb
    static f3up := this.lb this.sc.f3 this.syntax.up this.rb
    static f3down := this.lb this.sc.f3 this.syntax.down this.rb

    static f4 := this.lb this.sc.f4 this.rb
    static f4up := this.lb this.sc.f4 this.syntax.up this.rb
    static f4down := this.lb this.sc.f4 this.syntax.down this.rb

    static f5 := this.lb this.sc.f5 this.rb
    static f5up := this.lb this.sc.f5 this.syntax.up this.rb
    static f5down := this.lb this.sc.f5 this.syntax.down this.rb

    static f6 := this.lb this.sc.f6 this.rb
    static f6up := this.lb this.sc.f6 this.syntax.up this.rb
    static f6down := this.lb this.sc.f6 this.syntax.down this.rb

    static f7 := this.lb this.sc.f7 this.rb
    static f7up := this.lb this.sc.f7 this.syntax.up this.rb
    static f7down := this.lb this.sc.f7 this.syntax.down this.rb

    static f8 := this.lb this.sc.f8 this.rb
    static f8up := this.lb this.sc.f8 this.syntax.up this.rb
    static f8down := this.lb this.sc.f8 this.syntax.down this.rb

    static f9 := this.lb this.sc.f9 this.rb
    static f9up := this.lb this.sc.f9 this.syntax.up this.rb
    static f9down := this.lb this.sc.f9 this.syntax.down this.rb

    static f10 := this.lb this.sc.f10 this.rb
    static f10up := this.lb this.sc.f10 this.syntax.up this.rb
    static f10down := this.lb this.sc.f10 this.syntax.down this.rb

    static numlock := this.lb this.sc.numlock this.rb
    static numlockup := this.lb this.sc.numlock this.syntax.up this.rb
    static numlockdown := this.lb this.sc.numlock this.syntax.down this.rb

    static scrolllock := this.lb this.sc.scrolllock this.rb
    static scrolllockup := this.lb this.sc.scrolllock this.syntax.up this.rb
    static scrolllockdown := this.lb this.sc.scrolllock this.syntax.down this.rb

    static numpad7 := this.lb this.sc.numpad7 this.rb
    static numpad7up := this.lb this.sc.numpad7 this.syntax.up this.rb
    static numpad7down := this.lb this.sc.numpad7 this.syntax.down this.rb

    static numpad8 := this.lb this.sc.numpad8 this.rb
    static numpad8up := this.lb this.sc.numpad8 this.syntax.up this.rb
    static numpad8down := this.lb this.sc.numpad8 this.syntax.down this.rb

    static numpad9 := this.lb this.sc.numpad9 this.rb
    static numpad9up := this.lb this.sc.numpad9 this.syntax.up this.rb
    static numpad9down := this.lb this.sc.numpad9 this.syntax.down this.rb

    static numpadMinus := this.lb this.sc.numpadMinus this.rb
    static numpadMinusup := this.lb this.sc.numpadMinus this.syntax.up this.rb
    static numpadMinusdown := this.lb this.sc.numpadMinus this.syntax.down this.rb

    static numpad4 := this.lb this.sc.numpad4 this.rb
    static numpad4up := this.lb this.sc.numpad4 this.syntax.up this.rb
    static numpad4down := this.lb this.sc.numpad4 this.syntax.down this.rb

    static numpad5 := this.lb this.sc.numpad5 this.rb
    static numpad5up := this.lb this.sc.numpad5 this.syntax.up this.rb
    static numpad5down := this.lb this.sc.numpad5 this.syntax.down this.rb

    static numpad6 := this.lb this.sc.numpad6 this.rb
    static numpad6up := this.lb this.sc.numpad6 this.syntax.up this.rb
    static numpad6down := this.lb this.sc.numpad6 this.syntax.down this.rb

    static numpadPlus := this.lb this.sc.numpadPlus this.rb
    static numpadPlusup := this.lb this.sc.numpadPlus this.syntax.up this.rb
    static numpadPlusdown := this.lb this.sc.numpadPlus this.syntax.down this.rb

    static numpad1 := this.lb this.sc.numpad1 this.rb
    static numpad1up := this.lb this.sc.numpad1 this.syntax.up this.rb
    static numpad1down := this.lb this.sc.numpad1 this.syntax.down this.rb

    static numpad2 := this.lb this.sc.numpad2 this.rb
    static numpad2up := this.lb this.sc.numpad2 this.syntax.up this.rb
    static numpad2down := this.lb this.sc.numpad2 this.syntax.down this.rb

    static numpad3 := this.lb this.sc.numpad3 this.rb
    static numpad3up := this.lb this.sc.numpad3 this.syntax.up this.rb
    static numpad3down := this.lb this.sc.numpad3 this.syntax.down this.rb

    static numpad0 := this.lb this.sc.numpad0 this.rb
    static numpad0up := this.lb this.sc.numpad0 this.syntax.up this.rb
    static numpad0down := this.lb this.sc.numpad0 this.syntax.down this.rb

    static numpadDot := this.lb this.sc.numpadDot this.rb
    static numpadDotup := this.lb this.sc.numpadDot this.syntax.up this.rb
    static numpadDotdown := this.lb this.sc.numpadDot this.syntax.down this.rb

    static f11 := this.lb this.sc.f11 this.rb
    static f11up := this.lb this.sc.f11 this.syntax.up this.rb
    static f11down := this.lb this.sc.f11 this.syntax.down this.rb

    static f12 := this.lb this.sc.f12 this.rb
    static f12up := this.lb this.sc.f12 this.syntax.up this.rb
    static f12down := this.lb this.sc.f12 this.syntax.down this.rb

    static numpadDiv := this.lb this.sc.numpadDiv this.rb
    static numpadDivup := this.lb this.sc.numpadDiv this.syntax.up this.rb
    static numpadDivdown := this.lb this.sc.numpadDiv this.syntax.down this.rb

    static printscreen := this.lb this.sc.printscreen this.rb
    static printscreenup := this.lb this.sc.printscreen this.syntax.up this.rb
    static printscreendown := this.lb this.sc.printscreen this.syntax.down this.rb

    static pause := this.lb this.sc.pause this.rb
    static pauseup := this.lb this.sc.pause this.syntax.up this.rb
    static pausedown := this.lb this.sc.pause this.syntax.down this.rb

    static home := this.lb this.sc.home this.rb
    static homeup := this.lb this.sc.home this.syntax.up this.rb
    static homedown := this.lb this.sc.home this.syntax.down this.rb

    ; static scUp := this.lb this.sc.scup this.rb
    ; static scupup := this.lb this.sc.scup this.syntax.up this.rb
    ; static scupdown := this.lb this.sc.scup this.syntax.down this.rb

    static pageup := this.lb this.sc.pageup this.rb
    static pageupup := this.lb this.sc.pageup this.syntax.up this.rb
    static pageupdown := this.lb this.sc.pageup this.syntax.down this.rb

    static left := this.lb this.sc.left this.rb
    static leftup := this.lb this.sc.left this.syntax.up this.rb
    static leftdown := this.lb this.sc.left this.syntax.down this.rb

    static right := this.lb this.sc.right this.rb
    static rightup := this.lb this.sc.right this.syntax.up this.rb
    static rightdown := this.lb this.sc.right this.syntax.down this.rb

    static end := this.lb this.sc.end this.rb
    static endup := this.lb this.sc.end this.syntax.up this.rb
    static enddown := this.lb this.sc.end this.syntax.down this.rb

    ; static scdown := this.lb this.sc.scdown this.rb
    ; static scdownup := this.lb this.sc.scdown this.syntax.up this.rb
    ; static scdropdown := this.lb this.sc.scdown this.syntax.down this.rb

    static pagedown := this.lb this.sc.pagedown this.rb
    static pagedownup := this.lb this.sc.pagedown this.syntax.up this.rb
    static pagedowndown := this.lb this.sc.pagedown this.syntax.down this.rb

    static insert := this.lb this.sc.insert this.rb
    static insertup := this.lb this.sc.insert this.syntax.up this.rb
    static insertdown := this.lb this.sc.insert this.syntax.down this.rb

    static delete := this.lb this.sc.delete this.rb
    static deleteup := this.lb this.sc.delete this.syntax.up this.rb
    static deletedown := this.lb this.sc.delete this.syntax.down this.rb

    static appskey := this.lb this.sc.appskey this.rb
    static appskeyup := this.lb this.sc.appskey this.syntax.up this.rb
    static appskeydown := this.lb this.sc.appskey this.syntax.down this.rb

    static menu := this.lb this.sc.menu this.rb
    static menuup := this.lb this.sc.menu this.syntax.up this.rb
    static menudown := this.lb this.sc.menu this.syntax.down this.rb

    static hznsave := this.altdown this.f this.s this.altup
    
	static find := this.ctrldown this.f this.ctrlup
	static replace := this.ctrldown this.h this.ctrlup
	static bold := this.ctrldown this.b this.ctrlup
	static italics := this.ctrldown this.i this.ctrlup
	static underline := this.ctrldown this.u this.ctrlup
	static paste := this.ctrldown this.v this.ctrlup
	static shiftinsert := this.shiftdown this.insert this.shiftup
	static copy := this.ctrldown this.c this.ctrlup
	static cut := this.ctrldown this.x this.ctrlup
	static selectall := this.ctrldown this.a this.ctrlup
	static undo := this.ctrldown this.z this.ctrlup
	static redo := this.ctrldown this.y this.ctrlup
	static newfile := this.ctrldown this.n this.ctrlup
	static openfile := this.ctrldown this.o this.ctrlup
	static saveas := this.ctrldown this.shiftdown this.s this.shiftup this.ctrlup
	static print := this.ctrldown this.p this.ctrlup
	static close := this.ctrldown this.w this.ctrlup
	static quit := this.altdown this.f4 this.altup

    ; Navigation and window management
    static nextTab := this.ctrldown this.tab this.ctrlup
    static prevTab := this.ctrldown this.shiftdown this.tab this.shiftup this.ctrlup
    static nextWindow := this.altdown this.tab this.altup
    static prevWindow := this.altdown this.shiftdown this.tab this.shiftup this.altup
    static minimize := this.windown this.syntax.down this.winup
    static maximize := this.windown this.syntax.up this.winup
    static showDesktop := this.windown this.d this.winup
    static lockScreen := this.windown this.l this.winup

    ; Text editing
    static lineStart := this.home
    static lineEnd := this.end
    static wordLeft := this.ctrldown this.left this.ctrlup
    static wordRight := this.ctrldown this.right this.ctrlup
    static deleteWord := this.ctrldown this.delete this.ctrlup
    static backspaceWord := this.ctrldown this.backspace this.ctrlup

    ; System commands
    static taskManager := this.ctrldown this.shiftdown this.esc this.shiftup this.ctrlup
    static run := this.windown this.r this.winup
    static explorer := this.windown this.e this.winup


    ; static __New() {
    ;     /*
    ;     ; prop := value := ''
    ;     ; for prop, value in this.sc.OwnProps(){
    ;     ;     this.DefineProp(prop, {
    ;     ;         Set: (*) => prop := this.lb value this.lb,
    ;     ;         Get: (*) => prop
    ;     ;     })
    ;     ;     this.DefineProp(prop "down", {
    ;     ;         Set: (*) => prop := this.lb value this.syntax.down this.rb,
    ;     ;         Get: (*) => prop
    ;     ;     })
    ;     ;     this.DefineProp(prop "up", {
    ;     ;         Set: (*) => prop := this.lb . value . this.syntax.up . this.rb,
    ;     ;         Get: (*) => prop
    ;     ;     })
    ;     ; }
    ;     ;     this.DefineProp(prop . "down", {
    ;     ;         Get: (*) => this.lb . value . this.syntax.down . this.rb,
    ;     ;     })
    ;     ;     this.DefineProp(prop . "up", {
    ;     ;         Get: (*) => this.lb . value . this.syntax.up . this.rb,
    ;     ;     })
    ;     ; }
    ;     */
    ;     ; /*
    ;     ; Define individual key properties for all keys in sc class
    ;     this.esc := this.lb this.sc.esc this.rb
    ;     this.escup := this.lb this.sc.esc this.syntax.up this.rb
    ;     this.escdown := this.lb this.sc.esc this.syntax.down this.rb

    ;     this.1 := this.lb this.sc.1 this.rb
    ;     this.1up := this.lb this.sc.1 this.syntax.up this.rb
    ;     this.1down := this.lb this.sc.1 this.syntax.down this.rb

    ;     this.2 := this.lb this.sc.2 this.rb
    ;     this.2up := this.lb this.sc.2 this.syntax.up this.rb
    ;     this.2down := this.lb this.sc.2 this.syntax.down this.rb

    ;     this.3 := this.lb this.sc.3 this.rb
    ;     this.3up := this.lb this.sc.3 this.syntax.up this.rb
    ;     this.3down := this.lb this.sc.3 this.syntax.down this.rb

    ;     this.4 := this.lb this.sc.4 this.rb
    ;     this.4up := this.lb this.sc.4 this.syntax.up this.rb
    ;     this.4down := this.lb this.sc.4 this.syntax.down this.rb

    ;     this.5 := this.lb this.sc.5 this.rb
    ;     this.5up := this.lb this.sc.5 this.syntax.up this.rb
    ;     this.5down := this.lb this.sc.5 this.syntax.down this.rb

    ;     this.6 := this.lb this.sc.6 this.rb
    ;     this.6up := this.lb this.sc.6 this.syntax.up this.rb
    ;     this.6down := this.lb this.sc.6 this.syntax.down this.rb

    ;     this.7 := this.lb this.sc.7 this.rb
    ;     this.7up := this.lb this.sc.7 this.syntax.up this.rb
    ;     this.7down := this.lb this.sc.7 this.syntax.down this.rb

    ;     this.8 := this.lb this.sc.8 this.rb
    ;     this.8up := this.lb this.sc.8 this.syntax.up this.rb
    ;     this.8down := this.lb this.sc.8 this.syntax.down this.rb

    ;     this.9 := this.lb this.sc.9 this.rb
    ;     this.9up := this.lb this.sc.9 this.syntax.up this.rb
    ;     this.9down := this.lb this.sc.9 this.syntax.down this.rb

    ;     this.0 := this.lb this.sc.0 this.rb
    ;     this.0up := this.lb this.sc.0 this.syntax.up this.rb
    ;     this.0down := this.lb this.sc.0 this.syntax.down this.rb

    ;     this.minus := this.lb this.sc.minus this.rb
    ;     this.minusup := this.lb this.sc.minus this.syntax.up this.rb
    ;     this.minusdown := this.lb this.sc.minus this.syntax.down this.rb

    ;     this.equal := this.lb this.sc.equal this.rb
    ;     this.equalup := this.lb this.sc.equal this.syntax.up this.rb
    ;     this.equaldown := this.lb this.sc.equal this.syntax.down this.rb

    ;     this.backspace := this.lb this.sc.backspace this.rb
    ;     this.backspaceup := this.lb this.sc.backspace this.syntax.up this.rb
    ;     this.backspacedown := this.lb this.sc.backspace this.syntax.down this.rb

    ;     this.tab := this.lb this.sc.tab this.rb
    ;     this.tabup := this.lb this.sc.tab this.syntax.up this.rb
    ;     this.tabdown := this.lb this.sc.tab this.syntax.down this.rb

    ;     this.q := this.lb this.sc.q this.rb
    ;     this.qup := this.lb this.sc.q this.syntax.up this.rb
    ;     this.qdown := this.lb this.sc.q this.syntax.down this.rb

    ;     this.w := this.lb this.sc.w this.rb
    ;     this.wup := this.lb this.sc.w this.syntax.up this.rb
    ;     this.wdown := this.lb this.sc.w this.syntax.down this.rb

    ;     this.e := this.lb this.sc.e this.rb
    ;     this.eup := this.lb this.sc.e this.syntax.up this.rb
    ;     this.edown := this.lb this.sc.e this.syntax.down this.rb

    ;     this.r := this.lb this.sc.r this.rb
    ;     this.rup := this.lb this.sc.r this.syntax.up this.rb
    ;     this.rdown := this.lb this.sc.r this.syntax.down this.rb

    ;     this.t := this.lb this.sc.t this.rb
    ;     this.tup := this.lb this.sc.t this.syntax.up this.rb
    ;     this.tdown := this.lb this.sc.t this.syntax.down this.rb

    ;     this.y := this.lb this.sc.y this.rb
    ;     this.yup := this.lb this.sc.y this.syntax.up this.rb
    ;     this.ydown := this.lb this.sc.y this.syntax.down this.rb

    ;     this.u := this.lb this.sc.u this.rb
    ;     this.uup := this.lb this.sc.u this.syntax.up this.rb
    ;     this.udown := this.lb this.sc.u this.syntax.down this.rb

    ;     this.i := this.lb this.sc.i this.rb
    ;     this.iup := this.lb this.sc.i this.syntax.up this.rb
    ;     this.idown := this.lb this.sc.i this.syntax.down this.rb

    ;     this.o := this.lb this.sc.o this.rb
    ;     this.oup := this.lb this.sc.o this.syntax.up this.rb
    ;     this.odown := this.lb this.sc.o this.syntax.down this.rb

    ;     this.p := this.lb this.sc.p this.rb
    ;     this.pup := this.lb this.sc.p this.syntax.up this.rb
    ;     this.pdown := this.lb this.sc.p this.syntax.down this.rb

    ;     this.lbracket := this.lb this.sc.lbracket this.rb
    ;     this.lbracketup := this.lb this.sc.lbracket this.syntax.up this.rb
    ;     this.lbracketdown := this.lb this.sc.lbracket this.syntax.down this.rb

    ;     this.rbracket := this.lb this.sc.rbracket this.rb
    ;     this.rbracketup := this.lb this.sc.rbracket this.syntax.up this.rb
    ;     this.rbracketdown := this.lb this.sc.rbracket this.syntax.down this.rb

    ;     this.enter := this.lb this.sc.enter this.rb
    ;     this.enterup := this.lb this.sc.enter this.syntax.up this.rb
    ;     this.enterdown := this.lb this.sc.enter this.syntax.down this.rb

    ;     this.ctrl := this.lb this.sc.ctrl this.rb
    ;     this.ctrlup := this.lb this.sc.ctrl this.syntax.up this.rb
    ;     this.ctrldown := this.lb this.sc.ctrl this.syntax.down this.rb

    ;     this.lctrl := this.lb this.sc.lctrl this.rb
    ;     this.lctrlup := this.lb this.sc.lctrl this.syntax.up this.rb
    ;     this.lctrldown := this.lb this.sc.lctrl this.syntax.down this.rb

    ;     this.a := this.lb this.sc.a this.rb
    ;     this.aup := this.lb this.sc.a this.syntax.up this.rb
    ;     this.adown := this.lb this.sc.a this.syntax.down this.rb

    ;     this.s := this.lb this.sc.s this.rb
    ;     this.sup := this.lb this.sc.s this.syntax.up this.rb
    ;     this.sdown := this.lb this.sc.s this.syntax.down this.rb

    ;     this.d := this.lb this.sc.d this.rb
    ;     this.dup := this.lb this.sc.d this.syntax.up this.rb
    ;     this.ddown := this.lb this.sc.d this.syntax.down this.rb

    ;     this.f := this.lb this.sc.f this.rb
    ;     this.fup := this.lb this.sc.f this.syntax.up this.rb
    ;     this.fdown := this.lb this.sc.f this.syntax.down this.rb

    ;     this.g := this.lb this.sc.g this.rb
    ;     this.gup := this.lb this.sc.g this.syntax.up this.rb
    ;     this.gdown := this.lb this.sc.g this.syntax.down this.rb

    ;     this.h := this.lb this.sc.h this.rb
    ;     this.hup := this.lb this.sc.h this.syntax.up this.rb
    ;     this.hdown := this.lb this.sc.h this.syntax.down this.rb

    ;     this.j := this.lb this.sc.j this.rb
    ;     this.jup := this.lb this.sc.j this.syntax.up this.rb
    ;     this.jdown := this.lb this.sc.j this.syntax.down this.rb

    ;     this.k := this.lb this.sc.k this.rb
    ;     this.kup := this.lb this.sc.k this.syntax.up this.rb
    ;     this.kdown := this.lb this.sc.k this.syntax.down this.rb

    ;     this.l := this.lb this.sc.l this.rb
    ;     this.lup := this.lb this.sc.l this.syntax.up this.rb
    ;     this.ldown := this.lb this.sc.l this.syntax.down this.rb

    ;     this.semicolon := this.lb this.sc.semicolon this.rb
    ;     this.semicolonup := this.lb this.sc.semicolon this.syntax.up this.rb
    ;     this.semicolondown := this.lb this.sc.semicolon this.syntax.down this.rb

    ;     this.quote := this.lb this.sc.quote this.rb
    ;     this.quoteup := this.lb this.sc.quote this.syntax.up this.rb
    ;     this.quotedown := this.lb this.sc.quote this.syntax.down this.rb

    ;     this.backtick := this.lb this.sc.backtick this.rb
    ;     this.backtickup := this.lb this.sc.backtick this.syntax.up this.rb
    ;     this.backtickdown := this.lb this.sc.backtick this.syntax.down this.rb

    ;     this.shift := this.lb this.sc.shift this.rb
    ;     this.shiftup := this.lb this.sc.shift this.syntax.up this.rb
    ;     this.shiftdown := this.lb this.sc.shift this.syntax.down this.rb

    ;     this.lshift := this.lb this.sc.lshift this.rb
    ;     this.lshiftup := this.lb this.sc.lshift this.syntax.up this.rb
    ;     this.lshiftdown := this.lb this.sc.lshift this.syntax.down this.rb

    ;     this.backslash := this.lb this.sc.backslash this.rb
    ;     this.backslashup := this.lb this.sc.backslash this.syntax.up this.rb
    ;     this.backslashdown := this.lb this.sc.backslash this.syntax.down this.rb

    ;     this.z := this.lb this.sc.z this.rb
    ;     this.zup := this.lb this.sc.z this.syntax.up this.rb
    ;     this.zdown := this.lb this.sc.z this.syntax.down this.rb

    ;     this.x := this.lb this.sc.x this.rb
    ;     this.xup := this.lb this.sc.x this.syntax.up this.rb
    ;     this.xdown := this.lb this.sc.x this.syntax.down this.rb

    ;     this.c := this.lb this.sc.c this.rb
    ;     this.cup := this.lb this.sc.c this.syntax.up this.rb
    ;     this.cdown := this.lb this.sc.c this.syntax.down this.rb

    ;     this.v := this.lb this.sc.v this.rb
    ;     this.vup := this.lb this.sc.v this.syntax.up this.rb
    ;     this.vdown := this.lb this.sc.v this.syntax.down this.rb

    ;     this.b := this.lb this.sc.b this.rb
    ;     this.bup := this.lb this.sc.b this.syntax.up this.rb
    ;     this.bdown := this.lb this.sc.b this.syntax.down this.rb

    ;     this.n := this.lb this.sc.n this.rb
    ;     this.nup := this.lb this.sc.n this.syntax.up this.rb
    ;     this.ndown := this.lb this.sc.n this.syntax.down this.rb

    ;     this.m := this.lb this.sc.m this.rb
    ;     this.mup := this.lb this.sc.m this.syntax.up this.rb
    ;     this.mdown := this.lb this.sc.m this.syntax.down this.rb

    ;     this.comma := this.lb this.sc.comma this.rb
    ;     this.commaup := this.lb this.sc.comma this.syntax.up this.rb
    ;     this.commadown := this.lb this.sc.comma this.syntax.down this.rb

    ;     this.period := this.lb this.sc.period this.rb
    ;     this.periodup := this.lb this.sc.period this.syntax.up this.rb
    ;     this.perioddown := this.lb this.sc.period this.syntax.down this.rb

    ;     this.slash := this.lb this.sc.slash this.rb
    ;     this.slashup := this.lb this.sc.slash this.syntax.up this.rb
    ;     this.slashdown := this.lb this.sc.slash this.syntax.down this.rb

    ;     this.rshift := this.lb this.sc.rshift this.rb
    ;     this.rshiftup := this.lb this.sc.rshift this.syntax.up this.rb
    ;     this.rshiftdown := this.lb this.sc.rshift this.syntax.down this.rb

    ;     this.numpadMult := this.lb this.sc.numpadMult this.rb
    ;     this.numpadMultup := this.lb this.sc.numpadMult this.syntax.up this.rb
    ;     this.numpadMultdown := this.lb this.sc.numpadMult this.syntax.down this.rb

    ;     this.alt := this.lb this.sc.alt this.rb
    ;     this.altup := this.lb this.sc.alt this.syntax.up this.rb
    ;     this.altdown := this.lb this.sc.alt this.syntax.down this.rb

    ;     this.lalt := this.lb this.sc.lalt this.rb
    ;     this.laltup := this.lb this.sc.lalt this.syntax.up this.rb
    ;     this.laltdown := this.lb this.sc.lalt this.syntax.down this.rb

    ;     this.space := this.lb this.sc.space this.rb
    ;     this.spaceup := this.lb this.sc.space this.syntax.up this.rb
    ;     this.spacedown := this.lb this.sc.space this.syntax.down this.rb

    ;     this.capslock := this.lb this.sc.capslock this.rb
    ;     this.capslockup := this.lb this.sc.capslock this.syntax.up this.rb
    ;     this.capslockdown := this.lb this.sc.capslock this.syntax.down this.rb

    ;     this.f1 := this.lb this.sc.f1 this.rb
    ;     this.f1up := this.lb this.sc.f1 this.syntax.up this.rb
    ;     this.f1down := this.lb this.sc.f1 this.syntax.down this.rb

    ;     this.f2 := this.lb this.sc.f2 this.rb
    ;     this.f2up := this.lb this.sc.f2 this.syntax.up this.rb
    ;     this.f2down := this.lb this.sc.f2 this.syntax.down this.rb

    ;     this.f3 := this.lb this.sc.f3 this.rb
    ;     this.f3up := this.lb this.sc.f3 this.syntax.up this.rb
    ;     this.f3down := this.lb this.sc.f3 this.syntax.down this.rb

    ;     this.f4 := this.lb this.sc.f4 this.rb
    ;     this.f4up := this.lb this.sc.f4 this.syntax.up this.rb
    ;     this.f4down := this.lb this.sc.f4 this.syntax.down this.rb

    ;     this.f5 := this.lb this.sc.f5 this.rb
    ;     this.f5up := this.lb this.sc.f5 this.syntax.up this.rb
    ;     this.f5down := this.lb this.sc.f5 this.syntax.down this.rb

    ;     this.f6 := this.lb this.sc.f6 this.rb
    ;     this.f6up := this.lb this.sc.f6 this.syntax.up this.rb
    ;     this.f6down := this.lb this.sc.f6 this.syntax.down this.rb

    ;     this.f7 := this.lb this.sc.f7 this.rb
    ;     this.f7up := this.lb this.sc.f7 this.syntax.up this.rb
    ;     this.f7down := this.lb this.sc.f7 this.syntax.down this.rb

    ;     this.f8 := this.lb this.sc.f8 this.rb
    ;     this.f8up := this.lb this.sc.f8 this.syntax.up this.rb
    ;     this.f8down := this.lb this.sc.f8 this.syntax.down this.rb

    ;     this.f9 := this.lb this.sc.f9 this.rb
    ;     this.f9up := this.lb this.sc.f9 this.syntax.up this.rb
    ;     this.f9down := this.lb this.sc.f9 this.syntax.down this.rb

    ;     this.f10 := this.lb this.sc.f10 this.rb
    ;     this.f10up := this.lb this.sc.f10 this.syntax.up this.rb
    ;     this.f10down := this.lb this.sc.f10 this.syntax.down this.rb

    ;     this.numlock := this.lb this.sc.numlock this.rb
    ;     this.numlockup := this.lb this.sc.numlock this.syntax.up this.rb
    ;     this.numlockdown := this.lb this.sc.numlock this.syntax.down this.rb

    ;     this.scrolllock := this.lb this.sc.scrolllock this.rb
    ;     this.scrolllockup := this.lb this.sc.scrolllock this.syntax.up this.rb
    ;     this.scrolllockdown := this.lb this.sc.scrolllock this.syntax.down this.rb

    ;     this.numpad7 := this.lb this.sc.numpad7 this.rb
    ;     this.numpad7up := this.lb this.sc.numpad7 this.syntax.up this.rb
    ;     this.numpad7down := this.lb this.sc.numpad7 this.syntax.down this.rb

    ;     this.numpad8 := this.lb this.sc.numpad8 this.rb
    ;     this.numpad8up := this.lb this.sc.numpad8 this.syntax.up this.rb
    ;     this.numpad8down := this.lb this.sc.numpad8 this.syntax.down this.rb

    ;     this.numpad9 := this.lb this.sc.numpad9 this.rb
    ;     this.numpad9up := this.lb this.sc.numpad9 this.syntax.up this.rb
    ;     this.numpad9down := this.lb this.sc.numpad9 this.syntax.down this.rb

    ;     this.numpadMinus := this.lb this.sc.numpadMinus this.rb
    ;     this.numpadMinusup := this.lb this.sc.numpadMinus this.syntax.up this.rb
    ;     this.numpadMinusdown := this.lb this.sc.numpadMinus this.syntax.down this.rb

    ;     this.numpad4 := this.lb this.sc.numpad4 this.rb
    ;     this.numpad4up := this.lb this.sc.numpad4 this.syntax.up this.rb
    ;     this.numpad4down := this.lb this.sc.numpad4 this.syntax.down this.rb

    ;     this.numpad5 := this.lb this.sc.numpad5 this.rb
    ;     this.numpad5up := this.lb this.sc.numpad5 this.syntax.up this.rb
    ;     this.numpad5down := this.lb this.sc.numpad5 this.syntax.down this.rb

    ;     this.numpad6 := this.lb this.sc.numpad6 this.rb
    ;     this.numpad6up := this.lb this.sc.numpad6 this.syntax.up this.rb
    ;     this.numpad6down := this.lb this.sc.numpad6 this.syntax.down this.rb

    ;     this.numpadPlus := this.lb this.sc.numpadPlus this.rb
    ;     this.numpadPlusup := this.lb this.sc.numpadPlus this.syntax.up this.rb
    ;     this.numpadPlusdown := this.lb this.sc.numpadPlus this.syntax.down this.rb

    ;     this.numpad1 := this.lb this.sc.numpad1 this.rb
    ;     this.numpad1up := this.lb this.sc.numpad1 this.syntax.up this.rb
    ;     this.numpad1down := this.lb this.sc.numpad1 this.syntax.down this.rb

    ;     this.numpad2 := this.lb this.sc.numpad2 this.rb
    ;     this.numpad2up := this.lb this.sc.numpad2 this.syntax.up this.rb
    ;     this.numpad2down := this.lb this.sc.numpad2 this.syntax.down this.rb

    ;     this.numpad3 := this.lb this.sc.numpad3 this.rb
    ;     this.numpad3up := this.lb this.sc.numpad3 this.syntax.up this.rb
    ;     this.numpad3down := this.lb this.sc.numpad3 this.syntax.down this.rb

    ;     this.numpad0 := this.lb this.sc.numpad0 this.rb
    ;     this.numpad0up := this.lb this.sc.numpad0 this.syntax.up this.rb
    ;     this.numpad0down := this.lb this.sc.numpad0 this.syntax.down this.rb

    ;     this.numpadDot := this.lb this.sc.numpadDot this.rb
    ;     this.numpadDotup := this.lb this.sc.numpadDot this.syntax.up this.rb
    ;     this.numpadDotdown := this.lb this.sc.numpadDot this.syntax.down this.rb

    ;     this.f11 := this.lb this.sc.f11 this.rb
    ;     this.f11up := this.lb this.sc.f11 this.syntax.up this.rb
    ;     this.f11down := this.lb this.sc.f11 this.syntax.down this.rb

    ;     this.f12 := this.lb this.sc.f12 this.rb
    ;     this.f12up := this.lb this.sc.f12 this.syntax.up this.rb
    ;     this.f12down := this.lb this.sc.f12 this.syntax.down this.rb

    ;     this.rctrl := this.lb this.sc.rctrl this.rb
    ;     this.rctrlup := this.lb this.sc.rctrl this.syntax.up this.rb
    ;     this.rctrldown := this.lb this.sc.rctrl this.syntax.down this.rb

    ;     this.numpadDiv := this.lb this.sc.numpadDiv this.rb
    ;     this.numpadDivup := this.lb this.sc.numpadDiv this.syntax.up this.rb
    ;     this.numpadDivdown := this.lb this.sc.numpadDiv this.syntax.down this.rb

    ;     this.printscreen := this.lb this.sc.printscreen this.rb
    ;     this.printscreenup := this.lb this.sc.printscreen this.syntax.up this.rb
    ;     this.printscreendown := this.lb this.sc.printscreen this.syntax.down this.rb

    ;     this.ralt := this.lb this.sc.ralt this.rb
    ;     this.raltup := this.lb this.sc.ralt this.syntax.up this.rb
    ;     this.raltdown := this.lb this.sc.ralt this.syntax.down this.rb

    ;     this.pause := this.lb this.sc.pause this.rb
    ;     this.pauseup := this.lb this.sc.pause this.syntax.up this.rb
    ;     this.pausedown := this.lb this.sc.pause this.syntax.down this.rb

    ;     this.home := this.lb this.sc.home this.rb
    ;     this.homeup := this.lb this.sc.home this.syntax.up this.rb
    ;     this.homedown := this.lb this.sc.home this.syntax.down this.rb
    ;     /*
    ;     ; this.up := this.lb this.sc.up this.rb
    ;     ; this.upup := this.lb this.sc.up this.syntax.up this.rb
    ;     ; this.updown := this.lb this.sc.up this.syntax.down this.rb
    ;     */
    ;     this.pageup := this.lb this.sc.pageup this.rb
    ;     this.pageupup := this.lb this.sc.pageup this.syntax.up this.rb
    ;     this.pageupdown := this.lb this.sc.pageup this.syntax.down this.rb

    ;     this.left := this.lb this.sc.left this.rb
    ;     this.leftup := this.lb this.sc.left this.syntax.up this.rb
    ;     this.leftdown := this.lb this.sc.left this.syntax.down this.rb

    ;     this.right := this.lb this.sc.right this.rb
    ;     this.rightup := this.lb this.sc.right this.syntax.up this.rb
    ;     this.rightdown := this.lb this.sc.right this.syntax.down this.rb

    ;     this.end := this.lb this.sc.end this.rb
    ;     this.endup := this.lb this.sc.end this.syntax.up this.rb
    ;     this.enddown := this.lb this.sc.end this.syntax.down this.rb
    ;     /*
    ;     ; this.down := this.lb this.sc.down this.rb
    ;     ; this.downup := this.lb this.sc.down this.syntax.up this.rb
    ;     ; this.dropdown := this.lb this.sc.down this.syntax.down this.rb
    ;     */
    ;     this.pagedown := this.lb this.sc.pagedown this.rb
    ;     this.pagedownup := this.lb this.sc.pagedown this.syntax.up this.rb
    ;     this.pagedowndown := this.lb this.sc.pagedown this.syntax.down this.rb

    ;     this.insert := this.lb this.sc.insert this.rb
    ;     this.insertup := this.lb this.sc.insert this.syntax.up this.rb
    ;     this.insertdown := this.lb this.sc.insert this.syntax.down this.rb

    ;     this.delete := this.lb this.sc.delete this.rb
    ;     this.deleteup := this.lb this.sc.delete this.syntax.up this.rb
    ;     this.deletedown := this.lb this.sc.delete this.syntax.down this.rb

    ;     this.win := this.lb this.sc.win this.rb
    ;     this.winup := this.lb this.sc.win this.syntax.up this.rb
    ;     this.windown := this.lb this.sc.win this.syntax.down this.rb

    ;     this.lwin := this.lb this.sc.lwin this.rb
    ;     this.lwinup := this.lb this.sc.lwin this.syntax.up this.rb
    ;     this.lwindown := this.lb this.sc.lwin this.syntax.down this.rb

    ;     this.rwin := this.lb this.sc.rwin this.rb
    ;     this.rwinup := this.lb this.sc.rwin this.syntax.up this.rb
    ;     this.rwindown := this.lb this.sc.rwin this.syntax.down this.rb

    ;     this.appskey := this.lb this.sc.appskey this.rb
    ;     this.appskeyup := this.lb this.sc.appskey this.syntax.up this.rb
    ;     this.appskeydown := this.lb this.sc.appskey this.syntax.down this.rb

    ;     this.menu := this.lb this.sc.menu this.rb
    ;     this.menuup := this.lb this.sc.menu this.syntax.up this.rb
    ;     this.menudown := this.lb this.sc.menu this.syntax.down this.rb
    ;     ; */

    ;     ; this.find := this.ctrldown this.f this.ctrlup
    ;     ; this.replace := this.ctrldown this.h this.ctrlup
    ;     ; this.bold := this.ctrldown this.b this.ctrlup
    ;     ; this.italics := this.ctrldown this.i this.ctrlup
    ;     ; this.underline := this.ctrldown this.u this.ctrlup
    ;     ; this.paste := this.ctrldown this.v this.ctrlup
    ;     ; this.copy := this.ctrldown this.c this.ctrlup
    ;     ; this.cut := this.ctrldown this.x this.ctrlup
    ;     ; this.selectall := this.ctrldown this.a this.ctrlup
    ;     ; this.undo := this.ctrldown this.z this.ctrlup
    ;     ; this.redo := this.ctrldown this.y this.ctrlup
    ;     ; this.newfile := this.ctrldown this.n this.ctrlup
    ;     ; this.openfile := this.ctrldown this.o this.ctrlup
    ;     ; this.saveas := this.ctrldown this.shiftdown this.s this.shiftup this.ctrlup
    ;     ; this.print := this.ctrldown this.p this.ctrlup
    ;     ; this.close := this.ctrldown this.w this.ctrlup
    ;     ; this.quit := this.altdown this.f4 this.altup

    ;     ; Navigation and window management
    ;     this.nextTab := this.ctrldown this.tab this.ctrlup
    ;     this.prevTab := this.ctrldown this.shiftdown this.tab this.shiftup this.ctrlup
    ;     this.nextWindow := this.altdown this.tab this.altup
    ;     this.prevWindow := this.altdown this.shiftdown this.tab this.shiftup this.altup
    ;     this.minimize := this.windown this.syntax.down this.winup
    ;     this.maximize := this.windown this.syntax.up this.winup
    ;     this.showDesktop := this.windown this.d this.winup
    ;     this.lockScreen := this.windown this.l this.winup

    ;     ; Text editing
    ;     this.lineStart := this.home
    ;     this.lineEnd := this.end
    ;     this.wordLeft := this.ctrldown this.left this.ctrlup
    ;     this.wordRight := this.ctrldown this.right this.ctrlup
    ;     this.deleteWord := this.ctrldown this.delete this.ctrlup
    ;     this.backspaceWord := this.ctrldown this.backspace this.ctrlup

    ;     ; System commands
    ;     this.taskManager := this.ctrldown this.shiftdown this.esc this.shiftup this.ctrlup
    ;     this.run := this.windown this.r this.winup
    ;     this.explorer := this.windown this.e this.winup
        
    ; }
}

; key.__New()
