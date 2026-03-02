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

:: WSL distributions (under Packages)
for /r "%LOCALAPPDATA%\Packages" %%f in (ext4.vhdx) do (
    set /a idx+=1
    set "vhdx_!idx!=%%f"
    set "found=1"
    echo       Found: %%f
)

:: Docker Desktop (under Docker\wsl)
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
    set "vhdx_path=!vhdx_%%i!"
    echo       [%%i/!total!] Processing: !vhdx_path!

    :: Get size before compaction
    for %%s in ("!vhdx_path!") do set "before_size=%%~zs"

    :: Write diskpart script to temp file and execute
    set "dp_script=%TEMP%\wsl-disk-cleanup-diskpart.txt"
    (
        echo select vdisk file="!vhdx_path!"
        echo compact vdisk
        echo exit
    ) > "!dp_script!"

    diskpart /s "!dp_script!"

    :: Get size after compaction
    for %%s in ("!vhdx_path!") do set "after_size=%%~zs"

    :: Display sizes in MB
    set /a before_mb=!before_size! / 1048576
    set /a after_mb=!after_size! / 1048576
    set /a saved_mb=!before_mb! - !after_mb!

    echo.
    echo       Before: !before_mb! MB -^> After: !after_mb! MB (Saved: !saved_mb! MB)
    echo.

    del "!dp_script!" >nul 2>&1
)

echo ============================================================
echo  Cleanup complete!
echo ============================================================
echo.
pause
