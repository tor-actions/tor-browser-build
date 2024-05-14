  !addplugindir nsis-plugins
  !include "common.nsh"
  !include "registry.nsh"
  !include "Win\COM.nsh"

;--------------------------------
  OutFile "browser-install.exe"
  VIAddVersionKey "FileDescription" "${DISPLAY_NAME} Installer"

  !define DEFAULT_INSTALL_DIR "$LocalAppdata\${APP_DIR}\${NAME_NO_SPACES}\${UPDATE_CHANNEL}"
  InstallDir "${DEFAULT_INSTALL_DIR}"

  AutoCloseWindow true

;--------------------------------
; Pages
  Page custom SetupType SetupTypeLeave
  Page custom AdvancedSetup AdvancedSetupLeave
  ; Disable the directory selection when updating
  !define MUI_PAGE_CUSTOMFUNCTION_PRE PageDirectoryPre
  !define MUI_PAGE_CUSTOMFUNCTION_SHOW PageDirectoryShow
  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE CheckIfTargetDirectoryExists
  !define MUI_PAGE_HEADER_SUBTEXT ""
  !insertmacro MUI_PAGE_DIRECTORY
  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE StartBrowser
  !insertmacro MUI_PAGE_INSTFILES

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  ; If we want to restore the finish page in the uninstaller, we have to enable
  ; it also for the installer (but we can still skip it by adding Quit in
  ; StartBrowser).
  ; !insertmacro MUI_UNPAGE_FINISH

  ; Languages must be defined after pages
  !include "languages.nsh"

;--------------------------------
; Installer

; Path to an existing install. If not empty we are in update mode.
var existingInstall

; Installation settings
var isAdvancedMode
var isStandaloneMode
var createDesktopShortcut

; Variable used by the setup type page
var typeRadioStandard
var typeRadioAdvanced
var typeRadioClicked
var typeNextButton

; Variables used in the advanced setup page
var advancedCheckboxDesktop
var advancedCheckboxStandalone

ReserveFile ${WELCOME_IMAGE}

Function .onInit
  Call CheckRequirements

  ; Skip NSIS's language selection prompt and try to use the OS language without
  ; further confirmations.

  File /oname=$PLUGINSDIR\${WELCOME_IMAGE} "${WELCOME_IMAGE}"

  ReadRegStr $existingInstall HKCU "${UNINST_KEY}" "InstallLocation"
  StrCpy $createDesktopShortcut "true"
FunctionEnd

Function SetupType
  ; Freely inspired by the built-in page implemented in
  ; Contrib/Modern UI 2/Pages/Welcome.nsh.
  ; The problem with the built-in page is that the description label fills all
  ; the vertical space, preventing the addition of other widgets (they will be
  ; hidden, will become visible when using Tab, but it will not be possible to
  ; interact with them with the mouse.
  nsDialogs::Create 1044
  Pop $0
  ${If} $0 == error
    Abort
  ${EndIf}
  SetCtlColors $0 "" "${MUI_BGCOLOR}"

  ${NSD_CreateBitmap} 0u 0u 109u 193u ""
  Pop $0
  !insertmacro MUI_INTERNAL_FULLWINDOW_LOADWIZARDIMAGE "" $0 $PLUGINSDIR\${WELCOME_IMAGE} $1

  ${NSD_CreateLabel} 120u 10u 195u 28u "Welcome to the ${DISPLAY_NAME} Installer"
  Pop $0
  SetCtlColors $0 "${MUI_TEXTCOLOR}" "${MUI_BGCOLOR}"
  CreateFont $2 "$(^Font)" "12" "700"
  SendMessage $0 ${WM_SETFONT} $2 0

  ${NSD_CreateLabel} 120u 45u 195u 60u "${INTRO_TEXT}"
  Pop $0
  SetCtlColors $0 "${MUI_TEXTCOLOR}" "${MUI_BGCOLOR}"

  ${NSD_CreateLabel} 120u 105u 195u 12u "Installation Type"
  Pop $0
  SetCtlColors $0 "" ${MUI_BGCOLOR}

  ${If} $existingInstall == ""
    ${NSD_CreateRadioButton} 120u 117u 160u 12u "Standard"
    Pop $typeRadioStandard
  ${Else}
    ${NSD_CreateRadioButton} 120u 117u 160u 12u "Update current installation"
    Pop $typeRadioStandard
  ${EndIf}
  ${NSD_CreateRadioButton} 120u 129u 160u 12u "Advanced"
  Pop $typeRadioAdvanced

  SetCtlColors $typeRadioStandard "" ${MUI_BGCOLOR}
  ${NSD_OnClick} $typeRadioStandard SetupTypeRadioClick
  SetCtlColors $typeRadioAdvanced "" ${MUI_BGCOLOR}
  ${NSD_OnClick} $typeRadioAdvanced SetupTypeRadioClick

  GetDlgItem $typeNextButton $HWNDPARENT 1

  ; Re-check radios if the user presses back
  ${If} $isAdvancedMode == "true"
    StrCpy $typeRadioClicked $typeRadioAdvanced
  ${Else}
    StrCpy $typeRadioClicked $typeRadioStandard
  ${EndIf}
  ${NSD_Check} $typeRadioClicked
  Call SetupTypeUpdate

  nsDialogs::Show

  ${NSD_FreeBitmap} $1
FunctionEnd

Function SetupTypeRadioClick
  Pop $typeRadioClicked
  Call SetupTypeUpdate
FunctionEnd

Function SetupTypeUpdate
  ${If} $typeRadioClicked == $typeRadioAdvanced
    StrCpy $isAdvancedMode "true"
    SendMessage $typeNextButton ${WM_SETTEXT} 0 "STR:$(^NextBtn)"
  ${ElseIf} $typeRadioClicked == $typeRadioStandard
    StrCpy $isAdvancedMode "false"
    StrCpy $isStandaloneMode "false"
    ${If} $existingInstall == ""
      SendMessage $typeNextButton ${WM_SETTEXT} 0 "STR:$(^InstallBtn)"
    ${Else}
      SendMessage $typeNextButton ${WM_SETTEXT} 0 "STR:&Update"
    ${EndIf}
  ${EndIf}
FunctionEnd

Function SetupTypeLeave
  ${If} $typeRadioClicked == $typeRadioAdvanced
    StrCpy $isAdvancedMode "true"
  ${ElseIf} $typeRadioClicked == $typeRadioStandard
    StrCpy $isAdvancedMode "false"
    StrCpy $isStandaloneMode "false"
  ${Else}
    Abort
  ${EndIf}
FunctionEnd

Function AdvancedSetup
  ${If} $isAdvancedMode != "true"
    Return
  ${EndIf}

  !insertmacro MUI_HEADER_TEXT "Advanced setup" ""
  nsDialogs::Create 1018
  Pop $0
  ${If} $0 == error
    Abort
  ${EndIf}

  ${NSD_CreateCheckbox} 0 18% 100% 6% "Create a desktop shortcut"
  Pop $advancedCheckboxDesktop
  ${NSD_CreateCheckbox} 0 30% 100% 6% "Standalone installation"
  Pop $advancedCheckboxStandalone
  ${NSD_CreateLabel} 4% 37% 95% 50% "Choose the standalone installation if you want to install Mullvad Browser in its own dedicated folder, without adding it to the Start menu and to the list of applications."
  Pop $0
  ${NSD_OnClick} $advancedCheckboxStandalone AdvancedSetupCheckboxClick
  ${NSD_OnClick} $advancedCheckboxDesktop AdvancedSetupCheckboxClick

  ${If} $createDesktopShortcut == "true"
    ${NSD_Check} $advancedCheckboxDesktop
  ${EndIf}
  ${If} $existingInstall != ""
    ; If we already have an installation, this is already standalone mode.
    StrCpy $isStandaloneMode "true"
    ${NSD_Check} $advancedCheckboxStandalone
    EnableWindow $advancedCheckboxStandalone 0
  ${ElseIf} $isStandaloneMode == "true"
    ${NSD_Check} $advancedCheckboxStandalone
  ${EndIf}

  nsDialogs::Show
FunctionEnd

Function AdvancedSetupUpdate
  ${NSD_GetState} $advancedCheckboxDesktop $0
  ${If} $0 == "${BST_CHECKED}"
    StrCpy $createDesktopShortcut "true"
  ${Else}
    StrCpy $createDesktopShortcut "false"
  ${EndIf}

  ${NSD_GetState} $advancedCheckboxStandalone $0
  ${If} $0 == "${BST_CHECKED}"
    StrCpy $isStandaloneMode "true"
  ${Else}
    StrCpy $isStandaloneMode "false"
  ${EndIf}
FunctionEnd

Function AdvancedSetupCheckboxClick
  Pop $0
  Call AdvancedSetupUpdate
FunctionEnd

Function AdvancedSetupLeave
  Call AdvancedSetupUpdate
FunctionEnd

Function PageDirectoryPre
  ${If} $isStandaloneMode == "true"
    StrCpy $INSTDIR "${DEFAULT_PORTABLE_DIR}"
    ; Always go through this page in standalone mode.
    Return
  ${ElseIf} $existingInstall != ""
    ; When updating, force the old directory and skip the page.
    StrCpy $INSTDIR $existingInstall
    Abort
  ${Else}
    StrCpy $INSTDIR "${DEFAULT_INSTALL_DIR}"
  ${EndIf}

  ${If} $isAdvancedMode != "true"
    ; Standard install, use the default directory and skip the page.
    Abort
  ${EndIf}
FunctionEnd

Function PageDirectoryShow
  ShowWindow $mui.DirectoryPage.Text ${SW_HIDE}
  ShowWindow $mui.DirectoryPage.SpaceRequired ${SW_HIDE}
  ShowWindow $mui.DirectoryPage.SpaceAvailable ${SW_HIDE}
FunctionEnd

Section "Browser" SecBrowser
  SetOutPath "$INSTDIR"

  ${If} $isStandaloneMode == "true"
    File /r "${PROGRAM_SOURCE}\*.*"
    CreateShortCut "$INSTDIR\${DISPLAY_NAME}.lnk" "$INSTDIR\Browser\${EXE_NAME}"
  ${Else}
    ; Do not use a Browser directory for installs.
    File /r "${PROGRAM_SOURCE}\Browser\*.*"

    ; Tell the browser we are not in standalone mode anymore.
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
  ${If} $isStandaloneMode == "true"
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
