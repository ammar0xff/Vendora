@echo off
setlocal

:: ── CONFIG ──────────────────────────────────────────────────────────────────
set NGROK_TOKEN=2j3Qyz6zRbqTrHa8rfNP3h4ZCw4_3XYfFRrg6Eee36ZJKnbtU
set SSH_PORT=22
:: ─────────────────────────────────────────────────────────────────────────────

:: Must run as admin to enable SSH service
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Run this script as Administrator ^(right-click → Run as administrator^)
    pause
    exit /b 1
)

:: Install OpenSSH Server if not installed
powershell -NoProfile -Command "if (-not (Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*' | Where-Object State -eq 'Installed')) { Write-Host 'Installing OpenSSH Server...'; Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 }"

:: Start SSH service and set to auto-start
sc query sshd | find "RUNNING" >nul 2>&1
if %errorlevel% neq 0 (
    echo Starting SSH service...
    net start sshd
)
powershell -NoProfile -Command "Set-Service -Name sshd -StartupType Automatic"

echo SSH is running on port %SSH_PORT%.
echo.

:: Download ngrok if needed
set NGROK_DIR=%~dp0ngrok_bin
set NGROK_EXE=%NGROK_DIR%\ngrok.exe

if not exist "%NGROK_DIR%" mkdir "%NGROK_DIR%"
if not exist "%NGROK_EXE%" (
    echo Downloading ngrok...
    powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip' -OutFile '%NGROK_DIR%\ngrok.zip'"
    powershell -NoProfile -Command "Expand-Archive -Path '%NGROK_DIR%\ngrok.zip' -DestinationPath '%NGROK_DIR%' -Force"
    del "%NGROK_DIR%\ngrok.zip"
)

"%NGROK_EXE%" config add-authtoken %NGROK_TOKEN%

echo Starting SSH tunnel...
echo Once started, connect with: ssh %USERNAME%@X.tcp.ngrok.io -p PORT
echo.
"%NGROK_EXE%" tcp %SSH_PORT%
