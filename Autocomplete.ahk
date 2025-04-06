/************************************************************************
	* @description
	* @file AutoComplete.v2.ahk
	* @author
	* @date 2024/08/19
	* @version 0.0.0
	* @resource https://github.com/Pulover/CbAutoComplete
	* @changes Updated to AutoHotkey v2 (2.0.11)
	* @author Pulover (origional)
	* @resource https://github.com/Pulover/CbAutoComplete
	* @author Ark565 (& others) (v2-beta)
	* @resource https://www.reddit.com/r/AutoHotkey/s/4InT1j8Mro
	* @author OvercastBTC (updates to v2 [2.0.11])
	***********************************************************************/
; ---------------------------------------------------------------------------
/** @region AutoComplete() */
; ---------------------------------------------------------------------------
; AutoComplete(CtlObj, ListObj, GuiObj?) {
; 	static CB_GETEDITSEL := 320, CB_SETEDITSEL := 322, valueFound := false
; 	local Start :=0, End := 0,

; 	cText := CtlObj.Text

; 	currContent := CtlObj.Text

; 	CtlObj.Value := currContent
; 	; QSGui['your name'].Value := currContent
; 	; QSGui.Add('Text','Section','Text')
; 	; QSGui.Show("AutoSize")
; 	; QSGui.Show()
; 	; if ((GetKeyState("Delete", "P")) || (GetKeyState("Backspace", "P"))){
; 	if ((GetKeyState('Delete')) || (GetKeyState('Backspace'))){
; 		return
; 	}

; 	valueFound := false
; 	; ---------------------------------------------------------------------------
; 	/** @i for index, value in entries */
; 	; ---------------------------------------------------------------------------
; 	/** @i Check if the current value matches the target value */
; 	; ---------------------------------------------------------------------------
; 	for index, value in ListObj {
; 		; ---------------------------------------------------------------------------
; 	/** @i Exit the loop if the value is found */
; 		; ---------------------------------------------------------------------------
; 		if (value = currContent) {
; 			valueFound := true
; 			break
; 		}
; 	}
; 	; ---------------------------------------------------------------------------
; 	/** @i Exit Nested request */
; 	; ---------------------------------------------------------------------------
; 	if (valueFound){
; 		return
; 	}
; 	; ---------------------------------------------------------------------------
; 	/** @i Start := 0, End :=0 */
; 	; ---------------------------------------------------------------------------
; 	MakeShort(0, &Start, &End)
; 	try {
; 		if (ControlChooseString(cText, CtlObj) > 0) {
; 			Start := StrLen(currContent)
; 			End := StrLen(CtlObj.Text)
; 			PostMessage(CB_SETEDITSEL, 0, MakeLong(Start, End),,CtlObj.Hwnd)
; 		}
; 	} Catch as e {
; 		ControlSetText(currContent, CtlObj)
; 		ControlSetText(cText, CtlObj)
; 		PostMessage(CB_SETEDITSEL, 0, MakeLong(StrLen(cText), StrLen(cText)),,CtlObj.Hwnd)
; 	}

; 	MakeShort(Long, &LoWord, &HiWord) => (LoWord := Long & 0xffff, HiWord := Long >> 16)

; 	MakeLong(LoWord, HiWord) {
; 		return (HiWord << 16) | (LoWord & 0xffff)
; 	}
; }

; #HotIf WinActive(A_ScriptName)
; #5::testAutoComplete()

; testAutoComplete() {
; ; SetCapsLockState("Off")
; acInfos := Infos('AutoComplete enabled'
; 				'Press "Shift+{Enter}",to activate'
; 			)
; ; acInfos := Infos('Press "ctrl + a" to activate, or press "Shift+Enter"')
; ; Hotkey(" ", (*) => createGUI())
; ; Hotkey("^a", (*) => createGUI())
; Hotkey('+Enter', (*) => createGUI() )
; ; createGUI()
; createGUI() {
; 	initQuery := "Recommendation Library"
; 	initQuery := ""
; 	; global entriesList := ["Red", "Green", "Blue"]
; 	mList := []
; 	; mlist := understanding_the_risk
; 	mlist := Links_AhkLib
; 	; Infos(mlist)
; 	; entriesList := [mlist]
; 	; entries := []
; 	entries := ''
; 	entriesList := []
; 	m:=''
; 	for each, m in mList {
; 		entriesList.SafePush(m)
; 	}
; 	e:=''
; 	for each, e in entriesList {
; 		; entriesList := ''
; 		; entries := ''
; 		; entriesList .= value '`n'
; 		entries .= e '`n'
; 	}

; 	global QSGui, initQuery, entriesList
; 	global width := Round(A_ScreenWidth / 4)
; 	QSGui := Gui("AlwaysOnTop +Resize +ToolWindow Caption", "Recommendation Picker")
; 	QSGui.SetColor := 0x161821
; 	QSGui.BackColor := 0x161821
; 	QSGui.SetFont( "s10 q5", "Fira Code")
; 	; QSCB := QSGui.AddComboBox("vQSEdit w200", entriesList)
; 	QSCB := QSGui.AddComboBox("vQSEdit w" width ' h200' ' Wrap', entriesList)
; 	qEdit := QSGui.AddEdit('vqEdit w' width ' h200')
; 	; qEdit.OnEvent('Change', (*) => updateEdit(QSCB, entriesList))
; 	QSGui_Change(QSCB) => qEdit.OnEvent('Change',qEdit)
; 	QSGui.Add('Text','Section')
; 	QSGui.Opt('+Owner ' QSGui.Hwnd)
; 	; QSCB := QSGui.AddComboBox("vQSEdit w" width ' h200', entriesList)
; 	QSCB.Text := initQuery
; 	QSCB.OnEvent("Change", (*) => AutoComplete(QSCB, entriesList))
; 	; QSCB.OnEvent('Change', (*) => updateEdit(QSCB, entriesList))
; 	QSBtn := QSGui.AddButton("default hidden yp hp w0", "OK")
; 	QSBtn.OnEvent("Click", (*) => processInput())
; 	QSGui.OnEvent("Close", (*) => QSGui.Destroy())
; 	QSGui.OnEvent("Escape", (*) => QSGui.Destroy())
; 	; QSGui.Show( "w222")
; 	; QSGui.Show("w" width ' h200')
; 	QSGui.Show( "AutoSize")
; }

; processInput() {
; 	QSSubmit := QSGui.Submit()    ; Save the contents of named controls into an object.
; 	if QSSubmit.QSEdit {
; 		; MsgBox(QSSubmit.QSEdit, "Debug GUI")
; 		initQuery := QSSubmit.QSEdit
; 		Infos.DestroyAll()
; 		Sleep(100)
; 		updated_Infos := Infos(QSSubmit.QSEdit)

; 	}
; 	QSGui.Destroy()
; 	WinWaitClose(updated_Infos.hwnd)
; 	Run(A_ScriptName)
; }
; }

/**
 * Enhanced AutoComplete class with flexible input and control support
 */
class AutoComplete {

	#Requires AutoHotkey v2+

	static __New() {
		this.CB_GETEDITSEL := 320
		this.CB_SETEDITSEL := 322
		this.MatchLimit := 5  ; Maximum matches to show
		this.MinCharacters := 2  ; Minimum characters before showing matches
	}
	
	/**
	 * Process various input types into a consistent format
	 * @param {Any} input The input to process
	 * @returns {Array} Processed array of items
	 */
	static ProcessInput(input) {
		result := []
		
		switch Type(input) {
			case "String":
				; Handle string input
				if InStr(input, "`n")
					result := StrSplit(input, "`n", "`r")
				else if InStr(input, "|")
					result := StrSplit(input, "|")
				else
					result := [input]
			
			case "Array":
				; Already in desired format
				result := input
			
			case "Map":
				; Convert both keys and values
				for key, value in input {
					if IsObject(value)
						result.Push(key)
					else {
						result.Push(key)
						result.Push(value)
					}
				}
			
			case "Object":
				; Convert object properties
				for prop in input.OwnProps()
					result.Push(prop)
			
			default:
				if HasMethod(input, "__Enum")
					for item in input
						result.Push(item)
				else
					throw ValueError("Unsupported input type")
		}
		
		return result
	}
	
	/**
	 * Handle autocomplete for various control types
	 * @param {Gui.Control} CtlObj The control to enhance
	 * @param {Any} ListObj The source data
	 * @param {Object} Options Additional options
	 */
	static Enhance(CtlObj, ListObj, Options := {}) {
		; Process options
		options := {
			ShowMatches: Options.HasProp("ShowMatches") ? Options.ShowMatches : true,
			MatchDisplay: Options.HasProp("MatchDisplay") ? Options.MatchDisplay : "Stacked",
			MaxMatches: Options.HasProp("MaxMatches") ? Options.MaxMatches : this.MatchLimit,
			MinChars: Options.HasProp("MinChars") ? Options.MinChars : this.MinCharacters
		}
		
		; Process input data
		items := this.ProcessInput(ListObj)
		
		; Set up event handling based on control type
		switch CtlObj.Type {
			case "Edit", "ComboBox":
				this.EnhanceEditControl(CtlObj, items, options)
			
			case "ListBox":
				this.EnhanceListControl(CtlObj, items, options)
			
			case "ListView":
				this.EnhanceListViewControl(CtlObj, items, options)
			
			default:
				throw ValueError("Unsupported control type")
		}
	}
	
	/**
	 * Handle Edit/ComboBox autocomplete
	 */
	static EnhanceEditControl(CtlObj, items, options) {
		; Store data with the control
		CtlObj.AutoCompleteData := items
		CtlObj.AutoCompleteOptions := options
		
		; Set up change handler
		CtlObj.OnEvent("Change", this.HandleEditChange.Bind(this))
		
		; Set up ^Enter handler for showing matches
		if (options.ShowMatches) {
			HotIfWinActive("ahk_id " CtlObj.Gui.Hwnd)
			Hotkey("^Enter", (*) => this.ShowMatches(CtlObj))
		}
	}
	
	/**
	 * Handle text change events
	 */
	static HandleEditChange(CtlObj, *) {
		; Get current text
		currContent := CtlObj.Text
		if (StrLen(currContent) < CtlObj.AutoCompleteOptions.MinChars)
			return
			
		; Don't process backspace/delete
		if (GetKeyState("Backspace") || GetKeyState("Delete"))
			return
			
		; Find best match
		bestMatch := ""
		for item in CtlObj.AutoCompleteData {
			if (InStr(item, currContent) == 1) {
				bestMatch := item
				break
			}
		}
		
		; Apply match if found
		if (bestMatch && CtlObj.Type = "ComboBox") {
			try {
				if (ControlChooseString(bestMatch, CtlObj) > 0) {
					start := StrLen(currContent)
					end := StrLen(bestMatch)
					PostMessage(this.CB_SETEDITSEL, 0, (end << 16) | (start & 0xffff),, CtlObj.Hwnd)
				}
			}
		} else if (bestMatch && CtlObj.Type = "Edit") {
			CtlObj.Text := bestMatch
			CtlObj.Gui.Focus
			SendMessage(0xB1, StrLen(currContent), -1,, CtlObj.Hwnd)
		}
	}
	
	/**
	 * Show multiple matches in specified display mode
	 */
	static ShowMatches(CtlObj) {
		currContent := CtlObj.Text
		if (StrLen(currContent) < CtlObj.AutoCompleteOptions.MinChars)
			return
			
		; Find matches
		matches := []
		for item in CtlObj.AutoCompleteData {
			if (InStr(item, currContent) == 1)
				matches.Push(item)
			if (matches.Length >= CtlObj.AutoCompleteOptions.MaxMatches)
				break
		}
		
		if (!matches.Length)
			return
			
		; Show matches based on display mode
		switch CtlObj.AutoCompleteOptions.MatchDisplay {
			case "Stacked":
				this.ShowStackedMatches(CtlObj, matches)
			case "ListView":
				this.ShowListViewMatches(CtlObj, matches)
			case "Inline":
				this.ShowInlineMatches(CtlObj, matches)
		}
	}
	
	/**
	 * Show matches in stacked Infos-style display
	 */
	static ShowStackedMatches(CtlObj, matches) {
		for index, match in matches {
			Infos(match)
		}
	}
	
	/**
	 * Show matches in a temporary ListView
	 */
	static ShowListViewMatches(CtlObj, matches) {
		; Create temporary GUI
		matchGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
		lv := matchGui.AddListView("w200 h150", ["Matches"])
		
		; Add matches
		for match in matches
			lv.Add(, match)
			
		; Position below control
		CtlObj.GetPos(&x, &y, &w, &h)
		matchGui.Show("x" x " y" (y + h))
		
		; Setup selection handler
		lv.OnEvent("DoubleClick", (*) => (
			CtlObj.Text := lv.GetText(lv.GetNext()),
			matchGui.Destroy()
		))
		
		; Auto-close
		SetTimer(() => matchGui.Destroy(), -3000)
	}

	/**
	 * Handle ListBox autocomplete
	 */
	static EnhanceListControl(CtlObj, items, options) {
		; Store data with the control
		CtlObj.AutoCompleteData := items
		CtlObj.AutoCompleteOptions := options
		
		; Add items to ListBox
		for item in items {
			CtlObj.Add([item])
		}
		
		; Set up search-as-you-type handling
		CtlObj.OnEvent("Change", (*) => this.HandleListChange(CtlObj))
	}

	/**
	 * Handle ListView autocomplete
	 */
	static EnhanceListViewControl(CtlObj, items, options) {
		; Store data with the control
		CtlObj.AutoCompleteData := items
		CtlObj.AutoCompleteOptions := options
		
		; Add items to ListView
		for item in items {
			CtlObj.Add(, item)
		}
		
		; Set up search-as-you-type handling
		CtlObj.OnEvent("Change", (*) => this.HandleListViewChange(CtlObj))
	}

	/**
	 * Handle ListBox changes
	 */
	static HandleListChange(CtlObj) {
		; Implementation depends on specific needs
		; This is a basic example
		currentText := CtlObj.Text
		if (currentText) {
			loop CtlObj.GetCount() {
				if (InStr(CtlObj.GetText(A_Index), currentText) == 1) {
					CtlObj.Choose(A_Index)
					break
				}
			}
		}
	}

	/**
	 * Handle ListView changes
	 */
	static HandleListViewChange(CtlObj) {
		; Implementation depends on specific needs
		; This is a basic example
		currentText := CtlObj.GetText(CtlObj.GetNext())
		if (currentText) {
			loop CtlObj.GetCount() {
				if (InStr(CtlObj.GetText(A_Index), currentText) == 1) {
					CtlObj.Modify(A_Index, "Select Focus")
					break
				}
			}
		}
	}

	/**
	 * Show matches inline below the control
	 */
	static ShowInlineMatches(CtlObj, matches) {
		; Get control position
		CtlObj.GetPos(&x, &y, &w, &h)
		
		; Create temporary info box for matches
		matchText := ""
		for match in matches {
			matchText .= match "`n"
		}
		
		; Use InfoBox to display matches
		infoBox := InfoBox(matchText, 3000, {
			x: x,
			y: y + h,
			width: w,
			FontSize: 10
		})
		
		; Set up click handling to select match
		infoBox.control.OnEvent("Click", (*) => (
			CtlObj.Text := infoBox.control.Text,
			infoBox.Destroy()
		))
	}
}
