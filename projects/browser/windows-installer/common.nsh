; Common code for the NSIS Installers for Tor/Base/Mullvad Browser.
; Based on NSIS examples by Joost Verburg.
; Originally adapted to Tor Browser by Moritz Bartl
; https://github.com/moba/tbb-windows-installer
; Released under the zlib/libpng license.

;--------------------------------
  !include "FileFunc.nsh"
  !include "LogicLib.nsh"
  !include "MUI2.nsh"
  !include "WinVer.nsh"

  !include "defines.nsh"

;--------------------------------
; General settings
  Name "${DISPLAY_NAME}"

  ; Best (but slowest) compression
  SetCompressor /SOLID lzma
  SetCompressorDictSize 32

  ; Do not require elevated privileges.
  ; Even for the installer, we install only for the current user, so we do not
  ; need high privileges.
  RequestExecutionLevel user

  ; Support HiDPI displays
  ManifestDPIAware true

  ; Do not show "Nullsoft Install System vX.XX"
  BrandingText " "

;--------------------------------
; Version information
  VIProductVersion "${VERSION_WINDOWS}"
  VIAddVersionKey "ProductName" "${DISPLAY_NAME}"
  VIAddVersionKey "ProductVersion" "${VERSION}"
  VIAddVersionKey "FileVersion" "${VERSION}"
  VIAddVersionKey "LegalCopyright" "${COPYRIGHT_STRING}"

;--------------------------------
; Interface Configuration
  ; Installer icon
  !define MUI_ICON "${ICON_NAME}"
  !define MUI_ABORTWARNING

;--------------------------------
; Modern UI settings
  !define MUI_FINISHPAGE_NOREBOOTSUPPORT ; Reboot not required
  !define MUI_FINISHPAGE_RUN
  !define MUI_FINISHPAGE_RUN_FUNCTION "StartBrowser"

;--------------------------------
; Reserve Files
  ; If you are using solid compression, files that are required before
  ; the actual installation should be stored first in the data block,
  ; because this will make your installer start faster.
  !insertmacro MUI_RESERVEFILE_LANGDLL

;--------------------------------
; Helper functions
Function CheckRequirements
  ${IfNot} ${AtLeastWin7}
    MessageBox MB_USERICON|MB_OK "${PROJECT_NAME} requires at least Windows 7"
    SetErrorLevel 1
    Quit
  ${EndIf}

  ; Don't install on systems that don't support SSE2. The parameter value of
  ; 10 is for PF_XMMI64_INSTRUCTIONS_AVAILABLE which will check whether the
  ; SSE2 instruction set is available.
  System::Call "kernel32::IsProcessorFeaturePresent(i 10)i .R7"
  ${If} "$R7" == "0"
    MessageBox MB_OK|MB_ICONSTOP "${PROJECT_NAME} requires a processor with SSE2 support."
    Quit
  ${EndIf}
FunctionEnd

Function CheckIfTargetDirectoryExists
  ${If} ${FileExists} "$INSTDIR\*.*"
    MessageBox MB_YESNO "The destination directory already exists. Do you want to continue anyway?" IDYES +2
    Abort
  ${EndIf}
FunctionEnd
