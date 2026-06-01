@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1

:: ============================================================
:: WSL2 + Docker Disk Cleanup Script
::
:: WSL2 vhdx files do not automatically shrink even after
:: deleting Docker images/containers. This script:
::   1. Removes unused Docker resources
::   2. Shuts down WSL
::   3. Compacts vhdx files via diskpart
::
:: Must be run as Administrator.
:: ============================================================

:: Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [Error] Administrator privileges required. Right-click and select "Run as administrator".
    pause
    exit /b 1
)

echo ============================================================
echo  WSL2 + Docker Disk Cleanup
echo ============================================================
echo.

:: Step 1: Remove unused Docker resources
echo [1/4] Removing unused Docker resources...
wsl -- docker system prune -a --volumes -f >nul 2>&1
if %errorlevel% equ 0 (
    echo       Done.
) else (
    echo       Docker not found or not running. Skipping.
)
echo.

:: Step 2: Shut down WSL
echo [2/4] Shutting down WSL...
wsl --shutdown
echo       Done.
echo.

:: Step 3: Search for vhdx files
echo [3/4] Searching for vhdx files...
set "found=0"
set "idx=0"

:: WSL distributions (under %LOCALAPPDATA%\wsl)
if exist "%LOCALAPPDATA%\wsl" (
    for /r "%LOCALAPPDATA%\wsl" %%f in (ext4.vhdx) do (
        if /i not "%%~dpf"=="%LOCALAPPDATA%\wsl\" (
            set /a idx+=1
            set "vhdx_!idx!=%%f"
            set "found=1"
            echo       Found: %%f
        )
    )
)

:: Docker Desktop (under %LOCALAPPDATA%\Docker\wsl)
if exist "%LOCALAPPDATA%\Docker\wsl" (
    for /r "%LOCALAPPDATA%\Docker\wsl" %%f in (ext4.vhdx) do (
        set /a idx+=1
        set "vhdx_!idx!=%%f"
        set "found=1"
        echo       Found: %%f
    )
)

if "!found!"=="0" (
    echo       No vhdx files found.
    echo.
    pause
    exit /b 0
)

set "total=!idx!"
echo       Found !total! vhdx file(s) in total.
echo.

:: Step 4: Compact vhdx files via diskpart
echo [4/4] Compacting vhdx files...
echo.

for /l %%i in (1,1,!total!) do (
    call :compact_vhdx %%i !total!
)
goto :done

:compact_vhdx
set "i=%~1"
set "t=%~2"
set "vhdx_path=!vhdx_%i%!"
echo       [%i%/%t%] Processing: !vhdx_path!

:: Get size before compaction (via PowerShell, to handle >2GB files)
for /f %%s in ('powershell -nologo -noprofile -command "(Get-Item '!vhdx_path!').Length / 1MB -as [int]"') do set "before_mb=%%s"

:: Write diskpart script to temp file and execute
set "dp_script=%TEMP%\wsl-disk-cleanup-diskpart.txt"
(
    echo select vdisk file="!vhdx_path!"
    echo compact vdisk
    echo exit
) > "!dp_script!"

diskpart /s "!dp_script!"
if !errorlevel! neq 0 (
    echo.
    echo       [Warning] Failed to compact: !vhdx_path!
    echo.
    del "!dp_script!" >nul 2>&1
    exit /b 0
)

:: Get size after compaction (via PowerShell, to handle >2GB files)
for /f %%s in ('powershell -nologo -noprofile -command "(Get-Item '!vhdx_path!').Length / 1MB -as [int]"') do set "after_mb=%%s"
set /a saved_mb=!before_mb! - !after_mb!

echo.
echo       Before: !before_mb! MB -^> After: !after_mb! MB (Saved: !saved_mb! MB)
echo.

del "!dp_script!" >nul 2>&1
exit /b 0

:done
echo ============================================================
echo  Cleanup complete!
echo ============================================================
echo.
pause
