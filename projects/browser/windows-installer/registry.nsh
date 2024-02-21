; Utilities to update the registry values in installs.
; Based on Firefox's NSIS scripts.
;
; This Source Code Form is subject to the terms of the Mozilla Public
; License, v. 2.0. If a copy of the MPL was not distributed with this
; file, You can obtain one at http://mozilla.org/MPL/2.0/.

!define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME_NO_SPACES}${UPDATE_CHANNEL}"

; The only "public" functions of this file are UpdateRegistry and ClearRegistry.

var aumid

; Compute the AUMID we will use for our links.
; We use the same strategy as Firefox: we hash the path of the installation
; directory with CityHash64.
; See InitHashAppModelId in toolkit/mozapps/installer/windows/nsis/common.nsh.
; While we could differentiate between channels (we force one install for each
; channel), following Firefox has the advantage that we have to adapt/rework
; less stuff.
Function ComputeAumid
  StrCpy $0 $INSTDIR
  ; NSIS command will not convert from short form to the long one.
  ; So, this is the way they suggest to get the long name in their docs.
  System::Call 'kernel32::GetLongPathName(t r0, t .r1, i ${NSIS_MAX_STRLEN}) i .r2'
  ${If} $2 != "error"
    CityHash::GetCityHash64 $1
    Pop $aumid
  ${Else}
    StrCpy $aumid "error"
  ${EndIf}
FunctionEnd

; Set the installation details.
; See https://nsis.sourceforge.io/Add_uninstall_information_to_Add/Remove_Programs.
Function SetUninstallData
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
FunctionEnd

; Register a certain class in the form $browserName$className-$aumid.
; The classes registered by Firefox are URL, HTML and PDF.
; The default browser agent checks them before registering anything.
; See SetDefaultBrowserUserChoice in
; toolkit/mozapps/defaultagent/SetDefaultBrowser.cpp, FormatProgID and
; CheckProgIDExists in browser/components/shell/WindowsUserChoice.cpp.
; See also AddHandlerValues in
; toolkit/mozapps/installer/windows/nsis/common.nsh.
Function RegisterClass
  ; Based on Firefox's AddHandlerValues
  Pop $3 ; Is this a protocol?
  Pop $2 ; Icon index
  Pop $1 ; Description
  Pop $0 ; Class name

  StrCpy $R0 "${NAME_NO_SPACES}$0-$aumid" ; Expanded class name
  StrCpy $R1 "${PROJECT_NAME} $1" ; Description with project name
  StrCpy $R2 "$INSTDIR\${EXE_NAME}" ; Full path to the main executable
  StrCpy $R3 "Software\Classes\$R0" ; Registry key to update

  WriteRegStr HKCU $R3 "" "$R1"
  WriteRegStr HKCU $R3 "FriendlyTypeName" "$R1"
  ${If} $3 == "true"
    WriteRegStr HKCU $R3 "URL Protocol" ""
  ${EndIf}
  ; Firefox sets EditFlags only when empty
  ReadRegDWORD $R4 HKCU $R3 "EditFlags"
  ${If} $R4 == ""
    WriteRegDWORD HKCU $R3 "EditFlags" 0x00000002
  ${EndIf}
  WriteRegStr HKCU "$R3\DefaultIcon" "" "$R2,$2"
  WriteRegStr HKCU "$R3\shell" "" "open"
  WriteRegStr HKCU "$R3\shell\open\command" "" '"$R2" -osint -url "%1"'
FunctionEnd

; Register all the classes we need to handle.
; See RegisterClass.
Function RegisterClasses
  Push "URL"
  Push "URL"
  Push 1
  Push true
  Call RegisterClass

  Push "HTML"
  Push "HTML Document"
  Push 1
  Push false
  Call RegisterClass

  Push "PDF"
  Push "PDF Document"
  Push 5
  Push false
  Call RegisterClass
FunctionEnd

; Register the start menu entry.
; Microsoft's documentation says this is deprecated after Windows 8, however
; these entries are still visible in the settings application.
; See the SetStartMenuInternet macro in
; browser/installer/windows/nsis/shared.nsh.
; We do not add entries for features we do not support, such as the safe mode.
; Also, the functionality to hide/show shortcuts should not apply to Windows 10,
; so we did not implement that as well.
Function RegisterStartMenu
  StrCpy $0 "Software\Clients\StartMenuInternet\${NAME_NO_SPACES}-$aumid"
  StrCpy $1 "$INSTDIR\${EXE_NAME}"
  StrCpy $2 "${NAME_NO_SPACES}-$aumid"
  StrCpy $3 "${NAME_NO_SPACES}URL-$aumid"
  StrCpy $4 "${NAME_NO_SPACES}HTML-$aumid"
  StrCpy $5 "${NAME_NO_SPACES}PDF-$aumid"

  WriteRegStr HKCU "$0" "" "${DISPLAY_NAME}"
  WriteRegStr HKCU "$0\DefaultItcon" "" "$1,0"
  WriteRegStr HKCU "$0\shell\open\command" "" '"$1"'
  WriteRegStr HKCU "$0\Capabilities\StartMenu" "StartMenuInternet" "$2"
  ; Same as Firefox, see SetStartMenuInternet
  ; URLs
  WriteRegStr HKCU "$0\Capabilities\URLAssociations" "http" "$3"
  WriteRegStr HKCU "$0\Capabilities\URLAssociations" "https" "$3"
  ; mailto is currently unsupported, but we could enable it here, if needed.
  ; WriteRegStr HKCU "$0\Capabilities\URLAssociations" "mailto" "$3"
  ; No need to uninstall FTP here, since we had never installed it.
  ; HTML + aumid
  WriteRegStr HKCU "$0\Capabilities\FileAssociations" ".htm" "$4"
  WriteRegStr HKCU "$0\Capabilities\FileAssociations" ".html" "$4"
  WriteRegStr HKCU "$0\Capabilities\FileAssociations" ".shtml" "$4"
  WriteRegStr HKCU "$0\Capabilities\FileAssociations" ".xht" "$4"
  WriteRegStr HKCU "$0\Capabilities\FileAssociations" ".xhtml" "$4"
  WriteRegStr HKCU "$0\Capabilities\FileAssociations" ".svg" "$4"
  WriteRegStr HKCU "$0\Capabilities\FileAssociations" ".webp" "$4"
  WriteRegStr HKCU "$0\Capabilities\FileAssociations" ".avif" "$4"
  ; PDF + aumid
  WriteRegStr HKCU "$0\Capabilities\FileAssociations" ".pdf" "$5"

  WriteRegStr HKCU "Software\RegisteredApplications" "$2" "$0\Capabilities"
FunctionEnd

; Copied from toolkit/mozapps/installer/windows/nsis/common.nsh.
; Implemented as a macro first so that we can use it both in the installer (to
; update the registry) and in the uninstaller (to check which links we have to
; remove). The macro is then expanded in an installer function, and in an
; uninstaller function, to avoid multiple copies of the same code.
!macro GetPathFromStringImp
  Exch $R9
  Push $R8
  Push $R7

  StrCpy $R7 0          ; Set the counter to 0.

  ; Handle quoted paths with arguments.
  StrCpy $R8 $R9 1      ; Copy the first char.
  StrCmp $R8 '"' +2 +1  ; Is it a "?
  StrCmp $R8 "'" +1 +9  ; Is it a '?
  StrCpy $R9 $R9 "" 1   ; Remove the first char.
  IntOp $R7 $R7 + 1     ; Increment the counter.
  StrCpy $R8 $R9 1 $R7  ; Starting from the counter copy the next char.
  StrCmp $R8 "" end +1  ; Are there no more chars?
  StrCmp $R8 '"' +2 +1  ; Is it a " char?
  StrCmp $R8 "'" +1 -4  ; Is it a ' char?
  StrCpy $R9 $R9 $R7    ; Copy chars up to the counter.
  GoTo end

  ; Handle DefaultIcon paths. DefaultIcon paths are not quoted and end with
  ; a , and a number.
  IntOp $R7 $R7 - 1     ; Decrement the counter.
  StrCpy $R8 $R9 1 $R7  ; Copy one char from the end minus the counter.
  StrCmp $R8 '' +4 +1   ; Are there no more chars?
  StrCmp $R8 ',' +1 -3  ; Is it a , char?
  StrCpy $R9 $R9 $R7    ; Copy chars up to the end minus the counter.
  GoTo end

  ; Handle unquoted paths with arguments. An unquoted path with arguments
  ; must be an 8dot3 path.
  StrCpy $R7 -1          ; Set the counter to -1 so it will start at 0.
  IntOp $R7 $R7 + 1      ; Increment the counter.
  StrCpy $R8 $R9 1 $R7   ; Starting from the counter copy the next char.
  StrCmp $R8 "" end +1   ; Are there no more chars?
  StrCmp $R8 " " +1 -3   ; Is it a space char?
  StrCpy $R9 $R9 $R7     ; Copy chars up to the counter.

  end:
  ClearErrors

  Pop $R7
  Pop $R8
  Exch $R9
!macroend

Function GetPathFromString
  !insertmacro GetPathFromStringImp
FunctionEnd

; Create a Software\Classes\Applications\$exeName.exe entry, shared by all the
; installs.
; If this key has already been registered by another channel/install, we just
; make sure the open entry has the expected command line flags.
; See SetStartMenuInternet in browser/installer/windows/nsis/shared.nsh.
Function RegisterTypes
  StrCpy $0 "Software\Classes\Applications\${EXE_NAME}"
  StrCpy $1 "$0\shell\open\command"
  StrCpy $2 "$0\SupportedTypes"

  ReadRegStr $3 HKCU "$1" ""
  ${If} $3 != ""
    ; If the user already has something, we just update it to make sure it
    ; contains the -osint flag. This should not be a problem if we created these
    ; entries, but we still check them in case they were added manually.
    Push $3
    Call GetPathFromString
    Pop $3
    WriteRegStr HKCU "$1" "" '"$3" -osint -url "%1"'
  ${Else}
    WriteRegStr HKCU "$1" "" '"$INSTDIR\${EXE_NAME}" -osint -url "%1"'
    WriteRegStr HKCU "$0\DefaultIcon" "" "$INSTDIR\${EXE_NAME},1"

    ; Same as Firefox, see SetStartMenuInternet
    WriteRegStr HKCU "$2" ".apng" ""
    WriteRegStr HKCU "$2" ".bmp" ""
    WriteRegStr HKCU "$2" ".flac" ""
    WriteRegStr HKCU "$2" ".gif" ""
    WriteRegStr HKCU "$2" ".htm" ""
    WriteRegStr HKCU "$2" ".html" ""
    WriteRegStr HKCU "$2" ".ico" ""
    WriteRegStr HKCU "$2" ".jfif" ""
    WriteRegStr HKCU "$2" ".jpeg" ""
    WriteRegStr HKCU "$2" ".jpg" ""
    WriteRegStr HKCU "$2" ".json" ""
    WriteRegStr HKCU "$2" ".m4a" ""
    WriteRegStr HKCU "$2" ".mp3" ""
    WriteRegStr HKCU "$2" ".oga" ""
    WriteRegStr HKCU "$2" ".ogg" ""
    WriteRegStr HKCU "$2" ".ogv" ""
    WriteRegStr HKCU "$2" ".opus" ""
    WriteRegStr HKCU "$2" ".pdf" ""
    WriteRegStr HKCU "$2" ".pjpeg" ""
    WriteRegStr HKCU "$2" ".pjp" ""
    WriteRegStr HKCU "$2" ".png" ""
    WriteRegStr HKCU "$2" ".rdf" ""
    WriteRegStr HKCU "$2" ".shtml" ""
    WriteRegStr HKCU "$2" ".svg" ""
    WriteRegStr HKCU "$2" ".webm" ""
    WriteRegStr HKCU "$2" ".avif" ""
    WriteRegStr HKCU "$2" ".xht" ""
    WriteRegStr HKCU "$2" ".xhtml" ""
    WriteRegStr HKCU "$2" ".xml" ""
  ${EndIf}
FunctionEnd

; Set the AUMID to all links pointing to our exe in a certain directory.
; See RegisterAumid.
Function RegisterAumidDirectory
  Pop $0
  FindFirst $1 $2 "$0\*.lnk"
  loop:
    IfErrors end
    ShellLink::GetShortCutTarget "$0\$2"
    ; Do not pop, and pass the value over
    Call GetPathFromString
    Pop $3
    ${If} $3 == "$INSTDIR\${EXE_NAME}"
      ApplicationID::Set "$0\$2" "$aumid" "true"
    ${EndIf}
    FindNext $1 $2
    goto loop
  end:
  FindClose $1
FunctionEnd

; Firefox expects the installer to write its AUMID in the registry.
; It is hardcoded to use Software\Mozilla\Firefox\TaskBarIDs, but we change it
; in widget/windows/WinTaskbar.cpp in one of our patches.
; See InitHashAppModelId in toolkit/mozapps/installer/windows/nsis/common.nsh.
;
; In addition to that, we need to associate the AUMID to every link as per
; specifications:
; https://learn.microsoft.com/en-us/windows/win32/shell/appids#application-defined-and-system-defined-appusermodelids
Function RegisterAumid
  StrCpy $0 "Software\${APP_DIR}\${PROJECT_NAME}\TaskBarIDs"
  WriteRegStr HKCU "$0" "$INSTDIR" "$aumid"

  Push $DESKTOP
  Call RegisterAumidDirectory
  Push "$QUICKLAUNCH\User Pinned\TaskBar"
  Call RegisterAumidDirectory
  Push "$QUICKLAUNCH\User Pinned\StartMenu"
  Call RegisterAumidDirectory
FunctionEnd

; Sets all the needed registry keys during an install, or run all the needed
; maintenance in the post update.
Function UpdateRegistry
  Call SetUninstallData
  Call ComputeAumid
  ${If} $aumid != "error"
    Call RegisterClasses
    Call RegisterStartMenu
    Call RegisterTypes
    Call RegisterAumid
  ${EndIf}
FunctionEnd

;--------------------------------
; Uninstall helper
; We do not ship an uninstaller in the updates.
; However, to be able to undo changes done during the post update step, we call
; `postupdate.exe` with the `/Uninstall`. They are implemented here.
; `postupdate.exe` always runs as it was an installer, which is the reason for
; which the following functions do not have the `un.` prefix.
; However, they have an `Un` suffix, and each `Un$function` function undoes the
; changes done by the corresponding `$function` function.

Function UnregisterClass
  Pop $0 ; Class name
  StrCpy $1 "${NAME_NO_SPACES}$0-$aumid" ; Expanded class name
  DeleteRegKey HKCU "Software\Classes\$1"
FunctionEnd

Function UnregisterClasses
  Push "URL"
  Call UnregisterClass
  Push "HTML"
  Call UnregisterClass
  Push "PDF"
  Call UnregisterClass
FunctionEnd

Function UnregisterStartMenu
  DeleteRegValue HKCU "Software\RegisteredApplications" "${NAME_NO_SPACES}-$aumid"
  DeleteRegKey HKCU "Software\Clients\StartMenuInternet\${NAME_NO_SPACES}-$aumid"
FunctionEnd

Function UnregisterTypes
  StrCpy $0 "Software\Classes\Applications\${EXE_NAME}"
  StrCpy $1 "$0\shell\open\command"
  ReadRegStr $2 HKCU "$1" ""
  ${If} $2 != ""
    Push $2
    Call GetPathFromString
    Pop $3
    ; Do not do anything if we are not the installation that created the keys.
    ${If} $3 == "$INSTDIR\${EXE_NAME}"
      DeleteRegKey HKCU "$0"
    ${EndIf}
  ${EndIf}
FunctionEnd

Function UnregisterAumid
  DeleteRegValue HKCU "Software\${APP_DIR}\${PROJECT_NAME}\TaskBarIDs" "$INSTDIR"
  ; No need to do anything on the links, as they will be deleted.
FunctionEnd

; Remove all the registry changes we have done.
Function ClearRegistry
  Call ComputeAumid
  ${If} $aumid != "error"
    ; We take for granted we do not have conflicting aumids.
    Call UnregisterClasses
    Call UnregisterStartMenu
    Call UnregisterAumid
  ${EndIf}
  ; The types do not depend on the AUMID. So, even though we add them only
  ; when we have an AUMID (they would be useless otherwise), we always check if
  ; we should remove them.
  Call UnregisterTypes
FunctionEnd
