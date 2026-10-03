@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_release_checks.ps1"
echo.
pause
