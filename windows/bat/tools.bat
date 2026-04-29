@echo off
setlocal

set TOOLS=VideoLAN.VLC DuongDieuPhap.ImageGlass 7zip.7zip

for %%T in (%TOOLS%) do (
	winget list --id %%T >nul 2>&1
	if errorlevel 1 (
		echo Installing %%T ...
		winget install --id %%T --exact --accept-source-agreements --accept-package-agreements
	) else (
		echo %%T is already installed.
	)
)

set FONT_INSTALLED=0
reg query "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /f "Moralerspace Neon" >nul 2>&1
if not errorlevel 1 set FONT_INSTALLED=1
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /f "Moralerspace Neon" >nul 2>&1
if not errorlevel 1 set FONT_INSTALLED=1

if %FONT_INSTALLED%==0 (
	echo Installing Moralerspace Neon ...
	powershell -ExecutionPolicy Bypass -Command ^
		"$release = Invoke-RestMethod 'https://api.github.com/repos/yuru7/moralerspace/releases/latest';" ^
		"$asset = $release.assets | Where-Object { $_.name -match '^Moralerspace_v' } | Select-Object -First 1;" ^
		"$tmp = Join-Path $env:TEMP 'moralerspace';" ^
		"$zip = Join-Path $env:TEMP 'moralerspace.zip';" ^
		"Remove-Item -Path $tmp, $zip -Recurse -Force -ErrorAction SilentlyContinue;" ^
		"Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zip;" ^
		"Expand-Archive -Path $zip -DestinationPath $tmp;" ^
		"$fonts = (New-Object -ComObject Shell.Application).Namespace(0x14);" ^
		"Get-ChildItem -Path $tmp -Filter 'MoralerspaceNeon*.ttf' -Recurse | ForEach-Object { $fonts.CopyHere($_.FullName, 0x10) };" ^
		"Remove-Item -Path $tmp, $zip -Recurse -Force -ErrorAction SilentlyContinue"
) else (
	echo Moralerspace Neon is already installed.
)

endlocal
pause
