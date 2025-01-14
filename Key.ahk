#Requires AutoHotkey v2+
; #Include <Directives\__AE.v2>
#Include <Includes\ObjectTypeExtensions>

class key2 {
    static vk := {
        Delete: "Delete"  ; Virtual key name for Delete key
    }
}

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
        static _1 := 'sc02'
        static _2 := 'sc03'
        static _3 := 'sc04'
        static _4 := 'sc05'
        static _5 := 'sc06'
        static _6 := 'sc07'
        static _7 := 'sc08'
        static _8 := 'sc09'
        static _9 := 'sc0A'
        static _0 := 'sc0B'
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
            this.SelectAll    	:= '^' this.sc.a
            this.SelectHome   	:= '^' this.sc.Home
            this.SelectEnd    	:= '^' this.sc.End
            ; this.italics      := '{' this.CONTROL ' Down}' '{' this.KEY_I '}' '{' this.CONTROL ' Up}'
            this.italics      	:= '^' this.sc.i
            this.bold         	:= '^' this.sc.b
            this.underline    	:= '^' this.sc.u
            this.AlignLeft    	:= '^' this.sc.l
            this.AlignRight   	:= '^' this.sc.r
            this.AlignCenter  	:= '^' this.sc.e
            this.Justified    	:= '^' this.sc.j
            this.Cut          	:= '^' this.sc.x
            this.Copy         	:= '^' this.sc.c
            this.Paste        	:= '^' this.sc.v
            this.Undo         	:= '^' this.sc.z
            this.Redo         	:= '^' this.sc.y
            this.pastespecial 	:= '^!' this.sc.v
            this.BulletedList 	:= '+' this.sc.f12
            this.InsertTable  	:= '^' this.sc.F12
            this.SuperScript  	:= '^='
            this.SubScript    	:= '^+='
            this.wSupScript 	:= '^.'
            this.wSubScript    	:= '^,'
            this.Search       	:= this.sc.F5 ; 'F5'
            this.Find         	:= '^' this.sc.f
            this.Replace      	:= '^' this.sc.h
            this.CtrlEnter    	:= '^' this.sc.enter
            this.Save         	:= '^' this.sc.s
            this.Open         	:= '^' this.sc.o
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
		static Replace 	:= '^vk48'
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
		return RegExMatch(key, "i)^\{VK_\w+ sc\w+\}$")
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

	/**
	 * @return scString
	 */
	static SendSC(keys) {
		scString := this.translateToSC(keys)
		Send(scString)
		return scString
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

    Class vksc extends key{
        static italics := this.vk.CONTROL ' & ' this.sc.i
        static BulletedList := this.vk.SHIFT ' & ' this.sc.f12
    }
    ; static down := " down"
    ; static up := " up"
	; sc := {}
    static lb := "{"
    static rb := "}"
    static shift        := '{' this.sc.shift '}'
    static shiftup      := '{' this.sc.shift ' up}'
    static shiftdown    := '{' this.sc.shift ' down}'
    static lshift       := '{' this.sc.lshift '}'
    static lshiftup     := '{' this.sc.lshift ' up}'
    static lshiftdown   := '{' this.sc.lshift ' down}'
    static rshift       := '{' this.sc.rshift '}'
    static rshiftup     := '{' this.sc.rshift ' up}'
    static rshiftdown   := '{' this.sc.rshift ' down}'

    static ctrl         := '{' this.sc.ctrl '}'
    static control      := '{' this.sc.ctrl '}'
    static controldown  := '{' this.sc.ctrl ' down}'
    static ctrldown     := '{' this.sc.ctrl ' down}'
    static controlup    := '{' this.sc.ctrl ' up}'
    static ctrlup       := '{' this.sc.ctrl ' up}'
    static lctrl        := '{' this.sc.lctrl '}'
    static lctrldown    := '{' this.sc.lctrl ' down}'
    static lctrlup      := '{' this.sc.lctrl ' up}'
    static rctrl        := '{' this.sc.rctrl '}'
    static rctrldown    := '{' this.sc.rctrl ' down}'
    static rctrlup      := '{' this.sc.rctrl ' up}'

    static alt          := '{' this.sc.alt '}'
    static altup        := '{' this.sc.alt ' up}'
    static altdown      := '{' this.sc.alt ' down}'
    static lalt         := '{' this.sc.lalt '}'
    static laltup       := '{' this.sc.lalt ' up}'
    static laltdown     := '{' this.sc.lalt ' down}'
    static ralt         := '{' this.sc.ralt '}'
    static raltup       := '{' this.sc.ralt ' up}'
    static raltdown     := '{' this.sc.ralt ' down}'

    static win          := '{' this.sc.win '}'
    static winup        := '{' this.sc.win ' up}'
    static windown      := '{' this.sc.win ' down}'
    static lwin         := '{' this.sc.lwin '}'
    static lwinup       := '{' this.sc.lwin ' up}'
    static lwindown     := '{' this.sc.lwin ' down}'
    static rwin         := '{' this.sc.rwin '}'
    static rwinup       := '{' this.sc.rwin ' up}'
    static rwindown     := '{' this.sc.rwin ' down}'

    ; Define individual key properties for all keys in sc class
    static esc := '{' this.sc.esc '}'
    static escup := '{' this.sc.esc ' up}'
    static escdown := '{' this.sc.esc ' down}'

    static _1 := '{' this.sc._1 '}'
    static _1up := '{' this.sc._1 ' up}'
    static 1down := '{' this.sc._1 ' down}'

    static _2 := '{' this.sc._2 '}'
    static 2up := '{' this.sc._2 ' up}'
    static 2down := '{' this.sc._2 ' down}'

    static _3 := '{' this.sc._3 '}'
    static 3up := '{' this.sc._3 ' up}'
    static 3down := '{' this.sc._3 ' down}'

    static _4 := '{' this.sc._4 '}'
    static 4up := '{' this.sc._4 ' up}'
    static 4down := '{' this.sc._4 ' down}'

    static _5 := '{' this.sc._5 '}'
    static 5up := '{' this.sc._5 ' up}'
    static 5down := '{' this.sc._5 ' down}'

    static _6 := '{' this.sc._6 '}'
    static _6up := '{' this.sc._6 ' up}'
    static _6down := '{' this.sc._6 ' down}'

    static _7 := '{' this.sc._7 '}'
    static _7up := '{' this.sc._7 ' up}'
    static _7down := '{' this.sc._7 ' down}'

    static _8 := '{' this.sc._8 '}'
    static _8up := '{' this.sc._8 ' up}'
    static _8down := '{' this.sc._8 ' down}'

    static _9 := '{' this.sc._9 '}'
    static _9up := '{' this.sc._9 ' up}'
    static _9down := '{' this.sc._9 ' down}'

    static _0 := '{' this.sc._0 '}'
    static _0up := '{' this.sc._0 ' up}'
    static _0down := '{' this.sc._0 ' down}'

    static minus := '{' this.sc.minus '}'
    static minusup := '{' this.sc.minus ' up}'
    static minusdown := '{' this.sc.minus ' down}'

    static equal := '{' this.sc.equal '}'
    static equalup := '{' this.sc.equal ' up}'
    static equaldown := '{' this.sc.equal ' down}'

    static backspace := '{' this.sc.backspace '}'
    static backspaceup := '{' this.sc.backspace ' up}'
    static backspacedown := '{' this.sc.backspace ' down}'

    static tab := '{' this.sc.tab '}'
    static tabup := '{' this.sc.tab ' up}'
    static tabdown := '{' this.sc.tab ' down}'

    static q := '{' this.sc.q '}'
    static qup := '{' this.sc.q ' up}'
    static qdown := '{' this.sc.q ' down}'

    static w := '{' this.sc.w '}'
    static wup := '{' this.sc.w ' up}'
    static wdown := '{' this.sc.w ' down}'

    static e := '{' this.sc.e '}'
    static eup := '{' this.sc.e ' up}'
    static edown := '{' this.sc.e ' down}'

    static r := '{' this.sc.r '}'
    static rup := '{' this.sc.r ' up}'
    static rdown := '{' this.sc.r ' down}'

    static t := '{' this.sc.t '}'
    static tup := '{' this.sc.t ' up}'
    static tdown := '{' this.sc.t ' down}'

    static y := '{' this.sc.y '}'
    static yup := '{' this.sc.y ' up}'
    static ydown := '{' this.sc.y ' down}'

    static u := '{' this.sc.u '}'
    static uup := '{' this.sc.u ' up}'
    static udown := '{' this.sc.u ' down}'

    static i := '{' this.sc.i '}'
    static iup := '{' this.sc.i ' up}'
    static idown := '{' this.sc.i ' down}'

    static o := '{' this.sc.o '}'
    static oup := '{' this.sc.o ' up}'
    static odown := '{' this.sc.o ' down}'

    static p := '{' this.sc.p '}'
    static pup := '{' this.sc.p ' up}'
    static pdown := '{' this.sc.p ' down}'

    static lbracket := '{' this.sc.lbracket '}'
    static lbracketup := '{' this.sc.lbracket ' up}'
    static lbracketdown := '{' this.sc.lbracket ' down}'

    static rbracket := '{' this.sc.rbracket '}'
    static rbracketup := '{' this.sc.rbracket ' up}'
    static rbracketdown := '{' this.sc.rbracket ' down}'

    static enter := '{' this.sc.enter '}'
    static enterup := '{' this.sc.enter ' up}'
    static enterdown := '{' this.sc.enter ' down}'

    static a := '{' this.sc.a '}'
    static aup := '{' this.sc.a ' up}'
    static adown := '{' this.sc.a ' down}'

    static s := '{' this.sc.s '}'
    static sup := '{' this.sc.s ' up}'
    static sdown := '{' this.sc.s ' down}'

    static d := '{' this.sc.d '}'
    static dup := '{' this.sc.d ' up}'
    static ddown := '{' this.sc.d ' down}'

    static f := '{' this.sc.f '}'
    static fup := '{' this.sc.f ' up}'
    static fdown := '{' this.sc.f ' down}'

    static g := '{' this.sc.g '}'
    static gup := '{' this.sc.g ' up}'
    static gdown := '{' this.sc.g ' down}'

    static h := '{' this.sc.h '}'
    static hup := '{' this.sc.h ' up}'
    static hdown := '{' this.sc.h ' down}'

    static j := '{' this.sc.j '}'
    static jup := '{' this.sc.j ' up}'
    static jdown := '{' this.sc.j ' down}'

    static k := '{' this.sc.k '}'
    static kup := '{' this.sc.k ' up}'
    static kdown := '{' this.sc.k ' down}'

    static l := '{' this.sc.l '}'
    static lup := '{' this.sc.l ' up}'
    static ldown := '{' this.sc.l ' down}'

    static semicolon := '{' this.sc.semicolon '}'
    static semicolonup := '{' this.sc.semicolon ' up}'
    static semicolondown := '{' this.sc.semicolon ' down}'

    static quote := '{' this.sc.quote '}'
    static quoteup := '{' this.sc.quote ' up}'
    static quotedown := '{' this.sc.quote ' down}'

    static backtick := '{' this.sc.backtick '}'
    static backtickup := '{' this.sc.backtick ' up}'
    static backtickdown := '{' this.sc.backtick ' down}'

    static backslash := '{' this.sc.backslash '}'
    static backslashup := '{' this.sc.backslash ' up}'
    static backslashdown := '{' this.sc.backslash ' down}'

    static z := '{' this.sc.z '}'
    static zup := '{' this.sc.z ' up}'
    static zdown := '{' this.sc.z ' down}'

    static x := '{' this.sc.x '}'
    static xup := '{' this.sc.x ' up}'
    static xdown := '{' this.sc.x ' down}'

    static c := '{' this.sc.c '}'
    static cup := '{' this.sc.c ' up}'
    static cdown := '{' this.sc.c ' down}'

    static v := '{' this.sc.v '}'
    static vup := '{' this.sc.v ' up}'
    static vdown := '{' this.sc.v ' down}'

    static b := '{' this.sc.b '}'
    static bup := '{' this.sc.b ' up}'
    static bdown := '{' this.sc.b ' down}'

    static n := '{' this.sc.n '}'
    static nup := '{' this.sc.n ' up}'
    static ndown := '{' this.sc.n ' down}'

    static m := '{' this.sc.m '}'
    static mup := '{' this.sc.m ' up}'
    static mdown := '{' this.sc.m ' down}'

    static comma := '{' this.sc.comma '}'
    static commaup := '{' this.sc.comma ' up}'
    static commadown := '{' this.sc.comma ' down}'

    static period := '{' this.sc.period '}'
    static periodup := '{' this.sc.period ' up}'
    static perioddown := '{' this.sc.period ' down}'

    static slash := '{' this.sc.slash '}'
    static slashup := '{' this.sc.slash ' up}'
    static slashdown := '{' this.sc.slash ' down}'

    static numpadMult := '{' this.sc.numpadMult '}'
    static numpadMultup := '{' this.sc.numpadMult ' up}'
    static numpadMultdown := '{' this.sc.numpadMult ' down}'

    static space := '{' this.sc.space '}'
    static spaceup := '{' this.sc.space ' up}'
    static spacedown := '{' this.sc.space ' down}'

    static capslock := '{' this.sc.capslock '}'
    static capslockup := '{' this.sc.capslock ' up}'
    static capslockdown := '{' this.sc.capslock ' down}'

    static f1 := '{' this.sc.f1 '}'
    static f1up := '{' this.sc.f1 ' up}'
    static f1down := '{' this.sc.f1 ' down}'
    
    static f2 := '{' this.sc.f2 '}'
    static f2up := '{' this.sc.f2 ' up}'
    static f2down := '{' this.sc.f2 ' down}'

    static f3 := '{' this.sc.f3 '}'
    static f3up := '{' this.sc.f3 ' up}'
    static f3down := '{' this.sc.f3 ' down}'

    static f4 := '{' this.sc.f4 '}'
    static f4up := '{' this.sc.f4 ' up}'
    static f4down := '{' this.sc.f4 ' down}'

    static f5 := '{' this.sc.f5 '}'
    static f5up := '{' this.sc.f5 ' up}'
    static f5down := '{' this.sc.f5 ' down}'

    static f6 := '{' this.sc.f6 '}'
    static f6up := '{' this.sc.f6 ' up}'
    static f6down := '{' this.sc.f6 ' down}'

    static f7 := '{' this.sc.f7 '}'
    static f7up := '{' this.sc.f7 ' up}'
    static f7down := '{' this.sc.f7 ' down}'

    static f8 := '{' this.sc.f8 '}'
    static f8up := '{' this.sc.f8 ' up}'
    static f8down := '{' this.sc.f8 ' down}'

    static f9 := '{' this.sc.f9 '}'
    static f9up := '{' this.sc.f9 ' up}'
    static f9down := '{' this.sc.f9 ' down}'

    static f10 := '{' this.sc.f10 '}'
    static f10up := '{' this.sc.f10 ' up}'
    static f10down := '{' this.sc.f10 ' down}'

    static numlock := '{' this.sc.numlock '}'
    static numlockup := '{' this.sc.numlock ' up}'
    static numlockdown := '{' this.sc.numlock ' down}'

    static scrolllock := '{' this.sc.scrolllock '}'
    static scrolllockup := '{' this.sc.scrolllock ' up}'
    static scrolllockdown := '{' this.sc.scrolllock ' down}'

    static numpad7 := '{' this.sc.numpad7 '}'
    static numpad7up := '{' this.sc.numpad7 ' up}'
    static numpad7down := '{' this.sc.numpad7 ' down}'

    static numpad8 := '{' this.sc.numpad8 '}'
    static numpad8up := '{' this.sc.numpad8 ' up}'
    static numpad8down := '{' this.sc.numpad8 ' down}'

    static numpad9 := '{' this.sc.numpad9 '}'
    static numpad9up := '{' this.sc.numpad9 ' up}'
    static numpad9down := '{' this.sc.numpad9 ' down}'

    static numpadMinus := '{' this.sc.numpadMinus '}'
    static numpadMinusup := '{' this.sc.numpadMinus ' up}'
    static numpadMinusdown := '{' this.sc.numpadMinus ' down}'

    static numpad4 := '{' this.sc.numpad4 '}'
    static numpad4up := '{' this.sc.numpad4 ' up}'
    static numpad4down := '{' this.sc.numpad4 ' down}'

    static numpad5 := '{' this.sc.numpad5 '}'
    static numpad5up := '{' this.sc.numpad5 ' up}'
    static numpad5down := '{' this.sc.numpad5 ' down}'

    static numpad6 := '{' this.sc.numpad6 '}'
    static numpad6up := '{' this.sc.numpad6 ' up}'
    static numpad6down := '{' this.sc.numpad6 ' down}'

    static numpadPlus := '{' this.sc.numpadPlus '}'
    static numpadPlusup := '{' this.sc.numpadPlus ' up}'
    static numpadPlusdown := '{' this.sc.numpadPlus ' down}'

    static numpad1 := '{' this.sc.numpad1 '}'
    static numpad1up := '{' this.sc.numpad1 ' up}'
    static numpad1down := '{' this.sc.numpad1 ' down}'

    static numpad2 := '{' this.sc.numpad2 '}'
    static numpad2up := '{' this.sc.numpad2 ' up}'
    static numpad2down := '{' this.sc.numpad2 ' down}'

    static numpad3 := '{' this.sc.numpad3 '}'
    static numpad3up := '{' this.sc.numpad3 ' up}'
    static numpad3down := '{' this.sc.numpad3 ' down}'

    static numpad0 := '{' this.sc.numpad0 '}'
    static numpad0up := '{' this.sc.numpad0 ' up}'
    static numpad0down := '{' this.sc.numpad0 ' down}'

    static numpadDot := '{' this.sc.numpadDot '}'
    static numpadDotup := '{' this.sc.numpadDot ' up}'
    static numpadDotdown := '{' this.sc.numpadDot ' down}'

    static f11 := '{' this.sc.f11 '}'
    static f11up := '{' this.sc.f11 ' up}'
    static f11down := '{' this.sc.f11 ' down}'

    static f12 := '{' this.sc.f12 '}'
    static f12up := '{' this.sc.f12 ' up}'
    static f12down := '{' this.sc.f12 ' down}'

    static numpadDiv := '{' this.sc.numpadDiv '}'
    static numpadDivup := '{' this.sc.numpadDiv ' up}'
    static numpadDivdown := '{' this.sc.numpadDiv ' down}'

    static printscreen := '{' this.sc.printscreen '}'
    static printscreenup := '{' this.sc.printscreen ' up}'
    static printscreendown := '{' this.sc.printscreen ' down}'

    static pause := '{' this.sc.pause '}'
    static pauseup := '{' this.sc.pause ' up}'
    static pausedown := '{' this.sc.pause ' down}'

    static home := '{' this.sc.home '}'
    static homeup := '{' this.sc.home ' up}'
    static homedown := '{' this.sc.home ' down}'

    ; static scUp := '{' this.sc.scup '}'
    ; static scupup := '{' this.sc.scup ' up}'
    ; static scupdown := '{' this.sc.scup ' down}'

    static pageup := '{' this.sc.pageup '}'
    static pageupup := '{' this.sc.pageup ' up}'
    static pageupdown := '{' this.sc.pageup ' down}'

    static left := '{' this.sc.left '}'
    static leftup := '{' this.sc.left ' up}'
    static leftdown := '{' this.sc.left ' down}'

    static right := '{' this.sc.right '}'
    static rightup := '{' this.sc.right ' up}'
    static rightdown := '{' this.sc.right ' down}'

    static end := '{' this.sc.end '}'
    static endup := '{' this.sc.end ' up}'
    static enddown := '{' this.sc.end ' down}'

    ; static scdown := '{' this.sc.scdown '}'
    ; static scdownup := '{' this.sc.scdown ' up}'
    ; static scdropdown := '{' this.sc.scdown ' down}'

    static pagedown := '{' this.sc.pagedown '}'
    static pagedownup := '{' this.sc.pagedown ' up}'
    static pagedowndown := '{' this.sc.pagedown ' down}'

    static insert := '{' this.sc.insert '}'
    static insertup := '{' this.sc.insert ' up}'
    static insertdown := '{' this.sc.insert ' down}'

    static delete := '{' this.sc.delete '}'
    static deleteup := '{' this.sc.delete ' up}'
    static deletedown := '{' this.sc.delete ' down}'

    static appskey := '{' this.sc.appskey '}'
    static appskeyup := '{' this.sc.appskey ' up}'
    static appskeydown := '{' this.sc.appskey ' down}'

    static menu := '{' this.sc.menu '}'
    static menuup := '{' this.sc.menu ' up}'
    static menudown := '{' this.sc.menu ' down}'

    static hznsave := this.altdown this.f this.s this.altup
    static hznOpenRTF := this.ctrldown this.shiftdown this.c this.shiftup this.ctrlup
    
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
    ;     ;         Set: (*) => prop := '{' value '{',
    ;     ;         Get: (*) => prop
    ;     ;     })
    ;     ;     this.DefineProp(prop "down", {
    ;     ;         Set: (*) => prop := '{' value ' down}',
    ;     ;         Get: (*) => prop
    ;     ;     })
    ;     ;     this.DefineProp(prop "up", {
    ;     ;         Set: (*) => prop := '{' . value . this.syntax.up . '}',
    ;     ;         Get: (*) => prop
    ;     ;     })
    ;     ; }
    ;     ;     this.DefineProp(prop . "down", {
    ;     ;         Get: (*) => '{' . value . this.syntax.down . '}',
    ;     ;     })
    ;     ;     this.DefineProp(prop . "up", {
    ;     ;         Get: (*) => '{' . value . this.syntax.up . '}',
    ;     ;     })
    ;     ; }
    ;     */
    ;     ; /*
    ;     ; Define individual key properties for all keys in sc class
    ;     this.esc := '{' this.sc.esc '}'
    ;     this.escup := '{' this.sc.esc ' up}'
    ;     this.escdown := '{' this.sc.esc ' down}'

    ;     this.1 := '{' this.sc.1 '}'
    ;     this.1up := '{' this.sc.1 ' up}'
    ;     this.1down := '{' this.sc.1 ' down}'

    ;     this.2 := '{' this.sc.2 '}'
    ;     this.2up := '{' this.sc.2 ' up}'
    ;     this.2down := '{' this.sc.2 ' down}'

    ;     this.3 := '{' this.sc.3 '}'
    ;     this.3up := '{' this.sc.3 ' up}'
    ;     this.3down := '{' this.sc.3 ' down}'

    ;     this.4 := '{' this.sc.4 '}'
    ;     this.4up := '{' this.sc.4 ' up}'
    ;     this.4down := '{' this.sc.4 ' down}'

    ;     this.5 := '{' this.sc.5 '}'
    ;     this.5up := '{' this.sc.5 ' up}'
    ;     this.5down := '{' this.sc.5 ' down}'

    ;     this.6 := '{' this.sc.6 '}'
    ;     this.6up := '{' this.sc.6 ' up}'
    ;     this.6down := '{' this.sc.6 ' down}'

    ;     this.7 := '{' this.sc.7 '}'
    ;     this.7up := '{' this.sc.7 ' up}'
    ;     this.7down := '{' this.sc.7 ' down}'

    ;     this.8 := '{' this.sc.8 '}'
    ;     this.8up := '{' this.sc.8 ' up}'
    ;     this.8down := '{' this.sc.8 ' down}'

    ;     this.9 := '{' this.sc.9 '}'
    ;     this.9up := '{' this.sc.9 ' up}'
    ;     this.9down := '{' this.sc.9 ' down}'

    ;     this.0 := '{' this.sc.0 '}'
    ;     this.0up := '{' this.sc.0 ' up}'
    ;     this.0down := '{' this.sc.0 ' down}'

    ;     this.minus := '{' this.sc.minus '}'
    ;     this.minusup := '{' this.sc.minus ' up}'
    ;     this.minusdown := '{' this.sc.minus ' down}'

    ;     this.equal := '{' this.sc.equal '}'
    ;     this.equalup := '{' this.sc.equal ' up}'
    ;     this.equaldown := '{' this.sc.equal ' down}'

    ;     this.backspace := '{' this.sc.backspace '}'
    ;     this.backspaceup := '{' this.sc.backspace ' up}'
    ;     this.backspacedown := '{' this.sc.backspace ' down}'

    ;     this.tab := '{' this.sc.tab '}'
    ;     this.tabup := '{' this.sc.tab ' up}'
    ;     this.tabdown := '{' this.sc.tab ' down}'

    ;     this.q := '{' this.sc.q '}'
    ;     this.qup := '{' this.sc.q ' up}'
    ;     this.qdown := '{' this.sc.q ' down}'

    ;     this.w := '{' this.sc.w '}'
    ;     this.wup := '{' this.sc.w ' up}'
    ;     this.wdown := '{' this.sc.w ' down}'

    ;     this.e := '{' this.sc.e '}'
    ;     this.eup := '{' this.sc.e ' up}'
    ;     this.edown := '{' this.sc.e ' down}'

    ;     this.r := '{' this.sc.r '}'
    ;     this.rup := '{' this.sc.r ' up}'
    ;     this.rdown := '{' this.sc.r ' down}'

    ;     this.t := '{' this.sc.t '}'
    ;     this.tup := '{' this.sc.t ' up}'
    ;     this.tdown := '{' this.sc.t ' down}'

    ;     this.y := '{' this.sc.y '}'
    ;     this.yup := '{' this.sc.y ' up}'
    ;     this.ydown := '{' this.sc.y ' down}'

    ;     this.u := '{' this.sc.u '}'
    ;     this.uup := '{' this.sc.u ' up}'
    ;     this.udown := '{' this.sc.u ' down}'

    ;     this.i := '{' this.sc.i '}'
    ;     this.iup := '{' this.sc.i ' up}'
    ;     this.idown := '{' this.sc.i ' down}'

    ;     this.o := '{' this.sc.o '}'
    ;     this.oup := '{' this.sc.o ' up}'
    ;     this.odown := '{' this.sc.o ' down}'

    ;     this.p := '{' this.sc.p '}'
    ;     this.pup := '{' this.sc.p ' up}'
    ;     this.pdown := '{' this.sc.p ' down}'

    ;     '{'racket := '{' this.sc.lbracket '}'
    ;     '{'racketup := '{' this.sc.lbracket ' up}'
    ;     '{'racketdown := '{' this.sc.lbracket ' down}'

    ;     '}'racket := '{' this.sc.rbracket '}'
    ;     '}'racketup := '{' this.sc.rbracket ' up}'
    ;     '}'racketdown := '{' this.sc.rbracket ' down}'

    ;     this.enter := '{' this.sc.enter '}'
    ;     this.enterup := '{' this.sc.enter ' up}'
    ;     this.enterdown := '{' this.sc.enter ' down}'

    ;     this.ctrl := '{' this.sc.ctrl '}'
    ;     this.ctrlup := '{' this.sc.ctrl ' up}'
    ;     this.ctrldown := '{' this.sc.ctrl ' down}'

    ;     this.lctrl := '{' this.sc.lctrl '}'
    ;     this.lctrlup := '{' this.sc.lctrl ' up}'
    ;     this.lctrldown := '{' this.sc.lctrl ' down}'

    ;     this.a := '{' this.sc.a '}'
    ;     this.aup := '{' this.sc.a ' up}'
    ;     this.adown := '{' this.sc.a ' down}'

    ;     this.s := '{' this.sc.s '}'
    ;     this.sup := '{' this.sc.s ' up}'
    ;     this.sdown := '{' this.sc.s ' down}'

    ;     this.d := '{' this.sc.d '}'
    ;     this.dup := '{' this.sc.d ' up}'
    ;     this.ddown := '{' this.sc.d ' down}'

    ;     this.f := '{' this.sc.f '}'
    ;     this.fup := '{' this.sc.f ' up}'
    ;     this.fdown := '{' this.sc.f ' down}'

    ;     this.g := '{' this.sc.g '}'
    ;     this.gup := '{' this.sc.g ' up}'
    ;     this.gdown := '{' this.sc.g ' down}'

    ;     this.h := '{' this.sc.h '}'
    ;     this.hup := '{' this.sc.h ' up}'
    ;     this.hdown := '{' this.sc.h ' down}'

    ;     this.j := '{' this.sc.j '}'
    ;     this.jup := '{' this.sc.j ' up}'
    ;     this.jdown := '{' this.sc.j ' down}'

    ;     this.k := '{' this.sc.k '}'
    ;     this.kup := '{' this.sc.k ' up}'
    ;     this.kdown := '{' this.sc.k ' down}'

    ;     this.l := '{' this.sc.l '}'
    ;     this.lup := '{' this.sc.l ' up}'
    ;     this.ldown := '{' this.sc.l ' down}'

    ;     this.semicolon := '{' this.sc.semicolon '}'
    ;     this.semicolonup := '{' this.sc.semicolon ' up}'
    ;     this.semicolondown := '{' this.sc.semicolon ' down}'

    ;     this.quote := '{' this.sc.quote '}'
    ;     this.quoteup := '{' this.sc.quote ' up}'
    ;     this.quotedown := '{' this.sc.quote ' down}'

    ;     this.backtick := '{' this.sc.backtick '}'
    ;     this.backtickup := '{' this.sc.backtick ' up}'
    ;     this.backtickdown := '{' this.sc.backtick ' down}'

    ;     this.shift := '{' this.sc.shift '}'
    ;     this.shiftup := '{' this.sc.shift ' up}'
    ;     this.shiftdown := '{' this.sc.shift ' down}'

    ;     this.lshift := '{' this.sc.lshift '}'
    ;     this.lshiftup := '{' this.sc.lshift ' up}'
    ;     this.lshiftdown := '{' this.sc.lshift ' down}'

    ;     this.backslash := '{' this.sc.backslash '}'
    ;     this.backslashup := '{' this.sc.backslash ' up}'
    ;     this.backslashdown := '{' this.sc.backslash ' down}'

    ;     this.z := '{' this.sc.z '}'
    ;     this.zup := '{' this.sc.z ' up}'
    ;     this.zdown := '{' this.sc.z ' down}'

    ;     this.x := '{' this.sc.x '}'
    ;     this.xup := '{' this.sc.x ' up}'
    ;     this.xdown := '{' this.sc.x ' down}'

    ;     this.c := '{' this.sc.c '}'
    ;     this.cup := '{' this.sc.c ' up}'
    ;     this.cdown := '{' this.sc.c ' down}'

    ;     this.v := '{' this.sc.v '}'
    ;     this.vup := '{' this.sc.v ' up}'
    ;     this.vdown := '{' this.sc.v ' down}'

    ;     this.b := '{' this.sc.b '}'
    ;     this.bup := '{' this.sc.b ' up}'
    ;     this.bdown := '{' this.sc.b ' down}'

    ;     this.n := '{' this.sc.n '}'
    ;     this.nup := '{' this.sc.n ' up}'
    ;     this.ndown := '{' this.sc.n ' down}'

    ;     this.m := '{' this.sc.m '}'
    ;     this.mup := '{' this.sc.m ' up}'
    ;     this.mdown := '{' this.sc.m ' down}'

    ;     this.comma := '{' this.sc.comma '}'
    ;     this.commaup := '{' this.sc.comma ' up}'
    ;     this.commadown := '{' this.sc.comma ' down}'

    ;     this.period := '{' this.sc.period '}'
    ;     this.periodup := '{' this.sc.period ' up}'
    ;     this.perioddown := '{' this.sc.period ' down}'

    ;     this.slash := '{' this.sc.slash '}'
    ;     this.slashup := '{' this.sc.slash ' up}'
    ;     this.slashdown := '{' this.sc.slash ' down}'

    ;     this.rshift := '{' this.sc.rshift '}'
    ;     this.rshiftup := '{' this.sc.rshift ' up}'
    ;     this.rshiftdown := '{' this.sc.rshift ' down}'

    ;     this.numpadMult := '{' this.sc.numpadMult '}'
    ;     this.numpadMultup := '{' this.sc.numpadMult ' up}'
    ;     this.numpadMultdown := '{' this.sc.numpadMult ' down}'

    ;     this.alt := '{' this.sc.alt '}'
    ;     this.altup := '{' this.sc.alt ' up}'
    ;     this.altdown := '{' this.sc.alt ' down}'

    ;     this.lalt := '{' this.sc.lalt '}'
    ;     this.laltup := '{' this.sc.lalt ' up}'
    ;     this.laltdown := '{' this.sc.lalt ' down}'

    ;     this.space := '{' this.sc.space '}'
    ;     this.spaceup := '{' this.sc.space ' up}'
    ;     this.spacedown := '{' this.sc.space ' down}'

    ;     this.capslock := '{' this.sc.capslock '}'
    ;     this.capslockup := '{' this.sc.capslock ' up}'
    ;     this.capslockdown := '{' this.sc.capslock ' down}'

    ;     this.f1 := '{' this.sc.f1 '}'
    ;     this.f1up := '{' this.sc.f1 ' up}'
    ;     this.f1down := '{' this.sc.f1 ' down}'

    ;     this.f2 := '{' this.sc.f2 '}'
    ;     this.f2up := '{' this.sc.f2 ' up}'
    ;     this.f2down := '{' this.sc.f2 ' down}'

    ;     this.f3 := '{' this.sc.f3 '}'
    ;     this.f3up := '{' this.sc.f3 ' up}'
    ;     this.f3down := '{' this.sc.f3 ' down}'

    ;     this.f4 := '{' this.sc.f4 '}'
    ;     this.f4up := '{' this.sc.f4 ' up}'
    ;     this.f4down := '{' this.sc.f4 ' down}'

    ;     this.f5 := '{' this.sc.f5 '}'
    ;     this.f5up := '{' this.sc.f5 ' up}'
    ;     this.f5down := '{' this.sc.f5 ' down}'

    ;     this.f6 := '{' this.sc.f6 '}'
    ;     this.f6up := '{' this.sc.f6 ' up}'
    ;     this.f6down := '{' this.sc.f6 ' down}'

    ;     this.f7 := '{' this.sc.f7 '}'
    ;     this.f7up := '{' this.sc.f7 ' up}'
    ;     this.f7down := '{' this.sc.f7 ' down}'

    ;     this.f8 := '{' this.sc.f8 '}'
    ;     this.f8up := '{' this.sc.f8 ' up}'
    ;     this.f8down := '{' this.sc.f8 ' down}'

    ;     this.f9 := '{' this.sc.f9 '}'
    ;     this.f9up := '{' this.sc.f9 ' up}'
    ;     this.f9down := '{' this.sc.f9 ' down}'

    ;     this.f10 := '{' this.sc.f10 '}'
    ;     this.f10up := '{' this.sc.f10 ' up}'
    ;     this.f10down := '{' this.sc.f10 ' down}'

    ;     this.numlock := '{' this.sc.numlock '}'
    ;     this.numlockup := '{' this.sc.numlock ' up}'
    ;     this.numlockdown := '{' this.sc.numlock ' down}'

    ;     this.scrolllock := '{' this.sc.scrolllock '}'
    ;     this.scrolllockup := '{' this.sc.scrolllock ' up}'
    ;     this.scrolllockdown := '{' this.sc.scrolllock ' down}'

    ;     this.numpad7 := '{' this.sc.numpad7 '}'
    ;     this.numpad7up := '{' this.sc.numpad7 ' up}'
    ;     this.numpad7down := '{' this.sc.numpad7 ' down}'

    ;     this.numpad8 := '{' this.sc.numpad8 '}'
    ;     this.numpad8up := '{' this.sc.numpad8 ' up}'
    ;     this.numpad8down := '{' this.sc.numpad8 ' down}'

    ;     this.numpad9 := '{' this.sc.numpad9 '}'
    ;     this.numpad9up := '{' this.sc.numpad9 ' up}'
    ;     this.numpad9down := '{' this.sc.numpad9 ' down}'

    ;     this.numpadMinus := '{' this.sc.numpadMinus '}'
    ;     this.numpadMinusup := '{' this.sc.numpadMinus ' up}'
    ;     this.numpadMinusdown := '{' this.sc.numpadMinus ' down}'

    ;     this.numpad4 := '{' this.sc.numpad4 '}'
    ;     this.numpad4up := '{' this.sc.numpad4 ' up}'
    ;     this.numpad4down := '{' this.sc.numpad4 ' down}'

    ;     this.numpad5 := '{' this.sc.numpad5 '}'
    ;     this.numpad5up := '{' this.sc.numpad5 ' up}'
    ;     this.numpad5down := '{' this.sc.numpad5 ' down}'

    ;     this.numpad6 := '{' this.sc.numpad6 '}'
    ;     this.numpad6up := '{' this.sc.numpad6 ' up}'
    ;     this.numpad6down := '{' this.sc.numpad6 ' down}'

    ;     this.numpadPlus := '{' this.sc.numpadPlus '}'
    ;     this.numpadPlusup := '{' this.sc.numpadPlus ' up}'
    ;     this.numpadPlusdown := '{' this.sc.numpadPlus ' down}'

    ;     this.numpad1 := '{' this.sc.numpad1 '}'
    ;     this.numpad1up := '{' this.sc.numpad1 ' up}'
    ;     this.numpad1down := '{' this.sc.numpad1 ' down}'

    ;     this.numpad2 := '{' this.sc.numpad2 '}'
    ;     this.numpad2up := '{' this.sc.numpad2 ' up}'
    ;     this.numpad2down := '{' this.sc.numpad2 ' down}'

    ;     this.numpad3 := '{' this.sc.numpad3 '}'
    ;     this.numpad3up := '{' this.sc.numpad3 ' up}'
    ;     this.numpad3down := '{' this.sc.numpad3 ' down}'

    ;     this.numpad0 := '{' this.sc.numpad0 '}'
    ;     this.numpad0up := '{' this.sc.numpad0 ' up}'
    ;     this.numpad0down := '{' this.sc.numpad0 ' down}'

    ;     this.numpadDot := '{' this.sc.numpadDot '}'
    ;     this.numpadDotup := '{' this.sc.numpadDot ' up}'
    ;     this.numpadDotdown := '{' this.sc.numpadDot ' down}'

    ;     this.f11 := '{' this.sc.f11 '}'
    ;     this.f11up := '{' this.sc.f11 ' up}'
    ;     this.f11down := '{' this.sc.f11 ' down}'

    ;     this.f12 := '{' this.sc.f12 '}'
    ;     this.f12up := '{' this.sc.f12 ' up}'
    ;     this.f12down := '{' this.sc.f12 ' down}'

    ;     this.rctrl := '{' this.sc.rctrl '}'
    ;     this.rctrlup := '{' this.sc.rctrl ' up}'
    ;     this.rctrldown := '{' this.sc.rctrl ' down}'

    ;     this.numpadDiv := '{' this.sc.numpadDiv '}'
    ;     this.numpadDivup := '{' this.sc.numpadDiv ' up}'
    ;     this.numpadDivdown := '{' this.sc.numpadDiv ' down}'

    ;     this.printscreen := '{' this.sc.printscreen '}'
    ;     this.printscreenup := '{' this.sc.printscreen ' up}'
    ;     this.printscreendown := '{' this.sc.printscreen ' down}'

    ;     this.ralt := '{' this.sc.ralt '}'
    ;     this.raltup := '{' this.sc.ralt ' up}'
    ;     this.raltdown := '{' this.sc.ralt ' down}'

    ;     this.pause := '{' this.sc.pause '}'
    ;     this.pauseup := '{' this.sc.pause ' up}'
    ;     this.pausedown := '{' this.sc.pause ' down}'

    ;     this.home := '{' this.sc.home '}'
    ;     this.homeup := '{' this.sc.home ' up}'
    ;     this.homedown := '{' this.sc.home ' down}'
    ;     /*
    ;     ; this.up := '{' this.sc.up '}'
    ;     ; this.upup := '{' this.sc.up ' up}'
    ;     ; this.updown := '{' this.sc.up ' down}'
    ;     */
    ;     this.pageup := '{' this.sc.pageup '}'
    ;     this.pageupup := '{' this.sc.pageup ' up}'
    ;     this.pageupdown := '{' this.sc.pageup ' down}'

    ;     this.left := '{' this.sc.left '}'
    ;     this.leftup := '{' this.sc.left ' up}'
    ;     this.leftdown := '{' this.sc.left ' down}'

    ;     this.right := '{' this.sc.right '}'
    ;     this.rightup := '{' this.sc.right ' up}'
    ;     this.rightdown := '{' this.sc.right ' down}'

    ;     this.end := '{' this.sc.end '}'
    ;     this.endup := '{' this.sc.end ' up}'
    ;     this.enddown := '{' this.sc.end ' down}'
    ;     /*
    ;     ; this.down := '{' this.sc.down '}'
    ;     ; this.downup := '{' this.sc.down ' up}'
    ;     ; this.dropdown := '{' this.sc.down ' down}'
    ;     */
    ;     this.pagedown := '{' this.sc.pagedown '}'
    ;     this.pagedownup := '{' this.sc.pagedown ' up}'
    ;     this.pagedowndown := '{' this.sc.pagedown ' down}'

    ;     this.insert := '{' this.sc.insert '}'
    ;     this.insertup := '{' this.sc.insert ' up}'
    ;     this.insertdown := '{' this.sc.insert ' down}'

    ;     this.delete := '{' this.sc.delete '}'
    ;     this.deleteup := '{' this.sc.delete ' up}'
    ;     this.deletedown := '{' this.sc.delete ' down}'

    ;     this.win := '{' this.sc.win '}'
    ;     this.winup := '{' this.sc.win ' up}'
    ;     this.windown := '{' this.sc.win ' down}'

    ;     this.lwin := '{' this.sc.lwin '}'
    ;     this.lwinup := '{' this.sc.lwin ' up}'
    ;     this.lwindown := '{' this.sc.lwin ' down}'

    ;     this.rwin := '{' this.sc.rwin '}'
    ;     this.rwinup := '{' this.sc.rwin ' up}'
    ;     this.rwindown := '{' this.sc.rwin ' down}'

    ;     this.appskey := '{' this.sc.appskey '}'
    ;     this.appskeyup := '{' this.sc.appskey ' up}'
    ;     this.appskeydown := '{' this.sc.appskey ' down}'

    ;     this.menu := '{' this.sc.menu '}'
    ;     this.menuup := '{' this.sc.menu ' up}'
    ;     this.menudown := '{' this.sc.menu ' down}'
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
