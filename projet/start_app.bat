@echo off
TITLE Waste Management System Launcher

echo ==========================================================
echo    WASTE MANAGEMENT SYSTEM - AUTO START
echo ==========================================================

:: 1. Check if Java is installed
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Java is not installed or not in PATH.
    pause
    exit /b
)

echo [INFO] Starting Backend Server...
:: Change "backend" to the folder where your JAR is located
:: If using the deployment folder: cd C:\WasteApp\backend
cd backend

:: Start the JAR in a new minimized window
start "WasteManagementBackend" /min java -jar target/waste-management-1.0.0.jar

echo [SUCCESS] Backend is launching in the background.
echo.
echo [INFO] Apache should be running as a service.
echo [INFO] Access your dashboard at: http://localhost:8089/
echo.
echo You can close this window (The backend will keep running).
pause
