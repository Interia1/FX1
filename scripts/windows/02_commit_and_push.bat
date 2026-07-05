@echo off
setlocal

echo [FX1] Commit and push current changes...

set REPO_DIR=%~dp0..\..\
pushd "%REPO_DIR%"

if not exist ".git" (
  echo [ERROR] .git not found. Run this script from FX1_repo\scripts\windows.
  popd
  pause
  exit /b 1
)

git add -A
if errorlevel 1 (
  echo [ERROR] git add failed.
  popd
  pause
  exit /b 1
)

set /p MSG=Enter commit message: 
if "%MSG%"=="" set MSG=Update FX1

git commit -m "%MSG%"
if errorlevel 1 (
  echo [INFO] Nothing to commit or commit failed.
)

git push origin main
if errorlevel 1 (
  echo [ERROR] git push failed.
  popd
  pause
  exit /b 1
)

echo [OK] Changes pushed to origin/main.

popd
pause
exit /b 0
