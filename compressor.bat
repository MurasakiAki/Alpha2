@echo off
set SCRIPT_PATH=src\alpha_compress.py

rem Function for automatic compression
:auto_compress
echo Starting automatic compression with default parameters.
python -c "import sys; sys.path.append('%~dp0%'); import %~n0 as alpha_compress; alpha_compress.auto_compressor()"
goto :eof

rem Function for manual compression
:manual_compress
echo Starting manual compression.
python -c "import sys; sys.path.append('%~dp0%'); import %~n0 as alpha_compress; alpha_compress.manual_compressor()"
goto :eof

rem Function for configuration check
:configure_compressor
set "config_file=src\config.ini"

rem Check if the config file exists
if not exist "%config_file%" (
    echo Error: Configuration file '%config_file%' not found.
    exit /b 1
)

echo Current Configuration:
type "%config_file%"

echo.
echo Enter new values for the configuration (press Enter to keep current value):

set /p "new_input_path=Input file path (Enter to keep current): "
set /p "new_output_path=Output file path (Enter to keep current): "
set /p "new_manual_config_path=Manual configuration file path (Enter to keep current): "
set /p "new_do_shortcuts=Do shortcuts (1 or 0, Enter to keep current): "
set /p "new_do_contractions=Do contractions (1 or 0, Enter to keep current): "

rem Use PowerShell to update the config file
powershell -Command "& { (Get-Content '%config_file%') -replace '^input_file_path=.*', 'input_file_path=${new_input_path:-$(Get-Content '%config_file%' | Select-String '^input_file_path=').Split('=')[1]}' | Set-Content '%config_file%'; }"
powershell -Command "& { (Get-Content '%config_file%') -replace '^output_file_path=.*', 'output_file_path=${new_output_path:-$(Get-Content '%config_file%' | Select-String '^output_file_path=').Split('=')[1]}' | Set-Content '%config_file%'; }"
powershell -Command "& { (Get-Content '%config_file%') -replace '^manual_json_file_path=.*', 'manual_json_file_path=${new_manual_config_path:-$(Get-Content '%config_file%' | Select-String '^manual_json_file_path=').Split('=')[1]}' | Set-Content '%config_file%'; }"
powershell -Command "& { (Get-Content '%config_file%') -replace '^do_shortcuts=.*', 'do_shortcuts=${new_do_shortcuts:-$(Get-Content '%config_file%' | Select-String '^do_shortcuts=').Split('=')[1]}' | Set-Content '%config_file%'; }"
powershell -Command "& { (Get-Content '%config_file%') -replace '^do_contractions=.*', 'do_contractions=${new_do_contractions:-$(Get-Content '%config_file%' | Select-String '^do_contractions=').Split('=')[1]}' | Set-Content '%config_file%'; }"

echo Updated Configuration:
type "%config_file%"

echo.
pause
exit /b

rem Main menu
:main_menu
set "main_menu_prompt=Hello, what would you like to do?"
set "sub_menu_prompt=Please select a compression method:"

:menu_loop
cls
echo %main_menu_prompt%
choice /c CQ /m "%sub_menu_prompt%"
if errorlevel 2 goto :quit
if errorlevel 1 goto :main_options

:main_options
cls
echo %sub_menu_prompt%
choice /c AMB /m "Auto Manual Back"
if errorlevel 3 goto :menu_loop
if errorlevel 2 goto :manual_compress
if errorlevel 1 goto :auto_compress

:quit
echo Thank you
pause
exit /b
