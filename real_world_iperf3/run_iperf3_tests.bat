@echo off
REM ============================================================================
REM SCRIPT: run_iperf3_tests.bat
REM PURPOSE: Automated real-world TCP vs UDP network benchmarks with iperf3
REM USAGE: run_iperf3_tests.bat <SERVER_IP>
REM Example: run_iperf3_tests.bat 192.168.1.100
REM ============================================================================

IF "%~1"=="" (
    echo [ERROR] Missing Server IP address.
    echo Usage: run_iperf3_tests.bat ^<SERVER_IP^>
    echo Example: run_iperf3_tests.bat 192.168.1.100
    exit /b 1
)

SET SERVER_IP=%~1
SET LOG_DIR=raw_logs
IF NOT EXIST "%LOG_DIR%" mkdir "%LOG_DIR%"

echo ============================================================================
echo Starting iperf3 Automated Test Suite against Server: %SERVER_IP%
echo Output Directory: %LOG_DIR%
echo ============================================================================

REM Check if iperf3 exists in path or current directory
where iperf3 >nul 2>nul
IF ERRORLEVEL 1 (
    IF NOT EXIST "iperf3.exe" (
        echo [ERROR] iperf3.exe was not found in PATH or the current folder.
        echo Please download iperf3 for Windows and place iperf3.exe here.
        exit /b 1
    )
    SET IPERF_CMD=.\iperf3.exe
) ELSE (
    SET IPERF_CMD=iperf3
)

REM Packet sizes to iterate over
SET SIZES=64 512 1024 1460

FOR %%S IN (%SIZES%) DO (
    echo.
    echo ------------------------------------------------------------------------
    echo Benchmarking Packet Size: %%S Bytes
    echo ------------------------------------------------------------------------

    REM 1. TCP Test (10 seconds, JSON output)
    echo [*] Running TCP Benchmark (Size: %%S Bytes)...
    %IPERF_CMD% -c %SERVER_IP% -t 5 -l %%S --json > "%LOG_DIR%\tcp_%%S.json"
    
    timeout /t 2 /nobreak >nul

    REM 2. UDP Test (Target bandwidth 100M, 10 seconds, JSON output)
    echo [*] Running UDP Benchmark (Size: %%S Bytes, Offered Bandwidth: 100M)...
    %IPERF_CMD% -c %SERVER_IP% -u -b 100M -t 5 -l %%S --json > "%LOG_DIR%\udp_%%S.json"

    timeout /t 2 /nobreak >nul
)

echo.
echo ============================================================================
echo [SUCCESS] Real-world benchmark sequence complete!
echo JSON logs are saved in folder: %LOG_DIR%
echo Run 'convert_iperf3_to_csv.R' in R to ingest these results into main.R!
echo ============================================================================

