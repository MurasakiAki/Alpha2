@echo off
setlocal enabledelayedexpansion

REM Function for automatic compression
:auto_compress
echo Starting automatic compression with default parameters.
python -c "from alpha_compress import auto_compress; auto_compress()"
goto :eof

REM Function for manual compression (TO-DO: Implement manual compression)
:manual_compress
echo Starting manual compression.
REM TO-DO
goto :eof

REM Function for configuration check
:configure_compressor
set "config_file=config.ini"

REM Check if the config file exists
if not exist "%config_file%" (
    echo Error: Configuration file '%config_file%' not found.
    goto :eof
)

echo Current Configuration:
type "%config_file%"

echo.
echo Enter new values for the configuration (press Enter to keep current value):

REM Read new values from the user
set /p "new_input_path=Input file path (Enter to keep current): "
set /p "new_output_path=Output file path (Enter to keep current): "
set /p "new_auto=Auto (1 or 0, Enter to keep current): "
set /p "new_do_shortcuts=Do shortcuts (1 or 0, Enter to keep current): "
set /p "new_do_contractions=Do contractions (1 or 0, Enter to keep current): "

REM Use PowerShell to update the config file
powershell -Command ^
    "(Get-Content '%config_file%') -replace '^input_file_path=.*', 'input_file_path=!new_input_path!' |" ^
    "Set-Content '%config_file%';" ^
    "(Get-Content '%config_file%') -replace '^output_file_path=.*', 'output_file_path=!new_output_path!' |" ^
    "Set-Content '%config_file%';" ^
    "(Get-Content '%config_file%') -replace '^auto=.*', 'auto=!new_auto!' |" ^
    "Set-Content '%config_file%';" ^
    "(Get-Content '%config_file%') -replace '^do_shortcuts=.*', 'do_shortcuts=!new_do_shortcuts!' |" ^
    "Set-Content '%config_file%';" ^
    "(Get-Content '%config_file%') -replace '^do_contractions=.*', 'do_contractions=!new_do_contractions!' |" ^
    "Set-Content '%config_file%'"

echo Updated Configuration:
type "%config_file%"

echo.
goto :eof

REM Main menu
:main_menu
set "main_menu_prompt=Hello, what would you like to do?"
set "sub_menu_prompt=Please select a compression method:"

:main_menu_loop
cls
echo %main_menu_prompt%
set "main_opt="
choice /C CQ /N /M "Select an option: "
if errorlevel 2 goto :quit
if errorlevel 1 set "main_opt=Compress"
if errorlevel 0 set "main_opt=Config"

if "%main_opt%"=="Compress" goto :compress_menu
if "%main_opt%"=="Config" goto :configure_compressor
goto :main_menu_loop

:compress_menu
:compress_menu_loop
cls
echo %sub_menu_prompt%
set "com_opt="
choice /C AMB /N /M "Select a compression method: "
if errorlevel 3 goto :main_menu
if errorlevel 2 set "com_opt=Manual"
if errorlevel 1 set "com_opt=Auto"
if errorlevel 0 goto :compress_menu_loop

:auto_compress
call :auto_compress
goto :compress_menu_loop

:manual_compress
call :manual_compress
goto :compress_menu_loop

:main_menu
goto :main_menu_loop

:quit
echo Thank you
goto :eof
