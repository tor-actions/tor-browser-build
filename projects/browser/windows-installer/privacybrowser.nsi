;NSIS Installer for Privacy Browser
;Written by Moritz Bartl
;released under Public Domain

;--------------------------------
;Modern UI

  !include "MUI2.nsh"
  !include "LogicLib.nsh"
  !include "WinVer.nsh"

;--------------------------------
;General

  ; location of Privacy Browser bundle to put into installer
  !define TBBSOURCE ".\Privacy Browser\"

  Name "Privacy Browser"
  OutFile "privacybrowser-install.exe"

  ;Default installation folder
  InstallDir "$DESKTOP\Privacy Browser"

  ;Best (but slowest) compression
  SetCompressor /SOLID lzma
  SetCompressorDictSize 32

  ;Request application privileges for Windows Vista
  RequestExecutionLevel user

;--------------------------------
;Interface Configuration

  !define MUI_ICON   "privacybrowser.ico"
  !define MUI_ABORTWARNING

;--------------------------------
;Modern UI settings
  !define MUI_FINISHPAGE_NOREBOOTSUPPORT     ; we don't require a reboot
  !define MUI_FINISHPAGE_RUN
  !define MUI_FINISHPAGE_RUN_FUNCTION "StartPrivacyBrowser"
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
;Reserve Files

  ;If you are using solid compression, files that are required before
  ;the actual installation should be stored first in the data block,
  ;because this will make your installer start faster.

  !insertmacro MUI_RESERVEFILE_LANGDLL

;--------------------------------
;Installer Sections

Section "Privacy Browser" SecPB

  SetOutPath "$INSTDIR"
  File /r "${TBBSOURCE}\*.*"
  SetOutPath "$INSTDIR\Browser"
  CreateShortCut "$INSTDIR\Start Privacy Browser.lnk" "$INSTDIR\Browser\privacybrowser.exe"

SectionEnd

Function CreateShortcuts

  CreateShortCut "$SMPROGRAMS\Start Privacy Browser.lnk" "$INSTDIR\Browser\privacybrowser.exe"
  CreateShortCut "$DESKTOP\Start Privacy Browser.lnk" "$INSTDIR\Browser\privacybrowser.exe"

FunctionEnd
;--------------------------------
;Installer Functions

Function .onInit

  ${IfNot} ${AtLeastWin7}
    MessageBox MB_USERICON|MB_OK "Privacy Browser requires at least Windows 7"
    SetErrorLevel 1
    Quit
  ${EndIf}

  ; Don't install on systems that don't support SSE2. The parameter value of
  ; 10 is for PF_XMMI64_INSTRUCTIONS_AVAILABLE which will check whether the
  ; SSE2 instruction set is available.
  System::Call "kernel32::IsProcessorFeaturePresent(i 10)i .R7"

  ${If} "$R7" == "0"
    MessageBox MB_OK|MB_ICONSTOP "Sorry, Privacy Browser can't be installed. This version of Privacy Browser requires a processor with SSE2 support."
    Abort
  ${EndIf}

  !insertmacro MUI_LANGDLL_DISPLAY

FunctionEnd

;--------------------------------
;Helper Functions

Function CheckIfTargetDirectoryExists
${If} ${FileExists} "$INSTDIR\*.*"
  MessageBox MB_YESNO "The destination directory already exists. You can try to upgrade Privacy Browser, but if you run into any problems, use a new directory instead. Continue?" IDYES NoAbort
    Abort
  NoAbort:
${EndIf}
FunctionEnd


Function StartPrivacyBrowser
ExecShell "open" "$INSTDIR/Start Privacy Browser.lnk"
FunctionEnd

