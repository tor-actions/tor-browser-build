  !addplugindir nsis-plugins
  !include "common.nsh"
  !include "registry.nsh"
  !include "Win\COM.nsh"

;--------------------------------
  OutFile "browser-install.exe"
  VIAddVersionKey "FileDescription" "${DISPLAY_NAME} Installer"

  !define DEFAULT_INSTALL_DIR "$LocalAppdata\${APP_DIR}\${NAME_NO_SPACES}\${UPDATE_CHANNEL}"
  InstallDir "${DEFAULT_INSTALL_DIR}"

;--------------------------------
; Pages
  Page custom SetupType SetupTypeLeave
  Page custom CustomSetup CustomSetupLeave
  ; Disable the directory selection when updating
  !define MUI_PAGE_CUSTOMFUNCTION_PRE CustomPageDirectory
  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE CheckIfTargetDirectoryExists
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

  ; Languages must be defined after pages
  !include "languages.nsh"

;--------------------------------
; Installer

; Path to an existing install. If not empty we are in update mode.
var existingInstall

; Installation settings
var isCustomMode
var isPortableMode
var createDesktopShortcut

; Variable used by the setup type page
var typeRadioStandard
var typeRadioCustom
var typeRadioClicked
var typeNextButton

; Variables used in the custom setup page
var customCheckboxPortable
var customCheckboxDesktop

Function .onInit
  Call CheckRequirements

  !insertmacro MUI_LANGDLL_DISPLAY

  ReadRegStr $existingInstall HKCU "${UNINST_KEY}" "InstallLocation"
  StrCpy $createDesktopShortcut "true"
FunctionEnd

Function SetupType
  !insertmacro MUI_HEADER_TEXT "Setup Type" "Choose setup options"
  nsDialogs::Create 1018
  Pop $0
  ${If} $0 == error
    Abort
  ${EndIf}

  ${NSD_CreateLabel} 0 0 100% 18% "Choose the type of setup you prefer."
  ${If} $existingInstall == ""
    ${NSD_CreateRadioButton} 0 18% 100% 6% "Standard"
    Pop $typeRadioStandard
    ${NSD_CreateRadioButton} 0 30% 100% 6% "Custom"
    Pop $typeRadioCustom
  ${Else}
    ${NSD_CreateRadioButton} 0 18% 100% 6% "Update your existing installation"
    Pop $typeRadioStandard
    ${NSD_CreateRadioButton} 0 30% 100% 6% "Portable installation"
    Pop $typeRadioCustom
  ${EndIf}
  ${NSD_OnClick} $typeRadioStandard SetupTypeRadioClick
  ${NSD_OnClick} $typeRadioCustom SetupTypeRadioClick

  GetDlgItem $typeNextButton $HWNDPARENT 1

  ; Re-check radios if the user presses back
  ${If} $isCustomMode == "true"
    StrCpy $typeRadioClicked $typeRadioCustom
  ${Else}
    StrCpy $typeRadioClicked $typeRadioStandard
  ${EndIf}
  ${NSD_Check} $typeRadioClicked
  Call SetupTypeUpdate

  nsDialogs::Show
FunctionEnd

Function SetupTypeRadioClick
  Pop $typeRadioClicked
  Call SetupTypeUpdate
FunctionEnd

Function SetupTypeUpdate
  ${If} $typeRadioClicked == $typeRadioCustom
    StrCpy $isCustomMode "true"
    SendMessage $typeNextButton ${WM_SETTEXT} 0 "STR:$(^NextBtn)"
  ${ElseIf} $typeRadioClicked == $typeRadioStandard
    StrCpy $isCustomMode "false"
    StrCpy $isPortableMode "false"
    ${If} $existingInstall == ""
      SendMessage $typeNextButton ${WM_SETTEXT} 0 "STR:$(^InstallBtn)"
    ${Else}
      SendMessage $typeNextButton ${WM_SETTEXT} 0 "STR:&Update"
    ${EndIf}
  ${EndIf}
FunctionEnd

Function SetupTypeLeave
  ${If} $typeRadioClicked == $typeRadioCustom
    StrCpy $isCustomMode "true"
  ${ElseIf} $typeRadioClicked == $typeRadioStandard
    StrCpy $isCustomMode "false"
    StrCpy $isPortableMode "false"
  ${Else}
    Abort
  ${EndIf}
FunctionEnd

Function CustomSetup
  ${If} $isCustomMode != "true"
    Return
  ${EndIf}

  !insertmacro MUI_HEADER_TEXT "Custom Setup" "Customize your setup options"
  nsDialogs::Create 1018
  Pop $0
  ${If} $0 == error
    Abort
  ${EndIf}

  ${NSD_CreateCheckbox} 0 18% 100% 6% "Portable installation"
  Pop $customCheckboxPortable
  ${NSD_CreateCheckbox} 0 30% 100% 6% "Create a desktop shortcut"
  Pop $customCheckboxDesktop
  ${NSD_OnClick} $customCheckboxPortable CustomSetupCheckboxClick
  ${NSD_OnClick} $customCheckboxDesktop CustomSetupCheckboxClick

  ${If} $existingInstall != ""
    ; If we already have an installation, this is already portable mode.
    StrCpy $isPortableMode "true"
    ${NSD_Check} $customCheckboxPortable
    EnableWindow $customCheckboxPortable 0
  ${ElseIf} $isPortableMode == "true"
    ${NSD_Check} $customCheckboxPortable
  ${EndIf}
  ${If} $createDesktopShortcut == "true"
    ${NSD_Check} $customCheckboxDesktop
  ${EndIf}

  nsDialogs::Show
FunctionEnd

Function CustomSetupUpdate
  ${NSD_GetState} $customCheckboxPortable $0
  ${If} $0 == "${BST_CHECKED}"
    StrCpy $isPortableMode "true"
  ${Else}
    StrCpy $isPortableMode "false"
  ${EndIf}

  ${NSD_GetState} $customCheckboxDesktop $0
  ${If} $0 == "${BST_CHECKED}"
    StrCpy $createDesktopShortcut "true"
  ${Else}
    StrCpy $createDesktopShortcut "false"
  ${EndIf}
FunctionEnd

Function CustomSetupCheckboxClick
  Pop $0
  Call CustomSetupUpdate
FunctionEnd

Function CustomSetupLeave
  Call CustomSetupUpdate
FunctionEnd

Function CustomPageDirectory
  ${If} $isPortableMode == "true"
    StrCpy $INSTDIR "${DEFAULT_PORTABLE_DIR}"
    ; Always go through this page in portable mode.
    Return
  ${ElseIf} $existingInstall != ""
    ; When updating, force the old directory and skip the page.
    StrCpy $INSTDIR $existingInstall
    Abort
  ${Else}
    StrCpy $INSTDIR "${DEFAULT_INSTALL_DIR}"
  ${EndIf}

  ${If} $isCustomMode != "true"
    ; Standard install, use the default directory and skip the page.
    Abort
  ${EndIf}
FunctionEnd

Section "Browser" SecBrowser
  SetOutPath "$INSTDIR"

  ${If} $isPortableMode == "true"
    File /r "${PROGRAM_SOURCE}\*.*"
    CreateShortCut "$INSTDIR\${DISPLAY_NAME}.lnk" "$INSTDIR\Browser\${EXE_NAME}"
  ${Else}
    ; Do not use a Browser directory for installs.
    File /r "${PROGRAM_SOURCE}\Browser\*.*"

    ; Tell the browser we are not in portable mode anymore.
    FileOpen $0 "$INSTDIR\system-install" w
    FileClose $0

    ; Write the uninstaller
    WriteUninstaller $INSTDIR\uninstall.exe

    Call UpdateRegistry

    CreateShortCut "$SMPROGRAMS\${DISPLAY_NAME}.lnk" "$INSTDIR\${EXE_NAME}"
    ${If} $createDesktopShortcut == "true"
      CreateShortCut "$DESKTOP\${DISPLAY_NAME}.lnk" "$INSTDIR\${EXE_NAME}"
    ${EndIf}
  ${EndIf}
SectionEnd

Function StartBrowser
  ${If} $isPortableMode == "true"
    ExecShell "open" "$INSTDIR\${DISPLAY_NAME}.lnk"
  ${Else}
    ExecShell "open" "$INSTDIR\${EXE_NAME}"
  ${EndIf}
FunctionEnd

;--------------------------------
; Uninstaller

Function un.GetPathFromString
  !insertmacro GetPathFromStringImp
FunctionEnd

Section "Uninstall"
  ; Currently, the uninstaller is written by the installer, only in install
  ; mode, and we do not have any way to update it.
  ; However, we keep postupdate.exe updated, so we can use that instead.
  ExecWait '"$INSTDIR\postupdate.exe" /Uninstall' $0

  RMDir /r "$INSTDIR"
  DeleteRegKey HKCU "${UNINST_KEY}"

  StrCpy $2 "$SMPROGRAMS\${DISPLAY_NAME}.lnk"
  StrCpy $3 ""
  ShellLink::GetShortCutTarget "$2"
  Pop $3
  ${If} $3 == "$INSTDIR\${EXE_NAME}"
    ; https://stackoverflow.com/questions/42816091/nsis-remove-pinned-icon-from-taskbar-on-uninstall
    !insertmacro ComHlpr_CreateInProcInstance ${CLSID_StartMenuPin} ${IID_IStartMenuPinnedList} r0 ""
    ${If} $0 P<> 0
      System::Call 'SHELL32::SHCreateItemFromParsingName(ws, p0, g "${IID_IShellItem}", *p0r1)' "$2"
      ${If} $1 P<> 0
        ${IStartMenuPinnedList::RemoveFromList} $0 '(r1)'
        ${IUnknown::Release} $1 ""
      ${EndIf}
      ${IUnknown::Release} $0 ""
    ${EndIf}

    Delete "$2"
  ${EndIf}

  FindFirst $1 $2 "$DESKTOP\*.lnk"
  loop:
    IfErrors end
    StrCpy $0 ""
    ShellLink::GetShortCutTarget "$DESKTOP\$2"
    ; Do not pop, and pass the value over
    Call un.GetPathFromString
    Pop $0
    ${If} $0 == "$INSTDIR\${EXE_NAME}"
      Delete "$DESKTOP\$2"
    ${EndIf}
    FindNext $1 $2
    goto loop
  end:
  FindClose $1

  ${RefreshShellIcons}

  ; TODO: Optionally remove profiles.
  ; This operation is not trivial, because it involes finding our installation
  ; hash, its associated default profile and making sure it is not shared with
  ; another channel/installation.
SectionEnd
