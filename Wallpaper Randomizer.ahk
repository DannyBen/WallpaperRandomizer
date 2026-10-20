#Requires AutoHotkey v2.0
#SingleInstance Force

; Wallpaper Randomizer - Danny Ben Shitrit (Sector-Seven)
; Homepage: https://sector-seven.com
; Contributors: Ashus - http://ashus.ashus.net/
; Rescan on each change; one seed per launch keeps unchanged files in order.
if A_IsCompiled || A_LineFile = A_ScriptFullPath {
  Persistent()
  WallpaperRandomizer().Start()
}

class WallpaperRandomizer {
  VersionString := "0.50"
  NameString := "Wallpaper Randomizer"
  AuthorString := "Danny Ben Shitrit (Sector-Seven)"
  Images := []
  SelectedImageIndex := 0
  SelectedImage := ""
  InTheMiddle := false
  ShuffleSeed := Random(1, 0xFFFFFFFF)
  Loading := false

  __New(iniFile := "") {
    SetWorkingDir(A_ScriptDir)
    this.IniFile := iniFile != "" ? iniFile : A_ScriptDir "\" this.NameString ".ini"
    this.ShortcutFile := A_Startup "\" this.NameString ".lnk"
    this.Interval := this.Read("Interval", 10) * 60000
    this.Suspended := this.Read("Paused", 0) + 0
    this.ImageDir := this.Read("ImageDir", "")
    this.ShowTraytip := this.Read("ShowTraytip", 1) + 0
    this.IntervalString := this.Read("Intervals", "2,5,10,15,20,30,45,60,90,120,180,240")
    this.TempDir := this.ExpandPath(this.Read("TempDir", A_ScriptDir))
    if !DirExist(this.TempDir)
      this.TempDir := A_ScriptDir
    this.HotkeyNext := this.Read("HotkeyNext", "#F5")
    this.HotkeyPrev := this.Read("HotkeyPrev", "+#F5")
    this.HotkeysEnabled := this.Read("HotkeysEnabled", 1) + 0
    ; Keep the same callback objects for timer updates and cancellation.
    this.TimerCallback := ObjBindMethod(this, "ChangeNow", 1)
    this.IntervalCallback := ObjBindMethod(this, "SetNewInterval")
    this.ExitCallback := ObjBindMethod(this, "Exit")
    this.AboutCallback := ObjBindMethod(this, "About")
  }

  Read(key, default) => IniRead(this.IniFile, "General", key, default)
  Write(key, value) => IniWrite(value, this.IniFile, "General", key)
  Callback(method, args*) => ObjBindMethod(this, method, args*)
  Quote(path) => '"' path '"'

  ExpandPath(path) {
    path := StrReplace(path, "%A_ScriptDir%", A_ScriptDir)
    path := StrReplace(path, "%A_Temp%", A_Temp)
    path := StrReplace(path, "%A_WorkingDir%", A_WorkingDir)
    ; Preserve support for environment variables in the old TempDir setting.
    while RegExMatch(path, "%([^%]+)%", &match) {
      value := EnvGet(match[1])
      path := StrReplace(path, match[0], value)
    }
    return path
  }

  Start() {
    if !FileExist("topng.exe")
      this.Fatal("Unable to find a required file: topng.exe`nAborting")
    this.BuildMenus()
    if this.HotkeysEnabled {
      Hotkey(this.HotkeyNext, this.Callback("ChangeNowForce", 1))
      Hotkey(this.HotkeyPrev, this.Callback("ChangeNowForce", -1))
    }
    if FileExist("W.ico")
      TraySetIcon("W.ico")
    A_IconTip := this.NameString " " this.VersionString " - Loading..."
    this.CheckStartupState()
    if !DirExist(this.ImageDir) {
      this.SelectFolder()
      ExitApp()
    }
    if this.ShowTraytip {
      this.Write("ShowTraytip", 0)
      TrayTip("Right click here for help and options", this.NameString " " this.VersionString, 1)
    }
    this.ChangeNowForce(1)
  }

  BuildMenus() {
    this.RefreshInterval := Menu()
    this.RefreshInterval.Add("Off", this.Callback("ChangeInterval"))
    this.RefreshInterval.Add()
    for minutes in StrSplit(this.IntervalString, ",")
      this.RefreshInterval.Add(Trim(minutes) " Minutes", this.Callback("ChangeInterval"))
    this.IntervalMenuItem := this.Interval > 0 ? Format("{:g}", this.Interval / 60000) " Minutes" : "Off"
    if this.Interval > 0
      this.RefreshInterval.Add(this.IntervalMenuItem, this.Callback("ChangeInterval"))
    this.RefreshInterval.Check(this.IntervalMenuItem)

    this.CurrentImageMenu := Menu()
    for action in ["Open", "Edit", "Properties"]
      this.CurrentImageMenu.Add(action, this.Callback("ImageAction", action))
    this.HotkeySetup := Menu()
    this.HotkeySetup.Add("Enable Hotkeys", this.Callback("HotkeysToggle"))
    this.HotkeySetup.Add("Next Hotkey...", this.Callback("SelectHotkeySetting", "HotkeyNext"))
    this.HotkeySetup.Add("Previous Hotkey...", this.Callback("SelectHotkeySetting", "HotkeyPrev"))
    if this.HotkeysEnabled
      this.HotkeySetup.Check("Enable Hotkeys")

    tray := A_TrayMenu
    tray.Delete()
    this.NextMenuItem := "Next Wallpaper`t" GetHotkeyDisplayString(this.HotkeyNext)
    this.PrevMenuItem := "Previous Wallpaper`t" GetHotkeyDisplayString(this.HotkeyPrev)
    if this.HotkeysEnabled {
      tray.Add(this.NextMenuItem, this.Callback("ChangeNowForce", 1))
      tray.Add(this.PrevMenuItem, this.Callback("ChangeNowForce", -1))
      tray.Add()
      tray.Default := this.NextMenuItem
    }
    tray.Add("Current Image", this.CurrentImageMenu)
    tray.Disable("Current Image")
    tray.Add()
    tray.Add("Refresh Interval", this.RefreshInterval)
    tray.Add("Pause", this.Callback("SuspendToggle"))
    if this.Suspended
      tray.Check("Pause")
    tray.Add()
    tray.Add("Select Image Folder...", this.Callback("SelectFolder"))
    tray.Add("Customize Hotkeys", this.HotkeySetup)
    tray.Add("Open Configuration File...", this.Callback("OpenIni"))
    tray.Add()
    tray.Add("Run " this.NameString " on Startup", this.Callback("ToggleStartup"))
    tray.Add()
    tray.Add("Visit Sector-Seven", (*) => Run("https://sector-seven.com"))
    tray.Add("About " this.NameString "...", this.AboutCallback)
    tray.Add("Exit " this.NameString, this.ExitCallback)
  }

  SuspendToggle(*) {
    this.Suspended := !this.Suspended
    if this.Suspended {
      SetTimer(this.TimerCallback, 0)
      A_TrayMenu.Check("Pause")
    } else {
      this.ChangeNowForce(1)
      A_TrayMenu.Uncheck("Pause")
    }
    this.Write("Paused", this.Suspended)
  }

  SetNewInterval(*) {
    if this.InTheMiddle {
      SetTimer(this.IntervalCallback, -1000)
      return
    }
    SetTimer(this.IntervalCallback, 0)
    SetTimer(this.TimerCallback, this.Interval > 0 && !this.Suspended ? this.Interval : 0)
  }

  ChangeNowForce(direction, *) {
    if this.InTheMiddle
      return
    this.ChangeNow(direction)
    this.SetNewInterval()
  }

  ChangeNow(direction, *) {
    if this.InTheMiddle
      return
    this.InTheMiddle := true
    try {
      menuItems := ["Refresh Interval", "Pause", "About " this.NameString "...", "Select Image Folder...", "Run " this.NameString " on Startup", "Customize Hotkeys"]
      if this.HotkeysEnabled
        menuItems.Push(this.NextMenuItem, this.PrevMenuItem)
      for item in menuItems
        A_TrayMenu.Disable(item)
      try this.ScanFiles()
      finally {
        for item in menuItems
          A_TrayMenu.Enable(item)
      }
      if !this.Images.Length
        throw Error("No supported wallpapers were found in the selected folder.")
      ; Follow the current image if its position changed. If it was deleted
      ; (or this is startup), begin at the first image of the shuffled list.
      this.SelectedImageIndex := 1
      for index, path in this.Images {
        if path = this.SelectedImage {
          this.SelectedImageIndex := Mod(index - 1 + direction + this.Images.Length, this.Images.Length) + 1
          break
        }
      }
      this.SelectedImage := this.Images[this.SelectedImageIndex]
      this.ApplyWallpaper(this.SelectedImage)
      A_TrayMenu.Enable("Current Image")
      SplitPath(this.SelectedImage, &fileName, &directory)
      SplitPath(directory, &folderName)
      A_IconTip := this.NameString " " this.VersionString " - " this.Images.Length " Wallpapers Loaded`nCurrently showing:`n" folderName " > " fileName
    } catch as err {
      this.ReportError(err)
    } finally {
      this.InTheMiddle := false
    }
  }

  ReportError(err) {
    MsgBox(err.Message, this.NameString, 16)
  }

  ScanFiles() {
    this.Loading := true
    try {
      paths := ""
      Loop Files this.ImageDir "\*.*", "FR" {
        if !RegExMatch(A_LoopFileExt, "i)^(bmp|png|jpg|gif)$")
          continue
        paths .= A_LoopFileFullPath "`n"
      }
      ; Sort first so filesystem enumeration order cannot change the shuffle.
      paths := RTrim(paths, "`n")
      this.Images := paths = "" ? [] : StrSplit(Sort(paths, "C"), "`n")
      seed := this.ShuffleSeed
      Loop this.Images.Length {
        ; Local 32-bit generator: restart from the session seed on every scan.
        seed := (1664525 * seed + 1013904223) & 0xFFFFFFFF
        index := Mod(seed, A_Index) + 1
        image := this.Images[A_Index]
        this.Images[A_Index] := this.Images[index]
        this.Images[index] := image
      }
    } finally {
      this.Loading := false
    }
  }

  ApplyWallpaper(selectedImage) {
    SplitPath(selectedImage, , , &extension)
    extension := StrLower(extension)
    newImage := this.TempDir "\Wallpaper." extension
    FileCopy(selectedImage, newImage, true)
    if extension != "bmp" {
      if !FileExist("topng.exe")
        throw Error("Unable to find a required file: topng.exe")
      exitCode := RunWait(this.Quote(A_ScriptDir "\topng.exe") " " this.Quote(newImage) " BMP", this.TempDir, "Hide")
      if exitCode != 0
        throw Error("Image conversion failed (exit code " exitCode ").")
      FileDelete(newImage)
    }
    finalPaper := this.TempDir "\Wallpaper.bmp"
    Sleep(100)
    this.SetWallpaper(finalPaper)
  }

  SetWallpaper(finalPaper) {
    if !DllCall("SystemParametersInfoW", "UInt", 0x14, "UInt", 0, "Str", finalPaper, "UInt", 1)
      throw OSError()
  }

  ChangeInterval(itemName, *) {
    this.RefreshInterval.Uncheck(this.IntervalMenuItem)
    this.IntervalMenuItem := itemName
    this.RefreshInterval.Check(itemName)
    minutes := itemName = "Off" ? 0 : StrSplit(itemName, " ")[1] + 0
    this.Write("Interval", minutes)
    this.Interval := minutes * 60000
    this.SetNewInterval()
  }

  About(*) {
    if this.InTheMiddle {
      SetTimer(this.AboutCallback, -1000)
      return
    }
    MsgBox(this.NameString " " this.VersionString "`t`t`n" this.AuthorString "`n`n" this.Images.Length " wallpapers loaded`n`nNow Showing:`n" this.SelectedImage, this.NameString, 64)
  }

  OpenIni(*) {
    if MsgBox("Editing the configuration file manually is not recommended unless you know what you are doing.`nIf you choose to edit these settings, you may need to restart Wallpaper Randomizer before your changes are reflected.`n`nOpen configuration file?", "Open Configuration File", 36) = "Yes"
      Run(this.Quote(this.IniFile))
  }

  ImageAction(action, *) {
    Run((action = "Open" ? "" : "*" action " ") this.Quote(this.SelectedImage))
  }

  SelectFolder(*) {
    folder := DirSelect("*" this.ImageDir, 0, "Select the folder containing your wallpapers.`nWallpapers can be in BMP, JPG, GIF or PNG format.`nTo set a relative path edit the configuration file manually.")
    if folder != "" {
      this.Write("ImageDir", folder)
      this.Write("ShowTraytip", 1)
      Reload()
    }
  }

  CheckStartupState() {
    item := "Run " this.NameString " on Startup"
    if FileExist(this.ShortcutFile)
      A_TrayMenu.Check(item)
    else
      A_TrayMenu.Uncheck(item)
  }

  ToggleStartup(*) {
    if FileExist(this.ShortcutFile)
      FileDelete(this.ShortcutFile)
    else if A_IsCompiled
      FileCreateShortcut(A_ScriptFullPath, this.ShortcutFile, A_ScriptDir)
    else
      FileCreateShortcut(A_AhkPath, this.ShortcutFile, A_ScriptDir, this.Quote(A_ScriptFullPath))
    this.CheckStartupState()
  }

  HotkeysToggle(*) {
    this.Write("HotkeysEnabled", !this.HotkeysEnabled)
    Reload()
  }

  SelectHotkeySetting(setting, *) {
    newKey := SelectHotkey(this.%setting%)
    if newKey != this.%setting% {
      this.Write(setting, newKey)
      Reload()
    }
  }

  Exit(*) {
    if this.InTheMiddle && !this.Loading
      SetTimer(this.ExitCallback, -1000)
    else
      ExitApp()
  }

  Fatal(message) {
    MsgBox("An error has occurred.`n" message, "Error", 16)
    ExitApp(1)
  }
}

SelectHotkey(originalKey := "") {
  keys := StrSplit("A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|1|2|3|4|5|6|7|8|9|0|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|~|-|=|[|]|;|'|\|,|.|/|Home|End|Insert|Delete|PgUp|PgDn|Backspace", "|")
  dialog := Gui(, "Hotkey")
  dialog.MarginX := 10
  dialog.MarginY := 10
  ctrl := dialog.AddCheckbox("w40", "Ctrl")
  shift := dialog.AddCheckbox("xp y+8 w40", "Shift")
  alt := dialog.AddCheckbox("xp y+8 w40", "Alt")
  win := dialog.AddCheckbox("xp y+8 w40", "Win")
  ctrl.Value := InStr(originalKey, "^") > 0
  shift.Value := InStr(originalKey, "+") > 0
  alt.Value := InStr(originalKey, "!") > 0
  win.Value := InStr(originalKey, "#") > 0
  keyList := dialog.AddListBox("x80 y10 w100 r6", keys)
  keyList.Choose(RegExReplace(originalKey, "[!+^#]", ""))
  accepted := false
  dialog.AddButton("x10 y+10 w80 Default", "OK").OnEvent("Click", Save)
  dialog.AddButton("x+10 yp wp", "Cancel").OnEvent("Click", Cancel)
  dialog.OnEvent("Escape", Cancel)
  dialog.OnEvent("Close", Cancel)
  dialog.Show()
  WinWaitClose("ahk_id " dialog.Hwnd)
  result := originalKey
  if accepted
    result := (ctrl.Value ? "^" : "") (shift.Value ? "+" : "") (alt.Value ? "!" : "") (win.Value ? "#" : "") keyList.Text
  dialog.Destroy()
  return result

  Save(*) {
    accepted := true
    dialog.Hide()
  }
  Cancel(*) {
    dialog.Hide()
  }
}

GetHotkeyDisplayString(hotkeyString) {
  result := StrReplace(hotkeyString, "^", "Ctrl@")
  result := StrReplace(result, "!", "Alt@")
  result := StrReplace(result, "#", "Win@")
  result := StrReplace(result, "+", "Shift@")
  return StrReplace(result, "@", "+")
}
