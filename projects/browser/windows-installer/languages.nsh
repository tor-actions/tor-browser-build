;--------------------------------
; Additional languages
  !insertmacro MUI_LANGUAGE "English" ; Always available

  ; Base Browser strings
  LangString add_shortcuts ${LANG_ENGLISH} "&Add Start menu and desktop icons"
  ; Use %(program)s instead of ${PROJECT_NAME}  and %(version)s instead of 7
  ; when sending the string from localization.
  ; Remember to update also add-strings.py when bumping the Windows version.
  LangString min_windows_version ${LANG_ENGLISH} "${PROJECT_NAME} requires Windows 10 or later."
  LangString destination_exists ${LANG_ENGLISH} "The destination folder already exists. Do you want to continue anyway?"

  ; Mullvad Browser strings
  ; Use %s instead of ${DISPLAY_NAME} for localization.
  LangString welcome_title ${LANG_ENGLISH} "Welcome to the ${DISPLAY_NAME} installer"
  ; Use %s instead of ${PROJECT_NAME} for localization
  LangString mb_intro ${LANG_ENGLISH} "${PROJECT_NAME} is a privacy-focused web browser designed to minimize tracking and fingerprinting."
  LangString installation_type ${LANG_ENGLISH} "Installation type"
  LangString standard ${LANG_ENGLISH} "Standard"
  LangString update_current ${LANG_ENGLISH} "Update current installation"
  LangString advanced ${LANG_ENGLISH} "Advanced"
  LangString update_button ${LANG_ENGLISH} "&Update"
  LangString advanced_setup ${LANG_ENGLISH} "Advanced Installation"
  LangString desktop_shortcut ${LANG_ENGLISH} "Add desktop icon"
  LangString standalone_installation ${LANG_ENGLISH} "Standalone installation"
  ; Use %s instead of ${PROJECT_NAME} for localization
  LangString standalone_description ${LANG_ENGLISH} "Choose the standalone installation if you want to install ${PROJECT_NAME} in its own dedicated folder, without adding it to the Start menu and to the list of applications."

  ; The rest of the languages and translated strings will be added here by
  ; add-strings.py.
