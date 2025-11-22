@echo off
setlocal enabledelayedexpansion

:: Intel Chipset Device Update Tool
:: Requires administrator privileges

:: Set console window size to 75 columns and 58 lines
mode con: cols=75 lines=59

echo /*************************************************************************
echo **                UNIVERSAL INTEL CHIPSET DEVICE UPDATER                 **
echo ** --------------------------------------------------------------------- **
echo **                                                                       **
echo **                     INFs Version: 10.1 (2025.11.5)                    **
echo **                                                                       **
echo **              Author: Marcin Grygiel / www.firstever.tech              **
echo **                                                                       **
echo ** --------------------------------------------------------------------- **
echo **         This tool is not affiliated with Intel Corporation.           **
echo **         INF files are sourced from official Intel servers.            **
echo **         Use at your own risk.                                         **
echo ** --------------------------------------------------------------------- **
echo **                                                                       **
echo **    Visit: github.com/FirstEverTech/Universal-Intel-Chipset-Updater    **
echo **                                                                       **
echo *************************************************************************/
echo.

:: Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"

:: Check if PowerShell script exists in the same directory
if not exist "!SCRIPT_DIR!UNIVERSAL-INTEL-CHIPSET-UPDATER.ps1" (
    echo Error: UNIVERSAL-INTEL-CHIPSET-UPDATER.ps1 not found in current directory!
    echo.
    echo Please ensure the PowerShell script is in the same folder as this BAT file.
    pause
    exit /b 1
)

:: Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires administrator privileges.
    echo Requesting elevation...
    echo.
    
    :: Re-launch as administrator with the correct directory
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs -WorkingDirectory '!SCRIPT_DIR!'"
    exit /b
)

echo Running Universal Intel Chipset Updater...
echo.

:: Change to script directory to ensure proper file access
cd /d "!SCRIPT_DIR!"

:: Run PowerShell script with execution policy bypass
powershell -ExecutionPolicy Bypass -File "UNIVERSAL-INTEL-CHIPSET-UPDATER.ps1"

echo.
pause
