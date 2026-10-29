@echo off
REM ============================================================================
REM RUN SCRIPT FOR TCP VS UDP PERFORMANCE ANALYSIS
REM Double-click this file or run from command prompt!
REM ============================================================================
echo.
echo ============================================================================
echo  Starting TCP vs UDP Protocol Performance Analysis Pipeline...
echo ============================================================================
echo.

where Rscript >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [*] Found R installation. Executing main.R with Rscript...
    Rscript main.R
) else (
    echo [*] Rscript not detected in PATH. Executing standalone analytical engine (Python)...
    python run_project.py
)

echo.
echo ============================================================================
echo Execution Complete! Check the 'output/' directory for all charts and reports.
echo ============================================================================
echo.
pause

