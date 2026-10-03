@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo Pushing BEZY commits to GitHub...
echo (If a GitHub sign-in window opens, sign in as ezylevy.)
echo.
git push
echo.
if %ERRORLEVEL%==0 (echo DONE - push succeeded.) else (echo PUSH FAILED - copy the text above and send it to Claude.)
echo.
pause
