@echo off
TITLE Waste Management System - Backup Utility

:: Set Backup Directory
set BACKUP_DIR=C:\Users\Mouhannedd\Downloads\projet\backups
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

:: Generate Timestamp (YYYY-MM-DD_HH-MM)
set TIMESTAMP=%date:~-4,4%-%date:~-7,2%-%date:~-10,2%_%time:~0,2%-%time:~3,2%
set TIMESTAMP=%TIMESTAMP: =0%

echo [INFO] Starting Backup for waste_management database...
echo [INFO] Target: %BACKUP_DIR%\backup_%TIMESTAMP%

:: Run Mongodump (Adjust path if mongodump is not in PATH)
mongodump --db waste_management --out "%BACKUP_DIR%\backup_%TIMESTAMP%"

if %errorlevel% equ 0 (
    echo [SUCCESS] Backup completed successfully!
) else (
    echo [ERROR] Backup failed. Make sure 'mongodump' is installed and Mongodb is running.
)

pause
