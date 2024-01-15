; NSIS Installer for Tor/Base/Mullvad Browser
; Based on NSIS examples by Joost Verburg.
; Originally adapted to Tor Browser by Moritz Bartl
; https://github.com/moba/tbb-windows-installer
; Released under the zlib/libpng license.

;--------------------------------
  !include "FileFunc.nsh"
  !include "LogicLib.nsh"
  !include "MUI2.nsh"
  !include "WinVer.nsh"

;--------------------------------
; General
  ; Location of Tor/Base/Mullvad Browser to put into installer
  !define PROGRAM_SOURCE ".\[% c('var/Project_Name') %]\"

[% IF c("var/channel") == "release";
      SET display_name = c('var/Project_Name');
   ELSIF c("var/testbuild");
      SET display_name = c('var/Project_Name') _ " Testbuild";
   ELSE;
      SET display_name = c('var/Project_Name_Channel');
   END
-%]
  Name "[% display_name %]"
  OutFile "browser-install.exe"

  ; Default installation folder
  InstallDir "$DESKTOP\[% display_name %]"

  ; Best (but slowest) compression
  SetCompressor /SOLID lzma
  SetCompressorDictSize 32

  ; Do not require elevated privileges
  RequestExecutionLevel user

  ; Support HiDPI displays
  ManifestDPIAware true

;--------------------------------
; Metadata
  VIProductVersion "[% pc('firefox', 'var/browser_series') %].0.0"
  VIAddVersionKey "ProductName" "[% display_name %]"
  VIAddVersionKey "ProductVersion" "[% c('var/torbrowser_version') %]"
  VIAddVersionKey "FileDescription" "[% display_name %] Portable Installer"
  VIAddVersionKey "LegalCopyright" "© [% pc('firefox', 'var/copyright_year') %] [% IF c('var/mullvad-browser') %]Mullvad, Tor Browser and Mozilla Developers[% ELSE %]The Tor Project[% END %]"

;--------------------------------
; Interface Configuration
  !define MUI_ICON "[% c('var/projectname') %][% IF !c('var/base-browser') %]-[% c('var/channel') %][% END %].ico"
  !define MUI_ABORTWARNING

;--------------------------------
; Modern UI settings
  !define MUI_FINISHPAGE_NOREBOOTSUPPORT ; Reboot not required
  !define MUI_FINISHPAGE_RUN
  !define MUI_FINISHPAGE_RUN_FUNCTION "StartBrowser"

  ; Misuse the option to show the readme to create the shortcuts.
  ; Less ugly than MUI_PAGE_COMPONENTS.
  !define MUI_FINISHPAGE_SHOWREADME
  !define MUI_FINISHPAGE_SHOWREADME_TEXT "&Add Start Menu && Desktop shortcuts"
  !define MUI_FINISHPAGE_SHOWREADME_FUNCTION "CreateShortCuts"

;--------------------------------
; Pages
  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE CheckIfTargetDirectoryExists
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

;--------------------------------
; Languages
  !insertmacro MUI_LANGUAGE "English" ; First language is the default language
  !insertmacro MUI_LANGUAGE "Arabic" ; ar
  !insertmacro MUI_LANGUAGE "Catalan" ; ca
  !insertmacro MUI_LANGUAGE "Czech" ; cs
  !insertmacro MUI_LANGUAGE "Danish" ; da
  !insertmacro MUI_LANGUAGE "German" ; de
  !insertmacro MUI_LANGUAGE "Greek" ; el
  !insertmacro MUI_LANGUAGE "Spanish" ; es-ES
  !insertmacro MUI_LANGUAGE "Farsi" ; fa
  !insertmacro MUI_LANGUAGE "Finnish" ; fi
  !insertmacro MUI_LANGUAGE "French" ; fr
  !insertmacro MUI_LANGUAGE "ScotsGaelic" ; ga-IE
  !insertmacro MUI_LANGUAGE "Hebrew" ; he
  !insertmacro MUI_LANGUAGE "Hungarian" ; hu
  !insertmacro MUI_LANGUAGE "Indonesian"; id
  !insertmacro MUI_LANGUAGE "Icelandic" ; is
  !insertmacro MUI_LANGUAGE "Italian" ; it
  !insertmacro MUI_LANGUAGE "Japanese" ; ja
  !insertmacro MUI_LANGUAGE "Georgian" ; ka
  !insertmacro MUI_LANGUAGE "Korean" ; ko
  !insertmacro MUI_LANGUAGE "Lithuanian" ; lt
  !insertmacro MUI_LANGUAGE "Macedonian" ; mk
  !insertmacro MUI_LANGUAGE "Malay" ; ms
  ; Burmese - my: not available on NSIS
  !insertmacro MUI_LANGUAGE "Norwegian" ; nb-NO
  !insertmacro MUI_LANGUAGE "Dutch" ; nl
  !insertmacro MUI_LANGUAGE "Polish" ; pl
  !insertmacro MUI_LANGUAGE "PortugueseBR" ; pt-BR
  !insertmacro MUI_LANGUAGE "Romanian" ; ro
  !insertmacro MUI_LANGUAGE "Russian" ; ru
  !insertmacro MUI_LANGUAGE "Albanian" ; sq
  !insertmacro MUI_LANGUAGE "Swedish" ; sv-SE
  !insertmacro MUI_LANGUAGE "Thai" ; th
  !insertmacro MUI_LANGUAGE "Turkish" ; tr
  !insertmacro MUI_LANGUAGE "Ukrainian" ; uk
  !insertmacro MUI_LANGUAGE "Vietnamese" ; vi
  !insertmacro MUI_LANGUAGE "SimpChinese" ; zh-hans, zh-cn
  !insertmacro MUI_LANGUAGE "TradChinese" ; zh-hant, zh-tw

;--------------------------------
; Reserve Files

  ; If you are using solid compression, files that are required before
  ; the actual installation should be stored first in the data block,
  ; because this will make your installer start faster.

  !insertmacro MUI_RESERVEFILE_LANGDLL

;--------------------------------
; Installer Sections

Section "Browser" SecBrowser
  SetOutPath "$INSTDIR"
  File /r "${PROGRAM_SOURCE}\*.*"
  CreateShortCut "$INSTDIR\[% display_name %].lnk" "$INSTDIR\Browser\[% c('var/exe_name') %].exe"
SectionEnd

;--------------------------------
; Installer Functions

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

Function CheckIfTargetDirectoryExists
  ${If} ${FileExists} "$INSTDIR\*.*"
    MessageBox MB_YESNO "The destination directory already exists. Do you want to continue anyway?" IDYES +2
    Abort
  ${EndIf}
FunctionEnd

Function CreateShortcuts
  CreateShortCut "$SMPROGRAMS\[% display_name %].lnk" "$INSTDIR\[% IF !system_install_mode -%]Browser\[% END -%][% c('var/exe_name') %].exe"
  CreateShortCut "$DESKTOP\[% display_name %].lnk" "$INSTDIR\[% IF !system_install_mode -%]Browser\[% END -%][% c('var/exe_name') %].exe"
FunctionEnd

Function StartBrowser
  ExecShell "open" "$INSTDIR/[% display_name %].lnk"
FunctionEnd
