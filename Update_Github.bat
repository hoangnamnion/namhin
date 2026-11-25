@echo off
setlocal EnableExtensions
chcp 65001 >nul

set "SOURCE=%~1"
set "REPO=%~2"

if "%SOURCE%"=="" set "SOURCE=%CD%"
if "%REPO%"=="" set "REPO=%CD%"

title Update GitHub
echo ================================================
echo   DONG BO VA DAY DU AN LEN GITHUB
echo ================================================

if not exist "%SOURCE%\" (
  echo [LOI] Khong tim thay thu muc nguon: %SOURCE%
  pause
  exit /b 1
)

if not exist "%REPO%\.git\" (
  echo [LOI] Khong tim thay Git repository: %REPO%
  pause
  exit /b 1
)

echo [1/5] Dong bo tu: %SOURCE%
if /i "%SOURCE%"=="%REPO%" goto sync_done
robocopy "%SOURCE%" "%REPO%" /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /XD ".git"
if errorlevel 8 (
  echo [LOI] Robocopy that bai.
  pause
  exit /b 1
)

:sync_done
cd /d "%REPO%"

echo [2/5] Lay main moi nhat
git fetch origin main
if errorlevel 1 goto failed

echo [3/5] Gop main neu can
git merge origin/main --no-edit
if errorlevel 1 (
  echo [LOI] Co xung dot Git. Giai quyet xung dot roi bam lai nut nay.
  pause
  exit /b 1
)

echo [4/5] Tao commit
git add -A
git diff --cached --quiet
if not errorlevel 1 (
  echo.
  echo Khong co thay doi moi.
  pause
  exit /b 0
)

git commit -m "Update website" -m "Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>"
if errorlevel 1 goto failed

echo [5/5] Push len main
git push origin HEAD:main
if errorlevel 1 goto failed

echo.
echo ================================================
echo   UPDATE THANH CONG
echo ================================================
pause
exit /b 0

:failed
echo.
echo ================================================
echo   UPDATE THAT BAI - XEM LOI PHIA TREN
echo ================================================
pause
exit /b 1
