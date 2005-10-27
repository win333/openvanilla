; Script generated by the HM NIS Edit Script Wizard.

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "OpenVanilla-Modules"
!define PRODUCT_VERSION "0.7.1rc0+r1485"
!define PRODUCT_PUBLISHER "openvanilla.org"
!define PRODUCT_WEB_SITE "http://openvanilla.org"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

SetCompressor lzma

; MUI 1.67 compatible ------
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!insertmacro MUI_PAGE_LICENSE "..\..\..\Documents\OSX\Installer\zh_TW.lproj\License.rtf"
; Directory page
;!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "TradChinese"

; Reserve files
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "OpenVanilla-Win32-Modules.exe"
InstallDir "$WINDIR\OpenVanilla"
ShowInstDetails show
ShowUnInstDetails show

Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Section "MainSection" SEC01
  SetOutPath "$WINDIR\OpenVanilla"
  SetOVerwrite ifnewer
  File /r "Modules"
  SetOutPath "$SYSDIR"
  File "System32\libchewing.dll"
  File "System32\sqlite3.dll"
SectionEnd

Section -AdditionalIcons
  SetOutPath $INSTDIR
  CreateDirectory "$SMPROGRAMS\OpenVanilla"
  CreateShortCut "$SMPROGRAMS\OpenVanilla\Uninstall-Modules.lnk" "$INSTDIR\uninst-modules.exe"
SectionEnd

Section -Post
WriteUninstaller "$INSTDIR\uninst-modules.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst-modules.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd


Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "OpenVanilla-Modules �w���\�a�q�A���q�������C"
FunctionEnd

Function un.onInit
!insertmacro MUI_UNGETLANGUAGE
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "�A�T�w�n�������� OpenVanilla-Modules �A��ΩҦ�������H" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  Delete "$INSTDIR\uninst-modules.exe"
  Delete "$SYSDIR\sqlite3.dll"
  Delete "$SYSDIR\libchewing.dll"
  RMDir /r "$WINDIR\OpenVanilla\zh_TW"
  
  Rename "$WINDIR\OpenVanilla\Modules\OVIMRoman.DLL" "$WINDIR\OpenVanilla\OVIMRoman.DLL"
  RMDir /r "$WINDIR\OpenVanilla\Modules"
  CreateDirectory "$WINDIR\OpenVanilla\Modules"
  Rename "$WINDIR\OpenVanilla\OVIMRoman.DLL" "$WINDIR\OpenVanilla\Modules\OVIMRoman.DLL"

  Delete "$SMPROGRAMS\OpenVanilla\Uninstall-Modules.lnk"

  RMDir "$SMPROGRAMS\OpenVanilla"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
 
  SetAutoClose true
SectionEnd