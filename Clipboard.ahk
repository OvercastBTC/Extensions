/************************************************************************
 * @description Creating a class for clipboard manipulation
 * The class provides both static and non-static versions to allow flexibility in usage:
 * - Static version (Clip.[method]): Used when you need to call the method directly from the class
 * - Non-static version (instance.[method]): Used when working with class instances
 * @author OvercastBTC
 * @date 2025/03/17
 * @version 3.0.0
 ***********************************************************************/

#Requires AutoHotkey v2.0+
#Include <Includes\Basic>

/**
 * @class SM
 * @description Utility class for managing and restoring AutoHotkey SendMode and key delay settings.
 * @version 1.0.0
 * @author OvercastBTC
 * @date 2025-04-20
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @property {Object} objSM Stores the current SendMode, KeyDelay, and KeyDuration settings.
 *
 * @example
 * sm := SM({s: "Event", d: 10, p: 10})
 * SM.Restore(sm)
 */
class SM {
	#Requires AutoHotkey v2.0+

	/**
	 * @property {Object} objSM
	 * @description Static property to store the current SendMode, KeyDelay, and KeyDuration settings.
	 */
	static objSM := {
		s: A_SendMode,
		d: A_KeyDelay,
		p: A_KeyDuration
	}

	/**
	 * @constructor
	 * @param {Object} params Optional. Properties:
	 *   - s: SendMode (default: current A_SendMode)
	 *   - d: KeyDelay (default: current A_KeyDelay or -1)
	 *   - p: KeyDuration (default: current A_KeyDuration or -1)
	 * @returns {Object} The applied settings object.
	 */
	__New(params?) {
		; Validate and initialize parameters
		s := (IsSet(params) && params.HasOwnProp("s")) ? params.s : A_SendMode
		d := (IsSet(params) && params.HasOwnProp("d")) ? params.d : -1
		p := (IsSet(params) && params.HasOwnProp("p")) ? params.p : -1
		SendMode("Event")
		SetKeyDelay(d, p)
		objParams := { s: s, d: d, p: p }
		return objParams
	}

	/**
	 * @static
	 * @description Alternate static constructor for SM.
	 * @param {Object} params Optional. See __New.
	 */
	static __New(params?) {
		SM(params?)
	}

	/**
	 * @static
	 * @description Restores SendMode and KeyDelay/KeyDuration from an object.
	 * @param {Object} objSM The settings object to restore. If omitted, uses SM.objSM.
	 * @returns {Object} The restored settings object.
	 */
	static Restore(objSM?) {
		if !IsSet(objSM) {
			objSM := SM.objSM
		}
		SetKeyDelay(objSM.d, objSM.p)
		SendMode(objSM.s)
		return objSM
	}
}

/**
 * @class BISL
 * @description Utility class for setting BlockInput and SendLevel.
 * @version 1.0.0
 * @author OvercastBTC
 * @date 2025-04-20
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @example
 * bisl := BISL({sl: 1, n: 1, bi: 0})
 */
class BISL {
	#Requires AutoHotkey v2.0+

	/**
	 * @constructor
	 * @param {Object} params Optional. Properties:
	 *   - sl: SendLevel (default: current A_SendLevel)
	 *   - n: SendLevel increment (default: 1)
	 *   - bi: BlockInput flag (default: 0)
	 * @returns {Object} The applied settings object.
	 */
	__New(params?) {
		; Validate and initialize parameters
		sl := (IsSet(params) && params.HasOwnProp("sl")) ? params.sl : A_SendLevel
		n := (IsSet(params) && params.HasOwnProp("n")) ? params.n : 1
		bi := (IsSet(params) && params.HasOwnProp("bi")) ? params.bi : 0

		SendLevel(0)
		if (A_SendLevel < 100) {
			SendLevel(A_SendLevel + n)
		} else {
			SendLevel(n + n)
		}
		BlockInput(bi)
		objBISL := { sl: sl, n: n, bi: bi }
		return objBISL
	}
}

/**
 * @class SD
 * @description Utility class for setting various delays (Control, Mouse, Window).
 * @version 1.0.0
 * @author OvercastBTC
 * @date 2025-04-20
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @example
 * SD(-1, -1)
 */
class SD {
	#Requires AutoHotkey v2.0+

	/**
	 * @constructor
	 * @param {Integer} n Delay value for Control, Mouse, and Window (default: -1)
	 * @param {Integer} p Optional. Not used unless SendMode() != Input (default: -1)
	 */
	__New(n?, p?) {
		if !(IsSet(n) && IsInteger(n)) {
			n := -1
		}
		if !(IsSet(p) && IsInteger(p)) {
			p := -1
		}
		SetControlDelay(n)
		SetMouseDelay(n)
		SetWinDelay(n)
		; SetKeyDelay(n, p)  ; Not used unless SendMode() != Input
	}
}

/**
 * @class Clip
 * @description Static utility class for clipboard and focused control operations.
 * @version 3.0.0
 * @author OvercastBTC
 * @date 2025-03-17
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @example
 * Clip.Send("Some text")
 */
class Clip {

	static _logFile := A_ScriptDir "\clip_usage_log.json"
	static _usageLog := []
	static _isLoaded := false
	#Requires AutoHotkey v2.0+

	static defaultEndChar := ''
	static defaultIsClipReverted := true
	static defaultUntilRevert := 500

    /**
     * @description Default delay time for the class
     * @property {Integer} Dynamic calculation based on system performance
     */
    static d := dly := delay := A_Delay
    static dly := delay := A_Delay
    static delay := A_Delay
	static __New(show := true, d := -1) {
		this.DH(show)
		this.SD(d)
		SM()
	}

	__New(show := true, d := -1) {
		this.DH(show)
		SD(d)
		SM()
	}

	/************************************************************************
	* @description Set SendMode, SendLevel, and BlockInput
	* @example this.SM_BISL(&SendModeObj, 1)
	***********************************************************************/
	static _SendMode_SendLevel_BlockInput(&SendModeObj?, n := 1) {
		SM(&SendModeObj)
		BISL()
		return SendModeObj
	}
	static SM_BISL(&SendModeObj?, n := 1) => this._SendMode_SendLevel_BlockInput(&SendModeObj?, n:=1)

	/************************************************************************
	 * @description Changes SendMode to 'Event' and adjusts SetKeyDelay settings. 
	 * The class provides both static and non-static versions to allow flexibility in usage:
	 * - Static version (Clip.SM): Used when you need to call the method directly from the class
	 * - Non-static version (instance.SM): Used when working with class instances
	 * 
	 * @class SM
	 * @param {Object} objSM - Configuration object for send mode settings
	 * @param {String} objSM.s - Current send mode (A_SendMode)
	 * @param {Integer} objSM.d - Key delay in milliseconds (A_KeyDelay)
	 * @param {Integer} objSM.p - Key press duration (A_KeyDuration)
	 * 
	 * @returns {Object} Returns the modified objSM object
	*************************************************************************/

	SM(&objSM) => SM(&objSM)

	; ---------------------------------------------------------------------------
	/************************************************************************
	* @description Restore SendMode and SetKeyDelay
	* @example Clip.rSM(objRestore)
	***********************************************************************/
	static _RestoreSendMode(objSM) {
		SetKeyDelay(objSM.d, objSM.p)
		SendMode(objSM.s)
	}
	static rSM(objSM) => this._RestoreSendMode(objSM)
	; ---------------------------------------------------------------------------
	
	/************************************************************************
	* @description Set BlockInput and SendLevel
	* @example this.BISL(1)
	* @var {Integer} : Send_Level := A_SendLevel
	* @var {Integer} : Block_Input := bi := 0
	* @var {Integer} : n = send level increase number
	* @returns {Integer}
	*************************************************************************/

	static _BlockInputSendLevel(n := 1, bi := 0, &send_Level?) {
		SendLevel(0)
		send_Level := sl := A_SendLevel
		(sl < 100) ? SendLevel(sl + n) : SendLevel(n + n)
		(n >= 1) ? bi := 1 : bi := 0 
		BlockInput(bi)
		return send_Level
	}
	static BISL(n := 1, bi := 0, &sl?) => this._BlockInputSendLevel(n, bi, &sl?)
	; ---------------------------------------------------------------------------

	/************************************************************************
	* @description Set detection for hidden windows and text
	* @example this.DH(1)
	***********************************************************************/
	static _DetectHidden_Text_Windows(n := true) {
		DetectHiddenText(n)
		DetectHiddenWindows(n)
	}
	static DetectHidden(n) 	=> this._DetectHidden_Text_Windows(n)
	static DH(n) 			=> this._DetectHidden_Text_Windows(n)
	DH(n) 					=> this.DH(n)

	/************************************************************************
	* @description Set various delay settings
	* @example this.SetDelays(-1)
	***********************************************************************/
	static _SetDelays(n := -1, p:=-1) {
		SetControlDelay(n)
		SetMouseDelay(n)
		SetWinDelay(n)
		SetKeyDelay(n, p)
	}
	static SetDelays(n) => this._SetDelays(n)
	static SD(n) => this._SetDelays(n)
	; ---------------------------------------------------------------------------
	/**
	 * @private
	 * @description Log Clip method usage to JSON file and optionally display.
	 * @param {String} method Method name
	 * @param {Map|Object} params Parameters used
	 * @param {Any} result Result returned (optional)
	 */
	static _LogUsage(method, params, result := unset) {
		entry := Map(
			"timestamp", FormatTime(, "yyyy-MM-dd HH:mm:ss"),
			"method", method,
			"params", params,
			"result", IsSet(result) ? result : ""
		)
		this._usageLog.Push(entry)
		try FileDelete(this._logFile)
		catch
		{}
		FileAppend(cJson.Dump(this._usageLog, 1), this._logFile)
	}

	/**
	 * @description Get the handle of the focused control.
	 * @returns {Ptr} Handle of focused control.
	 */
	static hCtl() {
		result := ControlGetFocus('A')
		this._LogUsage("hCtl", Map(), result)
		return result
	}

	/**
	 * @description Select all text in the focused control.
	 */
	static SelectAllText() {
		static EM_SETSEL := 0x00B1
		hCtl := this.hCtl()
		if hCtl
			DllCall('SendMessage', 'Ptr', hCtl, 'UInt', EM_SETSEL, 'Ptr', 0, 'Ptr', -1)
		this._LogUsage("SelectAllText", Map("hCtl", hCtl))
	}

	/**
	 * @description Copy selected text to clipboard.
	 */
	static CopyToClipboard() {
		static WM_COPY := 0x0301
		hCtl := this.hCtl()
		if hCtl
			DllCall('SendMessage', 'Ptr', hCtl, 'UInt', WM_COPY, 'Ptr', 0, 'Ptr', 0)
		this._LogUsage("CopyToClipboard", Map("hCtl", hCtl))
	}

	/**
	 * @description Check if the clipboard is currently busy.
	 * @returns {Boolean} True if busy.
	 */
	static IsClipboardBusy() {
		busy := Clipboard.IsBusy
		this._LogUsage("IsClipboardBusy", Map(), busy)
		return busy
	}

	/**
	 * @description Get text from clipboard.
	 * @param {String} format Clipboard format: "T" (text), "U" (unicode), "R" (rtf), "H" (html), "C" (csv)
	 * @returns {String} Clipboard content.
	 */
	static GetClipboardText(format := "T") {
		switch format {
			case "U", "Unicode":
				text := Clipboard.GetUnicode()
			case "R", "RTF":
				text := Clipboard.GetRTF()
			case "H", "HTML":
				text := Clipboard.GetHTML()
			case "C", "CSV":
				text := Clipboard.GetCSV()
			default:
				text := Clipboard.GetPlain()
		}
		this._LogUsage("GetClipboardText", Map("format", format), text)
		return text
	}

	/**
	 * @description Set clipboard text (unicode).
	 * @param {String} text Text to set.
	 */
	static SetClipboardText(text) {
		Clipboard.Set.Unicode(text)
		this._LogUsage("SetClipboardText", Map("text", text))
	}

	/**
	 * @description Clear the clipboard.
	 */
	static ClearClipboard() {
		Clipboard.Clear()
		this._LogUsage("ClearClipboard", Map())
	}

	/**
	 * @description Backup current clipboard content and clear it.
	 * @returns {ClipboardAll} Clipboard backup.
	 */
	static BackupAndClearClipboard() {
		backup := Clipboard.BackupAll()
		Clipboard.Clear()
		this._LogUsage("BackupAndClearClipboard", Map(), backup)
		return backup
	}

	/**
	 * @description Restore clipboard from backup.
	 * @param {ClipboardAll} backup Clipboard backup object.
	 */
	static RestoreClipboard(backup) {
		Clipboard.RestoreAll(backup)
		this._LogUsage("RestoreClipboard", Map("backup", backup))
	}

	/**
	 * @description Wait for the clipboard to be available.
	 * @param {Integer} timeout Timeout in ms.
	 */
	static WaitForClipboard(timeout := 1000) {
		result := Clipboard.Wait(timeout)
		this._LogUsage("WaitForClipboard", Map("timeout", timeout), result)
		return result
	}

	/**
	 * @description Safely copy content to clipboard with verification.
	 * @returns {String} Clipboard content.
	 */
	static SafeCopyToClipboard() {
		backup := this.BackupAndClearClipboard()
		this.WaitForClipboard()
		this.SelectAllText()
		this.CopyToClipboard()
		this.WaitForClipboard()
		clipContent := this.GetClipboardText()
		this._LogUsage("SafeCopyToClipboard", Map(), clipContent)
		return clipContent
	}

	/**
	 * @description Show the usage log in a GUI (if ErrorLogGui is available).
	 */
	static ShowUsageLog() {
		if IsSet(ErrorLogGui) {
			ErrorLogGui.Show(this._usageLog)
		} else {
			MsgBox cJson.Dump(this._usageLog, 1)
		}
	}

	/**
	 * @description Paste text (or clipboard) into the focused control, with clipboard backup and restore.
	 * @param {String} text Text to send. If omitted, sends current clipboard.
	 * @param {String} endChar Optional character(s) to send after paste.
	 * @param {Boolean} isClipReverted Restore clipboard after paste (default: true).
	 * @param {Integer} untilRevert Time in ms to wait before restoring clipboard (default: 500).
	 * @returns {Boolean} True if sent.
	 * @example
	 * Clip.Send("Hello world")
	 */
	static Send(text := "", endChar := "", isClipReverted := true, untilRevert := 500) {
		Clipboard.Send(text, endChar, isClipReverted, untilRevert)
		; /**
		;  * Implementation notes:
		;  * - Backs up clipboard if text is provided.
		;  * - Sets clipboard, waits for availability, sends Ctrl+V, restores clipboard if needed.
		;  * - If text is empty, just sends Ctrl+V.
		;  */
		; local cBak := unset, sent := false
		; try {
		; 	if (text != "") {
		; 		cBak := ClipboardAll()
		; 		; Wait for clipboard to update by monitoring the sequence number
		; 		initialSeq := Clipboard.GetSequenceNumber
		; 		Clipboard.Set.Unicode(text)
		; 		Loop {
		; 			Sleep(10)
		; 		} until Clipboard.GetSequenceNumber != initialSeq
		; 		Sleep(A_Delay)
		; 		; Send(key.paste)
		; 		Send(key.shiftinsert)
		; 		sent := true
		; 		if (endChar != "")
		; 			Send(endChar)
		; 		if isClipReverted {
		; 			SetTimer(() => (A_Clipboard := cBak), -untilRevert)
		; 		}
		; 	} else {
		; 		Send("^v")
				sent := true
		; 		if (endChar != "")
		; 			Send(endChar)
		; 	}
		try {
			this._LogUsage("Send", Map("text", text, "endChar", endChar, "isClipReverted", isClipReverted, "untilRevert", untilRevert), sent)
			return sent
		} catch as err {
			this._LogUsage("Send", Map("text", text, "endChar", endChar, "isClipReverted", isClipReverted, "untilRevert", untilRevert), "error: " err.Message)
			throw err
		}
	}

	/**
	 * @description Clean up resources when object is destroyed.
	 */
	__Delete() {
		; No persistent resources, but included for standards.
	}
}

^!c:: ; Ctrl+Alt+C to convert to CSV
{
    csvData := Clipboard.ToCSV()
    A_Clipboard := csvData
    MsgBox("Clipboard converted to CSV format")
}

^!j:: ; Ctrl+Alt+J to convert to JSON
{
    jsonData := Clipboard.ToJSON()
    A_Clipboard := jsonData
    MsgBox("Clipboard converted to JSON format")
}

^!k:: ; Ctrl+Alt+K to convert to Key-Value JSON
{
    jsonData := Clipboard.ToKeyValueJSON()
    A_Clipboard := jsonData
    MsgBox("Clipboard converted to Key-Value JSON format")
}

^!#v:: ; Ctrl+Alt+V to convert CSV to JSON
{
    jsonData := Clipboard.CSVToJSON()
    A_Clipboard := jsonData
    MsgBox("CSV data converted to JSON format")
}

/**
 * @class Clipboard
 * @description Provides advanced clipboard manipulation and introspection methods for AHK v2.
 * @version 2.0.0
 * @author OvercastBTC
 * @date 2025-04-17
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @property {UInt} SequenceNumber Current clipboard sequence number (increments on change)
 * @property {Ptr} Owner HWND of the clipboard owner window
 * @method {Array} EnumFormats() Enumerate all available clipboard formats
 * @method {String} GetFormatName(fmt) Get the name of a clipboard format
 * @method {Boolean} IsFormatAvailable(fmt) Check if a clipboard format is available
 * @method {Buffer|""} GetBuffer(fmt) Get clipboard data as a Buffer for a given format
 * @method {Int} AddFormatListener(hWnd) Add a clipboard format listener (modern)
 * @method {Int} RemoveFormatListener(hWnd) Remove a clipboard format listener
 * @method {Ptr} SetViewer(hWnd) Set the clipboard viewer (legacy)
 * @method {Int} ChangeChain(hWndRemove, hWndNext) Change the clipboard viewer chain
 * @method {ClipboardAll} BackupAll() Backup the entire clipboard using ClipboardAll()
 * @method {Boolean} RestoreAll(clipBackup) Restore the clipboard from a ClipboardAll() backup
 * @example
 *   seq := Clipboard.SequenceNumber
 *   formats := Clipboard.EnumFormats()
 *   name := Clipboard.GetFormatName(formats[1])
 *   isAvailable := Clipboard.IsFormatAvailable(13) ; Unicode text
 *   backup := Clipboard.BackupAll()
 *   ; ... do something ...
 *   Clipboard.RestoreAll(backup)
 */
;@region class Clipboard
class Clipboard {

	#Requires AutoHotkey v2.0+
	static _logFile := A_ScriptDir "\clip_usage_log.json"
    static _usageLog := []

    /**
     * @description Opens the clipboard with retry logic.
     * @param {Integer} maxAttempts Maximum number of attempts to open the clipboard.
     * @param {Integer} delay Delay between attempts in milliseconds.
     * @throws {OSError} If the clipboard cannot be opened.
     * @returns {Boolean} True if opened successfully.
     */
    static Open(maxAttempts := 5, delay := 50) {
        attempt := 0
        while attempt < maxAttempts {
            if DllCall('User32.dll\OpenClipboard', 'Ptr', 0) {
                return true
            }
            attempt++
            Sleep(delay)
        }
        throw OSError('Failed to open clipboard after ' maxAttempts ' attempts', -1)
    }

    /**
     * @description Empties the clipboard.
     * @throws {OSError} If the clipboard cannot be emptied.
     * @returns {Boolean} True if successful.
     */
    static Clear() {
        return !!DllCall('User32.dll\EmptyClipboard')
        ; if !DllCall('User32.dll\EmptyClipboard') {
		; 	loop {
		; 		Sleep(A_Delay/10)
		; 	} until this.IsNotBusy && (DllCall('User32.dll\EmptyClipboard') || A_Index ~= A_Delay || A_Clipboard = '')
        ; }
		; else {
		; 	throw OSError('Failed to empty clipboard', -1)
		; }
        ; return true
		; A_Clipboard := ''
    }

    /**
     * @description Closes the clipboard.
     * @returns {Boolean} True if successful.
     */
    static Close() {
        return !!DllCall('User32.dll\CloseClipboard')
    }

	static _IsRTFContent(content) {
		return FormatConverter.VerifyRTF(content).isRTF
	}

	static _IsHTMLContent(content) {
		return FormatConverter.VerifyHTML(content).isHTML
	}

	static _SetClipboardRTF(rtfText) {
		; Register RTF format if needed
		static CF_RTF := DllCall("RegisterClipboardFormat", "Str", "Rich Text Format", "UInt")
		
		; Open and clear clipboard
		; DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)
		DllCall("OpenClipboard", "Ptr", 0)
		DllCall("EmptyClipboard")
		
		; Allocate and copy RTF data
		hGlobal := DllCall("GlobalAlloc", "UInt", 0x42, "Ptr", StrPut(rtfText, "UTF-8"))
		pGlobal := DllCall("GlobalLock", "Ptr", hGlobal, "Ptr")
		StrPut(rtfText, pGlobal, "UTF-8")
		DllCall("GlobalUnlock", "Ptr", hGlobal)
		
		; Set clipboard data and close
		DllCall("SetClipboardData", "UInt", CF_RTF, "Ptr", hGlobal)
		DllCall("CloseClipboard")
		; this.Sleep()
	}

	/**
	 * @description Backup the entire clipboard using ClipboardAll()
	 * @returns {ClipboardAll} The backup of the clipboard.
	 */
	static BackupAndClearClipboard() {
		backup := this.BackupAll()
		this.Clear()
		return backup
	}

	;@region Send()
	/**
	 * Universal send method handling both RTF and regular content
	 * @param {String|Array|Map|Object|Class} input The content to send
	 * @param {String} endChar The ending character(s) to append
	 * @param {Boolean} isClipReverted Whether to revert the clipboard
	 * @param {Integer} untilRevert Time in ms before reverting clipboard
	 * @returns {String} The sent content
	 */

	static Send(input?, endChar := '', isClipReverted := true, untilRevert := 500, delay := A_Delay) {

		cPrev := pClip := prevClip := ''
		cRev := revClip := isClipReverted
		tmRev := untilRevert
		eChr := endChar
		content := input

		ReadyToRestore := false
		GroupAdd('CtrlV', 'ahk_exe EXCEL.exe')
		GroupAdd('CtrlV', 'ahk_exe VISIO.exe')
		GroupAdd('CtrlV', 'ahk_exe OUTLOOK.exe') ;? maybe?

		; (!IsSet(input)) ? input := this : input
		if (!IsSet(input)){
			input := this
		}

		; Handle backup and clear first
		if (isClipReverted){
			prevClip := this.BackupAndClearClipboard()
		}

		; Process input based on type
		content := input
		if (this._IsRTFContent(content)) {
			verifiedRTF := FormatConverter.IsRTF(content, true)
			; infos(verifiedRTF)
			this._SetClipboardRTF(verifiedRTF endChar)
		}
		else {
			; Regular content handling
			A_Clipboard := content endChar
			this.Wait()
		}
		; Wait for clipboard and send
		Sleep(A_Delay)

		If WinActive('ahk_group CtrlV') {
			; Send('{sc1D Down}{sc2F}{sc1D Up}')          ;! {Control}{v}
			Send(key.paste)
			Sleep(A_Delay)
			readyToRestore := true
		}
        else {
			; Send('{sc2A Down}{sc152}{sc2A Up}')         ;! {Shift}{Insert}
			Send(key.shiftinsert)
			Sleep(A_Delay)
			readyToRestore := true
        }
		
		Sleep(A_Delay)

		; Restore clipboard if needed
		if (isClipReverted && readyToRestore) {
			this.Clear()
			A_Clipboard := prevClip
			this.Wait()
		}

		return content
	}
	; static Send(input?, endChar := '', revertClip := true, untilRevert := 500) {
	; 	; Infos('[' A_ThisFunc ']')
	; 	seqNumInitial := verifiedRTF := unset

	; 	ReadyToRestore := false
	; 	GroupAdd('CtrlV', 'ahk_exe EXCEL.exe')
	; 	GroupAdd('CtrlV', 'ahk_exe VISIO.exe')
	; 	GroupAdd('CtrlV', 'ahk_exe OUTLOOK.exe')

	; 	if (!IsSet(input)){
	; 		input := this
	; 	}

	; 	; Handle backup and clear first
	; 	if (revertClip){
	; 		this.BackupAll(&cBak)
	; 	}

	; 	this.Clear()

	; 	seqNumInitial := this.Get.SequenceNumber

	; 	loop {
	; 		Sleep(A_Delay/10)
	; 	} until this.IsNotBusy || A_Index ~= A_Delay

	; 	; Infos('IsRTF: ' (FormatConverter.VerifyRTF(input)).isRTF)
		
	; 	; Process input based on type
	; 	if (FormatConverter.VerifyRTF(input)) {
	; 		; Infos('IsRTF')
	; 		verifiedRTF := FormatConverter.IsRTF(input, true)
	; 		this.Set.RTF(verifiedRTF endChar)  ; Updated to include endChar as a parameter
	; 	}
	; 	else {
	; 		; Regular content handling
	; 		A_Clipboard := input endChar
	; 		; this.Set.Plain(input endChar)
	; 	}
	; 	loop {
	; 		; Wait for clipboard and send
	; 		Sleep(A_Delay/10)
	; 	} until seqNumInitial != this.Get.SequenceNumber && this.IsNotBusy

	; 	If WinActive('ahk_group CtrlV') {
	; 		; Send('{sc1D Down}{sc2F}{sc1D Up}')          ;! {Control}{v}
	; 		Send(key.paste)          ;! {Control}{v}
	; 		Sleep(A_Delay)
	; 		readyToRestore := true
	; 	}
    ;     else {
	; 		; Send('{sc2A Down}{sc152}{sc2A Up}')         ;! {Shift}{Insert}
	; 		Send(key.shiftinsert)         ;! {Shift}{Insert}
	; 		Sleep(A_Delay)
	; 		readyToRestore := true
    ;     }
		
	; 	loop {
	; 		Sleep(A_Delay)
	; 	} until readyToRestore || A_Index = 500

	; 	seqNumRestore := this.Get.SequenceNumber

	; 	; Restore clipboard if needed
	; 	if (revertClip && readyToRestore) {
	; 		this.ClearClipboard()
	; 		A_Clipboard := cBak
	; 		loop {
	; 			Sleep(A_Delay/10)
	; 		} until seqNumRestore != this.Get.SequenceNumber && this.IsNotBusy
	; 	}

	; 	return input
	; }

    /**
     * @property {Boolean} IsEmpty
     * @description Checks if the clipboard is empty.
     * @returns {Boolean} True if empty.
    ; Check if the clipboard is empty
    ; If GetClipboardData returns 0, the clipboard is empty
    ; If it returns a valid handle, the clipboard is not empty
    ; Return true if empty, false otherwise
    */
    static IsEmpty => this._IsEmpty()

    static _IsEmpty() {

        if DllCall("User32.dll\OpenClipboard", "Ptr", 0) {
            return (DllCall("User32.dll\GetClipboardData", "UInt", 0) ? false : true)
        }
        else {
            throw OSError("Failed to check clipboard", -1)
        }
    }
    
    /**
     * @property {UInt} GetSequenceNumber
     * @description Gets the clipboard sequence number (increments on change).
     * @example
     *   seq := Clipboard.GetSequenceNumber
     */
    static GetSequenceNumber => DllCall("User32.dll\GetClipboardSequenceNumber", "UInt")

    /**
     * @property {Ptr} Owner
     * @description Gets the HWND of the clipboard owner.
     * @example
     *   hwnd := Clipboard.Owner
     */
    static Owner => DllCall("User32.dll\GetClipboardOwner", "Ptr")

    /**
     * @method EnumFormats
     * @description Enumerates all available clipboard formats.
     * @returns {Array} Array of format identifiers.
     * @example
     *   formats := Clipboard.EnumFormats()
     */
    static EnumFormats() {
        local formats := []
        local prevFormat := 0
        this.Open()
        try {
            while (nextFormat := DllCall("User32.dll\EnumClipboardFormats", "UInt", prevFormat, "UInt")) {
                formats.Push(nextFormat)
                prevFormat := nextFormat
            }
        }
        finally {
            this.Close()
        }
        return formats
    }

    /**
     * @method GetFormatName
     * @description Gets the name of a clipboard format.
     * @param {Integer} fmt Format identifier.
     * @returns {String} Format name or empty string.
     * @throws {ValueError} If format identifier is not provided.
     * @example
     *   name := Clipboard.GetFormatName(fmt)
     */
    static GetFormatName(fmt) {
        local buf := Buffer(128, 0)
        if !IsSet(fmt) || !fmt {
            throw ValueError("Format identifier required", -1)
        }
        this.Open()
        try {
            local len := DllCall("User32.dll\GetClipboardFormatName", "UInt", fmt, "Ptr", buf, "Int", 128, "Int")
            return len ? StrGet(buf, len, "UTF-16") : ""
        }
        finally {
            this.Close()
        }
    }

    /**
     * @method IsFormatAvailable
     * @description Checks if a clipboard format is available.
     * @param {Integer} fmt Format identifier.
     * @returns {Boolean} True if available.
     * @throws {ValueError} If format identifier is not provided.
     * @example
     *   isAvailable := Clipboard.IsFormatAvailable(13)
     */
    static IsFormatAvailable(fmt) {
        if !IsSet(fmt) || !fmt
            throw ValueError("Format identifier required", -1)
        return !!DllCall("User32.dll\IsClipboardFormatAvailable", "UInt", fmt, "Int")
    }

    /**
     * @method GetBuffer
     * @description Gets clipboard data as a Buffer for a given format.
     * @param {Integer} fmt Format identifier.
     * @returns {Buffer|""} Buffer with clipboard data or empty string.
     * @throws {ValueError} If format identifier is not provided.
     * @example
     *   buf := Clipboard.GetBuffer(13)
     */
    static GetBuffer(fmt) {
        if !IsSet(fmt) || !fmt
            throw ValueError("Format identifier required", -1)
        this.Open()
        try {
            local hData := DllCall("User32.dll\GetClipboardData", "UInt", fmt, "Ptr")
            if !hData
                return ""
            local pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "Ptr")
            if !pData
                return ""
            local size := DllCall("Kernel32.dll\GlobalSize", "Ptr", hData, "UPtr")
            local buf := Buffer(size)
            DllCall("RtlMoveMemory", "Ptr", buf, "Ptr", pData, "UPtr", size)
            DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
            return buf
        } finally this.Close()
    }

    /**
     * @method AddFormatListener
     * @description Adds a clipboard format listener (modern clipboard monitoring).
     * @param {Ptr} hWnd Window handle to receive notifications.
     * @returns {Int} Nonzero if successful.
     * @throws {ValueError} If window handle is not provided.
     */
    static AddFormatListener(hWnd) {
        if !IsSet(hWnd) || !hWnd
            throw ValueError("Window handle required", -1)
        return DllCall("User32.dll\AddClipboardFormatListener", "Ptr", hWnd, "Int")
    }

    /**
     * @method RemoveFormatListener
     * @description Removes a clipboard format listener.
     * @param {Ptr} hWnd Window handle.
     * @returns {Int} Nonzero if successful.
     * @throws {ValueError} If window handle is not provided.
     */
    static RemoveFormatListener(hWnd) {
        if !IsSet(hWnd) || !hWnd
            throw ValueError("Window handle required", -1)
        return DllCall("User32.dll\RemoveClipboardFormatListener", "Ptr", hWnd, "Int")
    }

    /**
     * @method SetViewer
     * @description Sets the clipboard viewer (legacy monitoring).
     * @param {Ptr} hWnd Window handle.
     * @returns {Ptr} Handle to the next window in the chain.
     * @throws {ValueError} If window handle is not provided.
     */
    static SetViewer(hWnd) {
        if !IsSet(hWnd) || !hWnd
            throw ValueError("Window handle required", -1)
        return DllCall("User32.dll\SetClipboardViewer", "Ptr", hWnd, "Ptr")
    }

    /**
     * @method ChangeChain
     * @description Changes the clipboard viewer chain.
     * @param {Ptr} hWndRemove Handle to remove.
     * @param {Ptr} hWndNext Next window in chain.
     * @returns {Int} Nonzero if successful.
     * @throws {ValueError} If either window handle is not provided.
     */
    static ChangeChain(hWndRemove, hWndNext) {
        if !IsSet(hWndRemove) || !hWndRemove
            throw ValueError("hWndRemove required", -1)
        if !IsSet(hWndNext) || !hWndNext
            throw ValueError("hWndNext required", -1)
        return DllCall("User32.dll\ChangeClipboardChain", "Ptr", hWndRemove, "Ptr", hWndNext, "Int")
    }

    /**
     * @method BackupAll
     * @description Backup the entire clipboard using ClipboardAll().
     * @returns {ClipboardAll} Clipboard backup object.
     * @example
     *   backup := Clipboard.BackupAll()
     */
    static BackupAll(&cBak?) {
		cbak := ClipboardAll()
		return cBak
    }

    /**
     * @method RestoreAll
     * @description Restore the clipboard from a ClipboardAll() backup.
     * @param {ClipboardAll} clipBackup The backup object to restore.
     * @returns {Boolean} True if restored.
     * @throws {ValueError} If backup is not provided.
     * @example
     *   Clipboard.RestoreAll(backup)
     */
    static RestoreAll(clipBackup) {
        if !IsSet(clipBackup)
            throw ValueError("ClipboardAll backup required", -1)
        A_Clipboard := clipBackup
        return true
    }

    /**
     * @property {Boolean} IsOpen
     * @description Checks if the clipboard is currently open.
     * @returns {Boolean}
     */
    static IsOpen => !!DllCall("User32.dll\GetOpenClipboardWindow", "Ptr")

    /**
     * @property {Boolean} IsBusy
     * @description Checks if the clipboard is currently busy.
     * @returns {Boolean}
     */
    static IsBusy => !!DllCall("User32.dll\GetOpenClipboardWindow", "Ptr")

    /**
     * @property {Boolean} IsNotBusy
     * @description Checks if the clipboard is not busy.
     * @returns {Boolean}
     */
    static IsNotBusy => !DllCall("User32.dll\GetOpenClipboardWindow", "Ptr")

    /**
     * @method Wait
     * @description Waits until the clipboard is available or timeout.
     * @param {Integer} timeout Timeout in ms.
     * @returns {Boolean} True if clipboard became available.
     */
    static Wait(timeout := 1000) {
        local startTime := A_TickCount
        while this.IsBusy {
            if (A_TickCount - startTime > timeout) {
                return false
            }
            Sleep(10)
        }
        return true
    }

    /**
     * @method ClearClipboard
     * @description Clears the clipboard safely.
     * @returns {Boolean} True if successful.
     */
    static ClearClipboard() {
        this.OpenClipboard()
        this.EmptyClipboard()
        this.CloseClipboard()
        Sleep(A_Delay)
        return true
    }

    /**
     * @method OpenClipboard
     * @description Opens the clipboard with retry logic.
     * @param {Integer} maxAttempts Maximum number of attempts to open the clipboard.
     * @param {Integer} delay Delay between attempts in milliseconds.
     * @returns {Boolean} True if opened successfully.
     * @throws {OSError} If the clipboard cannot be opened.
     */
    static OpenClipboard(maxAttempts := 5, delay := 50) {
        local attempt := 0
        while attempt < maxAttempts {
            if DllCall("User32.dll\OpenClipboard", "Ptr", 0) {
                return true
            }
            attempt++
            Sleep(delay)
        }
        throw OSError("Failed to open clipboard after " maxAttempts " attempts", -1)
    }

    /**
     * @method EmptyClipboard
     * @description Empties the clipboard.
     * @returns {Boolean} True if successful.
     * @throws {OSError} If the clipboard cannot be emptied.
     */
    static EmptyClipboard() {
        if !DllCall("User32.dll\EmptyClipboard") {
            throw OSError("Failed to empty clipboard", -1)
        }
        return true
    }

    /**
     * @method CloseClipboard
     * @description Closes the clipboard.
     * @returns {Boolean} True if successful.
     */
    static CloseClipboard() {
        return !!DllCall("User32.dll\CloseClipboard")
    }

    /**
     * @method Busy
     * @description Checks if clipboard is currently open/busy.
     * @returns {Boolean} True if busy.
     */
    static Busy() {
        return !!DllCall("User32.dll\GetOpenClipboardWindow", "Ptr")
    }

    /**
     * @method Sleep
     * @description Waits for the clipboard to be available or for a specified time.
     * @param {Integer} n Time in ms to wait.
     * @returns {Void}
     */
    static Sleep(n := 10) {
        this.Wait(n)
    }

    
    /**
     * @description Gets clipboard data as string for a given format.
     * @param {Integer} format Clipboard format identifier.
     * @returns {String} Clipboard content or empty string.
     */
    static GetContent(format := 1) => Clipboard.Get.Content(format)

    /**
     * @description Gets TSV content from the clipboard.
     * @returns {String} TSV clipboard content or empty string.
     */
    static GetTSV() {
        format := this.RegisterFormat.TSV()
        return this.GetContent(format)
    }

    /**
     * @description Gets plain text from the clipboard.
     * @returns {String} Clipboard text or empty string.
     */
    static GetPlain() {
        static CF_TEXT := 1
        return this.GetContent(CF_TEXT)
    }

    /**
     * @description Gets Unicode text from the clipboard.
     * @returns {String} Clipboard text or empty string.
     */
    static GetUnicode() {
        static CF_UNICODETEXT := 13
        return this.GetContent(CF_UNICODETEXT)
    }

    /**
     * @description Gets RTF content from the clipboard.
     * @returns {String} RTF clipboard content or empty string.
     */
    static GetRTF() {
        format := this.RegisterFormat.RTF()
        return this.GetContent(format)
    }

    /**
     * @description Gets HTML content from the clipboard.
     * @returns {String} HTML clipboard content or empty string.
     */
    static GetHTML() {
        format := this.RegisterFormat.HTML()
        return this.GetContent(format)
    }

    /**
     * @description Gets CSV content from the clipboard.
     * @returns {String} CSV clipboard content or empty string.
     */
    static GetCSV() {
        format := this.RegisterFormat.CSV()
        return this.GetContent(format)
    }

	/**
	 * @description Convert clipboard content to CSV.
	 * @returns {String} CSV text.
	 */
	static ToCSV() {
		clipText := Clipboard.GetPlain()
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
		csvText := RTrim(csvText, "`n")
		this._LogUsage("ToCSV", Map(), csvText)
		return csvText
	}
	
	/**
	 * @description Convert clipboard content to JSON.
	 * @returns {String} JSON text.
	 */
	static ToJSON() {
		clipText := Clipboard.GetPlain()
		lines := StrSplit(clipText, "`n", "`r")
		jsonArray := []
		headers := StrSplit(lines[1], "`t")
		for i, line in lines {
			if (i == 1) {
				continue
			}
			fields := StrSplit(line, "`t")
			; Use a plain Map instead of {} to avoid __Item error
			row := Map()
			Loop headers.Length {
				row[headers[A_Index]] := fields.Has(A_Index) ? fields[A_Index] : ""
			}
			jsonArray.Push(row)
		}
		json := cJson.Dump(jsonArray)
		this._LogUsage("ToJSON", Map(), json)
		return json
	}
	
	/**
	 * @description Convert clipboard content to Key-Value JSON.
	 * @returns {String} JSON text.
	 */
	static ToKeyValueJSON() {
		clipText := Clipboard.GetPlain()
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
		json := cJson.Dump(obj)
		this._LogUsage("ToKeyValueJSON", Map(), json)
		return json
	}

	/**
	 * @description Convert CSV clipboard content to JSON.
	 * @returns {String} JSON text.
	 */
	static CSVToJSON() {
		csvText := Clipboard.GetCSV()
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
		json := cJson.Dump(jsonArray)
		this._LogUsage("CSVToJSON", Map(), json)
		return json
	}
    ;@region class Clipboard.Get
    /**
     * @class Clipboard.Get
     * @description Provides grouped accessors for clipboard state and sequence number.
     */
    class Get {

        /**
         * @property {UInt} SequenceNumber
         * @description Gets the clipboard sequence number (increments on change).
         * @example
         *   seq := Clipboard.Get.SequenceNumber
         */
        static SequenceNumber => DllCall("User32.dll\GetClipboardSequenceNumber", "UInt")

        /**
         * @property {Ptr} Owner
         * @description Gets the HWND of the clipboard owner.
         * @example
         *   hwnd := Clipboard.Get.Owner
         */
        static Owner => DllCall("User32.dll\GetClipboardOwner", "Ptr")

        /**
         * @property {String} Format
         * @description Gets the current clipboard format.
         * @example
         *   format := Clipboard.Get.Format
         */
        static Format => DllCall("User32.dll\GetClipboardFormatName", "UInt", DllCall("User32.dll\GetClipboardFormatName", "UInt"), "Str", "", "UInt", 256)

        /**
         * @method Clipboard.Get.Data
         * @description Retrieves data from the clipboard.
         * @param {UInt} format The format of the data to retrieve.
         * @returns {Ptr} Pointer to the clipboard data.
         * @throws {OSError} If the data cannot be retrieved.
         */
        static Data(format) {
            if !IsSet(format) {
                throw ValueError("Format required", -1)
            }
            if !DllCall("User32.dll\OpenClipboard", "Ptr", 0) {
                throw OSError("Failed to open clipboard", -1)
            }
            local hData := DllCall("User32.dll\GetClipboardData", "UInt", format, "Ptr")
            if !hData {
                throw OSError("Failed to get clipboard data", -1)
            }
            return hData
        }

        /**
         * @description Gets clipboard data as string for a given format.
         * @param {Integer} format Clipboard format identifier.
         * @returns {String} Clipboard content or empty string.
         */
        static Content(format := 1) {
            if !Clipboard.Open() {
                return ""
            }
            try {
                hData := DllCall('User32.dll\GetClipboardData', 'UInt', format, 'Ptr')
                if !hData {
                    return ""
                }
                pData := DllCall('Kernel32.dll\GlobalLock', 'Ptr', hData, 'Ptr')
                if !pData {
                    return ""
                }
                text := StrGet(pData, "UTF-8")
                DllCall('Kernel32.dll\GlobalUnlock', 'Ptr', hData)
                return text
            } finally {
                Clipboard.Close()
            }
        }
    }
    ; ---------------------------------------------------------------------------
    ;@endregion class Clipboard.Get
    ; ---------------------------------------------------------------------------

    ; For backward compatibility, keep static methods on Clipboard itself
    /**
     * @description Sets clipboard content with specified format.
     * @param {String} content Content to set in the clipboard.
     * @param {Integer} format Clipboard format identifier.
     * @throws {OSError} If clipboard operations fail.
     */
    static SetContent(content, format) => Clipboard.Set.Content(content, format)

    ;@region Clipboard.Set
    /**
     * @class Clipboard.Set
     * @description Provides methods to set clipboard content in various formats and raw format.
     */
    class Set {
        /**
         * @description Sets clipboard content with specified format.
         * @param {String} content Content to set in the clipboard.
         * @param {Integer} format Clipboard format identifier.
         * @throws {OSError} If clipboard operations fail.
         */
        static Content(content, format) {
            size := StrPut(content, "UTF-8")
            hGlobal := DllCall('Kernel32.dll\GlobalAlloc', 'UInt', 0x42, 'UPtr', size)
            if !hGlobal {
                throw OSError('Failed to allocate memory', -1)
            }
            try {
                pGlobal := DllCall('Kernel32.dll\GlobalLock', 'Ptr', hGlobal, 'Ptr')
                if !pGlobal {
                    throw OSError('Failed to lock memory', -1)
                }
                StrPut(content, pGlobal, "UTF-8")
                DllCall('Kernel32.dll\GlobalUnlock', 'Ptr', hGlobal)
                if !DllCall('User32.dll\SetClipboardData', 'UInt', format, 'Ptr', hGlobal) {
                    throw OSError('Failed to set clipboard data', -1)
                }
                hGlobal := 0 ; Ownership transferred to system
            } catch Any as err {
                if hGlobal {
                    DllCall('Kernel32.dll\GlobalFree', 'Ptr', hGlobal)
                }
                throw err
            }
        }

        /**
         * @description Sets RTF content to the clipboard.
         * @param {String} rtfText RTF formatted text.
         * @throws {OSError} If clipboard operations fail.
         */
        static RTF(rtfText, endChar:= '') {
            format := Clipboard.RegisterFormat.RTF
            Clipboard.Open()
			if A_Clipboard != '' {
				try Clipboard.Clear()
			}
			Clipboard.SetContent(rtfText endChar, format)
            try {
            } finally {
            	Clipboard.Close()
            }
        }

        /**
         * @description Sets plain text to the clipboard.
         * @param {String} text Plain text.
         * @throws {OSError} If clipboard operations fail.
         */
        static Plain(text) {
            static CF_TEXT := 1
            Clipboard.Open()
            try {
                Clipboard.Clear()
                Clipboard.SetContent(text, CF_TEXT)
            } finally {
                Clipboard.Close()
            }
        }

        /**
         * @description Sets Unicode text to the clipboard.
         * @param {String} text Unicode text.
         * @throws {OSError} If clipboard operations fail.
         */
        static Unicode(text) {
            static CF_UNICODETEXT := 13
            Clipboard.Open()
            try {
                Clipboard.Clear()
                size := StrPut(text, "UTF-16")
                hGlobal := DllCall('Kernel32.dll\GlobalAlloc', 'UInt', 0x42, 'UPtr', size * 2)
                if !hGlobal
                    throw OSError('Failed to allocate memory', -1)
                try {
                    pGlobal := DllCall('Kernel32.dll\GlobalLock', 'Ptr', hGlobal, 'Ptr')
                    if !pGlobal
                        throw OSError('Failed to lock memory', -1)
                    StrPut(text, pGlobal, "UTF-16")
                    DllCall('Kernel32.dll\GlobalUnlock', 'Ptr', hGlobal)
                    if !DllCall('User32.dll\SetClipboardData', 'UInt', CF_UNICODETEXT, 'Ptr', hGlobal)
                        throw OSError('Failed to set clipboard data', -1)
                    hGlobal := 0
                } catch as err {
                    if hGlobal
                        DllCall('Kernel32.dll\GlobalFree', 'Ptr', hGlobal)
                    throw err
                }
            } finally {
                Clipboard.Close()
            }
        }

        /**
         * @description Sets HTML content to the clipboard.
         * @param {String} htmlText HTML formatted text.
         * @throws {OSError} If clipboard operations fail.
         */
        static HTML(htmlText) {
            format := Clipboard.RegisterFormat.HTML()
            Clipboard.Open()
            try {
                Clipboard.Clear()
                Clipboard.SetContent(htmlText, format)
            } finally {
                Clipboard.Close()
            }
        }

        /**
         * @description Sets CSV content to the clipboard.
         * @param {String} csvText CSV formatted text.
         * @throws {OSError} If clipboard operations fail.
         */
        static CSV(csvText) {
            format := Clipboard.RegisterFormat.CSV()
            Clipboard.Open()
            try {
                Clipboard.Clear()
                Clipboard.SetContent(csvText, format)
            } finally {
                Clipboard.Close()
            }
        }
    }
    ; ---------------------------------------------------------------------------
    ;@endregion class Clipboard.Set
    ; ---------------------------------------------------------------------------

    ;@region Clipboard.RegisterFormat
    /**
     * @class Clipboard.RegisterFormat
     * @description Provides methods to register custom clipboard formats.
     */
    class RegisterFormat {
        /**
         * @description Registers the RTF clipboard format.
         * @returns {Integer} Format identifier.
         */
        static RTF => DllCall('User32.dll\RegisterClipboardFormat', 'Str', 'Rich Text Format', 'UInt')
        /**
         * @description Registers the HTML clipboard format.
         * @returns {Integer} Format identifier.
         */
        static HTML => DllCall('User32.dll\RegisterClipboardFormat', 'Str', 'HTML Format', 'UInt')
        /**
         * @description Registers the CSV clipboard format.
         * @returns {Integer} Format identifier.
         */
        static CSV => DllCall('User32.dll\RegisterClipboardFormat', 'Str', 'CSV', 'UInt')
        /**
         * @description Registers the TSV clipboard format.
         * @returns {Integer} Format identifier.
         */
        static TSV => DllCall('User32.dll\RegisterClipboardFormat', 'Str', 'TSV', 'UInt')
        /**
         * @description Registers the Unicode Text clipboard format.
         * @returns {Integer} Format identifier.
         */
        static UnicodeText => DllCall('User32.dll\RegisterClipboardFormat', 'Str', 'UnicodeText', 'UInt')
        /**
         * @description Registers the OEM Text clipboard format.
         * @returns {Integer} Format identifier.
         */
        static OEMText => DllCall('User32.dll\RegisterClipboardFormat', 'Str', 'OEMText', 'UInt')
        /**
         * @description Registers the Bitmap clipboard format.
         * @returns {Integer} Format identifier.
         */
        static Bitmap => DllCall('User32.dll\RegisterClipboardFormat', 'Str', 'Bitmap', 'UInt')
        /**
         * @description Registers the FileName clipboard format.
         * @returns {Integer} Format identifier.
         */
        static FileName => DllCall('User32.dll\RegisterClipboardFormat', 'Str', 'FileName', 'UInt')
        /**
         * @description Registers a custom clipboard format by name.
         * @param {String} name Format name.
         * @returns {Integer} Format identifier.
         */
        static Custom(name) {
            return DllCall('User32.dll\RegisterClipboardFormat', 'Str', name, 'UInt')
        }
    }
    ;@endregion Clipboard.RegisterFormat

	/**
     * @private
     * @description Log Clip method usage to JSON file and optionally display.
     * @param {String} method Method name
     * @param {Map|Object} params Parameters used
     * @param {Any} result Result returned (optional)
     */
	static _LogUsage(method, params, result := unset) {
		entry := Map(
			"timestamp", FormatTime(, "yyyy-MM-dd HH:mm:ss"),
			"method", method,
			"params", params,
			"result", IsSet(result) ? result : ""
		)
		this._usageLog.Push(entry)
		try {
			FileDelete(this._logFile)
		} catch
		{}
		FileAppend(cJson.Dump(this._usageLog, 1), this._logFile)
		; Optionally display log (ErrorLogGui or MsgBox)
		; ErrorLogGui.Show(this._usageLog) ; Uncomment if ErrorLogGui is available
	}
    /**
     * @method __Delete
     * @description Clean up resources when object is destroyed.
     */
    __Delete() {
        ; No persistent resources to clean up, but method included for completeness.
    }
}
; ---------------------------------------------------------------------------
;@endregion class Clipboard
; ---------------------------------------------------------------------------

