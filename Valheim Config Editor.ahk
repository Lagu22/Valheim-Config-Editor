#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory
#SingleInstance Force ; Skips the dialog box and replaces the old instance automatically



; - - - - - - - - - FUNCTIONS - - - - - - - - - 
; load tree view hierarchy from the file mapping
loadTreeViewFromMapping(mapping)
{
	local
	TV_Delete()
	if (mapping.length() != 0) {
		sect := ""
		for k, v in mapping {
			if (sect != v["section"]) {
				sect := v["section"]
				currentSectionParentID := TV_Add(sect)
			}
			TV_Add(v["name"], currentSectionParentID)
		}
		TV_Modify(0, "Sort")
		GuiControl, -ReadOnly, guiEdit
	}
	return
}

; Load mappingping based on targetFile contents
loadFileMapping(targetFile)
{
	local
	currentSection := ""
	currentDescription := ""
	settings := []
	setting := {"section":"", "name":"", "value":"", "description":"", "updateFlag":false}
	
	; Load file
	if (FileExist(targetFile)) {
		Loop, read, % targetFile
		{
			; skip blank lines
			if (StrLen(A_LoopReadLine) != 0) {		
				; find sections "[String]"
				line := StrSplit(A_LoopReadLine)
				if (line[1] = "[" || line[(line.MaxIndex() - 1)] = "]") {			
					currentSection := A_LoopReadLine
					currentSection := SubStr(A_LoopReadLine, 2, -1)
				; find descriptions ";"
				} else if (line[1] = ";" || line[1] = "#") {
					if (currentDescription = "") {
						currentDescription := SubStr(A_LoopReadLine, 3)
					} else {
						currentDescription := currentDescription . "`n" . SubStr(A_LoopReadLine, 3)
					}		
				; adding setting details to 
				} else {
					settingSplit := StrSplit(A_LoopReadLine, "=")
					if (settingSplit.length() > 1) {
						setting := defineSetting(settingSplit, currentSection, currentDescription)
						if (StrLen(setting["description"]) < 5) {
							setting["description"] := settings[settings.Length()]["description"]
						}
					}
					settings.Push(setting)
					currentDescription := ""
				}
			}
		}
	}
	return settings
}


; create a setting object based on current file data
defineSetting(split, sect, description)
{
	local
	return {"section":sect, "name":split[1], "value":split[2], "description":description, "updateFlag":false}
}

; Save settings in buffer to file
saveRoutine(buffer, file)
{
	local
	for k, v in buffer {
		IniWrite, % v["value"], % file, % v["section"], % v["name"]
	}
	return
}

; Get the mapping key based on TreeView item's item ID
getSettingID(TreeViewItemID, mapping)
{
	local
	sID := -1
	sectID := TV_GetParent(TreeViewItemID)
	if (sectID != 0) {
		TV_GetText(sectText, sectID)
		TV_GetText(nameText, TreeViewItemID)
		for k, v in mapping {
			if (v["section"] != sectText) {
				continue
			} else if (v["name"] = nameText) {
				sID := k
				break
			}
		}
	}
	return sID
}

;
updateMapping(oldList, newList)
{
	local
	; update the existing settings sections in the new list
	msgbox, % oldList.length() . " " . newlist.length()
	for i, newSett in newlist {
		for j, oldSett in oldList {
			if (newSett["section"] = oldSett["section"]) {
				if (newSett["name"] = oldSett["name"]) {
					newSett["value"] := oldSett["value"]
					break
				}
			}
		}
	}
	return newList
}



; - - - - - - - - - MAIN  - - - - - - - - - 
version := "(v1.0)"

settingsList := []
settingsUpdateBuffer := []
settingID := 1
textID := 0
targetFile := ""
logoImage := "logo.ico"	
FileInstall, logo.ico, logo.ico, 1

if (FileExist("valheim_plus.cfg")) {
	targetFile := "valheim_plus.cfg"
} else {
	targetFile := ""
}
; Build GUI
; load image resource if available
if (FileExist(logoImage)) {
	Gui, Add, Picture, w64 h-1 x+225, % logoImage
	; remove image resource once loaded in GUI
	FileDelete, logoImage
}
Gui, Font, bold
Gui, Add, Text, r1 w200 x185, % "Valheim Config Editor " . version
Gui, Font,
Gui, Add, Text, r1 xm
Gui, Add, Text, r1 w250, % "Select a file to load settings into the menu"
Gui, Add, Edit, vguiPathBox r1 w300 ReadOnly section, % targetFile
Gui, Add, Button, vguiPathBtn gguiPathBtnEvent ys xs+320, % "Select File"
Gui, Add, Button, vguiMergeBtn gguiMergeBtnEvent ys xs+400, % "Merge Files"
Gui, Add, Text, r1 xm
Gui, Add, Text, vguiTextSearch r1 w40 xm section, % "Search: "
Gui, Add, Edit, vguiSearch gguiSearchEvent r1 w100 limit10 ys section, 
Gui, Add, Text, vguiTextResultCount r1 w75 ys+6, % "Results: "
Gui, Add, TreeView, glistTreeEvent r10 w300 xm section
Gui, Add, Text, vguiName r1 w500, % "Setting: "
Gui, Add, Text, r1
Gui, Add, Edit, vguiEdit gguiEditEvent r1 w100 limit10 +ReadOnly, 
Gui, Add, GroupBox, w200 h165 xm ys xs+320, % "Description:"
Gui, Add, Text, vguiDescr w150 r8 wrap xp+25 yp+30,
Gui, Add, StatusBar,,
SB_SetParts(450)
settingsList := loadFileMapping(targetFile)
loadTreeViewFromMapping(settingsList)
GuiControl, Text, guiTextResultCount, % "Results: " . settingsList.length()
Gui, Show
return



; - - - - - - - - - GUI Event Subroutines - - - - - - - - - 
; Update the GUI with this current setting's details based on TreeView selection : guiDescr, guiName, guiEdit, textID
listTreeEvent:
	; only fire when an TreeView item is selected
	if (A_GuiEvent = "S") {
		; Clear GUI
		GuiControl, Text, guiDescr,
		GuiControl, Text, guiName, % "Setting: "
		GuiControl,, guiEdit, % ""
		; Only update the GUI if child node selected
		textID := A_EventInfo
		settingID := getSettingID(textID, settingsList)
		if (settingID != 0) {
			; Update the GUI
			GuiControl, Text, guiDescr, % settingsList[settingID]["description"]
			GuiControl, Text, guiName, % "Setting: " . settingsList[settingID]["name"]
			GuiControl,, guiEdit, % settingsList[settingID]["value"]
		}
	}
	return

; Add the current setting to the update buffer : guiEdit, textID
guiEditEvent:
	Critical, On
	gui, submit, nohide
	settingID := getSettingID(textID, settingsList)
	if (settingID != 0) {
		; Update the setting mapping for this settingID
		settingsList[settingID]["value"] := guiEdit
		; Push this setting to the update buffer if it is not already
		if (settingsList[settingID]["updateFlag"] != true && settingsList[settingID]["section"] != "") {
			settingsList[settingID]["updateFlag"] := true
			settingsUpdateBuffer.Push(settingsList[settingID])
		}
		; Update the status bar
		FormatTime, timeNow,, HH:mm (ss)
		if (settingID != 0 && TV_GetParent(textID) != 0) {
			SB_SetText("Last Edit: " . settingsList[settingID]["section"] . " - " . settingsList[settingID]["name"] 
			. "=" . settingsList[settingID]["value"], 1)
			SB_SetText("Time: " . timeNow, 2) 
		}
	}
	Critical, Off
	return

; Update the current .cfg file loaded in the TreeView and mappingping : guiPathBox, targetFile
guiPathBtnEvent:
	tFile := targetFile
	FileSelectFile, targetFile, 9,, Select a config file, *.cfg
	if !(targetFile) {
		targetFile := tFile
		Gui, show
		return
	}
	tfile := ""
	GuiControl,, guiPathBox, % targetFile
	settingsList := loadFileMapping(targetFile)
	loadTreeViewFromMapping(settingsList)
	GuiControl, Text, guiTextResultCount, % "Results: " . settingsList.length()
	return

; Load a new TreeView based on search query : guiSearch
guiSearchEvent:
	gui, submit, nohide
	queryResults := []
	if (StrLen(guiSearch) > 0) {
		query := guiSearch
		queryLen := StrLen(query)
		for key, value in settingsList {
			;chars := SubStr(value["name"], 1, -(StrLen(value["name"]) - queryLen))
			;if (chars = query) {
			if (InStr(value["name"], query, 0, 1, 1)){
				queryResults.Push(value)
			}
			;}
		}
	loadTreeViewFromMapping(queryResults)
	GuiControl, Text, guiTextResultCount, % "Results: " . queryResults.length()
	} else if (guiSearch = "") {
		loadTreeViewFromMapping(settingsList)
		GuiControl, Text, guiTextResultCount, % "Results: " . settingsList.length()
	}
	return

;
guiMergeBtnEvent:
	FileSelectFile, old_targetFile, 9,, % "Select old config file to get updates from", *.cfg
	FileSelectFile, new_targetFile, 9,, % "Select new config file to update", *.cfg
	if (old_targetFile = "" || new_targetFile = "") {
		return
	}
	settingsList := updateMapping(loadFileMapping(old_targetFile), loadFileMapping(new_targetFile))
	msgbox, % settingsList.length()
	loadTreeViewFromMapping(settingsList)
	GuiControl, Text, guiTextResultCount, % "Results: " . settingsList.length()
	GuiControl,, guiPathBox, % new_targetFile
	saveRoutine(settingsList, new_targetFile)
	return

; If GUI is closed, Escape is pressed or the guiCloseEvent is called, save
; the update buffer to file and exit
GuiClose:
GuiEscape:
guiCloseEvent:
	saveRoutine(settingsUpdateBuffer, targetFile)
	ExitApp

