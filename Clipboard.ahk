#Requires AutoHotkey v2+
; #Include <Directives\__AE.v2>
#Include <Includes\ObjectTypeExtensions>

global A_Delay := Clip.delayTime

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
		fCtl := ControlGetFocus()
		return fCtl
	}

	static fCtl(&hCtl?) {
		hCtl := ControlGetFocus('A')
		return hCtl
	}

	/************************************************************************
	* @description Initialize the class with default settings
	* @example AE class is Initiated
	***********************************************************************/
	static __New() {
		this.DH(1)
		this.SetDelays(-1)
		this.SM()
	}

	/************************************************************************
	* @description Set SendMode, SendLevel, and BlockInput
	* @example AE.SM_BISL(&SendModeObj, 1)
	***********************************************************************/
	static _SendMode_SendLevel_BlockInput(&SendModeObj?, n := 1) {
		this.SM(&SendModeObj)
		this.BISL(1)
		return SendModeObj
	}
	static SM_BISL(&SendModeObj?, n := 1) => this._SendMode_SendLevel_BlockInput(&SendModeObj?, n:=1)
	/************************************************************************
	* @description Change SendMode and SetKeyDelay
	* @example AE.SM(&SendModeObj)
	* @var {Object} : SendModeObject,
	* @var {Integer} : s: A_SendMode,
			d: A_KeyDelay,
			p: A_KeyDuration
	***********************************************************************/
	static _SendMode(&SendModeObj := {}) {
		SendModeObj := {
			s: A_SendMode,
			d: A_KeyDelay,
			p: A_KeyDuration
		}
		SendMode('Event')
		SetKeyDelay(-1, -1)
		return SendModeObj
	}
	static SM(&SendModeObj?) => this._SendMode(&SendModeObj?)

	/************************************************************************
	* @description Restore SendMode and SetKeyDelay
	* @example Clip.rSM(RestoreObject)
	***********************************************************************/
	static _RestoreSendMode(RestoreObject) {
		SetKeyDelay(RestoreObject.d, RestoreObject.p)
		SendMode(RestoreObject.s)
	}
	static rSM(RestoreObject) => this._RestoreSendMode(RestoreObject)
		/************************************************************************
	* @description Set BlockInput and SendLevel
	* @example AE.BISL(1)
	* @var {Integer} : Send_Level := A_SendLevel
	* @var {Integer} : Block_Input := bi := 0
	* @var {Integer} : n = send level increase number
	* @returns {Integer}
	***********************************************************************/
	static _BlockInputSendLevel(n := 1, bi := 0, &Send_Level?) {
		SendLevel(0)
		Send_Level := sl := A_SendLevel
		(sl < 100) ? SendLevel(sl + n) : SendLevel(n + n)
		(n >= 1) ? bi := 1 : bi := 0 
		BlockInput(bi)
		return Send_Level
	}
	static BISL(n := 1, bi := 0, &sl?) => this._BlockInputSendLevel(n, bi, &sl?)
	; ---------------------------------------------------------------------------
		/************************************************************************
	* @description Set detection for hidden windows and text
	* @example AE.DH(1)
	***********************************************************************/
	static _DetectHidden_Text_Windows(n := 1) {
		DetectHiddenText(n)
		DetectHiddenWindows(n)
	}
	static DH(n) => this._DetectHidden_Text_Windows(n)
	static DetectHidden(n) => this._DetectHidden_Text_Windows(n)

	/************************************************************************
	* @description Set various delay settings
	* @example AE.SetDelays(-1)
	* @var {Integer} : delay_key := d := n := -1
	* @var {Integer} : hold_time := delay_press := p := -1
	***********************************************************************/
	static _SetDelays(n := -1, p:=-1) {
		delay_key := d := n
		hold_time := delay_press := p
		SetControlDelay(n)
		SetMouseDelay(n)
		SetWinDelay(n)
		SetKeyDelay(delay_key, delay_press)
	}
	static SetDelays(n) => this._SetDelays(n)
	; ---------------------------------------------------------------------------
	
	/**
	 * Sets clipboard content as RTF format
	 * @param {String} rtfText The RTF formatted text
	 */
	static _SetClipboardRTF(rtfText) {
		; Register RTF format if needed
		static CF_RTF := DllCall("RegisterClipboardFormat", "Str", "Rich Text Format", "UInt")
		
		; Open and clear clipboard
		DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)
		DllCall("EmptyClipboard")
		
		; Allocate and copy RTF data
		hGlobal := DllCall("GlobalAlloc", "UInt", 0x42, "Ptr", StrPut(rtfText, "UTF-8"))
		pGlobal := DllCall("GlobalLock", "Ptr", hGlobal, "Ptr")
		StrPut(rtfText, pGlobal, "UTF-8")
		DllCall("GlobalUnlock", "Ptr", hGlobal)
		
		; Set clipboard data and close
		DllCall("SetClipboardData", "UInt", CF_RTF, "Ptr", hGlobal)
		DllCall("CloseClipboard")
		Sleep(this.delayTime)
	}

	static delayTime => this.getdelayTime()

	static getdelayTime(*){
		counterAfter := counterBefore := freq := 0
		DllCall('QueryPerformanceFrequency', 'Int*', &freq := 0)
		DllCall('QueryPerformanceCounter', 'Int*', &counterBefore := 0)
		loop 1000 {
			num := A_Index
		}
		DllCall('QueryPerformanceCounter', 'Int*', &counterAfter := 0)

		delayTime := ((counterAfter - CounterBefore) / freq)
		delayTime := delayTime  * 1000000 ;? Convert to milliseconds
		; delayTime := delayTime  * 10000000 ;? Convert to milliseconds
		
		delaytime := Round(delayTime)

		; Infos(delayTime ' (' Round(delayTime*10) ')', Round(delayTime*10))

		return delayTime
	}

	static DefaultFormat := "rtf"  ; Can be "rtf", "html", "markdown", or "text"
	
	static DetectFormat(text) {
		if RegExMatch(text, "^{\rtf1")
			return "rtf"
		if RegExMatch(text, "^<!DOCTYPE html|^<html")
			return "html"
		if RegExMatch(text, "^#|^\*\*|^- ")
			return "markdown"
		if RegExMatch(text, '^{[\s\n]*""')
			return "json"
		return text
	}
	
	static ConvertFormat(text, fromFormat, toFormat) {
		if (fromFormat == toFormat)
			return text
			
		switch fromFormat {
			case "text":
				return text.rtf()
			case "html":
				return FormatConverter.HTMLToRTF(text)
			case "markdown":
				return FormatConverter.MarkdownToRTF(text)
			case "json":
				; Placeholder for JSON formatting
				return text
		}
		return text
	}

	/**
	 * Universal send method handling both RTF and regular content
	 * @param {String|Array|Map|Object|Class} input The content to send
	 * @param {String} endChar The ending character(s) to append
	 * @param {Boolean} isClipReverted Whether to revert the clipboard
	 * @param {Integer} untilRevert Time in ms before reverting clipboard
	 * @returns {String} The sent content
	 */
	static Send(input?, endChar := '', isClipReverted := true, untilRevert := 500) {
		if (!IsSet(input))
			input := this

		; Handle backup first
		prevClip := ''
		if (isClipReverted){
			prevClip := this.BackupAndClearClipboard()
		}

		; Process input based on type
		content := input
		if (this._IsRTFContent(input)) {
			; RTF handling
			verifiedRTF := FormatConverter.IsRTF(input, true)
			; this.ClearClipboard()
			; Infos(verifiedRTF endChar)
			this._SetClipboardRTF(verifiedRTF endChar)
		}
		else {
			; Regular content handling
			; content := this.ConvertToString(input)
			; this.ClearClipboard()
			A_Clipboard := content endChar
		}
		
		; Wait for clipboard and send
		this.Sleep(this.delayTime*10)
		; Send('{sc2A Down}{sc152}{sc2A Up}') 		;! {Shift}{Insert}
		Send('{sc1D Down}{sc2F}{sc1D Up}') 			;! {Control}{v}
		; Send('{sc1D Down}{sc2A Down}{sc2F}{sc2A Up}{sc1D Up}') 		;! {Shift}{Insert}
		; Sleep(this.delayTime * 5)
		Sleep(this.delayTime)
		
		; Restore clipboard if needed
		if (isClipReverted) {
			this.ClearClipboard()
			A_Clipboard := prevClip
		}
		
		return content
	}

	/**
	 * Alias for Send with RTF content
	 * @param {String} rtfText The RTF formatted text to send
	 * @returns {String} The sent content
	 */
	static SendRTF(rtfText?, endChar := '', isClipReverted := true, untilRevert := 500) {
		return this.Send(rtfText, endChar, isClipReverted, untilRevert)
	}
	
		/**
	 * Sends text as RTF format to the clipboard
	 * @param {String} rtfText The RTF formatted text to send
	 * @param {String} endChar The ending character(s) to append
	 * @param {Boolean} isClipReverted Whether to revert the clipboard
	 * @param {Integer} untilRevert Time in ms before reverting clipboard
	 * @returns {String} The sent content
	 */
	; static SendRTF(rtfText?, endChar := '', isClipReverted := true, untilRevert := 500) {
	; 	prevClip := ''
		
	; 	if (!IsSet(rtfText)) {
	; 		rtfText := this
	; 	}

	; 	; Use FormatConverter to handle RTF verification and standardization
	; 	verifiedRTF := FormatConverter.IsRTF(rtfText, true)

	; 	; isClipReverted ? prevClip := ClipboardAll() : ''
	; 	isClipReverted ? prevClip := this.BackupAndClearClipboard() : ''
		
	; 	this.ClearClipboard()
	; 	this._SetClipboardRTF(rtfText . endChar)
		
	; 	this.Sleep(this.delayTime)

	; 	Send('{sc2A Down}{sc152}{sc2A Up}') 		;! {Shift}{Insert}
	; 	; Send('{sc1D Down}{sc2F}{sc1D Up}') 			;! {Control}{v}

	; 	Sleep(this.delayTime*5)

	; 	if (isClipReverted) {
	; 		this.ClearClipboard()
	; 		A_Clipboard := prevClip
	; 	}
		
	; 	return rtfText
	; }

	/**
	 * Checks if content appears to be RTF formatted
	 * @param {String} content The content to check
	 * @returns {Boolean} True if content appears to be RTF
	 */
	; static _IsRTFContent(content) {
	; 	if (Type(content) != "String")
	; 		return false
			
	; 	; Basic RTF detection - checks for common RTF header
	; 	return RegExMatch(content, "i)^{\s*\\rtf1\b") ? true : false
	; }
	static _IsRTFContent(content) {
		return FormatConverter.VerifyRTF(content).isRTF
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
	* @description Wait for the clipboard to be available
	* @example WaitForClipboard()
	***********************************************************************/
	static WaitForClipboard(timeout := 1000) {
		clipboardReady := false
		startTime := A_TickCount

		checkClipboard := () => _checkClipboard()
		_checkClipboard() {
			if (!this.IsClipboardBusy()) {
				clipboardReady := true
				SetTimer(checkClipboard, 0)  ; Turn off the timer
			} else if (A_TickCount - startTime > timeout) {
				SetTimer(checkClipboard, 0)  ; Turn off the timer
				; throw Error('Clipboard timeout')
			}
		}
		
		SetTimer(checkClipboard, 10)  ; Check every 10ms

		; Wait for the clipboard to be ready or for a timeout
		while (!clipboardReady) {
			Sleep(10)
		}
	}
	
	; static Sleep(n := 10) => this._Clipboard_Sleep(n)
	static Sleep(n := 10) => this.WaitForClipboard(n)
	/************************************************************************
		* @description Safely copy content to clipboard with verification
		* @context_sensitive Yes
		* @example result := SafeCopyToClipboard()
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
	* @example cBak := BackupAndClearClipboard()
	***********************************************************************/
	static BackupAndClearClipboard(&backup?) {
		; backup := DllCall('OleGetClipboard', 'Ptr', 0, 'Ptr')
		; backup := DllCall('ole32\OleGetClipboard', 'Ptr', 0, 'Ptr')
		backup := ClipboardAll()
		this.OpenClipboard()
		this.EmptyClipboard()
		this.CloseClipboard()
		return backup
	}

	/************************************************************************
	* @description Select all text in the focused control
	* @context_sensitive Yes
	* @example SelectAllText()
	***********************************************************************/
	static SelectAllText() {
		static EM_SETSEL := 0x00B1
		hCtl := this.hfCtl()
		DllCall('SendMessage', 'Ptr', hCtl, 'UInt', EM_SETSEL, 'Ptr', 0, 'Ptr', -1)
	}

	/************************************************************************
	* @description Copy selected text to clipboard
	* @context_sensitive Yes
	* @example CopyToClipboard()
	***********************************************************************/
	static CopyToClipboard() {
		static WM_COPY := 0x0301
		hCtl := this.hfCtl()
		DllCall('SendMessage', 'Ptr', hCtl, 'UInt', WM_COPY, 'Ptr', 0, 'Ptr', 0)
	}

	/************************************************************************
	* @description Check if the clipboard is currently busy
	* @example if IsClipboardBusy()
	***********************************************************************/
	static IsClipboardBusy() {
		return DllCall('GetOpenClipboardWindow', 'Ptr')
	}

	/************************************************************************
	* @description Get text from clipboard using DllCalls
	* @example clipText := GetClipboardText()
	***********************************************************************/
	static GetClipboardText(hData?) {
		Infos(hData)
		; if (!DllCall('OpenClipboard', 'Ptr', 0)) {
		if (!DllCall('OpenClipboard')) {
			return ''
		}
		if (hData == 0){
			hData := DllCall('GetClipboardData', 'UInt', 1, 'Ptr') ; CF_UNICODETEXT := 13, CF_TEXT := 1
		}
		if (hData == 0) {
			DllCall('CloseClipboard')
			return ''
		}
		
		DllCall('GlobalUnlock', 'Ptr', hData)

		pData := DllCall('GlobalLock', 'Ptr', hData, 'Ptr')
		if (pData == 0) {
			DllCall('CloseClipboard')
			return ''
		}

		text := StrGet(pData, 'UTF-8')

		DllCall('GlobalUnlock', 'Ptr', hData)
		DllCall('CloseClipboard')

		return text
	}
	static OpenClipboard() => DllCall('User32.dll\OpenClipboard', 'Ptr')
	static EmptyClipboard() => DllCall('User32.dll\EmptyClipboard', 'Int')
	static CloseClipboard() => DllCall('User32.dll\CloseClipboard', 'Int')
	static ClearClipboard() {
		
		; Open and clear clipboard
		this.OpenClipboard()
		this.EmptyClipboard()
		
		this.CloseClipboard()
		DllCall('Kernel32.dll\GlobalUnlock', 'Ptr')
		this.Sleep()
	}
	; static testClearClipboard() {
	; 	arrError := []
	; 	hWndGetClipOpen  	:= this.GetOpenClipboardWindow()
	; 	errhWndClipOpen		:= 'errhWndClipOpen: ' A_LastError
	; 	arrError.SafePush(errhWndClipOpen)
	; 	hWndClipOwn 		:= DllCall('GetClipboardOwner')
	; 	errhWndClipOwn		:= 'errhWndClipOwn: ' A_LastError
	; 	arrError.SafePush(errhWndClipOwn)
	; 	clipUnlock 	  		:= DllCall('Kernel32.dll\GlobalUnlock', 'Ptr', !hWndGetClipOpen ? hWndClipOwn : 0)
	; 	errclipUnlock		:= 'errclipUnlock: ' A_LastError
	; 	arrError.SafePush(errclipUnlock)
	; 	clipOpen 	  		:= DllCall('User32.dll\OpenClipboard')
	; 	errclipOpen			:= 'errclipOpen: ' A_LastError
	; 	arrError.SafePush(errclipOpen)
	; 	clipEmpty 			:= DllCall('User32.dll\EmptyClipboard')
	; 	errclipEmpty		:= 'errclipEmpty: ' A_LastError
	; 	arrError.SafePush(errclipEmpty)
	; 	clipClose 			:= DllCall('User32.dll\CloseClipboard')
	; 	errclipClose		:= 'errclipClose: ' A_LastError
	; 	clipUnlockAfter 	:= DllCall('Kernel32.dll\GlobalUnlock', 'Ptr', !hWndGetClipOpen ? hWndClipOwn : 0)
	; 	errclipUnlockAfter	:= 'clipUnlockAfter: ' A_LastError
	; 	arrError.SafePush(errclipClose)
		
	; 	for each, value in arrError {
	; 		ErrorObj := {}
	; 		ErrorObj := error_list(value)
	; 		; Infos(ErrorObj.code '`t' 'Error message: ' ErrorObj.desc)
	; 	}
		
	; 	error_list(errorcode?, &ErrorObj:={code:0, desc:''}) {
	; 		mapError := Map(
	; 			0, 'ERROR_SUCCESS',
	; 			1, 'ERROR_INVALID_FUNCTION',
	; 			2, 'ERROR_FILE_NOT_FOUND',
	; 			3, 'ERROR_PATH_NOT_FOUND',
	; 			4, 'ERROR_TOO_MANY_OPEN_FILES',
	; 			5, 'ERROR_ACCESS_DENIED',
	; 			6, 'ERROR_INVALID_HANDLE',
	; 			7, 'ERROR_ARENA_TRASHED',
	; 			8, 'ERROR_NOT_ENOUGH_MEMORY',
	; 			9, 'ERROR_INVALID_BLOCK'
	; 		)

	; 		; if mapError.Has(errorcode) {
	; 		; 	Infos('System error #: ' errorcode '`tError message: ' mapError[error])
	; 		; }
	; 		; else {
	; 		; 	Infos('System error #: ' errorcode '`tError message: Not in Map' )
	; 		; }
	; 		desc:=(mapError.Has(ErrorObj.code)? 'Error message: ' mapError[ErrorObj.code] : 'Error message: Not in Map')
	; 		; Make a faulty system function call
	; 		; DllCall('GetHandleInformation')
	; 		; Error is set to 6
	; 		; Infos('System error number: ' A_LastError
	; 		; 	'`nError message: ' mapError[A_LastError])
	; 		return ErrorObj := {code:errorcode, desc: desc}
	; 	}
	; }

	/************************************************************************
	* @description Get the handle of the window with an open clipboard
	* @example GetOpenClipboardWindow()
	***********************************************************************/
	static GetOpenClipboardWindow() => DllCall('User32.dll\GetOpenClipboardWindow', 'Ptr')
	static GetOpenClipWin() => this.GetOpenClipboardWindow()

	/************************************************************************
	* @description Backup and clear clipboard
	* @example _Clipboard_Backup_Clear(&cBak)
	***********************************************************************/
	/**
	 * @description Backup ClipboardAll() and clear clipboard
	 * @param cBak 
	 * @returns {ClipboardAll} 
	 */
	static BackupClear(&cBak?) => this._Clipboard_Backup_Clear(&cBak?)
	static cBakClr(&cBak?) => this._Clipboard_Backup_Clear(&cBak?)
	static BakClr(&cBak?) => this._Clipboard_Backup_Clear(&cBak?)
	static _Clipboard_Backup_Clear(&cBak?) {
		; ClipObj := {
		; 	cBak : cBak,
		; 	hWndClipOpen  : hWndClipOpen  := this.GetOpenClipboardWindow(),
		; 	hWndClipOwner : hWndClipOwner := DllCall('GetClipboardOwner')
		; }
		cBak := ClipboardAll()
		; this.EmptyClipboard()
		; this.Sleep(100)
		; this.CloseClipboard()
		; hWndClipOpen  := this.GetOpenClipboardWindow()
		; hWndClipOwner := DllCall('GetClipboardOwner')
		; DllCall('GlobalUnlock', 'Ptr', !hWndClipOpen ? hWndClipOwner : 0)
		DllCall('OpenClipboard')
		DllCall('EmptyClipboard')
		DllCall('CloseClipboard')

		; return (cBak, ClipObj)
		return cBak
	}

	/************************************************************************
	* @description Restore clipboard from backup
	* @example _Clipboard_Restore(cBak)
	***********************************************************************/
	static _Clipboard_Restore(cBak) {
		SetTimer(() => this.Sleep(50), -500)
		A_Clipboard := cBak
		this.CloseClipboard()
	}
	static cRestore(cBak) => this._Clipboard_Restore(cBak)
	static Restore(cBak) => this._Clipboard_Restore(cBak)

	static ToCSV() {
		; This method remains unchanged as it doesn't use JSON
		clipText := A_Clipboard
		lines := StrSplit(clipText, "`n", "`r")
		csvText := ""
		for index, line in lines {
			fields := StrSplit(line, "`t")
			csvLine := ""
			for _, field in fields {
				csvLine .= '"' . StrReplace(field, '"', '""') . '",'
			}
			csvText .= RTrim(csvLine, ",") . "`n"
		}
		return RTrim(csvText, "`n")
	}

	static ToJSON() {
		clipText := A_Clipboard
		lines := StrSplit(clipText, "`n", "`r")
		jsonArray := []
		headers := StrSplit(lines[1], "`t")
		for i, line in lines {
			if (i == 1) {
				continue
			}
			fields := StrSplit(line, "`t")
			obj := {}
			Loop headers.Length {
				obj[headers[A_Index]] := fields.Has(A_Index) ? fields[A_Index] : ""
			}
			jsonArray.Push(obj)
		}
		return cJson.Dump(jsonArray)
	}

	static ToKeyValueJSON() {
		clipText := A_Clipboard
		lines := StrSplit(clipText, "`n", "`r")
		obj := {}
		currentSection := "root"
		for _, line in lines {
			if (RegExMatch(line, "\[(.+?)\]", &match)) {
				currentSection := Trim(match[1])
				obj[currentSection] := {}
			} else if (RegExMatch(line, "(.+?):(.+)", &match)) {
				key := Trim(match[1])
				value := Trim(match[2])
				if (currentSection == "root") {
					obj[key] := value
				} else {
					obj[currentSection][key] := value
				}
			}
		}
		return cJson.Dump(obj)  ; Changed to cJson.Dump
	}

	static CSVToJSON() {
		csvText := A_Clipboard
		lines := StrSplit(csvText, "`n", "`r")
		jsonArray := []
		headers := StrSplit(lines[1], ",")
		headers := headers.Map((header) => (StrReplace(Trim(header, '"'), " ", "_")))
		
		for i, line in lines {
			if (i == 1) {
				continue
			}
			fields := StrSplit(line, ",")
			obj := {}
			Loop headers.Length {
				obj[headers[A_Index]] := fields.Has(A_Index) ? Trim(fields[A_Index], '"') : ""
			}
			jsonArray.Push(obj)
		}
		return cJson.Dump(jsonArray)
	}

}

^!c:: ; Ctrl+Alt+C to convert to CSV
{
	csvData := Clip.ToCSV()
	A_Clipboard := csvData
	MsgBox("Clipboard converted to CSV format")
}

^!j:: ; Ctrl+Alt+J to convert to JSON
{
	jsonData := Clip.ToJSON()
	A_Clipboard := jsonData
	MsgBox("Clipboard converted to JSON format")
}

^!k:: ; Ctrl+Alt+K to convert to Key-Value JSON
{
	jsonData := Clip.ToKeyValueJSON()
	A_Clipboard := jsonData
	MsgBox("Clipboard converted to Key-Value JSON format")
}

^!#v:: ; Ctrl+Alt+V to convert CSV to JSON
{
	jsonData := Clip.CSVToJSON()
	A_Clipboard := jsonData
	MsgBox("CSV data converted to JSON format")
}

; #Requires AutoHotkey v2+
; ; #Include <Directives\__AE.v2>
; #Include <Includes\ObjectTypeExtensions>

; class Clip {
; 	static defaultEndChar := ''
; 	static defaultIsClipReverted := true
; 	static defaultUntilRevert := 500

; 	/************************************************************************
; 	* @description Get the handle of the focused control
; 	* @context_sensitive Yes
; 	* @example this.hfCtl(&fCtl)
; 	***********************************************************************/
; 	static hfCtl(&fCtl?) {
; 		return fCtl := ControlGetFocus('A')
; 	}

; 	static fCtl(&hCtl?) => hCtl := ControlGetFocus('A')

; 	/************************************************************************
; 	* @description Initialize the class with default settings
; 	* @example AE class is Initiated
; 	***********************************************************************/
; 	static __New() {
; 		this.DH(1)
; 		this.SetDelays(-1)
; 	}

; 	/************************************************************************
; 	* @description Set SendMode, SendLevel, and BlockInput
; 	* @example AE.SM_BISL(&SendModeObj, 1)
; 	***********************************************************************/
; 	static _SendMode_SendLevel_BlockInput(&SendModeObj?, n := 1) {
; 		this.SM(&SendModeObj)
; 		this.BISL(1)
; 		return SendModeObj
; 	}
; 	static SM_BISL(&SendModeObj?, n := 1) => this._SendMode_SendLevel_BlockInput(&SendModeObj?, n:=1)
; 	/************************************************************************
; 	* @description Change SendMode and SetKeyDelay
; 	* @example AE.SM(&SendModeObj)
; 	* @var {Object} : SendModeObject,
; 	* @var {Integer} : s: A_SendMode,
; 			d: A_KeyDelay,
; 			p: A_KeyDuration
; 	***********************************************************************/
; 	static _SendMode(&SendModeObj := {}) {
; 		SendModeObj := {
; 			s: A_SendMode,
; 			d: A_KeyDelay,
; 			p: A_KeyDuration
; 		}
; 		SendMode('Event')
; 		SetKeyDelay(-1, -1)
; 		return SendModeObj
; 	}
; 	static SM(&SendModeObj?) => this._SendMode(&SendModeObj?)
; 		/************************************************************************
; 	* @description Set BlockInput and SendLevel
; 	* @example AE.BISL(1)
; 	* @var {Integer} : Send_Level := A_SendLevel
; 	* @var {Integer} : Block_Input := bi := 0
; 	* @var {Integer} : n = send level increase number
; 	* @returns {Integer}
; 	***********************************************************************/
; 	static _BlockInputSendLevel(n := 1, bi := 0, &Send_Level?) {
; 		SendLevel(0)
; 		Send_Level := sl := A_SendLevel
; 		(sl < 100) ? SendLevel(sl + n) : SendLevel(n + n)
; 		(n >= 1) ? bi := 1 : bi := 0 
; 		BlockInput(bi)
; 		return Send_Level
; 	}
; 	static BISL(n := 1, bi := 0, &sl?) => this._BlockInputSendLevel(n, bi, &sl?)
; 	; ---------------------------------------------------------------------------
; 		/************************************************************************
; 	* @description Set detection for hidden windows and text
; 	* @example AE.DH(1)
; 	***********************************************************************/
; 	static _DetectHidden_Text_Windows(n := 1) {
; 		DetectHiddenText(n)
; 		DetectHiddenWindows(n)
; 	}
; 	static DH(n) => this._DetectHidden_Text_Windows(n)
; 	static DetectHidden(n) => this._DetectHidden_Text_Windows(n)

; 	/************************************************************************
; 	* @description Set various delay settings
; 	* @example AE.SetDelays(-1)
; 	* @var {Integer} : delay_key := d := n := -1
; 	* @var {Integer} : hold_time := delay_press := p := -1
; 	***********************************************************************/
; 	static _SetDelays(n := -1, p:=-1) {
; 		delay_key := d := n
; 		hold_time := delay_press := p
; 		SetControlDelay(n)
; 		SetMouseDelay(n)
; 		SetWinDelay(n)
; 		SetKeyDelay(delay_key, delay_press)
; 	}
; 	static SetDelays(n) => this._SetDelays(n)
; 	; ---------------------------------------------------------------------------
	
; 	/**
; 	 * Sets clipboard content as RTF format
; 	 * @param {String} rtfText The RTF formatted text
; 	 */
; 	static _SetClipboardRTF(rtfText) {
; 		; Register RTF format if needed
; 		static CF_RTF := DllCall("RegisterClipboardFormat", "Str", "Rich Text Format", "UInt")
		
; 		; Open and clear clipboard
; 		; DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)
; 		DllCall("OpenClipboard")
; 		DllCall("EmptyClipboard")
		
; 		; Allocate and copy RTF data
; 		hGlobal := DllCall("GlobalAlloc", "UInt", 0x42, "Ptr", StrPut(rtfText, "UTF-8"))
; 		pGlobal := DllCall("GlobalLock", "Ptr", hGlobal, "Ptr")
; 		StrPut(rtfText, pGlobal, "UTF-8")
; 		DllCall("GlobalUnlock", "Ptr", hGlobal)
		
; 		; Set clipboard data and close
; 		DllCall("SetClipboardData", "UInt", CF_RTF, "Ptr", hGlobal)
; 		DllCall("GlobalFree", "Ptr", hGlobal)
; 		this.Sleep(this.delayTime)
; 		DllCall("CloseClipboard")
; 		this.Sleep(this.delayTime)
; 		rtf := A_Clipboard
; 		Sleep(this.delayTime * 2)
; 		return rtf
; 	}

; 	static delayTime => this.getdelayTime()

; 	static getdelayTime(*){
; 		counterAfter := counterBefore := freq := 0
; 		DllCall('QueryPerformanceFrequency', 'Int*', &freq := 0)
; 		DllCall('QueryPerformanceCounter', 'Int*', &counterBefore := 0)
; 		loop 1000 {
; 			num := A_Index
; 		}
; 		DllCall('QueryPerformanceCounter', 'Int*', &counterAfter := 0)

; 		delayTime := ((counterAfter - CounterBefore) / freq)
; 		delayTime := delayTime  * 1000000 ;? Convert to milliseconds
		
; 		delaytime := Round(delayTime)

; 		; Infos(delayTime)

; 		return delayTime
; 	}

; 	static DefaultFormat := "rtf"  ; Can be "rtf", "html", "markdown", or "text"
	
; 	static DetectFormat(text) {
; 		if RegExMatch(text, "^{\rtf1")
; 			return "rtf"
; 		if RegExMatch(text, "^<!DOCTYPE html|^<html")
; 			return "html"
; 		if RegExMatch(text, "^#|^\*\*|^- ")
; 			return "markdown"
; 		if RegExMatch(text, '^{[\s\n]*""')
; 			return "json"
; 		return text
; 	}
	
; 	static ConvertFormat(text, fromFormat, toFormat) {
; 		if (fromFormat == toFormat)
; 			return text
			
; 		switch fromFormat {
; 			case "text":
; 				return text.rtf()
; 			case "html":
; 				return FormatConverter.HTMLToRTF(text)
; 			case "markdown":
; 				return FormatConverter.MarkdownToRTF(text)
; 			case "json":
; 				; Placeholder for JSON formatting
; 				return text
; 		}
; 		return text
; 	}

; 	/**
; 	 * Universal send method handling both RTF and regular content
; 	 * @param {String|Array|Map|Object|Class} input The content to send
; 	 * @param {String} endChar The ending character(s) to append
; 	 * @param {Boolean} isClipReverted Whether to revert the clipboard
; 	 * @param {Integer} untilRevert Time in ms before reverting clipboard
; 	 * @returns {String} The sent content
; 	 */
; 	static Send(input?, endChar := '', isClipReverted := true, untilRevert := 500) {
; 		if (!IsSet(input))
; 			input := this

; 		; Handle backup first
; 		prevClip := ''
; 		if (isClipReverted){
; 			prevClip := this.BackupAndClearClipboard()
; 		}

; 		; Process input based on type
; 		content := input
; 		if (this._IsRTFContent(input)) {
; 			; RTF handling
; 			verifiedRTF := FormatConverter.IsRTF(input, true)
; 			this.ClearClipboard()
; 			; Infos(verifiedRTF endChar)
; 			this._SetClipboardRTF(verifiedRTF endChar)
; 		}
; 		else {
; 			; Regular content handling
; 			content := this.ConvertToString(input)
; 			this.ClearClipboard()
; 			A_Clipboard := content endChar
; 		}
		
; 		; Wait for clipboard and send
; 		this.Sleep(this.delayTime*5)
; 		Send('{sc2A Down}{sc152}{sc2A Up}') 		;! {Shift}{Insert}
; 		; Send('{sc1D Down}{sc2F}{sc1D Up}') 			;! {Control}{v}
; 		Sleep(this.delayTime * 5)

; 		; Restore clipboard if needed
; 		if (isClipReverted) {
; 			this.ClearClipboard()
; 			A_Clipboard := prevClip
; 		}
		
; 		return content
; 	}

; 	/**
; 	 * Alias for Send with RTF content
; 	 * @param {String} rtfText The RTF formatted text to send
; 	 * @returns {String} The sent content
; 	 */
; 	static SendRTF(rtfText?, endChar := '', isClipReverted := true, untilRevert := 500) {
; 		return this.Send(rtfText, endChar, isClipReverted, untilRevert)
; 	}
	
; 		/**
; 	 * Sends text as RTF format to the clipboard
; 	 * @param {String} rtfText The RTF formatted text to send
; 	 * @param {String} endChar The ending character(s) to append
; 	 * @param {Boolean} isClipReverted Whether to revert the clipboard
; 	 * @param {Integer} untilRevert Time in ms before reverting clipboard
; 	 * @returns {String} The sent content
; 	 */
; 	; static SendRTF(rtfText?, endChar := '', isClipReverted := true, untilRevert := 500) {
; 	; 	prevClip := ''
		
; 	; 	if (!IsSet(rtfText)) {
; 	; 		rtfText := this
; 	; 	}

; 	; 	; Use FormatConverter to handle RTF verification and standardization
; 	; 	verifiedRTF := FormatConverter.IsRTF(rtfText, true)

; 	; 	; isClipReverted ? prevClip := ClipboardAll() : ''
; 	; 	isClipReverted ? prevClip := this.BackupAndClearClipboard() : ''
		
; 	; 	this.ClearClipboard()
; 	; 	this._SetClipboardRTF(rtfText . endChar)
		
; 	; 	this.Sleep(this.delayTime)

; 	; 	Send('{sc2A Down}{sc152}{sc2A Up}') 		;! {Shift}{Insert}
; 	; 	; Send('{sc1D Down}{sc2F}{sc1D Up}') 			;! {Control}{v}

; 	; 	Sleep(this.delayTime*5)

; 	; 	if (isClipReverted) {
; 	; 		this.ClearClipboard()
; 	; 		A_Clipboard := prevClip
; 	; 	}
		
; 	; 	return rtfText
; 	; }

; 	/**
; 	 * Checks if content appears to be RTF formatted
; 	 * @param {String} content The content to check
; 	 * @returns {Boolean} True if content appears to be RTF
; 	 */
; 	; static _IsRTFContent(content) {
; 	; 	if (Type(content) != "String")
; 	; 		return false
			
; 	; 	; Basic RTF detection - checks for common RTF header
; 	; 	return RegExMatch(content, "i)^{\s*\\rtf1\b") ? true : false
; 	; }
; 	static _IsRTFContent(content) {
; 		return FormatConverter.VerifyRTF(content).isRTF
; 	}

; 	/**
; 	 * @param {Any} input The input to convert to string
; 	 * @returns {String} The converted string
; 	 */
; 	static ConvertToString(input) {
; 		switch Type(input) {
; 			case 'String':
; 				return input
; 			case 'Array':
; 				return input.Join('')
; 			case 'Map':
; 				return input.ToString()
; 			case 'Object':
; 				return jsongo.Stringify(input)
; 			case 'Initializable':
; 				return jsongo.Stringify(input)
; 			default:
; 				return input
; 		}
; 	}

; 	static SendMsgPaste() => (*) => SendMessage(0x0302, 0, 0, ControlGetFocus('A'), 'A')
	
; 	/************************************************************************
; 	* @description Wait for the clipboard to be available
; 	* @example WaitForClipboard()
; 	***********************************************************************/
; 	static WaitForClipboard(timeout := 1000) {
; 		clipboardReady := false
; 		startTime := A_TickCount

; 		checkClipboard := () => _checkClipboard()
; 		_checkClipboard() {
; 			if (!this.IsClipboardBusy()) {
; 				clipboardReady := true
; 				SetTimer(checkClipboard, 0)  ; Turn off the timer
; 			} else if (A_TickCount - startTime > timeout) {
; 				SetTimer(checkClipboard, 0)  ; Turn off the timer
; 				; throw Error('Clipboard timeout')
; 			}
; 		}
		
; 		SetTimer(checkClipboard, 10)  ; Check every 10ms

; 		; Wait for the clipboard to be ready or for a timeout
; 		while (!clipboardReady) {
; 			Sleep(10)
; 		}
; 	}
	
; 	; static Sleep(n := 10) => this._Clipboard_Sleep(n)
; 	static Sleep(n := 10) => this.WaitForClipboard(n)
; 	/************************************************************************
; 		* @description Safely copy content to clipboard with verification
; 		* @context_sensitive Yes
; 		* @example result := SafeCopyToClipboard()
; 		***********************************************************************/
; 	static SafeCopyToClipboard() {
; 		; cBak := this.BackupAndClearClipboard()
; 		cBak := ''
; 		this.BackupAndClearClipboard(&cBak)
; 		this.WaitForClipboard()
; 		this.SelectAllText()
; 		this.CopyToClipboard()
; 		this.WaitForClipboard()
; 		clipContent := this.GetClipboardText()
; 		return clipContent
; 	}

; 	/************************************************************************
; 	* @description Backup current clipboard content and clear it
; 	* @example cBak := BackupAndClearClipboard()
; 	***********************************************************************/
; 	static BackupAndClearClipboard(&backup?) {
; 		; backup := DllCall('OleGetClipboard', 'Ptr', 0, 'Ptr')
; 		; backup := DllCall('ole32\OleGetClipboard', 'Ptr', 0, 'Ptr')
; 		backup := ClipboardAll()
; 		this.OpenClipboard()
; 		this.EmptyClipboard()
; 		this.CloseClipboard()
; 		return backup
; 	}

; 	/************************************************************************
; 	* @description Select all text in the focused control
; 	* @context_sensitive Yes
; 	* @example SelectAllText()
; 	***********************************************************************/
; 	static SelectAllText() {
; 		static EM_SETSEL := 0x00B1
; 		hCtl := this.hfCtl()
; 		DllCall('SendMessage', 'Ptr', hCtl, 'UInt', EM_SETSEL, 'Ptr', 0, 'Ptr', -1)
; 	}

; 	/************************************************************************
; 	* @description Copy selected text to clipboard
; 	* @context_sensitive Yes
; 	* @example CopyToClipboard()
; 	***********************************************************************/
; 	static CopyToClipboard() {
; 		static WM_COPY := 0x0301
; 		hCtl := this.hfCtl()
; 		DllCall('SendMessage', 'Ptr', hCtl, 'UInt', WM_COPY, 'Ptr', 0, 'Ptr', 0)
; 	}

; 	/************************************************************************
; 	* @description Check if the clipboard is currently busy
; 	* @example if IsClipboardBusy()
; 	***********************************************************************/
; 	static IsClipboardBusy() {
; 		return DllCall('GetOpenClipboardWindow', 'Ptr')
; 	}

; 	/************************************************************************
; 	* @description Get text from clipboard using DllCalls
; 	* @example clipText := GetClipboardText()
; 	***********************************************************************/
; 	static GetClipboardText(hData?) {
; 		Infos(hData)
; 		; if (!DllCall('OpenClipboard', 'Ptr', 0)) {
; 		if (!DllCall('OpenClipboard')) {
; 			return ''
; 		}
; 		if (hData == 0){
; 			hData := DllCall('GetClipboardData', 'UInt', 1, 'Ptr') ; CF_UNICODETEXT := 13, CF_TEXT := 1
; 		}
; 		if (hData == 0) {
; 			DllCall('CloseClipboard')
; 			return ''
; 		}
		
; 		DllCall('GlobalUnlock', 'Ptr', hData)

; 		pData := DllCall('GlobalLock', 'Ptr', hData, 'Ptr')
; 		if (pData == 0) {
; 			DllCall('CloseClipboard')
; 			return ''
; 		}

; 		text := StrGet(pData, 'UTF-8')

; 		DllCall('GlobalUnlock', 'Ptr', hData)
; 		DllCall('CloseClipboard')

; 		return text
; 	}
; 	static OpenClipboard() => DllCall('User32.dll\OpenClipboard', 'Ptr')
; 	static EmptyClipboard() => DllCall('User32.dll\EmptyClipboard', 'Int')
; 	static CloseClipboard() => DllCall('User32.dll\CloseClipboard', 'Int')
; 	static ClearClipboard() {
		
; 		; Open and clear clipboard
; 		this.OpenClipboard()
; 		this.EmptyClipboard()
		
; 		this.CloseClipboard()
; 		DllCall('Kernel32.dll\GlobalUnlock', 'Ptr')
; 		this.Sleep()
; 	}
; 	static testClearClipboard() {
; 		arrError := []
; 		hWndGetClipOpen  	:= this.GetOpenClipboardWindow()
; 		errhWndClipOpen		:= 'errhWndClipOpen: ' A_LastError
; 		arrError.SafePush(errhWndClipOpen)
; 		hWndClipOwn 		:= DllCall('GetClipboardOwner')
; 		errhWndClipOwn		:= 'errhWndClipOwn: ' A_LastError
; 		arrError.SafePush(errhWndClipOwn)
; 		clipUnlock 	  		:= DllCall('Kernel32.dll\GlobalUnlock', 'Ptr', !hWndGetClipOpen ? hWndClipOwn : 0)
; 		errclipUnlock		:= 'errclipUnlock: ' A_LastError
; 		arrError.SafePush(errclipUnlock)
; 		clipOpen 	  		:= DllCall('User32.dll\OpenClipboard')
; 		errclipOpen			:= 'errclipOpen: ' A_LastError
; 		arrError.SafePush(errclipOpen)
; 		clipEmpty 			:= DllCall('User32.dll\EmptyClipboard')
; 		errclipEmpty		:= 'errclipEmpty: ' A_LastError
; 		arrError.SafePush(errclipEmpty)
; 		clipClose 			:= DllCall('User32.dll\CloseClipboard')
; 		errclipClose		:= 'errclipClose: ' A_LastError
; 		clipUnlockAfter 	:= DllCall('Kernel32.dll\GlobalUnlock', 'Ptr', !hWndGetClipOpen ? hWndClipOwn : 0)
; 		errclipUnlockAfter	:= 'clipUnlockAfter: ' A_LastError
; 		arrError.SafePush(errclipClose)
		
; 		for each, value in arrError {
; 			ErrorObj := {}
; 			ErrorObj := error_list(value)
; 			; Infos(ErrorObj.code '`t' 'Error message: ' ErrorObj.desc)
; 		}
		
; 		error_list(errorcode?, &ErrorObj:={code:0, desc:''}) {
; 			mapError := Map(
; 				0, 'ERROR_SUCCESS',
; 				1, 'ERROR_INVALID_FUNCTION',
; 				2, 'ERROR_FILE_NOT_FOUND',
; 				3, 'ERROR_PATH_NOT_FOUND',
; 				4, 'ERROR_TOO_MANY_OPEN_FILES',
; 				5, 'ERROR_ACCESS_DENIED',
; 				6, 'ERROR_INVALID_HANDLE',
; 				7, 'ERROR_ARENA_TRASHED',
; 				8, 'ERROR_NOT_ENOUGH_MEMORY',
; 				9, 'ERROR_INVALID_BLOCK'
; 			)

; 			; if mapError.Has(errorcode) {
; 			; 	Infos('System error #: ' errorcode '`tError message: ' mapError[error])
; 			; }
; 			; else {
; 			; 	Infos('System error #: ' errorcode '`tError message: Not in Map' )
; 			; }
; 			desc:=(mapError.Has(ErrorObj.code)? 'Error message: ' mapError[ErrorObj.code] : 'Error message: Not in Map')
; 			; Make a faulty system function call
; 			; DllCall('GetHandleInformation')
; 			; Error is set to 6
; 			; Infos('System error number: ' A_LastError
; 			; 	'`nError message: ' mapError[A_LastError])
; 			return ErrorObj := {code:errorcode, desc: desc}
; 		}
; 	}

; 	/************************************************************************
; 	* @description Get the handle of the window with an open clipboard
; 	* @example GetOpenClipboardWindow()
; 	***********************************************************************/
; 	static GetOpenClipboardWindow() => DllCall('User32.dll\GetOpenClipboardWindow', 'Ptr')
; 	static GetOpenClipWin() => this.GetOpenClipboardWindow()

; 	/************************************************************************
; 	* @description Backup and clear clipboard
; 	* @example _Clipboard_Backup_Clear(&cBak)
; 	***********************************************************************/
; 	/**
; 	 * @description Backup ClipboardAll() and clear clipboard
; 	 * @param cBak 
; 	 * @returns {ClipboardAll} 
; 	 */
; 	static BackupClear(&cBak?) => this._Clipboard_Backup_Clear(&cBak?)
; 	static cBakClr(&cBak?) => this._Clipboard_Backup_Clear(&cBak?)
; 	static BakClr(&cBak?) => this._Clipboard_Backup_Clear(&cBak?)
; 	static _Clipboard_Backup_Clear(&cBak?) {
; 		; ClipObj := {
; 		; 	cBak : cBak,
; 		; 	hWndClipOpen  : hWndClipOpen  := this.GetOpenClipboardWindow(),
; 		; 	hWndClipOwner : hWndClipOwner := DllCall('GetClipboardOwner')
; 		; }
; 		cBak := ClipboardAll()
; 		; this.EmptyClipboard()
; 		; this.Sleep(100)
; 		; this.CloseClipboard()
; 		; hWndClipOpen  := this.GetOpenClipboardWindow()
; 		; hWndClipOwner := DllCall('GetClipboardOwner')
; 		; DllCall('GlobalUnlock', 'Ptr', !hWndClipOpen ? hWndClipOwner : 0)
; 		DllCall('OpenClipboard')
; 		DllCall('EmptyClipboard')
; 		DllCall('CloseClipboard')

; 		; return (cBak, ClipObj)
; 		return cBak
; 	}

; 	/************************************************************************
; 	* @description Restore clipboard from backup
; 	* @example _Clipboard_Restore(cBak)
; 	***********************************************************************/
; 	static _Clipboard_Restore(cBak) {
; 		SetTimer(() => this.Sleep(50), -500)
; 		A_Clipboard := cBak
; 		this.CloseClipboard()
; 	}
; 	static cRestore(cBak) => this._Clipboard_Restore(cBak)
; 	static Restore(cBak) => this._Clipboard_Restore(cBak)

; 	static ToCSV() {
; 		; This method remains unchanged as it doesn't use JSON
; 		clipText := A_Clipboard
; 		lines := StrSplit(clipText, "`n", "`r")
; 		csvText := ""
; 		for index, line in lines {
; 			fields := StrSplit(line, "`t")
; 			csvLine := ""
; 			for _, field in fields {
; 				csvLine .= '"' . StrReplace(field, '"', '""') . '",'
; 			}
; 			csvText .= RTrim(csvLine, ",") . "`n"
; 		}
; 		return RTrim(csvText, "`n")
; 	}

; 	static ToJSON() {
; 		clipText := A_Clipboard
; 		lines := StrSplit(clipText, "`n", "`r")
; 		jsonArray := []
; 		headers := StrSplit(lines[1], "`t")
; 		for i, line in lines {
; 			if (i == 1) {
; 				continue
; 			}
; 			fields := StrSplit(line, "`t")
; 			obj := {}
; 			Loop headers.Length {
; 				obj[headers[A_Index]] := fields.Has(A_Index) ? fields[A_Index] : ""
; 			}
; 			jsonArray.Push(obj)
; 		}
; 		return cJson.Dump(jsonArray)
; 	}

; 	static ToKeyValueJSON() {
; 		clipText := A_Clipboard
; 		lines := StrSplit(clipText, "`n", "`r")
; 		obj := {}
; 		currentSection := "root"
; 		for _, line in lines {
; 			if (RegExMatch(line, "\[(.+?)\]", &match)) {
; 				currentSection := Trim(match[1])
; 				obj[currentSection] := {}
; 			} else if (RegExMatch(line, "(.+?):(.+)", &match)) {
; 				key := Trim(match[1])
; 				value := Trim(match[2])
; 				if (currentSection == "root") {
; 					obj[key] := value
; 				} else {
; 					obj[currentSection][key] := value
; 				}
; 			}
; 		}
; 		return cJson.Dump(obj)  ; Changed to cJson.Dump
; 	}

; 	static CSVToJSON() {
; 		csvText := A_Clipboard
; 		lines := StrSplit(csvText, "`n", "`r")
; 		jsonArray := []
; 		headers := StrSplit(lines[1], ",")
; 		headers := headers.Map((header) => (StrReplace(Trim(header, '"'), " ", "_")))
		
; 		for i, line in lines {
; 			if (i == 1) {
; 				continue
; 			}
; 			fields := StrSplit(line, ",")
; 			obj := {}
; 			Loop headers.Length {
; 				obj[headers[A_Index]] := fields.Has(A_Index) ? Trim(fields[A_Index], '"') : ""
; 			}
; 			jsonArray.Push(obj)
; 		}
; 		return cJson.Dump(jsonArray)
; 	}

; }

; ^!c:: ; Ctrl+Alt+C to convert to CSV
; {
; 	csvData := Clip.ToCSV()
; 	A_Clipboard := csvData
; 	MsgBox("Clipboard converted to CSV format")
; }

; ^!j:: ; Ctrl+Alt+J to convert to JSON
; {
; 	jsonData := Clip.ToJSON()
; 	A_Clipboard := jsonData
; 	MsgBox("Clipboard converted to JSON format")
; }

; ^!k:: ; Ctrl+Alt+K to convert to Key-Value JSON
; {
; 	jsonData := Clip.ToKeyValueJSON()
; 	A_Clipboard := jsonData
; 	MsgBox("Clipboard converted to Key-Value JSON format")
; }

; ^!#v:: ; Ctrl+Alt+V to convert CSV to JSON
; {
; 	jsonData := Clip.CSVToJSON()
; 	A_Clipboard := jsonData
; 	MsgBox("CSV data converted to JSON format")
; }
