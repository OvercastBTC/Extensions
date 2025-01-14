#Requires AutoHotkey v2+
#Include <Includes\ObjectTypeExtensions>


Gui.Prototype.Base := Gui2

class Gui2 {
	static WS_EX_NOACTIVATE 	:= '0x08000000L'
	static WS_EX_TRANSPARENT 	:= '0x00000020L'
	static WS_EX_COMPOSITED 	:= '0x02000000L'
	static WS_EX_CLIENTEDGE 	:= '0x00000200L'
	static WS_EX_APPWINDOW 		:= '0x00040000L'
	static NOACTIVATE 			:= this.WS_EX_NOACTIVATE
	static TRANSPARENT 			:= this.WS_EX_TRANSPARENT
	static COMPOSITED 			:= this.WS_EX_COMPOSITED
	static CLIENTEDGE 			:= this.WS_EX_CLIENTEDGE
	static APPWINDOW 			:= this.WS_EX_APPWINDOW

	static __New() {
		; Add all Gui2 methods to Gui prototype
		for methodName in Gui2.OwnProps() {
			if methodName != "__New" && HasMethod(Gui2, methodName) {
				; Check if method already exists
				if Gui.Prototype.HasOwnProp(methodName) {
					; Either skip, warn, or override based on your needs
					continue  ; Skip if method exists
					; Or override:
					; Gui.Prototype.DeleteProp(methodName)
				}
				Gui.Prototype.DefineProp(methodName, {
					Call: Gui2.%methodName%
				})
			}
		}
	}

	/**
	 * Add a RichEdit control to a GUI
	 * @param {Gui} guiObj The GUI object to add the control to
	 * @param {String} options Control options string
	 * @param {String} text Initial text content
	 * @returns {RichEdit} The created RichEdit control
	 */
	; static AddRichEdit(guiObj?, options := "", text := "") {
	; 	if !IsSet(guiObj) {
	; 		guiObj := this
	; 	}
	; 	; Default options if none provided
	; 	if (options = "") {
	; 		options := "w400 h300"  ; Default size
	; 	}

	; 	; Create RichEdit control
	; 	reObj := RichEdit(guiObj, options)
		
	; 	; Set initial text if provided
	; 	if (text != "") {
	; 		reObj.SetText(text)
	; 	}
		
	; 	; Configure default settings
	; 	reObj.SetOptions(["SELECTIONBAR"])  ; Enable selection bar
	; 	reObj.AutoURL(true)                 ; Enable URL detection
	; 	reObj.SetEventMask([
	; 		"SELCHANGE",                    ; Selection change events
	; 		"LINK",                         ; Link click events
	; 		"PROTECTED"                     ; Protected text events
	; 	])
		
	; 	return reObj
	; }

	/**
	 * 
	 * @param guiObj 
	 * @param options 
	 * @param text 
	 */
	static AddRichEdit(options := '', text := "", toolbar := true, showScrollBars := false) {
        ; 'this' refers to the Gui instance here
        guiObj := this
        ; Create RichEdit control with default size if none specified
        if !IsSet(options) {
            options := "w400 r10"  ; Default size
        }
		
		; Create RichEdit control
		reObj := RichEdit(this, options)
        ; Calculate positions
		; Set sizing properties
		reObj.WidthP := 1.0   ; Take full width
		reObj.HeightP := 1.0  ; Take full height after toolbar
		reObj.MinWidth := 200
		reObj.MinHeight := 100
		reObj.AnchorIn := true

		; Initialize GuiReSizer for the parent GUI
		guiObj.Init := 2  ; Force initial resize

		; Ensure parent GUI resizes properly
		guiObj.OnEvent("Size", GuiReSizer)
        btnW := 18, btnH := 15, margin := 1
        
        ; If toolbar enabled, add it before the RichEdit
        if (toolbar) {
			toolbarH := btnH + margin*2
			x := margin
			y := margin
			
			; Bold
			boldBtn := guiObj.AddButton(Format("x{1} y{2} w{3} h{4}", x, y, btnW, btnH), "B")
			x += btnW + margin
			
			; Italic
			italicBtn := guiObj.AddButton(Format("x{1} y{2} w{3} h{4}", x, y, btnW, btnH), "I")
			x += btnW + margin
			
			; Underline 
			underBtn := guiObj.AddButton(Format("x{1} y{2} w{3} h{4}", x, y, btnW, btnH), "U")
			x += btnW + margin
			
			; Strikethrough
			strikeBtn := guiObj.AddButton(Format("x{1} y{2} w{3} h{4}", x, y, btnW, btnH), "S")
			
			; Position RichEdit below toolbar
			options := "x" margin " y" (y + btnH + margin) " " options
        }

        ; ; Create RichEdit control with default size if none specified
        ; if !IsSet(options) {
        ;     options := "w400 r10"  ; Default size
        ; }
		
		; ; Create RichEdit control
		; reObj := RichEdit(this, options)
		reObj.SetFont({Name: "Times New Roman", Size: 11})
		; Add GuiReSizer properties after creating RichEdit
		reObj.GetPos(&xPos, &yPos, &wGui, &hGui)

		; Add resizing properties for GUI
		if (toolbar) {
			; Account for toolbar space if present
			reObj.X := margin
			reObj.Y := btnH + margin*2
		} else {
			reObj.X := margin
			reObj.Y := margin
		}
		
		; Configure scrollbar visibility
		if (!showScrollBars) {
			reObj.SetOptions([
				"SELECTIONBAR",
				; "MULTILEVEL",
				"AUTOWORDSEL",
				; "-HSCROLL",  ; Disable horizontal scrollbar
				; "-VSCROLL"   ; Disable vertical scrollbar
				; "-AUTOVSCROLL",  ; Show vertical scrollbar when needed
				; "-AUTOHSCROLL"   ; Show horizontal scrollbar when needed
			])
		} else {
			reObj.SetOptions([
				"SELECTIONBAR",
				"MULTILEVEL",
				"AUTOWORDSEL",
				"AUTOVSCROLL",  ; Show vertical scrollbar when needed
				"AUTOHSCROLL"   ; Show horizontal scrollbar when needed
			])
		}
		
		; Enable features
		reObj.AutoURL(true)                 ; Enable URL detection
		reObj.SetEventMask([
			"SELCHANGE",                    ; Selection change events
			"LINK",                         ; Link click events
			"PROTECTED",                    ; Protected text events
			"CHANGE"                        ; Text change events
		])
	
		; Add GuiReSizer properties for automatic sizing
		reObj.WidthP := 1.0      ; Take up full width
		reObj.HeightP := 1.0     ; Take up full height
		reObj.MinWidth := 200    ; Minimum dimensions
		reObj.MinHeight := 100
		reObj.AnchorIn := true   ; Stay within parent bounds
	
		; Add basic keyboard shortcuts
		HotIfWinactive("ahk_id " reObj.Hwnd)
		Hotkey("^b", (*) => reObj.ToggleFontStyle("B"))
		Hotkey("^i", (*) => reObj.ToggleFontStyle("I"))
		Hotkey("^u", (*) => reObj.ToggleFontStyle("U"))
		Hotkey("^+s", (*) => reObj.ToggleFontStyle("S"))
		Hotkey("^z", (*) => reObj.Undo())
		Hotkey("^y", (*) => reObj.Redo())
		HotIf()
	
		; Set initial text if provided
		if IsSet(text) {
			reObj.SetText(text)
		}
		
		; Define button callbacks
		BoldText(*) {
			reObj.ToggleFontStyle("B")
			reObj.Focus()
		}
		
		ItalicText(*) {
			reObj.ToggleFontStyle("I")
			reObj.Focus()
		}
		
		UnderlineText(*) {
			reObj.ToggleFontStyle("U")
			reObj.Focus()
		}
		
		StrikeText(*) {
			reObj.ToggleFontStyle("S")
			reObj.Focus()
		}

		return reObj
	}
	
	/**
	 * Extension method for Gui class
	 * @param {String} options Control options
	 * @param {String} text Initial text
	 * @returns {RichEdit} The created RichEdit control
	 */
	static AddRTE(options := "", text := "") {
		return this.AddRichEdit(this, options, text)
	}

	; static AddRichTextEdit(options := "", text := ""){
	; 	return this.AddRichEdit(this, options, text)
	; }
	/**
	 * Extension method for Gui class
	 * @param {String} options Control options
	 * @param {String} text Initial text
	 * @returns {RichEdit} The created RichEdit control
	 */
	static AddRichTextEdit(options := "", text := "") => this.AddRichEdit(this, options, text)
	/**
	 * Extension method for Gui class
	 * @param {String} options Control options
	 * @param {String} text Initial text
	 * @returns {RichEdit} The created RichEdit control
	 */
	static AddRichText(options := "", text := "") => this.AddRichEdit(this, options, text)

	static SetDefaultFont(guiObj := this, fontObj := '') {
		if (guiObj is Gui) {

			if (IsObject(fontObj)) {
				; Use the provided font object
				size := fontObj.HasProp('Size') ? 's' . fontObj.Size : 's9'
				weight := fontObj.HasProp('Weight') ? ' w' . fontObj.Weight : ''
				italic := fontObj.HasProp('Italic') && fontObj.Italic ? ' Italic' : ''
				underline := fontObj.HasProp('Underline') && fontObj.Underline ? ' Underline' : ''
				strikeout := fontObj.HasProp('Strikeout') && fontObj.Strikeout ? ' Strike' : ''
				name := fontObj.HasProp('Name') ? fontObj.Name : 'Segoe UI'

				options := size . weight . italic . underline . strikeout
				guiObj.SetFont(options, name)
			} else if !guiObj.HasProp('Font') {
				; Use default settings if no font object is provided
				guiObj.SetFont('s9', 'Segoe UI')
			}
		}
		return this
	}

	static DarkMode(guiObj := this, BackgroundColor := '') {
		if (guiObj is Gui) {
			if (BackgroundColor = '') {
				guiObj.BackColor := '0xA2AAAD'
			} else {
				guiObj.BackColor := BackgroundColor
			}
		}
		return this
	}

	static MakeFontNicer(guiObj := this, options := '20 Q5', nFont := 'Consolas') {
		try RegExReplace(options, 's([\d\s]+)', '$1')
		if (guiObj is Gui) {
			guiObj.SetFont('s' options, nFont)
		}
		return this
	}

	; static NeverFocusWindow(guiObj := this) {
	static NeverFocusWindow() {
		; guiObj := guiObj ? guiObj : this
		; WinSetExStyle('+' this.NOACTIVATE, guiObj)
		WinSetExStyle('+' this.NOACTIVATE, this)
		; WinSetExStyle('+' . this.TRANSPARENT, guiObj)
		; WinSetExStyle('+' . this.COMPOSITED, guiObj)
		; WinSetExStyle('+' . this.CLIENTEDGE, guiObj)
		; WinSetExStyle('+' . this.APPWINDOW, guiObj)
		; return guiObj
		return this
	}

	static MakeClickThrough(guiObj := this) {
		if (guiObj is Gui){
			; WinSetTransparent(255, guiObj)
			WinSetTransparent(255, this)
			guiObj.Opt('+E0x20')
		}
		return this
	}

	static SetButtonWidth(input, bMargin := 1.5) {
		return GuiButtonProperties.SetButtonWidth(input, bMargin)
	}

	static SetButtonHeight(rows := 1, vMargin := 1.2) {
		return GuiButtonProperties.SetButtonHeight(rows, vMargin)
	}

	static GetButtonDimensions(text, options := {}) {
		return GuiButtonProperties.GetButtonDimensions(text, options)
	}

	static GetOptimalButtonLayout(totalButtons, containerWidth, containerHeight) {
		return GuiButtonProperties.GetOptimalButtonLayout(totalButtons, containerWidth, containerHeight)
	}

	static AddButtonGroup(guiObj, buttonOptions, labelObj, groupOptions := '', columns := 1) {
		buttons := Map()
		
		if (Type(labelObj) = 'String') {
			labelObj := StrSplit(labelObj, '|')
		}
		
		if (Type(labelObj) = 'Array' or Type(labelObj) = 'Map' or Type(labelObj) = 'Object') {
			totalButtons := labelObj.Length
			rows := Ceil(totalButtons / columns)
			
			; Parse groupOptions
			groupPos := '', groupSize := ''
			if (groupOptions != '') {
				RegExMatch(groupOptions, 'i)x\s*(\d+)', &xMatch)
				RegExMatch(groupOptions, 'i)y\s*(\d+)', &yMatch)
				RegExMatch(groupOptions, 'i)w\s*(\d+)', &wMatch)
				RegExMatch(groupOptions, 'i)h\s*(\d+)', &hMatch)
				
				groupPos := (xMatch ? 'x' . xMatch[1] : '') . ' ' . (yMatch ? 'y' . yMatch[1] : '')
				groupSize := (wMatch ? 'w' . wMatch[1] : '') . ' ' . (hMatch ? 'h' . hMatch[1] : '')
			}
			
			groupBox := guiObj.AddGroupBox(groupPos . ' ' . groupSize, 'Button Group')
			groupBox.GetPos(&groupX, &groupY, &groupW, &groupH)
			
			btnWidth := Gui2.SetButtonWidth(labelObj)
			btnHeight := Gui2.SetButtonHeight()
			
			xMargin := 10
			yMargin := 25
			xSpacing := 10
			ySpacing := 5
			
			for index, label in labelObj {
				col := Mod(A_Index - 1, columns)
				row := Floor((A_Index - 1) / columns)
				
				xPos := groupX + xMargin + (col * (btnWidth + xSpacing))
				yPos := groupY + yMargin + (row * (btnHeight + ySpacing))
				
				btnOptions := StrReplace(buttonOptions, 'xm', 'x' . xPos)
				btnOptions := StrReplace(btnOptions, 'ym', 'y' . yPos)
				btnOptions := 'x' . xPos . ' y' . yPos . ' w' . btnWidth . ' h' . btnHeight . ' ' . btnOptions
				
				btn := guiObj.AddButton(btnOptions, label)
				buttons[label] := btn
			}
			
			; Only resize the group box if buttons were actually added
			if (buttons.Count > 0) {
				lastButton := buttons[labelObj[labelObj.Length]]
				lastButton.GetPos(&lastX, &lastY, &lastW, &lastH)
				newGroupW := lastX + lastW + xMargin - groupX
				newGroupH := lastY + lastH + yMargin - groupY
				groupBox.Move(,, newGroupW, newGroupH)
			}
		}
		
		return buttons
	}
	

	static OriginalPositions := Map()

	static AddCustomizationOptions(GuiObj) {
		; Get position for the new group box
		GuiObj.groupBox.GetPos(&gX, &gY, &gW, &gH)
		
		; Add a new group box for customization options
		GuiObj.AddGroupBox("x" gX " y" (gY + gH + 10) " w" gW " h100", "GUI Customization")
		
		; Add checkboxes for enabling customization and saving settings
		GuiObj.AddCheckbox("x" (gX + 10) " y+10 vEnableCustomization", "Enable Customization")
			.OnEvent("Click", (*) => this.ToggleCustomization(GuiObj))
		GuiObj.AddCheckbox("x+10 vSaveSettings", "Save Settings")
			.OnEvent("Click", (*) => this.ToggleSaveSettings(GuiObj))
		
		; Add button for adjusting positions
		GuiObj.AddButton("x" (gX + 10) " y+10 w100 vAdjustPositions", "Adjust Positions")
			.OnEvent("Click", (*) => this.ShowAdjustPositionsGUI(GuiObj))
		
		; Add text size control
		GuiObj.AddText("x+10 y+-15", "Text Size:")
		GuiObj.AddEdit("x+5 w30 vTextSize", "14")
			.OnEvent("Change", (*) => this.UpdateTextSize(GuiObj))

		; Add custom hotkey option
		GuiObj.AddText("x" (gX + 10) " y+10", "Custom Hotkey:")
		GuiObj.AddHotkey("x+5 w100 vCustomHotkey")
			.OnEvent("Change", (*) => this.UpdateCustomHotkey(GuiObj))

		; Store original positions
		this.StoreOriginalPositions(GuiObj)

		; Add methods to GuiObj
		GuiObj.DefineProp("ApplySettings", {Call: (self, settings) => this.ApplySettings(self, settings)})
		GuiObj.DefineProp("SaveSettings", {Call: (self) => this.SaveSettings(self)})
		GuiObj.DefineProp("LoadSettings", {Call: (self) => this.LoadSettings(self)})
	}

	static StoreOriginalPositions(GuiObj) {
		this.OriginalPositions[GuiObj.Hwnd] := Map()
		for ctrl in GuiObj {
			ctrl.GetPos(&x, &y)
			this.OriginalPositions[GuiObj.Hwnd][ctrl.Name] := {x: x, y: y}
		}
	}

	static ToggleCustomization(GuiObj) {
		isEnabled := GuiObj["EnableCustomization"].Value
		GuiObj["AdjustPositions"].Enabled := isEnabled
		GuiObj["TextSize"].Enabled := isEnabled
		GuiObj["CustomHotkey"].Enabled := isEnabled
	}

	static ToggleSaveSettings(GuiObj) {
		if (GuiObj["SaveSettings"].Value) {
			this.SaveSettings(GuiObj)
		}
	}

	static UpdateTextSize(GuiObj) {
		newSize := GuiObj["TextSize"].Value
		if (newSize is integer && newSize > 0) {
			GuiObj.SetFont("s" newSize)
			for ctrl in GuiObj {
				if (ctrl.Type == "Text" || ctrl.Type == "Edit" || ctrl.Type == "Button") {
					ctrl.SetFont("s" newSize)
				}
			}
		}
	}

	static UpdateCustomHotkey(GuiObj) {
		newHotkey := GuiObj["CustomHotkey"].Value
		if (newHotkey) {
			Hotkey(newHotkey, (*) => this.ToggleVisibility(GuiObj))
		}
	}

	static ToggleVisibility(GuiObj) {
		if (GuiObj.Visible) {
			GuiObj.Hide()
		} else {
			GuiObj.Show()
		}
	}

	static ShowAdjustPositionsGUI(GuiObj) {
		adjustGui := Gui("+AlwaysOnTop", "Adjust Control Positions")
		
		for ctrl in GuiObj {
			if (ctrl.Type != "GroupBox") {
				adjustGui.AddText("w150", ctrl.Name)
				adjustGui.AddButton("x+5 w20 h20", "↑").OnEvent("Click", (*) => this.MoveControl(GuiObj, ctrl, 0, -5))
				adjustGui.AddButton("x+5 w20 h20", "↓").OnEvent("Click", (*) => this.MoveControl(GuiObj, ctrl, 0, 5))
				adjustGui.AddButton("x+5 w20 h20", "←").OnEvent("Click", (*) => this.MoveControl(GuiObj, ctrl, -5, 0))
				adjustGui.AddButton("x+5 w20 h20", "→").OnEvent("Click", (*) => this.MoveControl(GuiObj, ctrl, 5, 0))
				adjustGui.AddButton("x+10 w60", "Reset").OnEvent("Click", (*) => this.ResetControlPosition(GuiObj, ctrl))
			}
		}
		
		adjustGui.AddButton("x10 w100", "Save").OnEvent("Click", (*) => (this.SaveSettings(GuiObj), adjustGui.Destroy()))
		adjustGui.Show()
	}

	static MoveControl(GuiObj, ctrl, dx, dy) {
		ctrl.GetPos(&x, &y)
		ctrl.Move(x + dx, y + dy)
	}

	static ResetControlPosition(GuiObj, ctrl) {
		if (this.OriginalPositions.Has(GuiObj.Hwnd) && this.OriginalPositions[GuiObj.Hwnd].Has(ctrl.Name)) {
			originalPos := this.OriginalPositions[GuiObj.Hwnd][ctrl.Name]
			ctrl.Move(originalPos.x, originalPos.y)
		}
	}

	static SaveSettings(GuiObj) {
		settings := Map(
			"GuiSize", {w: GuiObj.Pos.W, h: GuiObj.Pos.H},
			"ControlPositions", this.GetControlPositions(GuiObj),
			"TextSize", GuiObj["TextSize"].Value,
			"CustomHotkey", GuiObj["CustomHotkey"].Value
		)
		FileDelete(A_ScriptDir "\GUISettings.json")
		FileAppend(cJSON.Stringify(settings), A_ScriptDir "\GUISettings.json")
	}

	static LoadSettings(GuiObj) {
		if (FileExist(A_ScriptDir "\GUISettings.json")) {
			settings := cJSON.Load(FileRead(A_ScriptDir "\GUISettings.json"))
			this.ApplySettings(GuiObj, settings)
		}
	}

	static ApplySettings(GuiObj, settings) {
		if (settings.Has("GuiSize")) {
			GuiObj.Move(,, settings.GuiSize.w, settings.GuiSize.h)
		}
		if (settings.Has("ControlPositions")) {
			this.SetControlPositions(GuiObj, settings.ControlPositions)
		}
		if (settings.Has("TextSize")) {
			GuiObj["TextSize"].Value := settings.TextSize
			this.UpdateTextSize(GuiObj)
		}
		if (settings.Has("CustomHotkey")) {
			GuiObj["CustomHotkey"].Value := settings.CustomHotkey
			this.UpdateCustomHotkey(GuiObj)
		}
	}

	static GetControlPositions(GuiObj) {
		positions := Map()
		for ctrl in GuiObj {
			ctrl.GetPos(&x, &y)
			positions[ctrl.Name] := {x: x, y: y}
		}
		return positions
	}

	static SetControlPositions(GuiObj, positions) {
		for ctrlName, pos in positions {
			if (GuiObj.HasProp(ctrlName)) {
				GuiObj[ctrlName].Move(pos.x, pos.y)
			}
		}
	}

	; Static wrapper methods
	static AddCustomizationOptionsToGui(GuiObj?) {
		if !GuiObj {
			guiObj := this
		}
		GuiObj.AddCustomizationOptions()
		return this
	}

	static SaveGuiSettings(GuiObj?) {
		GuiObj.SaveSettings()
		return this
	}

	static LoadGuiSettings(GuiObj?) {
		GuiObj.LoadSettings()
		return this
	}
}

class GuiButtonProperties {
	static SetButtonWidth(input, bMargin := 1) {
		largestLength := 0

		if Type(input) = 'String' {
			return largestLength := StrLen(input)
		} else if Type(input) = 'Array' {
			for value in input {
				currentLength := StrLen(value)
				if (currentLength > largestLength) {
					largestLength := currentLength
				}
			}
		} else if Type(input) = 'Map' || Type(input) = 'Object' {
			for key, value in input {
				currentLength := StrLen(value)
				if (currentLength > largestLength) {
					largestLength := currentLength
				}
			}
		}

		return GuiButtonProperties.CalculateButtonWidth(largestLength, bMargin)
	}

	; Function to set button length based on various input types
	static SetButtonLength(input) {
		largestLength := 0

		if Type(input) = 'String' {
			return StrLen(input)
		} else if Type(input) = 'Array' {
			for value in input {
				currentLength := StrLen(value)
				if (currentLength > largestLength) {
					largestLength := currentLength
				}
			}
		} else if Type(input) = 'Map' || Type(input) = 'Object' {
			for key, value in input {
				currentLength := StrLen(value)
				if (currentLength > largestLength) {
					largestLength := currentLength
				}
			}
		} else if Type(input) = 'String' && (SubStr(input, -4) = '.json' || SubStr(input, -3) = '.ini') {
			; Read from JSON or INI file and process
			; (Implementation depends on file format and structure)
		}

		return largestLength
	}

	static CalculateButtonWidth(textLength, bMargin := 7.5) {
		; Using default values instead of FontProperties
		avgCharWidth := 6  ; Approximate average character width
		fontSize := 9      ; Default font size
		return Round((textLength * avgCharWidth) + (2 * (bMargin * fontSize)))
		; return Round((textLength * bMargin))
	}

	static SetButtonHeight(rows := 1, vMargin := 7.5) {
		; Using default values instead of FontProperties
		fontSize := 15      ; Default font size
		return Round((fontSize * vMargin) * rows)
	}

	static GetButtonDimensions(text, options := {}) {
		width := options.HasProp('width') ? options.width : GuiButtonProperties.CalculateButtonWidth(StrLen(text))
		height := options.HasProp('height') ? options.height : GuiButtonProperties.SetButtonHeight()
		return {width: width, height: height}
	}

	static GetOptimalButtonLayout(totalButtons, containerWidth, containerHeight) {
		buttonDimensions := this.GetButtonDimensions('Sample')
		maxColumns := Max(1, Floor(containerWidth / buttonDimensions.width))
		maxRows := Max(1, Floor(containerHeight / buttonDimensions.height))

		columns := Min(maxColumns, totalButtons)
		columns := Max(1, columns)  ; Ensure columns is at least 1
		rows := Ceil(totalButtons / columns)

		if (rows > maxRows) {
			rows := maxRows
			columns := Ceil(totalButtons / rows)
		}

		return {rows: rows, columns: columns}
	}
}

class FontProperties extends Gui {
	static Defaults := Map(
		'Name', 'Segoe UI',
		'Size', 9,
		'Weight', 400,
		'Italic', false,
		'Underline', false,
		'Strikeout', false,
		'Quality', 5,  ; 5 corresponds to CLEARTYPE_QUALITY
		'Charset', 1   ; 1 corresponds to DEFAULT_CHARSET
	)

	static GetDefault(key) {
		return this.Defaults.Has(key) ? this.Defaults[key] : ''
	}

	__New(guiObj := '') {
		this.LoadDefaults()
		if (guiObj != '') {
			this.UpdateFont(guiObj)
		}
		this.AvgCharW := this.CalculateAverageCharWidth()
	}

	LoadDefaults() {
		for key, value in FontProperties.Defaults {
			this.%key% := value
		}
	}

	UpdateFont(guiObj) {
		if !(guiObj is Gui) {
			return
		}

		hFont := SendMessage(0x31, 0, 0,, 'ahk_id ' guiObj.Hwnd)
		if (hFont = 0) {
			return
		}
		
		LOGFONT := Buffer(92, 0)
		if (!DllCall('GetObject', 'Ptr', hFont, 'Int', LOGFONT.Size, 'Ptr', LOGFONT.Ptr)) {
			return
		}
	
		this.Name := StrGet(LOGFONT.Ptr + 28, 32, 'UTF-16')
		this.Size := -NumGet(LOGFONT, 0, 'Int') * 72 / A_ScreenDPI
		this.Weight := NumGet(LOGFONT, 16, 'Int')
		this.Italic := NumGet(LOGFONT, 20, 'Char') != 0
		this.Underline := NumGet(LOGFONT, 21, 'Char') != 0
		this.Strikeout := NumGet(LOGFONT, 22, 'Char') != 0
		this.Quality := NumGet(LOGFONT, 26, 'Char')
		this.Charset := NumGet(LOGFONT, 23, 'Char')

		this.AvgCharW := this.CalculateAverageCharWidth()
	}

	CalculateAverageCharWidth() {
		hdc := DllCall('GetDC', 'Ptr', 0, 'Ptr')
		if (hdc == 0) {
			return 8  ; Default fallback value
		}

		hFont := DllCall('CreateFont'
			, 'Int', this.Size
			, 'Int', 0
			, 'Int', 0
			, 'Int', 0
			, 'Int', this.Weight
			, 'Uint', this.Italic
			, 'Uint', this.Underline
			, 'Uint', this.Strikeout
			, 'Uint', this.Charset
			, 'Uint', 0
			, 'Uint', 0
			, 'Uint', 0
			, 'Uint', 0
			, 'Str', this.Name)

		if (hFont == 0) {
			DllCall('ReleaseDC', 'Ptr', 0, 'Ptr', hdc)
			return 8  ; Default fallback value
		}

		hOldFont := DllCall('SelectObject', 'Ptr', hdc, 'Ptr', hFont)
		textMetrics := Buffer(56)
		if (!DllCall('GetTextMetrics', 'Ptr', hdc, 'Ptr', textMetrics)) {
			DllCall('SelectObject', 'Ptr', hdc, 'Ptr', hOldFont)
			DllCall('DeleteObject', 'Ptr', hFont)
			DllCall('ReleaseDC', 'Ptr', 0, 'Ptr', hdc)
			return 8  ; Default fallback value
		}

		averageCharWidth := NumGet(textMetrics, 20, 'Int')

		DllCall('SelectObject', 'Ptr', hdc, 'Ptr', hOldFont)
		DllCall('DeleteObject', 'Ptr', hFont)
		DllCall('ReleaseDC', 'Ptr', 0, 'Ptr', hdc)

		return averageCharWidth ? averageCharWidth : 8  ; Use fallback if averageCharWidth is 0
	}

	static CreateFontInfo(guiObj) {
		return FontProperties(guiObj)
	}
	static GetControlFontInfo(control) {
		if !(control is Gui.Control) {
			return FontProperties()
		}
		return FontProperties(control.Gui)
	}
}

class CleanInputBox extends Gui {

	Width     := Round(A_ScreenWidth  / 1920 * 1200)
	TopMargin := Round(A_ScreenHeight / 1080 * 800)

	DarkMode(BackgroundColor := '') {
		Gui2.DarkMode(this, BackgroundColor)
		return this
	}

	MakeFontNicer(fontSize := 15) {
		Gui2.MakeFontNicer(this, fontSize)
		return this
	}

	__New() {
		super.__New('AlwaysOnTop -Caption +Border')
		this.DarkMode()
		this.MakeFontNicer(15)
		this.MarginX := 0

		this.InputField := this.AddEdit(
			'x0 Center -E0x200 Background' this.BackColor ' w' this.Width
		)

		this.Input := ''
		this.isWaiting := true
		this.RegisterHotkeys()
	}

	Show() => (super.Show('y' this.TopMargin ' w' this.Width), this)

	/**
	 * Occupy the thread until you type in your input and press
	 * Enter, returns this input
	 * @returns {String}
	 */
	WaitForInput() {
		this.Show()
		while this.isWaiting {
		}
		return this.Input
	}

	SetInput() {
		this.Input := this.InputField.Text
		this.isWaiting := false
		this.Finish()
	}

	SetCancel() {
		this.isWaiting := false
		this.Finish()
	}

	RegisterHotkeys() {
		HotIfWinactive('ahk_id ' this.Hwnd)
		Hotkey('Enter', (*) => this.SetInput(), 'On')
		Hotkey('CapsLock', (*) => this.SetCancel())
		this.OnEvent('Escape', (*) => this.SetCancel())
	}

	Finish() {
		HotIfWinactive('ahk_id ' this.Hwnd)
		Hotkey('Enter', 'Off')
		this.Minimize()
		this.Destroy()
	}
}

class Infos {
	static fontSize := 8
	static distance := 4
	static unit := A_ScreenDPI / 144
	static guiWidth := Infos.fontSize * Infos.unit * Infos.distance
	static maximumInfos := Floor(A_ScreenHeight / Infos.guiWidth)
	static spots := Infos._GeneratePlacesArray()
	static maxNumberedHotkeys := 12
	static maxWidthInChars := 110

	__text := ''
	text {
		get => this.__text
		set => this.__text := value
	}

	__New(text, autoCloseTimeout := 0) {
		this.gui := Gui('AlwaysOnTop -Caption +ToolWindow')
		this.autoCloseTimeout := autoCloseTimeout
		this.text := text
		this.spaceIndex := 0
		if !this._GetAvailableSpace() {
			this._StopDueToNoSpace()
			return
		}
		this._CreateGui()
		this._SetupHotkeysAndEvents()
		this._SetupAutoclose()
		this._Show()
	}

	_CreateGui() {
		this.DarkMode()
		this.MakeFontNicer(Infos.fontSize ' cblue')
		this.NeverFocusWindow()
		this.gcText := this.gui.AddText(, this._FormatText())
		return this
	}

	DarkMode(BackgroundColor := '') {
		this.gui.BackColor := BackgroundColor = '' ? '0xA2AAAD' : BackgroundColor
		return this
	}

	MakeFontNicer(fontSize := 20) {
		this.gui.SetFont('s' fontSize ' c0000ff', 'Consolas')
		return this
	}

	NeverFocusWindow() {
		WinSetExStyle('+0x08000000', this.gui)  ; WS_EX_NOACTIVATE
		return this
	}

	static DestroyAll(*) {
		for index, infoObj in Infos.spots {
			if (infoObj is Infos) {
				infoObj.Destroy()
			}
		}
	}

	static _GeneratePlacesArray() {
		availablePlaces := []
		loop Infos.maximumInfos {
			availablePlaces.Push(false)
		}
		return availablePlaces
	}

	ReplaceText(newText) {
		if !this.gui.Hwnd {
			return Infos(newText, this.autoCloseTimeout)
		}

		if StrLen(newText) = StrLen(this.gcText.Text) {
			this.gcText.Text := newText
			this._SetupAutoclose()
			return this
		}

		Infos.spots[this.spaceIndex] := false
		return Infos(newText, this.autoCloseTimeout)
	}

	Destroy(*) {
		if (!this.gui.Hwnd) {
			return false
		}
		this.RemoveHotkeys()
		this.gui.Destroy()
		if (this.spaceIndex > 0) {
			Infos.spots[this.spaceIndex] := false
		}
		return true
	}

	RemoveHotkeys() {
		hotkeys := ['Escape', '^Escape']
		if (this.spaceIndex > 0 && this.spaceIndex <= Infos.maxNumberedHotkeys) {
			hotkeys.Push('F' this.spaceIndex)
		}
		HotIfWinExist('ahk_id ' this.gui.Hwnd)
		for hk in hotkeys {
			try Hotkey(hk, 'Off')
		}
		HotIf()
	}

	_FormatText() {
		ftext := String(this.text)
		lines := ftext.Split('`n')
		; lines := StrSplit(ftext, '`n')
		if lines.Length > 1 {
			ftext := this._FormatByLine(lines)
		}
		else {
			ftext := this._LimitWidth(ftext)
		}

		return String(this.text).Replace('&', '&&')
		; return StrReplace(ftext,'&', '&&')
	}

	_FormatByLine(lines) {
		newLines := []
		for index, line in lines {
			newLines.Push(this._LimitWidth(line))
		}
		ftext := ''
		for index, line in newLines {
			if index = newLines.Length {
				ftext .= line
				break
			}
			ftext .= line '`n'
		}
		return ftext
	}

	_LimitWidth(ltext) {
		if StrLen(ltext) < Infos.maxWidthInChars {
			return ltext
		}
		insertions := 0
		while (insertions + 1) * Infos.maxWidthInChars + insertions < StrLen(ltext) {
			insertions++
			ltext := ltext.Insert('`n', insertions * Infos.maxWidthInChars + insertions)
		}
		return ltext
	}

	_GetAvailableSpace() {
		for index, isOccupied in Infos.spots {
			if !isOccupied {
				this.spaceIndex := index
				Infos.spots[index] := this
				return true
			}
		}
		return false
	}

	_CalculateYCoord() => Round(this.spaceIndex * Infos.guiWidth - Infos.guiWidth)

	_StopDueToNoSpace() => this.Destroy()

	_SetupHotkeysAndEvents() {
		HotIfWinExist('ahk_id ' this.gui.Hwnd)
		Hotkey('Escape', (*) => this.Destroy(), 'On')
		Hotkey('^Escape', (*) => Infos.DestroyAll(), 'On')
		if (this.spaceIndex > 0 && this.spaceIndex <= Infos.maxNumberedHotkeys) {
			Hotkey('F' this.spaceIndex, (*) => this.Destroy(), 'On')
		}
		HotIf()
		this.gcText.OnEvent('Click', (*) => this.Destroy())
		this.gui.OnEvent('Close', (*) => this.Destroy())
	}

	_SetupAutoclose() {
		if this.autoCloseTimeout {
			SetTimer(() => this.Destroy(), -this.autoCloseTimeout)
		}
	}

	_Show() => this.gui.Show('AutoSize NA x0 y' this._CalculateYCoord())
}



; Info(text, timeout?) => Infos(text, timeout ?? 2000)
Info(text, timeout?) => Infos(text, timeout ?? 0)


class ErrorLogGui {
	logGui := {}
	logListView := {}
	logData := Map()
	logFile := 'error_log.json'
	instanceId := 0

	__New() {
		this.instanceId := this.GenerateUniqueId()
		this.CreateGui()
		this.LoadLogData()
	}
	
	AddTrayMenuItem() {
		A_TrayMenu.Add('Toggle ErrorLog Click-Through', (*) => this.MakeClickThrough())
	}

	MakeClickThrough() {
		static isClickThrough := false
		if (isClickThrough) {
			WinSetTransparent('Off', 'ahk_id ' . this.logGui.Hwnd)
			this.logGui.Opt('-E0x20')  ; Remove WS_EX_TRANSPARENT style
			isClickThrough := false
		} else {
			WinSetTransparent(255, 'ahk_id ' . this.logGui.Hwnd)
			this.logGui.Opt('+E0x20')  ; Add WS_EX_TRANSPARENT style
			isClickThrough := true
		}
	}

	GenerateUniqueId() {
		Loop {
			randomId := 'ErrorLogGui_' . Random(1, 9999)
			if (!WinExist('ahk_class AutoHotkeyGUI ahk_pid ' . DllCall('GetCurrentProcessId') . ' ' . randomId)) {
				return randomId
			}
		}
	}
	
	; CreateGui() {
	;     this.logGui := Gui('+Resize', 'Error Log - ' . this.instanceId)
	;     this.logGui.NeverFocusWindow()  ; This prevents the window from getting focus
	;     this.logGui.Opt('+LastFound')
	;     WinSetTitle(this.instanceId)
	;     this.logListView := this.logGui.Add('ListView', 'r20 w600 vLogContent', ['Timestamp', 'Message'])
	;     this.logGui.Add('Button', 'w100', 'Copy to Clipboard').OnEvent('Click', (*) => this.CopyToClipboard())
	;     this.logGui.OnEvent('Close', (*) => this.logGui.Hide())
	;     this.logGui.OnEvent('Size', (*) => this.ResizeControls())
	;     this.logGui.Show()
	; }
	
	CreateGui() {
		this.logGui := Gui('+Resize', 'Error Log - ' . this.instanceId)
		; this.logGui.NeverFocusWindow()  ; Using the new method
		; Gui2.NeverFocusWindow(this.logGui)
		this.logGui.Opt('+LastFound')
		WinSetTitle(this.instanceId)
		this.logListView := this.logGui.Add('ListView', 'r20 w600 vLogContent', ['Timestamp', 'Message'])
		this.logGui.Add('Button', 'w100', 'Copy to Clipboard').OnEvent('Click', (*) => this.CopyToClipboard())
		this.logGui.OnEvent('Close', (*) => this.logGui.Hide())
		this.logGui.OnEvent('Size', (*) => this.ResizeControls())
		this.logGui.Show()
	}
	
	ResizeControls() {
		clientPos := {}, h := w := 0
		if (this.logGui.Hwnd) {
			this.logGui.GetClientPos(,,&w, &h)
			clientPos.w := w
			clientPos.h := h
			; this.logListView.Move('w' . (clientPos.w - 20) . ' h' . (clientPos.h - 40))
			this.logListView.Move(,,(clientPos.w - 20) , (clientPos.h - 40))
		}
	}
	
	LoadLogData() {
		if (!FileExist(this.logFile)) {
			this.CreateDefaultLogFile()
		}
		
		try {
			fileContent := FileRead(this.logFile)
			loadedData := jsongo.Parse(fileContent)
			if (IsObject(loadedData) && loadedData.Length) {
				this.logData := Map()
				for entry in loadedData {
					this.logData.Set(entry.timestamp, entry.message)
				}
			}
		} catch as err {
			ErrorLogger.Log('Error loading log data: ' . err.Message)
			this.logData := Map()
		}
		
		this.UpdateListView()
	}
	
	CreateDefaultLogFile() {
		defaultData := [{timestamp: FormatTime(, 'yyyy-MM-dd HH:mm:ss'), message: 'Log file created'}]
		FileAppend(jsongo.Stringify(defaultData, 4), this.logFile)
	}
	
	; UpdateListView() {
	;     this.logListView.Delete()
	;     for timestamp, message in this.logData {
	;         this.logListView.Add(, timestamp, message)
	;     }
	;     this.logListView.ModifyCol()  ; Auto-size columns
	; }

	UpdateListView() {
		OutputDebug('LogData count: ' . this.logData.Count)
		OutputDebug('Updating ListView')
		this.logListView.Opt('-Redraw')  	; Suspend redrawing
		this.logListView.Delete()
		for timestamp, message in this.logData {
			this.logListView.Add(, timestamp, message)
		}
		this.logListView.ModifyCol()  		; Auto-size columns
		this.logListView.Opt('+Redraw')  	; Resume redrawing
	}
	
	; Log(message, showGui := true) {
	;     timestamp := FormatTime(, 'yyyy-MM-dd HH:mm:ss')
	;     this.logData.Set(timestamp, message)
		
	;     this.UpdateListView()
	;     this.SaveLogData()
	;     OutputDebug(timestamp . ': ' . message)
		
	;     if (showGui) {
	;         this.logGui.Show()
	;     }
	; }
	
	Log(input, showGui := true) {
		timestamp := FormatTime(, 'yyyy-MM-dd HH:mm:ss')
		
		if (IsObject(input)) {
			this.logData.Set(timestamp, input)
		} else {
			this.logData.Set(timestamp, {message: input})
		}
		
		this.UpdateGUI()
		this.SaveLogData()
		
		if (showGui) {
			this.logGui.Show()
		}
	}
	
	UpdateGUI() {
	if (this.logData.Count == 0) {
		return
	}
	
	; Get the first log entry to determine the structure
	firstEntry := this.logData[this.logData.Count]
	
	; Clear existing controls
	this.logGui.Destroy()
	
	; Recreate the GUI
	this.CreateBaseGUI()
	
	; Create headers based on the first entry
	headers := ['Timestamp']
	for key in firstEntry.OwnProps() {
		headers.Push(key)
	}
	
	; Create the ListView
	this.logListView := this.logGui.Add('ListView', 'r20 w600', headers)
	
	; Populate the ListView
	for timestamp, data in this.logData {
		row := [timestamp]
		for key, value in data.OwnProps() {
			row.Push(value)
		}
		this.logListView.Add(, row*)
	}
	
	this.logListView.ModifyCol()  ; Auto-size columns
	this.ResizeControls()
}

CreateBaseGUI() {
	this.logGui := Gui('+Resize', 'Error Log - ' . this.instanceId)
	; Gui2.NeverFocusWindow(this.logGui)
	this.logGui.NeverFocusWindow()
	this.logGui.OnEvent('Close', (*) => this.logGui.Hide())
	this.logGui.OnEvent('Size', (*) => this.ResizeControls())
}

	DelayedUpdate() {
		this.UpdateListView()
		this.updatePending := false
	}

	; SaveLogData() {
	; 	try {
	; 		FileDelete(this.logFile)
	; 		dataToSave := []
	; 		for timestamp, message in this.logData {
	; 			dataToSave.Push({timestamp: timestamp, message: message})
	; 		}
	; 		FileAppend(jsongo.Stringify(dataToSave, 4), this.logFile)
	; 	} catch as err {
	; 		OutputDebug('Error saving log data: ' . err.Message)
	; 	}
	; }

	SaveLogData() {
		try {
			dataToSave := []
			for timestamp, message in this.logData {
				dataToSave.Push({timestamp: timestamp, message: message})
			}
			FileAppend(jsongo.Stringify(dataToSave, 4), this.logFile)
		} catch as err {
			try OutputDebug('Error saving log data: ' . err.Message)
			try Infos('Error saving log data: ' . err.Message)
		}
	}
	
	CopyToClipboard() {
		clipboardContent := ''
		for timestamp, message in this.logData {
			clipboardContent .= timestamp . ': ' . message . '`n'
		}
		A_Clipboard := clipboardContent
		MsgBox('Log data copied to clipboard!')
	}
}

; Static class to manage instances
class ErrorLogger {
	static instances := Map()
	
	static GetInstance(name := 'default') {
		if (!this.instances.Has(name)) {
			this.instances.Set(name, ErrorLogGui())
		}
		return this.instances.Get(name)
	}
	
	static Log(input, instanceName := 'default', showGui := true) {
		this.GetInstance(instanceName).Log(input, showGui)
	}
}

class FileSystemSearch extends Gui {

	/**
		* Find all the matches of your search request within the currently
		* opened folder in the explorer.
		* The searcher recurses into all the subfolders.
		* Will search for both files and folders.
		* After the search is completed, will show all the matches in a list.
		* Call StartSearch() after creating the class instance if you can pass
		* the input yourself.
		* Call GetInput() after creating the class instance if you want to have
		* an input box to type in your search into.
		*/
	__New(searchWhere?, caseSense := 'Off') {
		super.__New('+Resize', 'These files match your search:')

		Gui2.MakeFontNicer(14)
		Gui2.DarkMode(this)

		this.List := this.AddText(, '
		(
			Right click on a result to copy its full path.
			Double click to open it in explorer.
		)')

		this.WidthOffset  := 35
		this.HeightOffset := 80

		this.List := this.AddListView(
			'Count50 Background' this.BackColor,
			/**
				* Count50 — we're not losing much by allocating more memory
				* than needed,
				* and on the other hand we improve the performance by a lot
				* by doing so
				*/
			['File', 'Folder', 'Directory']
		)

		this.caseSense := caseSense

		if !IsSet(searchWhere) {
			this.ValidatePath()
		} else {
			this.path := searchWhere
		}

		this.SetOnEvents()
	}

	/**
		* Get an input box to type in your search request into.
		* Get a list of all the matches that you can open in explorer.
		*/
	GetInput() {
		if !input := CleanInputBox().WaitForInput() {
			return false
		}
		this.StartSearch(input)
	}

	ValidatePath() {
		SetTitleMatchMode('RegEx')
		try this.path := WinGetTitle('^[A-Z]: ahk_exe explorer\.exe')
		catch Any {
			Info('Open an explorer window first!')
			Exit()
		}
	}

	/**
		* Get a list of all the matches of *input*.
		* You can either open them in explorer or copy their path.
		* @param input *String*
		*/
	StartSearch(input) {
		/**
			* Improves performance rather than keeping on adding rows
			* and redrawing for each one of them
			*/
		this.List.Opt('-Redraw')

		;To remove the worry of 'did I really start the search?'
		gInfo := Infos('The search is in progress')

		if this.path ~= '^[A-Z]:\\$' {
			this.path := this.path[1, -2]
		}

		loop files this.path '\*.*', 'FDR' {
			if !A_LoopFileName.Find(input, this.caseSense) {
				continue
			}
			if A_LoopFileAttrib.Find('D')
				this.List.Add(, , A_LoopFileName, A_LoopFileDir)
			else if A_LoopFileExt
				this.List.Add(, A_LoopFileName, , A_LoopFileDir)
		}

		gInfo.Destroy()

		this.List.Opt('+Redraw')
		this.List.ModifyCol() ;It makes the columns fit the data — @rbstrachan

		this.Show('AutoSize')
	}

	DestroyResultListGui() {
		this.Minimize()
		this.Destroy()
	}

	SetOnEvents() {
		this.List.OnEvent('DoubleClick',
			(guiCtrlObj, selectedRow) => this.ShowResultInFolder(selectedRow)
		)
		this.List.OnEvent('ContextMenu',
			(guiCtrlObj, rowNumber, var:=0) => this.CopyPathToClip(rowNumber)
		)
		this.OnEvent('Size',
			(guiObj, minMax, width, height) => this.FixResizing(width, height)
		)
		this.OnEvent('Escape', (guiObj) => this.DestroyResultListGui())
	}

	FixResizing(width, height) {
		this.List.Move(,, width - this.WidthOffset, height - this.HeightOffset)
		/**
			* When you resize the main gui, the listview also gets resize to have the same
			* borders as usual.
			* So, on resize, the onevent passes *what* you resized and the width and height
			* that's now the current one.
			* Then you can use that width and height to also resize the listview in relation
			* to the gui
			*/
	}

	ShowResultInFolder(selectedRow) {
		try Run('explorer.exe /select,' this.GetPathFromList(selectedRow))
		/**
			* By passing select, we achieve the cool highlighting thing when the file / folder
			* gets opened. (You can pass command line parameters into the run function)
			*/
	}

	CopyPathToClip(rowNumber) {
		A_Clipboard := this.GetPathFromList(rowNumber)
		Info('Path copied to clipboard!')
	}

	GetPathFromList(rowNumber) {
		/**
			* The OnEvent passes which row we interacted with automatically
			* So we read the text that's on the row
			* And concoct it to become the full path
			* This is much better performance-wise than adding all the full paths to an array
			* while adding the listviews (in the loop) and accessing it here.
			* Arguably more readable too
			*/

		file := this.List.GetText(rowNumber, 1)
		dir  := this.List.GetText(rowNumber, 2)
		path := this.List.GetText(rowNumber, 3)

		return path '\' file dir ; No explanation required, it's just logic — @rbstrachan
	}
}
class FileSearch {
	static fso := ComObject('Scripting.FileSystemObject')

	__New(searchPath := A_WorkingDir) {
		this.searchPath := searchPath
	}

	Search(pattern := '', options := {}) {
		results := []
		this._SearchRecursive(this.searchPath, pattern, options, &results)
		sortBy := options.HasOwnProp('sortBy') ? options.sortBy : 'name'
		sortDesc := options.HasOwnProp('sortDesc') ? options.sortDesc : false
		return this._SortResults(results, sortBy, sortDesc)
	}

	_SearchRecursive(folder, pattern, options, &results) {
		for file in FileSearch.fso.GetFolder(folder).Files {
			if this._MatchesCriteria(file, pattern, options)
				results.Push({path: file.Path, name: file.Name, size: file.Size, dateModified: file.DateLastModified})
		}
		for subFolder in FileSearch.fso.GetFolder(folder).SubFolders
			this._SearchRecursive(subFolder.Path, pattern, options, &results)
	}

	_MatchesCriteria(file, pattern, options) {
		if pattern && !InStr(file.Name, pattern)
			return false
		if options.HasOwnProp('minSize') && file.Size < options.minSize
			return false
		if options.HasOwnProp('maxSize') && file.Size > options.maxSize
			return false
		if options.HasOwnProp('afterDate') && file.DateLastModified < options.afterDate
			return false
		if options.HasOwnProp('beforeDate') && file.DateLastModified > options.beforeDate
			return false
		return true
	}

	_SortResults(results, sortBy := 'name', sortDesc := false) {
		results.Sort((*) => this._CompareItems(&a, &b, sortBy, sortDesc))
		return results
	}
	
	_CompareItems(&a, &b, sortBy, sortDesc) {
		if (sortDesc)
			return a.%sortBy% > b.%sortBy% ? -1 : 1
		else
			return a.%sortBy% < b.%sortBy% ? -1 : 1
	}

	ShowResultsGUI(results) {
		; Implement GUI display similar to FileSystemSearch class
		Infos(results)
	}
}

; #Include <System\DPI>
; #Include <WindowSpyDpi>

; ---------------------------------------------------------------------------
; @Section ...: [Class] GuiReSizer
; ---------------------------------------------------------------------------
/************************************************************************
	* @description 
	* @file HotstringManager.ahk
	* @author 
	* @date 2024/01/09
	* @version 0.0.0
	***********************************************************************/
/************************************************************************
	* @author Fanatic Guru
	* @version 2023.03.13
	* @version 2023.02.15:  Add more Min Max properties and renamed some properties
	* @version 2023.03.13:  Major rewrite.  Converted to Class to allow for Methods
	* @version 2023.03.17:  Add function InTab3 to allow automatic anchoring of controls in Tab3
	* @example
;! ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
Class to Handle the Resizing of Gui and
Move and Resize Controls
; ---------------------------------------------------------------------------
Class GuiReSizer

Call: GuiReSizer(GuiObj, WindowMinMax, Width, Height)

Parameters:
1) {GuiObj} 		Gui Object
2) {WindowMinMax}	Window status, 0 = neither minimized nor maximized, 1 = maximized, -1 = minimized
3) {Width}			Width of GuiObj
4) {Height}			Height of GuiObj

Normally parameters are passed by a callback from {gui}.OnEvent("Size", GuiReSizer)

Properties | Abbr | Description
X					X positional offset from margins
Y					Y positional offset from margins
XP					X positional offset from margins as percentage of Gui width
YP					Y positional offset from margins as percentage of Gui height
OriginX		 OX		control origin X defaults to 0 or left side of control, this relocates the origin
OriginXP	 OXP	control origin X as percentage of Gui width defaults to 0 or left side of control, this relocates the origin
OriginY		 OY		control origin Y defaults to 0 or top side of control, this relocates the origin
OriginYP	 OYP	control origin Y as percentage of Gui height defaults to 0 or top side of control, this relocates the origin
Width		 W		width of control
WidthP		 WP		width of control as percentage of Gui width
Height		 H		height of control
HeightP		 HP		height of control as percentage of Gui height
MinX				mininum X offset
MaxX				maximum X offset
MinY				minimum Y offset
MaxY				maximum Y offset
MinWidth	 MinW	minimum control width
MaxWidth	 MaxW	maximum control width
MinHeight	 MinH	minimum control height
MaxHeight	 MaxH	maximum control height
Cleanup		 C		{true/false} when set to true will redraw this control each time to cleanup artifacts, normally not required and causes flickering
Function	 F		{function} custom function that will be called for this control
Anchor		 A 		{contol object} anchor control so that size and position commands are in relation to another control
AnchorIn	 AI		{true/false} controls where the control is restricted to the inside of another control

Methods:
Now(GuiObj)         will force a manual Call now for {GuiObj}
Opt({switches})     same as Options method
Options({switches}) all options are set as a string with each switch separated by a space "x10 yp50 oCM"

	Flags:			Abbreviation 
	x{number}       X
	y{number}       Y
	xp{number}      XP
	yp{number}      YP
	wp{number}      WidthP
	hp{number}      HeightP
	w{number}       Width
	h{number}       Height
	minx{number}    MinX
	maxx{number}    MaxX
	miny{number}    MinY
	maxy{number}    MaxY
	minw{number}    MinWidth
	maxw{number}    MaxWidth
	minh{number}    MinHeight
	maxh{number}    MaxHeight
	oxp{number}     OriginXP
	oyp{number}     OriginYP
	ox{number}      OriginX
	oy{number}      OriginY
	o{letters}      Origin: "L" left, "C" center, "R" right, "T" top, "M" middle, "B" bottom; may use 1 or 2 letters

Gui Properties:
Init		{Gui}.Init := 1, will cause all controls of the Gui to be redrawn on next function call
			{Gui}.Init := 2, will also reinitialize abbreviations
;! ---------------------------------------------------------------------------
***********************************************************************/
Class GuiReSizer
{
	;{ Call GuiReSizer
	Static Call(GuiObj, WindowMinMax, GuiW, GuiH)
	{
		; On Initial display of Gui use redraw to cleanup first positioning
		Try{
			(GuiObj.Init)
		}
		Catch{
			GuiObj.Init := 2 ; Redraw Twice on Initial Call(called on initial Show)
		}
		If WindowMinMax = -1{ ; Do nothing if window minimized
			Return
		}
		;{ Loop through all Controls of Gui
		For Hwnd, CtrlObj in GuiObj {
			;{ Initializations on First Call
			If GuiObj.Init = 2
			{
				Try CtrlObj.OriginXP	:= CtrlObj.OX
				Try CtrlObj.OriginXP	:= CtrlObj.OXP
				Try CtrlObj.OriginY 	:= CtrlObj.OY
				Try CtrlObj.OriginYP 	:= CtrlObj.OYP
				Try CtrlObj.Width 		:= CtrlObj.W
				Try CtrlObj.WidthP 		:= CtrlObj.WP
				Try CtrlObj.Height 		:= CtrlObj.H
				Try CtrlObj.HeightP 	:= CtrlObj.HP
				Try CtrlObj.MinWidth 	:= CtrlObj.MinW
				Try CtrlObj.MaxWidth 	:= CtrlObj.MaxW
				Try CtrlObj.MinHeight 	:= CtrlObj.MinH
				Try CtrlObj.MaxHeight 	:= CtrlObj.MaxH
				Try CtrlObj.Function 	:= CtrlObj.F
				Try CtrlObj.Cleanup 	:= CtrlObj.C
				Try CtrlObj.Anchor 		:= CtrlObj.A
				Try CtrlObj.AnchorIn 	:= CtrlObj.AI
				If !CtrlObj.HasProp("AnchorIn"){
					CtrlObj.AnchorIn 	:= true
				}
			}
			;}
			;{ Initialize Current Positions and Sizes
			
			CtrlObj.GetPos(&CtrlX, &CtrlY, &CtrlW, &CtrlH)
			; DPI.WinGetClientPos(&CtrlX, &CtrlY, &CtrlW, &CtrlH, CtrlObj)
			; ControlGetPos(&CtrlX, &CtrlY, &CtrlW, &CtrlH, CtrlObj)
			; DPI.WinGetClientPos(&CtrlX, &CtrlY, &CtrlW, &CtrlH)
			LimitX := AnchorW := GuiW, LimitY := AnchorH := GuiH, OffsetX := OffsetY := 0
			;}
			;{ Check for Anchor
			If CtrlObj.HasProp("Anchor")
			{
				If Type(CtrlObj.Anchor) = "Gui.Tab"
				{
					CtrlObj.Anchor.GetPos(&AnchorX, &AnchorY, &AnchorW, &AnchorH)
					Offset(CtrlObj, &TabX, &TabY)
					CtrlX := CtrlX - TabX, CtrlY := CtrlY - TabY
					AnchorW := AnchorW + AnchorX - TabX, AnchorH := AnchorH + AnchorY - TabY
				}
				Else
				{
					CtrlObj.Anchor.GetPos(&AnchorX, &AnchorY, &AnchorW, &AnchorH)
					If CtrlObj.HasProp("X") or CtrlObj.HasProp("XP")
						OffsetX := AnchorX
					If CtrlObj.HasProp("Y") or CtrlObj.HasProp("YP")
						OffsetY := AnchorY
				}
				If CtrlObj.AnchorIn
					LimitX := AnchorW, LimitY := AnchorH
			}
			;}
			;{ OriginX
			If CtrlObj.HasProp("OriginX") and CtrlObj.HasProp("OriginXP")
				OriginX := CtrlObj.OriginX + (CtrlW * CtrlObj.OriginXP)
			Else If CtrlObj.HasProp("OriginX") and !CtrlObj.HasProp("OriginXP")
				OriginX := CtrlObj.OriginX
			Else If !CtrlObj.HasProp("OriginX") and CtrlObj.HasProp("OriginXP")
				OriginX := CtrlW * CtrlObj.OriginXP
			Else
				OriginX := 0
			;}
			;{ OriginY
			If CtrlObj.HasProp("OriginY") and CtrlObj.HasProp("OriginYP")
				OriginY := CtrlObj.OriginY + (CtrlH * CtrlObj.OriginYP)
			Else If CtrlObj.HasProp("OriginY") and !CtrlObj.HasProp("OriginYP")
				OriginY := CtrlObj.OriginY
			Else If !CtrlObj.HasProp("OriginY") and CtrlObj.HasProp("OriginYP")
				OriginY := CtrlH * CtrlObj.OriginYP
			Else
				OriginY := 0
			;}
			;{ X
			If CtrlObj.HasProp("X") and CtrlObj.HasProp("XP")
				CtrlX := Mod(LimitX + CtrlObj.X + (AnchorW * CtrlObj.XP) - OriginX, LimitX)
			Else If CtrlObj.HasProp("X") and !CtrlObj.HasProp("XP")
				CtrlX := Mod(LimitX + CtrlObj.X - OriginX, LimitX)
			Else If !CtrlObj.HasProp("X") and CtrlObj.HasProp("XP")
				CtrlX := Mod(LimitX + (AnchorW * CtrlObj.XP) - OriginX, LimitX)
			;}
			;{ Y
			If CtrlObj.HasProp("Y") and CtrlObj.HasProp("YP")
				CtrlY := Mod(LimitY + CtrlObj.Y + (AnchorH * CtrlObj.YP) - OriginY, LimitY)
			Else If CtrlObj.HasProp("Y") and !CtrlObj.HasProp("YP")
				CtrlY := Mod(LimitY + CtrlObj.Y - OriginY, LimitY)
			Else If !CtrlObj.HasProp("Y") and CtrlObj.HasProp("YP")
				CtrlY := Mod(LimitY + AnchorH * CtrlObj.YP - OriginY, LimitY)
			;}
			;{ Width
			If CtrlObj.HasProp("Width") and CtrlObj.HasProp("WidthP")
				(CtrlObj.Width > 0 and CtrlObj.WidthP > 0 ? CtrlW := CtrlObj.Width + AnchorW * CtrlObj.WidthP : CtrlW := CtrlObj.Width + AnchorW + AnchorW * CtrlObj.WidthP - CtrlX)
			Else If CtrlObj.HasProp("Width") and !CtrlObj.HasProp("WidthP")
				(CtrlObj.Width > 0 ? CtrlW := CtrlObj.Width : CtrlW := AnchorW + CtrlObj.Width - CtrlX)
			Else If !CtrlObj.HasProp("Width") and CtrlObj.HasProp("WidthP")
				(CtrlObj.WidthP > 0 ? CtrlW := AnchorW * CtrlObj.WidthP : CtrlW := AnchorW + AnchorW * CtrlObj.WidthP - CtrlX)
			;}
			;{ Height
			If CtrlObj.HasProp("Height") and CtrlObj.HasProp("HeightP")
				(CtrlObj.Height > 0 and CtrlObj.HeightP > 0 ? CtrlH := CtrlObj.Height + AnchorH * CtrlObj.HeightP : CtrlH := CtrlObj.Height + AnchorH + AnchorH * CtrlObj.HeightP - CtrlY)
			Else If CtrlObj.HasProp("Height") and !CtrlObj.HasProp("HeightP")
				(CtrlObj.Height > 0 ? CtrlH := CtrlObj.Height : CtrlH := AnchorH + CtrlObj.Height - CtrlY)
			Else If !CtrlObj.HasProp("Height") and CtrlObj.HasProp("HeightP")
				(CtrlObj.HeightP > 0 ? CtrlH := AnchorH * CtrlObj.HeightP : CtrlH := AnchorH + AnchorH * CtrlObj.HeightP - CtrlY)
			;}
			;{ Min Max
			(CtrlObj.HasProp("MinX") ? MinX := CtrlObj.MinX : MinX := -999999)
			(CtrlObj.HasProp("MaxX") ? MaxX := CtrlObj.MaxX : MaxX := 999999)
			(CtrlObj.HasProp("MinY") ? MinY := CtrlObj.MinY : MinY := -999999)
			(CtrlObj.HasProp("MaxY") ? MaxY := CtrlObj.MaxY : MaxY := 999999)
			(CtrlObj.HasProp("MinWidth") ? MinW := CtrlObj.MinWidth : MinW := 0)
			(CtrlObj.HasProp("MaxWidth") ? MaxW := CtrlObj.MaxWidth : MaxW := 999999)
			(CtrlObj.HasProp("MinHeight") ? MinH := CtrlObj.MinHeight : MinH := 0)
			(CtrlObj.HasProp("MaxHeight") ? MaxH := CtrlObj.MaxHeight : MaxH := 999999)
			CtrlX := MinMax(CtrlX, MinX, MaxX)
			CtrlY := MinMax(CtrlY, MinY, MaxY)
			CtrlW := MinMax(CtrlW, MinW, MaxW)
			CtrlH := MinMax(CtrlH, MinH, MaxH)
			;}
			;{ Move and Size
			CtrlObj.Move(CtrlX + OffsetX, CtrlY + OffsetY, CtrlW, CtrlH)
			;}
			;{ Redraw on Cleanup or GuiObj.Init
			If GuiObj.Init or (CtrlObj.HasProp("Cleanup") and CtrlObj.Cleanup = true)
				CtrlObj.Redraw()
			;}
			;{ Custom Function Call
			If CtrlObj.HasProp("Function")
				CtrlObj.Function(GuiObj) ; CtrlObj is hidden 'this' first parameter
			;}
		}
		;}
		;{ Reduce GuiObj.Init Counter and Check for Call again
		If (GuiObj.Init := Max(GuiObj.Init - 1, 0))
		{
			GuiObj.GetClientPos(, , &AnchorW, &AnchorH)
			GuiReSizer(GuiObj, WindowMinMax, AnchorW, AnchorH)
		}
		;}
		;{ Functions: Helpers
		MinMax(Num, MinNum, MaxNum) => Min(Max(Num, MinNum), MaxNum)
		Offset(CtrlObj, &OffsetX, &OffsetY)
		{
			Hwnd := CtrlObj.Hwnd
			hParentWnd := DllCall("GetParent", "Ptr", Hwnd, "Ptr")
			RECT := Buffer(16, 0)
			DllCall("GetWindowRect", "Ptr", hParentWnd, "Ptr", RECT)
			DllCall("MapWindowPoints", "Ptr", 0, "Ptr", DllCall("GetParent", "Ptr", hParentWnd, "Ptr"), "Ptr", RECT, "UInt", 1)
			OffsetX := NumGet(RECT, 0, "Int"), OffsetY := NumGet(RECT, 4, "Int")
		}
		;}
	}
	;}
	;{ Methods:
	;{ Options
	Static Opt(CtrlObj, Options) => GuiReSizer.Options(CtrlObj, Options)
	Static Options(CtrlObj, Options)
	{
		For Option in StrSplit(Options, " ")
		{
			For Abbr, Cmd in Map(
				"xp", "XP", "yp", "YP", "x", "X", "y", "Y",
				"wp", "WidthP", "hp", "HeightP", "w", "Width", "h", "Height",
				"minx", "MinX", "maxx", "MaxX", "miny", "MinY", "maxy", "MaxY",
				"minw", "MinWidth", "maxw", "MaxWidth", "minh", "MinHeight", "maxh", "MaxHeight",
				"oxp", "OriginXP", "oyp", "OriginYP", "ox", "OriginX", "oy", "OriginY")
				If RegExMatch(Option, "i)^" Abbr "([\d.-]*$)", &Match)
				{
					CtrlObj.%Cmd% := Match.1
					Break
				}
			; Origin letters
			If SubStr(Option, 1, 1) = "o"
			{
				Flags := SubStr(Option, 2)
				If Flags ~= "i)l"           ; left
					CtrlObj.OriginXP := 0
				If Flags ~= "i)c"           ; center (left to right)
					CtrlObj.OriginXP := 0.5
				If Flags ~= "i)r"           ; right
					CtrlObj.OriginXP := 1
				If Flags ~= "i)t"           ; top
					CtrlObj.OriginYP := 0
				If Flags ~= "i)m"           ; middle (top to bottom)
					CtrlObj.OriginYP := 0.5
				If Flags ~= "i)b"           ; bottom
					CtrlObj.OriginYP := 1
			}
		}
	}
	;}
	;{ Now
	Static Now(GuiObj, Redraw := true, Init := 2)
	{
		If Redraw
			GuiObj.Init := Init
		GuiObj.GetClientPos(, , &Width, &Height)
		GuiReSizer(GuiObj, WindowMinMax := 1, Width, Height)
	}
	;}
	;}
}
;}
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

#Requires AutoHotkey v2.0+
; #Include <Directives\__AE.v2>
; #Include <Common\Common_Rec_Texts>
#Include <Includes/Notes>
#Include <Includes/ObjectTypeExtensions>
; ---------------------------------------------------------------------------
/** @region AutoComplete() */
; ---------------------------------------------------------------------------
AutoComplete(CtlObj, ListObj, GuiObj?) {
	static CB_GETEDITSEL := 320, CB_SETEDITSEL := 322, valueFound := false
	local Start :=0, End := 0,

	cText := CtlObj.Text

	currContent := CtlObj.Text

	CtlObj.Value := currContent
	; QSGui['your name'].Value := currContent
	; QSGui.Add('Text','Section','Text')
	; QSGui.Show("AutoSize")
	; QSGui.Show()
	; if ((GetKeyState("Delete", "P")) || (GetKeyState("Backspace", "P"))){
	if ((GetKeyState('Delete')) || (GetKeyState('Backspace'))){
		return
	}

	valueFound := false
	; ---------------------------------------------------------------------------
	/** @i for index, value in entries */
	; ---------------------------------------------------------------------------
	/** @i Check if the current value matches the target value */
	; ---------------------------------------------------------------------------
	for index, value in ListObj {
		; ---------------------------------------------------------------------------
	/** @i Exit the loop if the value is found */
		; ---------------------------------------------------------------------------
		if (value = currContent) {
			valueFound := true
			break
		}
	}
	; ---------------------------------------------------------------------------
	/** @i Exit Nested request */
	; ---------------------------------------------------------------------------
	if (valueFound){
		return
	}
	; ---------------------------------------------------------------------------
	/** @i Start := 0, End :=0 */
	; ---------------------------------------------------------------------------
	MakeShort(0, &Start, &End)
	try {
		if (ControlChooseString(cText, CtlObj) > 0) {
			Start := StrLen(currContent)
			End := StrLen(CtlObj.Text)
			PostMessage(CB_SETEDITSEL, 0, MakeLong(Start, End),,CtlObj.Hwnd)
		}
	} Catch as e {
		ControlSetText(currContent, CtlObj)
		ControlSetText(cText, CtlObj)
		PostMessage(CB_SETEDITSEL, 0, MakeLong(StrLen(cText), StrLen(cText)),,CtlObj.Hwnd)
	}

	MakeShort(Long, &LoWord, &HiWord) => (LoWord := Long & 0xffff, HiWord := Long >> 16)

	MakeLong(LoWord, HiWord) {
		return (HiWord << 16) | (LoWord & 0xffff)
	}
}

#HotIf WinActive(A_ScriptName)
#5::testAutoComplete()

testAutoComplete() {
; SetCapsLockState("Off")
acInfos := Infos('AutoComplete enabled'
				'Press "Shift+{Enter}",to activate'
			)
; acInfos := Infos('Press "ctrl + a" to activate, or press "Shift+Enter"')
; Hotkey(" ", (*) => createGUI())
; Hotkey("^a", (*) => createGUI())
Hotkey('+Enter', (*) => createGUI() )
; createGUI()
createGUI() {
	initQuery := "Recommendation Library"
	initQuery := ""
	; global entriesList := ["Red", "Green", "Blue"]
	mList := []
	; mlist := understanding_the_risk
	mlist := Links_AhkLib
	; Infos(mlist)
	; entriesList := [mlist]
	; entries := []
	entries := ''
	entriesList := []
	m:=''
	for each, m in mList {
		entriesList.SafePush(m)
	}
	e:=''
	for each, e in entriesList {
		; entriesList := ''
		; entries := ''
		; entriesList .= value '`n'
		entries .= e '`n'
	}

	global QSGui, initQuery, entriesList
	global width := Round(A_ScreenWidth / 4)
	QSGui := Gui("AlwaysOnTop +Resize +ToolWindow Caption", "Recommendation Picker")
	QSGui.SetColor := 0x161821
	QSGui.BackColor := 0x161821
	QSGui.SetFont( "s10 q5", "Fira Code")
	; QSCB := QSGui.AddComboBox("vQSEdit w200", entriesList)
	QSCB := QSGui.AddComboBox("vQSEdit w" width ' h200' ' Wrap', entriesList)
	qEdit := QSGui.AddEdit('vqEdit w' width ' h200')
	; qEdit.OnEvent('Change', (*) => updateEdit(QSCB, entriesList))
	QSGui_Change(QSCB) => qEdit.OnEvent('Change',qEdit)
	QSGui.Add('Text','Section')
	QSGui.Opt('+Owner ' QSGui.Hwnd)
	; QSCB := QSGui.AddComboBox("vQSEdit w" width ' h200', entriesList)
	QSCB.Text := initQuery
	QSCB.OnEvent("Change", (*) => AutoComplete(QSCB, entriesList))
	; QSCB.OnEvent('Change', (*) => updateEdit(QSCB, entriesList))
	QSBtn := QSGui.AddButton("default hidden yp hp w0", "OK")
	QSBtn.OnEvent("Click", (*) => processInput())
	QSGui.OnEvent("Close", (*) => QSGui.Destroy())
	QSGui.OnEvent("Escape", (*) => QSGui.Destroy())
	; QSGui.Show( "w222")
	; QSGui.Show("w" width ' h200')
	QSGui.Show( "AutoSize")
}

processInput() {
	QSSubmit := QSGui.Submit()    ; Save the contents of named controls into an object.
	if QSSubmit.QSEdit {
		; MsgBox(QSSubmit.QSEdit, "Debug GUI")
		initQuery := QSSubmit.QSEdit
		Infos.DestroyAll()
		Sleep(100)
		updated_Infos := Infos(QSSubmit.QSEdit)

	}
	QSGui.Destroy()
	WinWaitClose(updated_Infos.hwnd)
	Run(A_ScriptName)
}
}

; class AutoCompleteGUI {
;     static Create(data) {
;         return AutoCompleteGUI(data)
;     }

;     __New(data) {
;         this.data := this.ProcessInput(data)
;         this.CreateGUI()
;     }

;     ProcessInput(input) {
;         switch Type(input) {
;             case "String":
;                 if (FileExist(input)) {
;                     return this.LoadFile(input)
;                 } else {
;                     return StrSplit(input, "`n", "`r")
;                 }
;             case "Array", "Map":
;                 return input
;             case "Object":
;                 return input.OwnProps()
;             default:
;                 throw ValueError("Unsupported input type")
;         }
;     }

;     ; LoadFile(filename) {
;     ;     ext := FileExt(filename)
;     ;     switch ext {
;     ;         case "json":
;     ;             return JSON.Parse(FileRead(filename))
;     ;         case "ini":
;     ;             return this.ParseIni(filename)
;     ;         case "txt":
;     ;             return StrSplit(FileRead(filename), "`n", "`r")
;     ;         default:
;     ;             throw ValueError("Unsupported file type")
;     ;     }
;     ; }

;     LoadFile(filename) {
;         ext := this.FileExt(filename)  ; Using class method
;         switch ext {
;             case "json":
;                 return JSON.Parse(FileRead(filename))
;             case "ini":
;                 return this.ParseIni(filename)
;             case "txt":
;                 return StrSplit(FileRead(filename), "`n", "`r")
;             default:
;                 throw ValueError("Unsupported file type")
;         }
;     }

;     ; New method added to existing class
;     FileExt(filename) {
;         SplitPath(filename,, &dir, &ext)
;         return ext
;     }

;     ParseIni(filename) {
;         result := Map()
;         IniRead(sections, filename)
;         for section in StrSplit(sections, "`n") {
;             result[section] := IniRead(filename, section)
;         }
;         return result
;     }

;     CreateGUI() {
;         this.gui := Gui("+Resize +MinSize320x240", "Enhanced AutoComplete")
;         this.gui.OnEvent("Size", (*) => this.OnResize())

;         this.gui.Add("Text", "w320", "Search:")
;         this.searchBox := this.gui.Add("Edit", "w320 vSearchTerm")
;         this.searchBox.OnEvent("Change", (*) => this.UpdateList())

;         this.listBox := this.gui.Add("ListBox", "w320 h200 vSelectedItem")
;         this.listBox.OnEvent("DoubleClick", (*) => this.SelectItem())

;         this.gui.Add("Button", "w100 vOK", "Select").OnEvent("Click", (*) => this.SelectItem())
;         this.gui.Show()

;         this.UpdateList()
;     }

;     UpdateList() {
;         searchTerm := this.searchBox.Value
;         filteredItems := []

;         for item in this.data {
;             if (RegExMatch(item, "i)" . searchTerm)) {
;                 filteredItems.Push(item)
;             }
;         }

;         this.listBox.Delete()
;         this.listBox.Add(filteredItems)
;     }

;     SelectItem() {
;         if (selected := this.listBox.Text) {
;             MsgBox("Selected: " . selected)
;             this.gui.Destroy()
;         }
;     }

;     OnResize() {
;         if (this.gui.Pos.w = 320 or this.gui.Pos.h = 240) {
;             return
;         }

;         ctrlWidth := this.gui.Pos.w - 20
;         listHeight := this.gui.Pos.h - 120

;         this.searchBox.Move(,, ctrlWidth)
;         this.listBox.Move(,, ctrlWidth, listHeight)
;     }
; }

; ; Example usage
; #HotIf WinActive(A_ScriptName)
; F1:: {
;     data := [
;         "Apple", "Banana", "Cherry", "Date", "Elderberry",
;         "Fig", "Grape", "Honeydew", "Kiwi", "Lemon",
;         "Mango", "Nectarine", "Orange", "Papaya", "Quince"
;     ]
;     AutoCompleteGUI.Create(data)
; }

class AutoCompleteGui extends Gui {
	__New(suggestions := [], minChars := 1, triggerString := "") {
		super.__New("+AlwaysOnTop -Caption +ToolWindow")
		this.suggestions := this.ProcessSuggestions(suggestions)
		this.minChars := minChars
		this.triggerString := triggerString
		this.CreateGui()
	}

	ProcessSuggestions(input) {
		result := []
		if IsObject(input) {
			if Type(input) is Array {
				for item in input {
					result.Push(this.ProcessSuggestions(item)*)
				}
			} else if Type(input) is Map || Type(input) is Object {
				for key, value in input {
					result.Push(IsObject(value) ? key : value)
				}
			}
		} else if Type(input) == "String" {
			result := StrSplit(input, "`n", "`r")
		}
		return result
	}

	CreateGui() {
		this.listBox := this.Add("ListBox", "w200 r10 vSuggestionList")
		this.listBox.OnEvent("DoubleClick", (*) => this.SelectSuggestion())
		this.OnEvent("Close", (*) => this.Hide())
		this.OnEvent("Escape", (*) => this.Hide())
	}

	Show(input, x, y) {
		filteredSuggestions := this.FilterSuggestions(input)
		this.listBox.Delete()
		this.listBox.Add(filteredSuggestions)
		super.Show(Format("x{1} y{2} AutoSize NoActivate", x, y))
	}

	FilterSuggestions(input) {
		filteredList := []
		for suggestion in this.suggestions {
			distance := String2.DamerauLevenshteinDistance(input, SubStr(suggestion, 1, StrLen(input)))
			if (distance <= 2) {  ; Adjust this threshold as needed
				filteredList.Push(suggestion)
			}
		}
		return filteredList
	}

	SelectSuggestion() {
		if (selected := this.listBox.Text) {
			if this.targetHwnd {
				ControlSetText(selected, "ahk_id " this.targetHwnd)
			}
			this.Hide()
		}
	}

	ConnectTo(controlObj) {
		this.targetHwnd := controlObj.Hwnd
		controlObj.OnEvent("Change", (*) => this.OnInputChange(controlObj))
	}

	OnInputChange(controlObj) {
		text := controlObj.Text
		if (StrLen(text) >= this.minChars) &&
			(this.triggerString == "" || InStr(text, this.triggerString) == 1) {
			controlPos := controlObj.Pos
			this.Show(text, controlPos.X, controlPos.Y + controlPos.H)
		} else {
			this.Hide()
		}
	}

	DemoAutoComplete() {
		demoGui := Gui("+AlwaysOnTop +Resize", "AutoComplete Demo")
		demoGui.SetFont("s10", "Segoe UI")
		edit := demoGui.Add("Edit", "w300 vInputField")
		this.ConnectTo(edit)
		demoGui.Add("Text", "xm y+10", "Type to see suggestions. Press Shift+Enter to submit.")
		demoGui.OnEvent("Close", (*) => ExitApp())
		demoGui.Show()

		HotIf(*) => WinActive("AutoComplete Demo")
		Hotkey("+Enter", (*) => this.ProcessInput(demoGui))
	}

	ProcessInput(demoGui) {
		if submitValue := demoGui.Submit()["InputField"] {
			MsgBox("You selected: " submitValue)
		}
	}

	AddListObj(newSuggestions) {
		this.suggestions.Push(this.ProcessSuggestions(newSuggestions)*)
	}
}

; ; Create an instance of AutoCompleteGui with custom settings
; ac := AutoCompleteGui(, 2, "dsp.")  ; Show suggestions after 2 chars, and only if input starts with "dsp."

; ; Add suggestions from various sources
; ac.AddListObj(["apple", "banana", "cherry"])
; ; ac.AddListObj({car: "Ford", bike: "Trek"})
; ac.AddListObj(Map("color", "red", "shape", "circle"))
; ac.AddListObj("dog`ncat`nfish")

; ; Run the demo
; ac.DemoAutoComplete()

/**
	* Enhanced message box with rich text support using Gui2.AddRichEdit
	*/
/**
	* Enhanced message box with rich text support using Gui2.AddRichEdit
	*/
class RTFMsgBox {
	static Instances := Map()
	static InstanceCount := 0  ; Add counter for debugging
	
	; Default settings
	DefaultSettings := {
		Width: 400,
		MinHeight: 150,
		MaxHeight: 600,
		ButtonHeight: 30,
		MarginX: 20,
		MarginY: 15,
		Font: {
			Name: "Segoe UI",
			Size: 10
		},
		Colors: {
			Background: 0xFFFFFF,
			Text: 0x000000,
			Button: 0xF0F0F0
		}
	}

	; static rtfgui := this.rtfgui

	__New(text, title := "", options := "", owner := "") {

		; Debug output
		RTFMsgBox.InstanceCount += 1

		OutputDebug("RTFMsgBox instance created. Count: " RTFMsgBox.InstanceCount "`n")
		OutputDebug("Call stack: `n" debug_getCallStack() "`n")

		MB_TYPES := Map(
			"OK", ["OK"],
			"OKCancel", ["OK", "Cancel"],
			"YesNo", ["Yes", "No"],
			"YesNoCancel", ["Yes", "No", "Cancel"],
			"RetryCancel", ["Retry", "Cancel"],
			"AbortRetryIgnore", ["Abort", "Retry", "Ignore"]
		)

		; Create GUI
		title := (title ? title : "RTFMsgBox_" RTFMsgBox.InstanceCount)
		this.rtfGui := Gui("+Owner" (owner ? owner : "") " +AlwaysOnTop -MinimizeBox")
		this.rtfGui.Title := title
		this.rtfGui.BackColor := this.DefaultSettings.Colors.Background
		this.rtfGui.SetFont("s" this.DefaultSettings.Font.Size, this.DefaultSettings.Font.Name)

		; Parse options
		buttons := MB_TYPES["OK"]  ; Default buttons
		for type, btnSet in MB_TYPES {
			if InStr(options, type) {
				buttons := btnSet
				break
			}
		}

		; Calculate dimensions
		margin := this.DefaultSettings.MarginX
		width := this.DefaultSettings.Width
		editWidth := width - 2*margin

		; Add RichEdit using the enhanced method
		reOptions := Format("x{1} y{2} w{3} h{4}", 
			margin,
			margin,
			editWidth,
			this.DefaultSettings.MinHeight
		)
		
		this.RE := this.rtfGui.AddRichEdit(,reOptions, text)
		this.RE.ReadOnly := true

		; Calculate heights
		textHeight := min(max(10, this.DefaultSettings.MinHeight), this.DefaultSettings.MaxHeight)

		; Add buttons
		buttonY := textHeight + margin
		buttonWidth := (width - (buttons.Length + 1)*margin) / buttons.Length
		
		for i, buttonText in buttons {
			x := margin + (i-1)*(buttonWidth + margin)
			btn := this.rtfGui.AddButton(Format("x{1} y{2} w{3} h{4}",
				x, buttonY, buttonWidth, this.DefaultSettings.ButtonHeight),
				buttonText)
			btn.OnEvent("Click", this.ButtonClick.Bind(this))
		}

		; Set up result storage
		this.Result := ""

		; Calculate final height
		height := buttonY + this.DefaultSettings.ButtonHeight + margin

		; Set window title
		this.rtfGui.Title := title

		; ; Store instance
		; RTFMsgBox.Instances[this.rtfGui.Hwnd] := this
		
		; Store instance with the unique identifier
		RTFMsgBox.Instances[this.rtfGui.Hwnd] := {
			instance: this,
			createTime: A_TickCount
		}

		; Show the window and return immediately if we already have another instance waiting
		if (RTFMsgBox.InstanceCount > 1) {
			OutputDebug("Multiple RTFMsgBox instances detected - check for duplicate calls`n")
		}

		; Show the window
		this.rtfGui.Show(Format("w{1} h{2} Center", width, height))

		; Wait for result
		while !this.Result {
			Sleep(10)
		}

		return this.Result
		; return this
	}

	_Cleanup() {
		RTFMsgBox.InstanceCount--
		RTFMsgBox.Instances.Delete(this.rtfGui.Hwnd)
		OutputDebug("RTFMsgBox instance destroyed. Remaining count: " RTFMsgBox.InstanceCount "`n")
	}

	ButtonClick(GuiCtrl, *) {
		this.Result := GuiCtrl.Text
		this.rtfGui.Destroy()
	}

	static Show(text, title := "", options := "", owner := "") {
		return RTFMsgBox(text, title, options, owner)
	}
}

; Helper function to get call stack for debugging
debug_getCallStack() {
	stack := ""
	try {
		loop 10 {
			if (ex := Error("", -A_Index)) {
				stack .= Format("  Line {1}: {2}`n", ex.Line, ex.What)
			}
		}
	}
	return stack || "No call stack available`n"
}

; Helper function - modified to add debug info
MsgRTFBox(text, title := "", options := "YesNoCancel", owner := "") {
	Infos("MsgRTFBox called`n")
	return RTFMsgBox.Show(text, title, options, owner || A_ScriptHwnd)
}
