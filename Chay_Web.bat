@echo off
title Khoi dong Web Dao Hin Si Gon
chcp 65001 >nul
cd /d "%~dp0"
echo ========================================================
echo   DANG KHOI CHAY WEB DAO HIN SI GON (THO LAND)...
echo ========================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1"
pause
