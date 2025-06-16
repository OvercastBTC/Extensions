#Include <Includes/Basic>

/**
 * @class FileSystemSearch
 * @description Utility for searching files and folders in the file system
 * @version 1.1.0
 * @author Original: Axlefublr
 * @author Updates: OvercastBTC
 */
class FileSystemSearch {
    ; Standard paths for quick selection
    StandardPaths := [
        "C:\Users\" A_UserName "\Documents",
        "C:\Users\" A_UserName "\Desktop",
        "C:\Users\" A_UserName "\Downloads",
        A_MyDocuments,
        A_Desktop,
        ; Add more standard paths as needed
    ]

    /**
     * @constructor
     * @param {String} searchWhere Optional path to search in
     * @param {String} caseSense Case sensitivity for search, default "Off"
     * @param {Object} options Additional search options
     */
    __New(searchWhere?, caseSense := "Off", options := {}) {
        ; Create GUI instance - use the appropriate base class
        this.exGui := Gui("+Resize", "File System Search")
        
        ; Apply visual styling
        this.exGui.MakeFontNicer(14)
        this.exGui.DarkMode()
        
        ; Add instructions
        this.List := this.exGui.AddText(, "
        (
            Right click on a result to copy its full path.
            Double click to open it in explorer.
        )")
        
        ; Configure layout parameters
        this.WidthOffset := 35
        this.HeightOffset := 80
        
        ; Set default search options
        this.caseSense := caseSense
        this.options := options
        
        ; Default options
        this.searchFilesDefault := this.options.HasProp("searchFiles") ? this.options.searchFiles : true
        this.searchFoldersDefault := this.options.HasProp("searchFolders") ? this.options.searchFolders : true
        this.maxResults := this.options.HasProp("maxResults") ? this.options.maxResults : 1000
        this.searchSubfolders := this.options.HasProp("searchSubfolders") ? this.options.searchSubfolders : true
        
        ; Create ListView for results
        this.List := this.exGui.AddListView(
            "Count50 Background" this.exGui.BackColor,
            ["File", "Folder", "Directory"]
        )
        
        ; Set up path
        if !IsSet(searchWhere) {
            this.ValidatePath()
        } else {
            this.path := searchWhere
        }
        
        ; Set up event handlers
        this.SetOnEvents()
    }

    /**
     * @description Shows UI to select a search location
     * @returns {FileSystemSearch} Current instance for method chaining
     */
    GetSearchPath() {
        ; Create a selection GUI for choosing search location
        selectionGui := Gui("+AlwaysOnTop", "Select Search Location")
        selectionGui.Add("Text",, "Choose where to search:")
        
        ; Add standard paths as radio buttons
        radioGroup := selectionGui.AddGroupBox("w400 h" (this.StandardPaths.Length * 25 + 40), "Standard Locations")
        y := 20
        
        ; Create unique names for radio buttons
        for index, path in this.StandardPaths {
            selectionGui.AddCheckBox("xm+10 yp+" y " vSearchPath" index ' Checked', path)
            y := 25
        }
        
        ; Add option for custom path with unique name
        selectionGui.AddRadio("y+" (this.StandardPaths.Length * 25 + 30) " vSearchPathCustom", "Custom Path...")
        selectionGui.AddButton("y+10 w80", "Select").OnEvent("Click", (*) => this.HandlePathSelection(selectionGui))
        
        selectionGui.Show()
        
        return this ; For method chaining
    }

    /**
     * @description Processes the path selection
     * @param {Gui} selectionGui The selection GUI object
     */
    HandlePathSelection(selectionGui) {
        for ctrl in selectionGui {
            if ctrl.HasProp("Value") && ctrl.Value {
                if (ctrl.Text == "Custom Path...") {
                    if folder := DirSelect(,, "Select folder to search in") {
                        this.path := folder
                    }
                } else {
                    this.path := ctrl.Text
                }
                break
            }
        }
        selectionGui.Destroy()
    }

    /**
     * @description Validates and sets the search path
     * @returns {FileSystemSearch} Current instance for method chaining
     */
    ValidatePath() {
        try {
            ; Try to get path from explorer window
            SetTitleMatchMode('RegEx')
            this.path := WinGetTitle('^[A-Z]: ahk_exe explorer\.exe')
            
            ; Format path if needed
            if this.path ~= '^[A-Z]:\\$' {
                this.path := this.path[1, -2]
            }
        } catch Any {
            ; If we can't get explorer path, show GUI to select path
            this.GetSearchPath()
            
            ; If still no path selected, use Documents as default
            if !this.HasProp("path") || !this.path {
                this.path := A_MyDocuments
                Infos('Using default path: ' this.path, 2000)
            }
        }
        
        return this ; For method chaining
    }

    /**
     * @description Starts the search with the specified input
     * @param {String} input Text to search for
     * @returns {FileSystemSearch} Current instance for method chaining
     */
    StartSearch(input) {
        this.List.Opt("-Redraw")
        gInfo := Infos("The search is in progress")

        ; Clear previous results
        this.List.Delete()

        ; Handle path formatting
        if this.path ~= "^[A-Z]:\\$" {
            this.path := this.path[1, -2]
        }

        ; Track results and time
        startTime := A_TickCount
        resultCount := 0

        ; Search in the selected path
        try {
            resultCount := this.SearchInPath(this.path, input)
        } catch as e {
            Infos("Search error: " e.Message, 3000)
        }

        ; Calculate search time
        searchTime := (A_TickCount - startTime) / 1000

        ; Update UI
        gInfo.Destroy()
        this.List.Opt("+Redraw")
        this.List.ModifyCol()
        
        ; Show results with stats
        this.exGui.Title := "File System Search - " resultCount " results (" searchTime "s)"
        this.exGui.Show("AutoSize")
        
        return this ; For method chaining
    }

    /**
     * @description Recursively searches for files and folders in the specified path
     * @param {String} searchPath Path to search in
     * @param {String} input Text to search for
     * @returns {Integer} Number of results found
     */
    SearchInPath(searchPath, input) {
        resultCount := 0
        searchMode := (this.searchSubfolders ? "FDR" : "FD")
        
        try {
            loop files searchPath "\*.*", searchMode {
                ; Check if we should stop searching
                if resultCount >= this.maxResults {
                    break
                }
                
                ; Check if file/folder matches search criteria
                if !A_LoopFileName.Find(input, this.caseSense) {
                    continue
                }
                
                ; Add folder to results if enabled
                if A_LoopFileAttrib.Find("D") {
                    if this.searchFoldersDefault {
                        this.List.Add(,, A_LoopFileName, A_LoopFileDir)
                        resultCount++
                    }
                } 
                ; Add file to results if enabled
                else if A_LoopFileExt {
                    if this.searchFilesDefault {
                        this.List.Add(, A_LoopFileName,, A_LoopFileDir)
                        resultCount++
                    }
                }
            }
        } catch as e {
            ; Allow the search to continue in case of access denied errors
            ; This will be common when searching system folders
        }
        
        return resultCount
    }

    /**
     * @description Shows an input box and starts the search
     * @param {String} defaultInput Optional default input for search box
     * @returns {Boolean} False if input was cancelled
     */
    GetInput(defaultInput := "") {
        try {
            if !input := CleanInputBox().WaitForInput() {
                return false
            }
            this.StartSearch(input)
            return true
        } catch as e {
            Infos("Error: " e.Message, 3000)
            return false
        }
    }

    /**
     * @description Destroys the results GUI
     */
    DestroyResultListGui() {
        this.exGui.Minimize()
        this.exGui.Destroy()
    }

    /**
     * @description Sets up all event handlers
     */
    SetOnEvents() {
        this.List.OnEvent("DoubleClick",
            (guiCtrlObj, selectedRow) => this.ShowResultInFolder(selectedRow)
        )
        this.List.OnEvent("ContextMenu",
            (guiCtrlObj, rowNumber, *) => this.CopyPathToClip(rowNumber)
        )
        this.exGui.OnEvent("Size",
            (guiObj, minMax, width, height) => this.FixResizing(width, height)
        )
        this.exGui.OnEvent("Escape", (guiObj) => this.DestroyResultListGui())
    }

    /**
     * @description Adjusts the ListView size when the GUI is resized
     * @param {Number} width New width of the GUI
     * @param {Number} height New height of the GUI
     */
    FixResizing(width, height) {
        this.List.Move(,, width - this.WidthOffset, height - this.HeightOffset)
    }

    /**
     * @description Opens the selected result in Explorer
     * @param {Number} selectedRow Index of the selected row
     */
    ShowResultInFolder(selectedRow) {
        try {
            path := this.GetPathFromList(selectedRow)
            Run("explorer.exe /select," path)
        } catch as e {
            Infos("Error opening item: " e.Message, 3000)
        }
    }

    /**
     * @description Copies the full path of the selected result to clipboard
     * @param {Number} rowNumber Index of the selected row
     */
    CopyPathToClip(rowNumber) {
        try {
            A_Clipboard := this.GetPathFromList(rowNumber)
            Info("Path copied to clipboard!")
        } catch as e {
            Info("Error copying path: " e.Message)
        }
    }

    /**
     * @description Constructs the full path for a list item
     * @param {Number} rowNumber Index of the row
     * @returns {String} Full path of the file or folder
     */
    GetPathFromList(rowNumber) {
        file := this.List.GetText(rowNumber, 1)
        dir  := this.List.GetText(rowNumber, 2)
        path := this.List.GetText(rowNumber, 3)
        return path "\" file dir
    }
    
    /**
     * @description Set search options
     * @param {Object} options Options object with properties
     * @returns {FileSystemSearch} Current instance for method chaining
     */
    SetOptions(options) {
        ; Update options properties
        for key, value in options.OwnProps() {
            this.options.%key% := value
        }
        
        ; Update instance variables from options
        if options.HasProp("searchFiles") 
            this.searchFilesDefault := options.searchFiles
        if options.HasProp("searchFolders") 
            this.searchFoldersDefault := options.searchFolders
        if options.HasProp("maxResults")
            this.maxResults := options.maxResults
        if options.HasProp("searchSubfolders")
            this.searchSubfolders := options.searchSubfolders
            
        return this
    }
    
    /**
     * @description Filter results by file extension
     * @param {String|Array} extensions Extensions to include (e.g., "txt" or ["txt", "docx"])
     * @returns {FileSystemSearch} Current instance for method chaining
     */
    FilterByExtension(extensions) {
        ; Filter rows based on extensions
        if !this.List
            return this
            
        extensionList := Type(extensions) = "Array" ? extensions : [extensions]
        
        ; Filter ListView
        rowsToRemove := []
        rowCount := this.List.GetCount()
        
        ; Identify rows to remove
        loop rowCount {
            row := rowCount - A_Index + 1 ; Work backwards
            file := this.List.GetText(row, 1)
            
            ; Skip folders
            folder := this.List.GetText(row, 2)
            if folder 
                continue
                
            ; Check extension
            SplitPath(file,,, &ext)
            if !ext || !extensionList.Has(ext)
                rowsToRemove.Push(row)
        }
        
        ; Remove rows
        for row in rowsToRemove
            this.List.Delete(row)
            
        ; Update column widths
        this.List.ModifyCol()
        
        return this
    }
    
    /**
     * @description Helper function to create standalone search instance
     * @param {String} path Optional path to search in
     * @returns {FileSystemSearch} New search instance
     */
    static New(path?) {
        return IsSet(path) ? FileSystemSearch(path) : FileSystemSearch()
    }
    
    /**
     * @description Quick search standalone function
     * @param {String} path Optional path to search in
     * @param {String} searchTerm Optional search term (if not provided, will prompt)
     */
    static QuickSearch(path?, searchTerm?) {
        search := IsSet(path) ? FileSystemSearch(path) : FileSystemSearch()
        
        if IsSet(searchTerm)
            search.StartSearch(searchTerm)
        else
            search.GetInput()
    }
}

/**
 * @description Quick function to launch the file system search
 */
filesearch() {
    search := FileSystemSearch()
    search.GetInput()
}

; Auto-execute when included directly
if (A_LineFile = A_ScriptFullPath)
    filesearch()
