#!/bin/bash

SCRIPT_PATH="src/alpha_compress.py"

# Function for automatic compression
function auto_compress {
    echo "Starting automatic compression with default parameters."
    python -c "import sys; sys.path.append('$(dirname $SCRIPT_PATH)'); import $(basename $SCRIPT_PATH .py) as alpha_compress; alpha_compress.auto_compressor()"
}

# Function for manual compression (TO-DO: Implement manual compression)
function manual_compress {
    echo "Starting manual compression."
    python -c "import sys; sys.path.append('$(dirname $SCRIPT_PATH)'); import $(basename $SCRIPT_PATH .py) as alpha_compress; alpha_compress.manual_compressor()"
}

# Function for configuration check
function configure_compressor {
    config_file="src/config.ini"

    # Check if the config file exists
    if [ ! -f "$config_file" ]; then
        echo "Error: Configuration file '$config_file' not found."
        return 1
    fi

    echo "Current Configuration:"
    cat "$config_file"

    echo
    echo "Enter new values for the configuration (press Enter to keep current value):"

    # Read new values from the user
    read -p "Input file path (Enter to keep current): " new_input_path
    read -p "Output file path (Enter to keep current): " new_output_path
    read -p "Manual configuration file path (Enter to keep current): " new_manual_config_path
    read -p "Output booklet file path (Enter to keep current): " new_booklet_path
    read -p "Do shortcuts (1 or 0, Enter to keep current): " new_do_shortcuts
    read -p "Do contractions (1 or 0, Enter to keep current): " new_do_contractions

    # Use sed to update the config file
    sed -i "s|^input_file_path=.*|input_file_path=${new_input_path:-$(grep '^input_file_path=' "$config_file" | cut -d '=' -f2)}|" "$config_file"
    sed -i "s|^output_file_path=.*|output_file_path=${new_output_path:-$(grep '^output_file_path=' "$config_file" | cut -d '=' -f2)}|" "$config_file"
    sed -i "s|^manual_json_file_path=.*|manual_json_file_path=${new_manual_config_path:-$(grep '^manual_json_file_path=' "$config_file" | cut -d '=' -f2)}|" "$config_file"
    sed -i "s|^booklet_json_file_path=.*|booklet_json_file_path=${new_booklet_path:-$(grep '^booklet_json_file_path=' "$config_file" | cut -d '=' -f2)}|" "$config_file"
    sed -i "s|^do_shortcuts=.*|do_shortcuts=${new_do_shortcuts:-$(grep '^do_shortcuts=' "$config_file" | cut -d '=' -f2)}|" "$config_file"
    sed -i "s|^do_contractions=.*|do_contractions=${new_do_contractions:-$(grep '^do_contractions=' "$config_file" | cut -d '=' -f2)}|" "$config_file"

    echo "Updated Configuration:"
    cat "$config_file"
    
    echo
}

# Main menu
main_menu_prompt="Hello, what would you like to do?"
sub_menu_prompt="Please select a compression method:"

while true; do
    clear
    echo $main_menu_prompt
    select main_opt in Compress Config Quit
    do
        case $main_opt in
            "Compress")
                
                while true; do
                    clear
                    echo $sub_menu_prompt
                    select com_opt in Auto Manual Back
                    do
                        case $com_opt in
                            "Auto") auto_compress;;
                            "Manual") manual_compress;;
                            "Back") break 2;;
                            *) echo "Wrong choice.";;
                        esac
                    done
                done
                break;;
            "Config") configure_compressor;;
            "Quit")
                echo "Thank you"
                exit;;
            *) echo "Wrong choice.";;
        esac
    done
done
