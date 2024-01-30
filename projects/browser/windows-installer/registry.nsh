!define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME_NO_SPACES}${UPDATE_CHANNEL}"

!macro UPDATE_REGISTRY
  WriteRegStr HKCU "${UNINST_KEY}" "DisplayName" "${DISPLAY_NAME}"
  WriteRegStr HKCU "${UNINST_KEY}" "DisplayIcon" "$\"$INSTDIR\${EXE_NAME}$\""
  WriteRegStr HKCU "${UNINST_KEY}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "${UNINST_KEY}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr HKCU "${UNINST_KEY}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
  WriteRegDWORD HKCU "${UNINST_KEY}" "NoModify" "1"
  WriteRegDWORD HKCU "${UNINST_KEY}" "NoRepair" "1"
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKCU "${UNINST_KEY}" "EstimatedSize" "$0"
  WriteRegStr HKCU "${UNINST_KEY}" "InstallLocation" "$INSTDIR"
    WriteRegStr HKCU "${UNINST_KEY}" "Publisher" "${PUBLISHER}"
  WriteRegStr HKCU "${UNINST_KEY}" "URLInfoAbout" "${URL_ABOUT}"
  WriteRegStr HKCU "${UNINST_KEY}" "URLUpdateInfo" "${URL_UPDATE}"
  WriteRegStr HKCU "${UNINST_KEY}" "HelpLink" "${URL_HELP}"
!macroend
