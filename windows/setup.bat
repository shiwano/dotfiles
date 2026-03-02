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

endlocal
