@echo off
setlocal EnableDelayedExpansion
title ERP System Installer

set "DIR=%~dp0"
set "DIR=%DIR:~0,-1%"

echo.
echo  ============================================
echo   ERP System - Windows Installer
echo  ============================================
echo.

:: Check admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] This script requires Administrator privileges.
    echo [!] Right-click install.bat and select "Run as administrator"
    pause
    exit /b 1
)

:: ── Step 1: Install Winget if missing ────────────────────────────────────────
echo [1/5] Checking package manager...
winget --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] winget not found. Please install it from the Microsoft Store
    echo     or update Windows to version 1809+
    pause
    exit /b 1
)
echo [OK] winget available

:: ── Step 2: Install Docker Desktop ───────────────────────────────────────────
echo.
echo [2/5] Checking Docker...
docker --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [*] Installing Docker Desktop...
    winget install -e --id Docker.DockerDesktop --silent --accept-package-agreements --accept-source-agreements
    if %errorLevel% neq 0 (
        echo [!] Docker installation failed.
        echo     Please install manually from: https://www.docker.com/products/docker-desktop
        pause
        exit /b 1
    )
    echo [OK] Docker Desktop installed
    echo.
    echo [!] Docker Desktop was just installed.
    echo     Please:
    echo       1. Start Docker Desktop from the Start Menu
    echo       2. Wait for it to fully start (whale icon in taskbar)
    echo       3. Run this installer again
    echo.
    pause
    exit /b 0
) else (
    echo [OK] Docker already installed: 
    docker --version
)

:: ── Step 3: Check Docker is running ──────────────────────────────────────────
echo.
echo [3/5] Checking Docker is running...
docker info >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Docker is installed but not running.
    echo     Please start Docker Desktop and wait for it to fully load,
    echo     then run this installer again.
    pause
    exit /b 1
)
echo [OK] Docker is running

:: ── Step 4: Install Python (for manage.py) ───────────────────────────────────
echo.
echo [4/5] Checking Python...
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [*] Installing Python...
    winget install -e --id Python.Python.3.12 --silent --accept-package-agreements --accept-source-agreements
    :: Refresh PATH
    call refreshenv >nul 2>&1
    set "PATH=%PATH%;%LOCALAPPDATA%\Programs\Python\Python312;%LOCALAPPDATA%\Programs\Python\Python312\Scripts"
)
echo [OK] Python ready

:: ── Step 5: Build and start ERP ──────────────────────────────────────────────
echo.
echo [5/5] Building and starting ERP system...
echo     (This may take 5-10 minutes on first run)
echo.
cd /d "%DIR%"
docker compose up -d --build
if %errorLevel% neq 0 (
    echo [!] Failed to start ERP system. Check Docker Desktop is running.
    pause
    exit /b 1
)

:: Wait for health
echo.
echo [*] Waiting for system to be ready...
set /a attempts=0
:waitloop
set /a attempts+=1
if %attempts% gtr 30 goto timeout
curl -sf http://localhost/api/health >nul 2>&1
if %errorLevel% neq 0 (
    timeout /t 3 /nobreak >nul
    goto waitloop
)
goto ready

:timeout
echo [!] System is taking longer than expected. Check: docker compose logs
goto done

:ready
echo [OK] System is UP!

:: ── Create desktop shortcut ───────────────────────────────────────────────────
echo.
echo [*] Creating desktop shortcut...
set "SHORTCUT=%USERPROFILE%\Desktop\ERP System.lnk"
set "TARGET=%DIR%\open.bat"

:: Create open.bat
echo @echo off > "%DIR%\open.bat"
echo start http://localhost >> "%DIR%\open.bat"

:: Create shortcut via PowerShell
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SHORTCUT%'); $s.TargetPath = '%DIR%\open.bat'; $s.IconLocation = 'shell32.dll,14'; $s.Description = 'Open ERP System'; $s.Save()"
echo [OK] Desktop shortcut created

:: ── Create erp.bat command ────────────────────────────────────────────────────
copy /y "%DIR%\erp.bat" "%SystemRoot%\System32\erp.bat" >nul 2>&1

:: Create erp.bat in system32
echo @echo off > "%SystemRoot%\System32\erp.bat"
echo python "%DIR%\manage.py" %%* >> "%SystemRoot%\System32\erp.bat"

:: ── Auto-start on Windows login ───────────────────────────────────────────────
echo [*] Setting up auto-start...
set "TASK_CMD=docker compose -f \"%DIR%\docker-compose.yml\" start"
schtasks /create /tn "ERP System" /tr "cmd /c cd /d \"%DIR%\" && docker compose start" /sc onlogon /ru "%USERNAME%" /f >nul 2>&1
echo [OK] Auto-start on login enabled

:done
echo.
echo  ============================================
echo   ERP System is ready!
echo  ============================================
echo.
echo   URL:      http://localhost
echo   Login:    ammar
echo   Password: changeme
echo.
echo   Commands (run in any terminal):
echo     erp status
echo     erp backup
echo     erp restore ^<file^>
echo     erp restart
echo     erp logs
echo.
echo   A shortcut was created on your Desktop.
echo  ============================================
echo.
echo  [!] Change the default password after first login!
echo.
pause
