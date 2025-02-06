#Requires AutoHotkey v2.0+
#Include <Includes/Basic>


/*
Name: String.ahk
Version 0.13 (15.10.22)
Github link: https://github.com/Descolada/AHK-v2-libraries/blob/main/Lib/String.ahk
Created: 27.08.22
Author: Descolada
Credit:
tidbit		--- Author of "String Things - Common String & Array Functions", from which
				I copied/based a lot of methods
Contributors to "String Things": AfterLemon, Bon, Lexikos, MasterFocus, Rseding91, Verdlin

Description:
A compilation of useful string methods. Also lets strings be treated as objects.

These methods cannot be used as stand-alone. To do that, you must add another argument
'string' to the function and replace all occurrences of 'this' with 'string'.
.-==========================================================================-.
| Methods                                                                    |
|============================================================================|
| Native functions as methods:                                               |
| String.ToUpper()                                                           |
|       .ToLower()                                                           |
|       .ToTitle()                                                           |
|       .Split([Delimiters, OmitChars, MaxParts])                            |
|       .Replace(Needle [, ReplaceText, CaseSense, &OutputVarCount, Limit])  |
|       .Trim([OmitChars])                                                   |
|       .LTrim([OmitChars])                                                  |
|       .RTrim([OmitChars])                                                  |
|       .Compare(comparison [, CaseSense])                                   |
|       .Sort([, Options, Function])                                         |
|       .Find(Needle [, CaseSense, StartingPos, Occurrence])                 |
|       .SplitPath() => returns object {FileName, Dir, Ext, NameNoExt, Drive}|
|		.RegExMatch(needleRegex, &match?, startingPos?)                      |
|		.RegExReplace(needle, replacement?, &count?, limit?, startingPos?)   |
|                                                                            |
| String[n] => gets nth character                                            |
| String[i,j] => substring from i to j                                       |
| String.Length                                                              |
| String.Count(searchFor)                                                    |
| String.Insert(insert, into [, pos])                                        |
| String.Delete(string [, start, length])                                    |
| String.Overwrite(overwrite, into [, pos])                                  |
| String.Repeat(count)                                                       |
| Delimeter.Concat(words*)                                                   |
|                                                                            |
| String.LineWrap([column:=56, indentChar:=""])                              |
| String.WordWrap([column:=56, indentChar:=""])                              |
| String.ReadLine(line [, delim:="`n", exclude:="`r"])                       |
| String.DeleteLine(line [, delim:="`n", exclude:="`r"])                     |
| String.InsertLine(insert, into, line [, delim:="`n", exclude:="`r"])       |
|                                                                            |
| String.Reverse()                                                           |
| String.Contains(needle1 [, needle2, needle3...])                           |
| String.RemoveDuplicates([delim:="`n"])                                     |
| String.LPad(count)                                                         |
| String.RPad(count)                                                         |
|                                                                            |
| String.Center([fill:=" ", symFill:=0, delim:="`n", exclude:="`r", width])  |
| String.Right([fill:=" ", delim:="`n", exclude:="`r"])                      |
'-==========================================================================-'
*/

class docProperties {
	static Properties := {
		FontFamily: 'Times New Roman',
		FontSize: 11,
		FontColor: '000000',
		CharSet: 1252,
		DefaultFont: 'froman', 
		DefaultPrq: 2,
		LineHeight: 1.2,
		DefaultMargin: 0,
		DefaultPadding: '0.5em 0',
		StyleMappings: Map(
			"strike", "\strike",
			"super", "\super",
			"sub", "\sub",
			"bullet", "• ",
			"align-left", "\ql",
			"align-right", "\qr",
			"align-center", "\qc",
			"align-justify", "\qj"
		)
	}
}

; class htmlHandler extends docProperties{

; 	; static __New(text := '') {
; 	; 	this.SetClipboardHTML(text)
; 	; }

; 	/**
; 	 * @description Sets clipboard content as HTML format with enhanced error handling
; 	 * @param {String} htmlText The HTML formatted text
; 	 * @throws {Error} If clipboard operations fail
; 	 */
; 	static SetClipboardHTML(htmlText) {
; 		; Register HTML format
; 		static CF_HTML := DllCall("RegisterClipboardFormat", "Str", "HTML Format", "UInt")
		
; 		if (!CF_HTML)
; 			throw Error("Failed to register HTML clipboard format", -1)
		
; 		; Header required for HTML clipboard format
; 		header := "Version:0.9`r`n" 
; 				. "StartHTML:00000097`r`n"
; 				. "EndHTML:{:08d}`r`n"
; 				. "StartFragment:00000134`r`n"
; 				. "EndFragment:{:08d}`r`n"
; 				. "<html><body><!--StartFragment-->{:s}<!--EndFragment--></body></html>"
		
; 		; Calculate fragment positions
; 		fragmentEnd := 134 + StrLen(htmlText)
; 		htmlEnd := fragmentEnd + 40  ; Length of closing tags
		
; 		; Format the complete HTML
; 		htmlData := Format(header, htmlEnd, fragmentEnd, htmlText)
		
; 		; Open and clear clipboard with timeout handling
; 		startTime := A_TickCount
; 		while (!DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)) {
; 			if (A_TickCount - startTime > 1000)
; 				throw Error("Failed to open clipboard", -1)
; 			Sleep(10)
; 		}
		
; 		DllCall("EmptyClipboard")
		
; 		; Allocate and copy HTML data
; 		hGlobal := DllCall("GlobalAlloc", "UInt", 0x42, "Ptr", StrPut(htmlData, "UTF-8"))
; 		if (!hGlobal)
; 			throw Error("Failed to allocate memory for clipboard", -1)
			
; 		try {
; 			pGlobal := DllCall("GlobalLock", "Ptr", hGlobal, "Ptr")
; 			if (!pGlobal)
; 				throw Error("Failed to lock global memory", -1)
				
; 			StrPut(htmlData, pGlobal, "UTF-8")
; 			DllCall("GlobalUnlock", "Ptr", hGlobal)
			
; 			; Set clipboard data
; 			if (!DllCall("SetClipboardData", "UInt", CF_HTML, "Ptr", hGlobal))
; 				throw Error("Failed to set clipboard data", -1)
; 		} catch Error as err {
; 			; Cleanup on error
; 			DllCall("GlobalFree", "Ptr", hGlobal)
; 			DllCall("CloseClipboard")
; 			throw err
; 		}
		
; 		DllCall("CloseClipboard")
; 		Clip.Sleep(clip.delayTime)  ; Small delay to ensure clipboard operations complete
; 	}
; }

/**
 * @class RTFHandler
 * @description Core RTF handling functionality with improved structure and error handling
 */
; class RTFHandler {
; 	static Properties := {
; 		FontFamily: "Times New Roman",
; 		FontSize: 22,  ; RTF uses half-points
; 		FontColor: "000000",
; 		DefaultFont: "froman",
; 		DefaultPrq: 2,
; 		CharSet: 1252,
; 		PageWidth: 12240,    ; From rtf_example.rtf
; 		PageHeight: 15840,   ; From rtf_example.rtf
; 		MarginLeft: 360,
; 		MarginRight: 1080,
; 		MarginTop: 720,
; 		MarginBottom: 280,
; 		StyleMappings: Map(
; 			"strike", "\strike",
; 			"super", "\super",
; 			"sub", "\sub",
; 			"bullet", "• ",
; 			"align-left", "\ql",
; 			"align-right", "\qr",
; 			"align-center", "\qc",
; 			"align-justify", "\qj"
; 		)
; 	}

; 	/**
; 	 * @description Generates comprehensive RTF header with extended options
; 	 * @param {Object} options Optional settings to override defaults
; 	 * @returns {String} Complete RTF header
; 	 */
; 	static GetHeader(options := {}) {
; 		; Merge provided options with defaults
; 		props := this.Properties
; 		for key, value in options.OwnProps()
; 			props.%key% := value

; 		return Format('
; 		(
; 			{\rtf1\ansi\ansicpg{1}\deff0\nouicompat\deflang1033
; 			{{\fonttbl{{
; 				\f0\fbidis\{2}\fprq{3}\fcharset0 {4};}}
; 				{{\f1\fbidis\{2}\fcharset0 {4};}}
; 				{{\f2\fbidis\fnil\fcharset2 Wingdings;}}
; 				{{\f3\fnil\fcharset0 {4};}}
; 			}}
; 			{{\colortbl;
; 				\red0\green0\blue0;
; 				\red106\green115\blue123;
; 				\red255\green255\blue255;
; 			}}
; 			{{\stylesheet{{
; 				\fs{5}\f0\sqformat\spriority1 Normal}}
; 				{{\s1\li1909\f0\fs{5}\sbasedon0\sqformat\spriority1 Body Text}}
; 				{{\s2\li1689\sb109\f1\fs{5}\b1\sbasedon0\sqformat\spriority1 Title}}
; 				{{\s3\li1909\fi-239\f0\sbasedon0\sqformat\spriority1 List Paragraph}}
; 				{{\s4\li124\f0\sbasedon0\sqformat\spriority1 Table Paragraph}}
; 			}}
; 			{{\*\generator AHK RTF Generator;}}
; 			{{\info{{
; 				\creatim\yr{6}\mo{7}\dy{8}\hr{9}\min{10}\sec{11}
; 			}}}}
; 			\jexpand\dntblnsbdb
; 			\viewkind1
; 			\noxlattoyen
; 			\nospaceforul
; 			\useltbaln
; 			\paperw{12}\paperh{13}
; 			\margl{14}\margr{15}\margt{16}\margb{17}
; 			\widowctrl
; 			\sectd\sbknone
; 			\pard\plain
; 		)',
; 		props.CharSet,
; 		props.DefaultFont,
; 		props.DefaultPrq,
; 		props.FontFamily,
; 		props.FontSize,
; 		A_Year,
; 		A_Mon,
; 		A_MDay,
; 		A_Hour,
; 		A_Min,
; 		A_Sec,
; 		props.PageWidth,
; 		props.PageHeight,
; 		props.MarginLeft,
; 		props.MarginRight,
; 		props.MarginTop,
; 		props.MarginBottom)
; 		; return Format('
; 		; 	(
; 		; 		{\rtf1\ansi\ansicpg1252\deff0\nouicompat\deflang1033
; 		; 		{{\fonttbl
; 		; 			{{\f0\froman\fprq2\fcharset0 Times New Roman;}}
; 		; 			{{\f1\fnil Times New Roman;}}
; 		; 			{{\f2\fnil\fcharset2 Symbol;}}
; 		; 		}}
; 		; 		{{\colortbl ;\red0\green0\blue0;}}
; 		; 		\viewkind4\uc1\pard\f0\fs22
; 		; 	)')
; 	}

; 	/**
; 	 * @description Creates a list table definition for RTF
; 	 * @returns {String} RTF list table definition
; 	 */
; 	static GetListTableDef() {
; 		return '
; 		(
; 			{\*\listtable{\list\listtemplateid2181
; 				{\listlevel\levelnfc23\leveljc0\li1910\fi-241
; 					{\leveltext\'01\uc1\u61548 ?;}
; 					{\levelnumbers;}\f2\fs14\b0\i0}
; 				{\listlevel\levelnfc23\leveljc0\li2808\fi-241
; 					{\leveltext\'01\'95;}{\levelnumbers;}}
; 				{\listlevel\levelnfc23\leveljc0\li3696\fi-241
; 					{\leveltext\'01\'95;}{\levelnumbers;}}
; 				\listid1026}
; 			}
; 			{\*\listoverridetable{\listoverride\listoverridecount0\listid1026\ls1}}
; 		)'
; 	}

;     /**
;      * @description Sets clipboard content as RTF format with enhanced error handling
;      * @param {String} rtfText The RTF formatted text
;      * @throws {Error} If clipboard operations fail
;      */
;     static SetClipboardRTF(rtfText) {
;         ; Register RTF format if needed
;         static CF_RTF := DllCall("RegisterClipboardFormat", "Str", "Rich Text Format", "UInt")
		
;         if (!CF_RTF)
;             throw Error("Failed to register RTF clipboard format", -1)
		
;         ; Open and clear clipboard with timeout handling
;         startTime := A_TickCount
;         while (!DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)) {
;             if (A_TickCount - startTime > 1000)
;                 throw Error("Failed to open clipboard", -1)
;             Sleep(10)
;         }
		
;         DllCall("EmptyClipboard")
		
;         ; Allocate and copy RTF data
;         hGlobal := DllCall("GlobalAlloc", "UInt", 0x42, "Ptr", StrPut(rtfText, "UTF-8"))
;         if (!hGlobal)
;             throw Error("Failed to allocate memory for clipboard", -1)
			
;         try {
;             pGlobal := DllCall("GlobalLock", "Ptr", hGlobal, "Ptr")
;             if (!pGlobal)
;                 throw Error("Failed to lock global memory", -1)
				
;             StrPut(rtfText, pGlobal, "UTF-8")
;             DllCall("GlobalUnlock", "Ptr", hGlobal)
			
;             ; Set clipboard data
;             if (!DllCall("SetClipboardData", "UInt", CF_RTF, "Ptr", hGlobal))
;                 throw Error("Failed to set clipboard data", -1)
;         } catch Error as err {
;             ; Cleanup on error
;             DllCall("GlobalFree", "Ptr", hGlobal)
;             DllCall("CloseClipboard")
;             throw err
;         }
		
;         DllCall("CloseClipboard")
;         Sleep(50)  ; Small delay to ensure clipboard operations complete
;     }

; }

class rtfHandler extends docProperties {

	static SetClipboardRTF(rtfText) {
		static CF_RTF := DllCall('RegisterClipboardFormat', 'Str', 'Rich Text Format', 'UInt')
		
		if (!CF_RTF) {
			throw Error('Failed to register RTF format', -1) 
		}

		startTime := A_TickCount
		while (!DllCall('OpenClipboard', 'Ptr', A_ScriptHwnd)) {
			if (A_TickCount - startTime > 1000) {
				throw Error('Failed to open clipboard', -1)
			}
			Sleep(10)
		}
		
		DllCall('EmptyClipboard')
		
		hGlobal := DllCall('GlobalAlloc', 'UInt', 0x42, 'Ptr', StrPut(rtfText, 'UTF-8'))
		if (!hGlobal) {
			throw Error('Failed to allocate memory for clipboard', -1)
		}
			
		try {
			pGlobal := DllCall('GlobalLock', 'Ptr', hGlobal, 'Ptr')
			if (!pGlobal) {
				throw Error('Failed to lock global memory', -1)
			}
				
			StrPut(rtfText, pGlobal, 'UTF-8')
			DllCall('GlobalUnlock', 'Ptr', hGlobal)
			
			if (!DllCall('SetClipboardData', 'UInt', CF_RTF, 'Ptr', hGlobal)) {
				throw Error('Failed to set clipboard data', -1)
			}
		} catch Error as err {
			DllCall('GlobalFree', 'Ptr', hGlobal)
			DllCall('CloseClipboard')
			throw err
		}
		
		DllCall('GlobalFree', 'Ptr', hGlobal)
		DllCall('CloseClipboard')
		Sleep(Clip.delayTime)
	}

	static GetHeader() {
		props := this.Properties
		return Format('{\rtf1\ansi\ansicpg{1}\deff0\nouicompat\deflang1033{{\fonttbl{{\f0\{2}\fprq{3}\fcharset0 {4};}}}}{{\colortbl;\red0\green0\blue0;}}\viewkind4\uc1\pard\cf1\f0\fs{5}',
			props.CharSet,
			props.DefaultFont,
			props.DefaultPrq,
			props.FontFamily,
			props.FontSize * 2)
	}

	static GetListTableDef() {
		return "{\*\listtable{\list\listtemplateid2181{\listlevel\levelnfc23\leveljc0\li1910\fi-241{\leveltext\'01\uc1\u61548 ?;}{\levelnumbers;}\f2\fs14\b0\i0}{\listlevel\levelnfc23\leveljc0\li2808\fi-241{\leveltext\'01\'95;}{\levelnumbers;}}{\listlevel\levelnfc23\leveljc0\li3696\fi-241{\leveltext\'01\'95;}{\levelnumbers;}}\listid1026}}{\*\listoverridetable{\listoverride\listoverridecount0\listid1026\ls1}}"
	}
}

class markdownHandler extends docProperties {

	static ToRTF(markdown := '') {
		if (!markdown) {
			return ''
		}

		rtf := RTFHandler.GetHeader()
		rtf .= RTFHandler.GetListTableDef()
		
		text := this._ProcessTextFormatting(markdown)
		text := this._ProcessLists(text)
		
		rtf .= text "}"
		return rtf
	}

	static _ProcessTextFormatting(text) {
		props := this.Properties
		; Bold
		text := RegExReplace(text, "\*\*([^*]+?)\*\*", "\b $1\b0 ")
		
		; Italic
		text := RegExReplace(text, "(?<![*])\*([^*]+?)\*(?![*])", "\i $1\i0 ")
		text := RegExReplace(text, "(?<![_])_([^_]+?)_(?![_])", "\i $1\i0 ")
		
		; Strikethrough
		text := RegExReplace(text, "~~([^~]+?)~~", "\strike $1\strike0 ")

		; Headers with font sizes
		try {
			RegExMatch(text, 'm)((?<![#])#+)', &headermatch)
			if (headermatch.len > 0) {
				text := RegExReplace(text, 'm)#{' headermatch.len "}\s([\w]+\b[\w ]+)", 
					Format("\line\f0\fs{1}\b $1\b0\f0\fs{2}\line\f0 ", 
					props.FontSize[headermatch.len], props.DefaultFont))
			}
		}

		return text
	}
	static _ProcessLists(text) {

		; RegEx pattern for bullet points - capture indentation level
		bulletPattern := 'm)^([\s]*)(- |• )(.*)'  ; Groups: (1)indent (2)bullet (3)text
		bulletPatternOnly := 'm)^([\s]*)(- |• )'
		
		; RTF list format patterns with \'B7 bullet
		firstLevelBullet := "\pard{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-360\li360 $3 \par"
		
		secondLevelBullet := "\pard{\listtext\f2\'B7\tab}\ls1\ilvl1\fi-360\li720\tx360\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\tx9360 $3 \par"
		
		arrText := arrMatch := []
		t := match := ''
		
		arrText := StrSplit(text, '`n')
		
		; Collect bullet points
		for t in arrtext {
			if t ~= bulletPatternOnly {
				arrMatch.Push(t)
			}
		}
		
		; Process each bullet point
		for match in arrMatch {
			index := arrText.IndexOf(match)
			; Check if it's an indented bullet (second level)
			if RegExMatch(match, bulletPattern, &m) && m[1] {  ; Has indentation
				nText := RegExReplace(match, bulletPattern, secondLevelBullet)
			} else {  ; First level bullet
				nText := RegExReplace(match, bulletPattern, firstLevelBullet)
			}
			arrText.RemoveAt(index)
			arrText.InsertAt(index, nText)
		}
	
		text := ''
		for each, value in arrText {
			if value ~= "\\f2\\'B7\\tab" {
				text .= value (A_Index < arrText.Length ? "`n" : '')
			}
			else {
				code := "\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\tx9360\tx10080\f0\fs22 "
				if A_Index == 1 {
					text .= code value 
				}
				else {
					text .= code value (A_Index < arrText.Length ? "`n" : '')
				}
			}
		}

		; Handle line breaks
		text := RegExReplace(text, "\R\R+", "\par ")
		text := RegExReplace(text, "(?<!\\par)\R", "\par ")
		
		; Clean up
		text := RegExReplace(text, "\s+$", "")
	
		return text
	}
}

class plainText {
	; Add to String2 class
	static SetPlainText(text:='') {
		; if text = ''{
			; 	text := this
		; }
		text := this
		CF_TEXT := 1

		if DllCall("OpenClipboard", "Ptr") {
			DllCall("EmptyClipboard")
			hMem := DllCall("GlobalAlloc", "UInt", 0x42, "Ptr", StrPut(text, "UTF-8"))
			pMem := DllCall("GlobalLock", "Ptr", hMem)
			StrPut(text, pMem, "UTF-8")
			DllCall("GlobalUnlock", "Ptr", hMem)
			DllCall("SetClipboardData", "UInt", CF_TEXT, "Ptr", hMem)
			DllCall("CloseClipboard")
			return true
		}
		return false
	}

	static wmPaste(controlHwnd) {
		WM_PASTE := 0x0302
		return DllCall("SendMessage", "Ptr", controlHwnd, "UInt", WM_PASTE, "Ptr", 0, "Ptr", 0)
	}

	static emPasteSpec(controlHwnd, format := 1) {
		EM_PASTESPECIAL := 0x0440
		return DllCall("SendMessage", "Ptr", controlHwnd, "UInt", EM_PASTESPECIAL, "Ptr", format, "Ptr", 0)
	}

	static __New(text := '') {
		this.SetPlainText(text)
		hCtl := ControlGetFocus("A")
		; return this.wmPaste(hCtl)
		return this.emPasteSpec(hCtl)
	}
}

/**
 * @class FormatConverter
 * @description Enhanced converter between plain text, HTML, RTF, and Markdown formats
*/

class FormatConverter {
	
	class RTFFormat {
		static Properties := {
			FontFamily: "Times New Roman",
			FontSize: 22,  ; RTF uses half-points
			FontColor: "000000",
			DefaultFont: "froman",
			DefaultPrq: 2,
			CharSet: 1252,
			StyleMappings: Map(
				"strike", "\strike",
				"super", "\super",
				"sub", "\sub",
				"bullet", "• ",
				"align-left", "\ql",
				"align-right", "\qr",
				"align-center", "\qc",
				"align-justify", "\qj"
			)
		}
	
		static GetHeader() {
			props := this.Properties
			return Format('
				(
					{\rtf1\ansi\ansicpg{1}\deff0\nouicompat\deflang1033
					{{\fonttbl{{\f0\{2}\fprq{3}\fcharset0 {4};}}}}
					{{\colortbl ;\red0\green0\blue0;}}
					\viewkind4\uc1\pard\cf1\f0\fs{5}
				)',
				props.CharSet,
				props.DefaultFont,
				props.DefaultPrq,
				props.FontFamily,
				props.FontSize)
		}
	
		static ApplyFontStyle(text, family := this.Properties.FontFamily, size := this.Properties.FontSize) {
			rtf := this.GetHeader()
			if (size != "")
				rtf .= "\fs" size
			if (family != "")
				rtf .= "\fname " family
			rtf .= " " text "`n}"
			return rtf
		}
	
		static ApplyFormatting(text, format) {
			props := this.Properties
			if props.StyleMappings.Has(format)
				return props.StyleMappings[format] . " " text . (format ~= "align" ? "" : "\" format "0")
			return text
		}
	}

	static Properties := RTFHandler.Properties

	; Define font sizes
	static dFont := 22  ; Default font size (11pt)
	
	static dS := this.dFont
	static h6 := this.dS + 2        ; Header 6 size (12pt * 2)
	static h5 := this.h6 + 2        ; Header 5 size (13pt * 2)
	static h4 := this.h5 + 2        ; Header 4 size (14pt * 2)
	static h3 := this.h4 + 2        ; Header 3 size (15pt * 2)
	static h2 := this.h3 + 2        ; Header 2 size (16pt * 2)
	static h1 := this.h2 + 2        ; Header 1 size (17pt * 2)
	static hSize := [this.h6, this.h5, this.h4, this.h3, this.h2, this.h1]

	/**
	 * Verifies if content is RTF and validates its structure
	 * @param {String} content The content to verify
	 * @returns {Object} {isRTF: Boolean, content: String}
	 */
	static VerifyRTF(content) {
		; Type check
		if (Type(content) != "String")
			return {isRTF: false, content: content}
		
		; Quick header check first
		; if !RegExMatch(content, "i)^{\s*\\rtf1\b") {
		if !(content ~= 'rtf1') {
			return {isRTF: false, content: content}
		}
		; More detailed RTF validation checks
		rtfChecks := [
			"\{\\rtf1",                     ; RTF version 1
			"\{\\fonttbl",                  ; Font table
			"\{\\colortbl",                 ; Color table
			"\\viewkind4",                  ; View kind
			"\\fs\d+",                      ; Font size
			"\\f\d+",                       ; Font number
			"\\cf\d+",                      ; Color reference
			"\\b(?!\w)",                    ; Bold
			"\\i(?!\w)",                    ; Italic
			"\\ul(?!\w)",                   ; Underline
			"\\strike(?!\w)",               ; Strikethrough
			"\\pard",                       ; Paragraph defaults
			"\\par\b",                      ; Paragraph break
			"\\q[lrcj]",					; Alignment
			"\\'[0-9a-fA-F]{2}",			; Hex character codes
			"\\u\d+",                       ; Unicode character
			"\{[^{}]*\}",                   ; Valid group structure
			"\\[a-z]+(?:-?\d+)?"            ; Valid control words
		]
		
		matchCount := 0
		for pattern in rtfChecks {
			if RegExMatch(content, "i)" pattern)
				matchCount++
		}
		
		; Calculate confidence score (adjust threshold as needed)
		; confidenceThreshold := 4  ; Minimum number of matches needed
		confidenceThreshold := 1  ; Minimum number of matches needed
		isRTF := matchCount >= confidenceThreshold
		
		; Validate basic structure integrity
		if isRTF {
			; Check for balanced braces
			braceCount := 0
			Loop Parse, content {
				if (A_LoopField = "{")
					braceCount++
				else if (A_LoopField = "}")
					braceCount--
				if (braceCount < 0)
					return {isRTF: false, content: content}
			}
			if (braceCount != 0)
				return {isRTF: false, content: content}
		}

		return {isRTF: isRTF, content: content}
	}

	/**
	 * Comprehensive RTF content check and standardization
	 * @param {String} content Content to check/standardize
	 * @param {Boolean} standardize Whether to force standardization
	 * @returns {String} Verified/standardized RTF or original content
	 */
	static IsRTF(content, standardize := false) {
		; Use VerifyRTF to check content
		result := this.VerifyRTF(content)
		
		; If standardization requested or content is RTF
		if (standardize || result.isRTF) {
			return this.RTFtoRTF(result.content)
		}
		
		return content
	}

	/**
	 * @description Process text formatting elements
	 * @param {String} text The text to process
	 * @returns {String} Processed text with RTF formatting
	 */
	static _ProcessTextFormatting(text) {

		; Bold handling with non-greedy matching
		text := RegExReplace(text, "\*\*([^*]+?)\*\*", "\b $1\b0 ")
		
		; Italic handling with improved patterns
		text := RegExReplace(text, "(?<![*])\*([^*]+?)\*(?![*])", "\i $1\i0 ")
		text := RegExReplace(text, "(?<![_])_([^_]+?)_(?![_])", "\i $1\i0 ")
		
		; Strikethrough
		text := RegExReplace(text, "~~([^~]+?)~~", "\strike $1\strike0 ")

		; Underline with multiple patterns
		text := RegExReplace(text, "__([^_]+?)__", "\ul $1\ul0 ")
		text := RegExReplace(text, "~([^~]+?)~", "\ul $1\ul0 ")
		
		; Special characters
		text := StrReplace(text, "°", "\'b0")
		; text := RegExReplace(text, "(?<!\\)• ", "\f2\'B7\f0 ")
		
		return text
	}

	/**
	 * @description Process list formatting with improved structure
	 * @param {String} text The text to process
	 * @returns {String} Processed text with RTF list formatting
	 */

	static _ProcessLists(text) {
		; RegEx pattern for bullet points - capture indentation level
		bulletPattern := 'm)^([\s]*)(- |• )(.*)'  ; Groups: (1)indent (2)bullet (3)text
		bulletPatternOnly := 'm)^([\s]*)(- |• )'
		
		; RTF list format patterns with \'B7 bullet
		firstLevelBullet := "\pard{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-360\li360 $3 \par"
		
		secondLevelBullet := "\pard{\listtext\f2\'B7\tab}\ls1\ilvl1\fi-360\li720\tx360\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\tx9360 $3 \par"
		
		arrText := arrMatch := []
		t := match := ''
		
		arrText := StrSplit(text, '`n')
		
		; Collect bullet points
		for t in arrtext {
			if t ~= bulletPatternOnly {
				arrMatch.Push(t)
			}
		}
		
		; Process each bullet point
		for match in arrMatch {
			index := arrText.IndexOf(match)
			; Check if it's an indented bullet (second level)
			if RegExMatch(match, bulletPattern, &m) && m[1] {  ; Has indentation
				nText := RegExReplace(match, bulletPattern, secondLevelBullet)
			} else {  ; First level bullet
				nText := RegExReplace(match, bulletPattern, firstLevelBullet)
			}
			arrText.RemoveAt(index)
			arrText.InsertAt(index, nText)
		}
	
		text := ''
		for each, value in arrText {
			if value ~= "\\f2\\'B7\\tab" {
				text .= value (A_Index < arrText.Length ? "`n" : '')
			}
			else {
				code := "\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\tx9360\tx10080\f0\fs22 "
				if A_Index == 1 {
					text .= code value 
				}
				else {
					text .= code value (A_Index < arrText.Length ? "`n" : '')
				}
			}
		}

		; Handle line breaks
		text := RegExReplace(text, "\R\R+", "\par ")
		text := RegExReplace(text, "(?<!\\par)\R", "\par ")
		
		; Clean up
		text := RegExReplace(text, "\s+$", "")
	
		return text
	}
	/**
	 * @description Enhanced RTF processing with proper formatting maintenance
	 * @param {String} rtf The RTF content to process
	 * @param {Boolean} standardize Whether to force standardization
	 * @returns {String} Processed RTF content
	 */
	static RTFtoRTF(rtf := '', standardize := true) {
		if (!rtf){
			return ''
		}
		; Verify and process RTF content
		verifiedRTF := this.VerifyRTF(rtf)
		; Infos('Verify RTF: (T: ' true ' F: ' false ' ) : ' verifiedRTF.isRTF)
		if (!verifiedRTF.isRTF && !standardize){
			return rtf
		}
		; Start with standard header and list table
		standardRtf := RTFHandler.GetHeader()
		standardRtf .= RTFHandler.GetListTableDef()
		
		; Extract content after headers
		text := verifiedRTf.content
		if (RegExMatch(rtf, "\\viewkind4\\uc1.*?({[^{]+}|[^{]+)$", &match))
			text := match[1]
			
		; Clean up content
		text := RegExReplace(text, "^\s*{*\s*", "")  ; Remove leading braces/spaces
		text := RegExReplace(text, "\s*}*\s*$", "")  ; Remove trailing braces/spaces
		
		; Process line breaks
		text := StrReplace(text, "`r`n", "\line")
		text := StrReplace(text, "`r", "\line")
		
		; Process lists maintaining proper structure
		text := this._ProcessRTFLists(text)
		
		; Return assembled RTF
		return standardRtf . text . "}"
	}

	/**
	 * @description Converts HTML to RTF with enhanced formatting support
	 * @param {String} html The HTML text to convert
	 * @returns {String} RTF formatted text
	 */
	static HTMLToRTF(html := '') {
		if (!IsSet(html) || html = '')
			return ''
			
		; Start with enhanced header
		rtf := RTFHandler.GetHeader()
		rtf .= RTFHandler.GetListTableDef()

		text := html

		; Pre-process line breaks for consistent handling
		text := StrReplace(text, "`n", "\line ")
		text := RegExReplace(text, '<br[^>]*>|<BR[^>]*>', '\line ')

		; Enhanced paragraph handling from rtf_example.rtf
		text := RegExReplace(text, '<p[^>]*>', '{\pard\plain\s1\nooverflow\nocwrap\lnbrkrule\li1909\sl230\slmult1 ')
		text := RegExReplace(text, '</p>', '\par}')

		; Improved heading handling with proper spacing
		text := RegExReplace(text, '<h1[^>]*>(.*?)</h1>', 
			'{\pard\s2\li1689\sl232\slmult1\sb109\f1\fs' . (this.dFont + 4) . '\b1 $1\par}')
		text := RegExReplace(text, '<h2[^>]*>(.*?)</h2>', 
			'{\pard\s2\li1689\sl232\slmult1\sb109\f1\fs' . (this.dFont + 2) . '\b1 $1\par}')

		; Enhanced list handling
		text := this._ProcessHTMLLists(text)

		; Style handling with spacing control
		text := RegExReplace(text, '<(b|bold|strong)[^>]*>', '\b ')
		text := RegExReplace(text, '</(b|bold|strong)>', '\b0 ')
		text := RegExReplace(text, '<(i|italics|em)[^>]*>', '\i ')
		text := RegExReplace(text, '</(i|italics|em)>', '\i0 ')
		text := RegExReplace(text, '<u>([^\n]+)</u>', '\ul $1\ul0')
		text := RegExReplace(text, '<s>([^\n]+)</s>', '\strike $1\strike0 ')

		; Special characters
		text := StrReplace(text, "°", "\'b0")

		; Clean up and return
		rtf .= text '}'
		return rtf
	}

	/**
	 * @description Process HTML lists with proper RTF formatting
	 * @param {String} text The text to process
	 * @returns {String} Processed text with RTF list formatting
	 */
	static _ProcessHTMLLists(text) {
		; Convert unordered lists
		text := RegExReplace(text, '<ul[^>]*>', '{\pard\plain\s3\ls1\ilvl0\nooverflow\nocwrap\lnbrkrule\li1909\fi-239\sl240\slmult1 ')
		text := RegExReplace(text, '</ul>', '\par}')
		
		; Convert list items with proper bullets
		text := RegExReplace(text, '<li[^>]*>', "{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-360\li360 ")
		text := RegExReplace(text, '</li>', '\par')

		return text
	}

	/**
	 * @description Process RTF lists maintaining proper structure
	 * @param {String} text The text to process
	 * @returns {String} Processed text with proper RTF list structure
	 */
	static _ProcessRTFLists(text) {
		; Convert basic bullets to properly formatted list items
		text := RegExReplace(text, 
			"\\bullet\s+", 
			"{\pntext\f2\'B7\tab}{\*\pn\pnlvlblt\pnf2\pnindent0{\pntxtb\'B7}}\fi-360\li360 ")
		
		; Handle list levels
		text := RegExReplace(text, 
			"(?<=\\pard)\\plain\\s3\\ls1\\ilvl([0-9])\\nooverflow\\nocwrap\\lnbrkrule", 
			"\plain\s3\ls1\ilvl$1\nooverflow\nocwrap\lnbrkrule\li1909\fi-239")

		return text
	}

	/**
	 * Converts Markdown text to RTF format with enhanced header and formatting support
	 * @param {String} markdown The markdown text to convert
	 * @returns {String} RTF formatted text
	 */

	static MarkdownToRTF(markdown := '') {
		if (!IsSet(markdown) || markdown = '')
			return ''
		
		; Process content first
		text := markdown
		text := this._ProcessTextFormatting(text)
		text := this._ProcessLists(text)
		
		; Check if result already has RTF header
		if (!RegExMatch(text, "i)^{\s*\\rtf1\b")) {
		; if !(text ~= "rtf1") {
			; Only add RTF header if needed
			rtf := RTFHandler.GetHeader()
			rtf .= RTFHandler.GetListTableDef()
			rtf .= text "}"
			return rtf
		}
		
		return text
	}

	/**
	 * @description Updated Markdown to HTML conversion with improved formatting
	 * TODO [] - Implement?
	 */
	/*
	static MarkdownToHTML(markdown := '') {
		if (!IsSet(markdown) || markdown = '')
			return ''
		props := this.Properties
		; Pre-process linebreaks for consistent handling
		markdown := StrReplace(markdown, "`r`n", "`n")
		html := markdown
		
		; Headers (with proper spacing)
		html := RegExReplace(html, "m)^# ([^`n]+)$", "<h1>$1</h1>`n")
		html := RegExReplace(html, "m)^## ([^`n]+)$", "<h2>$1</h2>`n")
		
		; Bold (with proper spacing)
		html := RegExReplace(html, "\*\*([^\*]+?)\*\*", "<strong>$1</strong>")
		html := RegExReplace(html, "__([^_]+?)__", "<strong>$1</strong>")
		
		; Italic (with proper spacing)
		html := RegExReplace(html, "\*([^\*]+?)\*", "<em>$1</em>")
		html := RegExReplace(html, "_([^_]+?)_", "<em>$1</em>")
		
		; Lists (with proper nesting)
		html := RegExReplace(html, "m)^- (.+)$", "<li>$1</li>")
		html := RegExReplace(html, "(<li>.*</li>`n)+", "<ul>`n$0</ul>`n")
		
		; Paragraphs (with proper spacing)
		html := RegExReplace(html, "(`n`n|^)(?!<[uo]l|<[hp]|<li)(.+?)(?=`n`n|$)", "<p>$2</p>")
		
		; Wrap with HTML structure
		html := Format('
		(
			<!DOCTYPE html>
			<html>
			<head>
			<meta charset="utf-8">
			<style>
			ul {{ margin-left: 1em; padding-left: 1em; }}
			li {{ margin: 0.25em 0; }}
			</style>
			</head>
			<body>
			{3}
			</body>
			</html>
		)', 
		props.FontFamily,
		props.FontSize,
		html)

		return html
	}
	*/

}


String.Prototype := String2

class String2 {

	static __New() {
		; Add String2 methods and properties into String object
		__ObjDefineProp := Object.Prototype.DefineProp
		for __String2_Prop in String2.OwnProps() {
			if !(__String2_Prop ~= "__Init|__Item|Prototype|Length") {
				if HasMethod(String2, __String2_Prop)
					__ObjDefineProp(String.Prototype, __String2_Prop, {call:String2.%__String2_Prop%})
			}
		}
		__ObjDefineProp(String.Prototype, "__Item", {get:(args*)=>String2.__Item[args*]})
		__ObjDefineProp(String.Prototype, "Length", {get:(arg)	=>String2.Length(arg)})
		__ObjDefineProp(String.Prototype, "WLength",{get:(arg)	=>String2.WLength(arg)})
	}

	static MarkdownToRTF(t := this) => FormatConverter.MarkdownToRTF(this)
	static rtf(text:=''){
		if !IsSet(text) || text := '' {
			text := this
		}
		; Auto-detect format and convert if needed
		if RegExMatch(text, "^{\rtf1"){ ; Already RTF
			return text
		}
		if RegExMatch(text, "^<!DOCTYPE html|^<html"){ ; HTML
			return FormatConverter.HTMLToRTF(text)
		}
		if RegExMatch(text, "^#|^\*\*|^- "){ ; Markdown
			return FormatConverter.MarkdownToRTF(text)
		}
		; Plain text - convert to RTF
		return FormatConverter.RTFFormat.ApplyFontStyle(text, FormatConverter.RTFFormat.Properties.FontFamily)
	
	}


	/**
	 * @description Converts a string to a Map object
	 * @param {String} strObj Optional string to convert, uses 'this' if not provided
	 * @returns {Map} Map object with key-value pairs from the string
	 * @example
	 * str := "key1=value1`nkey2=value2"
	 * mapObj := String.ToMap(str)
	 * ;!Or: 
	 * mapObj := str.ToMap()
	 */
	static ToMap(strObj*) {
		return this._StringToMap(Type('String') && IsSet(strObj) ? strObj : this)
	}
	

	/**
	 * @description Converts a string to an Array by splitting on newlines
	 * @param {String} strObj Optional string to convert, uses 'this' if not provided
	 * @returns {Array} Array containing lines from the string
	 * @throws {TypeError} If input is not a string
	 * @example
	 * str := "line1`nline2`nline3"
	 * arr := str.ToArray(str)
	 * ;! Or
	 * arrObj := str.ToArray()
	 */

	static ToArray(strObj*) {
		return this._StringToArray(Type('String') && IsSet(strObj) ? strObj : this)
	}

	/**
	 * @description Converts a string to an Object with properties
	 * @param {String} strObj Optional string to convert, uses 'this' if not provided
	 * @returns {Object} Object with properties from the string
	 * @example
	 * str := "prop1=value1`nprop2=value2"
	 * obj := String2.ToObject(str)
	 * ; Or: obj := str.ToObject()
	 */
	; static ToObject(strObj*) {
	;     return this._StringToObject(Type('String') && IsSet(strObj) ? strObj : this)
	; }

	/**
	 * @description Converts a string to a Map object
	 * @param {String} strObj Optional string to convert, uses 'this' if not provided
	 * @returns {Map} Map object with key-value pairs from the string
	 * @throws {TypeError} If input is not a string
	 * @example
	 * str := "key1=value1`nkey2=value2"
	 * mapObj := String2.ToMap(str)
	 */

	; TODO Fix - still not passing tests
	; static ToMap(strObj?) {
	;     str := Type(strObj) = "String" ? strObj : this
	;     if (Type(str) != "String")
	;         throw TypeError("Input must be a string")
		
	;     map := Map()
	;     if (str = "")
	;         return map
			
	;     for line in StrSplit(str, "`n", "`r") {
	;         if (line := Trim(line)) {
	;             parts := StrSplit(line, "=", " `t", 2)
	;             if (parts.Length = 2)
	;                 map[Trim(parts[1])] := Trim(parts[2])
	;         }
	;     }
	;     return map
	; }
	
	/**
	 * @description Converts a string to an Object with properties
	 * @param {String} strObj Optional string to convert, uses 'this' if not provided
	 * @returns {Object} Object with properties from the string
	 * @throws {TypeError} If input is not a string
	 * @example
	 * str := "prop1=value1`nprop2=value2"
	 * obj := String2.ToObject(str)
	 */

	static ToObject(strObj?) {
		str := Type(strObj) = "String" ? strObj : this
		if (Type(str) != "String")
			throw TypeError("Input must be a string")
		
		obj := {}
		if (str = "")
			return obj
			
		for line in StrSplit(str, "`n", "`r") {
			if (line := Trim(line)) {
				parts := StrSplit(line, "=", " `t", 2)
				if (parts.Length = 2 && RegExMatch(parts[1], "^[a-zA-Z_]\w*$"))
					obj.%Trim(parts[1])% := Trim(parts[2])
			}
		}
		return obj
	}

	static _StringToMap(str:='') {
		mapObj := Map()
		str := this
		for line in StrSplit(str, "`n", "`r") {
		; for line in StrSplit(this, "`n", "`r") {
			if (line := Trim(line)) {
				parts := StrSplit(line, "=", " `t", 2)
				if (parts.Length = 2)
					mapObj[parts[1]] := parts[2]
			}
		}
		return mapObj
	}
	
	static _StringToArray(str:='') {
		return StrSplit(!str? this : str, "`n", "`r")
	}

	static _StringToObject(str) {
		obj := {}
		for line in StrSplit(str, "`n", "`r") {
			if (line := Trim(line)) {
				parts := StrSplit(line, "=", " `t", 2)
				if (parts.Length = 2)
					obj.%parts[1]% := parts[2]
			}
		}
		return obj
	}

	static __Item[args*] {
		get {
			if (args.Length = 2) {
				index := IsInteger(args[2]) ? args[2] : 1
				return SubStr(args[1], index, 1)
			}
			else {
				len := StrLen(args[1])
				start := IsInteger(args[2]) ? args[2] : 1
				end := IsInteger(args[3]) ? args[3] : len
				
				if (start < 0){
					start := len + start + 1
				}
				if (end < 0){
					end := len + end + 1
				}
				if (end >= start){
					return SubStr(args[1], start, end - start + 1)
				}
				else{
					return SubStr(args[1], end, start - end + 1).Reverse()
				}
			}
		}
	}

	; Native functions implemented as methods for the String object
	static Length(str)    => StrLen(str)
	static WLength(str)   => (RegExReplace(str, "s).", "", &i), i)
	static ToUpper()      => StrUpper(this)
	static ToLower()      => StrLower(this)
	static ToTitle()      => StrTitle(this)
	static Split(args*)   => StrSplit(this, args*)
	static Replace(args*) => StrReplace(this, args*)
	static Trim(args*)    => Trim(this, args*)
	static LTrim(args*)   => LTrim(this, args*)
	static RTrim(args*)   => RTrim(this, args*)
	static Compare(args*) => StrCompare(this, args*)
	static Sort(args*)    => Sort(this, args*)
	static Find(args*)    => InStr(this, args*)
	static SplitPath()    => (SplitPath(this, &a1, &a2, &a3, &a4, &a5), {FileName: a1, Dir: a2, Ext: a3, NameNoExt: a4, Drive: a5})
	
	/**
	 * @description Returns the match object
	 * @param needleRegex *String* What pattern to match
	 * @param startingPos *Integer* Specify a number to start matching at. By default, starts matching at the beginning of the string
	 * @returns {Object}
	 */
	static RegExMatch(needleRegex, &match?, startingPos?) => (RegExMatch(this, needleRegex, &match, startingPos?), match)
	/**
	 * Uses regex to perform a replacement, returns the changed string
	 * @param needleRegex *String* What pattern to match
	 * @param replacement *String* What to replace that match into
	 * @param outputVarCount *Varref* Specify a variable with a `&` before it to assign it to the amount of replacements that have occured
	 * @param limit *Integer* The maximum amount of replacements that can happen. Unlimited by default
	 * @param startingPos *Integer* Specify a number to start matching at. By default, starts matching at the beginning of the string
	 * @returns {String} The changed string
	 */
	static RegExReplace(needleRegex, replacement?, &outputVarCount?, limit?, startingPos?) => RegExReplace(this, needleRegex, replacement?, &outputVarCount?, limit?, startingPos?)

	/**
	 * @description Add character(s) to left side of the input string.
	 * example: "aaa".LPad("+", 5)
	 * output: +++++aaa
	 * @param padding Text you want to add
	 * @param count How many times do you want to repeat adding to the left side.
	 * @returns {String}
	 */
	static LPad(padding, count:=1) {
		str := this
		if (count>0) {
			Loop count
				str := padding str
		}
		return str
	}

	/**
	 * @description Add character(s) to right side of the input string.
	 * example: "aaa".RPad("+", 5)
	 * output: aaa+++++
	 * @param padding Text you want to add
	 * @param count How many times do you want to repeat adding to the left side.
	 * @returns {String}
	 */
	static RPad(padding, count:=1) {
		str := this
		if (count>0) {
			Loop count
				str := str padding
		}
		return str
	}

	/**
	 * @description Count the number of occurrences of needle in the string
	 * input: "12234".Count("2")
	 * output: 2
	 * @param needle Text to search for
	 * @param caseSensitive
	 * @returns {Integer}
	 */
	static Count(needle, caseSensitive:=False) {
		StrReplace(this, needle,, caseSensitive, &count)
		return count
	}

	/**
	 * @description Duplicate the string 'count' times.
	 * input: "abc".Repeat(3)
	 * output: "abcabcabc"
	 * @param count *Integer*
	 * @returns {String}
	 */
	static Repeat(count) => StrReplace(Format("{:" count "}",""), " ", this)

	/**
	 * @description Reverse the string.
	 * @returns {String}
	 */
	static Reverse() {
		DllCall("msvcrt\_wcsrev", "str", str := this, "CDecl str")
		return str
	}
	static WReverse() {
		str := this, out := "", m := ""
		While str && (m := Chr(Ord(str))) && (out := m . out)
			str := SubStr(str,StrLen(m)+1)
		return out
	}

	/**
	 * @description Insert the string inside 'insert' into position 'pos'
	 * input: "abc".Insert("d", 2)
	 * output: "adbc"
	 * @param insert The text to insert
	 * @param pos *Integer*
	 * @returns {String}
	 */
	static Insert(insert, pos:=1) {
		Length := StrLen(this)
		((pos > 0)
			? pos2 := pos - 1
			: (pos = 0
				? (pos2 := StrLen(this), Length := 0)
				: pos2 := pos
				)
		)
		output := SubStr(this, 1, pos2) . insert . SubStr(this, pos, Length)
		if (StrLen(output) > StrLen(this) + StrLen(insert))
			((Abs(pos) <= StrLen(this)/2)
				? (output := SubStr(output, 1, pos2 - 1)
					. SubStr(output, pos + 1, StrLen(this))
				)
				: (output := SubStr(output, 1, pos2 - StrLen(insert) - 2)
					. SubStr(output, pos - StrLen(insert), StrLen(this))
				)
			)
		return output
	}

	/**
	 * @description Replace part of the string with the string in 'overwrite' starting from position 'pos'
	 * input: "aaabbbccc".Overwrite("zzz", 4)
	 * output: "aaazzzccc"
	 * @param overwrite Text to insert.
	 * @param pos The position where to begin overwriting. 0 may be used to overwrite at the very end, -1 will offset 1 from the end, and so on.
	 * @returns {String}
	 */
	static Overwrite(overwrite, pos:=1) {
		if (Abs(pos) > StrLen(this))
			return ""
		else if (pos>0)
			return SubStr(this, 1, pos-1) . overwrite . SubStr(this, pos+StrLen(overwrite))
		else if (pos<0)
			return SubStr(this, 1, pos) . overwrite . SubStr(this " ",(Abs(pos) > StrLen(overwrite) ? pos+StrLen(overwrite) : 0), Abs(pos+StrLen(overwrite)))
		else if (pos=0)
			return this . overwrite
	}

	/**
	 * @description Delete a range of characters from the specified string.
	 * input: "aaabbbccc".Delete(4, 3)
	 * output: "aaaccc"
	 * @param start The position where to start deleting.
	 * @param length How many characters to delete.
	 * @returns {String}
	 */
	static Delete(start:=1, length:=1) {
		if (Abs(start) > StrLen(this))
			return ""
		if (start>0)
			return SubStr(this, 1, start-1) . SubStr(this, start + length)
		else if (start<=0)
			return SubStr(this " ", 1, start-1) SubStr(this " ", ((start<0) ? start-1+length : 0), -1)
	}

	/**
	 * @description Wrap the string so each line is never more than a specified length.
	 * input: "Apples are a round fruit, usually red".LineWrap(20, "---")
	 * output: "Apples are a round f
	 *          ---ruit, usually red"
	 * @param column Specify a maximum length per line
	 * @param indentChar Choose a character to indent the following lines with
	 * @returns {String}
	 */
	static LineWrap(column:=56, indentChar:="") {
		CharLength := StrLen(indentChar)
		, columnSpan := column - CharLength
		, Ptr := A_PtrSize ? "Ptr" : "UInt"
		, UnicodeModifier := 2
		, VarSetStrCapacity(&out, (finalLength := (StrLen(this) + (Ceil(StrLen(this) / columnSpan) * (column + CharLength + 1))))*2)
		, A := StrPtr(out)

		Loop parse, this, "`n", "`r" {
			if ((FieldLength := StrLen(ALoopField := A_LoopField)) > column) {
				DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField), "UInt", column * UnicodeModifier)
				, A += column * UnicodeModifier
				, NumPut("UShort", 10, A)
				, A += UnicodeModifier
				, Pos := column

				While (Pos < FieldLength) {
					if CharLength
						DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(indentChar), "UInt", CharLength * UnicodeModifier)
						, A += CharLength * UnicodeModifier

					if (Pos + columnSpan > FieldLength)
						DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField) + (Pos * UnicodeModifier), "UInt", (FieldLength - Pos) * UnicodeModifier)
						, A += (FieldLength - Pos) * UnicodeModifier
						, Pos += FieldLength - Pos
					else
						DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField) + (Pos * UnicodeModifier), "UInt", columnSpan * UnicodeModifier)
						, A += columnSpan * UnicodeModifier
						, Pos += columnSpan

					NumPut("UShort", 10, A)
					, A += UnicodeModifier
				}
			} else
				DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField), "UInt", FieldLength * UnicodeModifier)
				, A += FieldLength * UnicodeModifier
				, NumPut("UShort", 10, A)
				, A += UnicodeModifier
		}
		NumPut("UShort", 0, A)
		VarSetStrCapacity(&out, -1)
		return SubStr(out,1, -1)
	}

	/**
	 * @description Wrap the string so each line is never more than a specified length.
	 * Unlike LineWrap(), this method takes into account words separated by a space.
	 * input: "Apples are a round fruit, usually red.".WordWrap(20, "---")
	 * output: "Apples are a round
	 *          ---fruit, usually
	 *          ---red."
	 * @param column Specify a maximum length per line
	 * @param indentChar Choose a character to indent the following lines with
	 * @returns {String}
	 */
	static WordWrap(column:=56, indentChar:="") {
		if !IsInteger(column)
			throw TypeError("WordWrap: argument 'column' must be an integer", -1)
		out := ""
		indentLength := StrLen(indentChar)

		Loop parse, this, "`n", "`r" {
			if (StrLen(A_LoopField) > column) {
				pos := 1
				Loop parse, A_LoopField, " "
					if (pos + (LoopLength := StrLen(A_LoopField)) <= column)
						out .= (A_Index = 1 ? "" : " ") A_LoopField
						, pos += LoopLength + 1
					else
						pos := LoopLength + 1 + indentLength
						, out .= "`n" indentChar A_LoopField

				out .= "`n"
			} else
				out .= A_LoopField "`n"
		}
		return SubStr(out, 1, -1)
	}

	/**
	* @description Insert a line of text at the specified line number.
	* The line you specify is pushed down 1 and your text is inserted at its
	* position. A "line" can be determined by the delimiter parameter. Not
	* necessarily just a `r or `n. But perhaps you want a | as your "line".
	* input: "aaa|ccc|ddd".InsertLine("bbb", 2, "|")
	* output: "aaa|bbb|ccc|ddd"
	* @param insert Text you want to insert.
	* @param line What line number to insert at. Use a 0 or negative to start inserting from the end.
	* @param delim The string which defines a "line".
	* @param exclude The text you want to ignore when defining a line.
	* @returns {String}
	*/
	static InsertLine(insert, line, delim:="`n", exclude:="`r") {
		into := this, new := ""
		count := into.Count(delim)+1

		; Create any lines that don't exist yet, if the Line is less than the total line count.
		if (line<0 && Abs(line)>count) {
			Loop Abs(line)-count
				into := delim into
			line:=1
		}
		if (line == 0)
			line:=Count+1
		if (line<0)
			line:=count+line+1
		; Create any lines that don't exist yet. Otherwise the Insert doesn't work.
		if (count<line)
			Loop line-count
				into.=delim

		Loop parse, into, delim, exclude
			new.=((a_index==line) ? insert . delim . A_LoopField . delim : A_LoopField . delim)

		return RTrim(new, delim)
	}

	/**
	 * @description Delete a line of text at the specified line number.
	 * The line you specify is deleted and all lines below it are shifted up.
	 * A "line" can be determined by the delimiter parameter. Not necessarily
	 * just a `r or `n. But perhaps you want a | as your "line".
	 * input: "aaa|bbb|777|ccc".DeleteLine(3, "|")
	 * output: "aaa|bbb|ccc"
	 * @param string Text you want to delete the line from.
	 * @param line What line to delete. You may use -1 for the last line and a negative an offset from the last. -2 would be the second to the last.
	 * @param delim The string which defines a "line".
	 * @param exclude The text you want to ignore when defining a line.
	 * @returns {String}
	 */
	static DeleteLine(line, delim:="`n", exclude:="`r") {
		new := ""
		; checks to see if we are trying to delete a non-existing line.
		count := this.Count(delim) + 1
		if (abs(line)>Count){
			throw ValueError("DeleteLine: the line number cannot be greater than the number of lines", -1)
		}
		if (line<0){
			line:=count+line+1
		}
		else if (line=0){
			throw ValueError("DeleteLine: line number cannot be 0", -1)
		}

		Loop parse, this, delim, exclude {
			if (a_index==line) {
				Continue
			} 
			else{
				(new .= A_LoopField . delim)
			}
		}

		return SubStr(new,1,-StrLen(delim))
	}

	/**
	 * @description Read the content of the specified line in a string. A "line" can be
	 * determined by the delimiter parameter. Not necessarily just a `r or `n.
	 * But perhaps you want a | as your "line".
	 * input: "aaa|bbb|ccc|ddd|eee|fff".ReadLine(4, "|")
	 * output: "ddd"
	 * @param line What line to read*. "L" = The last line. "R" = A random line. Otherwise specify a number to get that line. You may specify a negative number to get the line starting from the end. -1 is the same as "L", the last. -2 would be the second to the last, and so on.
	 * @param delim The string which defines a "line".
	 * @param exclude The text you want to ignore when defining a line.
	 * @returns {String}
	 */
	static ReadLine(line, delim:="`n", exclude:="`r") {

		out := ""
		count := this.Count(delim) + 1

		if (line="R"){
			line := Random(1, count)
		}
		else if (line="L"){
			line := count
		}
		else if abs(line)>Count{
			throw ValueError("ReadLine: the line number cannot be greater than the number of lines", -1)
		}
		else if (line<0){
			line:=count+line+1
		}
		else if (line=0){
			throw ValueError("ReadLine: line number cannot be 0", -1)
		}
		Loop parse, this, delim, exclude {
			if A_Index = line{
				return A_LoopField
			}
		}
		throw Error("ReadLine: something went wrong, the line was not found", -1)
	}


	/**
	 * @description Replace all consecutive occurrences of 'delim' with only one occurrence.
	 * input: "aaa|bbb|||ccc||ddd".RemoveDuplicates("|")
	 * output: "aaa|bbb|ccc|ddd"
	 * @param delim *String*
	 */
	static RemoveDuplicates(delim:="`n") => RegExReplace(this, "(\Q" delim "\E)+", "$1")


	/**
	 * @description Checks whether the string contains any of the needles provided.
	 * input: "aaa|bbb|ccc|ddd".Contains("eee", "aaa")
	 * output: 1 (although the string doesn't contain "eee", it DOES contain "aaa")
	 * @param needles
	 * @returns {Boolean}
	 */
	static Contains(needles*) {
		for needle in needles
			if InStr(this, needle)
				return 1
		return 0
	}

	/**
	 * @description Centers a block of text to the longest item in the string.
	 * example: "aaa`na`naaaaaaaa".Center()
	 * output: "aaa
	 *           a
	 *       aaaaaaaa"
	 * @param text The text you would like to center.
	 * @param fill A single character to use as the padding to center text.
	 * @param symFill 0: Just fill in the left half. 1: Fill in both sides.
	 * @param delim The string which defines a "line".
	 * @param exclude The text you want to ignore when defining a line.
	 * @param width Can be specified to add extra padding to the sides
	 * @returns {String}
	 */
	static Center(fill:=" ", symFill:=0, delim:="`n", exclude:="`r", width?) {
		fill:=SubStr(fill,1,1), longest := 0, new := ""
		Loop parse, this, delim, exclude
			if (StrLen(A_LoopField)>longest)
				longest := StrLen(A_LoopField)
		if IsSet(width)
			longest := Max(longest, width)
		Loop parse this, delim, exclude
		{
			filled:="", len := StrLen(A_LoopField)
			Loop (longest-len)//2
				filled.=fill
			new .= filled A_LoopField ((symFill=1) ? filled (2*StrLen(filled)+len = longest ? "" : fill) : "") "`n"
		}
		return RTrim(new,"`r`n")
	}

	/**
	 * @description Align a block of text to the right side.
	 * input: "aaa`na`naaaaaaaa".Right()
	 * output: "     aaa
	 *                 a
	 *          aaaaaaaa"
	 * @param fill A single character to use as to push the text to the right.
	 * @param delim The string which defines a "line".
	 * @param exclude The text you want to ignore when defining a line.
	 * @returns {String}
	 */
	static Right(fill:=" ", delim:="`n", exclude:="`r") {
		fill:=SubStr(fill,1,1), longest := 0, new := ""
		Loop parse, this, delim, exclude
			if (StrLen(A_LoopField)>longest)
				longest:=StrLen(A_LoopField)
		Loop parse, this, delim, exclude {
			filled:=""
			Loop Abs(longest-StrLen(A_LoopField))
				filled.=fill
			new.= filled A_LoopField "`n"
		}
		return RTrim(new,"`r`n")
	}

	/**
	 * @description Join a list of strings together to form a string separated by delimiter this was called with.
	 * input: "|".Concat("111", "222", "333", "abc")
	 * output: "111|222|333|abc"
	 * @param words A list of strings separated by a comma.
	 * @returns {String}
	 */
	static Concat(words*) {
		delim := this, s := ""
		for v in words{
			s .= v . delim
		}
		return SubStr(s,1,-StrLen(this))
	}

	/**
	 * @description Calculates the Damerau-Levenshtein distance between two strings.
	 * @param s The first string to compare.
	 * @param t The second string to compare.
	 * @returns {Integer} The number of operations required to transform one string into another.
	 */
	static DamerauLevenshteinDistance(s, t) {
		m := StrLen(s)
		n := StrLen(t)
		if (m = 0){
			return n
		}
		if (n = 0){
			return m
		}
		d := Array()
		d.Push([])
		d[1].Push(0)
		Loop m+1
			d[1].Push(A_Index)
		Loop n {
			d.Push([A_Index])
			Loop m+1{
				d[A_Index+1].Push(0)
			}
		}

		ix := 0
		iy := -1
		Loop Parse, s {
			sc := A_LoopField
			i := A_Index
			jx := 0
			jy := -1
			Loop Parse, t {
				j := A_Index
				a := d[ix+1][jx+1] + 1
				b := d[i+1][jx+1] + 1
				c := (A_LoopField != sc) + d[ix+1][jx+1]
				d[i+1][j+1] := Min(a, b, c)

				if (i > 1 and j > 1 and sc = tx and sx = A_LoopField){
					d[i+1][j+1] := Min(d[i+1][j+1], d[iy+1][ix+1] + c)
				}

				jx++
				jy++
				tx := A_LoopField
			}
			ix++
			iy++
			sx := A_LoopField
		}
		return d[m+1][n+1]
	}

	static LevenshteinDistance(s, t) {
		m := StrLen(s)
		n := StrLen(t)
		d := Array()
	
		Loop m+1{
			d.Push([A_Index-1])
		}
		Loop n{
			d[1].Push(A_Index)
		}
	
		Loop m {
			i := A_Index + 1
			Loop n {
				j := A_Index + 1
				cost := (SubStr(s, i-1, 1) != SubStr(t, j-1, 1))
				d[i][j] := Min(d[i-1][j] + 1, d[i][j-1] + 1, d[i-1][j-1] + cost)
			}
		}
		return d[m+1][n+1]
	}

	static LongestCommonSubsequence(s, t) {
		m := StrLen(s)
		n := StrLen(t)
		L := Array()
	
		Loop m+1 {
			L.Push([])
			Loop n+1{
				L[A_Index].Push(0)
			}
		}
	
		Loop m {
			i := A_Index
			Loop n {
				j := A_Index
				if (SubStr(s, i, 1) = SubStr(t, j, 1)){
					L[i+1][j+1] := L[i][j] + 1
				}
				else{
					L[i+1][j+1] := Max(L[i+1][j], L[i][j+1])
				}
			}
		}
	
		return L[m+1][n+1]
	}

	static JaroWinklerDistance(s, t) {
		jaroDist := this.JaroDistance(s, t)
		prefixLength := 0
		Loop 4 {
			if (SubStr(s, A_Index, 1) = SubStr(t, A_Index, 1))
				prefixLength++
			else
				break
		}
		return jaroDist + (prefixLength * 0.1 * (1 - jaroDist))
	}
	
	static JaroDistance(s, t) {
		sLen := StrLen(s)
		tLen := StrLen(t)
		
		if (sLen = 0 and tLen = 0)
			return 1
		
		matchDistance := Floor(Max(sLen, tLen) / 2) - 1
		sMatches := Array(), tMatches := Array()
		matches := 0, transpositions := 0
		
		Loop Parse, s {
			start := Max(1, A_Index - matchDistance)
			end := Min(A_Index + matchDistance, tLen)
			Loop end - start + 1 {
				j := start + A_Index - 1
				if (!tMatches[j] and A_LoopField = SubStr(t, j, 1)) {
					sMatches[A_Index] := true
					tMatches[j] := true
					matches++
					break
				}
			}
		}
		
		if (matches = 0)
			return 0
		
		k := 1
		Loop Parse, s {
			if (sMatches[A_Index]) {
				while (!tMatches[k])
					k++
				if (A_LoopField != SubStr(t, k, 1))
					transpositions++
				k++
			}
		}
		
		return (matches / sLen + matches / tLen + (matches - transpositions / 2) / matches) / 3
	}

	static HammingDistance(s, t) {
		if (StrLen(s) != StrLen(t))
			throw Error("Strings must be of equal length")
		
		distance := 0
		Loop Parse, s
			if (A_LoopField != SubStr(t, A_Index, 1))
				distance++
		return distance
	}

	; Improved FindBestMatch method
	static FindBestMatch(input, possibilities) {
		bestMatch := ""
		highestScore := 0

		for _, possibility in possibilities {
			score := this.CalculateSimilarityScore(input, possibility)
			if (score > highestScore) {
				highestScore := score
				bestMatch := possibility
			}
		}

		return bestMatch
	}

	; Calculate similarity score between two strings
	static CalculateSimilarityScore(str1, str2) {
		; Combine multiple similarity metrics for a more robust match
		levenshteinScore := 1 - (this.LevenshteinDistance(str1, str2) / Max(StrLen(str1), StrLen(str2)))
		jaroWinklerScore := this.JaroWinklerSimilarity(str1, str2)
		prefixScore := this.PrefixSimilarity(str1, str2)

		; Weighted average of scores
		return (levenshteinScore * 0.4) + (jaroWinklerScore * 0.4) + (prefixScore * 0.2)
	}

	; Jaro-Winkler similarity
	static JaroWinklerSimilarity(s, t) => this.JaroWinklerDistance(s, t)

	; Prefix similarity
	static PrefixSimilarity(s, t) {
		commonPrefixLength := 0
		minLength := Min(StrLen(s), StrLen(t))

		while (commonPrefixLength < minLength && SubStr(s, commonPrefixLength + 1, 1) == SubStr(t, commonPrefixLength + 1, 1)) {
			commonPrefixLength++
		}

		return commonPrefixLength / Max(StrLen(s), StrLen(t))
	}

}

DamerauLevenshteinDistance(s, t) {
	m := StrLen(s)
	n := StrLen(t)
	if (m = 0)
		return n
	if (n = 0)
		return m

	d := Array()
	d.Push([])
	d[1].Push(0)
	Loop m+1
		d[1].Push(A_Index)
	Loop n
	{
		d.Push([A_Index])
		Loop m+1
			d[A_Index+1].Push(0)
	}

	ix := 0
	iy := -1
	Loop Parse, s
	{
		sc := A_LoopField
		i := A_Index
		jx := 0
		jy := -1
		Loop Parse, t
		{
			j := A_Index
			a := d[ix+1][jx+1] + 1
			b := d[i+1][jx+1] + 1
			c := (A_LoopField != sc) + d[ix+1][jx+1]
			d[i+1][j+1] := Min(a, b, c)

			if (i > 1 and j > 1 and sc = tx and sx = A_LoopField)
				d[i+1][j+1] := Min(d[i+1][j+1], d[iy+1][ix+1] + c)

			jx++
			jy++
			tx := A_LoopField
		}
		ix++
		iy++
		sx := A_LoopField
	}
	return d[m+1][n+1]
}

String2.Prototype.Base := Text2

Class Text2 {
	static CompressSpaces() => RegexReplace(this, " {2,}", " ")

	static WriteFile(whichFile, flags := 'rw', encoding := 'UTF-8-RAW') {
		; fileObj := FileOpen(whichFile, "w", "UTF-8-RAW")
		; fileObj := FileOpen(whichFile, 'rw', 'UTF-8')
		; fileObj := FileOpen(this, 'rw')
		fileObj := FileOpen(whichFile, flags, encoding) || fileObj := FileOpen(this, flags, encoding)
		fileObj.Write(this)
	}

	static AppendFile(whichFile, encoding := 'UTF-8-RAW') => FileAppend(this, whichFile, encoding)

	static ToggleInfo() {
		g_ToggleInfo := Gui("AlwaysOnTop -Caption +ToolWindow").DarkMode().MakeFontNicer()
		g_ToggleInfo.AddText(, this)
		g_ToggleInfo.Show("W225 NA x1595 y640")
		SetTimer(() => g_ToggleInfo.Destroy(), -1000)
		return this
	}

	static FileWrite(content, filePath) {
		FileAppend(content, filePath, "UTF-8")
	}


	/**
	 * 
	 * @param {String} whichFile New file name or path to existing file
	 * @param {String} ext extension of the new file: Default: .txt
	 * @returns {String} newfile returns the new file name and associated extension
	 */
	static WriteTxtToFile(whichFile := A_ScriptDir '\' whichFile, ext := '.txt') {
		if FileExist(whichFile) {
			FileDelete(whichFile)
			this.AppendFile(this)
		}
		else {
			newfile := whichFile ext
			this.AppendFile(newfile)
			return newfile
		}
	}
}


File.Prototype.Base := File2
; File.Prototype.Append := (content) => FileWrite(content, this, "UTF-8")

Class File2 {

	static Run() => Run(this)

	; static ReadFile() => FileRead(this, 'UTF-8')
	static SwitchFiles(path2) {

		file1Read := FileOpen(this, "r", "UTF-8-RAW")
		file1Read.Seek(0, 0)
	
		file2Read := FileOpen(path2, "r", "UTF-8-RAW")
		file2Read.Seek(0, 0)
	
		text1 := file1Read.Read()
		text2 := file2Read.Read()
	
		file1Write := FileOpen(this, "w", "UTF-8-RAW")
	
		file2Write := FileOpen(path2, "w", "UTF-8-RAW")
	
		file1Write.Write(text2)
		file2Write.Write(text1)
	
		file1Read.Close()
		file2Read.Close()
	
		file1Write.Close()
		file2Write.Close()
	}

	/**
	 * @param {String} flags default flags of 'r'
	 * @param {String} encoding default encoding := 'UTF-8-RAW' 
	 * @returns {File} Same as FileOpen() but with default flags, and default encoding
	 */
	static Open() => FileOpen(this, "r", encoding := 'UTF-8-RAW')

		/**
	 * @param {String} flags default flags of 'r a' (read & append if the file doesn't exist)
	 * @param {String} encoding default encoding := 'UTF-8-RAW' 
	 * @returns {File} Same as FileOpen() but with default flags, and default encoding
	 */
	static Open2() => FileOpen(this, "r a", encoding := 'UTF-8-RAW')

	static Read2() => this.FileRead()

	static FileRead(text := '', encoding := 'UTF-8-RAW') {
		; !(file2Read := FileOpen(this, "r", encoding)) ? file2Read := FileOpen(this, "r a", encoding) : file2Read := FileOpen(this, "r", encoding)
		!(file2Read := this.Open()) ? file2Read := this.Open2() : file2Read := this.Open()
		text := file2Read.Read()
		file2Read.Seek(0, 0)
		file2Read.Close()
		return text
	}

	static WriteToFile(text := '', encoding := 'UTF-8-RAW') {

		; if !(fileRead := FileOpen(this, "r", encoding)) {
		; 	fileRead := FileOpen(this, "r a", encoding)
		; }
		; else {
		; 	fileRead := FileOpen(this, "r", encoding)
		; }
		!(file2Read := FileOpen(this, "r", encoding)) ? file2Read := FileOpen(this, "r a", encoding) : file2Read := FileOpen(this, "r", encoding)
		file2Read.Seek(0, 0)
	
		; file2Read := FileOpen(path2, "r", "UTF-8-RAW")
		; file2Read.Seek(0, 0)
	
		text := file2Read.Read()
		; text2 := file2Read.Read()
	
		file2Write := FileOpen(this, "w", encoding)
	
		; file2Write := FileOpen(path2, "w", "UTF-8-RAW")
	
		file2Write.Write(text)
		; file2Write.Write(text1)
	
		; file2Read.Close()
		; file2Read.Close()
	
		file2Write.Close()
		; file2Write.Close()
	}
	; Adding static method to built-in File class
	static Ext(filename){
		SplitPath(filename,, &dir, &ext)
		return ext
	}
}

; Standalone function
FileExt(filename) {
	SplitPath(filename,, &dir, &ext)
	return ext
}

class Unicode {

	static Symbols := Map(

		" ",                        0x0020,
		"zwj",                      0x200D,
		"varsel16",                 0xFE0F,
		"female sign",              0x2640,  ; ♀
		"pleading",                 0x1F97A, ; 🥺
		"yum",                      0x1F60B, ; 😋
		"exploding head",           0x1F92F, ; 🤯
		"smirk cat",                0x1F63C, ; 😼
		"sunglasses",               0x1F60E, ; 😎
		"sob",                      0x1F62D, ; 😭
		"face with monocle",        0x1F9D0, ; 🧐
		"flushed",                  0x1F633, ; 😳
		"face with raised eyebrow", 0x1F928, ; 🤨
		"purple heart",             0x1F49C, ; 💜
		"skull",                    0x1F480, ; 💀
		"rolling eyes",             0x1F644, ; 🙄
		"thinking",                 0x1F914, ; 🤔
		"weary",                    0x1F629, ; 😩
		"woozy",                    0x1F974, ; 🥴
		"finger left",              0x1F448, ; 👈
		"finger right",             0x1F449, ; 👉
		"drooling",                 0x1F924, ; 🤤
		"eggplant",                 0x1F346, ; 🍆
		"smiling imp",              0x1F608, ; 😈
		"fearful",                  0x1F628, ; 😨
		"middle dot",               0x00B7,  ; ·
		"long dash",                0x2014,  ; —
		"sun",                      0x2600,  ; ☀
		"cloud",                    0x2601,  ; ☁
		"nerd",                     0x1F913, ; 🤓
		"handshake",                0x1F91D, ; 🤝
		"shrug",                    0x1F937, ; 🤷
		"clap",                     0x1F44F, ; 👏
		"amogus",                   0x0D9E,  ; ඞ
		"confetti",                 0x1F389, ; 🎉
		"eyes",                     0x1F440, ; 👀
		"sneezing face",            0x1F927, ; 🤧
		"grimacing",                0x1F62C, ; 😬
		"crossed out",              0x1F635, ; 😵
		"dizzy",                    0x1F4AB, ; 💫
		"face with hearts",         0x1F970, ; 🥰
		"innocent",                 0x1F607, ; 😇
		"scarf",                    0x1F9E3, ; 🧣
		"sparkles",                 0x2728,  ; ✨
		"relieved",                 0x1F60C, ; 😌
		"knot",                     0x1FAA2, ;
		"comet",                    0x2604,  ; ☄️varsel16
		"panda",                    0x1F43C, ; 🐼
		"bamboo",                   0x1F38D, ; 🎍
		"muscle",                   0x1F4AA, ; 💪
		"scale",                    0x2696,  ; ⚖varsel16
		"alien",                    0x1F47D, ; 👽
		"badminton",                0x1F3F8, ; 🏸
		"clipboard",                0x1F4CB, ; 📋
		"lobster",                  0x1F99E, ; 🦞
		"rosette",                  0x1F3F5, ; 🏵varsel16
		"gem",                      0x1F48E, ; 💎
		"firecracker",              0x1F9E8, ; 🧨
		"athletic shoe",            0x1F45F, ; 👟
		"fish",                     0x1F41F, ; 🐟
		"satellite",                0x1F6F0, ; 🛰varsel16
		"statue of liberty",        0x1F5FD, ; 🗽
		"tropical fish",            0x1F420, ; 🐠
		"penguin",                  0x1F427, ; 🐧
		"kiwi",                     0x1F95D, ; 🥝
		"archery",                  0x1F3F9, ; 🏹
		"shell",                    0x1F41A, ; 🐚
		"shrimp",                   0x1F990, ; 🦐
		"broom",                    0x1F9F9, ; 🧹
		"ocean",                    0x1F30A, ; 🌊
		"wolf",                     0x1F43A, ; 🐺
		"paperclip",                0x1F4CE, ; 📎
		"nail polish",              0x1F485, ; 💅
		"shell top arc",            0x256D,  ; ╭
		"shell horizontal",         0x2500,  ; ─
		"shell bottom arc",         0x2570,  ; ╰
		"shell middle line",        0x2502,  ; │
		"cat",                      0x1F408, ; 🐈
		"chicken",                  0x1F414, ; 🐔
		"parrot",                   0x1F99C, ; 🦜
		"cricket",                  0x1F997, ; 🦗
		"glowing star",             0x1F31F, ; 🌟
		"ship",                     0x1F6A2, ; 🚢

	)

	/**
	* Sends a unicode character using the Send function by using the character's predefined name
	* @param name *String* The predefined name of the character
	* @param endingChar *String* The string to append to the character. For example, a space or a newline
	*/
	static Send(symbols*) {
		output := ''
		for index, symbol in symbols{
			output .= Chr(this.Symbols[symbol])
		}
		if symbols.Length > 1{
			Clip.Send(output)
		}
		else{
			SendText(output)
		}
	}

	static DynamicSend() {
		output := ''
		if !input := CleanInputBox().WaitForInput(){
			return
		}
		symbols := StrSplit(input, ",")
		for index, symbol in symbols {
			output .= Chr(this.Symbols.Choose(symbol))
		}
		Clip.Send(output)
	}

}
; #Include <Directives\__AE.v2>
; #Requires AutoHotkey v2+
; OnError(LogError)
; i := Integer("cause_error")

; LogError(exception, mode) {
; 	FileAppend("Error on line " exception.Line ": " exception.Message "`n", "errorlog.txt")
; 	return true
; }

; --------------------------------------------------------------------------------
CompressSpaces(text) => RegexReplace(text, " {2,}", " ")


/**
* Syntax sugar. Write text to a file
* @param whichFile *String* The path to the file
* @param text *String* The text to write
*/
WriteFile(whichFile, text := "") {
	fileObj := FileOpen(whichFile, "w", "UTF-8-RAW")
	; fileObj := FileOpen(whichFile, 'rw', 'UTF-8')
	; fileObj := FileOpen(whichFile, 'rw')
	fileObj.Write(text)
}

/**
* Syntax sugar. Append text to a file, or write it if the file
* doesn't exist yet
* @param whichFile *String* The path to the file
* @param text *String* The text to write
*/
AppendFile(whichFile, text) => FileAppend(text, whichFile, "UTF-8-RAW")



/**
* Syntax sugar. Reads a file and returns the text in it
* @param whichFile *String* The path to the file to read
* @returns {String}
*/
; ReadFile(whichFile) => FileRead(whichFile, 'UTF-8-RAW')
ReadFile(whichFile) => FileRead(whichFile, 'UTF-8')

/**
* Switch the contents of two files.
* The contents of file a will now be in file b, and the contents of file b will now be in file a.
* "Why not just use ReadFile and then WriteFile?" — Closing the file objects happens slower than ahk thinks.
* Because of this, there's a chance to have a failed write to one of the files, losing the data you were trying to write to it.
* Meaning, you end up with one file's contents just lost, effectively moving one file onto another.
* And there's no worse thing than code that works only *sometimes*.
* @param path1 ***String***
* @param path2 ***String***
*/
SwitchFiles(path1, path2) {

	file1Read := FileOpen(path1, "r", "UTF-8-RAW")
	file1Read.Seek(0, 0)

	file2Read := FileOpen(path2, "r", "UTF-8-RAW")
	file2Read.Seek(0, 0)

	text1 := file1Read.Read()
	text2 := file2Read.Read()

	file1Write := FileOpen(path1, "w", "UTF-8-RAW")

	file2Write := FileOpen(path2, "w", "UTF-8-RAW")

	file1Write.Write(text2)
	file2Write.Write(text1)

	file1Read.Close()
	file2Read.Close()

	file1Write.Close()
	file2Write.Close()
}

/**
 * @description Test suite for String2 conversion methods
 * @version 1.0.4
 */
class StringConversionTests extends TestSuite {
	static TestToMap() {
		; Basic test with string literal
		testStr1 := "key1=value1`nkey2=value2"
		map1 := String2.ToMap(testStr1)  ; Test static method
		this.AssertEqual("value1", map1["key1"], "Basic key=value parsing failed")
		
		; Test with spaces and empty lines
		testStr2 := "key1 = value1`n`nkey2  =   value2  "
		map2 := testStr2.ToMap()  ; Test instance method
		value1 := map2.Get("key1", "")  ; Use Get with default value
		value2 := map2.Get("key2", "")
		this.AssertEqual("value1", value1, "Whitespace handling failed")
		this.AssertEqual("value2", value2, "Whitespace handling failed")
		
		; Test empty string
		testStr3 := ""
		map3 := String2.ToMap(testStr3)
		this.AssertEqual(0, map3.Count, "Empty string should create empty map")
		
		return true
	}

	static TestToArray() {
		; Basic test
		testStr1 := "line1`nline2`nline3"
		arr1 := String2.ToArray(testStr1)
		this.AssertEqual(3, arr1.Length, "Basic line splitting failed")
		this.AssertEqual("line2", arr1[2], "Array element mismatch")
		
		; Test empty string
		testStr2 := ""
		arr2 := String2.ToArray(testStr2)
		this.AssertEqual(0, arr2.Length, "Empty string should create empty array")
		
		; Test with mixed line endings
		testStr3 := "line1`r`nline2`rline3`nline4"
		arr3 := testStr3.ToArray()  ; Test instance method
		; Debug output
		OutputDebug("Array length: " arr3.Length "`n")
		for i, v in arr3
			OutputDebug("Index " i ": '" v "'`n")
		this.AssertEqual(4, arr3.Length, "Mixed line ending handling failed")
		this.AssertEqual("line3", arr3[3], "Line content mismatch")
		
		return true
	}

	static TestToObject() {
		; Basic test
		testStr1 := "prop1=value1`nprop2=value2"
		obj1 := String2.ToObject(testStr1)
		this.AssertEqual("value1", obj1.prop1, "Basic property conversion failed")
		
		; Test invalid property names
		testStr2 := "valid=ok`n123=invalid`nvalid2=ok2"
		obj2 := String2.ToObject(testStr2)
		this.AssertEqual("ok", obj2.valid, "Valid property handling failed")
		this.AssertTrue(!obj2.HasOwnProp("123"), "Invalid property name should be skipped")
		
		; Test empty string
		testStr3 := ""
		obj3 := String2.ToObject(testStr3)
		this.AssertEqual(0, ObjOwnPropCount(obj3), "Empty string should create empty object")
		
		return true
	}

	static TestErrorHandling() {
		; Test ToMap with invalid input
		try {
			badInput := [1, 2, 3]  ; Initialize the variable
			map := String2.ToMap(badInput)
			return false  ; Should not reach here
		} catch TypeError as err {
			this.AssertTrue(InStr(err.Message, "Input must be a string"), "Wrong error message for ToMap")
		}
		
		; Test ToArray with invalid input
		try {
			badInput := Map()  ; Initialize the variable
			arr := String2.ToArray(badInput)
			return false  ; Should not reach here
		} catch TypeError as err {
			this.AssertTrue(InStr(err.Message, "Input must be a string"), "Wrong error message for ToArray")
		}
		
		; Test ToObject with invalid input
		try {
			badInput := 42  ; Initialize the variable
			obj := String2.ToObject(badInput)
			return false  ; Should not reach here
		} catch TypeError as err {
			this.AssertTrue(InStr(err.Message, "Input must be a string"), "Wrong error message for ToObject")
		}
		
		return true
	}

	static RunAllTests() {
		results := Map()
		
		; Run all test methods
		testMethods := ["TestToMap", "TestToArray", "TestToObject", "TestErrorHandling"]
		for testName in testMethods {
			try {
				if (this.%testName%()) {
					results[testName] := "✓ Pass"
				} else {
					results[testName] := "✗ Fail"
				}
			} catch as err {
				results[testName] := "✗ Error: " err.Message
			}
		}
		
		; Format output
		output := "String Conversion Test Results:`n`n"
		for testName, result in results {
			output .= Format("{}: {}`n", testName, result)
		}
		
		; Display results
		Infos(output)
		Clip.Send(output)
		; Return results for programmatic use
		return results
	}
}

; Run the tests
; StringConversionTests.RunAllTests()

; str := "line1`nline2`nline3"
; str := "key1=value1`nkey2=value2"

; Obj := str.ToMap(str)

; Infos(Obj.ToString())





