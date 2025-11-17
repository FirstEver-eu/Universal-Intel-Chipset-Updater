@echo off
setlocal enabledelayedexpansion

:: Intel Chipset HW_ID Detection Tool
:: Lists all Intel devices with their Hardware IDs for platform identification

:: Set console window size to 75 columns and 25 lines
mode con: cols=80 lines=25

echo /**************************************************************************
echo **                  INTEL CHIPSET HW_ID DETECTION TOOL                   **
echo ** --------------------------------------------------------------------- **
echo **                                                                       **
echo **         Detects Intel hardware IDs for platform identification        **
echo **            and creates a report in Intel_HWIDs_Report.txt             **
echo **                                                                       **
echo **              Author: Marcin Grygiel / www.firstever.tech              **
echo **                                                                       **
echo ** --------------------------------------------------------------------- **
echo **         This tool is not affiliated with Intel Corporation.           **
echo **         Drivers are sourced from official Intel servers.              **
echo **         Use at your own risk.                                         **
echo ** --------------------------------------------------------------------- **
echo **                                                                       **
echo **         GitHub.com/FirstEverTech/Intel-Chipset-Driver-Updater         **
echo **                                                                       **
echo *************************************************************************/
echo.

:: Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"

:: Check if PowerShell script exists in the same directory
if not exist "!SCRIPT_DIR!Get-Intel-HWIDs.ps1" (
    echo Error: Get-Intel-HWIDs.ps1 not found in current directory!
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

echo Running Intel HW_ID detection...
echo.

:: Change to script directory to ensure proper file access
cd /d "!SCRIPT_DIR!"

:: Run PowerShell script with execution policy bypass
powershell -ExecutionPolicy Bypass -File "Get-Intel-HWIDs.ps1"

echo.
pause