#Requires AutoHotkey v2+
#Include <Includes\ObjectTypeExtensions>


Gui.Prototype.Base := Gui2

class Gui2 {
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

	static Layered() => this.MakeLayered()
	static ToolWindow() => this.MakeToolWindow()
	static AlwaysOnTop() => this.SetAlwaysOnTop()
	static AppWindow() => this.ForceTaskbarButton()
	static Transparent() => this.MakeClickThrough()
	static NoActivate() => this.PreventActivation()
	static NeverFocusWindow() => this.NoActivate()

	; static DarkMode(guiObj := this, BackgroundColor := '') {
	; static DarkMode(BackgroundColor := '') {
	; 	guiObj := this
	; 	if (guiObj is Gui) {
	; 		if (BackgroundColor = '') {
	; 			guiObj.BackColor := '0xA2AAAD'
	; 		} else {
	; 			guiObj.BackColor := BackgroundColor
	; 		}
	; 	}
	; 	return this
	; }
	static DarkMode(params*) {
		
		; Default background color
		; static backgroundColor := '0xA2AAAD'
		static backgroundColor := unset
		; guiObj := this
		static hexNeedle := '\b[0-9A-Fa-f]+\b'
		
		; Parse params array
		for param in params {

			if (param is Gui){
				guiObj := param
			}
			else if IsObject(param){
				continue    ; Skip other object types
			}
			else {
				; backgroundColor := param
				if !IsSet(backgroundColor) {
					if param ~= hexNeedle {
						backgroundColor := param
					}
					else {
						backgroundColor := '0xA2AAAD'
					}
				}
			}
		}
		
		if !IsSet(guiObj) {
			guiObj := this
		}
		if !IsSet(backgroundColor) {
			backgroundColor := '0xA2AAAD'
		}
		; Apply background color 
		if (guiObj is Gui){
			guiObj.BackColor := backgroundColor
		}

		; infos(backgroundColor)

		return guiObj
	}

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
	; static MakeFontNicer(options := "12 Q5", nFont := "Consolas") {
	; 	guiObj := this
	; 	; Default settings
	; 	size := 12
	; 	quality := 5
	; 	color := "1eff00"    ; Default color
		
	; 	; Parse options if provided
	; 	if (options) {
	; 		; Check for font size (s## or just ##)
	; 		if (RegExMatch(options, "i)s?(\d+)", &match))
	; 			size := match[1]
			
	; 		; Check for quality setting (Q#)
	; 		if (RegExMatch(options, "i)Q(\d+)", &match))
	; 			quality := match[1]
				
	; 		; Check for color (###### or 0x######)
	; 		if (RegExMatch(options, "i)c([0-9a-f]{6}|0x[0-9a-f]{6})", &match))
	; 			color := match[1]
	; 	}
		
	; 	; Build font string
	; 	fontString := Format("s{1} q{2} c{3}", size, quality, color)
		
	; 	; Set the font
	; 		if (guiObj is Gui) {
	; 		guiObj.SetFont(fontString, nFont)
	; 	}
		
	; 	return this
	; }
	; static MakeFontNicer(options := '20', nFont := 'Consolas') {
	; 	guiObj := this
	; 	try RegExReplace(options, 's([\d\s]+)', '$1')
	; 	if (guiObj is Gui) {
	; 		guiObj.SetFont('s' options ' Q5', nFont)
	; 	}
	; 	return this
	; }

	; static MakeFontNicer(params*) {
	
	; 	; Define font characteristics as UnSet to allow setting defaults after parsing the params
	; 	static fontName := color := quality := size := unset
	; 	static hexNeedle := '\b[0-9A-Fa-f]+\b'
		
	; 	if params is Gui {
	; 		; Infos('Beginning: ' Type(this) ' or True(1)| False(0):' (Type(this) = Gui), 10000)
	; 		guiObj := params
	; 	}

	; 	paramsParser(parameter) {
	; 		if (parameter is Gui){
	; 			guiObj := parameter
	; 		}
	; 		if parameter ~= 'i)^s[\d]+' {
	; 			size := SubStr(parameter, 2)  ; Remove 's' prefix
	; 			try guiObj.setfont('s' size)
	; 		}
	; 		else if parameter ~= '([^q])[\d]+' {
	; 			size := parameter
	; 			try guiObj.setfont('s' size)
	; 		}
	; 		else if parameter ~= '([q])[\d]+' {
	; 			quality := parameter
	; 			try guiObj.setfont(quality)
	; 		}
	; 		else if parameter ~= 'i)^c[\w\d]+' || parameter ~= hexNeedle {
	; 			color := parameter
	; 			try guiObj.setfont(color)
	; 		}
	; 		else if !parameter ~= '([q])[\d]+' && parameter ~= 'i)[\w]+'{
	; 			Infos('Paramter: Font Name: ' parameter)
	; 			fontName := parameter
	; 			try guiObj.setfont(, fontName)
	; 		}
	; 	}

	; 	; Parse params
	; 	for param in params {
	; 		if param is Array {
	; 			aParams := param.Clone()
	; 			for cParam in aParams {
	; 				paramsParser(cParam)
	; 			}
	; 		}
	; 		if param is String {
	; 			paramsParser(param)
	; 		}
	; 	}
	
	; 	if !IsSet(guiObj) {
	; 		Infos('Not Set: guiObj')
	; 		guiObj := this
	; 		Infos('Set: guiObj = ' Type(guiObj) ' guiObj = Gui? ' (guiObj = gui))
	; 	}

	; 	if !IsSet(size) {
	; 		Infos('Not Set: size')
	; 		size := 20
	; 		Infos('Set: size = ' size)
	; 	}

	; 	if !IsSet(quality) {
	; 		Infos('Not Set: quality')
	; 		quality := 'Q5'
	; 		Infos('Set: quality = ' quality)
	; 	}
	; 	if !IsSet(color) {
	; 		Infos('Not Set: color')
	; 		color := 'cBlue'
	; 		Infos('Set: color = ' color)
	; 	}
	; 	if !IsSet(fontName) {
	; 		Infos('Not Set: fontName')
	; 		fontName := 'Consolas'
	; 		Infos('Set: fontName = ' fontName)
	; 	}

	; 	; Build font options string
	; 	options := 's' size ' ' quality ' ' color

	; 	infos(options)
	; 	; Apply font
	; 	if (guiObj is Gui){
	; 		infos(options)
	; 		super.SetFont(options, fontName)
	; 	}
		
	; 	Infos('Final: Type(guiObj): ' Type(guiObj))
	; 	return guiObj
	; }

	static MakeFontNicer(params*) {
		; Define font characteristics as UnSet to allow setting defaults after parsing the params
		static fontName := color := quality := size := unset
		static hexNeedle := '\b[0-9A-Fa-f]+\b'
		
		; Default background color
		static backgroundColor := unset
		
		if params is Gui {
			guiObj := params
		}
	
		paramsParser(parameter) {
			
			if (parameter is Gui) {
				guiObj := parameter
				return
			}
			infos('parameter:' parameter)
			; Font size with 's' prefix
			if parameter ~= 'i)^s[\d]+' {
				size := SubStr(parameter, 2)  ; Remove 's' prefix
				try guiObj.SetFont('s' size)
				return
			}
			; Font size without prefix
			if parameter ~= 'i)([^q])[\d]+' {
				size := parameter
				try guiObj.SetFont('s' size)
				return
			}
			; Quality setting
			if parameter ~= 'i)([q])[\d]+' {
				quality := parameter
				try guiObj.SetFont(quality)
				return
			}
			; Color handling - support both named colors and hex
			if parameter ~= 'i)^c[\w\d]+' {
				color := parameter  ; Direct color format (e.g., cBlue)
				try guiObj.SetFont(color)
				return
			}
			if parameter ~= hexNeedle {
				color := 'c' parameter  ; Add 'c' prefix for hex colors
				try guiObj.SetFont(color)
				return
			}
			; Font name - anything that starts with letter and contains word chars or spaces
			if parameter ~= '^[a-zA-Z][\w\s-]*$' {
				fontName := parameter
				try guiObj.SetFont(, fontName)
			}
		}

		if !IsSet(guiObj) {
			guiObj := this
		}

		; Parse params
		for param in params {
			if param is Array {
				aParams := param.Clone()
				for cParam in aParams {
					paramsParser(cParam)
				}
				continue
			}
			if param is String {
				paramsParser(param)
			}
		}
		
		; Set defaults for unset parameters
		; if !IsSet(guiObj) {
		; 	guiObj := this
		; }
		if !IsSet(size) {
			size := 20
		}
		if !IsSet(quality) {
			quality := 'Q5'
		}
		if !IsSet(color) {
			color := 'cBlue'
		}
		if !IsSet(fontName) {
			fontName := 'Consolas'
		}
	
		; Build font options string
		options := 's' size ' ' quality ' ' color
		Infos('options: ' options)
		; Apply font settings based on context
		if (guiObj is Gui) {
			Infos('I am a Gui')
			guiObj.SetFont(options, fontName)
		}
		else if Type(guiObj) = "Class" {
			Infos('I am a Class')
			guiObj.SetFont(options, fontName)
		}
		
		return guiObj
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

	class Color {
		
		; Use existing color map
		static mColors := GuiColors.mColors

		/**
		 * Converts color from various formats to RGB
		 * @param {*} params color [, options]
		 * @returns {Object} {r, g, b} color components
		 */
		static ToRGB(params*) {
			color := params[1]
			
			if color is Integer
				return {r: (color >> 16) & 0xFF, 
					g: (color >> 8) & 0xFF, 
					b: color & 0xFF}
				
			if IsObject(color)
				return color

			if this.mColors.Has(StrLower(color))
				color := this.mColors[StrLower(color)]
				
			if RegExMatch(color, "i)^#?([A-F0-9]{6})$", &match)
				color := match[1]
				
			return {r: Integer("0x" SubStr(color, 1, 2)),
					g: Integer("0x" SubStr(color, 3, 2)),
					b: Integer("0x" SubStr(color, 5, 2))}
		}

		/**
		 * Converts color to BGR format
		 * @param {*} params color [, options]
		 * @returns {Integer} BGR color value
		 */
		static ToBGR(params*) {
			rgb := this.ToRGB(params[1])
			return (rgb.b << 16) | (rgb.g << 8) | rgb.r
		}

		/**
		 * Converts color to hex string
		 * @param {*} params color [, options]
		 * @returns {String} Hex color string
		 */
		static ToHex(params*) {
			rgb := this.ToRGB(params[1])
			return Format("{:02X}{:02X}{:02X}", rgb.r, rgb.g, rgb.b)
		}

		/**
		 * Adjusts color brightness
		 * @param {*} params color, amount [, options]
		 * @returns {String} Hex color
		 */
		static Adjust(params*) {
			if params.Length < 2
				throw ValueError("Requires color and amount parameters")
				
			color := params[1]
			amount := params[2]
			rgb := this.ToRGB(color)
			amount := Min(1.0, Max(-1.0, amount))
			
			rgb.r := Min(255, Max(0, Round(rgb.r * (1 + amount))))
			rgb.g := Min(255, Max(0, Round(rgb.g * (1 + amount))))
			rgb.b := Min(255, Max(0, Round(rgb.b * (1 + amount))))
			
			return this.ToHex(rgb)
		}

		/**
		 * Mixes two colors
		 * @param {*} params color1, color2 [, ratio=0.5] [, options]
		 * @returns {String} Hex color
		 */
		static Mix(params*) {
			if params.Length < 2
				throw ValueError("Requires at least two colors")
				
			color1 := params[1]
			color2 := params[2]
			ratio := params.Length > 2 ? params[3] : 0.5
			
			c1 := this.ToRGB(color1)
			c2 := this.ToRGB(color2)
			ratio := Min(1, Max(0, ratio))
			
			return this.ToHex({
				r: Round(c1.r * (1 - ratio) + c2.r * ratio),
				g: Round(c1.g * (1 - ratio) + c2.g * ratio),
				b: Round(c1.b * (1 - ratio) + c2.b * ratio)
			})
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
}

; class CleanInputBox extends Gui {

; 	; Width     := Round(A_ScreenWidth  / 1920 * 1200)
; 	Width     := Round(A_ScreenWidth  / 3)
; 	TopMargin := Round(A_ScreenHeight / 1080 * 800)

; 	; DarkMode(BackgroundColor:='') {
; 	; 	Gui2.DarkMode(this, BackgroundColor)
; 	; 	return this
; 	; }

; 	; ; MakeFontNicer(fontSize := 15) {
; 	; MakeFontNicer(fontParams*) {
; 	; 	Gui2.MakeFontNicer(fontParams)
; 	; 	return this
; 	; }

; 	__New() {
; 		cibGui := Gui('AlwaysOnTop -Caption +Border')
; 		super.__New('AlwaysOnTop -Caption +Border')
; 		super.DarkMode()
; 		super.MakeFontNicer('s10', 'q3', 'cRed')
; 		this.MarginX := 0

; 		this.InputField := this.AddEdit('x0 Center -E0x200 Background' this.BackColor ' w' this.Width)

; 		this.Input := ''
; 		this.isWaiting := true
; 		this.RegisterHotkeys()
; 	}

; 	Show() => (super.Show('y' this.TopMargin ' w' this.Width), this)

; 	/**
; 	 * Occupy the thread until you type in your input and press
; 	 * Enter, returns this input
; 	 * @returns {String}
; 	 */
; 	WaitForInput() {
; 		this.Show()
; 		while this.isWaiting {
; 		}
; 		return this.Input
; 	}

; 	SetInput() {
; 		this.Input := this.InputField.Text
; 		this.isWaiting := false
; 		this.Finish()
; 	}

; 	SetCancel() {
; 		this.isWaiting := false
; 		this.Finish()
; 	}

; 	RegisterHotkeys() {
; 		HotIfWinactive('ahk_id ' this.Hwnd)
; 		Hotkey('Enter', (*) => this.SetInput(), 'On')
; 		Hotkey('CapsLock', (*) => this.SetCancel())
; 		this.OnEvent('Escape', (*) => this.SetCancel())
; 	}

; 	Finish() {
; 		HotIfWinactive('ahk_id ' this.Hwnd)
; 		Hotkey('Enter', 'Off')
; 		this.Minimize()
; 		this.Destroy()
; 	}
; }

; ---------------------------------------------------------------------------

; class CleanInputBox {
;     ; Static properties (similar to Infos)
;     static Width := Round(A_ScreenWidth / 3)
;     static TopMargin := Round(A_ScreenHeight / 1080 * 800)
;     static fontSize := 12
;     static quality := 5
;     static color := 'Blue'

;     ; Instance properties
;     gui := ""
;     InputField := ""
;     Input := ""
;     isWaiting := true

;     __New() {
;         ; Create the GUI without inheritance
;         this.gui := Gui('+AlwaysOnTop -Caption +Border')
        
;         ; Apply styling (similar to Infos pattern)
;         this.DarkMode()
;         this.MakeFontNicer()
        
;         ; Setup GUI properties
;         this.gui.MarginX := 0

;         ; Add input field
;         this.InputField := this.gui.AddEdit('x0 Center -E0x200 Background' this.gui.BackColor ' w' CleanInputBox.Width)

;         ; Setup event handlers
;         this.RegisterHotkeys()
;     }

;     /**
;      * Apply dark mode styling to the GUI
;      * @returns {CleanInputBox} Instance for chaining
;      */
;     DarkMode() {
;         this.gui.BackColor := '0xA2AAAD'
;         return this
;     }

;     /**
;      * Apply font styling to the GUI
;      * @returns {CleanInputBox} Instance for chaining
;      */
;     MakeFontNicer() {
;         this.gui.SetFont('s' CleanInputBox.fontSize ' q' CleanInputBox.quality ' c' CleanInputBox.color, 'Consolas')
;         return this
;     }

;     /**
;      * Show the input box GUI
;      * @returns {CleanInputBox} Instance for chaining
;      */
;     Show() {
;         this.gui.Show('y' CleanInputBox.TopMargin ' w' CleanInputBox.Width)
;         return this
;     }

;     /**
;      * Wait for user input and return the result
;      * @returns {String} User input or empty string if cancelled
;      */
;     WaitForInput() {
;         this.Show()
;         while this.isWaiting {
;             Sleep(10)
;         }
;         return this.Input
;     }

;     /**
;      * Handle the input submission
;      */
;     SetInput() {
;         this.Input := this.InputField.Text
;         this.isWaiting := false
;         this.Finish()
;     }

;     /**
;      * Handle cancellation
;      */
;     SetCancel() {
;         this.isWaiting := false
;         this.Finish()
;     }

;     /**
;      * Register hotkeys for the input box
;      */
;     RegisterHotkeys() {
;         HotIfWinactive('ahk_id ' this.gui.Hwnd)
;         Hotkey('Enter', (*) => this.SetInput(), 'On')
;         Hotkey('CapsLock', (*) => this.SetCancel())
;         this.gui.OnEvent('Escape', (*) => this.SetCancel())
;     }

;     /**
;      * Clean up and close the input box
;      */
;     Finish() {
;         HotIfWinactive('ahk_id ' this.gui.Hwnd)
;         Hotkey('Enter', 'Off')
;         this.gui.Minimize()
;         this.gui.Destroy()
;     }
; }

; ---------------------------------------------------------------------------

class CleanInputBox {

    ; Default settings
    static Defaults := {
        fontSize: 12,
        quality: 5,
        color: 'Blue',
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
            Sleep(10)
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
Info(text, timeout?) => Infos(text, timeout ?? 10000)

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

class GuiColors {
	; Common named colors
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

}
