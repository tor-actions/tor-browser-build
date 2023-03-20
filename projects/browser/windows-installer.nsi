;NSIS Installer for Tor/Base/Mullvad Browser
;Written by Moritz Bartl
;released under Public Domain

;--------------------------------
;Modern UI

  !include "FileFunc.nsh"
  !include "MUI2.nsh"
  !include "LogicLib.nsh"
  !include "WinVer.nsh"

;--------------------------------
;General

  ;Location of Tor/Base/Mullvad Browser to put into installer
  !define PROGRAM_SOURCE ".\[% c('var/Project_Name') %]\"

  Name "[% c('var/Project_Name') %]"
  OutFile "browser-install.exe"

  ;Default installation folder
[% IF system_install_mode -%]
  InstallDir "$PROGRAMFILES\[% c('var/Project_Name') %]"
[% ELSE -%]
  InstallDir "$DESKTOP\[% c('var/Project_Name') %]"
[% END -%]

  ;Best (but slowest) compression
  SetCompressor /SOLID lzma
  SetCompressorDictSize 32

  ;Request application privileges for Windows Vista
[% IF system_install_mode -%]
  RequestExecutionLevel admin
[% ELSE -%]
  RequestExecutionLevel user
[% END -%]

  ;Support HiDPI displays
  ManifestDPIAware true

[% IF system_install_mode -%]
  ;Registry keys to uninstall system-wide installs
  !define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\[% c('var/ProjectName') %]"
[% END -%]

;--------------------------------
;Metadata

  VIProductVersion "[% pc("firefox", "var/browser_series") %].0.0"
  VIAddVersionKey "ProductName" "[% c('var/Project_Name') %]"
  VIAddVersionKey "ProductVersion" "[% c('var/torbrowser_version') %]"
  VIAddVersionKey "FileDescription" "[% c('var/Project_Name') %][% IF system_install_mode -%] System[% END -%] Installer"
  VIAddVersionKey "LegalCopyright" "© [% pc("firefox", "var/copyright_year") %] [% IF c('var/mullvad-browser') -%]Mullvad, Tor Browser and Mozilla Developers[% ELSE -%]The Tor Project[% END -%]"

;--------------------------------
;Interface Configuration

  !define MUI_ICON   "[% c('var/projectname') %][% IF c('var/mullvad-browser') -%]-[% c('var/channel') %][% END -%].ico"
  !define MUI_ABORTWARNING

;--------------------------------
;Modern UI settings
  !define MUI_FINISHPAGE_NOREBOOTSUPPORT     ; we don't require a reboot
  !define MUI_FINISHPAGE_RUN
  !define MUI_FINISHPAGE_RUN_FUNCTION "StartBrowser"
  !define MUI_FINISHPAGE_SHOWREADME ; misuse for option to create shortcut; less ugly than MUI_PAGE_COMPONENTS
  !define MUI_FINISHPAGE_SHOWREADME_TEXT "&Add Start Menu && Desktop shortcuts"
  !define MUI_FINISHPAGE_SHOWREADME_FUNCTION "CreateShortCuts"
;--------------------------------
;Pages

  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE CheckIfTargetDirectoryExists
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English" ;first language is the default language
  !insertmacro MUI_LANGUAGE "French"
  !insertmacro MUI_LANGUAGE "German"
  !insertmacro MUI_LANGUAGE "Spanish"
  !insertmacro MUI_LANGUAGE "SpanishInternational"
  !insertmacro MUI_LANGUAGE "SimpChinese"
  !insertmacro MUI_LANGUAGE "TradChinese"
  !insertmacro MUI_LANGUAGE "Japanese"
  !insertmacro MUI_LANGUAGE "Korean"
  !insertmacro MUI_LANGUAGE "Italian"
  !insertmacro MUI_LANGUAGE "Dutch"
  !insertmacro MUI_LANGUAGE "Danish"
  !insertmacro MUI_LANGUAGE "Swedish"
  !insertmacro MUI_LANGUAGE "Norwegian"
  !insertmacro MUI_LANGUAGE "NorwegianNynorsk"
  !insertmacro MUI_LANGUAGE "Finnish"
  !insertmacro MUI_LANGUAGE "Greek"
  !insertmacro MUI_LANGUAGE "Russian"
  !insertmacro MUI_LANGUAGE "Portuguese"
  !insertmacro MUI_LANGUAGE "PortugueseBR"
  !insertmacro MUI_LANGUAGE "Polish"
  !insertmacro MUI_LANGUAGE "Ukrainian"
  !insertmacro MUI_LANGUAGE "Czech"
  !insertmacro MUI_LANGUAGE "Slovak"
  !insertmacro MUI_LANGUAGE "Croatian"
  !insertmacro MUI_LANGUAGE "Bulgarian"
  !insertmacro MUI_LANGUAGE "Hungarian"
  !insertmacro MUI_LANGUAGE "Thai"
  !insertmacro MUI_LANGUAGE "Romanian"
  !insertmacro MUI_LANGUAGE "Latvian"
  !insertmacro MUI_LANGUAGE "Macedonian"
  !insertmacro MUI_LANGUAGE "Estonian"
  !insertmacro MUI_LANGUAGE "Turkish"
  !insertmacro MUI_LANGUAGE "Lithuanian"
  !insertmacro MUI_LANGUAGE "Slovenian"
  !insertmacro MUI_LANGUAGE "Serbian"
  !insertmacro MUI_LANGUAGE "SerbianLatin"
  !insertmacro MUI_LANGUAGE "Arabic"
  !insertmacro MUI_LANGUAGE "Farsi"
  !insertmacro MUI_LANGUAGE "Hebrew"
  !insertmacro MUI_LANGUAGE "Indonesian"
  !insertmacro MUI_LANGUAGE "Mongolian"
  !insertmacro MUI_LANGUAGE "Luxembourgish"
  !insertmacro MUI_LANGUAGE "Albanian"
  !insertmacro MUI_LANGUAGE "Breton"
  !insertmacro MUI_LANGUAGE "Belarusian"
  !insertmacro MUI_LANGUAGE "Icelandic"
  !insertmacro MUI_LANGUAGE "Malay"
  !insertmacro MUI_LANGUAGE "Bosnian"
  !insertmacro MUI_LANGUAGE "Kurdish"
  !insertmacro MUI_LANGUAGE "Irish"
  !insertmacro MUI_LANGUAGE "Uzbek"
  !insertmacro MUI_LANGUAGE "Galician"
  !insertmacro MUI_LANGUAGE "Afrikaans"
  !insertmacro MUI_LANGUAGE "Catalan"
  !insertmacro MUI_LANGUAGE "Esperanto"

;--------------------------------
;Multi Language support: Read strings from separate file

; !include [% c('var/projectname') %]-langstrings.nsi

;--------------------------------
;Reserve Files

  ;If you are using solid compression, files that are required before
  ;the actual installation should be stored first in the data block,
  ;because this will make your installer start faster.

  !insertmacro MUI_RESERVEFILE_LANGDLL

;--------------------------------
;Installer Sections

Section "[% c('var/Project_Name') %]" SecBrowser

  SetOutPath "$INSTDIR"
[% IF !system_install_mode -%]
  File /r "${PROGRAM_SOURCE}\*.*"
  CreateShortCut "$INSTDIR\Start [% c('var/Project_Name') %].lnk" "$INSTDIR\Browser\[% c('var/exe_name') %].exe"
[% ELSE -%]
  File /r "${PROGRAM_SOURCE}\Browser\*.*"

  ;Enable system-wide install in the browser
  FileOpen $0 "$INSTDIR\system-install" w
  FileClose $0

  ;Write the uninstaller
  WriteUninstaller $INSTDIR\uninstall.exe

  ;Add the uninstaller to the control panel
  WriteRegStr HKLM "${UNINST_KEY}" "DisplayName" "[% c('var/Project_Name') %]"
  WriteRegStr HKLM "${UNINST_KEY}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr HKLM "${UNINST_KEY}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
  WriteRegStr HKLM "${UNINST_KEY}" "Publisher" "[% IF c('var/mullvad-browser') -%]Mullvad VPN[% ELSE -%]The Tor Project[% END -%]"
  WriteRegStr HKLM "${UNINST_KEY}" "DisplayIcon" "$\"$INSTDIR\[% c('var/exe_name') %].exe$\""
  WriteRegStr HKLM "${UNINST_KEY}" "DisplayVersion" "[% c('var/torbrowser_version') %]"
  WriteRegDWORD HKLM "${UNINST_KEY}" "NoModify" "1"
  WriteRegDWORD HKLM "${UNINST_KEY}" "NoRepair" "1"
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKLM "${UNINST_KEY}" "EstimatedSize" "$0"
[% END -%]

SectionEnd

[% IF system_install_mode -%]
Section "Uninstall"
  RMDir /r "$INSTDIR"
  DeleteRegKey HKLM "${UNINST_KEY}"
  SetShellVarContext all
  Delete "$SMPROGRAMS\[% c('var/Project_Name') %].lnk"
  Delete "$DESKTOP\[% c('var/Project_Name') %].lnk"
SectionEnd
[% END -%]

Function CreateShortcuts
[% IF system_install_mode -%]
  SetShellVarContext all
[% END -%]
  CreateShortCut "$SMPROGRAMS\[% c('var/Project_Name') %].lnk" "$INSTDIR\[% IF !system_install_mode -%]Browser\[% END -%][% c('var/exe_name') %].exe"
  CreateShortCut "$DESKTOP\[% c('var/Project_Name') %].lnk" "$INSTDIR\[% IF !system_install_mode -%]Browser\[% END -%][% c('var/exe_name') %].exe"

FunctionEnd
;--------------------------------
;Installer Functions

Function .onInit

  ${IfNot} ${AtLeastWin7}
    MessageBox MB_USERICON|MB_OK "[% c('var/Project_Name') %] requires at least Windows 7"
    SetErrorLevel 1
    Quit
  ${EndIf}

  ; Don't install on systems that don't support SSE2. The parameter value of
  ; 10 is for PF_XMMI64_INSTRUCTIONS_AVAILABLE which will check whether the
  ; SSE2 instruction set is available.
  System::Call "kernel32::IsProcessorFeaturePresent(i 10)i .R7"

  ${If} "$R7" == "0"
    MessageBox MB_OK|MB_ICONSTOP "Sorry, [% c('var/Project_Name') %] can't be installed. This version of [% c('var/Project_Name') %] requires a processor with SSE2 support."
    Abort
  ${EndIf}

  !insertmacro MUI_LANGDLL_DISPLAY

FunctionEnd

;--------------------------------
;Helper Functions

Function CheckIfTargetDirectoryExists
${If} ${FileExists} "$INSTDIR\*.*"
 MessageBox MB_YESNO "The destination directory already exists. You can try to upgrade the [% c('var/Project_Name') %], but if you run into any problems, use a new directory instead. Continue?" IDYES NoAbort
   Abort
 NoAbort:
${EndIf}
FunctionEnd

Function StartBrowser
[% IF !system_install_mode -%]
  ExecShell "open" "$INSTDIR/Start [% c('var/Project_Name') %].lnk"
[% ELSE -%]
  ExecShell "open" "$INSTDIR/[% c('var/exe_name') %].exe"
[% END -%]
FunctionEnd
