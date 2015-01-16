SetWorkingDir %A_ScriptDir%
FileDelete Wallpaper Randomizer.exe
IniWrite % "", Wallpaper Randomizer.ini, General, ImageDir
IniWrite 1, Wallpaper Randomizer.ini, General, ShowTraytip
RunWait "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "Wallpaper Randomizer.ahk" /out "Wallpaper Randomizer.exe" /icon "W.ico"
