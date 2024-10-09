#Requires AutoHotkey v2+
; #Include <Directives\__AE.v2>
#Include <Includes\ObjectTypeExtensions>

class Clip {
    static defaultEndChar := ''
    static defaultIsClipReverted := true
    static defaultUntilRevert := 500

	/************************************************************************
	* @description Get the handle of the focused control
	* @context_sensitive Yes
	* @example this.hfCtl(&fCtl)
	***********************************************************************/
	static hfCtl(&fCtl?) {
		return fCtl := ControlGetFocus('A')
	}

	static fCtl(&hCtl?) => hCtl := ControlGetFocus('A')
    /**
     * @param {String|Array|Map|Object|Class} input The content to send
     * @param {String} endChar The ending character(s) to append
     * @param {Boolean} isClipReverted Whether to revert the clipboard
     * @param {Integer} untilRevert Time in ms before reverting the clipboard
     * @returns {String} The sent content
     */
    static Send(input?, endChar := '', isClipReverted := true, untilRevert := 500) {
        prevClip := '', content := ''
        AE()
		AE.SM_BISL(&sm)
        if (!IsSet(input)) {
            input := this
        }

        content := this.ConvertToString(input)

        isClipReverted ? (prevClip := ClipboardAll()) : 0
		
		try Infos('input: ' input
				'`n'
				'content: ' content
				'`n'
				'isClipReverted: ' isClipReverted
				'`n'
				'A_Clipboard: ' A_Clipboard
			)
		
		this.cSleep(100)

		this.ClearClipboard()

		this.cSleep(100)
		try Infos('A_Clipboard (after clear): ' A_Clipboard)
        A_Clipboard := content . endChar
		
		this.cSleep(100)

        SetTimer(() => Send('{sc2A Down}{sc152}{sc2A Up}'), -ClipWait(1)) 	;! {Shift}{Insert}
        ; SetTimer(() => Send('{sc1D Down}{sc2F}{sc1D Up}'), -ClipWait(1)) 	;! {Control}{v}

        ; isClipReverted ? SetTimer((*) => A_Clipboard := prevClip, -untilRevert) : 0
        isClipReverted ? SetTimer((*) => A_Clipboard := prevClip, untilRevert) : 0

        return content
    }

    /**
     * @param {Any} input The input to convert to string
     * @returns {String} The converted string
     */
    static ConvertToString(input) {
        switch Type(input) {
            case 'String':
                return input
            case 'Array':
                return input.Join('')
            case 'Map':
                return input.ToString()
            case 'Object':
                return jsongo.Stringify(input)
			case 'Initializable':
				return jsongo.Stringify(input)
            default:
				return input
        }
    }

	static SendMsgPaste() => (*) => SendMessage(0x0302, 0, 0, ControlGetFocus('A'), 'A')
	
	/************************************************************************
	* @description Sleep while clipboard is in use
	* @example AE._Clipboard_Sleep(10)
	***********************************************************************/
	; static _Clipboard_Sleep(n := 10) {
	;     loop n {
	;         Sleep(n)
	;     } Until (!this.GetOpenClipboardWindow() || (A_Index = 50))
	; }

	/************************************************************************
	* @description Wait for the clipboard to be available
	* @example AE.WaitForClipboard()
	***********************************************************************/
	; static WaitForClipboard(timeout := 1000) {
	; 	startTime := A_TickCount
	; 	while (this.IsClipboardBusy()) {
	; 		if (A_TickCount - startTime > timeout) {
	; 			throw Error("Clipboard timeout")
	; 		}
	; 		Sleep(10)
	; 	}
	; }
	static WaitForClipboard(timeout := 1000) {
		clipboardReady := false
		startTime := A_TickCount

		checkClipboard := (*) => _checkClipboard()
		_checkClipboard() {
			if (!this.IsClipboardBusy()) {
				clipboardReady := true
				SetTimer(checkClipboard, 0)  ; Turn off the timer
			} else if (A_TickCount - startTime > timeout) {
				SetTimer(checkClipboard, 0)  ; Turn off the timer
				; throw Error("Clipboard timeout")
			}
		}
		
		SetTimer(checkClipboard, 10)  ; Check every 10ms

		; Wait for the clipboard to be ready or for a timeout
		while (!clipboardReady) {
			Sleep(10)
		}
	}
	
	; static cSleep(n := 10) => this._Clipboard_Sleep(n)
	static cSleep(n := 10) => this.WaitForClipboard(n)
	/************************************************************************
		* @description Safely copy content to clipboard with verification
		* @context_sensitive Yes
		* @example result := AE.SafeCopyToClipboard()
		***********************************************************************/
	static SafeCopyToClipboard() {
		; cBak := this.BackupAndClearClipboard()
		cBak := ''
		this.BackupAndClearClipboard(&cBak)
		this.WaitForClipboard()
		this.SelectAllText()
		this.CopyToClipboard()
		this.WaitForClipboard()
		clipContent := this.GetClipboardText()
		return clipContent
	}

	/************************************************************************
	* @description Backup current clipboard content and clear it
	* @example cBak := AE.BackupAndClearClipboard()
	***********************************************************************/
	static BackupAndClearClipboard(&backup?) {
		; backup := DllCall("OleGetClipboard", "Ptr", 0, "Ptr")
		backup := DllCall('ole32\OleGetClipboard', 'Ptr', 0, 'Ptr')
		DllCall('OpenClipboard')
		DllCall("EmptyClipboard")
		DllCall('CloseClipboard')
		return backup
	}

	/************************************************************************
	* @description Select all text in the focused control
	* @context_sensitive Yes
	* @example AE.SelectAllText()
	***********************************************************************/
	static SelectAllText() {
		static EM_SETSEL := 0x00B1
		hCtl := this.hfCtl()
		DllCall("SendMessage", "Ptr", hCtl, "UInt", EM_SETSEL, "Ptr", 0, "Ptr", -1)
	}

	/************************************************************************
	* @description Copy selected text to clipboard
	* @context_sensitive Yes
	* @example AE.CopyToClipboard()
	***********************************************************************/
	static CopyToClipboard() {
		static WM_COPY := 0x0301
		hCtl := this.hfCtl()
		DllCall("SendMessage", "Ptr", hCtl, "UInt", WM_COPY, "Ptr", 0, "Ptr", 0)
	}

	/************************************************************************
	* @description Check if the clipboard is currently busy
	* @example if AE.IsClipboardBusy()
	***********************************************************************/
	static IsClipboardBusy() {
		return DllCall("GetOpenClipboardWindow", "Ptr") ;!= 0
	}

	/************************************************************************
	* @description Get text from clipboard using DllCalls
	* @example clipText := AE.GetClipboardText()
	***********************************************************************/
	static GetClipboardText(hData?) {
		Infos(hData)
		; if (!DllCall("OpenClipboard", "Ptr", 0)) {
		if (!DllCall("OpenClipboard")) {
			return ""
		}
		if (hData == 0){
			hData := DllCall("GetClipboardData", "UInt", 1, "Ptr") ; CF_UNICODETEXT := 13, CF_TEXT := 1
		}
		if (hData == 0) {
			DllCall("CloseClipboard")
			return ""
		}
		
		DllCall("GlobalUnlock", "Ptr", hData)

		pData := DllCall("GlobalLock", "Ptr", hData, "Ptr")
		if (pData == 0) {
			DllCall("CloseClipboard")
			return ""
		}

		text := StrGet(pData, "UTF-8")

		DllCall("GlobalUnlock", "Ptr", hData)
		DllCall("CloseClipboard")

		return text
	}
	/************************************************************************
	* @description Empty the clipboard
	* @example this.EmptyClipboard()
	***********************************************************************/
	static EmptyClipboard() => DllCall("User32.dll\EmptyClipboard", "Int")
	static ClearClipboard() {
		arrError := []
		hWndGetClipOpen  	:= this.GetOpenClipboardWindow()
		errhWndClipOpen		:= 'errhWndClipOpen: ' A_LastError
		arrError.SafePush(errhWndClipOpen)
		hWndClipOwn 		:= DllCall('GetClipboardOwner')
		errhWndClipOwn		:= 'errhWndClipOwn: ' A_LastError
		arrError.SafePush(errhWndClipOwn)
		clipUnlock 	  		:= DllCall('Kernel32.dll\GlobalUnlock', 'Ptr', !hWndGetClipOpen ? hWndClipOwn : 0)
		errclipUnlock		:= 'errclipUnlock: ' A_LastError
		arrError.SafePush(errclipUnlock)
		clipOpen 	  		:= DllCall('User32.dll\OpenClipboard')
		errclipOpen			:= 'errclipOpen: ' A_LastError
		arrError.SafePush(errclipOpen)
		clipEmpty 			:= DllCall("User32.dll\EmptyClipboard")
		errclipEmpty		:= 'errclipEmpty: ' A_LastError
		arrError.SafePush(errclipEmpty)
		clipClose 			:= DllCall('User32.dll\CloseClipboard')
		errclipClose		:= 'errclipClose: ' A_LastError
		clipUnlockAfter 	:= DllCall('Kernel32.dll\GlobalUnlock', 'Ptr', !hWndGetClipOpen ? hWndClipOwn : 0)
		errclipUnlockAfter	:= 'clipUnlockAfter: ' A_LastError
		arrError.SafePush(errclipClose)
		
		for each, value in arrError {
			ErrorObj := {}
			ErrorObj := error_list(value)
			Infos(ErrorObj.code '`t' 'Error message: ' ErrorObj.desc)
		}
		
		error_list(errorcode?, &ErrorObj:={code:0, desc:''}) {
			mapError := Map(
				0, 'ERROR_SUCCESS',
				1, 'ERROR_INVALID_FUNCTION',
				2, 'ERROR_FILE_NOT_FOUND',
				3, 'ERROR_PATH_NOT_FOUND',
				4, 'ERROR_TOO_MANY_OPEN_FILES',
				5, 'ERROR_ACCESS_DENIED',
				6, 'ERROR_INVALID_HANDLE',
				7, 'ERROR_ARENA_TRASHED',
				8, 'ERROR_NOT_ENOUGH_MEMORY',
				9, 'ERROR_INVALID_BLOCK'
			)

			; if mapError.Has(errorcode) {
			; 	Infos('System error #: ' errorcode '`tError message: ' mapError[error])
			; }
			; else {
			; 	Infos('System error #: ' errorcode '`tError message: Not in Map' )
			; }
			desc:=(mapError.Has(ErrorObj.code)? 'Error message: ' mapError[ErrorObj.code] : 'Error message: Not in Map')
			; Make a faulty system function call
			; DllCall('GetHandleInformation')
			; Error is set to 6
			; Infos('System error number: ' A_LastError
			; 	'`nError message: ' mapError[A_LastError])
			return ErrorObj := {code:errorcode, desc: desc}
		}
	}

	/************************************************************************
	* @description Close the clipboard
	* @example AE.CloseClipboard()
	***********************************************************************/
	static CloseClipboard() => DllCall("User32.dll\CloseClipboard", "Int")

	/************************************************************************
	* @description Get the handle of the window with an open clipboard
	* @example AE.GetOpenClipboardWindow()
	***********************************************************************/
	static GetOpenClipboardWindow() => DllCall("User32.dll\GetOpenClipboardWindow", "Ptr")
	static GetOpenClipWin() => this.GetOpenClipboardWindow()

	/************************************************************************
	* @description Backup and clear clipboard
	* @example AE._Clipboard_Backup_Clear(&cBak)
	***********************************************************************/
	/**
	 * @description Backup ClipboardAll() and clear clipboard
	 * @param cBak 
	 * @returns {ClipboardAll} 
	 */
	static cBakClr(&cBak?) => this._Clipboard_Backup_Clear(&cBak?)
	static _Clipboard_Backup_Clear(&cBak?) {
		ClipObj := {
			cBak : cBak,
			hWndClipOpen  : hWndClipOpen  := this.GetOpenClipboardWindow(),
			hWndClipOwner : hWndClipOwner := DllCall('GetClipboardOwner')
		}
		cBak := ClipboardAll()
		; this.EmptyClipboard()
		; this.cSleep(100)
		; this.CloseClipboard()
		hWndClipOpen  := this.GetOpenClipboardWindow()
		hWndClipOwner := DllCall('GetClipboardOwner')
		DllCall("GlobalUnlock", "Ptr", !hWndClipOpen ? hWndClipOwner : 0)
		DllCall('OpenClipboard')
		DllCall("EmptyClipboard")
		DllCall('CloseClipboard')
		return (cBak, ClipObj)
	}

	/************************************************************************
	* @description Restore clipboard from backup
	* @example AE._Clipboard_Restore(cBak)
	***********************************************************************/
	static _Clipboard_Restore(cBak) {
		SetTimer(() => this.cSleep(50), -500)
		A_Clipboard := cBak
		this.CloseClipboard()
	}
	static cRestore(cBak) => this._Clipboard_Restore(cBak)

}
