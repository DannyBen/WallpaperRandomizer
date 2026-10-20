#Requires AutoHotkey v2.0
root := A_Temp "\WallpaperRandomizer-compiled-" DllCall("GetCurrentProcessId")
DirCreate(root)
try {
  FileCopy(A_ScriptDir "\Wallpaper Randomizer.exe", root "\Wallpaper Randomizer.exe")
  FileCopy(A_ScriptDir "\topng.exe", root "\topng.exe")
  Run('"' root '\Wallpaper Randomizer.exe"', root, , &pid)
  dialog := WinWait("ahk_class #32770 ahk_pid " pid, , 5)
  if !dialog
    throw Error("Compiled app did not show its first-run folder picker")
  FileAppend("PASS: compiled executable reaches first-run folder picker.`n", "*")
  WinClose(dialog)
  ProcessWaitClose(pid, 5)
  if ProcessExist(pid)
    throw Error("Compiled app did not exit after cancelling first-run setup")
  FileAppend("PASS: cancelling setup exits cleanly.`n", "*")
} catch as err {
  FileAppend("FAIL: " err.Message "`n", "**")
  ExitApp(1)
} finally {
  DirDelete(root, true)
}
