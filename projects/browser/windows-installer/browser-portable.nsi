  !include "common.nsh"

;--------------------------------
  OutFile "browser-portable.exe"
  VIAddVersionKey "FileDescription" "${DISPLAY_NAME} Portable Installer"
  InstallDir "$DESKTOP\${DISPLAY_NAME}"

;--------------------------------
; Pages
  ; Misuse the option to show the readme to create the shortcuts.
  ; Less ugly than MUI_PAGE_COMPONENTS.
  !define MUI_FINISHPAGE_SHOWREADME
  !define MUI_FINISHPAGE_SHOWREADME_TEXT "&Add Start Menu && Desktop shortcuts"
  !define MUI_FINISHPAGE_SHOWREADME_FUNCTION "CreateShortcuts"

  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE CheckIfTargetDirectoryExists
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  ; Languages must be defined after pages
  !include "languages.nsh"

;--------------------------------
; Installer
Function .onInit
  Call CheckRequirements

  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Section "Browser" SecBrowser
  SetOutPath "$INSTDIR"
  File /r "${PROGRAM_SOURCE}\*.*"
  CreateShortCut "$INSTDIR\${DISPLAY_NAME}.lnk" "$INSTDIR\Browser\${EXE_NAME}"
SectionEnd

Function CreateShortcuts
  CreateShortCut "$SMPROGRAMS\${DISPLAY_NAME}.lnk" "$INSTDIR\Browser\${EXE_NAME}"
  CreateShortCut "$DESKTOP\${DISPLAY_NAME}.lnk" "$INSTDIR\Browser\${EXE_NAME}"
FunctionEnd

Function StartBrowser
  ExecShell "open" "$INSTDIR/${DISPLAY_NAME}.lnk"
FunctionEnd
