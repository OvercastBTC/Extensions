; #Requires AutoHotkey v2+
#Include <Includes/Basic>

;@class Gui2
Gui.Prototype.Base := Gui2

class Gui2 {

	#Requires AutoHotkey v2+

	static WS_EX_NOACTIVATE 	:= '0x08000000L'
	static WS_EX_TRANSPARENT 	:= '0x00000020L'
	static WS_EX_COMPOSITED 	:= '0x02000000L'
	static WS_EX_CLIENTEDGE 	:= '0x00000200L'
	static WS_EX_APPWINDOW 		:= '0x00040000L'
	static WS_EX_LAYERED      	:= '0x00080000L'  ; Layered window for transparency
	static WS_EX_TOOLWINDOW   	:= '0x00000080L'  ; Creates a tool window (no taskbar button)
	static WS_EX_TOPMOST      	:= '0x00000008L'  ; Always on top
	static WS_EX_ACCEPTFILES  	:= '0x00000010L'  ; Accepts drag-drop files
	static WS_EX_CONTEXTHELP  	:= '0x00000400L'  ; Has '?' button in titlebar


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

	static Layered() {
		this.MakeLayered()
		return this
	}
	
	static ToolWindow() {
		this.MakeToolWindow()
		return this
	}
	
	static AlwaysOnTop() {
		this.SetAlwaysOnTop()
		return this
	}
	
	static AppWindow() {
		this.ForceTaskbarButton()
		return this
	}
	
	static Transparent() {
		this.MakeClickThrough()
		return this
	}
	
	static NoActivate() {
		this.PreventActivation()
		return this
	}
	
	static NeverFocusWindow() {
		this.NoActivate()
		return this
	}

	;; @method static DarkMode(params*)
	static DarkMode(params*) {
		; Initialize with default values
		; static DEFAULT_COLOR := '0x1E1E1E'  ; Dark gray
		static DEFAULT_COLOR := StrReplace(StrLower(GuiColors.VSCode.Selection), '#', '')
		static TEXT_COLOR := StrReplace(StrLower(GuiColors.VSCode.TextNormal), '#', '')
		guiObj := this  ; Default to 'this' if no Gui passed
		color := DEFAULT_COLOR  ; Start with default color
		tColor := TEXT_COLOR
		
		; Parse parameters
		for param in params {
			if (param is Gui) {
				guiObj := param  ; Store Gui object
			} else if IsObject(param) && param.HasProp("BackColor") {
				color := param.BackColor  ; Use color from object
			} else if param is String || param is Integer {
				; Convert integer to hex string if needed
				color := param is Integer ? Format('0x{:06X}', param) : param
				; Ensure hex format
				if !InStr(color, "0x || #") && RegExMatch(color, "^[0-9A-Fa-f]+$") {
					(color ~= '#') ? StrReplace(color, '#', '') :
					color := "0x" color
				}
			}
		}
		
		; Apply color if we have a valid Gui
		if (guiObj is Gui) {
			try {
				guiObj.BackColor := color
				guiObj.SetFont(tColor)
			} catch Error as e {
				; Fallback to default color on error
				guiObj.BackColor := DEFAULT_COLOR
				guiObj.SetFont('cd4d4d4')
			}
		}

		return guiObj  ; Return for method chaining
	}
	; ---------------------------------------------------------------------------

	/**
	 * @description Improves font settings with reasonable defaults and parameter parsing
	 * @param {String} options Optional font settings string containing:
	 *                        - Font size: "s12" or just "12"
	 *                        - Quality: "Q5" (0-5)
	 *                        - Color: "cFF0000" or "c0xFF0000"
	 * @param {String} nFont Optional font name (default: "Consolas")
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * ; Using defaults (s12 Q5 c1eff00 Consolas)
	 * gui.MakeFontNicer()
	 * 
	 * ; Setting just size
	 * gui.MakeFontNicer("14")             
	 * 
	 * ; Size and quality
	 * gui.MakeFontNicer("s16 Q4")         
	 * 
	 * ; Full specification
	 * gui.MakeFontNicer("s12 Q5 cFF0000") 
	 * 
	 * ; Different font
	 * gui.MakeFontNicer("s10", "Arial")   
	 */

	static MakeFontNicer(params*) {
		; Initialize config with defaults
		config := {
			size: 20,
			quality: 'Q5', 
			; color: 'cBlue',
			color: StrReplace(GuiColors.VSCode.TextNormal, '#', '0x'),
			fontName: 'Consolas',
			guiObj: this
		}

		static hexNeedle := '\b[\w\d]+\b'

		; Parse parameters
		for param in params {
			; Handle Gui object parameter
			if param is Gui {
				config.guiObj := param
				continue
			}

			; Handle string parameters
			if param is String {
				; Font size with 's' prefix
				if param ~= 'i)^s[\d]+' {
					config.size := SubStr(param, 2)
					continue
				}

				; Font size without prefix
				if param ~= 'i)([^q])[\d]+' || param ~= '^[\d]+' {
					config.size := param
					continue
				}

				; Quality setting
				if param ~= 'i)^q[\d]+' {
					config.quality := param
					continue 
				}

				; Color handling
				if param ~= 'i)^c[\w\d]+' || param ~= hexNeedle {
					; Check GuiColors first
					if GuiColors.mColors.Has(StrLower(param))
						config.color := 'c' GuiColors.mColors[StrLower(param)]
					else
						config.color := param ~= '^c' ? param : 'c' param
					continue
				}

				; Font name
				if param ~= '^[a-zA-Z][\w\s-]*$' {
					config.fontName := param
				}
			}
		}

		; Apply font settings
		try {
			config.guiObj.SetFont('s' config.size ' ' config.quality ' ' config.color, config.fontName)
		} catch Error as e {
			; Suppress errors but optionally log them
			ErrorLogger.Log("Font setting failed: " e.Message)
		}

		return config.guiObj
	}

	
	/**
	 * @description Prevents window from receiving focus or being activated
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.NoActivate()
	*/
	static PreventActivation() {
		WinSetExStyle('+' this.WS_EX_NOACTIVATE, this)
		return this
	}

	; static NeverFocusWindow(guiObj := this) {
	; static NeverFocusWindow() {
	; 	; guiObj := guiObj ? guiObj : this
	; 	; WinSetExStyle('+' this.NOACTIVATE, guiObj)
	; 	WinSetExStyle('+' this.WS_EX_NOACTIVATE, this)
	; 	; WinSetExStyle('+' . this.TRANSPARENT, guiObj)
	; 	; WinSetExStyle('+' . this.COMPOSITED, guiObj)
	; 	; WinSetExStyle('+' . this.CLIENTEDGE, guiObj)
	; 	; WinSetExStyle('+' . this.APPWINDOW, guiObj)
	; 	; return guiObj
	; 	return this
	; }

	/**
	 * @description Makes window click-through (input passes to windows beneath)
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.MakeClickThrough()
	 */
	static MakeClickThrough() {
		WinSetExStyle('+' this.WS_EX_TRANSPARENT, this)
		return this
	}

	; static MakeClickThrough(guiObj := this) {
	; 	if (guiObj is Gui){
	; 		; WinSetTransparent(255, guiObj)
	; 		WinSetTransparent(255, this)
	; 		guiObj.Opt('+E0x20')
	; 	}
	; 	return this
	; }

	/**
	 * @description Enables double-buffered composited window rendering
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.EnableComposited()
	 */
	static EnableComposited() {
		WinSetExStyle('+' this.WS_EX_COMPOSITED, this)
		return this
	}

	/**
	 * @description Adds 3D sunken edge border to window
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.AddClientEdge()
	 */
	static AddClientEdge() {
		WinSetExStyle('+' this.WS_EX_CLIENTEDGE, this)
		return this
	}

	/**
	 * @description Forces window to have a taskbar button
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.ForceTaskbarButton()
	 */
	static ForceTaskbarButton() {
		WinSetExStyle('+' this.WS_EX_APPWINDOW, this)
		return this
	}

	/**
	 * @description Makes window layered for transparency effects
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.MakeLayered()
	 */
	static MakeLayered() {
		WinSetExStyle('+' this.WS_EX_LAYERED, this)
		return this
	}

	/**
	 * @description Creates a tool window with no taskbar button
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.MakeToolWindow()
	 */
	static MakeToolWindow() {
		WinSetExStyle('+' this.WS_EX_TOOLWINDOW, this)
		return this
	}

	/**
	 * @description Sets window to always stay on top
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.SetAlwaysOnTop()
	 */
	static SetAlwaysOnTop() {
		WinSetExStyle('+' this.WS_EX_TOPMOST, this)
		return this
	}

	/**
	 * @description Enables drag and drop file acceptance
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.EnableDragDrop()
	 */
	static EnableDragDrop() {
		WinSetExStyle('+' this.WS_EX_ACCEPTFILES, this)
		return this
	}

	/**
	 * @description Adds help button (?) to titlebar
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.AddHelpButton()
	 */
	static AddHelpButton() {
		WinSetExStyle('+' this.WS_EX_CONTEXTHELP, this)
		return this
	}

	/**
	 * @description Sets window transparency level
	 * @param {Integer} level Transparency level (0-255, where 0 is invisible and 255 is opaque)
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.SetTransparency(180)  ; Set to 70% opacity
	 */
	static SetTransparency(level := 255) {
		if (level < 0 || level > 255)
			throw ValueError("Transparency level must be between 0 and 255")
		
		this.MakeLayered()  ; Window must be layered for transparency
		WinSetTransparent(level, this)
		return this
	}

	; static SetButtonWidth(input, bMargin := 1.5) {
	; 	return GuiButtonProperties.SetButtonWidth(input, bMargin)
	; }

	/**
	 * @description Creates an overlay window combining multiple styles
	 * @param {Object} options Window style options
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.CreateOverlay({
	*    transparency: 200,
	*    clickThrough: true,
	*    alwaysOnTop: true
	* })
	*/
	static CreateOverlay(options := {}) {

		this.NoActivate()

		if (options.HasProp("transparency")){
			this.SetTransparency(options.transparency)
		}
		if (options.Get("clickThrough", false)){
			this.MakeClickThrough()
		}
		if (options.Get("alwaysOnTop", true)){
			this.SetAlwaysOnTop()
		}
		if (options.Get("composited", true)){
			this.EnableComposited()
		}

		return this
	}

	/**
	 * @description Creates a floating toolbar window
	 * @param {Object} options Window style options
	 * @returns {Gui} The Gui object for method chaining
	 * @example
	 * gui.CreateToolbar({
	*    alwaysOnTop: true,
	*    dropShadow: true
	* })
	*/
	static CreateToolbar(options := {}) {
		
		this.MakeToolWindow()
		
		if (options.Get("alwaysOnTop", true)){
			this.SetAlwaysOnTop()
		}
		if (options.Get("acceptFiles", false)){
			this.EnableDragDrop()
		}
		if (options.Get("dropShadow", true)){
			this.AddClientEdge()
		}

		return this
	}

	static SetButtonWidth(params*) {
		input := bMargin := ''
		
		; Parse parameters
		for i, param in params {
			if (i = 1) {
				input := param
			}
			else if (i = 2) {
				bMargin := param
			}
		}
		
		; Set default margin if not provided
		bMargin := bMargin ? bMargin : 1.5
		
		return GuiButtonProperties.SetButtonWidth(input, bMargin)
	}

	; static SetButtonHeight(rows := 1, vMargin := 1.2) {
	; 	return GuiButtonProperties.SetButtonHeight(rows, vMargin)
	; }

	static SetButtonHeight(params*) {
		rows := vMargin := ''
		
		; Parse parameters
		for i, param in params {
			if (i = 1)
				rows := param
			else if (i = 2)
				vMargin := param
		}
		
		; Set defaults if not provided
		rows := rows ? rows : 1
		vMargin := vMargin ? vMargin : 1.2
		
		return GuiButtonProperties.SetButtonHeight(rows, vMargin)
	}

	static GetButtonDimensions(text, options := {}) {
		return GuiButtonProperties.GetButtonDimensions(text, options)
	}

	static GetOptimalButtonLayout(totalButtons, containerWidth, containerHeight) {
		return GuiButtonProperties.GetOptimalButtonLayout(totalButtons, containerWidth, containerHeight)
	}

	static _AddButtonGroup(guiObj, buttonOptions, labelObj, groupOptions := '', columns := 1) {
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
			
			btnWidth := this.SetButtonWidth(labelObj)
			btnHeight := this.SetButtonHeight()
			
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

	static AddButtonGroup(params*) {
		; Initialize default values
		config := {
			guiObj: '',
			buttonOptions: '',
			labelObj: '',
			groupOptions: '',
			columns: 1
		}
		
		; Parse parameters
		for i, param in params {
			if (param is Gui)
				config.guiObj := param
			else if (i = 2)
				config.buttonOptions := param
			else if (Type(param) = "String" && InStr(param, "x") || InStr(param, "y"))
				config.groupOptions := param
			else if (Type(param) = "Array" || Type(param) = "String")
				config.labelObj := param
			else if (Type(param) = "Integer")
				config.columns := param
		}
		
		; Call original implementation with parsed parameters
		return this._AddButtonGroup(config.guiObj, config.buttonOptions, config.labelObj, config.groupOptions, config.columns)
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
		
		; Create RichEdit control
		reObj := RichEdit(this, options)
		reObj.SetFont({Name: "Times New Roman", Size: 9})
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
		; Call AddRichEdit and return its result
		return this.AddRichEdit(options, text)
	}
	
	/**
	 * Extension method for Gui class - alternate name for AddRichEdit
	 * @param {String} options Control options 
	 * @param {String} text Initial text
	 * @returns {RichEdit} The created RichEdit control
	 */
	static AddRichTextEdit(options := "", text := "") {
		; Call AddRichEdit and return its result 
		return this.AddRichEdit(options, text)
	}

	/**
	 * @description Add a rich text control (simpler version of RichEdit)
	 * @param {String} options Control options
	 * @param {String} text Initial text content
	 * @returns {RichEdit} The created RichEdit control
	 */
	static AddRichText(options := "", text := "") {
		; Default size if not specified
		if !RegExMatch(options, "w\d+") {
			options := "w400 " options
		}
	
		; Create RichEdit with simplified settings
		reObj := RichEdit(this, options)
	
		; Configure for basic text display
		reObj.SetOptions([
			"READONLY",          ; Make it read-only like Text control
			"-HSCROLL",         ; Disable horizontal scrollbar
			"-VSCROLL",         ; Disable vertical scrollbar
			"MULTILINE",        ; Allow multiple lines like Text
			"SELECTIONBAR"      ; Enable selection bar
		])
	
		; Set initial text if provided
		if (text != "") {
			reObj.SetText(text)
		}
	
		return reObj
	}

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
}
; ---------------------------------------------------------------------------
;@endregion class Gui2

;@region CheckBoxManager
class CheckBoxManager {
	/************************************************************************
	* @description Stores found checkboxes and their states
	***********************************************************************/
	checkboxes := []
	currentIndex := 0

	/************************************************************************
	* @description Find and cache all checkboxes on the page
	* @example checkboxManager.FindAllCheckboxes()
	***********************************************************************/
	FindAllCheckboxes() {
		this.checkboxes := []
		try {
			expRpt := UIA.ElementFromChromium(' - Google Chrome')
			if !expRpt
				throw Error("Chrome window not found")
			
			; Find all checkboxes
			; foundBoxes := expRpt.FindAll({Type: '50002', LocalizedType: "check box"})
			foundBoxes := expRpt.FindAll({LocalizedType: "check box"})
			for box in foundBoxes{
				this.checkboxes.Push(box)
			}
			return this.checkboxes.Length
		} catch Error as e {
			throw Error("Failed to find checkboxes: " e.Message)
		}
	}

	/************************************************************************
	* @description Process the next unchecked checkbox in the list
	* @example checkboxManager.ProcessNextCheckbox()
	***********************************************************************/
	ProcessNextCheckbox() {
		if (this.checkboxes.Length = 0)
			this.FindAllCheckboxes()
		
		if (this.checkboxes.Length = 0)
			throw Error("No checkboxes found")
		
		loop this.checkboxes.Length {
			this.currentIndex++
			if (this.currentIndex > this.checkboxes.Length)
				this.currentIndex := 1
			
			currentBox := this.checkboxes[this.currentIndex]
			if (!this.IsCheckboxChecked(currentBox)) {
				this.FocusAndCheck(currentBox)
				return true
			}
		}
		
		return false ; No unchecked boxes found
	}

	/************************************************************************
	* @description Check if a checkbox is currently checked
	* @example if !checkboxManager.IsCheckboxChecked(checkbox)
	***********************************************************************/
	IsCheckboxChecked(checkbox) {
		try {
			return checkbox.GetPropertyValue(UIA.Property.ToggleToggleState)
		} catch {
			return false
		}
	}

	/************************************************************************
	* @description Focus on a checkbox and check it
	* @example checkboxManager.FocusAndCheck(checkbox)
	***********************************************************************/
	FocusAndCheck(checkbox) {
		try {
			checkbox.ScrollIntoView()
			Sleep(100)  ; Give UI time to update
			checkbox.SetFocus()
			Sleep(100)
			
			if (!this.IsCheckboxChecked(checkbox))
				checkbox.Click()
			
			return true
		} catch Error as e {
			throw Error("Failed to check checkbox: " e.Message)
		}
	}
}
; ---------------------------------------------------------------------------
;@endregion
; ---------------------------------------------------------------------------
;@region DisplaySettings
/**
 * @class DisplaySettings
 * @description Manages display settings for various GUI elements
 */
class DisplaySettings {
	; Store all settings maps
	static Settings := Map(
		"Base", {
			; Common base settings for all displays
			Font: {
				Name: "Consolas",
				Size: 10,
				Quality: 5,
				Color: "cBlue"
			},
			Colors: {
				Background: "cBlack",
				Text: '#000000'
			},
			Styles: "+AlwaysOnTop -Caption +ToolWindow",
			Margins: {
				X: 0,
				Y: 0
			},
			Grid: {
				Enabled: true,
				Columns: 3,
				Rows: 10,
				Spacing: 10
			}
		},
		"Infos", {
			; Infos-specific settings
			Font: {
				Size: 8,
				Quality: 5
			},
			Metrics: {
				Distance: 4,
				Unit: A_ScreenDPI / 144
			},
			Position: {
				Mode: "Grid",  ; "Grid", "Fixed", "Center"
				Column: 1,     ; Single column for traditional Infos
				MaxRows: Floor(A_ScreenHeight / (8 * (A_ScreenDPI / 144) * 4))
			},
			Limits: {
				MaxNumberedHotkeys: 12,
				MaxWidthInChars: 110
			}
		},
		"CleanInputBox", {
			; CleanInputBox-specific settings
			Size: {
				Width: Round(A_ScreenWidth / 3),
				MinHeight: 30
			},
			Position: {
				Mode: "Center",
				TopMargin: Round(A_ScreenHeight / 1080 * 800)
			},
			Font: {
				Size: 12
			},
			Input: {
				MinChars: 2,
				MaxMatches: 5,
				ShowMatchList: true
			}
		},
		"InputBox", {
			; Future InputBox-specific settings
			Size: {
				Width: Round(A_ScreenWidth / 4),
				Height: "Auto"
			},
			Position: {
				Mode: "Fixed",
				X: 100,
				Y: 100
			},
			Font: {
				Size: 11
			}
		}
	)

	/**
	 * Get settings for a specific display type
	 * @param {String} type The display type ("Infos", "CleanInputBox", etc)
	 * @returns {Object} Merged settings
	 */
	static GetSettings(type) {
		; Start with base settings
		mergedSettings := this.CloneMap(this.Settings["Base"])
		
		; Merge with type-specific settings if they exist
		if (this.Settings.Has(type)) {
			mergedSettings := this.MergeSettings(mergedSettings, this.Settings[type])
		}

		return mergedSettings
	}

	/**
	 * Update settings for a display type
	 * @param {String} type The display type
	 * @param {Object} newSettings New settings to apply
	 */
	static UpdateSettings(type, newSettings) {
		if (this.Settings.Has(type)) {
			this.Settings[type] := this.MergeSettings(this.Settings[type], newSettings)
		} else {
			this.Settings[type] := newSettings
		}
	}

	/**
	 * Deep clone a Map or Object
	 * @param {Map|Object} source Source to clone
	 * @returns {Map|Object} Cloned copy
	 */
	static CloneMap(source) {
		if (Type(source) = "Map") {
			result := Map()
			for key, value in source {
				result[key] := IsObject(value) ? this.CloneMap(value) : value
			}
			return result
		} else if (IsObject(source)) {
			result := {}
			for key, value in source.OwnProps() {
				result.%key% := IsObject(value) ? this.CloneMap(value) : value
			}
			return result
		}
		return source
	}

	/**
	 * Deep merge settings objects
	 * @param {Object} target Target object
	 * @param {Object} source Source object
	 * @returns {Object} Merged result
	 */
	static MergeSettings(target, source) {
		result := this.CloneMap(target)
		
		if (Type(source) = "Map") {
			for key, value in source {
				if (Type(value) = "Map" || IsObject(value)) {
					if (result.Has(key)) {
						result[key] := this.MergeSettings(result[key], value)
					} else {
						result[key] := this.CloneMap(value)
					}
				} else {
					result[key] := value
				}
			}
		} else if (IsObject(source)) {
			for key, value in source.OwnProps() {
				if (IsObject(value)) {
					if (result.HasProp(key)) {
						result.%key% := this.MergeSettings(result.%key%, value)
					} else {
						result.%key% := this.CloneMap(value)
					}
				} else {
					result.%key% := value
				}
			}
		}
		
		return result
	}

	/**
	 * Calculate derived settings (those that depend on other settings)
	 * @param {String} type Display type
	 * @param {Object} settings Base settings object
	 * @returns {Object} Settings with calculated values
	 */
	static CalculateDerivedSettings(type, settings) {
		derived := this.CloneMap(settings)
		
		switch type {
			case "Infos":
				; Calculate GUI width based on font metrics
				derived.guiWidth := derived.Font.Size 
					* derived.Metrics.Unit 
					* derived.Metrics.Distance
				
				; Calculate maximum instances based on screen height
				derived.maxInstances := Floor(A_ScreenHeight / derived.guiWidth)
				
			case "CleanInputBox":
				; Calculate centered position
				derived.Position.X := (A_ScreenWidth - derived.Size.Width) / 2
				derived.Position.Y := derived.Position.TopMargin
		}
		
		return derived
	}
}
; ---------------------------------------------------------------------------
/**
 * @class InfoBox
 * @description Base class for creating positioned info boxes with grid support
 */

/**
 * @class InfoBox
 * @description Core GUI creation and management functionality
 */
class InfoBox {
	static Instances := Map()
	static Grid := Map()

	__New(settings) {
		this.settings := settings
		; this.InitializeGrid()
		this.position := this.GetPosition()
		
		if (!this.position) {
			return
		}

		this.gui := Gui(this.settings.Styles)
		this.SetupGui()
		InfoBox.Instances[this.gui.Hwnd] := this
	}

	InitializeGrid() {
		if (this.settings.Position.Mode = "Grid") {
			gridId := this.settings.Grid.ID

			; Initialize grid if not exists
			if (!InfoBox.Grid.Has(gridId)) {
				InfoBox.Grid[gridId] := Array(this.settings.Grid.Rows)
				loop this.settings.Grid.Rows {
					row := A_Index
					InfoBox.Grid[gridId][row] := Array(this.settings.Grid.Columns)
					loop this.settings.Grid.Columns {
						InfoBox.Grid[gridId][row][A_Index] := false
					}
				}
			}
		}
	}

	SetupGui() {
		; Apply base settings
		this.gui.MarginX := this.settings.Margins.X
		this.gui.MarginY := this.settings.Margins.Y
		this.gui.BackColor := this.settings.Colors.Background

		; Set font
		this.gui.SetFont(
			"s" this.settings.Font.Size " q" this.settings.Font.Quality 
			" " this.settings.Font.Color,
			this.settings.Font.Name
		)
	}

	AddControl(type, options, text := "") {
		control := this.gui.Add(type, options, text)
		return control
	}

	GetPosition() {
		; if (this.settings.Position.Mode = "Grid") {
		; 	return this.GetGridPosition()
		; } else if (this.settings.Position.Mode = "Center") {
		; 	return this.GetCenteredPosition()
		; }
		; return {
		; 	x: this.settings.Position.X,
		; 	y: this.settings.Position.Y,
		; 	row: 0,
		; 	col: 0
		; }
		return this.GetCenteredPosition()
	}

	GetGridPosition() {
		gridId := this.settings.Grid.ID
		grid := InfoBox.Grid[gridId]
		
		loop this.settings.Grid.Rows {
			row := A_Index
			loop this.settings.Grid.Columns {
				col := A_Index
				if (!grid[row][col]) {
					grid[row][col] := true
					return {
						x: (col - 1) * (this.settings.Size.Width + this.settings.Grid.Spacing),
						y: (row - 1) * (this.settings.Size.Height + this.settings.Grid.Spacing),
						row: row,
						col: col
					}
				}
			}
		}
		return false
	}

	GetCenteredPosition() {
		return {
			x: (A_ScreenWidth - this.settings.Size.Width) / 2,
			y: this.settings.Position.HasProp("TopMargin") ? this.settings.Position.TopMargin : (A_ScreenHeight / 3),
			row: 0,
			col: 0
		}
	}

	Show(options := "") {
		if (this.position) {
			showOptions := options ? options 
				: Format("x{1} y{2} AutoSize", this.position.x, this.position.y)
			this.gui.Show(showOptions)
		}
	}

	Hide() {
		this.gui.Hide()
	}

	Destroy() {
		; Release grid position if using grid
		if (this.position && this.settings.Position.Mode = "Grid") {
			gridId := this.settings.Grid.ID
			InfoBox.Grid[gridId][this.position.row][this.position.col] := false
		}

		; Remove from instances
		InfoBox.Instances.Delete(this.gui.Hwnd)
		
		; Destroy GUI
		this.gui.Destroy()
	}

	static DestroyAll() {
		for hwnd, instance in InfoBox.Instances.Clone() {
			instance.Destroy()
		}
	}
}
; ---------------------------------------------------------------------------

; Info(text, timeout?) => Infos(text, timeout ?? 2000)
Info(text, timeout?) => Infos(text, timeout ?? 10000)

/**
 * @class UnifiedDisplayManager
 * @description Manages stacked GUI displays with consistent positioning and styling
 * @version 1.0.0
 * @date 2024/02/16
 */
class UnifiedDisplayManager {
	; Static properties for display configuration
	static Instances := Map()
	static InstanceCount := 0
	static DefaultSettings := {
		Width: Round(A_ScreenWidth / 3),
		TopMargin: Round(A_ScreenHeight / 2),
		StackMargin: 30,
		Styles: "+AlwaysOnTop -Caption +ToolWindow",
		Font: {
			Name: "Consolas",
			Size: 10,
			Quality: 5
		},
		Colors: {
			Background: "#0x161821",
			Text: "cBlue"
		}
	}

	; Instance properties
	Gui := ""
	Input := ""
	IsWaiting := true
	Settings := Map()
	Controls := Map()

	/**
	 * @constructor
	 * @param {Object} options Configuration options
	 */
	__New(options := {}) {
		this.InitializeSettings(options)
		this.CreateGui()
		UnifiedDisplayManager.InstanceCount++
		UnifiedDisplayManager.Instances[this.Gui.Hwnd] := this
	}

	InitializeSettings(options) {
		; Merge provided options with defaults
		this.Settings := UnifiedDisplayManager.DefaultSettings.Clone()
		for key, value in options.OwnProps() {
			if IsObject(this.Settings.%key%) && IsObject(value)
				this.Settings.%key% := this.MergeObjects(this.Settings.%key%, value)
			else
				this.Settings.%key% := value
		}
	}

	MergeObjects(target, source) {
		for key, value in source.OwnProps() {
			if IsObject(value) && IsObject(target.%key%)
				target.%key% := this.MergeObjects(target.%key%, value)
			else
				target.%key% := value
		}
		return target
	}

	CreateGui() {
		; Create base GUI with specified styles
		this.Gui := Gui(this.Settings.Styles)
		this.Gui.BackColor := this.Settings.Colors.Background
		this.Gui.SetFont("s" this.Settings.Font.Size " q" this.Settings.Font.Quality,
						this.Settings.Font.Name)

		; Setup default GUI events
		this.Gui.OnEvent("Close", (*) => this.Destroy())
		this.Gui.OnEvent("Escape", (*) => this.Destroy())
	}

	AddControl(type, options, text := "") {
		control := this.Gui.Add(type, options, text)
		this.Controls[control.Hwnd] := control
		return control
	}

	AddEdit(options := "", text := "") {
		return this.AddControl("Edit", "x0 Center -E0x200 Background" this.Settings.Colors.Background 
			" w" this.Settings.Width " " options, text)
	}

	AddComboBox(options := "", items := "") {
		if IsObject(items) {
			items := this.ProcessItems(items)
		}
		return this.AddControl("ComboBox", "x0 Center w" this.Settings.Width " " options, items)
	}

	ProcessItems(items) {
		result := []
		if Type(items) = "Array"
			result := items
		else if Type(items) = "Map" || Type(items) = "Object"
			for key, value in items
				result.Push(IsObject(value) ? key : value)
		return result
	}

	Show(params := "") {
		defaultPos := "y" this.CalculateYPosition() " w" this.Settings.Width
		this.Gui.Show(params ? params : defaultPos)
	}

	CalculateYPosition() {
		basePos := this.Settings.TopMargin
		stackOffset := (UnifiedDisplayManager.InstanceCount - 1) * this.Settings.StackMargin
		return basePos + stackOffset
	}

	/**
		* @method WaitForInput
		* @description Blocks until input is received
		* @returns {String} The input received
		*/
	WaitForInput() {
		this.Show()
		while this.IsWaiting {
			Sleep(10)
		}
		return this.Input
	}

	SetInput(value) {
		this.Input := value
		this.IsWaiting := false
	}

	RegisterHotkey(hotkeyStr, callback) {
		HotIfWinActive("ahk_id " this.Gui.Hwnd)
		Hotkey(hotkeyStr, callback)
	}

	Destroy() {
		; Clean up hotkeys
		HotIfWinActive("ahk_id " this.Gui.Hwnd)
		Hotkey("Enter", "Off")
		HotIf()

		; Remove from instances
		UnifiedDisplayManager.Instances.Delete(this.Gui.Hwnd)
		UnifiedDisplayManager.InstanceCount--

		; Destroy GUI
		this.Gui.Destroy()
	}

	/**
		* @method EnableAutoComplete
		* @description Enables autocomplete functionality for an input control
		* @param {Gui.Control} control The control to enable autocomplete for
		* @param {Array|Map|Object} source The data source for autocomplete
		*/
	EnableAutoComplete(control, source) {
		; Process source data into a consistent format
		items := this.ProcessItems(source)
		
		; Bind autocomplete handler
		control.OnEvent("Change", (*) => this.HandleAutoComplete(control, items))
	}

	HandleAutoComplete(control, items) {
		static CB_GETEDITSEL := 320, CB_SETEDITSEL := 322
		
		if ((GetKeyState("Delete")) || (GetKeyState("Backspace")))
			return

		currContent := control.Text
		if (!currContent)
			return

		; Check for exact match
		for item in items {
			if (item = currContent)
				return
		}

		; Try to find matching item
		try {
			if (ControlChooseString(currContent, control) > 0) {
				start := StrLen(currContent)
				end := StrLen(control.Text)
				PostMessage(CB_SETEDITSEL, 0, this.MakeLong(start, end),, control.Hwnd)
			}
		}
	}

	MakeLong(low, high) => (high << 16) | (low & 0xffff)
}

; ---------------------------------------------------------------------------
;@region GuiButtonProperties
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
		; fontSize := 9      ; Default font size
		fontSize := 1      ; Default font size
		return Round((textLength * avgCharWidth) + (2 * (bMargin * fontSize)))
	}

	static SetButtonHeight(rows := 1, vMargin := 7.5) {
		; Using default values instead of FontProperties
		fontSize := 15      ; Default font size
		return Round((fontSize * vMargin) * rows)
	}

	static GetButtonDimensions(text, options := {}) {
		width := options.HasOwnProp('width') ? options.width : GuiButtonProperties.CalculateButtonWidth(StrLen(text))
		height := options.HasOwnProp('height') ? options.height : GuiButtonProperties.SetButtonHeight()
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

;@region ErrorLogger/Gui
/**
 * @abstract ErrorLogger and ErrorLogGui - Advanced Error Logging System for AutoHotkey v2
 * 
 * @class ErrorLogger
 * @class ErrorLogGui
 * 
 * @description ErrorLogger provides a flexible error logging system with GUI support.
 * @description ErrorLogGui handles the visual representation of logs.
 * 
 * @example 
 * Basic Usage:
 * ; Create a new logger instance
 * logger := ErrorLogger("MyLogger")
 * 
 * ; Log a simple message
 * logger.Log("Something happened")
 * 
 * ; Log an error
 * try {
 *     ; Some code that might throw an error
 *     throw Error("Test error")
 * } catch as e {
 *     logger.LogErrorProps(e)
 * }
 * 
 * ; Use static methods
 * ErrorLogger.Log("Quick log message")
 * 
 * Git Operations:
 * ; Log git operations
 * logger.Git().Operation("push", "Pushed to remote")
 * logger.Git().Error("pull", errorObject)
 * 
 * Features:
 * - Persistent logging with JSON file storage
 * - Click-through GUI capability
 * - Auto-sizing columns
 * - Copy logs to clipboard
 * - Multiple logger instances support
 * - Chainable methods
 * 
 * GUI Features:
 * - Resizable window
 * - ListView display
 * - Click-through toggle via tray menu
 * - Auto-save to JSON file
 * 
 * @property {Map} ErrorLogger.instances - Stores all logger instances
 * @property {Integer} ErrorLogger.instanceId - Unique identifier counter
 * @property {Array} errorOrder - Order of error properties to display
 * @property {String} name - Instance name
 * @property {ErrorLogGui} logGui - GUI instance
 * 
 * @Methods
 * @method Log(input, showGui := true) - Log message or error object
 * @method LogErrorProps(e) - Log error properties in structured format
 * @method LogErrorMap(e) - Log error using property map
 * @method Git() - Access Git operation logging methods
 * 
 * @Static @Methods
 * @method ErrorLogger.Log(input, showGui := true) - Static logging
 * @method ErrorLogger.LogErrorProps(e) - Static error properties logging
 * @method ErrorLogger.LogErrorMap(e) - Static error map logging
 * @method ErrorLogger.Git() - Static Git operations
 * 
 * @ErrorLogGui @Methods
 * @method AddTrayMenuItem() - Add click-through toggle to tray menu
 * @method MakeClickThrough() - Toggle click-through capability
 * @method CreateGui() - Create the GUI window
 * @method UpdateListView() - Refresh the GUI display
 * @method CopyToClipboard() - Copy all logs to clipboard
 * 
 * @File @Storage
 * @note - Logs are stored in 'error_log.json' by default
 * @note - JSON format: [{timestamp: "YYYY-MM-DD HH:mm:ss", message: "log content"}]
 */
class ErrorLogGui {
	logGui := {}
	logListView := {}
	logData := []  ; Changed from Map to Array for better ordering and structured data
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
		static failsafeCounter := 0
		loop 10 {  ; Limit attempts to prevent infinite loop
			randomId := 'ErrorLogGui_' . Random(1, 9999)
			
			; CHANGED: Use DllCall directly to avoid WinExist which might trigger error handling
			if !DllCall("User32\FindWindowEx", "Ptr", 0, "Ptr", 0, "Str", "AutoHotkeyGUI", "Str", randomId, "Ptr")
				return randomId
			
			; Increment failsafe counter to prevent recursion
			if (++failsafeCounter > 20)
				return 'ErrorLogGui_Fallback_' . A_TickCount  ; Use timestamp as fallback
		}
		; If we exit the loop without finding a unique ID, use timestamp as fallback
		return 'ErrorLogGui_Fallback_' . A_TickCount
	}
	
	CreateGui() {
		; Create main GUI with modern styling using Gui2 extensions
		this.logGui := Gui('+Resize +MinSize400x300', 'Error Log - ' . this.instanceId)
		
		try {
			; Apply Gui2 extensions for better appearance - use try/catch
			this.logGui.MakeFontNicer("s10")
			this.logGui.DarkMode()
			this.logGui.Transparent()
			this.logGui.NoActivate()
		} catch Error as e {
			; Don't log this error - just continue without styling
			OutputDebug("Warning: Could not apply GUI styling: " e.Message)
		}
		
		; Set GUI title for identification
		this.logGui.Opt('+LastFound')
		WinSetTitle(this.instanceId)
		
		
		; Add control buttons
		buttonPanel := this.logGui.AddGroupBox("xm ym w780 h40", "Controls")
		buttonPanel.SetFont("s9")
		
		copyBtn := this.logGui.AddButton("x+10 y5 w120", "Copy to Clipboard")
		copyBtn.OnEvent("Click", (*) => this.CopyToClipboard())
		
		clearBtn := this.logGui.AddButton("x+10 w120", "Clear Log")
		clearBtn.OnEvent("Click", (*) => this.ClearLog())
		
		exportBtn := this.logGui.AddButton("x+10 w120", "Export JSON")
		exportBtn.OnEvent("Click", (*) => this.ExportLog())
		
		buttonPanel.GetPos(&x, &y, &w, &h)
		; Add ListView with enhanced columns for error information
		this.logListView := this.logGui.Add('ListView', x+5 y +5 ' r20 w800 vLogContent Grid', 
			['Timestamp', 'Type', 'Message', 'Source', 'Details'])

		; Set up event handlers
		this.logGui.OnEvent('Close', (*) => this.logGui.Hide())
		this.logGui.OnEvent('Size', (*) => this.ResizeControls())
		
		; Show the GUI initially
		this.logGui.Show("w800 h500")
	}
	
	ResizeControls() {
		if (!this.logGui.Hwnd)
			return
			
		this.logGui.GetClientPos(,,&w, &h)
		this.logListView.Move(,,w - 20, h - 60)
	}
	
	LoadLogData() {
		if (!FileExist(this.logFile)) {
			this.CreateDefaultLogFile()
			return
		}
		
		try {
			fileContent := FileRead(this.logFile)
			this.logData := jsongo.Parse(fileContent)
			if (!IsObject(this.logData) || !this.logData.Length) {
				this.logData := []
				this.CreateDefaultLogFile()
			}
		} catch as err {
			OutputDebug('Error loading log data: ' . err.Message)
			this.logData := []
			this.CreateDefaultLogFile()
		}
		
		this.UpdateListView()
	}
	
	CreateDefaultLogFile() {
		defaultData := [{
			timestamp: FormatTime(, 'yyyy-MM-dd HH:mm:ss'), 
			type: "System",
			message: 'Log file created',
			source: "ErrorLogGui",
			details: ""
		}]
		this.logData := defaultData
		FileAppend(jsongo.Stringify(defaultData, 4), this.logFile)
	}

	UpdateListView() {
		this.logListView.Opt('-Redraw')  ; Suspend redrawing
		this.logListView.Delete()
		
		for entry in this.logData {
			; Handle different data structures for backward compatibility
			if (IsObject(entry)) {
				; Process structured data
				row := [
					entry.HasProp("timestamp") ? entry.timestamp : FormatTime(, 'yyyy-MM-dd HH:mm:ss'),
					entry.HasProp("type") ? entry.type : "Info",
					entry.HasProp("message") ? entry.message : (entry.HasProp("text") ? entry.text : ""),
					entry.HasProp("source") ? entry.source : "",
					entry.HasProp("details") ? entry.details : ""
				]
				this.logListView.Add(, row*)
			} else {
				; Legacy format handling
				this.logListView.Add(, FormatTime(, 'yyyy-MM-dd HH:mm:ss'), "Legacy", entry, "", "")
			}
		}
		
		; Auto-size columns
		this.logListView.ModifyCol()
		this.logListView.ModifyCol(3, 250)  ; Make message column wider
		this.logListView.Opt('+Redraw')     ; Resume redrawing
	}
	
	Log(input, showGui := true) {
		; Create a consistent log entry object
		logEntry := {}
		timestamp := FormatTime(, 'yyyy-MM-dd HH:mm:ss')
		
		if (IsObject(input)) {
			; Handle structured input
			if (input is Error) {
				; Format error objects
				logEntry := {
					timestamp: timestamp,
					type: "Error",
					message: input.Message,
					source: input.HasProp("File") ? input.File : "Unknown",
					details: input.HasProp("Stack") ? input.Stack : ""
				}
			} else {
				; Handle other object types
				logEntry := {
					timestamp: timestamp,
					type: input.HasProp("type") ? input.type : "Info",
					message: input.HasProp("message") ? input.message : "Object log",
					source: input.HasProp("source") ? input.source : "",
					details: input.HasProp("details") ? input.details : ""
				}
			}
		} else {
			; Handle simple string input
			logEntry := {
				timestamp: timestamp,
				type: "Info",
				message: input,
				source: "",
				details: ""
			}
		}
		
		; Add to log data and update display
		this.logData.Push(logEntry)
		this.UpdateListView()
		this.SaveLogData()
		OutputDebug(timestamp . ': ' . logEntry.message)
		
		if (showGui) {
			this.logGui.Show()
		}
	}
	
	SaveLogData() {
		try {
			FileDelete(this.logFile)
			FileAppend(jsongo.Stringify(this.logData, 4), this.logFile)
		} catch as err {
			try OutputDebug('Error saving log data: ' . err.Message)
		}
	}
	
	CopyToClipboard() {
		clipboardContent := ""
		for entry in this.logData {
			if (IsObject(entry)) {
				clipboardContent .= Format("[{1}] [{2}] {3} ({4}){5}{6}`n", 
					entry.timestamp, 
					entry.type, 
					entry.message,
					entry.source,
					entry.details ? "`n" : "",
					entry.details)
			} else {
				clipboardContent .= entry . "`n"
			}
		}
		A_Clipboard := clipboardContent
		this.ShowTooltip("Log data copied to clipboard!")
	}
	
	ClearLog() {
		this.logData := []
		this.CreateDefaultLogFile()
		this.UpdateListView()
		this.ShowTooltip("Log cleared!")
	}
	
	ExportLog() {
		try {
			filename := A_Desktop . "\ErrorLog_" . FormatTime(, "yyyyMMdd_HHmmss") . ".json"
			FileAppend(jsongo.Stringify(this.logData, 4), filename)
			this.ShowTooltip("Log exported to: " . filename)
		} catch as err {
			this.ShowTooltip("Error exporting log: " . err.Message)
		}
	}
	
	ShowTooltip(message, duration := 1500) {
		ToolTip(message)
		SetTimer(() => ToolTip(), -duration)
	}
}
;@region ErrorLogger
class ErrorLogger {
	; Static properties
	static instances := Map()
	static instanceId := 0

	; Instance properties
	errorOrder := [
		"Message",
		"What", 
		"Extra",
		"File",
		"Line",
		"Stack"
	]

	name := ""
	logGui := ""

	/**
	 * Constructor initializes logger instance with unique ID
	 * @param {String} [name] Optional instance name
	 */
	__New(name := "") {
		; Generate unique ID if name not provided
		if (name = "") {
			ErrorLogger.instanceId++
			name := "Logger_" . ErrorLogger.instanceId
		}

		this.name := name
		this.logGui := ErrorLogGui()
		ErrorLogger.instances[this.name] := this

		; Initialize Git methods for chaining
		this.logGit := {
			Operation: this._GitOperation.Bind(this),
			Error: this._GitError.Bind(this)
		}

		return this
	}

	/**
	 * Static constructor to initialize class
	 */
	static __New() {
		; Add static methods as properties for chaining
		this.DefineProp("Log", {Call: this.LogStatic})
		this.DefineProp("LogErrorProps", {Call: this.LogErrorPropsStatic})
		this.DefineProp("LogErrorMap", {Call: this.LogErrorMapStatic})
		this.DefineProp("Git", {Call: this.GitStatic})
	}

	/**
	 * Create logger instance with given name or generate unique name
	 * @param {String} [name] Optional instance name
	 * @returns {ErrorLogger} Logger instance
	 */
	__Call(name := "") {
		return ErrorLogger(name)
	}

	/**
	 * Log message or error
	 * @param {String|Error} input Message or error to log
	 * @param {Boolean} [showGui] Whether to show GUI
	 * @returns {ErrorLogger} This instance for chaining
	 */
	Log(input, showGui := true) {
		
		; Enhanced error handling based on input type
		if (input is Error) {
			; Create structured error object for logging
			errorObj := {
				type: input.HasProp("Type") ? input.Type : "Error",
				message: input.Message,
				source: input.HasProp("File") ? input.File . ":" . input.Line : "Unknown",
				details: input.HasProp("Stack") ? input.Stack : ""
			}
			this.logGui.Log(errorObj, showGui)
		} else if (IsObject(input)) {
			; Pass object through
			this.logGui.Log(input, showGui)
		} else {
			; Simple message
			this.logGui.Log(input, showGui)
		}
		
		return this
	}

	/**
	 * Static log method
	 */
	static LogStatic(input, showGui := true) {
		static isLogging := false
		if (isLogging)
			return false  ; Prevent recursion
			
		isLogging := true
		try {
			return ErrorLogger().Log(input, showGui)
		} finally {
			isLogging := false
		}
	}

	/**
	 * Log error properties in order
		for propName in this.errorOrder {
			if (e.HasProp(propName) && e.%propName% != '') {
				details .= propName . ": " . e.%propName% . "`n"
			}
		}
		
		props.details := details
		props.source := e.HasProp("File") ? e.File . ":" . e.Line : "Unknown"
		
		this.logGui.Log(props)
		return this
	}

	/**
	 * Static error properties logging
	 */
	static LogErrorPropsStatic(e) {
		return ErrorLogger().LogErrorProps(e)
	}

	/**
	 * Log error using property map
	 * @param {Error} e Error object 
	 * @returns {ErrorLogger} This instance for chaining
	 */
	LogErrorMap(e) {
		errorProps := Map(
			"Message", e.Message,
			"What", e.What,
			"Extra", e.Extra,
			"File", e.File,
			"Line", e.Line,
			"Stack", e.Stack
		)
		
		props := {}
		props.type := "ErrorMap"
		props.message := "Error Details:"
		
		details := ""
		for propName in this.errorOrder {
			if (errorProps.Has(propName) && errorProps[propName] != '') {
				details .= propName . ": " . errorProps[propName] . "`n"
			}
		}
		
		props.details := details
		props.source := e.HasProp("File") ? e.File . ":" . e.Line : "Unknown"
		
		this.logGui.Log(props)
		return this
	}

	/**
	 * Static error map logging
	 */
	static LogErrorMapStatic(e) {
		return ErrorLogger().LogErrorMap(e)
	}

	/**
	 * Git operation methods that support chaining
	 * @returns {Object} Git operation methods
	 */
	Git() {
		return {
			Operation: this._GitOperation.Bind(this),
			Error: this._GitError.Bind(this)
		}
	}

	/**
	 * Static Git operations
	 */
	static GitStatic() {
		return ErrorLogger().Git()
	}

	_GitOperation(operation, details, logEdit := '') {
		gitLog := {
			type: "Git",
			message: details,
			source: "Git:" . operation,
			details: Type(details) == "object" ? JSON.Stringify(details) : details
		}
		
		this.logGui.Log(gitLog, true)
		
		if (logEdit)
			logEdit.Value := Format("[Git {1}] {2}", operation, details) . "`n" . logEdit.Value
			
		return this
	}

	_GitError(operation, e, logEdit := '') {
		errorDetails := {
			type: "GitError",
			message: e.Message,
			source: "Git:" . operation,
			details: e.HasProp("Stack") ? e.Stack : ""
		}
		
		this.logGui.Log(errorDetails, true)
		
		if (logEdit)
			logEdit.Value := Format("[Git Error-{1}] {2}", operation, e.Message) . "`n" . logEdit.Value
			
		return this
	}

	/**
	 * Clean up resources when logger instance is destroyed
	 */
	__Delete() {
		if (ErrorLogger.instances.Has(this.name))
			ErrorLogger.instances.Delete(this.name)
	}
}
;@region FileSystemSearch
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
		try {
			this.path := WinGetTitle('^[A-Z]: ahk_exe explorer\.exe')
		}
		catch Any {
			Infos('Open an explorer window first!')
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
;@endregion FileSystemSearch
; ---------------------------------------------------------------------------
;@region FileSearch
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

#HotIf WinActive('ahk_class CabinetWClass')
; F3::{
; 	sel := []
; 	sel := getSelected()
; 	str := ''
; 	str := sel.ToString()
; 	len := sel.Length
; 	Infos(len '`n' str)
; }
F3::fileString()
fileString(&str?){
	sel := []
	sel := getSelected()
	str := ''
	str := sel.ToString()
	len := sel.Length
	; Infos(len '`n' str)
	return str
}
^+Enter::
^+LButton::{
	sel := []
	sel := ''
	sel := getSelected()
	len := sel.length
	; if len == 1 {
	if len >= 1 {
		sel := sel.ToString()
		Run(Paths.Code ' "' sel '"')
		; Infos('len == ' len)
	}
	else {
		for each, value in sel {
			Run(Paths.Code ' "' value '"')
			; Infos('I did this array to run.')
		}
	}
}
#HotIf

/**
	* 
	* @description..: Get the paths of selected files and folders both in Explorer and on the Desktop
	* @link 	GEV: https://www.autohotkey.com/boards/viewtopic.php?p=514288#p514288
	* @link	v2: https://www.autohotkey.com/boards/viewtopic.php?style=17&t=60403#p255256
	* @author 	v1: GEV, teadrinker
	* @author 	v2: mikeyww
*/
; ---------------------------------------------------------------------------
getSelected(hWnd := 0) { 
	Static SWC_DESKTOP := 8, SWFO_NEEDDISPATCH := 1
	winClass := WinGetClass(hWnd := WinActive('A'))
	If !(winClass ~= 'Progman|WorkerW|(Cabinet|Explore)WClass'){
		Return
	}
	shellWindows := ComObject('Shell.Application').Windows
	sel := []
	If !(winClass ~= 'Progman|WorkerW') {
		For window in shellWindows{
			If hWnd = window.HWND && shellFolderView := window.Document{
				Break
			}
		}
	}
	Else shellFolderView := shellWindows.FindWindowSW(0, 0, SWC_DESKTOP, 0, SWFO_NEEDDISPATCH).Document
	For item in shellFolderView.SelectedItems{
		sel.SafePush(item.Path)
	}
	Return sel
}

/*
	Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GuiResizer.ahk
	Author: Nich-Cebolla
	Version: 1.0.0
	License: MIT
*/

/*
	Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Align.ahk
	Author: Nich-Cebolla
	Version: 1.0.0
	License: MIT
*/
;@region Class Align
/**
 * @class Align
 * @description Utility class for aligning and distributing GUI controls and windows.
 * @version 1.1.0
 * @author OvercastBTC, Nich-Cebolla
 * @license MIT
 * @date 2025-04-20
 * @requires AutoHotkey v2.0+
 */
class Align {

    static DPI_AWARENESS_CONTEXT := -4

    ; --- Window-level alignment methods (from original) ---
    static CenterH(Subject, Target) {
        Subject.GetPos(&X1, &Y1, &W1)
        Target.GetPos(&X2, , &W2)
        Subject.Move(X2 + W2 / 2 - W1 / 2, Y1)
    }
    static CenterHSplit(Win1, Win2) {
        Win1.GetPos(&X1, &Y1, &W1)
        Win2.GetPos(&X2, &Y2, &W2)
        diff := X1 + 0.5 * W1 - X2 - 0.5 * W2
        X1 -= diff * 0.5
        X2 += diff * 0.5
        Win1.Move(X1, Y1)
        Win2.Move(X2, Y2)
    }
    static CenterV(Subject, Target) {
        Subject.GetPos(&X1, &Y1, , &H1)
        Target.GetPos( , &Y2, , &H2)
        Subject.Move(X1, Y2 + H2 / 2 - H1 / 2)
    }
    static CenterVSplit(Win1, Win2) {
        Win1.GetPos(&X1, &Y1, , &H1)
        Win2.GetPos(&X2, &Y2, , &H2)
        diff := Y1 + 0.5 * H1 - Y2 - 0.5 * H2
        Y1 -= diff * 0.5
        Y2 += diff * 0.5
        Win1.Move(X1, Y1)
        Win2.Move(X2, Y2)
    }

    ; --- Control-level alignment methods (from your new class) ---

    /**
     * Center a list of controls horizontally within a given width or container.
     * @param {Array} controls Array of Gui.Control objects
     * @param {Integer|Gui.Control|Gui} containerOrWidth Optional: container (GroupBox/Area/Gui) or width
     * @param {Integer} y Optional Y position for all controls
     */
    static CenterHList(controls, containerOrWidth := 0, y := unset) {
        if !IsSet(controls) || !IsObject(controls) || controls.Length = 0
            throw ValueError("Align.CenterHList: controls must be a non-empty array", -1)
        local sumWidth := 0
        for _, ctrl in controls {
            if !ctrl.HasOwnProp("Hwnd")
                continue
            ctrl.GetPos(,, &w)
            sumWidth += w
        }
        ; Determine container width
        local totalWidth := 0
        if (containerOrWidth is Gui.Control || containerOrWidth is Gui) {
            containerOrWidth.GetPos(,, &totalWidth)
        } else if (containerOrWidth > 0) {
            totalWidth := containerOrWidth
        } else {
            ; fallback: use parent gui width
            parent := controls[1].Gui
            parent.GetClientPos(,, &totalWidth)
        }
        local spacing := 0
        if (totalWidth > 0 && controls.Length > 1)
            spacing := Floor((totalWidth - sumWidth) / (controls.Length + 1))
        else
            spacing := 5
        local x := spacing
        for _, ctrl in controls {
            ctrl.GetPos(,, &w, &h)
            if IsSet(y)
                ctrl.Move(x, y, w, h)
            else
                ctrl.Move(x, , w, h)
            x += w + spacing
        }
        return this
    }

    /**
     * Center a list of controls vertically within a given height or container.
     */
    static CenterVList(controls, containerOrHeight := 0, x := unset) {
        if !IsSet(controls) || !IsObject(controls) || controls.Length = 0
            throw ValueError("Align.CenterVList: controls must be a non-empty array", -1)
        local sumHeight := 0
        for _, ctrl in controls {
            if !ctrl.HasOwnProp("Hwnd")
                continue
            ctrl.GetPos(,,, &h)
            sumHeight += h
        }
        local totalHeight := 0
        if (containerOrHeight is Gui.Control || containerOrHeight is Gui) {
            containerOrHeight.GetPos(,,, &totalHeight)
        } else if (containerOrHeight > 0) {
            totalHeight := containerOrHeight
        } else {
            parent := controls[1].Gui
            parent.GetClientPos(,,, &totalHeight)
        }
        local spacing := 0
        if (totalHeight > 0 && controls.Length > 1)
            spacing := Floor((totalHeight - sumHeight) / (controls.Length + 1))
        else
            spacing := 5
        local y := spacing
        for _, ctrl in controls {
            ctrl.GetPos(,, &w, &h)
            if IsSet(x)
                ctrl.Move(x, y, w, h)
            else
                ctrl.Move(, y, w, h)
            y += h + spacing
        }
        return this
    }

    /**
     * Set all controls in a list to the same width (max width).
     */
    static GroupWidth(controls) {
        if !IsSet(controls) || !IsObject(controls) || controls.Length = 0
            throw ValueError("Align.GroupWidth: controls must be a non-empty array", -1)
        local maxWidth := 0
        for _, ctrl in controls {
            ctrl.GetPos(,, &w)
            if (w > maxWidth)
                maxWidth := w
        }
        for _, ctrl in controls {
            ctrl.GetPos(&x, &y, , &h)
            ctrl.Move(x, y, maxWidth, h)
        }
        return this
    }

    /**
     * Evenly distribute controls horizontally within a given width or container.
     */
    static DistributeH(controls, containerOrWidth, y := unset) {
        if !IsSet(controls) || !IsObject(controls) || controls.Length = 0
            throw ValueError("Align.DistributeH: controls must be a non-empty array", -1)
        local sumWidth := 0
        for _, ctrl in controls {
            ctrl.GetPos(,, &w)
            sumWidth += w
        }
        local totalWidth := 0
        if (containerOrWidth is Gui.Control || containerOrWidth is Gui) {
            containerOrWidth.GetPos(,, &totalWidth)
        } else {
            totalWidth := containerOrWidth
        }
        local spacing := 0
        if (controls.Length > 1)
            spacing := Floor((totalWidth - sumWidth) / (controls.Length - 1))
        else
            spacing := 0
        local x := 0
        for _, ctrl in controls {
            ctrl.GetPos(,, &w, &h)
            if IsSet(y)
                ctrl.Move(x, y, w, h)
            else
                ctrl.Move(x, , w, h)
            x += w + spacing
        }
        return this
    }

    /**
     * Evenly distribute controls vertically within a given height or container.
     */
    static DistributeV(controls, containerOrHeight, x := unset) {
        if !IsSet(controls) || !IsObject(controls) || controls.Length = 0
            throw ValueError("Align.DistributeV: controls must be a non-empty array", -1)
        local sumHeight := 0
        for _, ctrl in controls {
            ctrl.GetPos(,,, &h)
            sumHeight += h
        }
        local totalHeight := 0
        if (containerOrHeight is Gui.Control || containerOrHeight is Gui) {
            containerOrHeight.GetPos(,,, &totalHeight)
        } else {
            totalHeight := containerOrHeight
        }
        local spacing := 0
        if (controls.Length > 1)
            spacing := Floor((totalHeight - sumHeight) / (controls.Length - 1))
        else
            spacing := 0
        local y := 0
        for _, ctrl in controls {
            ctrl.GetPos(,, &w, &h)
            if IsSet(x)
                ctrl.Move(x, y, w, h)
            else
                ctrl.Move(, y, w, h)
            y += h + spacing
        }
        return this
    }

    ; --- Optionally: Add methods for grid/column/row layout ---
    /**
     * Arrange controls in a grid within a container.
     * @param {Array} controls Array of controls
     * @param {Integer} columns Number of columns
     * @param {Gui.Control|Gui} container Container to arrange within
     * @param {Integer} hSpacing Horizontal spacing
     * @param {Integer} vSpacing Vertical spacing
     */
    static Grid(controls, columns, container := unset, hSpacing := 5, vSpacing := 5) {
        if !IsSet(controls) || !IsObject(controls) || controls.Length = 0
            throw ValueError("Align.Grid: controls must be a non-empty array", -1)
        local x0 := 0, y0 := 0, cW := 0, cH := 0
        if IsSet(container) && (container is Gui.Control || container is Gui) {
            container.GetPos(&x0, &y0, &cW, &cH)
        }
        local rows := Ceil(controls.Length / columns)
        local maxW := 0, maxH := 0
        ; Find max width/height for uniform grid
        for _, ctrl in controls {
            ctrl.GetPos(,, &w, &h)
            if (w > maxW)
                maxW := w
            if (h > maxH)
                maxH := h
        }
        for i, ctrl in controls {
            local col := Mod(i-1, columns)
            local row := Floor((i-1)/columns)
            local x := x0 + col * (maxW + hSpacing)
            local y := y0 + row * (maxH + vSpacing)
            ctrl.Move(x, y, maxW, maxH)
        }
        return this
    }

	/**
	 * Arrange controls in a horizontal toolbar row within a given area.
	 * @param {Array} controls Array of Gui.Control objects
	 * @param {Gui|Gui.Control} area The area to arrange within (e.g. toolbar background Text, or Gui)
	 * @param {String} align "center" (default), "left", or "right"
	 * @param {Integer} spacing Space between controls (default 5)
	 * @param {Integer} y Optional Y position (defaults to vertical center of area)
	 * @returns {Align} For chaining
	 */
	static ToolbarRow(controls, area, align := "center", spacing := 5, y := unset) {
		if !IsSet(controls) || !IsObject(controls) || controls.Length = 0
			throw ValueError("Align.ToolbarRow: controls must be a non-empty array", -1)
		; Get area rectangle
		area.GetPos(&ax, &ay, &aw, &ah)
		; Calculate total width of controls + spacing
		totalWidth := 0
		for _, ctrl in controls {
			ctrl.GetPos(,, &w)
			totalWidth += w
		}
		totalWidth += spacing * (controls.Length - 1)
		; Determine starting X based on alignment
		switch align {
			case "center":
				x := ax + Floor((aw - totalWidth) / 2)
			case "left":
				x := ax
			case "right":
				x := ax + aw - totalWidth
			default:
				x := ax
		}
		; Determine Y
		if !IsSet(y) {
			; Vertically center in area
			controls[1].GetPos(,,, &h)
			y := ay + Floor((ah - h) / 2)
		}
		; Position controls
		for _, ctrl in controls {
			ctrl.GetPos(,, &w, &h)
			ctrl.Move(x, y, w, h)
			x += w + spacing
		}
		return this
	}

	/**
	 * Arrange controls in a vertical toolbar column within a given area.
	 * @param {Array} controls Array of Gui.Control objects
	 * @param {Gui|Gui.Control} area The area to arrange within
	 * @param {String} align "center" (default), "top", or "bottom"
	 * @param {Integer} spacing Space between controls (default 5)
	 * @param {Integer} x Optional X position (defaults to horizontal center of area)
	 * @returns {Align} For chaining
	 */
	static ToolbarColumn(controls, area, align := "center", spacing := 5, x := unset) {
		if !IsSet(controls) || !IsObject(controls) || controls.Length = 0
			throw ValueError("Align.ToolbarColumn: controls must be a non-empty array", -1)
		area.GetPos(&ax, &ay, &aw, &ah)
		totalHeight := 0
		for _, ctrl in controls {
			ctrl.GetPos(,,, &h)
			totalHeight += h
		}
		totalHeight += spacing * (controls.Length - 1)
		switch align {
			case "center":
				y := ay + Floor((ah - totalHeight) / 2)
			case "top":
				y := ay
			case "bottom":
				y := ay + ah - totalHeight
			default:
				y := ay
		}
		if !IsSet(x) {
			controls[1].GetPos(,, &w)
			x := ax + Floor((aw - w) / 2)
		}
		for _, ctrl in controls {
			ctrl.GetPos(,, &w, &h)
			ctrl.Move(x, y, w, h)
			y += h + spacing
		}
		return this
	}

	/**
	 * Get the client rectangle of a Gui or control (Text, Picture, etc.)
	 * @param {Gui|Gui.Control} area
	 * @returns {Object} {x, y, w, h}
	 */
	static Area(area) {
		if (area is Gui) {
			area.GetClientPos(&x, &y, &w, &h)
			return {x: x, y: y, w: w, h: h}
		} else if (area is Gui.Control) {
			area.GetPos(&x, &y, &w, &h)
			return {x: x, y: y, w: w, h: h}
		} else {
			throw ValueError("Align.Area: area must be a Gui or Gui.Control", -1)
		}
	}

	/**
	 * Pack controls tightly in a row, left to right, with optional spacing.
	 * @param {Array} controls
	 * @param {Integer} x Starting X
	 * @param {Integer} y Y position
	 * @param {Integer} spacing Space between controls (default 5)
	 * @returns {Align}
	 */
	static PackRow(controls, x, y, spacing := 5) {
		for _, ctrl in controls {
			ctrl.GetPos(,, &w, &h)
			ctrl.Move(x, y, w, h)
			x += w + spacing
		}
		return this
	}

	/**
	 * @class ControlGroupLayout
	 * @description Advanced toolbar/group layout manager for Word-like toolbars
	 * @version 1.0.0
	 * @author OvercastBTC
	 * @date 2025-04-20
	 * @requires AutoHotkey v2.0+
	 *
	 * @example
	 * ; Define groups and controls
	 * toolbarGroups := [
	 *   {name: "Clipboard", controls: [btnSave, btnCut, btnCopy, btnPaste]},
	 *   {name: "Font", controls: [btnBold, btnItalic, btnUnderline, btnStrike, btnNormal]},
	 *   {name: "Paragraph", controls: [btnAlignLeft, btnAlignCenter, btnAlignRight, btnAlignJustify]},
	 *   {name: "OpenGroup", controls: [btnOpenGroup]}
	 * ]
	 * ControlGroupLayout.ArrangeToolbar(gui, toolbarArea, toolbarGroups)
	 */
	class ControlGroupLayout {
		/**
		 * @description Arrange toolbar groups and controls in a Word-like toolbar.
		 * @param {Gui} gui The parent Gui object.
		 * @param {Gui.Control} toolbarArea The area (Text, GroupArea, etc.) to arrange within.
		 * @param {Array} groups Array of group objects: {name, controls, [expandable]}.
		 * @param {Integer} spacing Space between groups (default 12).
		 * @param {Integer} controlSpacing Space between controls in a group (default 4).
		 * @returns {ControlGroupLayout} This instance for chaining.
		 */
		static ArrangeToolbar(gui, toolbarArea, groups, spacing := 12, controlSpacing := 4) {
			; Validate parameters
			if !(gui is Gui)
				throw TypeError("gui must be a Gui object", -1)
			if !(toolbarArea is Gui.Control)
				throw TypeError("toolbarArea must be a Gui.Control", -1)
			if !IsObject(groups) || groups.Length = 0
				throw ValueError("groups must be a non-empty array", -1)
	
			; Get toolbar area dimensions
			toolbarArea.GetPos(&areaX, &areaY, &areaW, &areaH)
	
			; Calculate group widths (expandable group gets extra space)
			groupWidths := []
			totalFixedWidth := 0
			expandableIdx := 0
			for idx, group in groups {
				; Calculate width of controls in group
				groupWidth := 0
				for ctrl in group.controls {
					ctrl.GetPos(,, &w)
					groupWidth += w
				}
				groupWidth += controlSpacing * (group.controls.Length - 1)
				groupWidths.Push(groupWidth)
				if group.HasProp("expandable") && group.expandable
					expandableIdx := idx
				else
					totalFixedWidth += groupWidth
			}
			totalSpacing := spacing * (groups.Length - 1)
			remainingWidth := areaW - totalFixedWidth - totalSpacing
			if expandableIdx && remainingWidth > 0
				groupWidths[expandableIdx] += remainingWidth
	
			; Arrange groups left-to-right
			x := areaX
			for idx, group in groups {
				y := areaY + Floor((areaH - 28) / 2)  ; Vertically center (assume 28px button height)
				groupWidth := groupWidths[idx]
				; Arrange controls in group
				ctrlX := x
				for ctrlIdx, ctrl in group.controls {
					ctrl.GetPos(,, &w, &h)
					ctrl.Move(ctrlX, y, w, h)
					ctrlX += w + controlSpacing
				}
				; Optionally add group label below (Word-style)
				if group.HasProp("name") && group.name {
					labelY := areaY + areaH - 16
					labelW := groupWidth
					gui.AddText(Format("x{1} y{2} w{3} Center", x, labelY, labelW), group.name)
				}
				x += groupWidth + spacing
			}
			return this
		}
	
		/**
		 * @description Create an "open group" button for expanding/collapsing a group.
		 * @param {Gui} gui The parent Gui object.
		 * @param {String} label Button label (default: "▼").
		 * @param {Func} onClick Callback for expanding/collapsing.
		 * @param {String} options Button options.
		 * @returns {Gui.Button} The created button.
		 */
		static CreateOpenGroupButton(gui, label := "▼", onClick := unset, options := "w24 h24") {
			btn := gui.AddButton(options, label)
			if IsSet(onClick)
				btn.OnEvent("Click", onClick)
			return btn
		}
	}

    ; --- Window proxy for non-AHK windows (from original) ---
    __New(Hwnd) {
        this.Hwnd := Hwnd
    }
    GetPos(&X?, &Y?, &W?, &H?) {
        WinGetPos(&X, &Y, &W, &H, this.Hwnd)
    }
    Move(X?, Y?, W?, H?) {
        WinMove(X ?? unset, Y ?? unset, W ?? unset, H ?? unset, this.Hwnd)
    }
}
; class Align {

; 	static DPI_AWARENESS_CONTEXT := -4

; 	/**
; 	* @description - Centers the Subject window horizontally with respect to the Target window.
; 	* @param {Gui|Gui.Control|Align} Subject - The window to be centered.
; 	* @param {Gui|Gui.Control|Align} Target - The reference window.
; 	*/
; 	;@region Method CenterH()
; 	static CenterH(Subject, Target) {
; 		Subject.GetPos(&X1, &Y1, &W1)
; 		Target.GetPos(&X2, , &W2)
; 		Subject.Move(X2 + W2 / 2 - W1 / 2, Y1)
; 	}
; 	;@endregion
; 	/**
; 	* @description - Centers the two windows horizontally with one another, splitting the difference
; 	* between them.
; 	* @param {Gui|Gui.Control|Align} Win1 - The first window to be centered.
; 	* @param {Gui|Gui.Control|Align} Win2 - The second window to be centered.
; 	*/
; 	;@region static CenterHSplit()
; 	static CenterHSplit(Win1, Win2) {
; 		Win1.GetPos(&X1, &Y1, &W1)
; 		Win2.GetPos(&X2, &Y2, &W2)
; 		diff := X1 + 0.5 * W1 - X2 - 0.5 * W2
; 		X1 -= diff * 0.5
; 		X2 += diff * 0.5
; 		Win1.Move(X1, Y1)
; 		Win2.Move(X2, Y2)
; 	}

; 	/**
; 	* @description - Centers the Subject window vertically with respect to the Target window.
; 	* @param {Gui|Gui.Control|Align} Subject - The window to be centered.
; 	* @param {Gui|Gui.Control|Align} Target - The reference window.
; 	*/
; 	;@region static CenterV()
; 	static CenterV(Subject, Target) {
; 		Subject.GetPos(&X1, &Y1, , &H1)
; 		Target.GetPos( , &Y2, , &H2)
; 		Subject.Move(X1, Y2 + H2 / 2 - H1 / 2)
; 	}

; 	/**
; 		* @description - Centers the two windows vertically with one another, splitting the difference
; 		* between them.
; 		* @param {Gui|Gui.Control|Align} Win1 - The first window to be centered.
; 		* @param {Gui|Gui.Control|Align} Win2 - The second window to be centered.
; 		*/
; 	static CenterVSplit(Win1, Win2) {
; 		Win1.GetPos(&X1, &Y1, , &H1)
; 		Win2.GetPos(&X2, &Y2, , &H2)
; 		diff := Y1 + 0.5 * H1 - Y2 - 0.5 * H2
; 		Y1 -= diff * 0.5
; 		Y2 += diff * 0.5
; 		Win1.Move(X1, Y1)
; 		Win2.Move(X2, Y2)
; 	}

; 	/**
; 		* @description - Centers a list of windows horizontally with respect to one another, splitting
; 		* the difference between them. The center of each window will be the midpoint between the least
; 		* and greatest X coordinates of the windows.
; 		* @param {Array} List - An array of windows to be centered. This function assumes there are
; 		* no unset indices.
; 		*/
; 	static CenterHList(List) {
; 		if !(hDwp := DllCall('BeginDeferWindowPos', 'int', List.Length, 'ptr')) {
; 			throw Error('``BeginDeferWindowPos`` failed.', -1)
; 		}
; 		List[-1].GetPos(&L, &Y, &W)
; 		Params := [{ Y: Y, M: W / 2, Hwnd: List[-1].Hwnd }]
; 		Params.Capacity := List.Length
; 		R := L + W
; 		loop List.Length - 1 {
; 			List[A_Index].GetPos(&X, &Y, &W)
; 			Params.Push({ Y: Y, M: W / 2, Hwnd: List[A_Index].Hwnd })
; 			if X < L
; 				L := X
; 			if X + W > R
; 				R := X + W
; 		}
; 		Center := (R - L) / 2 + L
; 		for ps in Params {
; 			if !(hDwp := DllCall('DeferWindowPos'
; 				, 'ptr', hDwp
; 				, 'ptr', ps.Hwnd
; 				, 'ptr', 0
; 				, 'int', Center - ps.M
; 				, 'int', ps.Y
; 				, 'int', 0
; 				, 'int', 0
; 				, 'uint', 0x0001 | 0x0004 | 0x0010 ; SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE
; 				, 'ptr'
; 			)) {
; 				throw Error('``DeferWindowPos`` failed.', -1)
; 			}
; 		}
; 		if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
; 			throw Error('``EndDeferWindowPos`` failed.', -1)
; 		}
; 		return
; 	}

; 	/**
; 		* @description - Centers a list of windows vertically with respect to one another, splitting
; 		* the difference between them. The center of each window will be the midpoint between the least
; 		* and greatest Y coordinates of the windows.
; 		* @param {Array} List - An array of windows to be centered. This function assumes there are
; 		* no unset indices.
; 		*/
; 	static CenterVList(List) {
; 		if !(hDwp := DllCall('BeginDeferWindowPos', 'int', List.Length, 'ptr')) {
; 			throw Error('``BeginDeferWindowPos`` failed.', -1)
; 		}
; 		List[-1].GetPos(&X, &T, , &H)
; 		Params := [{ X: X, M: H / 2, Hwnd: List[-1].Hwnd }]
; 		Params.Capacity := List.Length
; 		B := T + H
; 		loop List.Length - 1 {
; 			List[A_Index].GetPos(&X, &Y, , &H)
; 			Params.Push({ X: X, M: H / 2, Hwnd: List[A_Index].Hwnd })
; 			if Y < T
; 				T := Y
; 			if Y + H > B
; 				B := Y + H
; 		}
; 		Center := (B - T) / 2 + T
; 		for ps in Params {
; 			if !(hDwp := DllCall('DeferWindowPos'
; 				, 'ptr', hDwp
; 				, 'ptr', ps.Hwnd
; 				, 'ptr', 0
; 				, 'int', ps.X
; 				, 'int', Center - ps.M
; 				, 'int', 0
; 				, 'int', 0
; 				, 'uint', 0x0001 | 0x0004 | 0x0010 ; SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE
; 				, 'ptr'
; 			)) {
; 				throw Error('``DeferWindowPos`` failed.', -1)
; 			}
; 		}
; 		if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
; 			throw Error('``EndDeferWindowPos`` failed.', -1)
; 		}
; 		return
; 	}

; 	/**
; 		* @description - Standardizes a group's width to the largest width in the group.
; 		* @param {Array} List - An array of windows to be standardized. This function assumes there are
; 		* no unset indices.
; 		*/
; 	static GroupWidth(List) {
; 		if !(hDwp := DllCall('BeginDeferWindowPos', 'int', List.Length, 'ptr')) {
; 			throw Error('``BeginDeferWindowPos`` failed.', -1)
; 		}
; 		List[-1].GetPos(, , &GW, &H)
; 		Params := [{ H: H, Hwnd: List[-1].Hwnd }]
; 		Params.Capacity := List.Length
; 		loop List.Length - 1 {
; 			List[A_Index].GetPos(, , &W, &H)
; 			Params.Push({ H: H, Hwnd: List[A_Index].Hwnd })
; 			if W > GW
; 				GW := W
; 		}
; 		for ps in Params {
; 			if !(hDwp := DllCall('DeferWindowPos'
; 				, 'ptr', hDwp
; 				, 'ptr', ps.Hwnd
; 				, 'ptr', 0
; 				, 'int', 0
; 				, 'int', 0
; 				, 'int', GW
; 				, 'int', ps.H
; 				, 'uint', 0x0002 | 0x0004 | 0x0010 ; SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE
; 				, 'ptr'
; 			)) {
; 				throw Error('``DeferWindowPos`` failed.', -1)
; 			}
; 		}
; 		if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
; 			throw Error('``EndDeferWindowPos`` failed.', -1)
; 		}
; 		return
; 	}

; 	static GroupWidthCb(G, Callback, ApproxCount := 2) {
; 		if !(hDwp := DllCall('BeginDeferWindowPos', 'int', ApproxCount, 'ptr')) {
; 			throw Error('``BeginDeferWindowPos`` failed.', -1)
; 		}
; 		GW := -99999
; 		Params := []
; 		Params.Capacity := ApproxCount
; 		for Ctrl in G {
; 			Ctrl.GetPos(, , &W, &H)
; 			if Callback(&GW, W, Ctrl) {
; 				Params.Push({ H: H, Hwnd: Ctrl.Hwnd })
; 				break
; 			}
; 		}
; 		for ps in Params {
; 			if !(hDwp := DllCall('DeferWindowPos'
; 				, 'ptr', hDwp
; 				, 'ptr', ps.Hwnd
; 				, 'ptr', 0
; 				, 'int', 0
; 				, 'int', 0
; 				, 'int', GW
; 				, 'int', ps.H
; 				, 'uint', 0x0002 | 0x0004 | 0x0010 ; SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE
; 				, 'ptr'
; 			)) {
; 				throw Error('``DeferWindowPos`` failed.', -1)
; 			}
; 		}
; 		if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
; 			throw Error('``EndDeferWindowPos`` failed.', -1)
; 		}
; 		return
; 	}

; 	;@region GroupHeight
; 	/**
; 		* @description - Standardizes a group's height to the largest height in the group.
; 		* @param {Array} List - An array of windows to be standardized. This function assumes there are
; 		* no unset indices.
; 		*/
; 	static GroupHeight(List) {
; 		if !(hDwp := DllCall('BeginDeferWindowPos', 'int', List.Length, 'ptr')) {
; 			throw Error('``BeginDeferWindowPos`` failed.', -1)
; 		}
; 		List[-1].GetPos(, , &W, &GH)
; 		Params := [{ W: W, Hwnd: List[-1].Hwnd }]
; 		Params.Capacity := List.Length
; 		loop List.Length - 1 {
; 			List[A_Index].GetPos(, , &W, &H)
; 			Params.Push({ W: W, Hwnd: List[A_Index].Hwnd })
; 			if H > GH
; 				GH := H
; 		}
; 		for ps in Params {
; 			if !(hDwp := DllCall('DeferWindowPos'
; 				, 'ptr', hDwp
; 				, 'ptr', ps.Hwnd
; 				, 'ptr', 0
; 				, 'int', 0
; 				, 'int', 0
; 				, 'int', ps.W
; 				, 'int', GH
; 				, 'uint', 0x0002 | 0x0004 | 0x0010 ; SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE
; 				, 'ptr'
; 			)) {
; 				throw Error('``DeferWindowPos`` failed.', -1)
; 			}
; 		}
; 		if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
; 			throw Error('``EndDeferWindowPos`` failed.', -1)
; 		}
; 		return
; 	}

; 	static GroupHeightCb(G, Callback, ApproxCount := 2) {
; 		if !(hDwp := DllCall('BeginDeferWindowPos', 'int', ApproxCount, 'ptr')) {
; 			throw Error('``BeginDeferWindowPos`` failed.', -1)
; 		}
; 		GH := -99999
; 		Params := []
; 		Params.Capacity := ApproxCount
; 		for Ctrl in G {
; 			Ctrl.GetPos(, , &W, &H)
; 			if Callback(&GH, H, Ctrl) {
; 				Params.Push({ W: W, Hwnd: Ctrl.Hwnd })
; 				break
; 			}
; 		}
; 		for ps in Params {
; 			if !(hDwp := DllCall('DeferWindowPos'
; 				, 'ptr', hDwp
; 				, 'ptr', ps.Hwnd
; 				, 'ptr', 0
; 				, 'int', 0
; 				, 'int', 0
; 				, 'int', ps.W
; 				, 'int', GH
; 				, 'uint', 0x0002 | 0x0004 | 0x0010 ; SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE
; 				, 'ptr'
; 			)) {
; 				throw Error('``DeferWindowPos`` failed.', -1)
; 			}
; 		}
; 		if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
; 			throw Error('``EndDeferWindowPos`` failed.', -1)
; 		}
; 		return
; 	}

; 	/**
; 		* @description - Allows the usage of the `_S` suffix for each function call. When you include
; 		* `_S` at the end of any function call, the function will call `SetThreadDpiAwarenessContext`
; 		* prior to executing the function. The value used will be `Align.DPI_AWARENESS_CONTEXT`, which
; 		* is initialized at `-4`, but you can change it to any value.
; 		* @example
; 		Align.DPI_AWARENESS_CONTEXT := -5
; 	* @
; 	*/
; 	static __Call(Name, Params) {
; 		Split := StrSplit(Name, '_')
; 		if this.HasMethod(Split[1]) && Split[2] = 'S' {
; 			DllCall('SetThreadDpiAwarenessContext', 'ptr', this.DPI_AWARENESS_CONTEXT, 'ptr')
; 			if Params.Length {
; 				return this.%Split[1]%(Params*)
; 			} else {
; 				return this.%Split[1]%()
; 			}
; 		} else {
; 			throw PropertyError('Property not found.', -1, Name)
; 		}
; 	}

; 	/**
; 		* @description - Creates a proxy for non-AHK windows.
; 		* @param {HWND} Hwnd - The handle of the window to be proxied.
; 		*/
; 	__New(Hwnd) {
; 		this.Hwnd := Hwnd
; 	}
; 	; 
; 	GetPos(&X?, &Y?, &W?, &H?) {
; 		WinGetPos(&X, &Y, &W, &H, this.Hwnd)
; 	}
; 	/**
; 		* @description - Moves the window to the specified position and size.
; 		* @param {Number} [X] - The new X coordinate of the window.
; 		* @param {Number} [Y] - The new Y coordinate of the window.
; 		* @param {Number} [W] - The new width of the window.
; 		* @param {Number} [H] - The new height of the window.
; 		*/
; 	Move(X?, Y?, W?, H?) {
; 		WinMove(X ?? unset, Y ?? unset, W ?? unset, H ?? unset, this.Hwnd)
; 	}
; }

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

;@region GuiColors Class
/**
* Integrated color management class with conversion and application functionality
*/
class GuiColors {

	; Individual app theme colors as separate static properties
	static VSCode := {
		Background: "#1E1E1E",
		Foreground: "#D4D4D4",
		Selection: "#264F78",
		LineNumber: "#858585",
		ActiveTab: "#2D2D2D",
		TextNormal: "#D4D4D4"
	}
	
	static GitHub := {
		Primary: "#24292E",
		Secondary: "#2188FF",
		Success: "#28A745",
		Warning: "#FFA500",
		Error: "#D73A49" 
	}
	
	static Git := {
		Added: "#28A745",
		Modified: "#DBAB09",
		Deleted: "#D73A49",
		Renamed: "#6F42C1"
	}
	
	static Terminal := {
		Background: "#0C0C0C",
		Foreground: "#CCCCCC",
		Selection: "#264F78",
		Cursor: "#FFFFFF",
		Black: "#0C0C0C",
		DarkBlue: "#0037DA",
		DarkGreen: "#13A10E",
		DarkCyan: "#3A96DD",
		DarkRed: "#C50F1F",
		DarkMagenta: "#881798",
		DarkYellow: "#C19C00",
		Gray: "#CCCCCC",
		DarkGray: "#767676",
		Blue: "#3B78FF",
		Green: "#16C60C",
		Cyan: "#61D6D6",
		Red: "#E74856",
		Magenta: "#B4009E",
		Yellow: "#F9F1A5",
		White: "#F2F2F2"
	}
	
	static Discord := {
		Primary: "#7289DA",
		Background: "#36393F",
		ChatBg: "#2F3136",
		TextArea: "#40444B"
	}
	
	static Slack := {
		Primary: "#4A154B",
		Background: "#F8F8F8",
		Text: "#2C2D30",
		Selection: "#E1E1E1"
	}
	
	static Office := {
		Word: "#185ABD",
		Excel: "#107C41",
		PowerPoint: "#CB4A32",
		Outlook: "#0F65A6",
		OneNote: "#7719AA",
		Teams: "#6264A7",
		Background: "#F3F2F1",
		Text: "#252423",
		Selection: "#CFE8FC"
	}

	; Map of all app themes for programmatic access
	static Apps := {
		VSCode: GuiColors.VSCode,
		GitHub: GuiColors.GitHub,
		Git: GuiColors.Git,
		Terminal: GuiColors.Terminal,
		Discord: GuiColors.Discord,
		Slack: GuiColors.Slack,
		Office: GuiColors.Office
	}
	
	; Theme combinations with paired background and text colors
	static Themes := {
		DarkMode: {
			Background: "#1E1E1E",
			Text: "#D4D4D4",
			Selection: "#264F78",
			Button: "#2D2D2D",
			ButtonText: "#CCCCCC",
			Border: "#4D4D4D"
		},
		LightMode: {
			Background: "#F3F2F1",
			Text: "#252423",
			Selection: "#CFE8FC",
			Button: "#E1E1E1",
			ButtonText: "#323130",
			Border: "#C8C6C4"
		},
		HighContrast: {
			Background: "#000000",
			Text: "#FFFFFF",
			Selection: "#1AEBFF",
			Button: "#2D2D2D",
			ButtonText: "#FFFFFF",
			Border: "#FFFFFF"
		},
		SoftDark: {
			Background: "#2D2D30",
			Text: "#E1E1E1",
			Selection: "#3E3E42",
			Button: "#3F3F46",
			ButtonText: "#E1E1E1",
			Border: "#555555"
		},
		SoftLight: {
			Background: "#F5F5F5",
			Text: "#333333",
			Selection: "#B8D6FB",
			Button: "#E5E5E5",
			ButtonText: "#333333",
			Border: "#CCCCCC"
		},
		BlueTheme: {
			Background: "#1A2733",
			Text: "#E1EFFF",
			Selection: "#4373AA",
			Button: "#2B5278",
			ButtonText: "#FFFFFF",
			Border: "#4373AA"
		},
		GreenTheme: {
			Background: "#1E3B2C",
			Text: "#C5E8D5",
			Selection: "#2D7D4D",
			Button: "#2D5F3F",
			ButtonText: "#FFFFFF",
			Border: "#2D7D4D"
		},
		SepiaTheme: {
			Background: "#F4ECD8",
			Text: "#5B4636",
			Selection: "#D9C9A7",
			Button: "#E0D3B8",
			ButtonText: "#5B4636",
			Border: "#C9B99A"
		}
	}

	/**
		* @description Get color value without '#' prefix for AHK compatibility
		* @param {String} colorName Color name or hex value
		* @returns {String} Hex color value without # prefix
		*/
	static GetAhkColor(colorName) {
		hexColor := this.GetColor(colorName)
		return (hexColor.StartsWith("#")) ? SubStr(hexColor, 2) : hexColor
	}
	
	/**
		* @description Convert color name to RGB hex value
		* @param {String} colorName Color name or hex value
		* @returns {String} Hex color value
		*/
	static GetColor(colorName) {
		if (InStr(colorName, "#") == 1)
			return colorName
			
		if (this.mColors.Has(colorName))
			return this.mColors[colorName]
			
		return "#000000"  ; Default to black if color not found
	}
	
	/**
		* @description Convert hex color to RGB values
		* @param {String} hexColor Hex color value
		* @returns {Object} Object with r, g, b properties
		*/
	static HexToRGB(hexColor) {
		; Remove # if present
		if (InStr(hexColor, "#") == 1)
			hexColor := SubStr(hexColor, 2)
			
		; Ensure 6 characters
		if (StrLen(hexColor) != 6)
			return {r: 0, g: 0, b: 0}
			
		; Convert to RGB
		r := Integer("0x" SubStr(hexColor, 1, 2))
		g := Integer("0x" SubStr(hexColor, 3, 2))
		b := Integer("0x" SubStr(hexColor, 5, 2))
		
		return {r: r, g: g, b: b}
	}
	
	/**
		* @description Convert decimal color to hex
		* @param {Integer} color Decimal color value
		* @returns {String} Hex color value
		*/
	static DecToHex(color) {
		return "#" Format("{:06X}", color)
	}
	
	/**
		* @description Convert RGB to hex color
		* @param {Integer} r Red value (0-255)
		* @param {Integer} g Green value (0-255)
		* @param {Integer} b Blue value (0-255)
		* @returns {String} Hex color value
		*/
	static RGBToHex(r, g, b) {
		return "#" Format("{:02X}{:02X}{:02X}", r, g, b)
	}
	
	/**
		* @description Calculate luminance of a color (for contrast calculations)
		* @param {String} hexColor Hex color value
		* @returns {Float} Luminance value (0-1)
		*/
	static GetLuminance(hexColor) {
		rgb := this.HexToRGB(hexColor)
		
		; Convert RGB to relative luminance using sRGB formula
		r := rgb.r / 255
		g := rgb.g / 255
		b := rgb.b / 255
		
		r := (r <= 0.03928) ? r/12.92 : ((r+0.055)/1.055) ** 2.4
		g := (g <= 0.03928) ? g/12.92 : ((g+0.055)/1.055) ** 2.4
		b := (b <= 0.03928) ? b/12.92 : ((b+0.055)/1.055) ** 2.4
		
		return 0.2126 * r + 0.7152 * g + 0.0722 * b
	}
	
	/**
		* @description Calculate contrast ratio between two colors
		* @param {String} color1 First hex color
		* @param {String} color2 Second hex color
		* @returns {Float} Contrast ratio (1-21)
		*/
	static GetContrast(color1, color2) {
		lum1 := this.GetLuminance(color1)
		lum2 := this.GetLuminance(color2)
		
		; Calculate contrast ratio
		if (lum1 > lum2)
			return (lum1 + 0.05) / (lum2 + 0.05)
		else
			return (lum2 + 0.05) / (lum1 + 0.05)
	}
	
	/**
		* @description Get text color (black/white) for best contrast with background
		* @param {String} bgColor Background hex color
		* @returns {String} Text color (#000000 or #FFFFFF)
		*/
	static GetTextColor(bgColor) {
		lum := this.GetLuminance(bgColor)
		return (lum > 0.5) ? "#000000" : "#FFFFFF"
	}
	
	/**
		* @description Adjusts color brightness
		* @param {String} color Color value
		* @param {Number} amount Adjustment amount (-1.0 to 1.0)
		* @returns {String} Hex color string
		*/
	static Adjust(color, amount) {
		rgb := this.HexToRGB(color)
		amount := Min(1.0, Max(-1.0, amount))

		rgb.r := Min(255, Max(0, Round(rgb.r * (1 + amount))))
		rgb.g := Min(255, Max(0, Round(rgb.g * (1 + amount))))
		rgb.b := Min(255, Max(0, Round(rgb.b * (1 + amount))))

		return this.RGBToHex(rgb.r, rgb.g, rgb.b)
	}

	/**
		* @description Mixes two colors together
		* @param {String} color1 First color
		* @param {String} color2 Second color
		* @param {Number} ratio Mix ratio (0.0 to 1.0)
		* @returns {String} Hex color string
		*/
	static Mix(color1, color2, ratio := 0.5) {
		c1 := this.HexToRGB(color1)
		c2 := this.HexToRGB(color2)
		ratio := Min(1, Max(0, ratio))

		return this.RGBToHex(
			Round(c1.r * (1 - ratio) + c2.r * ratio),
			Round(c1.g * (1 - ratio) + c2.g * ratio),
			Round(c1.b * (1 - ratio) + c2.b * ratio)
		)
	}

	/**
		* @description Apply color to a GUI or control
		* @param {Gui|GuiControl} target Target object
		* @param {String} color Color value
		* @param {String} type Color type (Background|Text)
		*/
	static Apply(target, color, type := "Background") {
		if !(target is Gui || target is Gui.Control)
			throw ValueError("Target must be a Gui or GuiControl")

		hexColor := this.GetAhkColor(color)

		switch type {
			case "Background": target.BackColor := "0x" hexColor
			case "Text": target.SetFont("c" hexColor)
			default: throw ValueError("Invalid color type")
		}
	}
	
	/**
		* @description Apply a complete theme to a GUI
		* @param {Gui} gui GUI object to theme
		* @param {String} themeName Name of the theme to apply
		* @returns {Gui} The themed GUI for method chaining
		*/
	static ApplyTheme(gui, themeName := "DarkMode") {
		if (!this.Themes.HasProp(themeName))
			themeName := "DarkMode"  ; Default to DarkMode if theme not found
			
		theme := this.Themes.%themeName%
		
		; Apply background color
		gui.BackColor := "0x" this.GetAhkColor(theme.Background)
		
		; Apply text color to all controls
		gui.SetFont("c" this.GetAhkColor(theme.Text))
		
		; Apply specific styling to button types
		for ctrl in gui {
			if (ctrl.Type = "Button") {
				ctrl.SetFont("c" this.GetAhkColor(theme.ButtonText))
				; Additional button styling could be done here
			}
		}
		
		return gui  ; Return GUI for method chaining
	}
	
	/**
		* @description Get a complete theme object by name
		* @param {String} themeName Name of the theme
		* @returns {Object} Theme object with color properties
		*/
	static GetTheme(themeName := "DarkMode") {
		if (!this.Themes.HasProp(themeName))
			return this.Themes.DarkMode
			
		return this.Themes.%themeName%
	}
	
	/**
		* @description Create a custom theme with specified colors
		* @param {String} name Theme name
		* @param {Object} colors Theme colors
		* @returns {Object} The created theme
		*/
	static CreateTheme(name, colors) {
		; Ensure required colors are present
		if (!colors.HasProp("Background"))
			colors.Background := "#FFFFFF"
		if (!colors.HasProp("Text"))
			colors.Text := this.GetTextColor(colors.Background)
			
		; Create theme
		this.Themes.%name% := colors
		return colors
	}
	
	/**
		* @description Apply dark mode to a GUI
		* @param {Gui} gui GUI to apply dark mode to
		* @returns {Gui} The themed GUI for method chaining
		*/
	static ApplyDarkMode(gui) {
		return this.ApplyTheme(gui, "DarkMode")
	}
	
	/**
		* @description Apply light mode to a GUI
		* @param {Gui} gui GUI to apply light mode to
		* @returns {Gui} The themed GUI for method chaining
		*/
	static ApplyLightMode(gui) {
		return this.ApplyTheme(gui, "LightMode")
	}
	
	/**
		* @description Apply high contrast mode to a GUI
		* @param {Gui} gui GUI to apply high contrast to
		* @returns {Gui} The themed GUI for method chaining
		*/
	static ApplyHighContrast(gui) {
		return this.ApplyTheme(gui, "HighContrast")
	}
	
	/**
		* @description Generate a color palette based on a primary color
		* @param {String} baseColor Primary color to base palette on
		* @returns {Object} Color palette with variants
		*/
	static GeneratePalette(baseColor) {
		rgb := this.HexToRGB(baseColor)
		
		return {
			Base: baseColor,
			Lighter: this.Adjust(baseColor, 0.3),
			Darker: this.Adjust(baseColor, -0.3),
			Complementary: this.RGBToHex(255 - rgb.r, 255 - rgb.g, 255 - rgb.b),
			Text: this.GetTextColor(baseColor)
		}
	}

	; Common named colors map
	static mColors := Map(
		"aliceblue", "F0F8FF",
		"antiquewhite", "FAEBD7",
		"aqua", "00FFFF",
		"aquamarine", "7FFFD4",
		"azure", "F0FFFF",
		"beige", "F5F5DC",
		"bisque", "FFE4C4",
		"black", "000000",
		"blanchedalmond", "FFEBCD",
		"blue", "0000FF",
		"blueviolet", "8A2BE2",
		"brown", "A52A2A",
		"burlywood", "DEB887",
		"cadetblue", "5F9EA0",
		"chartreuse", "7FFF00",
		"chocolate", "D2691E",
		"coral", "FF7F50",
		"cornflowerblue", "6495ED",
		"cornsilk", "FFF8DC",
		"crimson", "DC143C",
		"cyan", "00FFFF",
		"darkblue", "00008B",
		"darkcyan", "008B8B",
		"darkgoldenrod", "B8860B",
		"darkgray", "A9A9A9",
		"darkgreen", "006400",
		"darkkhaki", "BDB76B",
		"darkmagenta", "8B008B",
		"darkolivegreen", "556B2F",
		"darkorange", "FF8C00",
		"darkorchid", "9932CC",
		"darkred", "8B0000",
		"darksalmon", "E9967A",
		"darkseagreen", "8FBC8F",
		"darkslateblue", "483D8B",
		"darkslategray", "2F4F4F",
		"darkturquoise", "00CED1",
		"darkviolet", "9400D3",
		"deeppink", "FF1493",
		"deepskyblue", "00BFFF",
		"dimgray", "696969",
		"dodgerblue", "1E90FF",
		"firebrick", "B22222",
		"floralwhite", "FFFAF0",
		"forestgreen", "228B22",
		"fuchsia", "FF00FF",
		"gainsboro", "DCDCDC",
		"ghostwhite", "F8F8FF",
		"gold", "FFD700",
		"goldenrod", "DAA520",
		"gray", "808080",
		"green", "008000",
		"greenyellow", "ADFF2F",
		"honeydew", "F0FFF0",
		"hotpink", "FF69B4",
		"indianred", "CD5C5C",
		"indigo", "4B0082",
		"ivory", "FFFFF0",
		"khaki", "F0E68C",
		"lavender", "E6E6FA",
		"lavenderblush", "FFF0F5",
		"lawngreen", "7CFC00",
		"lemonchiffon", "FFFACD",
		"lightblue", "ADD8E6",
		"lightcoral", "F08080",
		"lightcyan", "E0FFFF",
		"lightgoldenrodyellow", "FAFAD2",
		"lightgray", "D3D3D3",
		"lightgreen", "90EE90",
		"lightpink", "FFB6C1",
		"lightsalmon", "FFA07A",
		"lightseagreen", "20B2AA",
		"lightskyblue", "87CEFA",
		"lightslategray", "778899",
		"lightsteelblue", "B0C4DE",
		"lightyellow", "FFFFE0",
		"lime", "00FF00",
		"limegreen", "32CD32",
		"linen", "FAF0E6",
		"magenta", "FF00FF",
		"maroon", "800000",
		"mediumaquamarine", "66CDAA",
		"mediumblue", "0000CD",
		"mediumorchid", "BA55D3",
		"mediumpurple", "9370DB",
		"mediumseagreen", "3CB371",
		"mediumslateblue", "7B68EE",
		"mediumspringgreen", "00FA9A",
		"mediumturquoise", "48D1CC",
		"mediumvioletred", "C71585",
		"midnightblue", "191970",
		"mintcream", "F5FFFA",
		"mistyrose", "FFE4E1",
		"moccasin", "FFE4B5",
		"navajowhite", "FFDEAD",
		"navy", "000080",
		"oldlace", "FDF5E6",
		"olive", "808000",
		"olivedrab", "6B8E23",
		"orange", "FFA500",
		"orangered", "FF4500",
		"orchid", "DA70D6",
		"palegoldenrod", "EEE8AA",
		"palegreen", "98FB98",
		"paleturquoise", "AFEEEE",
		"palevioletred", "DB7093",
		"papayawhip", "FFEFD5",
		"peachpuff", "FFDAB9",
		"peru", "CD853F",
		"pink", "FFC0CB",
		"plum", "DDA0DD",
		"powderblue", "B0E0E6",
		"purple", "800080",
		"rebeccapurple", "663399",
		"red", "FF0000",
		"rosybrown", "BC8F8F",
		"royalblue", "4169E1",
		"saddlebrown", "8B4513",
		"salmon", "FA8072",
		"sandybrown", "F4A460",
		"seagreen", "2E8B57",
		"seashell", "FFF5EE",
		"sienna", "A0522D",
		"silver", "C0C0C0",
		"skyblue", "87CEEB",
		"slateblue", "6A5ACD",
		"slategray", "708090",
		"snow", "FFFAFA",
		"springgreen", "00FF7F",
		"steelblue", "4682B4",
		"tan", "D2B48C",
		"teal", "008080",
		"thistle", "D8BFD8",
		"tomato", "FF6347",
		"turquoise", "40E0D0",
		"violet", "EE82EE",
		"wheat", "F5DEB3",
		"white", "FFFFFF",
		"whitesmoke", "F5F5F5",
		"yellow", "FFFF00",
		"yellowgreen", "9ACD32"
	)

	/**
		* Get app theme color
		* @param {String} app App name
		* @param {String} colorName Color name
		* @returns {String} Hex color
		*/
	static GetThemeColor(app, colorName) {
		if this.Apps.HasOwnProp(app) && this.Apps.%app%.HasOwnProp(colorName)
			return this.Apps.%app%.%colorName%
		throw ValueError("Invalid app or color name")
	}

	/**
		* Apply app theme to GUI
		* @param {Gui} gui GUI object
		* @param {String} app App name
		*/
	static ApplyAppTheme(gui, app) {
		if !this.Apps.HasOwnProp(app)
			throw ValueError("Invalid app name")

		theme := this.Apps.%app%
		if theme.HasOwnProp("Background")
			this.Apply(gui, theme.Background, "Background")
		if theme.HasOwnProp("Foreground") || theme.HasOwnProp("TextNormal")
			this.Apply(gui, theme.HasOwnProp("Foreground") ? theme.Foreground : theme.TextNormal, "Text")
	}
}
;@endregion
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
;@region Class StackedDisplay
class StackedDisplay {
	width := A_ScreenWidth/3
	topMargin := A_ScreenHeight/2
	stackMargin := 30
	
	guis := []
	selected := false
	result := 0

	__New() {
		this.guis := []
	}

	/**
		* Adds an option to the stacked display
		* @param {String} text The text to display
		* @param {Integer} value The value to return if selected
		* @param {Integer} index Position in stack (1-based)
		* @returns {Gui} The created GUI object
		*/
	AddOption(text, value, index) {
		gui := Gui("+AlwaysOnTop -Caption +ToolWindow")
		gui.SetFont("s10", "Segoe UI")
		gui.AddText("x10 y5", text)
		
		; Store data
		gui.value := value
		
		; Calculate position
		y := this.topMargin + (index-1)*this.stackMargin
		gui.Show(Format("y{1} w{2}", y, this.width))
		
		; Add to tracking
		this.guis.Push(gui)
		
		; Setup hotkey
		this.SetupHotkeys(gui, index)
		
		return gui
	}

	SetupHotkeys(gui, index) {
		; F-key hotkey
		HotIfWinExist("ahk_id " gui.Hwnd)
		Hotkey("F" index, this.HandleSelection.Bind(this, gui))

		; Click handler
		gui.OnEvent("Click", this.HandleSelection.Bind(this, gui))
	}

	HandleSelection(gui, *) {
		this.selected := true
		this.result := gui.value
		this.CleanupGuis()
	}

	WaitForSelection(timeout := 0) {
		startTime := A_TickCount
		while !this.selected {
			if (timeout && (A_TickCount - startTime > timeout)) {
				this.CleanupGuis()
				return 0
			}
			Sleep(10)
		}
		return this.result
	}

	CleanupGuis() {
		for gui in this.guis
			gui.Destroy()
		this.guis := []
	}

	__Delete() {
		this.CleanupGuis()
	}
}
; --------------------------------------------------------------------------

class CleanInputBox {

	; Default settings
	static Defaults := {
		fontSize: 12,
		quality: 5,
		color: StrReplace(StrLower(GuiColors.VSCode.TextNormal), '#', ''),
		font: 'Consolas',
		width: Round(A_ScreenWidth / 3),
		topMargin: Round(A_ScreenHeight / 1080 * 800),
		backgroundColor: '0xA2AAAD'
	}

	; Instance properties
	gui := ""
	InputField := ""
	Input := ""
	isWaiting := true
	settings := Map()

	/**
		* Handle direct calls to the class (e.g., CleanInputBox())
		* @param {String} name Method name (empty for direct calls)
		* @param {Array} params Parameters passed to the call
		* @returns {String} User input or empty string if cancelled
		*/
	static __Call(name, params) {
		if (name = "") {  ; Called directly as a function
			instance := CleanInputBox(params*)
			return instance.WaitForInput()
		}
	}

	__New(p1 := "", p2 := "", p3 := "") {
		; Parse parameters into settings
		this.settings := this.ParseParams(p1, p2, p3)
		
		; Create GUI
		this.gui := Gui('+AlwaysOnTop -Caption +Border')
		
		; Apply styling using Gui2 methods
		this.gui.DarkMode(this.settings.Get('backgroundColor', CleanInputBox.Defaults.backgroundColor))
		
		; Set font
		this.gui.SetFont(
			's' this.settings.Get('fontSize', CleanInputBox.Defaults.fontSize) 
			' q' this.settings.Get('quality', CleanInputBox.Defaults.quality) 
			' c' this.settings.Get('color', CleanInputBox.Defaults.color),
			this.settings.Get('font', CleanInputBox.Defaults.font)
		)
		
		; Setup GUI properties
		this.gui.MarginX := 0

		; Add input field
		this.InputField := this.gui.AddEdit(
			'x0 Center -E0x200 Background' this.gui.BackColor 
			' w' this.settings.Get('width', CleanInputBox.Defaults.width)
		)

		; Setup event handlers
		this.RegisterHotkeys()

		; this.WaitForInput()
	}

	static WaitForInput(){
		return CleanInputBox().WaitForInput()
	}

	ParseParams(p1 := "", p2 := "", p3 := "") {
		settings := Map()
		
		; If first parameter is object/map, use as settings
		if IsObject(p1) {
			for key, value in (p1 is Map ? p1 : p1.OwnProps()) {
				settings[key] := value
			}
			return settings
		}

		; Otherwise only add parameters that were actually provided
		if (p1 != "")
			settings['fontSize'] := p1
		if (p2 != "")
			settings['color'] := (SubStr(p2, 1, 1) = 'c' ? p2 : 'c' p2)
		if (p3 != "")
			settings['quality'] := p3
			
		return settings
	}

	WaitForInput() {
		this.gui.Show('y' this.settings.Get('topMargin', CleanInputBox.Defaults.topMargin) 
			' w' this.settings.Get('width', CleanInputBox.Defaults.width))
			
		while this.isWaiting {
			Sleep(A_Delay)
		}
		return this.Input
	}

	RegisterHotkeys() {
		HotIfWinactive('ahk_id ' this.gui.Hwnd)
		Hotkey('Enter', (*) => (this.Input := this.InputField.Text, this.isWaiting := false, this.Finish()), 'On')
		Hotkey('CapsLock', (*) => (this.isWaiting := false, this.Finish()))
		this.gui.OnEvent('Escape', (*) => (this.isWaiting := false, this.Finish()))
	}

	Finish() {
		HotIfWinactive('ahk_id ' this.gui.Hwnd)
		Hotkey('Enter', 'Off')
		this.gui.Minimize()
		this.gui.Destroy()
	}
}
;@endregion
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
;@region Class Infos
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
		textColor := StrReplace(GuiColors.VSCode.TextNormal, '#', '')
		this.gui.DarkMode()
		this.MakeFontNicer(Infos.fontSize , ' ' textColor)
		this.gui.NeverFocusWindow()
		this.gcText := this.gui.AddText(, this._FormatText())
		return this
	}

	DarkMode(BackgroundColor := '') {
		this.gui.BackColor := BackgroundColor = '' ? '0xA2AAAD' : BackgroundColor
		return this
	}

	MakeFontNicer(fontSize, params*) {
		if !IsSet(fontSize) {
			fontSize := 20
		}
		for param in params {
			if GuiColors.HasProp(param) {
				if param ~= '#' {
					StrReplace(param, '#', '0x')
					this.gui.SetFont(' ' param)
				}
				this.gui.SetFont('s' fontSize, 'Consolas')
			}

		}
		this.gui.SetFont('s' fontSize, 'Consolas')
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
;@endregion
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
;@region MsgBox()
/**
* @name MsgBox()
* @abstract Enhanced MsgBox with return value tracking and adaptive sizing
* @version 1.1.0
* @author OvercastBTC
* @date 2025-04-15
* @param {...*} params Variable parameters:
*    - Text: The message to display
*    - Title: The window title
*    - Options: Button configuration ("OK", "OKCancel", "YesNo", etc.)
*    - Owner: Owner window handle
* @returns {String} The button clicked: "OK", "Cancel", "Yes", "No", "Retry", "Abort", or "Ignore"
*/
; MsgBox(params*) {
; 	; Parse parameters based on MsgBox standard
; 	text := "", title := "", options := "OKCancel", owner := "" ; Default to OKCancel
; 	result := ""
	
; 	; Check if first parameter is text or options
; 	if (params.Length >= 1) {
; 		if (params[1] is Integer) || (InStr("OKCancel,YesNo,YesNoCancel,RetryCancel,AbortRetryIgnore", params[1])) {
; 			options := params[1]
; 		} else {
; 			text := params[1]
; 		}
; 	}
	
; 	; Check additional parameters
; 	if (params.Length >= 2) {
; 		if (options != "OKCancel") { ; Only use params[2] as text if explicit options given
; 			text := params[2] 
; 			if (params.Length >= 3)
; 				title := params[3]
; 		} else {
; 			title := params[2]
; 			if (params.Length >= 3)
; 				options := params[3]
; 		}
; 	}
	
; 	; Check for owner window
; 	if (params.Length >= 4) {
; 		owner := params[4]
; 	}

; 	; Create GUI with Gui2 enhancements
; 	mbGui := Gui("+AlwaysOnTop +Owner" owner)
; 	mbGui.Title := title ? title : "Message"
	
; 	; Apply Gui2 styling
; 	mbGui.MakeFontNicer(10, StrReplace(GuiColors.VSCode.TextNormal, '#, 0x'))
	
; 	; Calculate text metrics
; 	textWidth := 400 ; Default width
	
; 	; Calculate text dimensions based on content
; 	lineCount := 1
	
; 	; Count actual newlines in text
; 	if (InStr(text, "`n")) {
; 		lineCount := StrSplit(text, "`n", "`r").Length
; 	}
	
; 	; Estimate average character width (~8px per char at size 10)
; 	avgCharWidth := 8
	
; 	; Estimate if text will wrap
; 	maxLineLength := 0
; 	totalTextLength := StrLen(text)
	
; 	; Get longest line
; 	if (lineCount > 1) {
; 		lines := StrSplit(text, "`n", "`r")
; 		for line in lines {
; 			maxLineLength := Max(maxLineLength, StrLen(line))
; 		}
; 	} else {
; 		maxLineLength := totalTextLength
; 	}
	
; 	; Adjust width for very long text
; 	if (maxLineLength > 50) {
; 		textWidth := Min(800, 20 + maxLineLength * avgCharWidth)
; 	}
	
; 	; Estimate text height based on line count and wrap
; 	estWrappedLines := Ceil((maxLineLength * avgCharWidth) / textWidth)
; 	totalLines := Max(lineCount, estWrappedLines)
	
; 	; Calculate edit box height (height per line ~20px at size 10)
; 	lineHeight := 20
; 	boxHeight := Max(60, totalLines * lineHeight)
	
; 	; Add edit control for selectable text with calculated dimensions
; 	label := mbGui.AddEdit("w" textWidth " h" boxHeight " ReadOnly -E0x200 Center", text)
	
; 	; Parse button options using ButtonRow helper class
; 	buttons := ButtonRow.ParseButtons(options)
	
; 	; Use GuiButtonProperties to calculate button width based on text
; 	buttonWidth := mbGui.SetButtonWidth(buttons)
; 	spacing := 10
	
; 	; Calculate total width needed for buttons
; 	totalButtonWidth := (buttons.Length * buttonWidth) + ((buttons.Length - 1) * spacing)
; 	mbWidth := Max(textWidth + 20, totalButtonWidth + 40)
	
; 	; Position buttons below text
; 	startX := (mbWidth - totalButtonWidth) / 2
; 	label.GetPos(&lX, &lY, &lW, &lH)
; 	startY := lY + lH + 10
	
; 	; Add buttons with click handlers
; 	for index, buttonText in buttons {
; 		x := startX + ((index - 1) * (buttonWidth + spacing))
; 		btn := mbGui.AddButton(Format("x{1} y{2} w{3}", x, startY, buttonWidth), buttonText)
; 		btn.OnEvent("Click", GuiClickHandler)
; 	}

; 	; Show GUI centered
; 	mbGui.Show("w" mbWidth " AutoSize Center")
	
; 	; Register close event handler
; 	mbGui.OnEvent("Close", (*) => (result := "Cancel"))
	
; 	; Wait for result
; 	while !result {
; 		Sleep(10)
; 		if !WinExist(mbGui.Hwnd) {
; 			result := "Cancel"  ; Handle window closed via X button
; 			break
; 		}
; 	}

; 	; Clean up
; 	try mbGui.Destroy()
; 	catch Error as e {
; 		; Ignore errors if GUI is already destroyed
; 		ErrorLogger.Log("MsgBox cleanup error (ignorable): " e.Message, false)
; 	}
	
; 	return result

; 	GuiClickHandler(ctrl, *) {
; 		result := ctrl.Text
; 		mbGui.Hide()
; 	}
; }

; /**
; * Enhanced MsgBox with return value tracking
; * @param {...*} params Variable parameters:
; *    - Text: The message to display
; *    - Title: The window title
; *    - Options: Button configuration ("OK", "OKCancel", "YesNo", etc.)
; *    - Owner: Owner window handle
; * @returns {String} The button clicked: "OK", "Cancel", "Yes", "No", "Retry", "Abort", or "Ignore"
; */
; MsgBox(params*) {
; 	; Parse parameters based on MsgBox standard
; 	text := "", title := "", options := "OKCancel", owner := "" ; Default to OKCancel
; 	result := ""
	
; 	; Check if first parameter is text or options
; 	if (params.Length >= 1) {
; 		if (params[1] is Integer) || (InStr("OKCancel,YesNo,YesNoCancel,RetryCancel,AbortRetryIgnore", params[1])) {
; 			options := params[1]
; 		} else {
; 			text := params[1]
; 		}
; 	}
	
; 	; Check additional parameters
; 	if (params.Length >= 2) {
; 		if (options != "OKCancel") { ; Only use params[2] as text if explicit options given
; 			text := params[2] 
; 			if (params.Length >= 3)
; 				title := params[3]
; 		} else {
; 			title := params[2]
; 			if (params.Length >= 3)
; 				options := params[3]
; 		}
; 	}
	
; 	; Check for owner window
; 	if (params.Length >= 4) {
; 		owner := params[4]
; 	}

; 	; Create GUI
; 	mbGui := Gui("+AlwaysOnTop +Owner" owner)
; 	mbGui.Title := title ? title : "Message"
; 	mbGui.SetFont("s10", "Segoe UI")
	
; 	; Add edit control for selectable text
; 	label := mbGui.AddEdit("r3 w300 ReadOnly Center", text)
	
; 	; Add buttons using ButtonRow helper
; 	buttons := ButtonRow.ParseButtons(options) 
; 	buttonWidth := 80
; 	spacing := 10
; 	totalWidth := (buttons.Length * buttonWidth) + ((buttons.Length - 1) * spacing)
; 	startX := (300 - totalWidth) / 2  ; Center buttons
; 	startY := label.GetPos(&lX, &lY, &lW, &lH)
	
; 	; Add buttons with click handlers
; 	for index, buttonText in buttons {
; 		x := startX + ((index - 1) * (buttonWidth + spacing))
; 		btn := mbGui.AddButton(Format("x{1} y{2} w{3}", x, 's+' lH, buttonWidth), buttonText)
; 		btn.OnEvent("Click", GuiClickHandler)
; 	}

; 	; Show GUI centered
; 	mbGui.Show("AutoSize Center")
	
; 	; Register close event handler
; 	mbGui.OnEvent("Close", (*) => (result := "Cancel"))
	
; 	; Wait for result
; 	while !result {
; 		Sleep(10)
; 		if !WinExist(mbGui.Hwnd) {
; 			result := "Cancel"  ; Handle window closed via X button
; 			break
; 		}
; 	}

; 	; Clean up
; 	try mbGui.Destroy()
; 	catch Error {
; 		; Ignore errors if GUI is already destroyed
; 	}
	
; 	return result

; 	GuiClickHandler(ctrl, *) {
; 		result := ctrl.Text
; 	}
; }
;@endregion
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
;@region Class ButtonRow


/**
* @class ButtonRow
* @description Helper class for button management in message boxes
* @version 1.0.0
* @author OvercastBTC
*/
;;@class
class ButtonRow {
	static ParseButtons(options) {
		if (options = "OKCancel" || options = 1)
			return ["OK", "Cancel"]
		else if (options = "YesNo" || options = 4) 
			return ["Yes", "No"]
		else if (options = "YesNoCancel" || options = 3)
			return ["Yes", "No", "Cancel"] 
		else if (options = "RetryCancel" || options = 5)
			return ["Retry", "Cancel"]
		else if (options = "AbortRetryIgnore" || options = 2) 
			return ["Abort", "Retry", "Ignore"]
		return ["OK"]
	}
}

;@region Class Resizer
/**
	* @class Resizer
	* @description Enhanced GUI resizing and control layout management class for AHKv2
	* @author Fanatic Guru, Overcast
	* @version 2024.03.15
	* @requires AutoHotkey v2.0.2+
	* @example
	* ; Basic usage
	* myGui := Gui()
	* myGui.OnEvent("Size", Resizer) 
	* 
	* ; With positioning options
	* ctrl := myGui.AddButton("w100 h30", "Click")
	* ctrl.Resizer := {x: 0.5, y: 0.5} ; Center position
	*/

class Resizer {
	
	; Initialize base properties
	static VERSION := "2024.03.15"
	static AUTHOR := "Fanatic Guru, Overcast"
	static Last := ''
	
	; Initialize properties method
	InitializeProperties() {
		for prop, type in this.Properties {
			switch type {
				case "number": this.%prop% := 0
				case "boolean": this.%prop% := false
				default: this.%prop% := ""
			}
		}
	}
	static LastDimensions := Map()
	static instances := Map()
	
	; Property definitions with validation 
	static Properties := {
		; Core positioning
		X: "number",          ; X positional offset 
		Y: "number",          ; Y positional offset
		W: "number",          ; Width
		H: "number",          ; Height
		
		; Percentage based
		XP: "number",         ; X position as percentage
		YP: "number",         ; Y position as percentage
		WP: "number",         ; Width as percentage
		HP: "number",         ; Height as percentage
		
		; Constraints
		MinX: "number",       ; Minimum X offset
		MaxX: "number",       ; Maximum X offset
		MinY: "number",       ; Minimum Y offset
		MaxY: "number",       ; Maximum Y offset
		MinW: "number",       ; Minimum width
		MaxW: "number",       ; Maximum width
		MinH: "number",       ; Minimum height
		MaxH: "number",       ; Maximum height
		
		; Behavior flags
		Mode: "string",       ; "simple" or "advanced" resizing mode
		Cleanup: "boolean",   ; Redraw control flag
		AnchorIn: "boolean"   ; Restrict to anchor bounds
	}

	; Instance properties - combined from both implementations
	__New(GuiObj, params*) {
		; Allow flexible initialization
		config := {
			interval: 100,
			stopCount: 6,
			setSizerImmediately: true,
			dpiAwareness: -2,
			mode: "simple"    ; Default to simple mode for backward compatibility
		}

		; Parse parameters
		try if params.Length {
			if IsObject(params[1]) {
				; Handle object configuration
				for k, v in params[1].OwnProps()
					config.%k% := v
			} else {
				; Handle legacy parameter style
				config.interval := params.Has(1) ? params[1] : 100
				config.stopCount := params.Has(2) ? params[2] : 6
				config.setSizerImmediately := params.Has(3) ? params[3] : true
				config.dpiAwareness := params.Has(4) ? params[4] : -2
			}
		}

		; Initialize core properties
		this.InitializeProperties()
		Resizer.Last := this
		
		; Setup instance properties
		this.interval := config.interval
		this.expiredCtrls := []
		this.deltaW := this.deltaH := 0
		this.stopCount := config.stopCount
		this.guiObj := GuiObj
		this.mode := config.mode

		; Initialize size tracking
		this.active := {
			zeroCount: 0,
			lastW: 0,
			lastH: 0,
			w: 0,
			h: 0
		}

		; Control containers
		this.size := []
		this.move := []
		this.moveAndSize := []

		; DPI handling
		this.currentDPI := this.dpi := DllCall("User32\GetDpiForWindow", "Ptr", GuiObj.Hwnd, "UInt")
		this.setThreadDpiAwarenessContext := config.dpiAwareness

		; Get initial dimensions
		GuiObj.GetClientPos(,, &gw, &gh)
		this.shown := DllCall('IsWindowVisible', 'Ptr', GuiObj.Hwnd)
		this.active.w := gw
		this.active.h := gh

		; Setup event handling
		if config.setSizerImmediately
			GuiObj.OnEvent('size', this)
	}
	
	/**
		* Call handler for resize events
		* @param {Gui} GuiObj GUI being resized 
		* @param {Integer} MinMax Window state
		* @param {Integer} Width New width
		* @param {Integer} Height New height
		*/
	static Call(GuiObj, MinMax, Width, Height) {
		
		; Skip if minimized
		if (MinMax = -1) {
			return
		}
		
		; Cache dimensions
		; Initialize dimensions if not cached
		if (!this.LastDimensions.Has(GuiObj.Hwnd)) {
			GuiObj.GetClientPos(,,&gw, &gh)
			this.LastDimensions[GuiObj.Hwnd] := {w: gw, h: gh}
			return ; Initial call, store dimensions and exit
		}

		; Skip processing if minimized or no dimensions changed
		GuiObj.GetClientPos(,,&gw, &gh)
		if (MinMax = -1 || (gw = this.LastDimensions[GuiObj.Hwnd].w && gh = this.LastDimensions[GuiObj.Hwnd].h)) {
			return
		}

		; Cache current dimensions
		try {
			lastW := this.LastDimensions[GuiObj.Hwnd].w
			lastH := this.LastDimensions[GuiObj.Hwnd].h
		} catch Error as e {
			ErrorLogger.Log('Error accessing dimensions: ' e.Message)
			return
		}
		
		; Calculate deltas
		last := this.LastDimensions[GuiObj.Hwnd] 
		deltaW := Width - last.w
		deltaH := Height - last.h
		
		; Resize controls
		for ctrl in GuiObj {
			if (!ctrl.HasProp("Resizer")) {
				continue 
			}
			
			this.ResizeControl(ctrl, deltaW, deltaH)
		}
		
		; Update cache
		this.LastDimensions[GuiObj.Hwnd] := {w: Width, h: Height}
	}
	
	/**
		* Resize a single control
		* @param {GuiControl} ctrl Control to resize
		* @param {Integer} deltaW Width change
		* @param {Integer} deltaH Height change 
		*/
	static ResizeControl(ctrl, deltaW, deltaH) {
		
		r := ctrl.Resizer
		ctrl.GetPos(&x, &y, &w, &h)
		
		; Calculate new position/size
		newX := x + (r.HasProp("x") ? deltaW * r.x : 0) 
		newY := y + (r.HasProp("y") ? deltaH * r.y : 0)
		newW := w + (r.HasProp("w") ? deltaW * r.w : 0)
		newH := h + (r.HasProp("h") ? deltaH * r.h : 0)
		
		; Apply min/max constraints
		if (r.HasProp("minW")) {
			newW := Max(r.minW, newW)
		}
		if (r.HasProp("maxW")) {
			newW := Min(r.maxW, newW)
		}
		if (r.HasProp("minH")) {
			newH := Max(r.minH, newH)
		}
		if (r.HasProp("maxH")) {
			newH := Min(r.maxH, newH)
		}
		
		; Move and resize
		ctrl.Move(newX, newY, newW, newH)
		
		; Handle cleanup
		if (r.HasProp("cleanup") && r.cleanup) {
			ctrl.Redraw()
		}
	}
	
	/**
		* Add resize behavior to a control
		* @param {GuiControl} ctrl Control to add resize behavior to
		* @param {Object} opts Resize options
		*/
	static AddControl(ctrl, opts) {
		ctrl.Resizer := opts
	}
	
	/**
		* Remove resize behavior from a control
		* @param {GuiControl} ctrl Control to remove resize from
		*/
	static RemoveControl(ctrl) {
		ctrl.DeleteProp("Resizer")
	}
	
	/**
		* Update resize options for a control
		* @param {GuiControl} ctrl Control to update
		* @param {Object} newOpts New resize options
		*/
	static UpdateControl(ctrl, newOpts) {
		if (!ctrl.HasProp("Resizer")) {
			ctrl.Resizer := {}
		}
		for k,v in newOpts.OwnProps() {
			ctrl.Resizer.%k% := v
		}
	}
	
	/**
		* Reset resize cache for a GUI
		* @param {Gui} GuiObj GUI to reset cache for
		*/
	static ResetCache(GuiObj) {
		this.LastDimensions.Delete(GuiObj.Hwnd)
	}
	
	/**
		* Force a resize event
		* @param {Gui} GuiObj GUI to resize
		*/
	static ForceResize(GuiObj) {
		GuiObj.GetClientPos(,,&w,&h)
		this.Call(GuiObj, 0, w, h)
	}
	
	/**
		* Add common alignment presets
		* @param {GuiControl} ctrl Control to align
		* @param {String} preset Alignment preset name
		*/
	static AddPreset(ctrl, preset) {
		static presets := {
			TopLeft: {x: 0, y: 0},
			TopCenter: {x: 0.5, y: 0},
			TopRight: {x: 1, y: 0},
			CenterLeft: {x: 0, y: 0.5},
			Center: {x: 0.5, y: 0.5},
			CenterRight: {x: 1, y: 0.5},
			BottomLeft: {x: 0, y: 1},
			BottomCenter: {x: 0.5, y: 1},
			BottomRight: {x: 1, y: 1}
		}
		
		if (!presets.HasOwnProp(preset)) {
			throw ValueError("Invalid preset name", -1)
		}
		
		this.AddControl(ctrl, presets.%preset%)
	}

	/**
		* Set resizing mode
		* @param {String} mode "simple" or "advanced"
		* @returns {Resizer} This instance for chaining
		*/
	SetMode(mode) {
		if (!(mode ~= "i)^(simple|advanced)$"))
			throw ValueError("Invalid mode. Use 'simple' or 'advanced'")
		
		this.mode := mode
		return this
	}

	/**
		* Call handler that routes to appropriate resize method based on mode
		*/
	Call(GuiObj, MinMax, Width, Height) {
		if this.mode = "simple"
			this.SimpleResize(GuiObj, MinMax, Width, Height)
		else
			this.AdvancedResize(GuiObj, MinMax, Width, Height)
	}

	/**
		* SimpleResize - Original resize method
		* @param {Gui} GuiObj GUI being resized
		* @param {Integer} MinMax Window state
		* @param {Integer} Width New width
		* @param {Integer} Height New height
		*/
	SimpleResize(GuiObj, MinMax, Width, Height) {
		; Skip if minimized
		if (MinMax = -1)
			return

		; Cache dimensions
		GuiObj.GetClientPos(,,&gw, &gh)
		if (!this.LastDimensions.Has(GuiObj.Hwnd)) {
			this.LastDimensions[GuiObj.Hwnd] := {w: gw, h: gh}
			return
		}

		; Calculate deltas
		last := this.LastDimensions[GuiObj.Hwnd]
		deltaW := Width - last.w
		deltaH := Height - last.h

		; Resize controls
		for ctrl in GuiObj {
			if (!ctrl.HasProp("Resizer"))
				continue
			this.ResizeControl(ctrl, deltaW, deltaH)
		}

		; Update cache
		this.LastDimensions[GuiObj.Hwnd] := {w: Width, h: Height}
	}

	/**
		* AdvancedResize - Enhanced resize method with DPI awareness and timer
		* @param {Gui} GuiObj GUI being resized
		* @param {Integer} MinMax Window state
		* @param {Integer} Width New width
		* @param {Integer} Height New height
		*/
	AdvancedResize(GuiObj, MinMax, Width, Height) {
		if !this.Shown {
			this.GuiObj.GetClientPos(,, &gw, &gh)
			if gw <= 20
				return
			this.Active.W := gw, this.Active.H := gh
			this.Shown := 1
		}

		; Handle initial show
		if this.HasOwnProp('JustShown') {
			this.DeleteProp('JustShown')
			return
		}

		; DPI handling
		DPI := DllCall("User32\GetDpiForWindow", "Ptr", this.GuiObj.Hwnd, "UInt")
		if this.DPI != DPI {
			this.DPI := DPI
			return
		}

		; Setup resize timer
		this.GuiObj.OnEvent('Size', this, 0)
		SetTimer(this._Resize, this.Interval)
		this._TimeredResize()
	}

	/**
		* Internal timer-based resize handler
		* @private
		*/
	_TimeredResize(*) {
		if this.SetThreadDpiAwarenessContext
			DllCall("SetThreadDpiAwarenessContext", "ptr", this.SetThreadDpiAwarenessContext, "ptr")

		this.GuiObj.GetClientPos(,, &gw, &gh)
		
		; Check for no changes
		if !(gw - this.Active.LastW) && !(gh - this.Active.LastH) {
			if ++this.Active.ZeroCount >= this.StopCount {
				SetTimer(this._Resize, 0)
				if this.ExpiredCtrls.Length
					this.HandleExpiredCtrls()
				this.GuiObj.OnEvent('Size', this)
			}
			return
		}

		; Calculate deltas and resize
		this.DeltaW := gw - this.Active.W
		this.DeltaH := gh - this.Active.H
		this.IterateCtrlContainers(_Size, _Move, _MoveAndSize)
		this.Active.LastW := gw, this.Active.LastH := gh

		_Size(Ctrl) {
			if !Ctrl.HasOwnProp('Resizer') {
				this.ExpiredCtrls.Push(Ctrl)
				return
			}
			this.GetDimensions(Ctrl, &W, &H)
			Ctrl.Move(,, W, H)
		}

		_Move(Ctrl) {
			if !Ctrl.HasOwnProp('Resizer') {
				this.ExpiredCtrls.Push(Ctrl)
				return
			}
			this.GetCoords(Ctrl, &X, &Y)
			Ctrl.Move(X, Y)
		}

		_MoveAndSize(Ctrl) {
			if !Ctrl.HasOwnProp('Resizer') {
				this.ExpiredCtrls.Push(Ctrl)
				return
			}
			this.GetCoords(Ctrl, &X, &Y), this.GetDimensions(Ctrl, &W, &H)
			Ctrl.Move(X, Y, W, H)
		}
	}

		/**
		* Get both coordinates and dimensions for a control
		* @param {GuiControl} ctrl Control to get measurements for
		* @param {Integer} &X X coordinate output
		* @param {Integer} &Y Y coordinate output  
		* @param {Integer} &W Width output
		* @param {Integer} &H Height output
		*/
	GetMeasurements(Ctrl, &X, &Y, &W, &H) {
		; Use existing helpers
		this.GetCoords(Ctrl, &X, &Y)
		this.GetDimensions(Ctrl, &W, &H)
	}
	
	/**
		* Calculate percentage-based coordinates
		* @param {GuiControl} ctrl Control to calculate for
		* @param {Integer} &X X coordinate output 
		* @param {Integer} &Y Y coordinate output
		*/
	GetPercentCoords(Ctrl, &X, &Y) {
		r := Ctrl.Resizer
		
		; Calculate percentage-based positions
		if r.HasProp("XP")
			X := this.GuiObj.ClientWidth * r.XP
		if r.HasProp("YP") 
			Y := this.GuiObj.ClientHeight * r.YP
			
		; Apply min/max constraints
		if r.HasProp("MinX")
			X := Max(r.MinX, X)
		if r.HasProp("MaxX")
			X := Min(r.MaxX, X)
		if r.HasProp("MinY")
			Y := Max(r.MinY, Y)
		if r.HasProp("MaxY")
			Y := Min(r.MaxY, Y)
	}
	
	/**
		* Calculate percentage-based dimensions
		* @param {GuiControl} ctrl Control to calculate for
		* @param {Integer} &W Width output
		* @param {Integer} &H Height output
		*/
	GetPercentDimensions(Ctrl, &W, &H) {
		r := Ctrl.Resizer
		
		; Calculate percentage-based sizes
		if r.HasProp("WidthP")
			W := this.GuiObj.ClientWidth * r.WidthP
		if r.HasProp("HeightP")
			H := this.GuiObj.ClientHeight * r.HeightP
			
		; Apply min/max constraints
		if r.HasProp("MinWidth")
			W := Max(r.MinWidth, W)
		if r.HasProp("MaxWidth")
			W := Min(r.MaxWidth, W)
		if r.HasProp("MinHeight")
			H := Max(r.MinHeight, H)
		if r.HasProp("MaxHeight")
			H := Min(r.MaxHeight, H)
	}
	
	/**
		* Update the mode-specific resize settings
		* @param {String} mode Resize mode ("simple"|"advanced")
		* @param {Object} options Optional configuration
		*/
	UpdateResizeMode(mode, options?) {
		this.mode := mode
		
		if IsSet(options) {
			if this.mode = "advanced" {
				; Advanced mode settings
				this.interval := options.HasProp("interval") ? options.interval : 100
				this.stopCount := options.HasProp("stopCount") ? options.stopCount : 6
				this.setThreadDpiAwarenessContext := options.HasProp("dpiAwareness") ? options.dpiAwareness : -2
			} else {
				; Simple mode settings
				this.interval := 0  ; Disable timer
				this.stopCount := 0
				this.setThreadDpiAwarenessContext := 0  ; Disable DPI awareness
			}
		}
		
		; Reset state for mode change
		this.active.zeroCount := 0
		this.active.lastW := 0
		this.active.lastH := 0
		
		return this
	}

	/**
		* Set the minimum size for the resizer
		* @param {Integer} minWidth Minimum width
		* @param {Integer} minHeight Minimum height
		*/
	SetMinSize(minWidth, minHeight) {
		this.minWidth := minWidth
		this.minHeight := minHeight
	}

	/**
		* Set anchor point for a control
		* @param {GuiControl} ctrl Control to anchor
		* @param {GuiControl} anchor Control to anchor to
		* @param {String} position Anchor position (e.g., "top", "left", etc)
		*/
	SetAnchor(ctrl, anchor, position) {
		if !IsObject(ctrl.Resizer)
			ctrl.Resizer := {}
			
		ctrl.Resizer.Anchor := anchor
		ctrl.Resizer.AnchorPosition := position
		
		; Calculate relative positioning
		ctrl.GetPos(&cx, &cy, &cw, &ch)
		anchor.GetPos(&ax, &ay, &aw, &ah)
		
		; Store relative offsets
		switch position {
			case "top":
				ctrl.Resizer.y := cy - ay
			case "bottom":
				ctrl.Resizer.y := (ay + ah) - (cy + ch)
			case "left":
				ctrl.Resizer.x := cx - ax
			case "right":
				ctrl.Resizer.x := (ax + aw) - (cx + cw)
		}
		
		return this
	}
	
	/**
		* Handle controls in a container
		* @param {Array} container Array of controls
		* @param {Function} callback Processing callback
		*/
	ProcessContainer(container, callback) {
		for ctrl in container {
			if !ctrl.HasProp("Resizer") {
				this.ExpiredCtrls.Push(ctrl)
				continue
			}
			
			try {
				callback(ctrl)
			} catch as err {
				; Log error but continue processing
				OutputDebug("Error processing control: " err.Message)
			}
		}
	}
}
;@endregion Resizer
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
;@region Class GuiResizer
/*
Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GuiResizer.ahk
Author: Nich-Cebolla
Version: 1.0.0
License: MIT
*/
/**
	* @class GuiReSizer - A class to handle GUI resizing and control layout management
	* @author Fanatic Guru, enhanced by OvercastBTC
	* @version 2024.03.15
	* @description Manages the resizing of GUI windows and repositioning of controls
	* @requires AutoHotkey v2.0.2+
	* @example
	* ; Basic usage
	* myGui := Gui()
	* myGui.OnEvent("Size", GuiReSizer) 
*/

; GuiResizer.Prototype.Base := _GuiResizer
class GuiResizer {
; class _GuiResizer {
	static Last := ''
	
	/**
	 * @description Initializes default properties for the resizer
	 * This method sets up the default properties needed by the resizer
	 */
	InitializeProperties() {
		; Set default properties
		this.Properties := {
			X: "number",
			Y: "number",
			W: "number",
			H: "number",
			XP: "number",
			YP: "number",
			WP: "number",
			HP: "number",
			MinX: "number",
			MaxX: "number",
			MinY: "number",
			MaxY: "number",
			MinW: "number",
			MaxW: "number",
			MinH: "number",
			MaxH: "number",
			Mode: "string",
			Cleanup: "boolean",
			AnchorIn: "boolean"
		}
		
		; Initialize property values
		for prop, type in this.Properties {
			switch type {
				case "number": this.%prop% := 0
				case "boolean": this.%prop% := false
				default: this.%prop% := ""
			}
		}
	}
	
	/**
		* @description - Creates a callback function to be used with
		* `Gui.Prototype.OnEvent('Size', Callback)`. This function requires a bit of preparation. See
		* the longer explanation within the source document for more information. Note that
		* `GuiResizer` modifies the `Gui.Prototype.Show` method slightly. This is the change:
		@example
		Gui.Prototype.DefineProp('Show', {Call: _Show})
		_Show(Self) {
			Show := Gui.Prototype.Show
			this.JustShown := 1
			Show(Self)
		}
		@
	* @param {Gui} GuiObj - The GUI object that contains the controls to be resized.
	* @param {Integer} [Interval=33] - The interval at which resizing occurs after initiated. Once
	* the `Size` event has been raised, the callback is set to a timer that loops every `Interval`
	* milliseconds and the event handler is temporarily disabled. After the function detects that
	* no size change has occurred within `StopCount` iterations, the timer is disabled and the
	* event handler is re-enabled. For more control over the visual appearance of the display as
	* resizing occurs, set `SetWinDelay` in the Auto-Execute portion of your script.
	* {@link https://www.autohotkey.com/docs/v2/lib/SetWinDelay.htm}
	* @param {Integer} [StopCount=6] - The number of iterations that must occur without a size
	* change before the timer is disabled and the event handler is re-enabled.
	* @param {Boolean} [SetSizerImmediately=true] - If true, the `Size` event is raised immediately
	* after the object is created. When this is true, you can call `GuiResizer` like a function:
	* `GuiResizer(ControlsArr)`. If you do need the instance object in some other portion of the
	* code or at some expected later time, the last instance created is available on the class
	* object `GuiResizer.Last`.
	* @param {Integer} [UsingSetThreadDpiAwarenessContext=-2] - The DPI awareness context to use.
	* This is necessary as a parameter because, when using a THREAD_DPI_AWARENESS_CONTEXT other than
	* the default, AutoHotkey's behavior when returning values from built-in functions is
	* inconsistent unless the awareness context is set each time before calling the function.
	* Understand that if you leave the value at -4, the OS expects that you will handle DPI scaling
	* within your code. Set this parameter to 0 to disable THREAD_DPI_AWARENESS_CONTEXT.
	*/
	__New(GuiObj, Interval := 100, StopCount := 6, SetSizerImmediately := true, UsingSetThreadDpiAwarenessContext := -2) {
		GuiResizer.Last := this
		this.InitializeProperties()
		this.DefineProp('_Resize', {Call: ObjBindMethod(this, 'Resize')})
		GuiObj.DefineProp('Show', {Call: _Show})
		this.Interval := Interval
		this.ExpiredCtrls := []
		this.DeltaW := this.DeltaH := 0
		this.StopCount := StopCount
		this.GuiObj := GuiObj
		this.Active := {ZeroCount: 0, LastW: 0, LastH : 0}
		this.Size := []
		this.Move := []
		this.MoveAndSize := []
		this.CurrentDPI := this.DPI := DllCall("User32\GetDpiForWindow", "Ptr", GuiObj.Hwnd, "UInt")
		this.SetThreadDpiAwarenessContext := UsingSetThreadDpiAwarenessContext
		this.GuiObj.GetClientPos(, , &gw, &gh)
		this.Shown := DllCall('IsWindowVisible', 'Ptr', GuiObj.Hwnd)
		this.Active.W := gw
		this.Active.H := gh
		; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, , 'Gui initial size: W' gw ' H' gh)
		for Ctrl in GuiObj {
			if !Ctrl.HasOwnProp('Resizer')
				continue
			Resizer := Ctrl.Resizer, z := FlagSize := FlagMove := 0
			Ctrl.GetPos(&cx, &cy, &cw, &ch)
			Ctrl.Resizer.pos := {x: cx, y: cy, w: cw, h: ch}
			if Resizer.HasOwnProp('x')
				z += 1
			if Resizer.HasOwnProp('y')
				z += 2
			switch z {
				case 0:
					Resizer.x := 0, Resizer.y := 0
				case 1:
					Resizer.y := 0, FlagMove := 1
				case 2:
					Resizer.x := 0, FlagMove := 1
				case 3:
					FlagMove := 1
			}
			z := 0
			if Resizer.HasOwnProp('w')
				z += 1
			if Resizer.HasOwnProp('h')
				z += 2
			switch z {
				case 0:
					Resizer.w := 0, Resizer.h := 0
				case 1:
					Resizer.h := 0, FlagSize := 1
				case 2:
					Resizer.w := 0, FlagSize := 1
				case 3:
					FlagSize := 1
			}
			if FlagSize {
				if FlagMove
					this.MoveAndSize.Push(Ctrl)
				else
					this.Size.Push(Ctrl)
			} else if FlagMove
				this.Move.Push(Ctrl)
			else
				throw Error('A control has ``Resizer`` property, but the property does not have'
				'`r`na ``w``, ``h``, ``x``, or ``y`` property.', -1, 'Ctrl name: ' Ctrl.Name)

			_Show(Self) {
				Show := Gui.Prototype.Show
				this.JustShown := 1
				Show(Self)
			}
		}
		if SetSizerImmediately
			GuiObj.OnEvent('size', this)
	}

	Call(GuiObj, MinMax, Width, Height) {
		if !this.Shown {
			this.GuiObj.GetClientPos(,, &gw, &gh)
			if gw <= 20
				return
			this.Active.W := gw, this.Active.H := gh
			; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber,
			; , 'Gui shown for the first time. Size: W' gw ' H' gh)
			this.Shown := 1
		}
		if this.HasOwnProp('JustShown') {
			this.DeleteProp('JustShown')
			; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, , 'Gui just shown')
			return
		}
		DPI := DllCall("User32\GetDpiForWindow", "Ptr", this.GuiObj.Hwnd, "UInt")
		if this.DPI != DPI {
			; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber,
			; , 'Dpi changed. Old: ' this.DPI '`tNew: ' DPI '.')
			this.DPI := DPI
			return
		}
		this.GuiObj.OnEvent('Size', this, 0)
		; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, , 'Resize timer activated.')
		SetTimer(this._Resize, this.Interval)
		this.Resize()
	}

	IterateCtrlContainers(SizeCallback, MoveCallback, MoveAndResizeCallback) {
		for Ctrl in this.Size
			SizeCallback(Ctrl)
		for Ctrl in this.Move
			MoveCallback(Ctrl)
		for Ctrl in this.MoveAndSize
			MoveAndResizeCallback(Ctrl)
	}

	IterateAll(Callback) {
		this.IterateCtrlContainers(Callback, Callback, Callback)
	}

	Resize(*) {
		if this.SetThreadDpiAwarenessContext
			DllCall("SetThreadDpiAwarenessContext", "ptr", this.SetThreadDpiAwarenessContext, "ptr")
		this.GuiObj.GetClientPos(,, &gw, &gh)
		if !(gw - this.Active.LastW) && !(gh - this.Active.LastH) {
			; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber,
			; , 'No change since last tick. ZeroCount: ' this.Active.ZeroCount)
			if ++this.Active.ZeroCount >= this.StopCount {
				; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, , 'Disabling timer.')
				SetTimer(this._Resize, 0)
				if this.ExpiredCtrls.Length
					this.HandleExpiredCtrls()
				this.GuiObj.OnEvent('Size', this)
			}
			return
		}
		this.DeltaW := gw - this.Active.W
		this.DeltaH := gh - this.Active.H
		; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber,
		; , 'Resize function ticked. Size: W' gw ' H' gh)
		this.IterateCtrlContainers(_Size, _Move, _MoveAndSize)
		this.Active.LastW := gw, this.Active.LastH := gh

		_Size(Ctrl) {
			if !Ctrl.HasOwnProp('Resizer') {
				this.ExpiredCtrls.Push(Ctrl)
				return
			}
			; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'Before')
			this.GetDimensions(Ctrl, &W, &H)
			Ctrl.Move(,, W, H)
			; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'After')
		}

		_Move(Ctrl) {
			if !Ctrl.HasOwnProp('Resizer') {
				this.ExpiredCtrls.Push(Ctrl)
				return
			}
			; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'Before')
			this.GetCoords(Ctrl, &X, &Y)
			Ctrl.Move(X, Y)
			; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'After')
		}

		_MoveAndSize(Ctrl) {
			if !Ctrl.HasOwnProp('Resizer') {
				this.ExpiredCtrls.Push(Ctrl)
				return
			}
			; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'Before')
			this.GetCoords(Ctrl, &X, &Y), this.GetDimensions(Ctrl, &W, &H)
			Ctrl.Move(X, Y, W, H)
			; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'After')
		}
	}

	GetCoords(Ctrl, &X, &Y) {
		Resizer := Ctrl.Resizer, Pos := Resizer.Pos
		X := Resizer.X ? this.DeltaW * Resizer.X + Pos.X : Pos.X
		if X < 0
			X := 0
		Y := Resizer.Y ? this.DeltaH * Resizer.Y + Pos.Y : Pos.Y
		if Y < 0
			Y := 0
	}

	GetDimensions(Ctrl, &W, &H) {
		Resizer := Ctrl.Resizer, Pos := Resizer.Pos
		W := Resizer.W ? this.DeltaW * Resizer.W + Pos.W : Pos.W
		if W < 0
			W := 0
		H := Resizer.H ? this.DeltaH * Resizer.H + Pos.H : Pos.H
		if H < 0
			H := 0
	}

	HandleExpiredCtrls() {
		for Ctrl in this.ExpiredCtrls {
			FlagRemoved := 0
			for Container in [this.Size, this.Move, this.MoveAndSize] {
				for _Ctrl in Container {
					if Ctrl.Name == _Ctrl.Name {
						Container.RemoveAt(A_Index)
						FlagRemoved := 1
						break
					}
				}
				if FlagRemoved
					break
			}
			if FlagRemoved
				break
		}
	}

	/**
		* @description - Assigns the appropriate parameters to controls that are adjacent to one another.
		* The input controls must be aligned along one dimension; this method will not function as
		* expected if some are above others and also some are to the left or right of others. They must
		* be adjacent along a single axis. Use this when you have a small number of controls that you
		* want to be resized along with the GUI window. Be sure to handle any surrounding controls
		* so they don't overlap.
		* Here's some examples:

		||||| ||||| |||||             |     |||||||
		||||| ||||| |||||     - OK    |     |||||||         |||||   - NOT OK
		||||| ||||| |||||             |     |||||||         |||||
		_________________             |     |||||||
		||||        ||||              |
		||||        ||||     - OK     |         |||||
		||||                          |         |||||
			||||                    |         |||||
			||||                    |
			||||                    |
									|
		@example
			; You can run this example to see what it looks like
			GuiObj := Gui('+Resize -DPIScale')
			Controls := []
			Loop 4
				Controls.Push(GuiObj.Add('Edit', Format('x{} y{} w{} h{} vEdit{}'
				, 10 + 220 * (A_Index - 1), 10, 200, 400, A_Index)))
			GuiResizer.SetAdjacentControls(Controls)
			GuiResizer(GuiObj)
			GuiObj.Show()
		@
	* @param {Array} Controls - An array of controls to assign the appropriate parameters to.
	* @param {Boolean} Vertical - If true, the controls are aligned vertically; otherwise, they are aligned horizontally.
	* @param {Boolean} IncludeOpposite - If true, the opposite side of the control will be set to 1; otherwise, it will be set to 0.
	* @returns {Void}
	*/
	static SetAdjacentControls(Controls, Vertical := false, IncludeOpposite := true) {
		static Letters := Map('X', 'H', 'Y', 'W', '_X', 'W', '_Y', 'H')
		local Count := Controls.Length, Result := [], CDF := [], Order := []
		, X := Y := W := H := 0
		if Controls.Length < 2 {
			if Controls.Length
				Controls.Resizer := {w: 1, h: 1}, Result.Push(Controls)
			return
		}
		if Vertical
			_Refactored('Y')
		else
			_Refactored('X')

		_Refactored(X_Or_Y) {
			_GetCDF(1 / Count), Proportion := 1 / Count, _GetOrder(X_Or_Y)
			for Ctrl in Order
				Ctrl.Resizer := {}, Ctrl.Resizer.%Letters['_' X_Or_Y]% := Proportion, Ctrl.Resizer.%X_Or_Y% := CDF[A_Index]
				, Ctrl.Resizer.%Letters[X_Or_Y]% := IncludeOpposite ? 1 : 0
		}
		_GetCDF(Step) {
			Loop Count
				CDF.Push(Step * (A_Index - 1))
		}
		_GetOrder(X_Or_Y) {
			for Ctrl in Controls {
				Ctrl.GetPos(&x, &y, &w, &h)
				Ctrl.__Resizer := {x: x, y: y}
				Order.Push(Ctrl)
			}
			InsertionSort(Order, 1, , ((X_Or_Y, a, b) => a.__Resizer.%X_Or_Y% - b.__Resizer.%X_Or_Y%).Bind(X_Or_Y))
			InsertionSort(arr, start, end?, compareFn := (a, b) => a - b) {
				i := start - 1
				while ++i <= (end??arr.Length) {
					current := arr[i]
					j := i - 1
					while (j >= start && compareFn(arr[j], current) > 0) {
						arr[j + 1] := arr[j]
						j--
					}
					arr[j + 1] := current
				}
				return arr
			}
		}
	}

	/**
		* @description - Returns an integer representing the position of the first object relative
		* to the second object. This function assumes that the two objects do not overlap.
		* The inputs can be any of:
		* - A Gui object, Gui.Control object, or any object with an `Hwnd` property.
		* - An object with properties { L, T, R, B }.
		* - An Hwnd of a window or control.
		* @param {Integer|Object} Subject - The subject of the comparison. The return value indicates
		* the position of this object relative to the other.
		* @param {Integer|Object} Target - The object which the subject is compared to.
		* @returns {Integer} - Returns an integer representing the relative position shared between two objects.
		* The values are:
		* - 1: Subject is completely above target and completely to the left of target.
		* - 2: Subject is completely above target and neither completely to the right nor left of target.
		* - 3: Subject is completely above target and completely to the right of target.
		* - 4: Subject is completely to the right of target and neither completely above nor below target.
		* - 5: Subject is completely to the right of target and completely below target.
		* - 6: Subject is completely below target and neither completely to the right nor left of target.
		* - 7: Subject is completely below target and completely to the left of target.
		* - 8: Subject is completely below target and completely to the left of target.
		*/
	static GetRelativePosition(Subject, Target) {
		_Get(Subject, &L1, &T1, &R1, &B1)
		_Get(Target, &L2, &T2, &R2, &B2)
		if L1 < L2 && R1 < L2 {
			if B1 < T2
				return 1
			else if T1 > B2
				return 7
			else
				return 8
		} else if T1 < T2 && B1 < T2 {
			if L1 > R2
				return 3
			else
				return 2
		} else if L1 < R2
			return 6
		else if T1 < B2
			return 4
		else
			return 5

		_Get(Input, &L, &T, &R, &B) {
			if IsObject(Input) {
				if !Input.HasOwnProp('Hwnd') {
					L := Input.L, T := Input.T, R := Input.R, B := Input.B
					return
				}
				WinGetPos(&L, &T, &W, &H, Input.Hwnd)
			} else
				WinGetPos(&L, &T, &W, &H, Input)
			R := L + W, B := T + H
		}
	}

	static OutputDebug(Resizer, Fn, Line, Ctrl?, Extra?) {
		if IsSet(Ctrl) {
			Ctrl.GetPos(&cx, &cy, &cw, &ch)
			OutputDebug('`n'
				Format(
					'Function: {1}`tLine: {2}'
					'`nControl: {3}'
					'`nX: {4}`tY: {5}`tW: {6}`tH: {7}'
					'`nDeltaW: {8}`tDeltaH: {9}'
					'`nActiveW: {10}`tActiveH: {11}`tLastW: {12}`tLastH: {13}'
					'`nExtra: {14}'
					, Fn, Line, Ctrl.Name, cx, cy, cw, ch, Resizer.DeltaW, Resizer.DeltaH, Resizer.Active.W
					, Resizer.Active.H, Resizer.Active.LastW, Resizer.Active.LastH, Extra ?? ''
				)
			)
		} else {
			OutputDebug('`n'
				Format(
					'Function: {1}`tLine: {2}'
					'`nDeltaW: {3}`tDeltaH: {4}'
					'`nActiveW: {5}`tActiveH: {6}`tLastW: {7}`tLastH: {8}'
					'`nExtra: {9}'
					, Fn, Line, Resizer.DeltaW, Resizer.DeltaH, Resizer.Active.W, Resizer.Active.H
					, Resizer.Active.LastW, Resizer.Active.LastH, Extra ?? ''
				)
			)
		}
	}
}
;@endregion
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
;@region IL_IconManager

;@region IL_
/**
 * Helper function to create image list
 * @param {Integer} initialCount Initial count of images
 * @param {Integer} growCount Growth count
 * @param {Integer} flags Image list flags
 * @returns {Object} Image list handle
 */
IL_Create(initialCount := 10, growCount := 5, flags := 0) {
    return DllCall("Comctl32.dll\ImageList_Create", "Int", 16, "Int", 16, "UInt", flags | 0x21, "Int", initialCount, "Int", growCount, "Ptr")
}

/**
 * Add icon to image list
 * @param {Object} imageListID Image list handle
 * @param {String} filename File path
 * @param {Integer} iconNumber Icon index
 * @param {Boolean} resizeNonIcon Resize non-icon
 * @returns {Integer} Index of added icon
 */
IL_Add(imageListID, filename, iconNumber := 0, resizeNonIcon := false) {
    if !(FileExist(filename))
        return -1  ; File doesn't exist

    if (iconNumber > 0) {
        ; It's an icon or cursor
        handle := DllCall("LoadImage", "Ptr", 0, "Str", filename, "UInt", 1, "Int", 0, "Int", 0, "UInt", 0x10, "Ptr")
        result := DllCall("Comctl32.dll\ImageList_AddIcon", "Ptr", imageListID, "Ptr", handle, "Int")
        DllCall("DestroyIcon", "Ptr", handle)
        return result
    } else {
        ; Try as a bitmap
        handle := DllCall("LoadImage", "Ptr", 0, "Str", filename, "UInt", 0, "Int", 0, "Int", 0, "UInt", 0x10, "Ptr")
        result := DllCall("Comctl32.dll\ImageList_Add", "Ptr", imageListID, "Ptr", handle, "Ptr", 0, "Int")
        DllCall("DeleteObject", "Ptr", handle)
        return result
    }
}

/**
 * Get icon from image list
 * @param {Object} imageListID Image list handle
 * @param {Integer} index Icon index
 * @returns {Object} Icon handle
 */
IL_GetIcon(imageListID, index) {
    return DllCall("Comctl32.dll\ImageList_GetIcon", "Ptr", imageListID, "Int", index - 1, "UInt", 0, "Ptr")
}

/**
 * Get count of icons in image list
 * @param {Object} imageListID Image list handle
 * @returns {Integer} Count of icons
 */
IL_Count(imageListID) {
    return DllCall("Comctl32.dll\ImageList_GetImageCount", "Ptr", imageListID)
}

/**
 * Destroy image list
 * @param {Object} imageListID Image list handle
 * @returns {Boolean} Success state
 */
IL_Destroy(imageListID) {
    return DllCall("Comctl32.dll\ImageList_Destroy", "Ptr", imageListID)
}
;@endregion IL_
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
;@region Class IconManager
/**
	* @class IconManager
	* @description Centralized icon management for the rich text editor
	*/
class IconManager {
	; Static icon collections
	static Icons := {
		; Shell32.dll icons
		Shell: Map(
			"new", 1,           ; New document
			"open", 4,          ; Open folder
			"save", 259,        ; Save disk
			"print", 16,        ; Printer
			"cut", 131,         ; Scissors
			"copy", 133,        ; Copy/duplicate
			"paste", 134,       ; Clipboard
			"undo", 137,        ; Undo arrow
			"redo", 138,        ; Redo arrow
			"find", 22,         ; Search/find
			"help", 24,         ; Help/question mark
			"font", 157,        ; Font/text
			"bold", 138,        ; Format/style
			"settings", 277,    ; Settings/tools
			"rtf", 1           ; Document
		),

		; Unicode symbols
		Unicode: Map(
			"save", "💾",        ; Save
			"open", "📂",        ; Open folder
			"new", "📄",         ; New document
			"print", "🖨️",       ; Print
			"cut", "✂️",         ; Cut
			"copy", "📑",        ; Copy
			"paste", "📋",       ; Paste
			"undo", "↩️",        ; Undo
			"redo", "↪️",        ; Redo
			"bold", "𝐁",         ; Bold
			"italic", "𝐼",       ; Italic
			"underline", "U̲",    ; Underline
			"strike", "S̶",      ; Strikethrough
			"superscript", "X²", ; Superscript
			"subscript", "X₂"    ; Subscript
		),

		; Alignment options
		Alignment: {
			Modern: {
				Left: "⎗",
				Center: "⎘",
				Right: "⎙",
				Justify: "☰"
			},
			Unicode: {
				Left: "◀",
				Center: "◆",
				Right: "▶",
				Justify: "≡"
			},
			ASCII: {
				Left: "[|",
				Center: "|=|",
				Right: "|]",
				Justify: "≡"
			},
			ImageRes: {
				Left: 5536,
				Center: 5537,
				Right: 5538,
				Justify: 5539
			}
		}
	}

	/**
		* @description Load and apply icons to toolbar buttons
		* @param {Object} toolbar Toolbar object containing button references
		* @param {String} style Icon style to use ("Shell", "Unicode", or "Modern")
		* @returns {Object} Image list handle for shell icons
		*/
	static LoadIcons(toolbar, style := "Unicode") {
		; Initialize image lists
		shellIL := IL_Create(20)
		
		; Select icon style
		if (style = "Shell") {
			; Apply shell32.dll icons
			for name, index in IconManager.Icons.Shell {
				if (toolbar.HasProp(name . "Btn") && toolbar.%name%Btn) {
					IL_Add(shellIL, "shell32.dll", index)
					SendMessage(0x00F7, 1, IL_GetIcon(shellIL, IL_Count(shellIL)), toolbar.%name%Btn.Hwnd)
				}
			}
			return shellIL
		} 
		else if (style = "Unicode" || style = "Modern") {
			; Apply Unicode text as icons
			iconSet := IconManager.Icons.Unicode
			
			for name, symbol in iconSet {
				if (toolbar.HasProp(name . "Btn") && toolbar.%name%Btn) {
					; Update button text to Unicode symbol
					toolbar.%name%Btn.Text := symbol
				}
			}
			
			; Apply alignment icons specially
			alignStyle := style = "Modern" ? "Modern" : "Unicode"
			for action, symbol in IconManager.Icons.Alignment.%alignStyle% {
				btnName := "Align" . action . "Btn"
				if (toolbar.HasProp(btnName) && toolbar.%btnName%) {
					toolbar.%btnName%.Text := symbol
				}
			}
		}
		
		return shellIL
	}

	/**
		* @description Apply alignment icons to buttons using ImageList
		* @param {Object} toolbar Toolbar object
		* @param {Integer} IL ImageList handle
		*/
	static ApplyAlignmentIcons(toolbar, IL) {
		static BM_SETIMAGE := 0x00F7
		buttons := [
			toolbar.AlignLeftBtn,
			toolbar.AlignCenterBtn,
			toolbar.AlignRightBtn,
			toolbar.AlignJustifyBtn
		]
		
		for index, btn in buttons {
			SendMessage(BM_SETIMAGE, 1, IL_GetIcon(IL, index), btn.Hwnd)
		}
	}

	/**
		* @description Extract icon from resource or file
		* @param {String} source Source file
		* @param {Integer} index Icon index
		* @param {Integer} size Icon size
		* @returns {Integer} Icon handle
		*/
	static ExtractIcon(source, index, size := 32) {
		try {
			if (FileExist(source)) {
				return DllCall("Shell32\ExtractIconW", "Ptr", 0, "Str", source, "UInt", index, "Ptr")
			} else {
				; Try to extract from standard resources
				return DllCall("Shell32\ExtractIconW", "Ptr", 0, "Str", "shell32.dll", "UInt", index, "Ptr")
			}
		} catch {
			return 0
		}
	}

	/**
		* @description Apply icons to standard rich edit buttons
		* @param {Object} reObj RichEdit object
		* @param {String} style Icon style
		*/
	static ApplyStandardIconsToRichEdit(reObj, style := "Unicode") {
		; Standard buttons to process
		if (reObj.HasProp("toolbar") && IsObject(reObj.toolbar)) {
			this.LoadIcons(reObj.toolbar, style)
		}
	}
}
;@endregion
