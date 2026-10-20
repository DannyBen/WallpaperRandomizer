#Requires AutoHotkey v2.0
#Include Wallpaper Randomizer.ahk

; Run with AutoHotkey v2. Exercises the real conversion path without changing
; the desktop wallpaper, registering hotkeys, or touching the user's INI.
class TestRandomizer extends WallpaperRandomizer {
  ReportError(err) {
    throw err
  }
  SetWallpaper(path) {
    Assert(FileExist(path), "Converted wallpaper exists")
    fixtureFile := FileOpen(path, "r")
    Assert(fixtureFile.Read(2) = "BM", "Wallpaper has a BMP header")
    this.AppliedImage := this.SelectedImage
    this.AppliedCount := this.HasOwnProp("AppliedCount") ? this.AppliedCount + 1 : 1
  }
}

Assert(condition, message) {
  if !condition
    throw Error(message)
}

root := A_Temp "\WallpaperRandomizer-v2-" DllCall("GetCurrentProcessId")
DirCreate(root "\images\nested")
DirCreate(root "\output")
ini := root "\settings.ini"
try {
  ; A valid two-pixel-square PNG, including a mixed-case extension and nested folder.
  data := "iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAMSURBVBhXY0ADDAwAABIAAaMn47oAAAAASUVORK5CYII="
  size := 0
  DllCall("Crypt32\CryptStringToBinaryW", "Str", data, "UInt", 0, "UInt", 1, "Ptr", 0, "UInt*", &size, "Ptr", 0, "Ptr", 0)
  bytes := Buffer(size)
  DllCall("Crypt32\CryptStringToBinaryW", "Str", data, "UInt", 0, "UInt", 1, "Ptr", bytes, "UInt*", &size, "Ptr", 0, "Ptr", 0)
  fixtureFile := FileOpen(root "\images\one.PNG", "w")
  fixtureFile.RawWrite(bytes)
  fixtureFile.Close()
  FileCopy(root "\images\one.PNG", root "\images\nested\two.png")
  FileAppend("ignored", root "\images\ignored.txt")
  IniWrite(root "\images", ini, "General", "ImageDir")
  IniWrite(root "\output", ini, "General", "TempDir")
  IniWrite(0.5, ini, "General", "Interval")
  IniWrite(1, ini, "General", "Paused")
  IniWrite(0, ini, "General", "HotkeysEnabled")
  app := TestRandomizer(ini)
  app.BuildMenus()
  Assert(app.Interval = 30000, "Fractional minutes become milliseconds")
  Assert(app.ExpandPath("%A_Temp%") = A_Temp, "Temp variable expansion")
  Assert(GetHotkeyDisplayString("+#F5") = "Shift+Win+F5", "Hotkey display")
  app.ChangeNowForce(1)
  Assert(app.Images.Length = 2, "Recursive, case-insensitive supported-image scan")
  first := app.SelectedImage
  Assert(app.AppliedImage = first, "First wallpaper applied")
  originalOrder := app.Images.Clone()
  app.ScanFiles()
  for index, path in originalOrder
    Assert(app.Images[index] == path, "Unchanged scan preserves exact order")
  app.ChangeNowForce(1)
  Assert(app.SelectedImage != first, "Next advances in shuffled list")
  app.ChangeNowForce(-1)
  Assert(app.SelectedImage = first, "Previous returns to same image")
  app.ChangeNowForce(-1)
  app.ChangeNowForce(-1)
  Assert(app.SelectedImage = first, "Previous wraps")
  app.ChangeNowForce(1)
  app.ChangeNowForce(1)
  Assert(app.SelectedImage = first, "Next wraps")
  FileCopy(root "\images\one.PNG", root "\images\new.png")
  beforeAddition := app.SelectedImage
  app.ChangeNowForce(1)
  Assert(app.Images.Length = 3, "New images are discovered on the next change")
  app.ChangeNowForce(-1)
  Assert(app.SelectedImage = beforeAddition, "Navigation follows the current path after an addition")
  Loop 5
    FileCopy(root "\images\one.PNG", root "\images\extra-" A_Index ".png")
  app.ChangeNowForce(1)
  cycleStart := app.SelectedImage
  visited := Map()
  Loop app.Images.Length {
    app.ChangeNowForce(1)
    Assert(!visited.Has(app.SelectedImage), "No repeats within a full cycle")
    visited[app.SelectedImage] := true
  }
  Assert(app.SelectedImage = cycleStart && visited.Count = 8, "Cycle visits every image and wraps")
  originalOrder := app.Images.Clone()
  ; Recreate a file to change directory enumeration without changing the file set.
  FileDelete(root "\images\extra-1.png")
  FileCopy(root "\images\one.PNG", root "\images\extra-1.png")
  app.ScanFiles()
  for index, path in originalOrder
    Assert(app.Images[index] == path, "Filesystem enumeration does not affect order")
  FileDelete(app.SelectedImage)
  app.ChangeNowForce(1)
  Assert(app.Images.Length = 7 && app.SelectedImage = app.Images[1], "Deleted current image falls back to first surviving image")
  FileCopy(root "\output\Wallpaper.bmp", root "\images\original.bmp")
  app.ApplyWallpaper(root "\images\original.bmp")
  app.ScanFiles()
  for path in app.Images
    FileDelete(path)
  emptyFolderError := false
  try app.ChangeNowForce(1)
  catch as err
    emptyFolderError := InStr(err.Message, "No supported wallpapers") > 0
  Assert(emptyFolderError && !app.InTheMiddle, "Empty folder reports an error and releases the busy state")
  fixtureFile := FileOpen(root "\images\recovered.png", "w")
  fixtureFile.RawWrite(bytes)
  fixtureFile.Close()
  app.ChangeNowForce(1)
  Assert(app.Images.Length = 1, "Next change recovers when images return")
  app.ChangeNowForce(-1)
  Assert(app.SelectedImage = app.Images[1], "Single-image collection wraps safely")
  app.ShortcutFile := root "\startup.lnk"
  app.ToggleStartup()
  FileGetShortcut(app.ShortcutFile, &shortcutTarget, &shortcutDir, &shortcutArgs)
  Assert(shortcutTarget = A_AhkPath && shortcutArgs = app.Quote(A_ScriptFullPath), "Startup shortcut explicitly uses v2")
  Assert(shortcutDir = A_ScriptDir, "Startup shortcut working directory")
  app.ToggleStartup()
  Assert(!FileExist(app.ShortcutFile), "Startup shortcut toggle removes shortcut")
  ; Also construct the tray menus with hotkeys enabled, without registering them.
  app.HotkeysEnabled := true
  app.BuildMenus()
  app.ChangeInterval("Off")
  Assert(app.Interval = 0 && IniRead(ini, "General", "Interval") = 0, "Off persists zero minutes")
  app.ChangeInterval("0.5 Minutes")
  Assert(app.Interval = 30000 && IniRead(ini, "General", "Interval") = 0.5, "Interval persists in minutes")
  app.SuspendToggle()
  Assert(!app.Suspended, "Resume clears pause")
  app.SuspendToggle()
  Assert(app.Suspended && IniRead(ini, "General", "Paused") = 1, "Pause persists")
  app.Interval := 100
  app.Suspended := false
  appliedCount := app.AppliedCount
  app.SetNewInterval()
  Sleep(350)
  Assert(app.AppliedCount > appliedCount, "Automatic timer advances wallpaper")
  app.SuspendToggle()
  appliedCount := app.AppliedCount
  Sleep(250)
  Assert(app.AppliedCount = appliedCount, "Pause stops automatic timer")
  ; Exercise both accept and cancel of the migrated GUI using its own controls.
  SetTimer((*) => ControlClick("Button5", "Hotkey ahk_class AutoHotkeyGUI"), -200)
  Assert(SelectHotkey("+#F5") = "+#F5", "Hotkey dialog accepts existing combination")
  SetTimer((*) => ControlClick("Button6", "Hotkey ahk_class AutoHotkeyGUI"), -200)
  Assert(SelectHotkey("^!A") = "^!A", "Hotkey dialog cancels without changing combination")
  FileAppend("PASS: deterministic rescans, additions/deletions, complete cycles, empty-folder recovery, navigation, conversion, timers, INI, shortcuts, menus, hotkey dialog.`n", "*")
} catch as err {
  FileAppend("FAIL: " err.Message " (line " err.Line ")`n" err.Stack "`n", "**")
  ExitApp(1)
} finally {
  if IsSet(app)
    SetTimer(app.TimerCallback, 0)
  DirDelete(root, true)
}
ExitApp()
