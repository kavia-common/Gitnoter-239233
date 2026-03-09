@echo off
setlocal enabledelayedexpansion

REM Allow overriding build output directory (e.g. from CI)
REM Default keeps the historical path used by the original project.
if "%BUILD_DIR%"=="" (
  set "BUILD_DIR=..\build-Gitnoter-Desktop_Qt_5_9_3_MSVC2015_32bit-Release\release"
)

set "APP_EXE=%BUILD_DIR%\Gitnoter.exe"

if not exist "%APP_EXE%" (
  echo ERROR: App binary not found at: %APP_EXE%
  echo Set BUILD_DIR to your Qt build output directory (the folder that contains Gitnoter.exe).
  exit /b 1
)

rd /s/q .\release\Gitnoter 2>nul
del /q .\release\Gitnoter.zip 2>nul
md .\release\Gitnoter

copy /y "%APP_EXE%" .\release\Gitnoter\

REM windeployqt must be available on PATH
windeployqt.exe .\release\Gitnoter\Gitnoter.exe --release

xcopy .\window-missing-dll .\release\Gitnoter\ /s/f/h/y >nul

REM Optional: try to extract version from src\version.h, else fall back to unversioned name
set "VERSION="
for /f "tokens=2 delims=\" %%a in ('findstr /c:"VER_PRODUCTVERSION_STR" ..\src\version.h') do (
  set "VERSION=%%a"
  goto :havever
)
:havever

if not "%VERSION%"=="" (
  7z.exe a -tzip -r ".\release\Gitnoter-windows-v%VERSION%.zip" .\release\Gitnoter >nul
) else (
  7z.exe a -tzip -r ".\release\Gitnoter-windows-v.zip" .\release\Gitnoter >nul
)

endlocal
