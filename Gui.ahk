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

	static MakeFontNicer(guiObj := this, fontSize := 20) {
		if (guiObj is Gui) {
			guiObj.SetFont('s' fontSize ' c0000ff', 'Consolas')
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

	; static AddButtonGroup(guiObj, buttonOptions, labelObj, groupOptions := '', columns := 1, glabel := '') {
    ;     if (guiObj is Gui) {
    ;         Gui2.SetDefaultFont(guiObj)
            
    ;         buttons := Map()
            
    ;         if (Type(labelObj) = 'String') {
    ;             labelObj := StrSplit(labelObj, '|')
    ;         }
            
    ;         if (Type(labelObj) = 'Array' or Type(labelObj) = 'Map' or Type(labelObj) = 'Object') {
    ;             totalButtons := labelObj.Length
    ;             rows := Ceil(totalButtons / columns)
                
    ;             ; Parse groupOptions
    ;             groupPos := '', groupSize := ''
    ;             if (groupOptions != '') {
    ;                 RegExMatch(groupOptions, 'i)x\s*(\d+)', &xMatch)
    ;                 RegExMatch(groupOptions, 'i)y\s*(\d+)', &yMatch)
    ;                 RegExMatch(groupOptions, 'i)w\s*(\d+)', &wMatch)
    ;                 RegExMatch(groupOptions, 'i)h\s*(\d+)', &hMatch)
                    
    ;                 groupPos := (xMatch ? 'x' . xMatch[1] : '') . ' ' . (yMatch ? 'y' . yMatch[1] : '')
    ;                 groupSize := (wMatch ? 'w' . wMatch[1] : '') . ' ' . (hMatch ? 'h' . hMatch[1] : '')
    ;             }
                
    ;             groupBox := guiObj.AddGroupBox(groupPos . ' ' . groupSize, glabel)
                
    ;             for index, label in labelObj {
    ;                 ; Calculate position based on index
    ;                 col := Mod(A_Index - 1, columns)
    ;                 row := Floor((A_Index - 1) / columns)
                    
    ;                 ; Parse individual button options
    ;                 btnOptions := StrReplace(buttonOptions, 'xm', 'x+10')
    ;                 btnOptions := StrReplace(btnOptions, 'ym', 'y+10')
    ;                 btnOptions := RegExReplace(btnOptions, 'i)x\s*(\+?\d+)', 'x' . (col * 110 + 10))
    ;                 btnOptions := RegExReplace(btnOptions, 'i)y\s*(\+?\d+)', 'y' . (row * 35 + 25))
                    
    ;                 ; Add the button
    ;                 btn := guiObj.AddButton(btnOptions, label)
    ;                 buttons[label] := btn
    ;             }
    ;         }
            
    ;         return buttons
    ;     }
    ;     return Map()  ; Return an empty Map if guiObj is not a Gui
    ; }

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

; class Infos extends Gui {

;     static fontSize := 8
;     static distance := 4
;     static unit := A_ScreenDPI / 144
;     static guiWidth := Infos.fontSize * Infos.unit * Infos.distance
;     static maximumInfos := Floor(A_ScreenHeight / Infos.guiWidth)
;     static spots := Infos._GeneratePlacesArray()
;     static maxNumberedHotkeys := 12
;     static maxWidthInChars := 110

;     ; Add a writable text property
;     __text := ''
;     text {
;         get => this.__text
;         set => this.__text := value
;     }

;     __New(text, autoCloseTimeout := 0) {
;         super.__New('AlwaysOnTop -Caption +ToolWindow')
;         this.autoCloseTimeout := autoCloseTimeout
;         this.text := text
;         this.spaceIndex := 0
;         if !this._GetAvailableSpace() {
;             this._StopDueToNoSpace()
;             return
;         }
;         this._CreateGui()
;         this._SetupHotkeysAndEvents()
;         this._SetupAutoclose()
;         this._Show()
;     }

;     _CreateGui() {
;         this.DarkMode()
;         this.MakeFontNicer(Infos.fontSize)  ; This will use the instance method
;         this.NeverFocusWindow()
;         this.gcText := this.AddText(, this._FormatText())
;         return this
;     }

;     ; Explicitly define inherited methods
;     DarkMode(BackgroundColor := '') {
;         return Gui2.DarkMode(this, BackgroundColor)
;     }

; 	; Instance method
; 	MakeFontNicer(fontSize := 20) {
; 		; this.SetFont('s' fontSize ' c0000ff', 'Consolas')
; 		super.SetFont('s' fontSize ' c0000ff', 'Consolas')
; 		; this.fontProperties.UpdateFont(this)
; 		return this
; 	}

;     NeverFocusWindow() {
;         return Gui2.NeverFocusWindow(this)
;     }

;     static DestroyAll(*) {
;         for index, infoObj in Infos.spots {
;             if (infoObj is Infos) {
;                 infoObj.Destroy()
;             }
;         }
;     }

;     static _GeneratePlacesArray() {
;         availablePlaces := []
;         loop Infos.maximumInfos {
;             availablePlaces.Push(false)
;         }
;         return availablePlaces
;     }

;     ReplaceText(newText) {
;         try WinExist(this)
;         catch
;             return Infos(newText, this.autoCloseTimeout)

;         if StrLen(newText) = StrLen(this.gcText.Text) {
;             this.gcText.Text := newText
;             this._SetupAutoclose()
;             return this
;         }

;         Infos.spots[this.spaceIndex] := false
;         return Infos(newText, this.autoCloseTimeout)
;     }

;     Destroy(*) {
;         if (!WinExist(this.Hwnd)) {
;             return false
;         }
;         this.RemoveHotkeys()
;         super.Destroy()
;         if (this.spaceIndex > 0) {  ; Only clear the spot if spaceIndex is valid
;             Infos.spots[this.spaceIndex] := false
;         }
;         return true
;     }

;     RemoveHotkeys() {
;         hotkeys := ['Escape', '^Escape'], hk := ''
;         if (this.spaceIndex > 0 && this.spaceIndex <= Infos.maxNumberedHotkeys) {
;             hotkeys.Push('F' this.spaceIndex)
;         }
;         HotIfWinExist('ahk_id ' this.Hwnd)
;         for hk in hotkeys {
;             try {
;                 Hotkey(hk, 'Off')
;             }
;         }
;         HotIf()
;     }

;     _FormatText() {
;         ftext := String(this.text)
;         lines := ftext.Split('`n')
;         if lines.Length > 1 {
;             ftext := this._FormatByLine(lines)
;         }
;         else {
;             ftext := this._LimitWidth(ftext)
;         }
;         return String(this.text).Replace('&', '&&')
;     }

;     _FormatByLine(lines) {
;         newLines := []
;         for index, line in lines {
;             newLines.Push(this._LimitWidth(line))
;         }
;         ftext := ''
;         for index, line in newLines {
;             if index = newLines.Length {
;                 ftext .= line
;                 break
;             }
;             ftext .= line '`n'
;         }
;         return ftext
;     }

;     _LimitWidth(ltext) {
;         if StrLen(ltext) < Infos.maxWidthInChars {
;             return ltext
;         }
;         insertions := 0
;         while (insertions + 1) * Infos.maxWidthInChars + insertions < StrLen(ltext) {
;             insertions++
;             ltext := ltext.Insert('`n', insertions * Infos.maxWidthInChars + insertions)
;         }
;         return ltext
;     }

;     _GetAvailableSpace() {
;         for index, isOccupied in Infos.spots {
;             if !isOccupied {
;                 this.spaceIndex := index
;                 Infos.spots[index] := this
;                 return true
;             }
;         }
;         return false
;     }

;     _CalculateYCoord() => Round(this.spaceIndex * Infos.guiWidth - Infos.guiWidth)

;     _StopDueToNoSpace() => this.Destroy()

;     _SetupHotkeysAndEvents() {
;         HotIfWinExist('ahk_id ' this.Hwnd)
;         Hotkey('Escape', this.Destroy.Bind(this), 'On')
;         Hotkey('^Escape', Infos.DestroyAll, 'On')
;         if (this.spaceIndex > 0 && this.spaceIndex <= Infos.maxNumberedHotkeys) {
;             Hotkey('F' this.spaceIndex, this.Destroy.Bind(this), 'On')
;         }
;         HotIf()
;         this.gcText.OnEvent('Click', this.Destroy.Bind(this))
;         this.OnEvent('Close', this.Destroy.Bind(this))
;     }

;     _SetupAutoclose() {
;         if this.autoCloseTimeout {
;             SetTimer(this.Destroy.Bind(this), -this.autoCloseTimeout)
;         }
;     }

;     _Show() => (this.Show('AutoSize NA x0 y' this._CalculateYCoord()))
; }

; Make sure to keep this line at the end of your script

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
        this.MakeFontNicer(Infos.fontSize)
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
        if lines.Length > 1 {
            ftext := this._FormatByLine(lines)
        }
        else {
            ftext := this._LimitWidth(ftext)
        }
        return String(this.text).Replace('&', '&&')
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
