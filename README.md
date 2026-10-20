# Wallpaper Randomizer

A small Windows system tray utility that changes your desktop wallpaper on a
schedule or with a hotkey. No installation is required; controls live in the
tray menu.

## Features

- Change wallpaper when Windows starts, at regular intervals, or on demand.
- Browse a randomized list with Next and Previous, with wraparound.
- Include images from subfolders.
- Pause automatic changes while keeping manual navigation available.
- Customize hotkeys and refresh intervals.
- Open, edit, or view properties of the current image.
- Enable or disable running at Windows startup.

Supported image formats: BMP, PNG, JPG, and GIF.

## Getting started

Keep `Wallpaper Randomizer.exe` and `topng.exe` in the same folder, then run
`Wallpaper Randomizer.exe`. On first launch, select your wallpaper folder.
Right-click the tray icon for settings and other actions.

The compiled executable does not require AutoHotkey to be installed. To run the
source instead, use AutoHotkey v2.0 or later and keep `topng.exe` beside the script.

Default hotkeys:

| Action | Hotkey |
| --- | --- |
| Next wallpaper | Win+F5 |
| Previous wallpaper | Shift+Win+F5 |

A new shuffled list is built each time the app starts. Next and Previous move
through that same list. The folder is scanned only at startup: restart the app
to pick up added or removed images.

## Configuration

Settings are saved in `Wallpaper Randomizer.ini` beside the application. Most
settings can be changed through the tray menu. Manual INI edits require a restart.

- `Interval` is in minutes: `0.5` means 30 seconds; `0` disables automatic changes.
- `ImageDir` can be an absolute path or a path relative to the application folder.
- `Intervals` sets the comma-separated list of intervals shown in the tray menu.
- `TempDir` sets the folder used for BMP conversion. It supports `%A_Temp%` and
  `%A_ScriptDir%`.
- `HotkeyNext`, `HotkeyPrev`, and `HotkeysEnabled` control keyboard shortcuts.

Image conversion uses the bundled [ToPNG utility](http://www.bcheck.net/).

## Building

Install AutoHotkey v2 and Ahk2Exe, then run `Compile.ahk` with v2. The build script
expects the compiler at `C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe` and uses
the running v2 interpreter as its compiler base.

Building clears `ImageDir` and resets `ShowTraytip` in the local INI so the next
launch prompts for an image folder. Other settings are retained.

## Checks

Run these scripts with AutoHotkey v2:

- `Test.ahk` checks shuffled navigation, image conversion, intervals, pause,
  configuration, menus, startup shortcuts, and the hotkey dialog.
- `TestCompiled.ahk` checks the built executable's first-run folder picker and
  clean exit when setup is cancelled. Run `Compile.ahk` first.

The checks use temporary fixtures and do not change your desktop wallpaper or
application settings. The compiled check briefly opens the folder picker.

## History and credits

See [CHANGELOG.md](CHANGELOG.md) for release history and unreleased changes.

Created by Danny Ben Shitrit ([Sector-Seven](https://sector-seven.com/)).
Contributions by [Ashus](http://ashus.ashus.net/).

Released under the [MIT license](LICENSE).
