#Requires AutoHotkey v2.0
SetWorkingDir(A_ScriptDir)

; Compile with the same v2 runtime that is running this script.
exitCode := RunWait('"' A_AhkPath '" "' A_ScriptDir '\Compile.ahk"')
if exitCode != 0
  throw Error("Compilation failed (exit code " exitCode ").")

files := ["Wallpaper Randomizer.exe", "Wallpaper Randomizer.ini", "README.md", "CHANGELOG.md", "LICENSE"]
sources := ""
for name in files {
  if !FileExist(name)
    throw Error("Missing release file: " name)
  sources .= (sources = "" ? "" : ",") "'" name "'"
}

DirCreate("Release")
; Build a temporary archive so a failed build leaves the previous ZIP intact.
temporaryZip := "Release\wallpaper-randomizer.tmp.zip"
command := "$ErrorActionPreference = 'Stop'; Compress-Archive -LiteralPath " sources " -DestinationPath '" temporaryZip "' -Force"
try {
  exitCode := RunWait('powershell.exe -NoProfile -NonInteractive -Command "' command '"', A_ScriptDir, "Hide")
  if exitCode != 0
    throw Error("ZIP creation failed (exit code " exitCode ").")
  FileMove(temporaryZip, "Release\wallpaper-randomizer.zip", true)
} finally {
  if FileExist(temporaryZip)
    FileDelete(temporaryZip)
}
