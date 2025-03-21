!include MUI2.nsh

SetPluginUnload  alwaysoff

Unicode true
Name "ScanKass" 
!define MUI_WELCOMEPAGE_TEXT "Эта программа установит ScanKass на ваш компьютер.$\r$\n$\r$\nScanKass - это приложение для комплексного мониторинга кассового ПО и оборудования.$\r$\n$\r$\nПеред началом установки рекомендуется закрыть все работающие приложения. Это позволит программе установки обновить системные файлы без перезагрузки компьютера.$\r$\n$\r$\nНажмите кнопку$\"Далее$\" для продолжения."
!ifdef Test
OutFile "ScanKassSetup-Test.exe"
!else
OutFile "ScanKassSetup.exe"
!endif
InstallDir "C:\ScanKass\"
RequestExecutionLevel admin

Function .onInit
  SectionSetSize 1 32216
  SectionSetSize 2 4718592
  SectionSetSize 4 388590
FunctionEnd

Section "-hidden StopAndDelete" SEC01
  ExecWait "taskkill /IM ScanKassRunnerService.exe /F"
  ExecWait "taskkill /IM ScanKassWatcherService.exe /F"
  ExecWait "taskkill /IM ScanKassStatus.exe /F"
  SimpleSC::StopService "Zabbix Agent" 0 30
  SimpleSC::StopService "ScanKassRunner" 0 30
  SimpleSC::StopService "ScanKassWatcher" 0 30
  SimpleSC::RemoveService "Zabbix Agent"
  SimpleSC::RemoveService "ScanKassRunner"
  SimpleSC::RemoveService "ScanKassWatcher"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir /r "$INSTDIR"
SectionEnd

Section "-hidden Install" SEC02
  SetOutPath "$INSTDIR"
  File /r app\* 
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ScanKass" "InstallLocation" $INSTDIR  
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ScanKass" "DisplayName" "ScanKass"  
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ScanKass" "DisplayIcon" "$INSTDIR\WIZARD\SetupWizard.exe"  
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ScanKass" "Publisher" "ООО СканКасс"  
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ScanKass" "ModifyPath" "$INSTDIR\WIZARD\SetupWizard.exe"  
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ScanKass" "UninstallString" "$INSTDIR\Uninstall.exe" 
  WriteUninstaller "$INSTDIR\Uninstall.exe"  
SectionEnd

Section "Установка Framework 4.8" SEC03
  ExecWait "$INSTDIR\BIN\framework48.exe"
SectionEnd

Section "-hidden Wizard" SEC04
!ifdef Test
  ExecWait "$INSTDIR\WIZARD\SetupWizard.exe sav@kkm18.ru"
!else
!ifdef Email
  ExecWait "$INSTDIR\WIZARD\SetupWizard.exe ${Email}"
!else
  ExecWait "$INSTDIR\WIZARD\SetupWizard.exe"
!endif
!endif
SectionEnd

Section "Планировщик" SEC05
  DetailPrint "Установка планировщика (занимает 1-5 минут)"
  System::Call '$INSTDIR\skatworker_installation.dll::install() i .r1 '
  SetPluginUnload manual
  System::Free 0
SectionEnd

Section "-hidden Services" SEC06
  SimpleSC::InstallService "ScanKassRunner" "ScanKass Runner" "16" "2" "$INSTDIR\ScanKassRunnerService.exe" "" "" ""
  SimpleSC::InstallService "ScanKassWatcher" "ScanKass Watcher" "16" "2" "$INSTDIR\ScanKassWatcherService.exe" "" "" ""
  ExecWait "$INSTDIR\BIN\zabbix_agentd.exe --config $INSTDIR\CONF\zabbix_agentd.conf --install"
  SimpleSC::StartService "ScanKassRunner" "" 30
  SimpleSC::StartService "ScanKassWatcher" "" 30
  SimpleSC::StartService "Zabbix Agent" "" 30
SectionEnd

Section "Uninstall"
  ExecWait "taskkill /IM ScanKassRunnerService.exe /F"
  ExecWait "taskkill /IM ScanKassWatcherService.exe /F"
  ExecWait "taskkill /IM ScanKassStatus.exe /F"
  SimpleSC::StopService "ScanKassRunner" 0 30
  SimpleSC::StopService "Zabbix Agent" 0 30
  SimpleSC::StopService "ScanKassWatcher" 0 30
  SimpleSC::RemoveService "ScanKassRunner"
  SimpleSC::RemoveService "Zabbix Agent"
  SimpleSC::RemoveService "ScanKassWatcher"
  ExecWait "powershell -ExecutionPolicy Bypass -File '$INSTDIR\WIZARD\RestoreLogPathes.ps1'"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir /r "$INSTDIR"
  # Добавить удаление планировщика
  DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ScanKass"
SectionEnd

!define MUI_UNICON logo.ico
!define MUI_ICON logo.ico
!define MUI_UNWELCOMEFINISHPAGE_BITMAP banner.bmp
!define MUI_WELCOMEFINISHPAGE_BITMAP banner.bmp

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE license.txt
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "Russian"