#Requires AutoHotkey v1.1.33+
SetWorkingDir %A_ScriptDir%
FileDelete Wallpaper Randomizer.exe
IniWrite % "", Wallpaper Randomizer.ini, General, ImageDir
IniWrite 1, Wallpaper Randomizer.ini, General, ShowTraytip
RunWait "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "Wallpaper Randomizer.ahk" /out "Wallpaper Randomizer.exe" /icon "W.ico" /base "C:\Program Files\AutoHotkey\Compiler\Unicode 64-bit.bin"
