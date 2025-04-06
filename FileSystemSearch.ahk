#Include <Extensions\Gui>
#Include <Tools\Info>
#Include <Extensions\String>

class FileSystemSearch extends Gui {

    static StandardPaths := [
        "C:\Users\" A_UserName "\Documents",
        "C:\Users\" A_UserName "\Desktop",
        "C:\Users\" A_UserName "\Downloads",
        A_MyDocuments,
        A_Desktop,
        ; Add more standard paths as needed
    ]

    __New(searchWhere?, caseSense := "Off") {
        super.__New("+Resize", "File System Search")
        
        this.MakeFontNicer(14)
        this.DarkMode()
        
        this.List := this.AddText(, "
        (
            Right click on a result to copy its full path.
            Double click to open it in explorer.
        )")
        
        this.WidthOffset := 35
        this.HeightOffset := 80
        
        this.List := this.AddListView(
            "Count50 Background" this.BackColor,
            ["File", "Folder", "Directory"]
        )
        
        this.caseSense := caseSense
        
        if !IsSet(searchWhere) {
            this.GetSearchPath()
        } else {
            this.path := searchWhere
        }
        
        this.SetOnEvents()
    }

    GetSearchPath() {
        ; Create a selection GUI for choosing search location
        selectionGui := Gui("+AlwaysOnTop", "Select Search Location")
        selectionGui.Add("Text",, "Choose where to search:")
        
        ; Add standard paths as radio buttons
        radioGroup := selectionGui.Add("GroupBox", "w400 h" (this.StandardPaths.Length * 25 + 40), "Standard Locations")
        y := 20
        for path in this.StandardPaths {
            selectionGui.Add("Radio", "xp+10 yp+" y " vSearchPath", path)
            y := 25
        }
        
        ; Add option for custom path
        selectionGui.Add("Radio", "y+" (this.StandardPaths.Length * 25 + 30), "Custom Path...")
        selectionGui.Add("Button", "y+10 w80", "Select").OnEvent("Click", (*) => this.HandlePathSelection(selectionGui))
        
        selectionGui.Show()
    }

    HandlePathSelection(selectionGui) {
        if (selectionGui["SearchPath"].Value) {
            for ctrl in selectionGui.Controls {
                if ctrl is Radio && ctrl.Value {
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
        }
        selectionGui.Destroy()
    }

    StartSearch(input) {
        this.List.Opt("-Redraw")
        gInfo := Infos("The search is in progress")

        ; Handle path formatting
        if this.path ~= "^[A-Z]:\\$" {
            this.path := this.path[1, -2]
        }

        ; Search in the selected path
        this.SearchInPath(this.path, input)

        gInfo.Destroy()
        this.List.Opt("+Redraw")
        this.List.ModifyCol()
        this.Show("AutoSize")
    }

    SearchInPath(searchPath, input) {
        loop files searchPath "\*.*", "FDR" {
            if !A_LoopFileName.Find(input, this.caseSense) {
                continue
            }
            if A_LoopFileAttrib.Find("D")
                this.List.Add(,, A_LoopFileName, A_LoopFileDir)
            else if A_LoopFileExt
                this.List.Add(, A_LoopFileName,, A_LoopFileDir)
        }
    }

    GetInput() {
        if !input := CleanInputBox().WaitForInput() {
            return false
        }
        this.StartSearch(input)
    }

    DestroyResultListGui() {
        this.Minimize()
        this.Destroy()
    }

    SetOnEvents() {
        this.List.OnEvent("DoubleClick",
            (guiCtrlObj, selectedRow) => this.ShowResultInFolder(selectedRow)
        )
        this.List.OnEvent("ContextMenu",
            (guiCtrlObj, rowNumber, *) => this.CopyPathToClip(rowNumber)
        )
        this.OnEvent("Size",
            (guiObj, minMax, width, height) => this.FixResizing(width, height)
        )
        this.OnEvent("Escape", (guiObj) => this.DestroyResultListGui())
    }

    FixResizing(width, height) {
        this.List.Move(,, width - this.WidthOffset, height - this.HeightOffset)
    }

    ShowResultInFolder(selectedRow) {
        try Run("explorer.exe /select," this.GetPathFromList(selectedRow))
    }

    CopyPathToClip(rowNumber) {
        A_Clipboard := this.GetPathFromList(rowNumber)
        Info("Path copied to clipboard!")
    }

    GetPathFromList(rowNumber) {
        file := this.List.GetText(rowNumber, 1)
        dir  := this.List.GetText(rowNumber, 2)
        path := this.List.GetText(rowNumber, 3)
        return path "\" file dir
    }
}
