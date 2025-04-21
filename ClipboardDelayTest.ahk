/************************************************************************
 * @title Clipboard Delay Test Suite
 * @description This script tests the delay in clipboard operations using different methods.
 * @author OvercastBTC 
 * @date 2025/04/09
 * @version 0.0.1
 ***********************************************************************/
#Include <Extensions\Clipboard>

#HotIf WinActive(A_ScriptName)
; Auto-run the test when script is executed
ClipDelayTest(10)

; Hot reload shortcut
^!r:: {
	Reload()
}
#HotIf

:X*C1:script.delay::ClipDelayTest(100)

class ClipDelayTest {

	#Requires AutoHotkey v2+
	#SingleInstance Force

	static cdtGui := {}
	static LV := {}
	static samples := 5

	; Add static properties for history
	static historyFile := A_ScriptDir "\ClipDelay_History.csv"
	static maxHistoryEntries := 100  ; Adjust as needed
	static history := []  ; Initialize history array
	
	/**
	 * @description Initialize and run the test suite
	 */
	__New(samples?) {
		if samples {
			this.samples := samples
		}
		ClipDelayTest.CreateGui()
		ClipDelayTest.RunTests()  ; Pass the instance's samples to RunTests
	}
	
	static CreateGui() {
		this.cdtGui := Gui("+Resize", "Clipboard Delay Test Results")
		this.cdtGui.SetFont("s10", "Consolas")
		this.cdtGui.OnEvent("Size", this.GuiResize.Bind(this))

		; Cache initial positions
		this.guiPositions := {}
		
		; Current results ListView
		this.cdtGui.AddText("x10 y10", "Current Results:")
		this.LV := this.cdtGui.Add("ListView", "x10 y30 w600 h200 Grid", [
			"Method",
			"Average (ms)",
			"Min (ms)",
			"Max (ms)",
			"Samples", 
			"CPU Load",
			"Memory Load",
			"Timestamp"
		])
		
		this.guiPositions.historyY := 260  ; Cache the Y position

		; History ListView
		this.cdtGui.AddText("x10 y240", "Test History:")
		this.historyLV := this.cdtGui.Add("ListView", "x10 y260 w600 h200 Grid", [
			"Date",
			"Method",
			"Average (ms)",
			"Min (ms)",
			"Max (ms)",
			"Samples",
			"CPU Load",
			"Memory Load"
		])
		
		; Buttons - adjusted y position to go below both ListViews
		runBtn := this.cdtGui.Add("Button", "x10 y470 w120", "Run Tests")
		runBtn.OnEvent("Click", (*) => this.RunTests())
		
		clearBtn := this.cdtGui.Add("Button", "x+10 w120", "Clear")
		clearBtn.OnEvent("Click", (*) => this.ClearResults())
		
		saveBtn := this.cdtGui.Add("Button", "x+10 w120", "Save Results")
		saveBtn.OnEvent("Click", (*) => this.SaveResults())
		
		loadBtn := this.cdtGui.Add("Button", "x+10 w120", "Load History")
		loadBtn.OnEvent("Click", (*) => this.LoadHistory())
		
		this.cdtGui.Show()
		
		; Load history on startup
		this.LoadHistory()
	}
	
	; Modified resize handler for both ListViews
	static GuiResize(gui, minMax, width, height) {
		if minMax = -1  ; Window was minimized
			return
		
		listViewHeight := (height - 100) / 2  ; Split height between the two ListViews
		this.LV.Move(,, width - 20, listViewHeight)
		this.historyLV.Move(, this.guiPositions.historyY, width - 20, listViewHeight)
	}
	
	; Add methods for history management
	static SaveToHistory(method, avgDelay, minDelay, maxDelay, samples, cpuLoad, memLoad) {
		try {
			timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
			entry := [timestamp, method, avgDelay, minDelay, maxDelay, samples, cpuLoad, memLoad]
			
			; Read existing history
			history := this.history
			if FileExist(this.historyFile) {
				Loop Read this.historyFile {
					if A_Index > 1  ; Skip header
						history.Push(StrSplit(A_LoopReadLine, ","))
				}
			}

			; Add new entry
			history.Push(entry)

			; Trim history if too long
			while history.Length > this.maxHistoryEntries
				history.RemoveAt(1)

			; Save updated history
			content := "Date,Method,Average (ms),Min (ms),Max (ms),Samples,CPU Load,Memory Load`n"
			for row in history
				content .= '"' . row.Join('","') . '"' . "`n"

			FileDelete(this.historyFile)
			FileAppend(content, this.historyFile)

			; Update history view
			this.LoadHistory()
		}
		catch as err {
			MsgBox("Error saving to history: " err.Message)
		}
	}

	static LoadHistory() {
		try {
			this.historyLV.Delete()
			if !FileExist(this.historyFile)
				return

			Loop Read this.historyFile {
				if A_Index = 1  ; Skip header
					continue
				fields := StrSplit(A_LoopReadLine, ",")
				this.historyLV.Add(,fields*)
			}

			; Auto-size columns
			Loop this.historyLV.GetCount("Column")
				this.historyLV.ModifyCol(A_Index, "AutoHdr")
		}
		catch as err {
			MsgBox("Error loading history: " err.Message)
		}
	}

	/**
	 * @description Run the timing tests with different methods
	 */
	static RunTests() {
		this.LV.Delete()
		methods := ["query", "tick", "combined"]
		
		iterations := 1000
		
		for method in methods {
			; Run multiple tests for each method
			delays := []
			Loop 3 {
				delay := A_Delay
				delays.Push(delay)
			}
			
			; Calculate statistics
			avgDelay := this.Average(delays)
			minDelay := this.Min(delays)
			maxDelay := this.Max(delays)
			
			; Get system metrics
			cpuLoad := Clipboard.getSystemLoad()
			memLoad := Clipboard.getMemoryLoad()
			
			; Add results to ListView
			this.LV.Add(, 
				method,
				Format("{:.2f}", avgDelay),
				Format("{:.2f}", minDelay),
				Format("{:.2f}", maxDelay),
				this.samples,
				Format("{:.1f}%", cpuLoad),
				Format("{:.1f}%", memLoad)
			)
		}
		
		; Auto-size columns
		Loop this.LV.GetCount("Column"){
			this.LV.ModifyCol(A_Index, "AutoHdr")
		}
		this.SaveResults()
	}
	
	/**
	 * @description Clear the results ListView
	 */
	static ClearResults(*) {
		this.LV.Delete()
	}
	
	/**
	 * @description Save results to a CSV file
	 */
	static SaveResults(*) {
		try {
			filename := FormatTime(, "yyyy-MM-dd_HH-mm-ss") "_delay_test.csv"
			content := "Method,Average (ms),Min (ms),Max (ms),Samples,CPU Load,Memory Load`n"
			
			; Get data from ListView
			Loop this.LV.GetCount() {
				row := []
				Loop 7{
					row.Push(this.LV.GetText(A_Index))
					; content .= '"' . content.Join(row, '","') . '"' . "`n"
				}
				content .= '"' . content.Join(row, '","') . '"' . "`n"
			}
			
			; Create directory if it doesn't exist
			SplitPath(filename, , &dirPath)
			if (dirPath && !DirExist(dirPath))
				DirCreate(dirPath)
			
			; Delete existing file if it exists
			if FileExist(filename){
				FileDelete(filename)
			}
			FileAppend(content, filename)
			MsgBox("Results saved to " filename)
		}
		catch Error as err {
			dLog := ErrorLogger.Log(err)
			ErrorLogGui()
			; MsgBox("Error saving results: " err)
		}
	}
	
	; Helper methods
	static Average(arr) {
		sum := 0
		for val in arr
			sum += val
		return sum / arr.Length
	}
	
	static Min(arr) {
		min := arr[1]
		for val in arr
			min := val < min ? val : min
		return min
	}
	
	static Max(arr) {
		max := arr[1]
		for val in arr
			max := val > max ? val : max
		return max
	}
}
