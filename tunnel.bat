@echo off
setlocal

:: ── CONFIG ──────────────────────────────────────────────────────────────────
set NGROK_TOKEN=YOUR_NGROK_AUTHTOKEN_HERE
set SSH_PORT=22
:: ─────────────────────────────────────────────────────────────────────────────

set NGROK_DIR=%~dp0ngrok_bin
set NGROK_EXE=%NGROK_DIR%\ngrok.exe
set NGROK_ZIP=%NGROK_DIR%\ngrok.zip

if not exist "%NGROK_DIR%" mkdir "%NGROK_DIR%"

if not exist "%NGROK_EXE%" (
    echo Downloading ngrok...
    powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip' -OutFile '%NGROK_ZIP%'"
    powershell -NoProfile -Command "Expand-Archive -Path '%NGROK_ZIP%' -DestinationPath '%NGROK_DIR%' -Force"
    del "%NGROK_ZIP%"
    echo Done.
)

"%NGROK_EXE%" config add-authtoken %NGROK_TOKEN%

echo Starting SSH tunnel on port %SSH_PORT%...
echo Once connected, use: ssh user@X.tcp.ngrok.io -p PORT
echo.
"%NGROK_EXE%" tcp %SSH_PORT%
