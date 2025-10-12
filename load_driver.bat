@echo off
REM ================================================================
REM Driver Loader Script for infinity_hook_pro_max.sys
REM For security research and testing purposes only
REM ================================================================

echo.
echo [*] Infinity Hook Driver Loader
echo [*] For research purposes only
echo.

REM Check for admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] ERROR: Administrator privileges required
    echo [!] Right-click and select "Run as Administrator"
    pause
    exit /b 1
)

REM Set driver paths
set DRIVER_NAME=InfinityHookPro
set DRIVER_PATH=%~dp0infinity_hook_pro_max.sys
set BUILD_PATH=%~dp0build-artifacts\infinity_hook_pro_max.sys

REM Check if driver exists
if not exist "%DRIVER_PATH%" (
    if exist "%BUILD_PATH%" (
        echo [*] Using driver from build-artifacts folder
        set DRIVER_PATH=%BUILD_PATH%
    ) else (
        echo [!] ERROR: Driver file not found
        echo [!] Expected: %DRIVER_PATH%
        pause
        exit /b 1
    )
)

echo [*] Driver found: %DRIVER_PATH%
echo.

:MENU
echo Select loading method:
echo   1. Test Mode (Recommended for first-time setup)
echo   2. Service Manager (Standard method)
echo   3. Check current status
echo   4. Unload driver
echo   5. Exit
echo.
set /p choice="Enter choice (1-5): "

if "%choice%"=="1" goto TEST_MODE
if "%choice%"=="2" goto SERVICE_LOAD
if "%choice%"=="3" goto CHECK_STATUS
if "%choice%"=="4" goto UNLOAD
if "%choice%"=="5" exit /b 0
goto MENU

:TEST_MODE
echo.
echo [*] Checking test signing status...
bcdedit | findstr -i "testsigning" | findstr -i "Yes" >nul
if %errorlevel% equ 0 (
    echo [+] Test signing already enabled
    goto SERVICE_LOAD
) else (
    echo [*] Enabling test signing mode...
    bcdedit /set testsigning on
    echo [!] RESTART REQUIRED: Please restart your computer
    echo [!] After restart, run this script again and select option 2
    pause
    exit /b 0
)

:SERVICE_LOAD
echo.
echo [*] Creating driver service...

REM Check if service exists
sc query %DRIVER_NAME% >nul 2>&1
if %errorlevel% equ 0 (
    echo [*] Service already exists, attempting to stop...
    sc stop %DRIVER_NAME% >nul 2>&1
    timeout /t 2 >nul
    sc delete %DRIVER_NAME% >nul 2>&1
    timeout /t 2 >nul
)

REM Create service
sc create %DRIVER_NAME% type=kernel binPath="%DRIVER_PATH%" DisplayName="Infinity Hook Pro Driver"
if %errorlevel% neq 0 (
    echo [!] ERROR: Failed to create service
    pause
    goto MENU
)

echo [*] Starting driver service...
sc start %DRIVER_NAME%
if %errorlevel% neq 0 (
    echo [!] ERROR: Failed to start driver
    echo [!] Possible causes:
    echo     - Driver not signed (enable test mode first)
    echo     - Secure Boot enabled (disable in BIOS)
    echo     - Antivirus blocking driver load
    sc delete %DRIVER_NAME% >nul 2>&1
    pause
    goto MENU
)

echo [+] Driver loaded successfully!
echo [+] SetWindowDisplayAffinity bypass is now active
pause
goto MENU

:CHECK_STATUS
echo.
sc query %DRIVER_NAME% 2>nul | findstr "STATE"
if %errorlevel% neq 0 (
    echo [!] Driver service not found
) else (
    echo [*] Driver service exists
)

REM Check if driver is in memory
driverquery | findstr -i "infinity_hook" >nul 2>&1
if %errorlevel% equ 0 (
    echo [+] Driver is loaded in kernel memory
) else (
    echo [-] Driver is not loaded in kernel memory
)

pause
goto MENU

:UNLOAD
echo.
echo [*] Stopping driver service...
sc stop %DRIVER_NAME% >nul 2>&1
timeout /t 2 >nul

echo [*] Deleting driver service...
sc delete %DRIVER_NAME% >nul 2>&1

echo [+] Driver unloaded
pause
goto MENU