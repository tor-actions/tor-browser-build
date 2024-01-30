!include "FileFunc.nsh"
!include "LogicLib.nsh"

!include "defines.nsh"
!include "registry.nsh"

OutFile "postupdate.exe"
Icon "${ICON_NAME}"
RequestExecutionLevel user

Function .onInit
  ${GetOptions} $CMDLINE "/Visible" $0
  IfErrors 0 +2
  SetSilent silent
FunctionEnd

Section PostUpdate "PostUpdate"
  StrCpy $0 "false"
  IfFileExists $EXEDIR\system-install 0 +2
  StrCpy $0 "true"
  ${If} $0 == "true"
    StrCpy $INSTDIR $EXEDIR
    !insertmacro UPDATE_REGISTRY
    RMDir /r /REBOOTOK $EXEDIR\tobedeleted
  ${Else}
    RMDir /r $EXEDIR\tobedeleted
  ${EndIf}
SectionEnd
