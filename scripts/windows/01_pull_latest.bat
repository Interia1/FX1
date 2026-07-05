@echo off
setlocal

echo [FX1] Pull latest changes...

set REPO_DIR=%~dp0..\..\
pushd "%REPO_DIR%"

if not exist ".git" (
  echo [ERROR] .git not found. Run this script from FX1_repo\scripts\windows.
  popd
  pause
  exit /b 1
)

git fetch origin
if errorlevel 1 (
  echo [ERROR] git fetch failed.
  popd
  pause
  exit /b 1
)

git pull --ff-only origin main
if errorlevel 1 (
  echo [ERROR] git pull failed. Check local changes or network.
  popd
  pause
  exit /b 1
)

echo [OK] Repository updated to latest main.
echo [NEXT] Open MetaEditor and press F7 to compile FX1_EA.mq5.

popd
pause
exit /b 0
