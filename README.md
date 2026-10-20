# Wallpaper Randomizer

A small Windows system tray utility that changes your desktop wallpaper on a
schedule or with a hotkey. No installation is required; controls live in the
tray menu.

## Features

- Change wallpaper when Windows starts, at regular intervals, or on demand.
- Browse a randomized list with Next and Previous, with wraparound.
- Include images from subfolders.
- Discover added and removed images before every wallpaper change.
- Pause automatic changes while keeping manual navigation available.
- Customize hotkeys and refresh intervals.
- Open, edit, or view properties of the current image.
- Enable or disable running at Windows startup.

Supported image formats: BMP, PNG, JPG, and GIF.

## Getting started

Run `Wallpaper Randomizer.exe`. On first launch, select your wallpaper folder.
Right-click the tray icon for settings and other actions.

Requires Windows 8 or later. The compiled executable needs no additional tools.
To run the source instead, use AutoHotkey v2.0 or later.

Default hotkeys:

| Action | Hotkey |
| --- | --- |
| Next wallpaper | Win+F5 |
| Previous wallpaper | Shift+Win+F5 |

The folder and its subfolders are scanned before every wallpaper change. One
random seed per launch keeps the shuffled order identical while the file list
stays unchanged. Next and Previous walk that order with wraparound, visiting
every image once per cycle.

Adding, removing, or renaming files can change the order. Navigation continues
from the current image's new position; if it was deleted, the first image in the
rebuilt list is shown. Restarting the app creates a new shuffle seed.

## Configuration

Settings are saved in `Wallpaper Randomizer.ini` beside the application. Most
settings can be changed through the tray menu. Manual INI edits require a restart.

- `Interval` is in minutes: `0.5` means 30 seconds; `0` disables automatic changes.
- `ImageDir` can be an absolute path or a path relative to the application folder.
- `Intervals` sets the comma-separated list of intervals shown in the tray menu.
- `HotkeyNext`, `HotkeyPrev`, and `HotkeysEnabled` control keyboard shortcuts.

Images are loaded directly through the native Windows wallpaper API, without
conversion or temporary BMP files. The old `TempDir` setting is no longer used;
existing INI files remain compatible.

## Building

Install AutoHotkey v2 and Ahk2Exe, then run `Compile.ahk` with v2. The build script
expects the compiler at `C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe` and uses
the running v2 interpreter as its compiler base.

Building clears `ImageDir` and resets `ShowTraytip` in the local INI so the next
launch prompts for an image folder. Other settings are retained.

## Release ZIP

Run `Release.ahk` with AutoHotkey v2 to compile the app and create
`Release\wallpaper-randomizer.zip`. ZIP creation uses Windows PowerShell.
An existing release ZIP is replaced only after the new archive is created.

The ZIP contains `Wallpaper Randomizer.exe`, `Wallpaper Randomizer.ini`,
`README.md`, `CHANGELOG.md`, and `LICENSE` at its top level.
The INI comes from the local build, so review its settings before distributing.

## History and credits

See [CHANGELOG.md](CHANGELOG.md) for release history.

Created by Danny Ben Shitrit ([Sector-Seven](https://sector-seven.com/)).
Contributions by [Ashus](http://ashus.ashus.net/).

Released under the [MIT license](LICENSE).
