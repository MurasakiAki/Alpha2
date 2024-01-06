@echo off
set SCRIPT_PATH=src\alpha_compress.py

REM Function for automatic compression
:auto_compress
echo Starting automatic compression with default parameters.
python -c "import sys; sys.path.append('%~dp0'); import %~n0 as alpha_compress; alpha_compress.auto_compressor()"
goto :eof

REM Function for manual compression (TO-DO: Implement manual compression)
:manual_compress
echo Starting manual compression.
python -c "import sys; sys.path.append('%~dp0'); import %~n0 as alpha_compress; alpha_compress.manual_compressor()"
goto :eof

REM Function for configuration check
:configure_compressor
set CONFIG_FILE=src\config.ini

REM Check if the config file exists
if not exist %CONFIG_FILE% (
    echo Error: Configuration file '%CONFIG_FILE%' not found.
    exit /b 1
)

echo Current Configuration:
type %CONFIG_FILE%

echo.
echo Enter new values for the configuration (press Enter to keep current value):

set /p new_input_path="Input file path (Enter to keep current): "
set /p new_output_path="Output file path (Enter to keep current): "
set /p new_manual_config_path="Manual configuration file path (Enter to keep current): "
set /p new_do_shortcuts="Do shortcuts (1 or 0, Enter to keep current): "
set /p new_do_contractions="Do contractions (1 or 0, Enter to keep current): "

REM Use PowerShell to update the config file
powershell -Command ^
    "(Get-Content '%CONFIG_FILE%') -replace '^input_file_path=.*', 'input_file_path=${new_input_path:-$(Get-Content '%CONFIG_FILE%' | Select-String '^input_file_path=' | ForEach-Object { $_ -replace '^input_file_path=' })}' | " ^
    "Set-Content '%CONFIG_FILE%'; " ^
    "(Get-Content '%CONFIG_FILE%') -replace '^output_file_path=.*', 'output_file_path=${new_output_path:-$(Get-Content '%CONFIG_FILE%' | Select-String '^output_file_path=' | ForEach-Object { $_ -replace '^output_file_path=' })}' | " ^
    "Set-Content '%CONFIG_FILE%'; " ^
    "(Get-Content '%CONFIG_FILE%') -replace '^manual_json_file_path=.*', 'manual_json_file_path=${new_manual_config_path:-$(Get-Content '%CONFIG_FILE%' | Select-String '^manual_json_file_path=' | ForEach-Object { $_ -replace '^manual_json_file_path=' })}' | " ^
    "Set-Content '%CONFIG_FILE%'; " ^
    "(Get-Content '%CONFIG_FILE%') -replace '^do_shortcuts=.*', 'do_shortcuts=${new_do_shortcuts:-$(Get-Content '%CONFIG_FILE%' | Select-String '^do_shortcuts=' | ForEach-Object { $_ -replace '^do_shortcuts=' })}' | " ^
    "Set-Content '%CONFIG_FILE%'; " ^
    "(Get-Content '%CONFIG_FILE%') -replace '^do_contractions=.*', 'do_contractions=${new_do_contractions:-$(Get-Content '%CONFIG_FILE%' | Select-String '^do_contractions=' | ForEach-Object { $_ -replace '^do_contractions=' })}' | " ^
    "Set-Content '%CONFIG_FILE%'"

echo Updated Configuration:
type %CONFIG_FILE%

echo.
goto :eof

REM Main menu
:main_menu
set main_menu_prompt=Hello, what would you like to do?
set sub_menu_prompt=Please select a compression method:

:menu_loop
cls
echo %main_menu_prompt%
choice /C CQ /N /M %sub_menu_prompt%
if errorlevel 2 goto :quit
if errorlevel 1 (
    choice /C AMB /N /M %sub_menu_prompt%
    if errorlevel 3 goto :menu_loop
    if errorlevel 2 goto :manual_compress
    if errorlevel 1 goto :auto_compress
)
goto :menu_loop

REM Quit
:quit
echo Thank you
exit /b
