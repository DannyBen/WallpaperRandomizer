================================================================================

    Wallpaper Randomizer 0.40
    System Tray Wallpaper Changer
    
    Danny Ben Shitrit (Sector-Seven) 2011
    Homepage: http://sector-seven.net
    Email   : db@sector-seven.net
    
    Contributors: 
    Ashus - http://ashus.ashus.net/
    
    License: MIT
    
================================================================================


Introduction
-----------------------------
  Wallpaper Randomizer is a small system tray wallpaper changer.
  It lets you:
    • See a different wallpaper whenever you start Windows.
    • Change wallpaper on regular intervals.
    • Change wallpaper using a hotkey.
    
  When running it for the first time, you will be prompted to specify where is 
  your photos or wallpapers directory.
  
  Wallpaper Randomizer is completely unobstrusive. 
  It requires no installation, has no user interface and does not write anything
  in the registry - All functions are controlled through the system tray menu.
  
  You can enable or disable Walllpaper Randomizer at any time.
  
  Supported image formats: BMP, PNG, JPG and GIF.
  
Technical Notes
-----------------------------
  Wallpaper Randomizer uses the ToPNG command line utility 
  (http://www.bcheck.net/) which is included in the downloaded package.
  
    
  
Revision History
-----------------------------
  0.40  2011 07 05
    Added  : Support for relative paths.
    Added  : Open Configuration File menu item.

  0.39  2011 06 01
    Added  : Configuration dialog for hotkeys.
    Added  : Configuration to allow disabling hotkeys altogether.

  0.38  2011 03 27
    Fixed  : Now allowing refresh interval lower than one minute.

  0.37  2011 02 04
    Changed: Additional memory footprint improvement (thanks Ashus).
    Added  : Menu option to open, edit or view the properties of the current
             wallpaper (thanks Ashus).
    Added  : Temporary folder where the BMP is created may now be modified 
             in the INI file (thanks Ashus).
    Added  : Intervals menu can now be configured in the INI file.

  0.36  2011 02 02
    Changed: Loading time and memory footprint significantly improved for 
             large folders (thanks Ashus).
  
  0.35  2009 10 04
    Changed: Recompiled with newer AutoHotkey due to false positives reported
             by some antivirus programs.

  0.34  2009 09 24
    Fixed  : Will now abort gracefully if topng is not found.
    Fixed  : BMP wallpapers were not handled properly.

  0.33  2009 09 08
    Changed: topng.exe is no longer compiled into the executable, instead it is
             provided as is in the ZIP file. Some Vista users reported the 
             automatic extraction did not work.

  0.32  2009 09 04
    Fixed  : Random order of wallpapers is now more random.
    Changed: Recompiled with newer AutoHotkey version.

  0.31  2009 03 12
    Fixed  : Startup shortcut did not work when OS language was not English.

  0.30  2009 01 04
    Removed: Installer
    Removed: Open INI from tray menu
    Added  : Run on Startup menu option

  0.22  2008 12 25
    Removed: LiveUpdate
    Changed: Installer to Young
    Added  : Open INI file in the menu
    Added  : Select primary folder in the menu
    Added  : Now asking for a folder on first run

  0.20  2007 02 18
    Fixed  : unexpected behaviour, probably caused by unstable AutoHotkey 
             build - no change was done in the code, but this version is
             compiled with AHK 1.0.46 instead of 1.0.46.08
    
  0.19  2007 02 01
    Added  : Shift+Win+F5 shortcut for Previous Wallpaper
    
  0.18  2007 01 31
    Changed: wallpapers are now stored in a random order and are displayed
             sequentially, as opposed to just generate a random wallpaper
             from a list. this prevents the same wallpaper to appear twice,
             unless the entire list was displayed already.
  
  0.17  2007 01 14
    Added  : the state of the Pause option is now stored in the INI file. 
             this is useful if you only want Wallpaper Randomizer to change
             your wallpaper upon system start.
             You may still unpause it, or use the Refresh Now option to 
             change the wallpaper.
    Updated: installer

  0.16  2006 10 06
    Changed: compiled with new LiveUpdate version - now if no internet 
             connection, we will park and retry every 10 minutes, until 
             a connection is established
    
  0.15  2006 09 18
    Added  : Refresh Interval menu in tray icon
    Changed: Now when scanning files, some menu items are disabled
    
  0.14  2006 09 17
    Added  : now showing current wallpaper name in About box
    
  0.13  2006 09 17
    Changed: tray icon
    Added  : number of loaded wallpapers to system tray and about box
    Added  : Check for Updates menu item
    
  0.12  2006 09 16
    Changed: now supporting multiple folders
    
  0.11  2006 09 15
    Changed: Now scanning subfolders as well
    Changed: Now scanning folder only on the first run
    Removed: Sleep time before changing to new image. Was there to let the 
             OS recognize the new file, seems to be working fine without it.
    
  0.10  2006 09 15
    First Version
  
  
================================================================================
  