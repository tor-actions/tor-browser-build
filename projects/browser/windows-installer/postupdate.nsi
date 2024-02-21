!addplugindir nsis-plugins
!include "FileFunc.nsh"
!include "LogicLib.nsh"

!include "defines.nsh"
!include "registry.nsh"

OutFile "postupdate.exe"
Icon "${ICON_NAME}"
RequestExecutionLevel user

Function .onInit
  StrCpy $INSTDIR $EXEDIR

  ${GetOptions} $CMDLINE "/Visible" $0
  IfErrors 0 +2
  SetSilent silent
  ${GetOptions} $CMDLINE "/Uninstall" $0
  IfErrors +2 0
  Call Uninstall
FunctionEnd

Section PostUpdate "PostUpdate"
  StrCpy $0 "false"
  IfFileExists $EXEDIR\system-install 0 +2
  StrCpy $0 "true"
  ${If} $0 == "true"
    Call UpdateRegistry
    RMDir /r /REBOOTOK $EXEDIR\tobedeleted
  ${Else}
    RMDir /r $EXEDIR\tobedeleted
  ${EndIf}
SectionEnd

Function Uninstall
  Call ClearRegistry
  Quit
FunctionEnd
