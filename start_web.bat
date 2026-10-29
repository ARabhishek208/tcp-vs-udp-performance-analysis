@echo off
REM ============================================================================
REM SCRIPT: start_web.bat
REM PURPOSE: One-click launcher to run the dashboard on your web browser
REM ============================================================================
echo ============================================================================
echo   TCP vs UDP Protocol Performance Analysis - Web Dashboard Launcher
echo ============================================================================
echo.

cd /d "%~dp0"

echo [*] Checking if port 8000 is ready...
echo [*] Starting Python local HTTP server on port 8000...
start /b "" python -m http.server 8000

REM Wait 2 seconds for Python server to bind to socket
timeout /t 2 /nobreak >nul

echo [*] Opening web dashboard in your default browser: http://localhost:8000/
start "" "http://localhost:8000/"

echo.
echo ============================================================================
echo  [SUCCESS] Server is RUNNING at: http://localhost:8000/
echo ============================================================================
echo  - Keep this window OPEN while viewing the dashboard in your browser.
echo  - If you close this window, the local server will stop.
echo  - Press any key below only when you want to EXIT and stop the server.
echo ============================================================================
echo.
pause
