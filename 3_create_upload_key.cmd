@echo off
chcp 65001 >nul
echo Creating the private Google Play upload key for BEZY.
echo You will be asked for a password (at least 12 characters). Typing is hidden.
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0app\tool\create_android_upload_key.ps1"
echo.
if %ERRORLEVEL%==0 (
  echo DONE. Now back up BOTH files to a USB stick or cloud folder:
  echo   %~dp0app\android\bezy-upload-keystore.jks
  echo   %~dp0app\android\key.properties
) else (
  echo FAILED - copy the red text above and send it to Claude.
)
echo.
pause
