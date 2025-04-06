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

; 	/**
; 	 * @description Sets clipboard content as RTF format with enhanced error handling
; 	 * @param {String} rtfText The RTF formatted text
; 	 * @throws {Error} If clipboard operations fail
; 	 */
; 	static SetClipboardRTF(rtfText) {
; 		; Register RTF format if needed
; 		static CF_RTF := DllCall("RegisterClipboardFormat", "Str", "Rich Text Format", "UInt")
		
; 		if (!CF_RTF)
; 			throw Error("Failed to register RTF clipboard format", -1)
		
; 		; Open and clear clipboard with timeout handling
; 		startTime := A_TickCount
; 		while (!DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)) {
; 			if (A_TickCount - startTime > 1000)
; 				throw Error("Failed to open clipboard", -1)
; 			Sleep(10)
; 		}
		
; 		DllCall("EmptyClipboard")
		
; 		; Allocate and copy RTF data
; 		hGlobal := DllCall("GlobalAlloc", "UInt", 0x42, "Ptr", StrPut(rtfText, "UTF-8"))
; 		if (!hGlobal)
; 			throw Error("Failed to allocate memory for clipboard", -1)
			
; 		try {
; 			pGlobal := DllCall("GlobalLock", "Ptr", hGlobal, "Ptr")
; 			if (!pGlobal)
; 				throw Error("Failed to lock global memory", -1)
				
; 			StrPut(rtfText, pGlobal, "UTF-8")
; 			DllCall("GlobalUnlock", "Ptr", hGlobal)
			
; 			; Set clipboard data
; 			if (!DllCall("SetClipboardData", "UInt", CF_RTF, "Ptr", hGlobal))
; 				throw Error("Failed to set clipboard data", -1)
; 		} catch Error as err {
; 			; Cleanup on error
; 			DllCall("GlobalFree", "Ptr", hGlobal)
; 			DllCall("CloseClipboard")
; 			throw err
; 		}
		
; 		DllCall("CloseClipboard")
; 		Sleep(50)  ; Small delay to ensure clipboard operations complete
; 	}

; }

class rtfHandler extends docProperties {

	static SetClipboardRTF(rtfText) {
		static CF_RTF := DllCall('RegisterClipboardFormat', 'Str', 'Rich Text Format', 'UInt')
		
		if (!CF_RTF) {
			throw Error('Failed to register RTF format', -1) 
		}

		startTime := A_TickCount
		; while (!DllCall('OpenClipboard', 'Ptr', A_ScriptHwnd)) {
		while (!DllCall('OpenClipboard', 'Ptr', 0)) {
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

	__New(text := '') {
		hCtl := ''
		plainText.SetPlainText(text)
		try hCtl := ControlGetFocus("A")
		; return this.wmPaste(hCtl)
		return plainText.emPasteSpec(hCtl)
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
		confidenceThreshold := 2  ; Minimum number of matches needed
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

	/**
     * @description Automatically converts input to string representation
     * @param {Any} input The value to convert
     */
	__New(input?) {
		if !IsSet(input){
			input := ""
		}
		; Use existing ToString logic for conversion
		this.value := String2.ToString(input)
		return this.value
	}
	; static Send(input?){
	; 	; (Type(this) == 'String' && IsSet(this) && this != '')
	; 	Type(this) == 'String'? Clip.Send(this)	: Clip.Send(input)
	; }

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

	static HTMLToRTF(t := this) => FormatConverter.HTMLToRTF(this)
	static RTFtoRTF(t := this) => FormatConverter.RTFtoRTF(this)

	/**
     * @description Converts any input to string representation
     * @param {Any} input The value to convert to string
     * @returns {String} String representation of input
     */
	static ToString(input?) {
		if !IsSet(input)
			input := this

		; Check input type and call appropriate conversion
		switch Type(input) {
			case "Object", "Map", "Array":
				return this._ObjectToString(input)
			case "String":
				return input
			case "Integer", "Float":
				return String(input) 
			case "Undefined":
				return ""
			default:
				try {
					if input.HasOwnProp("ToString")
						return input.ToString()
					return String(input)
				}
				return String(input)
		}
	}
	
	/**
	 * @description Internal method to convert objects to string
	 * @param {Object} obj The object to convert
	 * @returns {String} String representation
	 */
	static _ObjectToString(obj) {
		switch Type(obj) {
			case "Array":
				return "[" obj.Join(", ") "]"
			case "Map":
				pairs := []
				for k, v in obj
					pairs.Push(k ": " this.ToString(v))
				return "{" pairs.Join(", ") "}"
			case "Object":
				pairs := []
				for k, v in obj.OwnProps()
					pairs.Push(k ": " this.ToString(v))
				return "{" pairs.Join(", ") "}"
			default:
				return String(obj)
		}
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

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include <Includes/Basic>
; ; Shift+Ctrl+f
; +^f::convertbrand()


class TextReplacer {
    mapFM := Map(
        'FM', ['FM\s?Global', 'FMG\s?', 'fmglobal'],
        'FM ', ['FMG\s'],
        'FM Affiliated', ['AFM', 'Affiliated\s?FM'],
        'FM Boiler RE', ['Mutual\s?Boiler\s?Re'],
        'sites', [
            {osite:'fmglobal\.com/liquid', nsite: 'fm.com/liquid'}, 
            {osite: 'fmglobaldatasheets\.com', nsite: 'fm.com/resources/fm-data-sheets'},
            {osite:'fmglobalcatalog\.com', nsite: 'fmcatalog.com'}, 
            {osite:'fmglobal\.com/training-center', nsite: 'fm.com/training-center'}, 
        ]
    )

    Needle := '(?:([\`'\`"]\w+[\`'\`"][,\s])|(\d+,)|([\`'\`"]{2}))'
    kNeedle := '([\`'\`"]\w+[\`'\`"][,\s])'
    vNeedle := '(\d+,)'
    bNeedle := '([\`'\`"]{2})'

    __New() {
        this.CreateGUI()
    }

    ProcessRTFFile(rtfFilePath) {
        try {
            nfile := FileOpen(rtfFilePath, "r")
            fContent := nfile.Read()
            nfile.Close()

            processedContent := this.ProcessRTFContent(fContent)

            nfile := FileOpen(rtfFilePath, "w")
            nfile.Write(processedContent)
            nfile.Close()

            return processedContent
        } catch as err {
            MsgBox("Error processing RTF file: " . err.Message)
            return ""
        }
    }

    ProcessRTFContent(rtfContent) {
        lines := StrSplit(rtfContent, "`n")
        processedLines := []

        for line in lines {
            processedLine := this.ProcessLine(line)
            processedLines.Push(processedLine)
        }

        return processedLines.Join("`n")
    }

    ProcessLine(line) {
        if (line ~= this.Needle) {
            for key, values in this.mapFM {
                if (IsObject(values)) {
                    if (key == "sites") {
                        for site in values {
                            line := RegExReplace(line, site.osite, site.nsite)
                        }
                    } else {
                        for pattern in values {
                            line := RegExReplace(line, pattern, key)
                        }
                    }
                } else {
                    line := RegExReplace(line, values, key)
                }
            }
        }
        return line
    }

    ProcessText(originalText) {
        try {
            this.UpdateGUI("Original Text", originalText)

            textFormat := this.GetTextFormat(originalText)
            this.UpdateGUI("Text Format", textFormat)

            modifiedText := this.ReplaceText(originalText)
            this.UpdateGUI("Modified Text", modifiedText)

            return modifiedText
        } catch as err {
            this.ShowMessage("Error: " . err.Message)
            return ""
        }
    }

    ExtractPlainTextFromRTF(rtfText) {
        plainText := rtfText
        plainText := RegExReplace(plainText, "^\{\\rtf1.*?\\par", "")  ; Remove RTF header
        plainText := RegExReplace(plainText, "\\[a-z]+", "")  ; Remove RTF commands
        plainText := RegExReplace(plainText, "\\'[0-9a-f]{2}", "")  ; Remove escaped characters
        plainText := StrReplace(plainText, "\par", "`n")  ; Replace paragraph breaks with newlines
        plainText := StrReplace(plainText, "}", "")  ; Remove closing brace
        return Trim(plainText)
    }

    GetTextFormat(text) {
        if (RegExMatch(text, "^\{\\rtf"))
            return "Rich Text Format"
        else
            return "Plain Text"
    }

    ReplaceText(text) {
        modifiedText := text
        for key, values in this.mapFM {
            if (IsObject(values)) {
                if (key == "sites") {
                    for site in values {
                        modifiedText := RegExReplace(modifiedText, site.osite, site.nsite)
                    }
                } else {
                    for pattern in values {
                        modifiedText := RegExReplace(modifiedText, pattern, key)
                    }
                }
            } else {
                modifiedText := RegExReplace(modifiedText, values, key)
            }
        }
        return modifiedText
    }

    UpdateRichTextWithReplacements(richText, originalPlainText, modifiedPlainText) {
        if (originalPlainText == modifiedPlainText)
            return richText

        ; Create a map of original to modified substrings
        replaceMap := Map()
        originalParts := StrSplit(originalPlainText, "`n")
        modifiedParts := StrSplit(modifiedPlainText, "`n")
        
        for index, originalPart in originalParts {
            if (originalPart != modifiedParts[index]) {
                replaceMap[originalPart] := modifiedParts[index]
            }
        }

        ; Replace in rich text
        for original, modified in replaceMap {
            richText := StrReplace(richText, original, modified)
        }

        return richText
    }

    CreateGUI() {
        this.gui := Gui("+Resize +MinSize400x300")
        this.gui.Title := "Text Replacer"
        this.gui.OnEvent("Close", (*) => this.gui.Hide())

        this.gui.Add("Text", "w400", "Original Text:")
        this.originalTextEdit := this.gui.Add("Edit", "r4 w400 ReadOnly")
        this.gui.Add("Text", "w400", "Text Format:")
        this.formatEdit := this.gui.Add("Edit", "r1 w400 ReadOnly")
        this.gui.Add("Text", "w400", "Modified Text:")
        this.modifiedTextEdit := this.gui.Add("Edit", "r4 w400 ReadOnly")
        this.gui.Add("Text", "w400", "Window Info:")
        this.windowInfoEdit := this.gui.Add("Edit", "r6 w400 ReadOnly")

        this.gui.Add("Button", "w100", "Close").OnEvent("Click", (*) => this.gui.Hide())
    }

    UpdateGUI(field, value) {
        switch field {
            case "Original Text":
                this.originalTextEdit.Value := value
            case "Text Format":
                this.formatEdit.Value := value
            case "Modified Text":
                this.modifiedTextEdit.Value := value
            case "Window Info":
                this.windowInfoEdit.Value := value
        }
        this.ShowGUI()
    }

    ShowGUI() {
        ; this.gui.Show()
    }

    ShowMessage(msg) {
        MsgBox(msg, "Text Replacer", 0x2000)  ; 0x2000 flag makes the MsgBox always on top
    }

    GetActiveWindowInfo() {
        ; Store the current active window
        originalActiveWindow := WinExist("A")

        ; Wait a bit to ensure the target window is active
        Sleep(50)

        ; Get info about the now-active window (which should be the target application)
        windowId := WinGetID("A")
        windowTitle := WinGetTitle(windowId)
        windowClass := WinGetClass(windowId)
        processName := WinGetProcessName(windowId)

        ; Get focused control information
        focusedControl := ControlGetFocus("A")
        controlClass := ControlGetClassNN(focusedControl)
        
        ; Get control styles and exstyles
        controlStyle := ControlGetStyle(focusedControl)
        controlExStyle := ControlGetExStyle(focusedControl)

        ; Translate styles to Win32 constants
        translatedStyle := this.TranslateStyles(controlStyle)
        translatedExStyle := this.TranslateExStyles(controlExStyle)

        ; Additional info for hznHorizon.exe
        additionalInfo := ""
        if (processName = "hznHorizon.exe") {
            additionalInfo := this.GetHorizonWindowInfo(windowId, focusedControl)
        }

        ; Activate the original window
        if (originalActiveWindow)
            WinActivate("ahk_id " originalActiveWindow)

        return {
            id: windowId, 
            title: windowTitle, 
            class: windowClass, 
            process: processName,
            focusedControl: focusedControl,
            controlClass: controlClass,
            controlStyle: Format("0x{:X}", controlStyle),
            controlExStyle: Format("0x{:X}", controlExStyle),
            translatedStyle: translatedStyle,
            translatedExStyle: translatedExStyle,
            additionalInfo: additionalInfo
        }
    }

    GetHorizonWindowInfo(hWnd, hControl) {
        static GA_ROOT := 2
        static GA_ROOTOWNER := 3
        static GA_PARENT := 1
        static GW_CHILD := 5

        hRoot := DllCall("GetAncestor", "Ptr", hWnd, "UInt", GA_ROOT, "Ptr")
        hRootOwner := DllCall("GetAncestor", "Ptr", hWnd, "UInt", GA_ROOTOWNER, "Ptr")
        hParent := DllCall("GetAncestor", "Ptr", hControl, "UInt", GA_PARENT, "Ptr")
        hChild := DllCall("GetWindow", "Ptr", hControl, "UInt", GW_CHILD, "Ptr")

        info := "Root Window: " . this.GetWindowDetails(hRoot) . "`n"
        info .= "Root Owner: " . this.GetWindowDetails(hRootOwner) . "`n"
        info .= "Parent Window: " . this.GetWindowDetails(hParent) . "`n"
        info .= "Child Window: " . (hChild ? this.GetWindowDetails(hChild) : "None")

        return info
    }

    GetWindowDetails(hWnd) {
        if (!hWnd)
            return "N/A"

        class := WinGetClass("ahk_id " . hWnd)
        title := WinGetTitle("ahk_id " . hWnd)
        return Format("0x{:X} ({:s}) - {:s}", hWnd, class, title)
    }

    TranslateStyles(style) {
        styles := []
        styleMap := Map(
            0x00000000, "WS_OVERLAPPED",
            0x00C00000, "WS_CAPTION",
            0x00080000, "WS_SYSMENU",
            0x00040000, "WS_THICKFRAME",
            0x00020000, "WS_MINIMIZEBOX",
            0x00010000, "WS_MAXIMIZEBOX",
            0x00000001, "WS_TABSTOP",
            0x00000002, "WS_GROUP",
            0x00000004, "WS_SIZEBOX",
            0x00000020, "WS_VSCROLL",
            0x00000010, "WS_HSCROLL",
            0x00800000, "WS_BORDER",
            0x00400000, "WS_DLGFRAME",
            0x00000100, "WS_VISIBLE",
            0x08000000, "WS_DISABLED",
            0x10000000, "WS_CHILD"
        )

        for flag, name in styleMap {
            if (style & flag)
                styles.Push(name)
        }

        return styles.Length ? styles.Join(", ") : "None"
    }

    TranslateExStyles(exStyle) {
        exStyles := []
        exStyleMap := Map(
            0x00000001, "WS_EX_DLGMODALFRAME",
            0x00000004, "WS_EX_NOPARENTNOTIFY",
            0x00000008, "WS_EX_TOPMOST",
            0x00000010, "WS_EX_ACCEPTFILES",
            0x00000020, "WS_EX_TRANSPARENT",
            0x00000040, "WS_EX_MDICHILD",
            0x00000080, "WS_EX_TOOLWINDOW",
            0x00000100, "WS_EX_WINDOWEDGE",
            0x00000200, "WS_EX_CLIENTEDGE",
            0x00000400, "WS_EX_CONTEXTHELP",
            0x00001000, "WS_EX_RIGHT",
            0x00002000, "WS_EX_RTLREADING",
            0x00004000, "WS_EX_LEFTSCROLLBAR",
            0x00010000, "WS_EX_CONTROLPARENT",
            0x00020000, "WS_EX_STATICEDGE",
            0x00040000, "WS_EX_APPWINDOW",
            0x00080000, "WS_EX_LAYERED",
            0x00100000, "WS_EX_NOINHERITLAYOUT",
            0x00200000, "WS_EX_NOREDIRECTIONBITMAP",
            0x00400000, "WS_EX_LAYOUTRTL",
            0x02000000, "WS_EX_COMPOSITED",
            0x08000000, "WS_EX_NOACTIVATE"
        )

        for flag, name in exStyleMap {
            if (exStyle & flag)
                exStyles.Push(name)
        }

        return exStyles.Length ? exStyles.Join(", ") : "None"
    }
}


; ProcessAndPasteText() {
;     replacer := TextReplacer()
;     AE.SM_BISL(&sm)
;     AE.cBakClr(&cBak)

;     ; Store the current active window
;     originalActiveWindow := WinExist("A")

;     ; Use key.SendVK for select all
;     key.SendVK(key.selectall)
;     Sleep(100)

;     ; Use key.SendVK for copy
;     key.SendVK(key.copy)
;     AE.cSleep(150)
    
;     originalText := A_Clipboard
;     AE.cSleep(150)
;     modifiedText := replacer.ProcessText(originalText)

;     if (modifiedText != "") {
;         windowInfo := replacer.GetActiveWindowInfo()
;         infoText := "Process: " . windowInfo.process . "`n"
;                   . "Class: " . windowInfo.class . "`n"
;                   . "Control: " . windowInfo.controlClass . "`n"
;                   . "Control Style: " . windowInfo.controlStyle . "`n"
;                   . "Translated Style: " . windowInfo.translatedStyle . "`n"
;                   . "Control ExStyle: " . windowInfo.controlExStyle . "`n"
;                   . "Translated ExStyle: " . windowInfo.translatedExStyle . "`n"
;                   . "Additional Info:`n" . windowInfo.additionalInfo
;         replacer.UpdateGUI("Window Info", infoText)
        
;         ; Activate the original window before pasting
;         if (originalActiveWindow) {
;             WinActivate("ahk_id " originalActiveWindow)
;             WinWaitActive("ahk_id " originalActiveWindow)
;             Sleep(100)  ; Give a moment for the window to become fully active
;         }

;         ; Set the clipboard to the modified text
;         A_Clipboard := modifiedText
;         AE.cSleep(150)

;         ; Use key.SendVK for paste
;         key.SendVK(key.paste)
;     }
;     sleep(500)
;     AE.cRestore(cBak)
;     AE.rSM_BISL(sm)
; }



; ProcessAndPasteText() {
;     AE.SM_BISL(&sm)
;     AE.cBakClr(&cBak)

;     ; Store the current active window
;     originalActiveWindow := WinExist("A")

;     ; Use key.SendVK for select all
;     key.SendVK(key.selectall)
;     Sleep(100)

;     ; Use key.SendVK for copy
;     key.SendVK(key.copy)
;     AE.cSleep(150)
    
;     ; Get the RTF content from the clipboard
;     rtfContent := AE.GetRichTextFromClipboard()

;     ; Extract the plain text from the RTF content
;     plainText := AE.ExtractPlainTextFromRTF(rtfContent)

;     ; Process the plain text
;     modifiedPlainText := replacer.ProcessText(plainText)

;     if (modifiedPlainText != plainText) {
;         ; Replace the text portion in the RTF content
;         modifiedRtfContent := AE.ReplaceTextInRTF(rtfContent, plainText, modifiedPlainText)

;         windowInfo := replacer.GetActiveWindowInfo()
;         infoText := "Process: " . windowInfo.process . "`n"
;                   . "Class: " . windowInfo.class . "`n"
;                   . "Control: " . windowInfo.controlClass . "`n"
;                   . "Control Style: " . windowInfo.controlStyle . "`n"
;                   . "Translated Style: " . windowInfo.translatedStyle . "`n"
;                   . "Control ExStyle: " . windowInfo.controlExStyle . "`n"
;                   . "Translated ExStyle: " . windowInfo.translatedExStyle . "`n"
;                   . "Additional Info:`n" . windowInfo.additionalInfo
;         replacer.UpdateGUI("Window Info", infoText)
        
;         ; Activate the original window before pasting
;         if (originalActiveWindow) {
;             WinActivate("ahk_id " originalActiveWindow)
;             WinWaitActive("ahk_id " originalActiveWindow)
;             Sleep(100)  ; Give a moment for the window to become fully active
;         }

;         ; Set the clipboard to the modified RTF content
;         AE.SetClipboardRichText(modifiedRtfContent)
;         AE.cSleep(150)

;         ; Use key.SendVK for paste
;         key.SendVK(key.paste)
;     }

;     Sleep(500)
;     AE.cRestore(cBak)
;     AE.rSM_BISL(sm)
; }

; ^+f::ProcessAndPasteText()


ProcessAndPasteText(){
    AE.SM_BISL(&sm)
    AE.cBakClr(&cBak)
    mapFM := Map(
        'FM', ['FM\s?Global', 'FMG\s?', 'fmglobal'],
        'FM ', ['FMG\s'],
        'FM Affiliated', ['AFM', 'Affiliated\s?FM'],
        'FM Boiler RE', ['Mutual\s?Boiler\s?Re'],
        'sites', [
            {osite:'fmglobal\.com/liquid', nsite: 'fm.com/liquid'}, 
            {osite: 'fmglobaldatasheets\.com', nsite: 'fm.com/resources/fm-data-sheets'},
            {osite:'fmglobalcatalog\.com', nsite: 'fmcatalog.com'}, 
            {osite:'fmglobal\.com/training-center', nsite: 'fm.com/training-center'}, 
        ]
    )

    Needle := '(?:([\`'\`"]\w+[\`'\`"][,\s])|(\d+,)|([\`'\`"]{2}))'
    kNeedle := '([\`'\`"]\w+[\`'\`"][,\s])'
    vNeedle := '(\d+,)'
    bNeedle := '([\`'\`"]{2})'

    ; Use key.SendVK for select all
    ; key.SendVK(key.selectall)
    ; Sleep(100)

    ; Use key.SendVK for copy
    ; key.SendVK(key.copy)
    ; AE.cSleep(150)
    
    ; Get the RTF content from the clipboard
    rtfContent := A_Clipboard
    AE.cSleep(150)
    fname := 'temprtffile.rtf'
    FileDelete(fname)
    FileAppend(rtfContent, fname, '`n UTF-8')

    return
    fOpen := FileOpen(fname, 'rw', 'UTF-8')
    arrFile := [], fArrObj := []
    fLine := '', fString := ''

    ProcessLine(line) {
        ; if (line ~= Needle) {
            for key, values in mapFM {
                if (IsObject(values)) {
                    if (key == "sites") {
                        for site in values {
                            line := RegExReplace(line, site.osite, site.nsite)
                        }
                    } else {
                        for pattern in values {
                            line := RegExReplace(line, pattern, key)
                        }
                    }
                } else {
                    line := RegExReplace(line, values, key)
                }
            }
        ; }
        return line
    }
    ; Read file contents
    loop read fName {
        fArrObj.Push(A_LoopReadLine)
        fLine .= A_LoopReadLine '`n'
    }

    ; Process each line
    for aLine in fArrObj {
        newLine := ProcessLine(aLine)
        fString .= newLine '`n'
    }

    ; Write updated content back to file
    fOpen.Write(fString)
    fOpen := ''
    ; return 0
    sleep(100)

    oFile := FileOpen(fname, 'r', 'UTF-8')
    rFile := oFile.Read()

    A_Clipboard := rFile
    AE.cSleep(150)
    ; MsgBox(rFile)

    ; return
    ; Use key.SendVK for paste
    key.SendVK(key.paste)

    Sleep(500)
    AE.cRestore(cBak)
    AE.rSM_BISL(sm)
}

class SpecialCharactersGui {
	CharacterGroups := Map(
		"Accented", "ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÑÒÓÔŒÕÖØÙÚÛÜßàáâãäåæçèéêëìíîïñòóôœõöøùúûüÿ",
		"Symbols", "¿¡«»§¶†‡•-–—™©®",
		"Currency", "¢€¥£₤¤",
		"Greek", "αβγδεζηθικλμνξοπρσςτυφχψωΓΔΘΛΞΠΣΦΨΩ",
		"Math", "∫∑∏√−±∞≈∝≡≠≤≥×·÷∂′″∇‰°∴",
		"Sets", "ø∈∉∩∪⊂⊃⊆⊇¬∧∨∃∀⇒⇔→↔↑ℵ",
		"Superscript", "⁰¹²³⁴⁵⁶⁷⁸⁹",
		"Subscript", "₀₁₂₃₄₅₆₇₈₉"
	)

	UnitArray := ["kW", "MW", "kVA", "MVA", "ft²", "ft³", "m²", "m³", "°C", "°F", "Ω", "µ", "¼", "½", "¾", "⅓", "⅔"]
	ScientificArray := ["×10⁻⁹", "×10⁻⁶", "×10⁻³", "×10³", "×10⁶", "×10⁹"]
	TooltipHwnds := Map()
	Settings := {System: {SizeOfTI: 24 + (A_PtrSize * 6)}}

	__New() {
		this.gui := Gui("+AlwaysOnTop -Caption +ToolWindow")
		this.gui.MakeFontNicer()
		this.gui.NeverFocusWindow()
		this.gui.DarkMode(0x2D2D30)
		this.buttonWidth := 40
		this.buttonHeight := 35
		this.columnsCount := 20
		this.currentY := 10
		this.padding := 5
		
		; Calculate total width for headers
		this.totalWidth := (this.buttonWidth * this.columnsCount) + (this.padding * (this.columnsCount - 1))
		
		; Add close button and escape functionality
		this.AddCloseButton()
		this.SetupHotkeys()
		
		this.CreateLayout()
	}

	AddCloseButton() {
		closeBtn := this.gui.AddText( 
			Format("x{1} y5 +Border cRed Center", this.totalWidth + 15), 
			"×")
		closeBtn.OnEvent("Click", (*) => this.gui.Destroy())
		this.GuiCtrlSetTip(closeBtn, "Close (Escape)")
	}

	SetupHotkeys() {
		; Add Escape and Ctrl+Escape hotkeys to close
		this.gui.OnEvent("Escape", (*) => this.gui.Destroy())
		HotIfWinActive("ahk_id " this.gui.Hwnd)
		Hotkey("^Escape", (*) => this.gui.Destroy())
		HotIf()
	}

	CreateGroupHeader(groupName) {
		; Header now uses calculated total width
		header := this.gui.AddText( 
			Format("x0 y{1} w{2} h25 Background404040 Center", 
				this.currentY, this.totalWidth), 
			groupName)
		this.currentY += 25 + this.padding
	}

	AddCharacterButtons(charArray) {
		for index, char in charArray {
			x := this.padding + (Mod(index - 1, this.columnsCount) * (this.buttonWidth + this.padding))
			y := this.currentY + (Floor((index - 1) / this.columnsCount) * (this.buttonHeight + this.padding))
			
			btn := this.gui.AddText( 
				Format("x{1} y{2} w{3} h{4} +Border +BackgroundTrans Center", 
				; Format("x{1} y{2} w{3} h{4} +Border cBlue Center", 
					x, y, this.buttonWidth, this.buttonHeight), 
				char)
			
			this.GuiCtrlSetTip(btn, "Click to send ' " char " ' or copy to clipboard")
			btn.OnEvent("Click", this.SendChar.Bind(this, char))
		}
		
		rowCount := Ceil(charArray.Length / this.columnsCount)
		this.currentY += (rowCount * (this.buttonHeight + this.padding))
	}

	CreateLayout() {
		; Add dark theme styling
		; this.gui.SetFont("s11 cWhite")
		this.gui.MakeFontNicer("12 c1eff00")
		
		this.CreateCharacterGroups()
		this.CreateUnitGroup()
		this.CreateScientificGroup()
		
		; Show GUI centered on screen
		this.gui.Show("AutoSize Center")
	}

	CreateCharacterGroups() {
		for groupName, chars in this.CharacterGroups {
			; Add group header with background
			this.CreateGroupHeader(groupName)

			; Convert string to array and add buttons
			charArray := StrSplit(chars)
			this.AddCharacterButtons(charArray)
			
			; Add spacing after group
			this.currentY += this.padding * 2
		}
	}

	CreateUnitGroup() {
		this.CreateGroupHeader("Common Units")
		this.AddCharacterButtons(this.UnitArray)
		this.currentY += this.padding * 2
	}

	CreateScientificGroup() {
		this.CreateGroupHeader("Scientific")
		this.AddCharacterButtons(this.ScientificArray)
		this.currentY += this.padding
	}

	GuiCtrlSetTip(GuiCtrl, TipText, UseAhkStyle := true) {
		static TTF_SUBCLASS := 0x0010
		static TTF_IDISHWND := 0x0001
		
		if !(GuiCtrl is Gui.Control)
			return false
			
		HGUI := GuiCtrl.Gui.Hwnd
		HCTL := GuiCtrl.Hwnd
		
		if !this.TooltipHwnds.Has(HGUI) {
			HTT := DllCall("CreateWindowEx", "UInt", 0, "Str", "tooltips_class32",
				"Ptr", 0, "UInt", 0x80000003, "Int", 0x80000000, "Int", 0x80000000,
				"Int", 0x80000000, "Int", 0x80000000, "Ptr", HGUI, "Ptr", 0,
				"Ptr", 0, "Ptr", 0, "UPtr")
				
			if (!HTT)
				return false
				
			if (UseAhkStyle)
				DllCall("Uxtheme.dll\SetWindowTheme", "Ptr", HTT, "Ptr", 0, "Ptr", 0)
				
			this.TooltipHwnds[HGUI] := HTT
		}
		
		TI := Buffer(this.Settings.System.SizeOfTI, 0)
		NumPut("UInt", this.Settings.System.SizeOfTI, TI)
		NumPut("UInt", TTF_SUBCLASS | TTF_IDISHWND, TI, 4)
		NumPut("UPtr", HGUI, TI, 8)
		NumPut("UPtr", HCTL, TI, 8 + A_PtrSize)
		NumPut("UPtr", StrPtr(TipText), TI, 24 + (A_PtrSize * 3))
		
		SendMessage(0x0432, 0, TI.Ptr, this.TooltipHwnds[HGUI])  ; TTM_ADDTOOL
		SendMessage(0x0418, 0, -1, this.TooltipHwnds[HGUI])      ; TTM_SETMAXTIPWIDTH
		
		return true
	}

	SendChar(char, *) {
		; Check if there's a focused window that can receive input
		if (WinActive("A") && ControlGetFocus("A")) {
			SendMode("Event")
			SetKeyDelay(-1, -1)
			Send(char)
		} else {
			; Copy to clipboard and show tooltip
			A_Clipboard := char
			InfoTip := Infos("Copied '" char "' to clipboard")
			SetTimer(() => InfoTip.Destroy(), -7000)
		}
	}
}

findtheglobal(){

	arrNeedle := []
	n1 := n := theMatchString := cBak := theText := ''
	n := 'imx)(?:^|\n|\r)'
	n1 := n '(g)\b'
	n2 := n '(global)([\w\s\n\r]+)?'
	n3 := n '(g\B)([\s\n\r])?'
	arrNeedle := [n1, n2, n3]

	Clip.SM()
	Clip.BakClr(&cBak)
	Send(key.SelectAll key.copy)

	Clip.Sleep()

	theText := A_Clipboard

	if A_Clipboard = '' {
		Clip.Sleep(10)
	}

	; for each, value in arrNeedle {
	; 	theText.RegExMatch(value, &objMatch:=[])
	; }

	; if objMatch.Len < 1 {
	; 	Infos('objMatch.Length = ' objMatch.Len)
	; }
	; else {
	; 	for each, value in objMatch {
	; 		theMatchString .= '"' value '"' '`n'
	; 	}
	; }

	; Infos(theMatchString)

	for each, value in arrNeedle {
		newtheText := theText.RegExReplace(value, '')
	}

	Clip.ClearClipboard()

	if A_Clipboard != '' {
		clip.Sleep(10)
	}

	Infos(newtheText)

	Sleep(750)
	theMatchString := objMatch := cBak := theText := ''
	objMatch := []
}

^+f::findtheglobal
; ^+f::ProcessAndPasteText()

class NumberConverter {
	/**
	 * @description Converts a decimal number to hexadecimal.
	 * @param {Integer|String} num The decimal number to convert.
	 * @param {Boolean} hexPrefix Whether to include the "0x" prefix in the result.
	 * @returns {String} The hexadecimal representation of the number.
	 */
	static DecToHex(num, hexPrefix := true) {
		if (Type(num) == "String") {
			if (!RegExMatch(num, "^-?\d+$"))  ; Check if the string is a valid integer
				throw ValueError("Invalid input: '" . num . "' is not a valid number")
			num := Integer(num)
		}
		return (hexPrefix ? "0x" : "") . Format("{:X}", num)
	}

	/**
	 * @description Converts a hexadecimal string to a decimal number.
	 * @param {String|Integer} num The hexadecimal string or integer to convert.
	 * @returns {Integer} The decimal representation of the number.
	 */
	static HexToDec(num) {
		if (Type(num) == "String") {
			; Remove "0x" prefix if it exists
			num := RegExReplace(num, "^0x", "")
			; Ensure the string is not empty and only contains valid hexadecimal characters
			if (num = "" || !RegExMatch(num, "^[0-9A-Fa-f]+$")) {
				throw ValueError("Invalid hexadecimal string: " . num)
			}
		} else if (Type(num) == "Float") {
			num := Floor(num)  ; Convert float to integer
		} else if (Type(num) != "Integer") {
		try {
			return Format("{:u}", Integer("0x" . num))
		} catch {
			throw ValueError("Invalid hexadecimal string: " . num)
		}
		}
		return Format("{:u}", Integer("0x" . num))
	}
}

/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/FillStr.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

/**
 * @class
 * In this documentation an instance of `FillStr` is referred to as `Filler`.
 * FillStr constructs strings of the requested length out of the provided filler string. Multiple
 * `Filler` objects can be active at any time. It would technically be possible to use a single
 * `Filler` object and swap out the substrings on the property `Filler.Str`, but this is not
 * recommended because FillStr caches some substrings for efficiency, so you may not get the expected
 * result after swapping out the `Str` property.
 *
 * Internally, FillStr works by deconstructing the input integer into its base 10 components. It
 * constructs then caches the strings for components that are divisible by 10, then adds on the
 * remainder. This offers a balance between efficiency, flexibility, and memory usage.
 *
 * Since this is expected to be most frequently used to pad strings with surrounding whitespace,
 * the `FillStr` object is instantiated with an instance of itself using a single space character
 * as the filler string. This is available on the property `FillStr.S`, and can also be utilized using
 * `FillStr[Qty]` to output a string of Qty space characters.
 */
class FillStr {
    static __New() {
        this.S := FillStr(' ')
    }
    static __Item[Qty] {
        Get => this.S[Qty]
        Set => this.S.Cache.Set(Qty, value)
    }

    /**
     * @description - Constructs the offset string according to the input parameters.
     * @param {Integer} Len - The length of the output string.
     * @param {Integer} TruncateAction - Controls how the filler string `Filler.Str` is truncated when
     * `Len` is not evenly divisible by `Filler.Len`. The options are:
     * - 0: Does not truncate the filler string, and allows the width of the output string to exceed
     * `Len`.
     * - 1: Does not truncate the filler string, and does not allow the width of the output string to
     * exceed `Len`, sometimes resulting in the width being less than `Len`.
     * - 2: Does not truncate the filler string, and does not allow the width of the output string to
     * exceed `Len`, and adds space characters to fill the remaining space. The space characters are
     * added to the left side of the output string.
     * - 3: Does not truncate the filler string, and does not allow the width of the output string to
     * exceed `Len`, and adds space characters to fill the remaining space. The space characters are
     * added to the right side of the output string.
     * - 4: Truncates the filler string, and the truncated portion is on the left side of the output
     * string.
     * - 5: Truncates the filler string, and the truncated portion is on the right side of the output
     * string.
     */
    static GetOffsetStr(Len, TruncateAction, self) {
        Out := self[Floor(Len / self.Len)]
        if R := Mod(Len, self.Len) {
            switch TruncateAction {
                case 0: Out .= self[1]
                case 2: Out := FillStr[R] Out
                case 3: Out .= FillStr[R]
                case 4: Out := SubStr(self[1], self.Len - R + 1) Out
                case 5: Out .= SubStr(self[1], 1, R)
            }
        }
        return Out
    }

    /**
     * @description - Creates a new FillStr object, referred to as `Filler` in this documentation.
     * Use the FillStr instance to generate strings of repeating characters. For general usage,
     * see {@link FillStr#__Item}.
     * @param {String} Str - The string to repeat.
     * @example
        Filler := FillStr('-')
        Filler[10] ; ----------
        Filler.LeftAlign('Hello, world!', 26)       ; Hello, world!-------------
        Filler.LeftAlign('Hello, world!', 26, 5)    ; -----Hello, world!--------
        Filler.CenterAlign('Hello, world!', 26)     ; -------Hello, world!------
        Filler.CenterAlign('Hello, world!', 26, 1)  ; -------Hello, world!------
        Filler.CenterAlign('Hello, world!', 26, 2)  ; ------Hello, world!-------
        Filler.CenterAlign('Hello, world!', 26, 3)  ; -------Hello, world!-------
        Filler.CenterAlign('Hello, world!', 26, 4)  ; ------Hello, world!------
        Filler.RightAlign('Hello, world!', 26)      ; -------------Hello, world!
        Filler.RightAlign('Hello, world!', 26, 5)   ; --------Hello, world!-----
     * @
     * @returns {FillStr} - A new FillStr object.
     */
    __New(Str) {
        this.Str := Str
        Loop 10
            Out .= Str
        this[10] := Out
        this.Len := StrLen(Str)
    }
    Cache := Map()
    __Item[Qty] {
        /**
         * @description - Returns the string of the specified number of repetitions. The `Qty`
         * parameter does not represent string length, it represents number of repetitions of
         * `Filler.Str`, which is the same as string length only when the length of `Filler.Str` == 1.
         * @param {Integer} Qty - The number of repetitions.
         * @returns {String} - The string of the specified number of repetitions.
         */
        Get {
            if !Qty
                return ''
            Out := ''
            if this.Cache.Has(Number(Qty))
                return this.Cache[Number(Qty)]
            r := Mod(Qty, 10)
            Loop r
                Out .= this.Str
            Qty -= r
            if Qty {
                Split := StrSplit(Qty)
                for n in Split {
                    if n = 0
                        continue
                    Tens := 1
                    Loop StrLen(Qty) - A_Index
                        Tens := Tens * 10
                    if this.Cache.Has(Tens) {
                        Loop n
                            Out .= this.Cache.Get(Tens)
                    } else {
                        Loop n
                            Out .= _Process(Tens)
                    }
                }
            }
            return Out

            _Process(Qty) {
                local Out
                ; if !RegExMatch(Qty, '^10+$')
                ;     throw Error('Logical error in _Process function call.', -1)
                Tenth := Integer(Qty / 10)
                if this.Cache.Has(Tenth) {
                    Loop 10
                        Out .= this.Cache.Get(Tenth)
                } else
                    Out := _Process(Tenth)
                this.Cache.Set(Number(Qty), Out)
                return Out
            }
        }
        /**
         * @description - Sets the cache value of the indicated `Qty`. This can be useful in a
         * situation where you know you will be using a string of X length often, but X is not
         * divisible by 10. `FillStr` instances do not cache lengths unless they are divisible by
         * 10 to avoid memory bloat, but will still return a cached value if the input Qty exists in
         * the cache.
         */
        Set {
            this.Cache.Set(Number(Qty), value)
        }
    }

    /**
     * @description - Center aligns the string within a specified width. This method is compatible
     * with filler strings of any length.
     * @param {String} Str - The string to center align.
     * @param {Integer} Width - The width of the output string in number of characters.
     * @param {Number} [RemainderAction=1] - The action to take when the difference between the width
     * and the string length is not evenly divisible by 2.
     * - 0: Exclude the remainder.
     * - 1: Add the remainder to the left side.
     * - 2: Add the remainder to the right side.
     * - 3: Add the remainder to both sides.
     */
    CenterAlign(Str, Width, RemainderAction := 1, Padding := ' ', TruncateActionLeft := 1, TruncateActionRight := 2) {
        Space := Width - StrLen(Str) - (LenPadding := StrLen(Padding) * 2)
        if Space < 1
            return Str
        Split := Floor(Space / 2)
        if R := Mod(Space, 2) {
            switch RemainderAction {
                case 0: LeftOffset := RightOffset := Split
                case 1: LeftOffset := Split + R, RightOffset := Split
                case 2: LeftOffset := Split, RightOffset := Split + R
                case 3: LeftOffset := RightOffset := Split + R
                default:
                    throw MethodError('Invalid RemainderAction.', -1, 'RemainderAction: ' RemainderAction)
            }
        } else
            LeftOffset := RightOffset := Split
        return FillStr.GetOffsetStr(LeftOffset, TruncateActionLeft, this) Padding Str Padding FillStr.GetOffsetStr(RightOffset, TruncateActionRight, this)
    }

    /**
     * @description - Center aligns a string within a specified width. This method is only compatible
     * with filler strings that are 1 character in length.
     * @param {String} Str - The string to center align.
     * @param {Number} Width - The width of the output string.
     * @param {Number} [RemainderAction=1] - The action to take when the difference between the width
     * and the string length is not evenly divisible by 2.
     * - 0: Exclude the remainder.
     * - 1: Add the remainder to the left side.
     * - 2: Add the remainder to the right side.
     * - 3: Add the remainder to both sides.
     * @returns {String} - The center aligned string.
     */
    CenterAlignA(Str, Width, RemainderAction := 1) {
        Space := Width - StrLen(Str)
        r := Mod(Space, 2)
        Split := (Space - r) / 2
        switch RemainderAction {
            case 0: return this[Split] Str this[Split]
            case 1: return this[Split + r] Str this[Split]
            case 2: return this[Split] Str this[Split + r]
            case 3: return this[Split + r] Str this[Split + r]
            default:
                throw MethodError('Invalid RemainderAction.', -1, 'RemainderAction: ' RemainderAction)
        }
    }

    /** @description - Clears the cache. */
    ClearCache() => this.Cache.Clear()

    /**
     * @description - Left aligns a string within a specified width. This method is compatible with
     * filler strings of any length.
     * @param {String} Str - The string to left align.
     * @param {Integer} Width - The width of the output string in number of characters.
     * @param {Integer} [LeftOffset=0] - The offset from the left side in number of characters. The
     * offset is constructed by using the filler string (`Filler.Str`) value and repeating
     * it until the offset length is reached.
     * @param {String} [Padding=' '] - The `Padding` value is added to the left and right side of
     * `Str` to create space between the string and the filler characters. To not use padding, set
     * it to an empty string.
     * @param {Integer} [TruncateActionLeft=1] - This parameter controls how the filler string
     * `Filler.Str` is truncated when the LeftOffset is not evenly divisible by the length of
     * `Filler.Str`. For a full explanation, see {@link FillStr.GetOffsetStr}.
     * @param {Integer} [TruncateActionRight=2] - This parameter controls how the filler string
     * `Filler.Str` is truncated when the remaining character count on the right side of the output
     * string is not evenly divisible by the length of `Filler.Str`. For a full explanation, see
     * {@link FillStr.GetOffsetStr}.
     */
    LeftAlign(Str, Width, LeftOffset := 0, Padding := ' ', TruncateActionLeft := 1, TruncateActionRight := 2) {
        if LeftOffset + (LenStr := StrLen(Str)) + (LenPadding := StrLen(Padding) * 2) > Width
            LeftOffset := Width - LenStr - LenPadding
        if LeftOffset > 0
            Out .= FillStr.GetOffsetStr(LeftOffset, TruncateActionLeft, this)
        Out .= Padding Str Padding
        if (Remainder := Width - StrLen(Out))
            Out .= FillStr.GetOffsetStr(Remainder, TruncateActionRight, this)
        return Out
    }

    /**
     * @description - Left aligns a string within a specified width. This method is only compatible
     * with filler strings that are 1 character in length.
     * @param {String} Str - The string to left align.
     * @param {Number} Width - The width of the output string.
     * @param {Number} [LeftOffset=0] - The offset from the left side.
     * @returns {String} - The left aligned string.
     */
    LeftAlignA(Str, Width, LeftOffset := 0) {
        if LeftOffset {
            if LeftOffset + StrLen(Str) > Width
                LeftOffset := Width - StrLen(Str)
            return this[LeftOffset] Str this[Width - StrLen(Str) - LeftOffset]
        }
        return Str this[Width - StrLen(Str)]
    }

    ; /**
    ;  * @description - Right aligns a string within a specified width. This method is compatible with
    ;  * filler strings of any length.
    ;  * @param {String} Str - The string to right align.
    ;  * @param {Integer} Width - The width of the output string in number of characters.
    ;  * @param {Integer} [RightOffset=0] - The offset from the right side in number of characters. The
    ;  * offset is constructed by using the filler string (`Filler.Str`) value and repeating
    ;  * it until the offset length is reached.
    ;  * @param {String} [Padding=' '] - The `Padding` value is added to the left and right side of
    ;  * `Str` to create space between the string and the filler characters. To not use padding, set
    ;  * it to an empty string.
    ;  * @param {Integer} [TruncateActionLeft=1] - This parameter controls how the filler string
    ;  * `Filler.Str` is truncated when the remaining character count on the left side of the output
    ;  * string is not evenly divisible by the length of `Filler.Str`. For a full explanation, see
    ;  * {@link FillStr.GetOffsetStr}.
    ;  * @param {Integer} [TruncateActionRight=2] - This parameter controls how the filler string
    ;  * `Filler.Str` is truncated when the RightOffset is not evenly divisible by the length of
    ;  * `Filler.Str`. For a full explanation, see {@link FillStr.GetOffsetStr}.
    ;  * @returns {String} - The right aligned string.
    ;  */
    ; RightAlign(Str, Width, RightOffset := 0, Padding := ' ', TruncateActionLeft := 1, TruncateActionRight := 2) {
    ;     if RightOffset + (LenStr := StrLen(Str)) + (LenPadding := StrLen(Padding) * 2) > Width
    ;         RightOffset := Width - LenStr - LenPadding
    ;     Out := Padding Str Padding
    ;     if (Remainder := Width - StrLen(Out) - RightOffset)
    ;         Out := FillStr.GetOffsetStr(Remainder, TruncateActionRight, this) Out
    ;     if RightOffset > 0
    ;         Out := FillStr.GetOffsetStr(RightOffset, TruncateActionLeft, this) Out
    ;     return Out
    ; }

	/**
	 * Right aligns text within a specified width with flexible padding and offset options
	 * @param {String} params* - Parameters in flexible order:
	 *   - str: String to align
	 *   - width: Total width for alignment 
	 *   - rightOffset: Offset from right edge (default: 0)
	 *   - padding: Padding character/string (default: ' ')
	 *   - truncateActionLeft: Left truncation mode (default: 1)
	 *   - truncateActionRight: Right truncation mode (default: 2)
	 * @returns {String} Right-aligned text string
	 * @throws {ValueError} If width < string length
	 */
	RightAlign(params*) {
		; Initialize defaults
		config := {
			str: "",
			width: 0, 
			rightOffset: 0,
			padding: " ",
			truncateActionLeft: 1,
			truncateActionRight: 2
		}
	
		; Parse parameters
		for param in params {
			if (param is String && !config.str)
				config.str := param
			else if (param is Integer && !config.width)
				config.width := param
			else if (param is Integer)
				config.rightOffset := param
			else if (param is String)
				config.padding := param
		}
	
		; Validate
		if (!config.str || !config.width)
			throw ValueError("String and width are required", -1)
			
		if (config.rightOffset + (lenStr := StrLen(config.str)) + 
			(lenPadding := StrLen(config.padding) * 2) > config.width)
			config.rightOffset := config.width - lenStr - lenPadding
	
		; Build output
		out := config.padding config.str config.padding
		
		if (remainder := config.width - StrLen(out) - config.rightOffset)
			out := FillStr.GetOffsetStr(remainder, config.truncateActionRight, this) out
			
		if (config.rightOffset > 0)
			out := FillStr.GetOffsetStr(config.rightOffset, config.truncateActionLeft, this) out
	
		return out
	}
    /**
     * @description - Right aligns a string within a specified width. This method is only compatible
     * with filler strings that are 1 character in length.
     * @param {String} Str - The string to right align.
     * @param {Number} Width - The width of the output string.
     * @param {Number} [RightOffset=0] - The offset from the right side.
     * @returns {String} - The right aligned string.
     */
    RightAlignA(Str, Width, RightOffset := 0) {
        if RightOffset {
            if RightOffset + StrLen(Str) > Width
                RightOffset := Width - StrLen(Str)
            return this[Width - StrLen(Str) - RightOffset] Str this[RightOffset]
        }
        return this[Width - StrLen(Str)] Str
    }
}
