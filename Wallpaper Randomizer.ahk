;===============================================================================
;
;   Wallpaper Randomizer
;   System Tray Wallpaper Changer
;
;   Danny Ben Shitrit (Sector-Seven) 2011
;   Homepage: http://sector-seven.net
;   Email: db@sector-seven.net
;
;   Contributors: 
;     Ashus - http://ashus.ashus.net/
; 
;===============================================================================
VersionString = 0.40
NameString    = Wallpaper Randomizer
AuthorString  = Danny Ben Shitrit (Sector-Seven)

#SingleInstance force
#Persistent

Gosub Init
Gosub Main

Return

;-------------------------------------------------------------------------------
; MAINS
;-------------------------------------------------------------------------------
Init:
  ; Some settings
  StringCaseSense Off
  SetWorkingDir %A_ScriptDir%

  If( !FileExist( "topng.exe" ) )
    Error( "Unable to find a required file: topng.exe`nAborting" )
  
  FirstRun := true
  MSEC_PER_MIN := 60000
  
  ShortcutFile := A_Startup . "\" . NameString . ".lnk"
  
  ; Read INI
  IniFile = %A_ScriptDir%\%NameString%.ini
  IniRead Interval,       %IniFile%, General, Interval, 10
  IniRead Suspended,      %IniFile%, General, Paused, 0
  IniRead ImageDir,       %IniFile%, General, ImageDir
  IniRead ShowTraytip,    %IniFile%, General, ShowTrayTip
  IniRead IntervalString, %IniFile%, General, Intervals, % "2,5,10,15,20,30,45,60,90,120,180,240"
  IniRead TempDir,        %IniFile%, General, TempDir, %A_ScriptDir%
  IniRead HotkeyNext,     %IniFile%, General, HotkeyNext, #F5
  IniRead HotkeyPrev,     %IniFile%, General, HotkeyPrev, +#F5
  IniRead HotkeysEnabled, %IniFile%, General, HotkeysEnabled, 1
  Transform TempDir, Deref, %TempDir%
  If( !IsDir( TempDir ) ) 
    TempDir := A_ScriptDir
    
  ; Hotkeys
  If( HotkeysEnabled ) {
    Hotkey %HotkeyNext%, ChangeNowForce
    Hotkey %HotkeyPrev%, ChangeNowForce2
    ; Get a representable string for each hotkey (for the menu)
    HotkeyNextString := GetHotkeyDisplayString( HotkeyNext )
    HotkeyPrevString := GetHotkeyDisplayString( HotkeyPrev )
  }
  
  ; Menus
  Menu RefreshInterval, Add, Off, ChangeInterval
  Menu RefreshInterval, Add
  Loop Parse, IntervalString, `,
    Menu RefreshInterval, Add, %A_LoopField% Minutes  , ChangeInterval
    
  Menu CurrentImageMenu, Add, Open, OpenImage
  Menu CurrentImageMenu, Add, Edit, EditImage
  Menu CurrentImageMenu, Add, Properties, PropertiesImage

  Menu HotkeySetup, Add, Enable Hotkeys, HotkeysToggle
  Menu HotkeySetup, Add, Next Hotkey..., SelectNextHotkey
  Menu HotkeySetup, Add, Previous Hotkey..., SelectPrevHotkey
  If( HotkeysEnabled )
    Menu HotkeySetup, Check, Enable Hotkeys
  
  Menu Tray, NoStandard
  If( HotkeysEnabled ) {
    Menu Tray, Add, Next Wallpaper`t%HotkeyNextString%, ChangeNowForce
    Menu Tray, Add, Previous Wallpaper`t%HotkeyPrevString%, ChangeNowForce2
    Menu Tray, Add
  }
  Menu Tray, Add, Current Image, :CurrentImageMenu
  Menu Tray, Add
  Menu Tray, Add, Refresh Interval, :RefreshInterval
  
  If( Interval > 0 ) {
    Menu RefreshInterval, Add, %Interval% Minutes, ChangeInterval
    Menu RefreshInterval, Check, %Interval% Minutes 
  }
  Else
    Menu RefreshInterval, Check, Off
  
  Menu Tray, Add, Pause, SuspendToggle
  If( Suspended )
    Menu Tray, Check, Pause
    
  Interval := Interval * MSEC_PER_MIN
  
  Menu Tray, Add
  Menu Tray, Add, Select Image Folder..., SelectFolder
  Menu Tray, Add, Customize Hotkeys, :HotkeySetup
  Menu Tray, Add, Open Configuration File..., OpenIni
  Menu Tray, Add
  Menu Tray, Add, Run %NameString% on Startup, ToggleStartup
  Menu Tray, Add
  Menu Tray, Add, Visit Sector-Seven, VisitHomepage
  Menu Tray, Add, About %NameString%..., About
  Menu Tray, Add, Exit %NameString%, Exit
  
  If( HotkeysEnabled ) 
    Menu Tray, Default, Next Wallpaper`t%HotkeyNextString%
  
  IfExist W.ico
    Menu, Tray, Icon, W.ico
    
  Menu, Tray, Tip, %NameString% %VersionString% - Loading...
  
  Gosub CheckStartupState
Return


Main:
  If( ImageDir = "" or Not FileExist( ImageDir ) ) {
    Gosub SelectFolder  
    IniRead ImageDir, %IniFile%, General, ImageDir
    If( ImageDir = "" or Not FileExist( ImageDir ) )
      ExitApp
  }
  Else {
    If( ShowTraytip ) {
      IniWrite 0, %IniFile%, General, ShowTraytip
      Traytip %NameString% %VersionString%, Right click here for help and options, 20, 1      
    }
    Gosub ChangeNowForce
  }
Return

;-------------------------------------------------------------------------------
; PRIMARY EVENTS
;-------------------------------------------------------------------------------
SuspendToggle:
  If( Suspended ) {
    Gosub ChangeNowForce
    Menu, Tray, Uncheck, Pause
    Suspended := false
  }
  Else {
    SetTimer ChangeNow, Off
    Menu, Tray, Check, Pause
    Suspended := true
  }
  IniWrite %Suspended%, %IniFile%, General, Paused
Return


SetNewInterval:
  If( Not InTheMiddle ) {
    SetTimer SetNewInterval, Off
    If( Interval > 0 ) {
      If ( Not Suspended )
        SetTimer ChangeNow, %Interval%
    }
    Else
      SetTimer ChangeNow, Off     
    
  }
  Else
    SetTimer SetNewInterval, -1000
Return

ChangeNowForce:
  If( Not InTheMiddle ) {
    ChangeNow( 1 )
    If( Interval > 0 ) and ( Not Suspended )
      SetTimer ChangeNow, %Interval%
  }
Return

ChangeNowForce2:
  If( Not InTheMiddle ) {
    ChangeNow( -1 )
    If( Interval > 0 ) and ( Not Suspended )
      SetTimer ChangeNow, %Interval%
  }
Return

ChangeNow:
  ChangeNow( 1 )
Return


ChangeNow( direction ) {
  Global
  InTheMiddle := true
  MenuItems := "Refresh Interval,Pause,About " . NameString . "...,Select Image Folder...,Run " . NameString . " on Startup,Customize Hotkeys"
  If( HotkeysEnabled )
    MenuItems .= ",Next Wallpaper`t" . HotkeyNextString . ",Previous Wallpaper`t" . HotkeyPrevString
    
  If( FirstRun ) {
    Menu Tray, Disable, Current Image
    Loop Parse, MenuItems, `,
      Menu Tray, Disable, %A_LoopField%

    Gosub ScanFiles
    
    Loop Parse, MenuItems, `,
      Menu Tray, Enable, %A_LoopField%

    Random SelectedImageIndex , 1, %Counter%
  }
  Else {
    SelectedImageIndex += direction
    If( SelectedImageIndex > Counter )
      SelectedImageIndex := 1
    
    If( SelectedImageIndex < 1 )
      SelectedImageIndex := Counter
  }
  
  SelectedImage := ImageDir . "\" . Image%SelectedImageIndex%  
  
  StringRight Extension, SelectedImage, 3
  NewImage = %TempDir%\Wallpaper.%Extension%
  FileCopy %SelectedImage%, %NewImage%, 1
  
  If( Extension <> "bmp" ) {
    If( !FileExist( "topng.exe" ) )
      Error( "Unable to find a required file: topng.exe`nAborting" )
    RunWait topng.exe "%NewImage%" BMP,%TempDir%,Hide 
    FileDelete %NewImage%
    StringReplace NewImage, NewImage, .jpg, .bmp
    StringReplace NewImage, NewImage, .png, .bmp
    StringReplace NewImage, NewImage, .gif, .bmp
  }
  
  FileMove %NewImage%, %TempDir%\Wallpaper.bmp, 1
  Sleep 100
  
  FinalPaper := TempDir . "\Wallpaper.BMP"
  DllCall( "SystemParametersInfo", UInt, 0x14, UInt, 0, Str, FinalPaper, UInt, 1 )
  Menu Tray, Enable, Current Image
  
  SplitPath, SelectedImage, SelFn, SelDir
  SplitPath, SelDir, SelDir
  Menu, Tray, Tip, %NameString% %VersionString% - %Counter% Wallpapers Loaded`nCurrently showing:`n%SelDir% > %SelFn%
  
  InTheMiddle := false
}

ScanFiles:
  Loading := true
  Random Seed, 0, 10000000
  Random ,,%Seed%
  
  Loop %ImageDir%\*.*,0,1
  {
    SplitPath A_LoopFileLongPath,,, OutExtension
    If( OutExtension <> "bmp" and OutExtension <> "png" and OutExtension <> "jpg" and OutExtension <> "gif" )
      Continue
    Counter++

    If( Mod(Counter,100) = 0 ) 
      Menu, Tray, Tip, %NameString% %VersionString% - Loading (%Counter%)...

    Random Rnd , 1, %Counter%
    Image%Counter% := Image%Rnd%
    StringReplace ThisImage, A_LoopFileFullPath, %ImageDir%\
    Image%Rnd% := ThisImage
  }
  
  Menu, Tray, Tip, %NameString% %VersionString% - %Counter% Wallpapers Loaded
  Loading := false
  FirstRun := false
Return

ChangeInterval:
  If( Interval > 0 ) {
    Interval := Interval / MSEC_PER_MIN
    Interval := RegexReplace( Interval, "0+$", "" )
    Interval := RegexReplace( Interval, "\.$", "" )
    Menu RefreshInterval, Uncheck, %Interval% Minutes
  }
  Else
    Menu RefreshInterval, Uncheck, Off
    
  If( A_ThisMenuItem <> "Off" ) {
    StringSplit WorkArray, A_ThisMenuItem, %A_Space%
    Interval := WorkArray1  
    Menu RefreshInterval, Check, %Interval% Minutes
    IniWrite %Interval%, %IniFile%, General, Interval
    Interval := Interval * MSEC_PER_MIN
  }
  Else {
    Interval := 0
    Menu RefreshInterval, Check, Off
    IniWrite %Interval%, %IniFile%, General, Interval
  }
  
  Gosub SetNewInterval
Return


;-------------------------------------------------------------------------------
; SERVICES AND SECONDARY EVENTS
;-------------------------------------------------------------------------------
Error( ErrCode ) {
  MsgBox 16,Error,An error has occured.`n%ErrCode%
  ExitApp
}

IsDir( pathstring ) {
  If( pathstring == "" )
    Return false
    
  FileGetAttrib, Attributes, %pathstring%
  Return InStr( Attributes, "D" )
}

RemoveToolTip:
  SetTimer RemoveToolTip, Off
  ToolTip
Return

RemoveTrayTip:
  SetTimer RemoveTrayTip, Off
  TrayTip
Return

About:
  If( InTheMiddle ) 
    SetTimer About, 1000
  Else {
    SetTimer About, Off
    Msgbox 64, %NameString%, %NameString% %VersionString%`t`t`n%AuthorString%`n`n%Counter% wallpapers loaded`n`nNow Showing:`n%SelectedImage%
  }
Return

OpenIni:
  Msgbox 36, Open Configuration File, Editing the configuration file manually is not recommended unless you know what you are doing.`nIf you choose to edit these settings, you may need to restart Wallpaper Randomizer before your changes are reflected.`n`nOpen configuration file?
  IfMsgBox Yes
    Run %IniFile%
Return

OpenImage:
  Run %SelectedImage%
Return

EditImage:
  Run Edit %SelectedImage%
Return

PropertiesImage:
  Run Properties %SelectedImage%
Return

VisitHomepage:
  Run http://sector-seven.net
Return

SelectFolder:
  FileSelectFolder NewFolder,*%ImageDir%,, Select the folder containing your wallpapers.`nWallpapers can be in BMP, JPG, GIF or PNG format.`nTo set a relative path edit the configuration file manually.
  If( Not ErrorLevel and NewFolder <> "" ) {
    IniWrite %NewFolder%, %IniFile%, General, ImageDir
    IniWrite 1, %IniFile%, General, ShowTraytip
    
    Reload
    Sleep 1000
  }
Return

CheckStartupState:
  If( FileExist( ShortcutFile ) )
    Menu Tray, Check, Run %Namestring% on Startup
  Else
    Menu Tray, Uncheck, Run %Namestring% on Startup
Return

ToggleStartup:
  If( FileExist( ShortcutFile ) )
    FileDelete %ShortcutFile%
  Else
    FileCreateShortcut %A_ScriptFullPath%, %ShortcutFile%
    
  Gosub CheckStartupState
Return

HotkeysToggle:
  HotkeysEnabled := !HotkeysEnabled
  IniWrite %HotkeysEnabled%, %IniFile%, General, HotkeysEnabled
  Reload
Return

SelectNextHotkey:
  NewKey := SelectHotkey( HotkeyNext )
  If( NewKey != HotkeyNext ) {
    IniWrite %NewKey%, %IniFile%, General, HotkeyNext
    Reload
  }
Return

SelectPrevHotkey:
  NewKey := SelectHotkey( HotkeyPrev )
  If( NewKey != HotkeyPrev ) {
    IniWrite %NewKey%, %IniFile%, General, HotkeyPrev
    Reload
  }
Return

Exit:
  If( InTheMiddle and !Loading ) 
    SetTimer Exit, -1000
  Else
    ExitApp
Return

;-------------------------------------------------------------------------------
; Select Hotkey Dialog
;-------------------------------------------------------------------------------
SelectHotkey( originalKey="" ) {
  Global _SelectHotkeyOpen, _SelectHotkeyAction
  Static GuiKey, GuiCtrl, GuiAlt, GuiWin, GuiShift
  
  KeyList := "A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|1|2|3|4|5|6|7|8|9|0|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|~|-|=|[|]|;|'|\|,|.|/|Home|End|Insert|Delete|PgUp|PgDn|Backspace"
  
  _SelectHotkeyOpen := true
  
  GuiCtrl  := InStr( originalKey, "^" ) ? 1 : 0
  GuiAlt   := InStr( originalKey, "!" ) ? 1 : 0
  GuiShift := InStr( originalKey, "+" ) ? 1 : 0
  GuiWin   := InStr( originalKey, "#" ) ? 1 : 0
  GuiKey   := RegexReplace( originalKey, "[!+^#]", "" )
  
  GuiID := 8
  Gui %GuiID%:Margin, 10, 10
  Gui %GuiID%:Add, Checkbox, w40 vGuiCtrl Checked%GuiCtrl%, Ctrl
  Gui %GuiID%:Add, Checkbox, xp y+8 vGuiShift Checked%GuiShift%, Shift
  Gui %GuiID%:Add, Checkbox, xp y+8 vGuiAlt Checked%GuiAlt%, Alt
  Gui %GuiID%:Add, Checkbox, xp y+8 vGuiWin Checked%GuiWin%, Win
  
  Gui %GuiID%:Add, ListBox, x80 y10 w100 r6 vGuiKey, %KeyList%
  GuiControl %GuiID%:ChooseString, GuiKey, %GuiKey%
  
  Gui %GuiID%:Add, Button, x10 y+10 w80 Default gReturnHotkey,OK
  Gui %GuiID%:Add, Button, x+10 yp wp gCancelHotkey,Cancel
  
  Gui %GuiID%:Show,,Hotkey
  
  Loop
    If( !_SelectHotkeyOpen )
      Break
      
  If( _SelectHotkeyAction == "cancel" )
    return originalKey
      
  Gui %GuiID%:Submit
  Gui %GuiID%:Destroy
  
  Result := ""
  If( GuiCtrl )
    Result .= "^"
  If( GuiShift )
    Result .= "+"
  If( GuiAlt )
    Result .= "!"
  If( GuiWin )
    Result .= "#"
    
  Result .= GuiKey
  Return Result
}

GetHotkeyDisplayString( hotkeyString ) {
  Result := hotkeyString
  StringReplace Result, Result, ^, Ctrl@
  StringReplace Result, Result, !, Alt@
  StringReplace Result, Result, #, Win@
  StringReplace Result, Result, +, Shift@
  StringReplace Result, Result, @, +, All
  Return Result
}

8GuiEscape:
8GuiClose:
CancelHotkey:
  Gui 8:Destroy
  _SelectHotkeyOpen := false
  _SelectHotkeyAction := "cancel"
Return

ReturnHotkey:
  _SelectHotkeyOpen := false
  _SelectHotkeyAction := "save"
Return
