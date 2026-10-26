@echo off
REM Windows: double-click this file. Run it again for a second terminal.
cd /d "%~dp0"
docker info >nul 2>&1
if errorlevel 1 (
  echo Docker is not running. Start Docker Desktop, wait for "Engine running", then try again.
  goto :fail
)
for /f "delims=" %%i in ('docker compose config --images lab') do set LABIMG=%%i
docker image inspect %LABIMG% >nul 2>&1
if errorlevel 1 (
  echo First run: getting the lab ready ^(about 1 GB, 5-10 minutes, one time only^)...
  echo %LABIMG% | find "/" >nul
  if errorlevel 1 ( docker compose build lab ) else ( docker compose pull lab || docker compose build lab )
  if errorlevel 1 goto :fail
)
docker compose up -d lab
if errorlevel 1 goto :fail
docker compose exec lab bash
echo.
echo Lab closed. Double-click start-lab.bat to open it again.
pause
exit /b 0
:fail
echo.
echo Something went wrong ^(see the message above^). Take a screenshot of this window and send it to your instructor.
pause
exit /b 1
