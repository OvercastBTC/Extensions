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
#Include <Extensions\Pipe>


;@region Detect Hidden
/**
 * @class DH
 * @description Utility class for managing detection of hidden windows and text.
 * @version 1.0.0
 * @author OvercastBTC
 * @date 2025-04-23
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @example
 * ; Set both to true
 * DH()
 * ; Set both to false
 * DH(false)
 * ; Set individually
 * DH.Text(true)
 * DH.Windows(false)
 */
class DH {
	#Requires AutoHotkey v2.0+

	; Store original settings
	static originalState := {
		Text: A_DetectHiddenText,
		Windows: A_DetectHiddenWindows
	}

	/**
	 * @constructor
	 * @param {Boolean} detect Whether to detect hidden elements (default: true)
	 * @returns {Object} The current instance for method chaining
	 */
	__New(detect := true) {
		DH.Set(detect)
		return this
	}

	/**
	 * @static
	 * @description Static constructor alternative
	 * @param {Boolean} detect Whether to detect hidden elements (default: true)
	 * @returns {Object} The class for method chaining
	 */
	static __New(detect := true) {
		return this.Set(detect)
	}

	/**
	 * @static
	 * @description Sets detection for both hidden windows and text
	 * @param {Boolean} detect Whether to detect hidden elements
	 * @returns {Object} The class for method chaining
	 */
	static Set(detect := true) {
		this.Text(detect)
		this.Windows(detect)
		return this
	}

	/**
	 * @static
	 * @description Sets detection for hidden text
	 * @param {Boolean} detect Whether to detect hidden text
	 * @returns {Object} The class for method chaining
	 */
	static Text(detect := true) {
		DetectHiddenText(detect)
		return this
	}

	/**
	 * @static
	 * @description Sets detection for hidden windows
	 * @param {Boolean} detect Whether to detect hidden windows
	 * @returns {Object} The class for method chaining
	 */
	static Windows(detect := true) {
		DetectHiddenWindows(detect)
		return this
	}

	/**
	 * @description Gets current detection state
	 * @returns {Object} Object with Text and Windows properties
	 */
	static GetState() {
		return {
			Text: A_DetectHiddenText,
			Windows: A_DetectHiddenWindows
		}
	}
	
	/**
	 * @description Restores original settings from when class was first loaded
	 * @returns {Object} The class for method chaining
	 */
	static Restore() {
		this.Text(this.originalState.Text)
		this.Windows(this.originalState.Windows)
		return this
	}
}
; @endregion Detect Hidden
; ---------------------------------------------------------------------------
;@region class SM
/**
 * @class SM
 * @description Advanced utility class for managing SendMode and key delay settings.
 * @version 3.1.0
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-04-23
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @example
 * ; Save current settings and switch to Event mode
 * settings := SM()
 * ; Restore previous settings
 * SM.Restore(settings)
 * ; Just change mode
 * SM.Mode("Input") 
 */
class SM {

	#Requires AutoHotkey v2.0+

	; Store original settings
	objSM := {}

	/**
	 * @constructor
	 * @description Captures current settings and switches to Event mode
	 * @returns {SM} Instance for method chaining
	 */
	__New(&objSM?) {
		; Capture current settings
		this.objSM := {
			mode: A_SendMode,
			delay: A_KeyDelay,
			duration: A_KeyDuration
		}
		
		; Set to default values for Event mode
		SendMode('Event')
		SetKeyDelay(-1, -1)
		objSM := this.objSM ; Return the captured settings
		return this
	}

	/**
	 * @description Restores original settings when object is destroyed
	 */
	__Delete() {
		this.objSM := {} ; Clear the stored settings
	}
	
	/**
	 * @description Sets the SendMode to a specified value
	 * @param {String} mode The SendMode to set (e.g., "Input", "Event")
	 * @returns {SM} This instance for method chaining
	 */
	Mode(mode) {
		SendMode(mode)
		return this
	}
	
	/**
	 * @description Sets the key delay settings
	 * @param {Integer} delay The delay between keystrokes
	 * @param {Integer} duration The key press duration
	 * @returns {SM} This instance for method chaining
	 */
	KeyDelay(delay, duration) {
		SetKeyDelay(delay, duration)
		return this
	}
	
	/**
	 * @description Get current SendMode settings
	 * @returns {Object} Object containing current SendMode and key delay settings
	 */
	GetSettings() {
		return this.objSM := {
			mode: A_SendMode,
			delay: A_KeyDelay,
			duration: A_KeyDuration
		}
	}
	
	/**
	 * @description Resets the SendMode and key delay settings to Input mode
	 * @returns {SM} This instance for method chaining
	 */
	Reset() {
		SendMode('Input')
		SetKeyDelay(0, 0)
		return this
	}
	
	/**
	 * @description Static method to quickly set SendMode
	 * @param {String} mode The SendMode to set
	 */
	static Mode(mode) {
		SendMode(mode)
	}
	
	/**
	 * @description Static method to quickly set key delay
	 * @param {Integer} delay The delay between keystrokes
	 * @param {Integer} duration The key press duration
	 */
	static SetDelays(delay, duration) {
		SetKeyDelay(delay, duration)
	}
}
; ---------------------------------------------------------------------------
; @region rSM
/**
 * @name RestoreSendMode
 * @abstract Restores SendMode and key delay settings from an object.
 * @author OvercastBTC (Adam Bacon)
 * @date 2025-04-23
 * @version 3.1.0
 * @param {Object} objSM Object containing SendMode and key delay settings.
 * @description Uses try to identify of objSM is populated, and sets/resets the SendMode() and SetKeyDelay()
 */
class rSM {
	__New(objSM?) {
		try {
			; Check if objSM is set and has properties
			if (IsObject(objSM) && objSM.HasOwnProp("s") && objSM.HasOwnProp("d") && objSM.HasOwnProp("p")) {
				SendMode(objSM.s)
				SetKeyDelay(objSM.d, objSM.p)
			}
			else {
				SendMode('Input')
				SetKeyDelay(0, 0) ; Reset key delay to default values
			}
		} finally {
			SendMode('Input')
			SetKeyDelay(0, 0) ; Reset key delay to default values
		}
	}
}
; @endregion rSM
; ---------------------------------------------------------------------------
; @region BISL
/**
 * @class BISL
 * @description Advanced utility class for managing BlockInput and SendLevel settings.
 * @version 1.1.0
 * @author OvercastBTC
 * @date 2025-04-23
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @example
 * ; Save current state and block input with sendlevel 1
 * state := BISL(1)
 * ; Restore previous settings
 * BISL.Restore(state)
 * ; Just change BlockInput
 * BISL.Block(true)
 */
class BISL {
	#Requires AutoHotkey v2.0+

	/**
	 * @property {Object} DefaultSettings
	 * @description Default settings for BlockInput and SendLevel
	 */
	static DefaultSettings := {
		SendLevel: 0,
		BlockInput: false
	}

	; Tracking for current block state
	static _currentBlockState := false

	/**
	 * @constructor
	 * @param {Integer|Object} params SendLevel or settings object
	 * @param {Boolean} block Whether to block input
	 * @returns {Object} Previous settings before changes
	 */
	__New(params?, block?) {
		return BISL.Apply(params?, block?)
	}

	/**
	 * @static
	 * @description Static constructor alternative
	 * @param {Integer|Object} params SendLevel or settings object
	 * @param {Boolean} block Whether to block input
	 * @returns {Object} Previous settings before changes
	 */
	static __New(params?, block?) {
		return this.Apply(params?, block?)
	}

	/**
	 * @static
	 * @description Applies BlockInput and SendLevel settings
	 * @param {Integer|Object} params SendLevel or settings object
	 * @param {Boolean} block Whether to block input
	 * @returns {Object} Previous settings for later restoration
	 */
	static Apply(params?, block?) {
		; Capture current settings
		prevSettings := {
			SendLevel: A_SendLevel,
			BlockInput: this._currentBlockState
		}

		; Handle number parameter as SendLevel
		if (IsSet(params) && params is Integer) {
			this.Level(params)
			
			; Handle optional block parameter when first param is a number
			if (IsSet(block) && block is Integer) {
				this.Block(!!block)
			}
			
			return prevSettings
		}

		; Apply default settings if no params
		if (!IsSet(params)) {
			this.Level(this.DefaultSettings.SendLevel)
			this.Block(this.DefaultSettings.BlockInput)
			return prevSettings
		}

		; Apply settings from object
		if (params is Object) {
			; Support different property naming styles
			if (params.HasOwnProp("SendLevel") || params.HasOwnProp("sl"))
				this.Level(params.HasOwnProp("SendLevel") ? params.SendLevel : params.sl)
			
			if (params.HasOwnProp("BlockInput") || params.HasOwnProp("bi"))
				this.Block(params.HasOwnProp("BlockInput") ? params.BlockInput : params.bi)
		}

		return prevSettings
	}

	/**
	 * @static
	 * @description Sets just the SendLevel
	 * @param {Integer} level The SendLevel to set
	 * @returns {Object} The class for method chaining
	 */
	static Level(level := 0) {
		; Reset to zero first as recommended
		SendLevel(0)
		
		; Apply the new level with safe value handling
		if (IsInteger(level)) {
			if (level < 0)
				level := 0
			
			; Avoid going beyond 100 (AHK limit) by using a safer approach
			if (level >= 100)
				level := 99
				
			SendLevel(level)
		}
		
		return this
	}

	/**
	 * @static
	 * @description Sets just the BlockInput state
	 * @param {Boolean|Integer} block Whether to block input (true/false or 1/0)
	 * @returns {Object} The class for method chaining
	 */
	static Block(block := true) {
		block := !!block
		BlockInput(block)
		this._currentBlockState := block
		return this
	}

	/**
	 * @static
	 * @description Restores BlockInput and SendLevel from an object
	 * @param {Object} settings Settings object to restore from
	 * @returns {Object} The class for method chaining
	 */
	static Restore(settings) {
		if (!IsSet(settings) || !IsObject(settings)) {
			settings := this.DefaultSettings
		}
		
		; Support different property naming styles
		if (settings.HasOwnProp("SendLevel") || settings.HasOwnProp("sl"))
			this.Level(settings.HasOwnProp("SendLevel") ? settings.SendLevel : settings.sl)
		
		if (settings.HasOwnProp("BlockInput") || settings.HasOwnProp("bi"))
			this.Block(settings.HasOwnProp("BlockInput") ? settings.BlockInput : settings.bi)
			
		return this
	}
	
	/**
	 * @description Gets current BlockInput and SendLevel settings
	 * @returns {Object} Object with current settings
	 */
	static GetState() {
		return {
			SendLevel: A_SendLevel,
			BlockInput: this._currentBlockState
		}
	}
	
	/**
	 * @static
	 * @description Resets SendLevel to 0 and unblocks input
	 * @returns {Object} The class for method chaining
	 */
	static Reset() {
		this.Level(0)
		this.Block(false)
		return this
	}
}
; @endregion BISL
; ---------------------------------------------------------------------------
; @region SM_BISL
/**
 * @class SM_BISL
 * @description Convenience class that combines SM and BISL functionality
 * @version 1.0.0
 * @author OvercastBTC
 * @date 2025-04-23
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @example
 * ; Set SendMode to Event and SendLevel to 1
 * settings := SM_BISL(1)
 */
class SM_BISL {
	/**
	 * @constructor
	 * @param {Integer} n SendLevel to apply (default: 1)
	 * @param {Object} SendModeObj Reference to store SendMode settings
	 * @returns {Object} SendModeObj with settings
	 */
	__New(n := 1, &SendModeObj?) {
		; Initialize SendModeObj if not provided
		if (!IsSet(SendModeObj)){
			SendModeObj := {}
		}
		SM(&SendModeObj)
		BISL(n)
		return SendModeObj
	}
	
	/**
	 * @static
	 * @description Static constructor alternative
	 * @param {Integer} n SendLevel to apply (default: 1)
	 * @param {Object} SendModeObj Reference to store SendMode settings
	 * @returns {Object} SendModeObj with settings
	 */
	static __New(n := 1, &SendModeObj?) {
		; Initialize SendModeObj if not provided
		if (!IsSet(SendModeObj))
			SendModeObj := {}
			
		SM(&SendModeObj)
		BISL(n)
		return SendModeObj
	}
}
; @endregion SM_BISL
; ---------------------------------------------------------------------------
; @region rSM_BISL
/**
 * @class rSM_BISL
 * @description Convenience class for restoring SM settings and resetting BISL
 * @version 1.0.0
 * @author OvercastBTC
 * @date 2025-04-23
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @example
 * ; Restore SendMode and reset BISL
 * rSM_BISL(savedSettings)
 */
class rSM_BISL {
	/**
	 * @constructor
	 * @param {Object} SendModeObj SendMode settings to restore
	 * @returns {Object} This instance for method chaining
	 */
	__New(SendModeObj?) {
		SM()
		BISL(0)
		return this
	}
	
	/**
	 * @static
	 * @description Static constructor alternative
	 * @param {Object} SendModeObj SendMode settings to restore
	 * @returns {Object} The class for method chaining
	 */
	static __New(SendModeObj?) {
		SM()
		BISL(0)
		return this
	}
}
; class SM_BISL {
; 	__New(&SendModeObj, n := 1) {
; 		SM(&SendModeObj)
; 		BISL(n)
; 		return SendModeObj
; 	}
; }
; class rSM_BISL {
; 	__New(SendModeObj) {
; 		rSM(SendModeObj)
; 		BISL(0)
; 	}
; }
; @endregion SM_BISL
; ---------------------------------------------------------------------------
; @region SD
/**
 * @class SD
 * @description Comprehensive utility class for managing various system delays.
 * @version 1.1.0
 * @author OvercastBTC
 * @date 2025-04-23
 * @requires AutoHotkey v2.0+
 * @license MIT
 *
 * @example
 * ; Set all delays to -1
 * SD()
 * ; Set all delays with custom values
 * SD(10, 50)
 * ; Set specific delay
 * SD.Control(20)
 */
class SD {
	#Requires AutoHotkey v2.0+

	/**
	 * @property {Integer} _defaults
	 * @description Default delay values used when resetting
	 */
	static _defaults := {
		control: -1,
		mouse: -1,
		window: -1,
		key: -1,
		keyDuration: -1
	}

	/**
	 * @constructor
	 * @param {Integer} delay Main delay value for Control, Mouse, and Window (default: -1)
	 * @param {Integer} keyDuration Key press duration for KeyDelay (default: -1)
	 * @returns {Object} The current instance for method chaining
	 */
	__New(delay := -1, keyDuration := -1) {
		SD.SetAll(delay, keyDuration)
		return this
	}

	/**
	 * @static
	 * @description Static constructor alternative
	 * @param {Integer} delay Main delay value (default: -1)
	 * @param {Integer} keyDuration Key press duration (default: -1)
	 */
	static __New(delay := -1, keyDuration := -1) {
		SD.SetAll(delay, keyDuration)
	}

	/**
	 * @static 
	 * @description Sets all delay types to the same value
	 * @param {Integer} delay Delay value in milliseconds (default: -1)
	 * @param {Integer} keyDuration Key press duration (default: -1)
	 * @returns {Object} The class for method chaining
	 */
	static SetAll(delay := -1, keyDuration := -1) {
		this.Control(delay)
		this.Mouse(delay)
		this.Window(delay)
		this.Key(delay, keyDuration)
		return this
	}

	/**
	 * @static
	 * @description Sets control delay
	 * @param {Integer} delay Delay in milliseconds
	 * @returns {Object} The class for method chaining
	 */
	static Control(delay := -1) {
		if (!IsInteger(delay))
			delay := -1
		SetControlDelay(delay)
		return this
	}

	/**
	 * @static
	 * @description Sets mouse delay
	 * @param {Integer} delay Delay in milliseconds
	 * @returns {Object} The class for method chaining
	 */
	static Mouse(delay := -1) {
		if (!IsInteger(delay))
			delay := -1
		SetMouseDelay(delay)
		return this
	}

	/**
	 * @static
	 * @description Sets window delay
	 * @param {Integer} delay Delay in milliseconds
	 * @returns {Object} The class for method chaining
	 */
	static Window(delay := -1) {
		if (!IsInteger(delay))
			delay := -1
		SetWinDelay(delay)
		return this
	}

	/**
	 * @static
	 * @description Sets key delay and duration
	 * @param {Integer} delay Delay in milliseconds
	 * @param {Integer} duration Key press duration in milliseconds
	 * @returns {Object} The class for method chaining
	 */
	static Key(delay := -1, duration := -1) {
		if (!IsInteger(delay))
			delay := -1
		if (!IsInteger(duration))
			duration := -1
		SetKeyDelay(delay, duration)
		return this
	}

	/**
	 * @static
	 * @description Resets all delays to default values
	 * @returns {Object} The class for method chaining
	 */
	static Reset() {
		return this.SetAll(this._defaults.key, this._defaults.keyDuration)
	}

	/**
	 * @description Gets current delay settings
	 * @returns {Object} Object with all current delay settings
	 */
	static GetState() {
		return {
			Control: A_ControlDelay,
			Mouse: A_MouseDelay,
			Window: A_WinDelay,
			Key: A_KeyDelay,
			KeyDuration: A_KeyDuration
		}
	}
}
; @endregion SD
; ---------------------------------------------------------------------------
; @region Clip
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
		BISL(n)
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
		if hCtl{
			DllCall('SendMessage', 'Ptr', hCtl, 'UInt', WM_COPY, 'Ptr', 0, 'Ptr', 0)
		}
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
			ErrorLogGui().Show(this._usageLog)
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
		; 		; Send(keys.paste)
		; 		Send(keys.shiftinsert)
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
; @endregion Clip
; ----------------------------------------------------------------------------
; @region Conversions
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
#HotIf !WinActive(VSCode.exe)
^+r:: ; Ctrl+Shift+R to convert RTF to HTML
{
	rtfData := Clipboard._SetClipboardRTF(A_Clipboard)
	MsgBox("RTF data converted to RTF format")
}
^+m:: ; Ctrl+Shift+M to convert Markdown to RTF
{
	mdtext := FormatConverter.MarkdownToRTF(A_Clipboard)
	mdData := Clipboard._SetClipboardRTF(mdtext)
	MsgBox("HTML data converted to RTF format")
}
#HotIf
; ----------------------------------------------------------------------------
; @endregion Format Conversion Hotkeys
; ----------------------------------------------------------------------------
; @region Clipboard Class
; ----------------------------------------------------------------------------
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

class Clipboard {

	#Requires AutoHotkey v2.0+
	static _logFile := A_ScriptDir "\clip_usage_log.json"
	static _usageLog := []

	; @region Open()
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
	; @endregion Open()
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; @region Clear()
	/**
	 * @description Empties the clipboard.
	 * @throws {OSError} If the clipboard cannot be emptied.
	 * @returns {Boolean} True if successful.
	 */
	static Clear() {
		return !!DllCall('User32.dll\EmptyClipboard')
	}
	; @endregion Clear()
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; @region Close()
	/**
	 * @description Closes the clipboard.
	 * @returns {Boolean} True if successful.
	 */
	static Close() {
		return !!DllCall('User32.dll\CloseClipboard')
	}
	; @endregion Close()
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; @region _IsHTMLContent
	static _IsHTMLContent(content) {
		; Simple HTML detection logic - check for common HTML tags
		; return RegExMatch(content, "i)^\s*<(!DOCTYPE|html|head|body|div)")
		return FormatConverter.VerifyHTML(content).isHTML
	}
	
	; @endregion _IsHTMLContent
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; @region _IsRTFContent
	static _IsRTFContent(content:=unset) {
		!IsSet(content) ? contect := this : content
		return FormatConverter.VerifyRTF(content).isRTF
	}
	; @endregion _IsRTFContent
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; @region _SetClipboardRTF()
	/**
	 * @description Set the clipboard content to RTF format.
	 * @param rtfText 
	 */
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
		return true
	}
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	;@region ToRTF()
	/**
	 * @description Converts current clipboard content to RTF format using existing converters
	 * @param {Boolean} standardize Whether to standardize existing RTF content
	 * @param {Boolean} setClipboard Whether to set converted RTF back to clipboard
	 * @param {String} sourceFormat Force a specific source format detection
	 * @returns {String} RTF formatted text
	 */
	static ToRTF(standardize := true, setClipboard := true, sourceFormat := "") {
		; Get current clipboard content and detect format
		clipText := ""
		detectedFormat := ""
		
		; Use enhanced format detection if no source format specified
		if (!sourceFormat) {
			detectedFormat := FormatConverter.DetectClipboardFormat()
			
			; Get content based on detected format using existing methods
			switch (detectedFormat) {
				case "rtf":
					clipText := this.GetRTF()
				case "html": 
					clipText := this.GetHTML()
				case "csv":
					clipText := this.GetCSV()
				case "tsv":
					clipText := this.GetTSV()
				case "unicode", "text":
					clipText := this.GetUnicode()
					; Re-analyze the text content for more specific format detection
					if (clipText) {
						detectedFormat := FormatConverter.DetectFormat(clipText, false)
					}
				default:
					; Fallback to Unicode text
					clipText := this.GetUnicode()
					if (clipText) {
						detectedFormat := FormatConverter.DetectFormat(clipText, false)
					}
			}
		} else {
			; Use forced source format
			detectedFormat := sourceFormat
			switch (sourceFormat) {
				case "rtf":
					clipText := this.GetRTF()
				case "html":
					clipText := this.GetHTML()
				case "csv":
					clipText := this.GetCSV()
				case "tsv":
					clipText := this.GetTSV()
				default:
					clipText := this.GetUnicode()
			}
		}
		
		if (!clipText) {
			return ""
		}
		
		; Convert based on detected format using existing converters
		rtfContent := ""
		switch (detectedFormat) {
			case "rtf":
				rtfContent := standardize ? FormatConverter.RTFtoRTF(clipText, true) : clipText
			case "html":
				rtfContent := FormatConverter.HTMLToRTF(clipText)
			case "markdown":
				rtfContent := FormatConverter.MarkdownToRTF(clipText)
			case "csv", "tsv":
				; Convert structured data to RTF using existing method
				rtfContent := FormatConverter.toRTF(clipText)
			default:
				; Plain text or unknown format
				rtfContent := FormatConverter.toRTF(clipText)
		}
		
		; Set back to clipboard if requested using existing method
		if (setClipboard && rtfContent) {
			this.Set.RTF(rtfContent)
		}
		
		this._LogUsage("ToRTF", Map(
			"standardize", standardize, 
			"setClipboard", setClipboard,
			"sourceFormat", detectedFormat
		), rtfContent)
		
		return rtfContent
	}
	; @endregion ToRTF()
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; @region winclipSetRTF()
	; static winclipSetRTF(rtfText) {
	; 	wClip := WinClip()
	; 	if (this._IsRTFContent(rtfText)) {
	; 		wClip.SetRTF(rtfText)
	; 	} else {
	; 		throw OSError("Invalid RTF content", -1)
	; 	}
	; }
	; @endregion winclipSetRTF()
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; @region SetRTF()
	static SetRTF(rtfText) {
		; return this.winclipSetRTF(rtfText)
		return this._SetClipboardRTF(rtfText)
	}
	; @endregion SetRTF()
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; -----------------------------------------------------------------------------
	; @region BackupAndClearClipboard()
	/**
	 * @description Backup the entire clipboard using ClipboardAll()
	 * @returns {ClipboardAll} The backup of the clipboard.
	 */
	static BackupAndClearClipboard(&backup?) {
		backup := this.Backup()
		this.Clear()
		return backup
	}

	/**
	 * @description {helper method} Backup and clear the clipboard.
	 * @returns {ClipboardAll} The backup of the clipboard from BackupAndClearClipboard()
	 */
	static BackupAndClear(&backup?) {
		return this.BackupAndClearClipboard(&backup?)
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

		prevClip := ''

		ReadyToRestore := false
		GroupAdd('CtrlV', 'ahk_exe EXCEL.exe')
		GroupAdd('CtrlV', 'ahk_exe VISIO.exe')
		GroupAdd('CtrlV', 'ahk_exe OUTLOOK.exe') ;? maybe?

		if (!IsSet(input)){
			input := this
		}

		; Handle backup and clear first
		if (isClipReverted){
			prevClip := this.BackupAndClear()
		}
		input._IsRTFContent()
		; Process input based on type
		if (this._IsRTFContent(input)) {
			; verifiedRTF := FormatConverter.IsRTF(input, true)
			; infos(verifiedRTF)
			; this._SetClipboardRTF(verifiedRTF endChar)
			this._SetClipboardRTF(input endChar)
		}
		else {
			; Regular content handling
			A_Clipboard := input endChar
			; this.Wait()
		}
		; Wait for clipboard and send
		; Sleep(A_Delay)

		Send(keys.paste)
		Sleep(A_Delay)
		readyToRestore := true
		; If WinActive('ahk_group CtrlV') {
		; 	; Send('{sc1D Down}{sc2F}{sc1D Up}')          ;! {Control}{v}
		; 	Send(keys.paste)
		; 	Sleep(A_Delay)
		; 	readyToRestore := true
		; }
		; else {
		; 	; Send('{sc2A Down}{sc152}{sc2A Up}')         ;! {Shift}{Insert}
		; 	Send(keys.shiftinsert)
		; 	Sleep(A_Delay)
		; 	readyToRestore := true°
		; }
		
		Sleep(A_Delay)

		; Restore clipboard if needed
		if (isClipReverted && readyToRestore) {
			this.Clear()
			A_Clipboard := prevClip
			this.Wait()
		}

		return input
	}

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
		if !IsSet(fmt) || !fmt {
			throw ValueError("Format identifier required", -1)
		}
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
		if !IsSet(fmt) || !fmt {
			throw ValueError("Format identifier required", -1)
		}
		this.Open()
		try {
			local hData := DllCall("User32.dll\GetClipboardData", "UInt", fmt, "Ptr")
			if !hData {
				return ""
			}
			local pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "Ptr")
			if !pData {
				return ""
			}
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
	 * @method Backup
	 * @description {helper method} Backup the entire clipboard using ClipboardAll().
	 * @returns {ClipboardAll} Clipboard backup object from BackupAll()
	 * @example
	 *   backup := Clipboard.BackupAll()
	 */
	static Backup(&cBak?) {
		return this.BackupAll(&cBak?)
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
		if !IsSet(clipBackup){
			throw ValueError("ClipboardAll backup required", -1)
		}
		A_Clipboard := clipBackup
		return true
	}

	/**
	 * @method Restore()
	 * @description Restores the clipboard from a backup.
	 * @param {ClipboardAll} clipBackup The backup object to restore.
	 * @returns {Boolean} True if restored.
	 * @throws {ValueError} If backup is not provided.
	 * @example
	 *   Clipboard.Restore(backup)
	 */
	static Restore(clipBackup) {
		return this.RestoreAll(clipBackup)
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
		format := this.RegisterFormat.RTF
		return this.GetContent(format)
	}

	/**
	 * @description Gets HTML content from the clipboard.
	 * @returns {String} HTML clipboard content or empty string.
	 */
	static GetHTML() {
		format := this.RegisterFormat.HTML
		return this.GetContent(format)
	}

	/**
	 * @description Gets CSV content from the clipboard.
	 * @returns {String} CSV clipboard content or empty string.
	 */
	static GetCSV() {
		format := this.RegisterFormat.CSV
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
	;@region class Get
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
			}
			finally {
				Clipboard.Close()
			}
		}
	}
	; ---------------------------------------------------------------------------
	;@endregion class Get
	; ---------------------------------------------------------------------------

	; For backward compatibility, keep static methods on Clipboard itself
	/**
	 * @description Sets clipboard content with specified format.
	 * @param {String} content Content to set in the clipboard.
	 * @param {Integer} format Clipboard format identifier.
	 * @throws {OSError} If clipboard operations fail.
	 */
	static SetContent(content, format) => Clipboard.Set.Content(content, format)

	;@region class Set
	/**
	 * @class Clipboard.Set
	 * @description Provides methods to set clipboard content in various formats and raw format.
	 * @version 1.1.0
	 * @author OvercastBTC
	 * @date 2025-06-11
	 * @requires AutoHotkey v2.0+
	 */
	class Set {
		/**
		 * @description Sets clipboard content with specified format using proper error handling
		 * @param {String} content Content to set in the clipboard
		 * @param {Integer} format Clipboard format identifier
		 * @throws {OSError} If clipboard operations fail
		 * @returns {Boolean} True if successful
		 */
		static Content(content, format) {
			if (!IsString(content)) {
				throw TypeError("Content must be a string", -1)
			}
			
			if (!IsInteger(format) || format <= 0) {
				throw ValueError("Format must be a positive integer", -1)
			}

			; Ensure clipboard is closed first
			try {
				Clipboard.Close()
			} catch {
				; Ignore if already closed
			}

			; Wait for clipboard to be available
			if (!Clipboard.Wait(1000)) {
				throw OSError("Clipboard is busy and cannot be accessed", -1)
			}

			; Open with retry logic
			if (!Clipboard.Open(5, 100)) {
				throw OSError("Failed to open clipboard for writing", -1)
			}

			try {
				; Clear existing content
				Clipboard.Clear()
				
				; Allocate and set content
				size := StrPut(content, "UTF-8")
				hGlobal := DllCall('Kernel32.dll\GlobalAlloc', 'UInt', 0x42, 'UPtr', size, 'Ptr')
				
				if (!hGlobal) {
					throw OSError('Failed to allocate memory for clipboard', -1)
				}

				try {
					pGlobal := DllCall('Kernel32.dll\GlobalLock', 'Ptr', hGlobal, 'Ptr')
					if (!pGlobal) {
						throw OSError('Failed to lock memory for clipboard', -1)
					}

					StrPut(content, pGlobal, "UTF-8")
					DllCall('Kernel32.dll\GlobalUnlock', 'Ptr', hGlobal)

					if (!DllCall('User32.dll\SetClipboardData', 'UInt', format, 'Ptr', hGlobal)) {
						throw OSError('Failed to set clipboard data', -1)
					}

					hGlobal := 0 ; Ownership transferred to system
					return true

				} catch as err {
					if (hGlobal) {
						DllCall('Kernel32.dll\GlobalFree', 'Ptr', hGlobal)
					}
					throw err
				}

			} finally {
				Clipboard.Close()
			}
		}

		/**
		 * @description Sets RTF content to the clipboard with enhanced error handling
		 * @param {String} rtfText RTF formatted text
		 * @param {String} endChar Optional character(s) to append
		 * @throws {OSError} If clipboard operations fail
		 * @throws {TypeError} If rtfText is not a string
		 * @returns {Boolean} True if successful
		 */
		static RTF(rtfText, endChar := '') {
			; Validate input
			if (!IsString(rtfText)) {
				throw TypeError("RTF text must be a string", -1)
			}

			if (!IsString(endChar)) {
				throw TypeError("End character must be a string", -1)
			}

			; Validate RTF content
			if (!Clipboard._IsRTFContent(rtfText)) {
				throw ValueError("Invalid RTF content provided", -1)
			}

			; Get RTF format identifier
			static rtfFormat := 0
			if (!rtfFormat) {
				rtfFormat := Clipboard.RegisterFormat.RTF
				if (!rtfFormat) {
					throw OSError("Failed to register RTF clipboard format", -1)
				}
			}

			; Prepare content
			finalContent := rtfText . endChar

			; Set content using the robust Content method
			try {
				return this.Content(finalContent, rtfFormat)
			} catch as err {
				throw OSError("Failed to set RTF content: " . err.Message, -1)
			}
		}

		/**
		 * @description Sets plain text to the clipboard with error handling
		 * @param {String} text Plain text
		 * @throws {OSError} If clipboard operations fail
		 * @throws {TypeError} If text is not a string
		 * @returns {Boolean} True if successful
		 */
		static Plain(text) {
			if (!IsString(text)) {
				throw TypeError("Text must be a string", -1)
			}

			static CF_TEXT := 1
			return this.Content(text, CF_TEXT)
		}

		/**
		 * @description Sets Unicode text to the clipboard with enhanced handling
		 * @param {String} text Unicode text
		 * @throws {OSError} If clipboard operations fail
		 * @throws {TypeError} If text is not a string
		 * @returns {Boolean} True if successful
		 */
		static Unicode(text) {
			if (!IsString(text)) {
				throw TypeError("Text must be a string", -1)
			}

			static CF_UNICODETEXT := 13

			; Ensure clipboard is available
			try {
				Clipboard.Close()
			} catch {
				; Ignore if already closed
			}

			if (!Clipboard.Wait(1000)) {
				throw OSError("Clipboard is busy and cannot be accessed", -1)
			}

			if (!Clipboard.Open(5, 100)) {
				throw OSError("Failed to open clipboard for Unicode text", -1)
			}

			try {
				Clipboard.Clear()
				
				; Calculate size for UTF-16
				size := StrPut(text, "UTF-16")
				hGlobal := DllCall('Kernel32.dll\GlobalAlloc', 'UInt', 0x42, 'UPtr', size * 2, 'Ptr')
				
				if (!hGlobal) {
					throw OSError('Failed to allocate memory for Unicode text', -1)
				}

				try {
					pGlobal := DllCall('Kernel32.dll\GlobalLock', 'Ptr', hGlobal, 'Ptr')
					if (!pGlobal) {
						throw OSError('Failed to lock memory for Unicode text', -1)
					}

					StrPut(text, pGlobal, "UTF-16")
					DllCall('Kernel32.dll\GlobalUnlock', 'Ptr', hGlobal)

					if (!DllCall('User32.dll\SetClipboardData', 'UInt', CF_UNICODETEXT, 'Ptr', hGlobal)) {
						throw OSError('Failed to set Unicode clipboard data', -1)
					}

					hGlobal := 0 ; Ownership transferred
					return true

				} catch as err {
					if (hGlobal) {
						DllCall('Kernel32.dll\GlobalFree', 'Ptr', hGlobal)
					}
					throw err
				}

			} finally {
				Clipboard.Close()
			}
		}

		/**
		 * @description Sets HTML content to the clipboard
		 * @param {String} htmlText HTML formatted text
		 * @throws {OSError} If clipboard operations fail
		 * @throws {TypeError} If htmlText is not a string
		 * @returns {Boolean} True if successful
		 */
		static HTML(htmlText) {
			if (!IsString(htmlText)) {
				throw TypeError("HTML text must be a string", -1)
			}

			static htmlFormat := 0
			if (!htmlFormat) {
				htmlFormat := Clipboard.RegisterFormat.HTML
				if (!htmlFormat) {
					throw OSError("Failed to register HTML clipboard format", -1)
				}
			}

			return this.Content(htmlText, htmlFormat)
		}

		/**
		 * @description Sets CSV content to the clipboard
		 * @param {String} csvText CSV formatted text
		 * @throws {OSError} If clipboard operations fail
		 * @throws {TypeError} If csvText is not a string
		 * @returns {Boolean} True if successful
		 */
		static CSV(csvText) {
			if (!IsString(csvText)) {
				throw TypeError("CSV text must be a string", -1)
			}

			static csvFormat := 0
			if (!csvFormat) {
				csvFormat := Clipboard.RegisterFormat.CSV
				if (!csvFormat) {
					throw OSError("Failed to register CSV clipboard format", -1)
				}
			}

			return this.Content(csvText, csvFormat)
		}
	}
	; ---------------------------------------------------------------------------
	;@endregion class Set
	; ---------------------------------------------------------------------------

	;@region RegisterFormat
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
	;@endregion RegisterFormat
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	;@region Logging
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
	; @endregion Logging
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
	; ---------------------------------------------------------------------------
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

