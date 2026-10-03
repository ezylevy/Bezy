@echo off
chcp 65001 >nul
echo Building the signed BEZY App Bundle for Google Play (takes a few minutes)...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0app\tool\build_play_bundle.ps1"
echo.
echo Finished. Tell Claude "built" - the log is in app\diagnostics\play-bundle.log
echo.
pause
