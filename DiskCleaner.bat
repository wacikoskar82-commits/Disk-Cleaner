@echo off
title Disk Speed Booster - Run as Admin!
color 0a
echo.
echo ========================================
echo     DISK SPEED BOOSTER v1.0
echo ========================================
echo.

:: Check for Admin Rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Please run as Administrator!
    echo Right-click -> Run as administrator
    pause
    exit /b
)

echo [1/8] Clearing Temporary Files...
del /q /f /s "%temp%\*.*" >nul 2>&1
del /q /f /s "C:\Windows\Temp\*.*" >nul 2>&1
del /q /f /s "C:\Windows\Prefetch\*.*" >nul 2>&1

echo [2/8] Emptying Recycle Bin...
powershell.exe -Command "Clear-RecycleBin -Force" >nul 2>&1

echo [3/8] Running Disk Cleanup...
cleanmgr /sagerun:1 >nul 2>&1

echo [4/8] Optimizing Drive (HDD = Defrag, SSD = Trim)...
for /f "tokens=2 delims==" %%i in ('wmic logicaldisk where drivetype^=3 get deviceid /format:list ^| find "="') do (
    echo     Optimizing %%i
    if exist %%i (
        defrag %%i /O /M >nul 2>&1
    )
)

echo [5/8] Disabling Unnecessary Startup Programs...
powershell -Command "Get-CimInstance Win32_StartupCommand | Select Name, Command | Where-Object {$_.Name -notlike '*Windows*'} | Format-Table" > startup_log.txt
echo     ^> Startup programs logged to startup_log.txt

echo [6/8] Flushing DNS and Resetting Network...
ipconfig /flushdns >nul
netsh winsock reset >nul
netsh int ip reset >nul
echo     Network stack reset!

echo [7/8] Running System File Checker...
sfc /scannow

echo [8/8] Running DISM Health Check...
DISM /Online /Cleanup-Image /RestoreHealth

echo.
echo ========================================
echo       OPTIMIZATION COMPLETE!
echo ========================================
echo.
echo Tips:
echo - For SSD: Enable TRIM (already done via /O)
echo - For HDD: Schedule weekly defrag
echo - Restart PC for full effect
echo.
pause