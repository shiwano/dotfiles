@echo off
setlocal

set "SRC=%~dp0"
set "SRC=%SRC:~0,-1%"
set "DEST=%USERPROFILE%\Documents"

echo Copying files from %SRC% to %DEST% ...

robocopy "%SRC%" "%DEST%" /E /IS /IT /XF setup.bat

if %ERRORLEVEL% LEQ 3 (
    echo Done.
) else (
    echo Error occurred. errorlevel=%ERRORLEVEL%
    exit /b 1
)

set "GHOSTTY_SRC=%~dp0..\dot.config\ghostty"
set "GHOSTTY_DEST=%LOCALAPPDATA%\ghostty"

echo Copying Ghostty config from %GHOSTTY_SRC% to %GHOSTTY_DEST% ...

robocopy "%GHOSTTY_SRC%" "%GHOSTTY_DEST%" /E /IS /IT

if %ERRORLEVEL% LEQ 3 (
    echo Done.
) else (
    echo Error occurred. errorlevel=%ERRORLEVEL%
    exit /b 1
)

endlocal
pause
