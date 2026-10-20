#Requires AutoHotkey v2.0
SetWorkingDir(A_ScriptDir)
compiler := "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
base := A_AhkPath
if !FileExist(compiler)
  throw Error("Unable to find the AutoHotkey compiler: " compiler)
IniWrite("", "Wallpaper Randomizer.ini", "General", "ImageDir")
IniWrite(1, "Wallpaper Randomizer.ini", "General", "ShowTraytip")
exitCode := RunWait('"' compiler '" /in "Wallpaper Randomizer.ahk" /out "Wallpaper Randomizer.exe" /icon "W.ico" /base "' base '"')
if exitCode != 0
  throw Error("Compilation failed (exit code " exitCode ").")
