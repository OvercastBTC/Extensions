#Requires AutoHotkey v2.0

class GUIInstance {
    static instances := Map()

    __New(name) {
        this.name := name
        this.gui := Gui("+Resize", "Instance: " . name)
        this.isVisible := false
        this.CreateControls()
        this.SetupEvents()
        this.errorLogger := ErrorLogger.GetInstance(name)
        GUIInstance.instances[name] := this
    }

    CreateControls() {
        this.gui.DarkMode()
        this.gui.MakeFontNicer(12)
        
        this.gui.Add("Text", "x10 y10 w280", "Welcome to instance: " . this.name)
        this.notepad := this.gui.Add("Edit", "x10 y40 w280 h100 vNotepad")
        this.gui.Add("Button", "x10 y150 w135", "Save").OnEvent("Click", (*) => this.SaveData())
        this.gui.Add("Button", "x155 y150 w135", "Load").OnEvent("Click", (*) => this.LoadData())
        this.gui.Add("Button", "x10 y190 w280", "Toggle Click-Through").OnEvent("Click", (*) => this.ToggleClickThrough())
    }

    SetupEvents() {
        this.gui.OnEvent("Close", (*) => this.Hide())
        this.gui.OnEvent("Size", (*) => this.ResizeControls())
    }

    ResizeControls() {
        if (this.gui.Hwnd) {
            this.gui.GetClientPos(,,&w, &h)
            this.notepad.Move(,, w - 20, h - 100)
        }
    }

    Show() {
        this.gui.Show()
        this.isVisible := true
    }

    Hide() {
        this.gui.Hide()
        this.isVisible := false
    }

    ToggleVisibility() {
        if (this.isVisible) {
            this.Hide()
        } else {
            this.Show()
        }
    }

    ToggleClickThrough() {
        static isClickThrough := false
        if (isClickThrough) {
            this.gui.Opt("-E0x20")
            WinSetTransparent("Off", "ahk_id " . this.gui.Hwnd)
            isClickThrough := false
            Info("Click-through disabled for " . this.name, 2000)
        } else {
            this.gui.Opt("+E0x20")
            WinSetTransparent(255, "ahk_id " . this.gui.Hwnd)
            isClickThrough := true
            Info("Click-through enabled for " . this.name, 2000)
        }
    }

    SaveData() {
        dataManager := DataManager()
        notepadContent := this.notepad.Value
        dataManager.StoreRevision(this.name, {notepad: notepadContent})
        this.errorLogger.Log("Data saved for instance: " . this.name)
        Info("Data saved for " . this.name, 2000)
    }

    LoadData() {
        dataManager := DataManager()
        revisions := dataManager.GetRevisions(this.name)
        if (revisions.Length > 0) {
            latestRevision := revisions[-1]
            this.notepad.Value := latestRevision.data.notepad
            this.errorLogger.Log("Data loaded for instance: " . this.name)
            Info("Data loaded for " . this.name, 2000)
        } else {
            this.errorLogger.Log("No data found for instance: " . this.name)
            Info("No data found for " . this.name, 2000)
        }
    }

    Update() {
        this.errorLogger.Log("Updating instance: " . this.name)
        Info("Updating " . this.name, 2000)
    }

    static GetInstance(name) {
        return GUIInstance.instances[name]
    }
}
