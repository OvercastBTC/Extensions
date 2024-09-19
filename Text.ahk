; String2.Prototype.Base := Text2

; Class Text2 {
; 	static CompressSpaces() => RegexReplace(this, " {2,}", " ")

; 	static WriteFile(whichFile, flags := 'rw', encoding := 'UTF-8-RAW') {
; 		; fileObj := FileOpen(whichFile, "w", "UTF-8-RAW")
; 		; fileObj := FileOpen(whichFile, 'rw', 'UTF-8')
; 		; fileObj := FileOpen(this, 'rw')
; 		fileObj := FileOpen(whichFile, flags, encoding) || fileObj := FileOpen(this, flags, encoding)
; 		fileObj.Write(this)
; 	}

; 	static AppendFile(whichFile, encoding := 'UTF-8-RAW') => FileAppend(this, whichFile, encoding)

; 	static ToggleInfo() {
; 		g_ToggleInfo := Gui("AlwaysOnTop -Caption +ToolWindow").DarkMode().MakeFontNicer()
; 		g_ToggleInfo.AddText(, this)
; 		g_ToggleInfo.Show("W225 NA x1595 y640")
; 		SetTimer(() => g_ToggleInfo.Destroy(), -1000)
; 		return this
; 	}

; 	static FileWrite(content, filePath) {
; 		FileAppend(content, filePath, "UTF-8")
; 	}


; 	/**
; 	 * 
; 	 * @param {String} whichFile New file name or path to existing file
; 	 * @param {String} ext extension of the new file: Default: .txt
; 	 * @returns {String} newfile returns the new file name and associated extension
; 	 */
; 	static WriteTxtToFile(whichFile := A_ScriptDir '\' whichFile, ext := '.txt') {
; 		if FileExist(whichFile) {
; 			FileDelete(whichFile)
; 			this.AppendFile(this)
; 		}
; 		else {
; 			newfile := whichFile ext
; 			this.AppendFile(newfile)
; 			return newfile
; 		}
; 	}
; }


; File.Prototype.Base := File2
; ; File.Prototype.Append := (content) => FileWrite(content, this, "UTF-8")

; Class File2 {
; 	; static ReadFile() => FileRead(this, 'UTF-8')
; 	static SwitchFiles(path2) {

; 		file1Read := FileOpen(this, "r", "UTF-8-RAW")
; 		file1Read.Seek(0, 0)
	
; 		file2Read := FileOpen(path2, "r", "UTF-8-RAW")
; 		file2Read.Seek(0, 0)
	
; 		text1 := file1Read.Read()
; 		text2 := file2Read.Read()
	
; 		file1Write := FileOpen(this, "w", "UTF-8-RAW")
	
; 		file2Write := FileOpen(path2, "w", "UTF-8-RAW")
	
; 		file1Write.Write(text2)
; 		file2Write.Write(text1)
	
; 		file1Read.Close()
; 		file2Read.Close()
	
; 		file1Write.Close()
; 		file2Write.Close()
; 	}

; 	/**
; 	 * @param {String} flags default flags of 'r'
; 	 * @param {String} encoding default encoding := 'UTF-8-RAW' 
; 	 * @returns {File} Same as FileOpen() but with default flags, and default encoding
; 	 */
; 	static Open() => FileOpen(this, "r", encoding := 'UTF-8-RAW')

; 		/**
; 	 * @param {String} flags default flags of 'r a' (read & append if the file doesn't exist)
; 	 * @param {String} encoding default encoding := 'UTF-8-RAW' 
; 	 * @returns {File} Same as FileOpen() but with default flags, and default encoding
; 	 */
; 	static Open2() => FileOpen(this, "r a", encoding := 'UTF-8-RAW')

; 	static Read2() => this.FileRead()

; 	static FileRead(text := '', encoding := 'UTF-8-RAW') {
; 		; !(file2Read := FileOpen(this, "r", encoding)) ? file2Read := FileOpen(this, "r a", encoding) : file2Read := FileOpen(this, "r", encoding)
; 		!(file2Read := this.Open()) ? file2Read := this.Open2() : file2Read := this.Open()
; 		text := file2Read.Read()
; 		file2Read.Seek(0, 0)
; 		file2Read.Close()
; 		return text
; 	}

; 	static WriteToFile(text := '', encoding := 'UTF-8-RAW') {

; 		; if !(fileRead := FileOpen(this, "r", encoding)) {
; 		; 	fileRead := FileOpen(this, "r a", encoding)
; 		; }
; 		; else {
; 		; 	fileRead := FileOpen(this, "r", encoding)
; 		; }
; 		!(file2Read := FileOpen(this, "r", encoding)) ? file2Read := FileOpen(this, "r a", encoding) : file2Read := FileOpen(this, "r", encoding)
; 		file2Read.Seek(0, 0)
	
; 		; file2Read := FileOpen(path2, "r", "UTF-8-RAW")
; 		; file2Read.Seek(0, 0)
	
; 		text := file2Read.Read()
; 		; text2 := file2Read.Read()
	
; 		file2Write := FileOpen(this, "w", encoding)
	
; 		; file2Write := FileOpen(path2, "w", "UTF-8-RAW")
	
; 		file2Write.Write(text)
; 		; file2Write.Write(text1)
	
; 		; file2Read.Close()
; 		; file2Read.Close()
	
; 		file2Write.Close()
; 		; file2Write.Close()
; 	}
; 	; Adding static method to built-in File class
; 	static Ext(filename){
; 		SplitPath(filename,, &dir, &ext)
; 		return ext
; 	}
; }

; ; Standalone function
; FileExt(filename) {
;     SplitPath(filename,, &dir, &ext)
;     return ext
; }

; class Unicode {

; 	static Symbols := Map(

; 		" ",                        0x0020,
; 		"zwj",                      0x200D,
; 		"varsel16",                 0xFE0F,
; 		"female sign",              0x2640,  ; ♀
; 		"pleading",                 0x1F97A, ; 🥺
; 		"yum",                      0x1F60B, ; 😋
; 		"exploding head",           0x1F92F, ; 🤯
; 		"smirk cat",                0x1F63C, ; 😼
; 		"sunglasses",               0x1F60E, ; 😎
; 		"sob",                      0x1F62D, ; 😭
; 		"face with monocle",        0x1F9D0, ; 🧐
; 		"flushed",                  0x1F633, ; 😳
; 		"face with raised eyebrow", 0x1F928, ; 🤨
; 		"purple heart",             0x1F49C, ; 💜
; 		"skull",                    0x1F480, ; 💀
; 		"rolling eyes",             0x1F644, ; 🙄
; 		"thinking",                 0x1F914, ; 🤔
; 		"weary",                    0x1F629, ; 😩
; 		"woozy",                    0x1F974, ; 🥴
; 		"finger left",              0x1F448, ; 👈
; 		"finger right",             0x1F449, ; 👉
; 		"drooling",                 0x1F924, ; 🤤
; 		"eggplant",                 0x1F346, ; 🍆
; 		"smiling imp",              0x1F608, ; 😈
; 		"fearful",                  0x1F628, ; 😨
; 		"middle dot",               0x00B7,  ; ·
; 		"long dash",                0x2014,  ; —
; 		"sun",                      0x2600,  ; ☀
; 		"cloud",                    0x2601,  ; ☁
; 		"nerd",                     0x1F913, ; 🤓
; 		"handshake",                0x1F91D, ; 🤝
; 		"shrug",                    0x1F937, ; 🤷
; 		"clap",                     0x1F44F, ; 👏
; 		"amogus",                   0x0D9E,  ; ඞ
; 		"confetti",                 0x1F389, ; 🎉
; 		"eyes",                     0x1F440, ; 👀
; 		"sneezing face",            0x1F927, ; 🤧
; 		"grimacing",                0x1F62C, ; 😬
; 		"crossed out",              0x1F635, ; 😵
; 		"dizzy",                    0x1F4AB, ; 💫
; 		"face with hearts",         0x1F970, ; 🥰
; 		"innocent",                 0x1F607, ; 😇
; 		"scarf",                    0x1F9E3, ; 🧣
; 		"sparkles",                 0x2728,  ; ✨
; 		"relieved",                 0x1F60C, ; 😌
; 		"knot",                     0x1FAA2, ;
; 		"comet",                    0x2604,  ; ☄️varsel16
; 		"panda",                    0x1F43C, ; 🐼
; 		"bamboo",                   0x1F38D, ; 🎍
; 		"muscle",                   0x1F4AA, ; 💪
; 		"scale",                    0x2696,  ; ⚖varsel16
; 		"alien",                    0x1F47D, ; 👽
; 		"badminton",                0x1F3F8, ; 🏸
; 		"clipboard",                0x1F4CB, ; 📋
; 		"lobster",                  0x1F99E, ; 🦞
; 		"rosette",                  0x1F3F5, ; 🏵varsel16
; 		"gem",                      0x1F48E, ; 💎
; 		"firecracker",              0x1F9E8, ; 🧨
; 		"athletic shoe",            0x1F45F, ; 👟
; 		"fish",                     0x1F41F, ; 🐟
; 		"satellite",                0x1F6F0, ; 🛰varsel16
; 		"statue of liberty",        0x1F5FD, ; 🗽
; 		"tropical fish",            0x1F420, ; 🐠
; 		"penguin",                  0x1F427, ; 🐧
; 		"kiwi",                     0x1F95D, ; 🥝
; 		"archery",                  0x1F3F9, ; 🏹
; 		"shell",                    0x1F41A, ; 🐚
; 		"shrimp",                   0x1F990, ; 🦐
; 		"broom",                    0x1F9F9, ; 🧹
; 		"ocean",                    0x1F30A, ; 🌊
; 		"wolf",                     0x1F43A, ; 🐺
; 		"paperclip",                0x1F4CE, ; 📎
; 		"nail polish",              0x1F485, ; 💅
; 		"shell top arc",            0x256D,  ; ╭
; 		"shell horizontal",         0x2500,  ; ─
; 		"shell bottom arc",         0x2570,  ; ╰
; 		"shell middle line",        0x2502,  ; │
; 		"cat",                      0x1F408, ; 🐈
; 		"chicken",                  0x1F414, ; 🐔
; 		"parrot",                   0x1F99C, ; 🦜
; 		"cricket",                  0x1F997, ; 🦗
; 		"glowing star",             0x1F31F, ; 🌟
; 		"ship",                     0x1F6A2, ; 🚢

; 	)

; 	/**
; 	* Sends a unicode character using the Send function by using the character's predefined name
; 	* @param name *String* The predefined name of the character
; 	* @param endingChar *String* The string to append to the character. For example, a space or a newline
; 	*/
; 	static Send(symbols*) {
; 		output := ""
; 		for index, symbol in symbols
; 			output .= Chr(this.Symbols[symbol])
; 		if symbols.Length > 1
; 			ClipSend(output)
; 		else
; 			SendText(output)
; 	}

; 	static DynamicSend() {
; 		if !input := CleanInputBox().WaitForInput()
; 			return
; 		symbols := StrSplit(input, ",")
; 		output := ""
; 		for index, symbol in symbols {
; 			output .= Chr(this.Symbols.Choose(symbol))
; 		}
; 		ClipSend(output)
; 	}

; }
