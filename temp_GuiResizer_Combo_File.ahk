; #Requires AutoHotkey v2.0
; #Include <Includes\Basic>

; /**
;  * @class Resizer
;  * @description Enhanced GUI resizing and control layout management class for AHKv2
;  * @author Fanatic Guru, Overcast
;  * @version 2024.03.15
;  * @requires AutoHotkey v2.0.2+
;  * @example
;  * ; Basic usage
;  * myGui := Gui()
;  * myGui.OnEvent("Size", Resizer) 
;  * 
;  * ; With positioning options
;  * ctrl := myGui.Add("Button", "w100 h30", "Click")
;  * ctrl.Resizer := {x: 0.5, y: 0.5} ; Center position
;  */

; class Resizer {
	
; 	; Initialize base properties
; 	static VERSION := "2024.03.15"
; 	static AUTHOR := "Fanatic Guru, Overcast"
; 	static Last := ''
	
; 	; Initialize properties method
; 	InitializeProperties() {
; 		for prop, type in this.Properties {
; 			switch type {
; 				case "number": this.%prop% := 0
; 				case "boolean": this.%prop% := false
; 				default: this.%prop% := ""
; 			}
; 		}
; 	}
; 	static LastDimensions := Map()
; 	static instances := Map()
	
; 	; Property definitions with validation 
; 	static Properties := {
; 		; Core positioning
; 		X: "number",          ; X positional offset 
; 		Y: "number",          ; Y positional offset
; 		W: "number",          ; Width
; 		H: "number",          ; Height
		
; 		; Percentage based
; 		XP: "number",         ; X position as percentage
; 		YP: "number",         ; Y position as percentage
; 		WP: "number",         ; Width as percentage
; 		HP: "number",         ; Height as percentage
		
; 		; Constraints
; 		MinX: "number",       ; Minimum X offset
; 		MaxX: "number",       ; Maximum X offset
; 		MinY: "number",       ; Minimum Y offset
; 		MaxY: "number",       ; Maximum Y offset
; 		MinW: "number",       ; Minimum width
; 		MaxW: "number",       ; Maximum width
; 		MinH: "number",       ; Minimum height
; 		MaxH: "number",       ; Maximum height
		
; 		; Behavior flags
; 		Mode: "string",       ; "simple" or "advanced" resizing mode
; 		Cleanup: "boolean",   ; Redraw control flag
; 		AnchorIn: "boolean"   ; Restrict to anchor bounds
; 	}

; 	; Instance properties - combined from both implementations
; 	__New(GuiObj, params*) {
; 		; Allow flexible initialization
; 		config := {
; 			interval: 100,
; 			stopCount: 6,
; 			setSizerImmediately: true,
; 			dpiAwareness: -2,
; 			mode: "simple"    ; Default to simple mode for backward compatibility
; 		}

; 		; Parse parameters
; 		if params.Length {
; 			if IsObject(params[1]) {
; 				; Handle object configuration
; 				for k, v in params[1].OwnProps()
; 					config.%k% := v
; 			} else {
; 				; Handle legacy parameter style
; 				config.interval := params[1] ?? 100
; 				config.stopCount := params[2] ?? 6
; 				config.setSizerImmediately := params[3] ?? true
; 				config.dpiAwareness := params[4] ?? -2
; 			}
; 		}

; 		; Initialize core properties
; 		this.InitializeProperties()
; 		Resizer.Last := this
		
; 		; Setup instance properties
; 		this.interval := config.interval
; 		this.expiredCtrls := []
; 		this.deltaW := this.deltaH := 0
; 		this.stopCount := config.stopCount
; 		this.guiObj := GuiObj
; 		this.mode := config.mode

; 		; Initialize size tracking
; 		this.active := {
; 			zeroCount: 0,
; 			lastW: 0,
; 			lastH: 0,
; 			w: 0,
; 			h: 0
; 		}

; 		; Control containers
; 		this.size := []
; 		this.move := []
; 		this.moveAndSize := []

; 		; DPI handling
; 		this.currentDPI := this.dpi := DllCall("User32\GetDpiForWindow", "Ptr", GuiObj.Hwnd, "UInt")
; 		this.setThreadDpiAwarenessContext := config.dpiAwareness

; 		; Get initial dimensions
; 		GuiObj.GetClientPos(,, &gw, &gh)
; 		this.shown := DllCall('IsWindowVisible', 'Ptr', GuiObj.Hwnd)
; 		this.active.w := gw
; 		this.active.h := gh

; 		; Setup event handling
; 		if config.setSizerImmediately
; 			GuiObj.OnEvent('size', this)
; 	}
	
; 	/**
; 	 * Call handler for resize events
; 	 * @param {Gui} GuiObj GUI being resized 
; 	 * @param {Integer} MinMax Window state
; 	 * @param {Integer} Width New width
; 	 * @param {Integer} Height New height
; 	 */
; 	static Call(GuiObj, MinMax, Width, Height) {
		
; 		; Skip if minimized
; 		if (MinMax = -1) {
; 			return
; 		}
		
; 		; Cache dimensions
; 		; Initialize dimensions if not cached
; 		if (!this.LastDimensions.Has(GuiObj.Hwnd)) {
; 			GuiObj.GetClientPos(,,&gw, &gh)
; 			this.LastDimensions[GuiObj.Hwnd] := {w: gw, h: gh}
; 			return ; Initial call, store dimensions and exit
; 		}

; 		; Skip processing if minimized or no dimensions changed
; 		GuiObj.GetClientPos(,,&gw, &gh)
; 		if (MinMax = -1 || (gw = this.LastDimensions[GuiObj.Hwnd].w && gh = this.LastDimensions[GuiObj.Hwnd].h)) {
; 			return
; 		}

; 		; Cache current dimensions
; 		try {
; 			lastW := this.LastDimensions[GuiObj.Hwnd].w
; 			lastH := this.LastDimensions[GuiObj.Hwnd].h
; 		} catch Error as e {
; 			ErrorLogger.Log('Error accessing dimensions: ' e.Message)
; 			return
; 		}
		
; 		; Calculate deltas
; 		last := this.LastDimensions[GuiObj.Hwnd] 
; 		deltaW := Width - last.w
; 		deltaH := Height - last.h
		
; 		; Resize controls
; 		for ctrl in GuiObj {
; 			if (!ctrl.HasProp("Resizer")) {
; 				continue 
; 			}
			
; 			this.ResizeControl(ctrl, deltaW, deltaH)
; 		}
		
; 		; Update cache
; 		this.LastDimensions[GuiObj.Hwnd] := {w: Width, h: Height}
; 	}
	
; 	/**
; 	 * Resize a single control
; 	 * @param {GuiControl} ctrl Control to resize
; 	 * @param {Integer} deltaW Width change
; 	 * @param {Integer} deltaH Height change 
; 	 */
; 	static ResizeControl(ctrl, deltaW, deltaH) {
		
; 		r := ctrl.Resizer
; 		ctrl.GetPos(&x, &y, &w, &h)
		
; 		; Calculate new position/size
; 		newX := x + (r.HasProp("x") ? deltaW * r.x : 0) 
; 		newY := y + (r.HasProp("y") ? deltaH * r.y : 0)
; 		newW := w + (r.HasProp("w") ? deltaW * r.w : 0)
; 		newH := h + (r.HasProp("h") ? deltaH * r.h : 0)
		
; 		; Apply min/max constraints
; 		if (r.HasProp("minW")) {
; 			newW := Max(r.minW, newW)
; 		}
; 		if (r.HasProp("maxW")) {
; 			newW := Min(r.maxW, newW)
; 		}
; 		if (r.HasProp("minH")) {
; 			newH := Max(r.minH, newH)
; 		}
; 		if (r.HasProp("maxH")) {
; 			newH := Min(r.maxH, newH)
; 		}
		
; 		; Move and resize
; 		ctrl.Move(newX, newY, newW, newH)
		
; 		; Handle cleanup
; 		if (r.HasProp("cleanup") && r.cleanup) {
; 			ctrl.Redraw()
; 		}
; 	}
	
; 	/**
; 	 * Add resize behavior to a control
; 	 * @param {GuiControl} ctrl Control to add resize behavior to
; 	 * @param {Object} opts Resize options
; 	 */
; 	static AddControl(ctrl, opts) {
; 		ctrl.Resizer := opts
; 	}
	
; 	/**
; 	 * Remove resize behavior from a control
; 	 * @param {GuiControl} ctrl Control to remove resize from
; 	 */
; 	static RemoveControl(ctrl) {
; 		ctrl.DeleteProp("Resizer")
; 	}
	
; 	/**
; 	 * Update resize options for a control
; 	 * @param {GuiControl} ctrl Control to update
; 	 * @param {Object} newOpts New resize options
; 	 */
; 	static UpdateControl(ctrl, newOpts) {
; 		if (!ctrl.HasProp("Resizer")) {
; 			ctrl.Resizer := {}
; 		}
; 		for k,v in newOpts.OwnProps() {
; 			ctrl.Resizer.%k% := v
; 		}
; 	}
	
; 	/**
; 	 * Reset resize cache for a GUI
; 	 * @param {Gui} GuiObj GUI to reset cache for
; 	 */
; 	static ResetCache(GuiObj) {
; 		this.LastDimensions.Delete(GuiObj.Hwnd)
; 	}
	
; 	/**
; 	 * Force a resize event
; 	 * @param {Gui} GuiObj GUI to resize
; 	 */
; 	static ForceResize(GuiObj) {
; 		GuiObj.GetClientPos(,,&w,&h)
; 		this.Call(GuiObj, 0, w, h)
; 	}
	
; 	/**
; 	 * Add common alignment presets
; 	 * @param {GuiControl} ctrl Control to align
; 	 * @param {String} preset Alignment preset name
; 	 */
; 	static AddPreset(ctrl, preset) {
; 		static presets := {
; 			TopLeft: {x: 0, y: 0},
; 			TopCenter: {x: 0.5, y: 0},
; 			TopRight: {x: 1, y: 0},
; 			CenterLeft: {x: 0, y: 0.5},
; 			Center: {x: 0.5, y: 0.5},
; 			CenterRight: {x: 1, y: 0.5},
; 			BottomLeft: {x: 0, y: 1},
; 			BottomCenter: {x: 0.5, y: 1},
; 			BottomRight: {x: 1, y: 1}
; 		}
		
; 		if (!presets.HasOwnProp(preset)) {
; 			throw ValueError("Invalid preset name", -1)
; 		}
		
; 		this.AddControl(ctrl, presets.%preset%)
; 	}

;     /**
;      * Set resizing mode
;      * @param {String} mode "simple" or "advanced"
;      * @returns {Resizer} This instance for chaining
;      */
;     SetMode(mode) {
;         if (!(mode ~= "i)^(simple|advanced)$"))
;             throw ValueError("Invalid mode. Use 'simple' or 'advanced'")
        
;         this.mode := mode
;         return this
;     }

;     /**
;      * Call handler that routes to appropriate resize method based on mode
;      */
;     Call(GuiObj, MinMax, Width, Height) {
;         if this.mode = "simple"
;             this.SimpleResize(GuiObj, MinMax, Width, Height)
;         else
;             this.AdvancedResize(GuiObj, MinMax, Width, Height)
;     }

; 	/**
; 	 * SimpleResize - Original resize method
; 	 * @param {Gui} GuiObj GUI being resized
; 	 * @param {Integer} MinMax Window state
; 	 * @param {Integer} Width New width
; 	 * @param {Integer} Height New height
; 	 */
; 	SimpleResize(GuiObj, MinMax, Width, Height) {
; 		; Skip if minimized
; 		if (MinMax = -1)
; 			return

; 		; Cache dimensions
; 		GuiObj.GetClientPos(,,&gw, &gh)
; 		if (!this.LastDimensions.Has(GuiObj.Hwnd)) {
; 			this.LastDimensions[GuiObj.Hwnd] := {w: gw, h: gh}
; 			return
; 		}

; 		; Calculate deltas
; 		last := this.LastDimensions[GuiObj.Hwnd]
; 		deltaW := Width - last.w
; 		deltaH := Height - last.h

; 		; Resize controls
; 		for ctrl in GuiObj {
; 			if (!ctrl.HasProp("Resizer"))
; 				continue
; 			this.ResizeControl(ctrl, deltaW, deltaH)
; 		}

; 		; Update cache
; 		this.LastDimensions[GuiObj.Hwnd] := {w: Width, h: Height}
; 	}

; 	/**
; 	 * AdvancedResize - Enhanced resize method with DPI awareness and timer
; 	 * @param {Gui} GuiObj GUI being resized
; 	 * @param {Integer} MinMax Window state
; 	 * @param {Integer} Width New width
; 	 * @param {Integer} Height New height
; 	 */
; 	AdvancedResize(GuiObj, MinMax, Width, Height) {
; 		if !this.Shown {
; 			this.GuiObj.GetClientPos(,, &gw, &gh)
; 			if gw <= 20
; 				return
; 			this.Active.W := gw, this.Active.H := gh
; 			this.Shown := 1
; 		}

; 		; Handle initial show
; 		if this.HasOwnProp('JustShown') {
; 			this.DeleteProp('JustShown')
; 			return
; 		}

; 		; DPI handling
; 		DPI := DllCall("User32\GetDpiForWindow", "Ptr", this.GuiObj.Hwnd, "UInt")
; 		if this.DPI != DPI {
; 			this.DPI := DPI
; 			return
; 		}

; 		; Setup resize timer
; 		this.GuiObj.OnEvent('Size', this, 0)
; 		SetTimer(this._Resize, this.Interval)
; 		this._TimeredResize()
; 	}

; 	/**
; 	 * Internal timer-based resize handler
; 	 * @private
; 	 */
; 	_TimeredResize(*) {
; 		if this.SetThreadDpiAwarenessContext
; 			DllCall("SetThreadDpiAwarenessContext", "ptr", this.SetThreadDpiAwarenessContext, "ptr")

; 		this.GuiObj.GetClientPos(,, &gw, &gh)
		
; 		; Check for no changes
; 		if !(gw - this.Active.LastW) && !(gh - this.Active.LastH) {
; 			if ++this.Active.ZeroCount >= this.StopCount {
; 				SetTimer(this._Resize, 0)
; 				if this.ExpiredCtrls.Length
; 					this.HandleExpiredCtrls()
; 				this.GuiObj.OnEvent('Size', this)
; 			}
; 			return
; 		}

; 		; Calculate deltas and resize
; 		this.DeltaW := gw - this.Active.W
; 		this.DeltaH := gh - this.Active.H
; 		this.IterateCtrlContainers(_Size, _Move, _MoveAndSize)
; 		this.Active.LastW := gw, this.Active.LastH := gh

; 		_Size(Ctrl) {
; 			if !Ctrl.HasProp('Resizer') {
; 				this.ExpiredCtrls.Push(Ctrl)
; 				return
; 			}
; 			this.GetDimensions(Ctrl, &W, &H)
; 			Ctrl.Move(,, W, H)
; 		}

; 		_Move(Ctrl) {
; 			if !Ctrl.HasProp('Resizer') {
; 				this.ExpiredCtrls.Push(Ctrl)
; 				return
; 			}
; 			this.GetCoords(Ctrl, &X, &Y)
; 			Ctrl.Move(X, Y)
; 		}

; 		_MoveAndSize(Ctrl) {
; 			if !Ctrl.HasProp('Resizer') {
; 				this.ExpiredCtrls.Push(Ctrl)
; 				return
; 			}
; 			this.GetCoords(Ctrl, &X, &Y), this.GetDimensions(Ctrl, &W, &H)
; 			Ctrl.Move(X, Y, W, H)
; 		}
; 	}

; 		/**
; 	 * Get both coordinates and dimensions for a control
; 	 * @param {GuiControl} ctrl Control to get measurements for
; 	 * @param {Integer} &X X coordinate output
; 	 * @param {Integer} &Y Y coordinate output  
; 	 * @param {Integer} &W Width output
; 	 * @param {Integer} &H Height output
; 	 */
; 	GetMeasurements(Ctrl, &X, &Y, &W, &H) {
; 		; Use existing helpers
; 		this.GetCoords(Ctrl, &X, &Y)
; 		this.GetDimensions(Ctrl, &W, &H)
; 	}
	
; 	/**
; 	 * Calculate percentage-based coordinates
; 	 * @param {GuiControl} ctrl Control to calculate for
; 	 * @param {Integer} &X X coordinate output 
; 	 * @param {Integer} &Y Y coordinate output
; 	 */
; 	GetPercentCoords(Ctrl, &X, &Y) {
; 		r := Ctrl.Resizer
		
; 		; Calculate percentage-based positions
; 		if r.HasProp("XP")
; 			X := this.GuiObj.ClientWidth * r.XP
; 		if r.HasProp("YP") 
; 			Y := this.GuiObj.ClientHeight * r.YP
			
; 		; Apply min/max constraints
; 		if r.HasProp("MinX")
; 			X := Max(r.MinX, X)
; 		if r.HasProp("MaxX")
; 			X := Min(r.MaxX, X)
; 		if r.HasProp("MinY")
; 			Y := Max(r.MinY, Y)
; 		if r.HasProp("MaxY")
; 			Y := Min(r.MaxY, Y)
; 	}
	
; 	/**
; 	 * Calculate percentage-based dimensions
; 	 * @param {GuiControl} ctrl Control to calculate for
; 	 * @param {Integer} &W Width output
; 	 * @param {Integer} &H Height output
; 	 */
; 	GetPercentDimensions(Ctrl, &W, &H) {
; 		r := Ctrl.Resizer
		
; 		; Calculate percentage-based sizes
; 		if r.HasProp("WidthP")
; 			W := this.GuiObj.ClientWidth * r.WidthP
; 		if r.HasProp("HeightP")
; 			H := this.GuiObj.ClientHeight * r.HeightP
			
; 		; Apply min/max constraints
; 		if r.HasProp("MinWidth")
; 			W := Max(r.MinWidth, W)
; 		if r.HasProp("MaxWidth")
; 			W := Min(r.MaxWidth, W)
; 		if r.HasProp("MinHeight")
; 			H := Max(r.MinHeight, H)
; 		if r.HasProp("MaxHeight")
; 			H := Min(r.MaxHeight, H)
; 	}
	
; 	/**
; 	 * Update the mode-specific resize settings
; 	 * @param {String} mode Resize mode ("simple"|"advanced")
; 	 * @param {Object} options Optional configuration
; 	 */
; 	UpdateResizeMode(mode, options?) {
; 		this.mode := mode
		
; 		if IsSet(options) {
; 			if this.mode = "advanced" {
; 				; Advanced mode settings
; 				this.interval := options.interval ?? 100
; 				this.stopCount := options.stopCount ?? 6
; 				this.setThreadDpiAwarenessContext := options.dpiAwareness ?? -2
; 			} else {
; 				; Simple mode settings
; 				this.interval := 0  ; Disable timer
; 				this.stopCount := 0
; 				this.setThreadDpiAwarenessContext := 0  ; Disable DPI awareness
; 			}
; 		}
		
; 		; Reset state for mode change
; 		this.active.zeroCount := 0
; 		this.active.lastW := 0
; 		this.active.lastH := 0
		
; 		return this
; 	}

; 	/**
; 	 * Set the minimum size for the resizer
; 	 * @param {Integer} minWidth Minimum width
; 	 * @param {Integer} minHeight Minimum height
; 	 */
; 	SetMinSize(minWidth, minHeight) {
; 		this.minWidth := minWidth
; 		this.minHeight := minHeight
; 	}

; 	/**
; 	 * Set anchor point for a control
; 	 * @param {GuiControl} ctrl Control to anchor
; 	 * @param {GuiControl} anchor Control to anchor to
; 	 * @param {String} position Anchor position (e.g., "top", "left", etc)
; 	 */
; 	SetAnchor(ctrl, anchor, position) {
; 		if !IsObject(ctrl.Resizer)
; 			ctrl.Resizer := {}
			
; 		ctrl.Resizer.Anchor := anchor
; 		ctrl.Resizer.AnchorPosition := position
		
; 		; Calculate relative positioning
; 		ctrl.GetPos(&cx, &cy, &cw, &ch)
; 		anchor.GetPos(&ax, &ay, &aw, &ah)
		
; 		; Store relative offsets
; 		switch position {
; 			case "top":
; 				ctrl.Resizer.y := cy - ay
; 			case "bottom":
; 				ctrl.Resizer.y := (ay + ah) - (cy + ch)
; 			case "left":
; 				ctrl.Resizer.x := cx - ax
; 			case "right":
; 				ctrl.Resizer.x := (ax + aw) - (cx + cw)
; 		}
		
; 		return this
; 	}
	
; 	/**
; 	 * Handle controls in a container
; 	 * @param {Array} container Array of controls
; 	 * @param {Function} callback Processing callback
; 	 */
; 	ProcessContainer(container, callback) {
; 		for ctrl in container {
; 			if !ctrl.HasProp("Resizer") {
; 				this.ExpiredCtrls.Push(ctrl)
; 				continue
; 			}
			
; 			try {
; 				callback(ctrl)
; 			} catch as err {
; 				; Log error but continue processing
; 				OutputDebug("Error processing control: " err.Message)
; 			}
; 		}
; 	}
; }

; ; GuiResizer.Prototype.Base := _GuiResizer
; ; ---------------------------------------------------------------------------
; /*
;     Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GuiResizer.ahk
;     Author: Nich-Cebolla
;     Version: 1.0.0
;     License: MIT
; */
; /**
;  * GuiReSizer - A class to handle GUI resizing and control layout management
;  * @class
;  * @author Fanatic Guru, enhanced by OvercastBTC
;  * @version 2024.03.15
;  * @description Manages the resizing of GUI windows and repositioning of controls
;  * @requires AutoHotkey v2.0.2+
;  * @example
;  * ; Basic usage
;  * myGui := Gui()
;  * myGui.OnEvent("Size", GuiReSizer) 
;  */
; class GuiResizer {
; ; class _GuiResizer {
;     static Last := ''
;     /**
;      * @description - Creates a callback function to be used with
;      * `Gui.Prototype.OnEvent('Size', Callback)`. This function requires a bit of preparation. See
;      * the longer explanation within the source document for more information. Note that
;      * `GuiResizer` modifies the `Gui.Prototype.Show` method slightly. This is the change:
;         @example
;         Gui.Prototype.DefineProp('Show', {Call: _Show})
;         _Show(Self) {
;             Show := Gui.Prototype.Show
;             this.JustShown := 1
;             Show(Self)
;         }
;         @
;      * @param {Gui} GuiObj - The GUI object that contains the controls to be resized.
;      * @param {Integer} [Interval=33] - The interval at which resizing occurs after initiated. Once
;      * the `Size` event has been raised, the callback is set to a timer that loops every `Interval`
;      * milliseconds and the event handler is temporarily disabled. After the function detects that
;      * no size change has occurred within `StopCount` iterations, the timer is disabled and the
;      * event handler is re-enabled. For more control over the visual appearance of the display as
;      * resizing occurs, set `SetWinDelay` in the Auto-Execute portion of your script.
;      * {@link https://www.autohotkey.com/docs/v2/lib/SetWinDelay.htm}
;      * @param {Integer} [StopCount=6] - The number of iterations that must occur without a size
;      * change before the timer is disabled and the event handler is re-enabled.
;      * @param {Boolean} [SetSizerImmediately=true] - If true, the `Size` event is raised immediately
;      * after the object is created. When this is true, you can call `GuiResizer` like a function:
;      * `GuiResizer(ControlsArr)`. If you do need the instance object in some other portion of the
;      * code or at some expected later time, the last instance created is available on the class
;      * object `GuiResizer.Last`.
;      * @param {Integer} [UsingSetThreadDpiAwarenessContext=-2] - The DPI awareness context to use.
;      * This is necessary as a parameter because, when using a THREAD_DPI_AWARENESS_CONTEXT other than
;      * the default, AutoHotkey's behavior when returning values from built-in functions is
;      * inconsistent unless the awareness context is set each time before calling the function.
;      * Understand that if you leave the value at -4, the OS expects that you will handle DPI scaling
;      * within your code. Set this parameter to 0 to disable THREAD_DPI_AWARENESS_CONTEXT.
;      */
;     __New(GuiObj, Interval := 100, StopCount := 6, SetSizerImmediately := true, UsingSetThreadDpiAwarenessContext := -2) {
;         GuiResizer.Last := this
; 		this.InitializeProperties()
;         this.DefineProp('_Resize', {Call: ObjBindMethod(this, 'Resize')})
;         GuiObj.DefineProp('Show', {Call: _Show})
;         this.Interval := Interval
;         this.ExpiredCtrls := []
;         this.DeltaW := this.DeltaH := 0
;         this.StopCount := StopCount
;         this.GuiObj := GuiObj
;         this.Active := {ZeroCount: 0, LastW: 0, LastH : 0}
;         this.Size := []
;         this.Move := []
;         this.MoveAndSize := []
;         this.CurrentDPI := this.DPI := DllCall("User32\GetDpiForWindow", "Ptr", GuiObj.Hwnd, "UInt")
;         this.SetThreadDpiAwarenessContext := UsingSetThreadDpiAwarenessContext
;         this.GuiObj.GetClientPos(, , &gw, &gh)
;         this.Shown := DllCall('IsWindowVisible', 'Ptr', GuiObj.Hwnd)
;         this.Active.W := gw
;         this.Active.H := gh
;         ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, , 'Gui initial size: W' gw ' H' gh)
;         for Ctrl in GuiObj {
;             if !Ctrl.HasOwnProp('Resizer')
;                 continue
;             Resizer := Ctrl.Resizer, z := FlagSize := FlagMove := 0
;             Ctrl.GetPos(&cx, &cy, &cw, &ch)
;             Ctrl.Resizer.pos := {x: cx, y: cy, w: cw, h: ch}
;             if Resizer.HasOwnProp('x')
;                 z += 1
;             if Resizer.HasOwnProp('y')
;                 z += 2
;             switch z {
;                 case 0:
;                     Resizer.x := 0, Resizer.y := 0
;                 case 1:
;                     Resizer.y := 0, FlagMove := 1
;                 case 2:
;                     Resizer.x := 0, FlagMove := 1
;                 case 3:
;                     FlagMove := 1
;             }
;             z := 0
;             if Resizer.HasOwnProp('w')
;                 z += 1
;             if Resizer.HasOwnProp('h')
;                 z += 2
;             switch z {
;                 case 0:
;                     Resizer.w := 0, Resizer.h := 0
;                 case 1:
;                     Resizer.h := 0, FlagSize := 1
;                 case 2:
;                     Resizer.w := 0, FlagSize := 1
;                 case 3:
;                     FlagSize := 1
;             }
;             if FlagSize {
;                 if FlagMove
;                     this.MoveAndSize.Push(Ctrl)
;                 else
;                     this.Size.Push(Ctrl)
;             } else if FlagMove
;                 this.Move.Push(Ctrl)
;             else
;                 throw Error('A control has ``Resizer`` property, but the property does not have'
;                 '`r`na ``w``, ``h``, ``x``, or ``y`` property.', -1, 'Ctrl name: ' Ctrl.Name)

;             _Show(Self) {
;                 Show := Gui.Prototype.Show
;                 this.JustShown := 1
;                 Show(Self)
;             }
;         }
;         if SetSizerImmediately
;             GuiObj.OnEvent('size', this)
;     }

;     Call(GuiObj, MinMax, Width, Height) {
;         if !this.Shown {
;             this.GuiObj.GetClientPos(,, &gw, &gh)
;             if gw <= 20
;                 return
;             this.Active.W := gw, this.Active.H := gh
;             ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber,
;             ; , 'Gui shown for the first time. Size: W' gw ' H' gh)
;             this.Shown := 1
;         }
;         if this.HasOwnProp('JustShown') {
;             this.DeleteProp('JustShown')
;             ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, , 'Gui just shown')
;             return
;         }
;         DPI := DllCall("User32\GetDpiForWindow", "Ptr", this.GuiObj.Hwnd, "UInt")
;         if this.DPI != DPI {
;             ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber,
;             ; , 'Dpi changed. Old: ' this.DPI '`tNew: ' DPI '.')
;             this.DPI := DPI
;             return
;         }
;         this.GuiObj.OnEvent('Size', this, 0)
;         ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, , 'Resize timer activated.')
;         SetTimer(this._Resize, this.Interval)
;         this.Resize()
;     }

;     IterateCtrlContainers(SizeCallback, MoveCallback, MoveAndResizeCallback) {
;         for Ctrl in this.Size
;             SizeCallback(Ctrl)
;         for Ctrl in this.Move
;             MoveCallback(Ctrl)
;         for Ctrl in this.MoveAndSize
;             MoveAndResizeCallback(Ctrl)
;     }

;     IterateAll(Callback) {
;         this.IterateCtrlContainers(Callback, Callback, Callback)
;     }

;     Resize(*) {
;         if this.SetThreadDpiAwarenessContext
;             DllCall("SetThreadDpiAwarenessContext", "ptr", this.SetThreadDpiAwarenessContext, "ptr")
;         this.GuiObj.GetClientPos(,, &gw, &gh)
;         if !(gw - this.Active.LastW) && !(gh - this.Active.LastH) {
;             ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber,
;             ; , 'No change since last tick. ZeroCount: ' this.Active.ZeroCount)
;             if ++this.Active.ZeroCount >= this.StopCount {
;                 ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, , 'Disabling timer.')
;                 SetTimer(this._Resize, 0)
;                 if this.ExpiredCtrls.Length
;                     this.HandleExpiredCtrls()
;                 this.GuiObj.OnEvent('Size', this)
;             }
;             return
;         }
;         this.DeltaW := gw - this.Active.W
;         this.DeltaH := gh - this.Active.H
;         ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber,
;         ; , 'Resize function ticked. Size: W' gw ' H' gh)
;         this.IterateCtrlContainers(_Size, _Move, _MoveAndSize)
;         this.Active.LastW := gw, this.Active.LastH := gh

;         _Size(Ctrl) {
;             if !Ctrl.HasOwnProp('Resizer') {
;                 this.ExpiredCtrls.Push(Ctrl)
;                 return
;             }
;             ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'Before')
;             this.GetDimensions(Ctrl, &W, &H)
;             Ctrl.Move(,, W, H)
;             ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'After')
;         }

;         _Move(Ctrl) {
;             if !Ctrl.HasOwnProp('Resizer') {
;                 this.ExpiredCtrls.Push(Ctrl)
;                 return
;             }
;             ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'Before')
;             this.GetCoords(Ctrl, &X, &Y)
;             Ctrl.Move(X, Y)
;             ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'After')
;         }

;         _MoveAndSize(Ctrl) {
;             if !Ctrl.HasOwnProp('Resizer') {
;                 this.ExpiredCtrls.Push(Ctrl)
;                 return
;             }
;             ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'Before')
;             this.GetCoords(Ctrl, &X, &Y), this.GetDimensions(Ctrl, &W, &H)
;             Ctrl.Move(X, Y, W, H)
;             ; GuiResizer.OutputDebug(this, A_ThisFunc, A_LineNumber, Ctrl, 'After')
;         }
;     }

;     GetCoords(Ctrl, &X, &Y) {
;         Resizer := Ctrl.Resizer, Pos := Resizer.Pos
;         X := Resizer.X ? this.DeltaW * Resizer.X + Pos.X : Pos.X
;         if X < 0
;             X := 0
;         Y := Resizer.Y ? this.DeltaH * Resizer.Y + Pos.Y : Pos.Y
;         if Y < 0
;             Y := 0
;     }

;     GetDimensions(Ctrl, &W, &H) {
;         Resizer := Ctrl.Resizer, Pos := Resizer.Pos
;         W := Resizer.W ? this.DeltaW * Resizer.W + Pos.W : Pos.W
;         if W < 0
;             W := 0
;         H := Resizer.H ? this.DeltaH * Resizer.H + Pos.H : Pos.H
;         if H < 0
;             H := 0
;     }

;     HandleExpiredCtrls() {
;         for Ctrl in this.ExpiredCtrls {
;             FlagRemoved := 0
;             for Container in [this.Size, this.Move, this.MoveAndSize] {
;                 for _Ctrl in Container {
;                     if Ctrl.Name == _Ctrl.Name {
;                         Container.RemoveAt(A_Index)
;                         FlagRemoved := 1
;                         break
;                     }
;                 }
;                 if FlagRemoved
;                     break
;             }
;             if FlagRemoved
;                 break
;         }
;     }

;     /**
;      * @description - Assigns the appropriate parameters to controls that are adjacent to one another.
;      * The input controls must be aligned along one dimension; this method will not function as
;      * expected if some are above others and also some are to the left or right of others. They must
;      * be adjacent along a single axis. Use this when you have a small number of controls that you
;      * want to be resized along with the GUI window. Be sure to handle any surrounding controls
;      * so they don't overlap.
;      * Here's some examples:

;         ||||| ||||| |||||             |     |||||||
;         ||||| ||||| |||||     - OK    |     |||||||         |||||   - NOT OK
;         ||||| ||||| |||||             |     |||||||         |||||
;         _________________             |     |||||||
;         ||||        ||||              |
;         ||||        ||||     - OK     |         |||||
;         ||||                          |         |||||
;               ||||                    |         |||||
;               ||||                    |
;               ||||                    |
;                                       |
;         @example
;             ; You can run this example to see what it looks like
;             GuiObj := Gui('+Resize -DPIScale')
;             Controls := []
;             Loop 4
;                 Controls.Push(GuiObj.Add('Edit', Format('x{} y{} w{} h{} vEdit{}'
;                 , 10 + 220 * (A_Index - 1), 10, 200, 400, A_Index)))
;             GuiResizer.SetAdjacentControls(Controls)
;             GuiResizer(GuiObj)
;             GuiObj.Show()
;         @
;      * @param {Array} Controls - An array of controls to assign the appropriate parameters to.
;      * @param {Boolean} Vertical - If true, the controls are aligned vertically; otherwise, they are aligned horizontally.
;      * @param {Boolean} IncludeOpposite - If true, the opposite side of the control will be set to 1; otherwise, it will be set to 0.
;      * @returns {Void}
;      */
;     static SetAdjacentControls(Controls, Vertical := false, IncludeOpposite := true) {
;         static Letters := Map('X', 'H', 'Y', 'W', '_X', 'W', '_Y', 'H')
;         local Count := Controls.Length, Result := [], CDF := [], Order := []
;         , X := Y := W := H := 0
;         if Controls.Length < 2 {
;             if Controls.Length
;                 Controls.Resizer := {w: 1, h: 1}, Result.Push(Controls)
;             return
;         }
;         if Vertical
;             _Refactored('Y')
;         else
;             _Refactored('X')

;         _Refactored(X_Or_Y) {
;             _GetCDF(1 / Count), Proportion := 1 / Count, _GetOrder(X_Or_Y)
;             for Ctrl in Order
;                 Ctrl.Resizer := {}, Ctrl.Resizer.%Letters['_' X_Or_Y]% := Proportion, Ctrl.Resizer.%X_Or_Y% := CDF[A_Index]
;                 , Ctrl.Resizer.%Letters[X_Or_Y]% := IncludeOpposite ? 1 : 0
;         }
;         _GetCDF(Step) {
;             Loop Count
;                 CDF.Push(Step * (A_Index - 1))
;         }
;         _GetOrder(X_Or_Y) {
;             for Ctrl in Controls {
;                 Ctrl.GetPos(&x, &y, &w, &h)
;                 Ctrl.__Resizer := {x: x, y: y}
;                 Order.Push(Ctrl)
;             }
;             InsertionSort(Order, 1, , ((X_Or_Y, a, b) => a.__Resizer.%X_Or_Y% - b.__Resizer.%X_Or_Y%).Bind(X_Or_Y))
;             InsertionSort(arr, start, end?, compareFn := (a, b) => a - b) {
;                 i := start - 1
;                 while ++i <= (end??arr.Length) {
;                     current := arr[i]
;                     j := i - 1
;                     while (j >= start && compareFn(arr[j], current) > 0) {
;                         arr[j + 1] := arr[j]
;                         j--
;                     }
;                     arr[j + 1] := current
;                 }
;                 return arr
;             }
;         }
;     }

;     /**
;      * @description - Returns an integer representing the position of the first object relative
;      * to the second object. This function assumes that the two objects do not overlap.
;      * The inputs can be any of:
;      * - A Gui object, Gui.Control object, or any object with an `Hwnd` property.
;      * - An object with properties { L, T, R, B }.
;      * - An Hwnd of a window or control.
;      * @param {Integer|Object} Subject - The subject of the comparison. The return value indicates
;      * the position of this object relative to the other.
;      * @param {Integer|Object} Target - The object which the subject is compared to.
;      * @returns {Integer} - Returns an integer representing the relative position shared between two objects.
;      * The values are:
;      * - 1: Subject is completely above target and completely to the left of target.
;      * - 2: Subject is completely above target and neither completely to the right nor left of target.
;      * - 3: Subject is completely above target and completely to the right of target.
;      * - 4: Subject is completely to the right of target and neither completely above nor below target.
;      * - 5: Subject is completely to the right of target and completely below target.
;      * - 6: Subject is completely below target and neither completely to the right nor left of target.
;      * - 7: Subject is completely below target and completely to the left of target.
;      * - 8: Subject is completely below target and completely to the left of target.
;      */
;     static GetRelativePosition(Subject, Target) {
;         _Get(Subject, &L1, &T1, &R1, &B1)
;         _Get(Target, &L2, &T2, &R2, &B2)
;         if L1 < L2 && R1 < L2 {
;             if B1 < T2
;                 return 1
;             else if T1 > B2
;                 return 7
;             else
;                 return 8
;         } else if T1 < T2 && B1 < T2 {
;             if L1 > R2
;                 return 3
;             else
;                 return 2
;         } else if L1 < R2
;             return 6
;         else if T1 < B2
;             return 4
;         else
;             return 5

;         _Get(Input, &L, &T, &R, &B) {
;             if IsObject(Input) {
;                 if !Input.HasOwnProp('Hwnd') {
;                     L := Input.L, T := Input.T, R := Input.R, B := Input.B
;                     return
;                 }
;                 WinGetPos(&L, &T, &W, &H, Input.Hwnd)
;             } else
;                 WinGetPos(&L, &T, &W, &H, Input)
;             R := L + W, B := T + H
;         }
;     }

;     static OutputDebug(Resizer, Fn, Line, Ctrl?, Extra?) {
;         if IsSet(Ctrl) {
;             Ctrl.GetPos(&cx, &cy, &cw, &ch)
;             OutputDebug('`n'
;                 Format(
;                     'Function: {1}`tLine: {2}'
;                     '`nControl: {3}'
;                     '`nX: {4}`tY: {5}`tW: {6}`tH: {7}'
;                     '`nDeltaW: {8}`tDeltaH: {9}'
;                     '`nActiveW: {10}`tActiveH: {11}`tLastW: {12}`tLastH: {13}'
;                     '`nExtra: {14}'
;                     , Fn, Line, Ctrl.Name, cx, cy, cw, ch, Resizer.DeltaW, Resizer.DeltaH, Resizer.Active.W
;                     , Resizer.Active.H, Resizer.Active.LastW, Resizer.Active.LastH, Extra ?? ''
;                 )
;             )
;         } else {
;             OutputDebug('`n'
;                 Format(
;                     'Function: {1}`tLine: {2}'
;                     '`nDeltaW: {3}`tDeltaH: {4}'
;                     '`nActiveW: {5}`tActiveH: {6}`tLastW: {7}`tLastH: {8}'
;                     '`nExtra: {9}'
;                     , Fn, Line, Resizer.DeltaW, Resizer.DeltaH, Resizer.Active.W, Resizer.Active.H
;                     , Resizer.Active.LastW, Resizer.Active.LastH, Extra ?? ''
;                 )
;             )
;         }
;     }
; ; }

; ; GuiResizer.Prototype.Base := _GuiResizer
; ; ; ---------------------------------------------------------------------------
; ; /**
; ;  * GuiReSizer - A class to handle GUI resizing and control layout management
; ;  * @class
; ;  * @author Fanatic Guru, enhanced by OvercastBTC
; ;  * @version 2024.03.15
; ;  * @description Manages the resizing of GUI windows and repositioning of controls
; ;  * @requires AutoHotkey v2.0.2+
; ;  * @example
; ;  * ; Basic usage
; ;  * myGui := Gui()
; ;  * myGui.OnEvent("Size", GuiReSizer) 
; ;  */
; ; class GuiResizer {
	
; 	#Requires AutoHotkey v2.0.2+
	
; 	; Static class properties
; 	static VERSION := "2024.03.15"
; 	static AUTHOR := "Fanatic Guru"
	
; 	; Property definitions with validation
; 	static Properties := {
; 		X: "number",          ; X positional offset 
; 		Y: "number",          ; Y positional offset
; 		XP: "number",         ; X position as percentage
; 		YP: "number",         ; Y position as percentage
; 		Width: "number",      ; Width of control
; 		Height: "number",     ; Height of control
; 		WidthP: "number",     ; Width as percentage
; 		HeightP: "number",    ; Height as percentage
; 		MinX: "number",       ; Minimum X offset
; 		MaxX: "number",       ; Maximum X offset
; 		MinY: "number",       ; Minimum Y offset
; 		MaxY: "number",       ; Maximum Y offset
; 		MinWidth: "number",   ; Minimum control width
; 		MaxWidth: "number",   ; Maximum control width
; 		MinHeight: "number",  ; Minimum control height
; 		MaxHeight: "number",  ; Maximum control height
; 		Cleanup: "boolean",   ; Redraw control flag
; 		AnchorIn: "boolean"   ; Restrict to anchor bounds
; 	}

; 	; Constructor 
; 	; __New() {
; 	; 	this.InitializeProperties()
; 	; }

; 	; Initialize default property values
; 	InitializeProperties() {
; 		; for prop, type in GuiReSizer.Properties {
; 		for prop, type in this.Properties {
; 			switch type {
; 				case "number": this.%prop% := 0
; 				case "boolean": this.%prop% := false
; 				default: this.%prop% := ""
; 			}
; 		}
; 	}

; 	; Cleanup method
; 	__Delete() {
; 		try {
; 			; Clean up any resources
; 			this.RemoveEventHandlers()
; 		}
; 		catch as err {
; 			throw ValueError("GuiReSizer cleanup failed: " err.Message)
; 		}
; 	}

; 	/**
; 	 * Convert object to string representation
; 	 * @returns {String} String representation of GuiReSizer
; 	 */
; 	ToString() {
; 		try {
; 			return Format("GuiReSizer [v{1}] - Controls:{2}", this.VERSION)
; 		}
; 		catch as err {
; 			throw ValueError("ToString failed: " err.Message)
; 		}
; 	}

; 	/**
; 	 * Convert to JSON format for serialization
; 	 * @returns {String} JSON representation
; 	 */
; 	ToJSON() {
; 		try {
; 			props := {}
; 			for prop in this.Properties {
; 				if this.HasProp(prop) {
; 					props.%prop% := this.%prop%
; 				}
; 			}
; 			return JSON.Stringify(props)
; 		}
; 		catch as err {
; 			throw ValueError("JSON conversion failed: " err.Message) 
; 		}
; 	}
; 	;{ Call GuiReSizer
; 	Static Call(GuiObj, WindowMinMax, GuiW, GuiH) {
; 		;{ Initial display of Gui use redraw to cleanup first positioning
; 		Try
; 			(GuiObj.Init)
; 		Catch
; 			GuiObj.Init := 3 ; Redraw twice and initialize abbreviations on Initial Call (called on initial Show)
; 		;}
; 		;{ Window minimize and maximize
; 		If WindowMinMax = -1 ; Do nothing if window minimized
; 			Return
; 		If WindowMinMax = 1 ; Repeat if maximized
; 			Repeat := true
; 		;}
; 		;{ Loop through all Controls of Gui
; 		Loop 2 { ; Loop twice by default to calculate Anchor controls
; 			For Hwnd, CtrlObj in GuiObj {
; 				;{ Initializations on First Call
; 				If GuiObj.Init = 3 {
; 					Try CtrlObj.OriginX := CtrlObj.OX
; 					Try CtrlObj.OriginXP := CtrlObj.OXP
; 					Try CtrlObj.OriginY := CtrlObj.OY
; 					Try CtrlObj.OriginYP := CtrlObj.OYP
; 					Try CtrlObj.Width := CtrlObj.W
; 					Try CtrlObj.WidthP := CtrlObj.WP
; 					Try CtrlObj.Height := CtrlObj.H
; 					Try CtrlObj.HeightP := CtrlObj.HP
; 					Try CtrlObj.MinWidth := CtrlObj.MinW
; 					Try CtrlObj.MaxWidth := CtrlObj.MaxW
; 					Try CtrlObj.MinHeight := CtrlObj.MinH
; 					Try CtrlObj.MaxHeight := CtrlObj.MaxH
; 					Try CtrlObj.Function := CtrlObj.F
; 					Try CtrlObj.Cleanup := CtrlObj.C
; 					Try CtrlObj.Anchor := CtrlObj.A
; 					Try CtrlObj.AnchorIn := CtrlObj.AI
; 					If !CtrlObj.HasProp("AnchorIn")
; 						CtrlObj.AnchorIn := true
; 				}
; 				;}
; 				;{ Initialize Current Positions and Sizes
; 				CtrlObj.GetPos(&CtrlX, &CtrlY, &CtrlW, &CtrlH)
; 				LimitX := AnchorW := GuiW, LimitY := AnchorH := GuiH, OffsetX := OffsetY := 0
; 				;}
; 				;{ Check for Anchor
; 				If CtrlObj.HasProp("Anchor") {
; 					Repeat := true
; 					CtrlObj.Anchor.GetPos(&AnchorX, &AnchorY, &AnchorW, &AnchorH)
; 					If CtrlObj.HasProp("X") or CtrlObj.HasProp("XP")
; 						OffsetX := AnchorX
; 					If CtrlObj.HasProp("Y") or CtrlObj.HasProp("YP")
; 						OffsetY := AnchorY
; 					If CtrlObj.AnchorIn
; 						LimitX := AnchorW, LimitY := AnchorH
; 				}
; 				;}
; 				;{ OriginX
; 				If CtrlObj.HasProp("OriginX") and CtrlObj.HasProp("OriginXP")
; 					OriginX := CtrlObj.OriginX + (CtrlW * CtrlObj.OriginXP)
; 				Else If CtrlObj.HasProp("OriginX") and !CtrlObj.HasProp("OriginXP")
; 					OriginX := CtrlObj.OriginX
; 				Else If !CtrlObj.HasProp("OriginX") and CtrlObj.HasProp("OriginXP")
; 					OriginX := CtrlW * CtrlObj.OriginXP
; 				Else
; 					OriginX := 0
; 				;}
; 				;{ OriginY
; 				If CtrlObj.HasProp("OriginY") and CtrlObj.HasProp("OriginYP")
; 					OriginY := CtrlObj.OriginY + (CtrlH * CtrlObj.OriginYP)
; 				Else If CtrlObj.HasProp("OriginY") and !CtrlObj.HasProp("OriginYP")
; 					OriginY := CtrlObj.OriginY
; 				Else If !CtrlObj.HasProp("OriginY") and CtrlObj.HasProp("OriginYP")
; 					OriginY := CtrlH * CtrlObj.OriginYP
; 				Else
; 					OriginY := 0
; 				;}
; 				;{ X
; 				If CtrlObj.HasProp("X") and CtrlObj.HasProp("XP")
; 					CtrlX := Mod(LimitX + CtrlObj.X + (AnchorW * CtrlObj.XP) - OriginX, LimitX)
; 				Else If CtrlObj.HasProp("X") and !CtrlObj.HasProp("XP")
; 					CtrlX := Mod(LimitX + CtrlObj.X - OriginX, LimitX)
; 				Else If !CtrlObj.HasProp("X") and CtrlObj.HasProp("XP")
; 					CtrlX := Mod(LimitX + (AnchorW * CtrlObj.XP) - OriginX, LimitX)
; 				;}
; 				;{ Y
; 				If CtrlObj.HasProp("Y") and CtrlObj.HasProp("YP")
; 					CtrlY := Mod(LimitY + CtrlObj.Y + (AnchorH * CtrlObj.YP) - OriginY, LimitY)
; 				Else If CtrlObj.HasProp("Y") and !CtrlObj.HasProp("YP")
; 					CtrlY := Mod(LimitY + CtrlObj.Y - OriginY, LimitY)
; 				Else If !CtrlObj.HasProp("Y") and CtrlObj.HasProp("YP")
; 					CtrlY := Mod(LimitY + AnchorH * CtrlObj.YP - OriginY, LimitY)
; 				;}
; 				;{ Width
; 				If CtrlObj.HasProp("Width") and CtrlObj.HasProp("WidthP")
; 					(CtrlObj.Width > 0 and CtrlObj.WidthP > 0 ? CtrlW := CtrlObj.Width + AnchorW * CtrlObj.WidthP : CtrlW := CtrlObj.Width + AnchorW + AnchorW * CtrlObj.WidthP - CtrlX)
; 				Else If CtrlObj.HasProp("Width") and !CtrlObj.HasProp("WidthP")
; 					(CtrlObj.Width > 0 ? CtrlW := CtrlObj.Width : CtrlW := AnchorW + CtrlObj.Width - CtrlX)
; 				Else If !CtrlObj.HasProp("Width") and CtrlObj.HasProp("WidthP")
; 					(CtrlObj.WidthP > 0 ? CtrlW := AnchorW * CtrlObj.WidthP : CtrlW := AnchorW + AnchorW * CtrlObj.WidthP - CtrlX)
; 				;}
; 				;{ Height
; 				If CtrlObj.HasProp("Height") and CtrlObj.HasProp("HeightP")
; 					(CtrlObj.Height > 0 and CtrlObj.HeightP > 0 ? CtrlH := CtrlObj.Height + AnchorH * CtrlObj.HeightP : CtrlH := CtrlObj.Height + AnchorH + AnchorH * CtrlObj.HeightP - CtrlY)
; 				Else If CtrlObj.HasProp("Height") and !CtrlObj.HasProp("HeightP")
; 					(CtrlObj.Height > 0 ? CtrlH := CtrlObj.Height : CtrlH := AnchorH + CtrlObj.Height - CtrlY)
; 				Else If !CtrlObj.HasProp("Height") and CtrlObj.HasProp("HeightP")
; 					(CtrlObj.HeightP > 0 ? CtrlH := AnchorH * CtrlObj.HeightP : CtrlH := AnchorH + AnchorH * CtrlObj.HeightP - CtrlY)
; 				;}
; 				;{ Min Max
; 				(CtrlObj.HasProp("MinX") ? MinX := CtrlObj.MinX : MinX := -999999)
; 				(CtrlObj.HasProp("MaxX") ? MaxX := CtrlObj.MaxX : MaxX := 999999)
; 				(CtrlObj.HasProp("MinY") ? MinY := CtrlObj.MinY : MinY := -999999)
; 				(CtrlObj.HasProp("MaxY") ? MaxY := CtrlObj.MaxY : MaxY := 999999)
; 				(CtrlObj.HasProp("MinWidth") ? MinW := CtrlObj.MinWidth : MinW := 0)
; 				(CtrlObj.HasProp("MaxWidth") ? MaxW := CtrlObj.MaxWidth : MaxW := 999999)
; 				(CtrlObj.HasProp("MinHeight") ? MinH := CtrlObj.MinHeight : MinH := 0)
; 				(CtrlObj.HasProp("MaxHeight") ? MaxH := CtrlObj.MaxHeight : MaxH := 999999)
; 				CtrlX := MinMax(CtrlX, MinX, MaxX)
; 				CtrlY := MinMax(CtrlY, MinY, MaxY)
; 				CtrlW := MinMax(CtrlW, MinW, MaxW)
; 				CtrlH := MinMax(CtrlH, MinH, MaxH)
; 				;}
; 				;{ Move and Size
; 				CtrlObj.Move(CtrlX + OffsetX, CtrlY + OffsetY, CtrlW, CtrlH)
; 				;}
; 				;{ Redraw on Cleanup or GuiObj.Init
; 				If GuiObj.Init or (CtrlObj.HasProp("Cleanup") and CtrlObj.Cleanup = true)
; 					CtrlObj.Redraw()
; 				;}
; 				;{ Custom Function Call
; 				If CtrlObj.HasProp("Function")
; 					CtrlObj.Function(GuiObj) ; CtrlObj is hidden 'this' first parameter
; 				;}
; 			}
; 			If !IsSet(Repeat) ; Break loop if no Repeat is needed because of Anchor or Maximize
; 				Break
; 		}
; 		;}
; 		;{ Reduce GuiObj.Init Counter and Check for Call again
; 		If (GuiObj.Init := GuiObj.Init - 1 > 0) {
; 			GuiObj.GetClientPos(, , &AnchorW, &AnchorH)
; 			GuiReSizer(GuiObj, WindowMinMax, AnchorW, AnchorH)
; 		}
; 		If WindowMinMax = 1 ; maximized
; 			GuiObj.Init := 2 ; redraw twice on next call after a maximize
; 		;}
; 		;{ Functions: Helpers
; 		MinMax(Num, MinNum, MaxNum) => Min(Max(Num, MinNum), MaxNum)
; 		;}
; 	}
; 	;}
	
; 	;{ Methods:
; 	;{ Options
; 	Static Opt(CtrlObj, Options) => this.Options(CtrlObj, Options)
	
; 	Static Options(CtrlObj, Options) {
; 		For Option in StrSplit(Options, " ") {
; 			For Abbr, Cmd in Map(
; 				"xp", "XP", "yp", "YP", "x", "X", "y", "Y",
; 				"wp", "WidthP", "hp", "HeightP", "w", "Width", "h", "Height",
; 				"minx", "MinX", "maxx", "MaxX", "miny", "MinY", "maxy", "MaxY", 
; 				"minw", "MinWidth", "maxw", "MaxWidth", "minh", "MinHeight", "maxh", "MaxHeight",
; 				"oxp", "OriginXP", "oyp", "OriginYP", "ox", "OriginX", "oy", "OriginY") {
; 				If RegExMatch(Option, "i)^" Abbr "([\d.-]*$)", &Match) {
; 					CtrlObj.%Cmd% := Match.1
; 					Break
; 				}
; 			}
; 			; Origin letters
; 			If SubStr(Option, 1, 1) = "o" {
; 				Flags := SubStr(Option, 2)
; 				If Flags ~= "i)l"           ; left
; 					CtrlObj.OriginXP := 0
; 				If Flags ~= "i)c"           ; center (left to right)
; 					CtrlObj.OriginXP := 0.5
; 				If Flags ~= "i)r"           ; right
; 					CtrlObj.OriginXP := 1
; 				If Flags ~= "i)t"           ; top
; 					CtrlObj.OriginYP := 0
; 				If Flags ~= "i)m"           ; middle (top to bottom)
; 					CtrlObj.OriginYP := 0.5
; 				If Flags ~= "i)b"           ; bottom
; 					CtrlObj.OriginYP := 1
; 			}
; 		}
; 	}
; 	;}
; 	;{ Now
; 	Static Now(GuiObj, Redraw := true, Init := 2) {
; 		If Redraw
; 			GuiObj.Init := Init
; 		GuiObj.GetClientPos(, , &Width, &Height)
; 		GuiReSizer(GuiObj, WindowMinMax := 1, Width, Height)
; 	}
; }
