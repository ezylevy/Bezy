@echo off
chcp 65001 >nul
set "SRC=%~dp0app\build\app\outputs\flutter-apk\app-release.apk"
set "DST=%USERPROFILE%\Desktop\BEZY.apk"
if not exist "%SRC%" (
  echo APK not found. Run app\tool\run_release_checks.cmd first.
  pause
  exit /b 1
)
copy /y "%SRC%" "%DST%" >nul
echo BEZY.apk was copied to your Desktop.
echo Send it to your phone (Google Drive / WhatsApp to yourself / USB cable),
echo open it on the phone and allow "Install unknown apps" when asked.
explorer /select,"%DST%"
echo.
pause
