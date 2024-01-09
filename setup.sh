#!/bin/bash
clear

echo "Setting up compressor..."

chmod +x compressor.sh

if [ -f "$HOME/.bashrc" ]; then
    echo "alias compressor='bash "$(pwd)"/compressor.sh'" >> "$HOME/.bashrc"

    . ~/.bashrc
    shopt -s expand_aliases
    echo "To execute the compressor, run 'compressor' command."
    
else
    echo "You are using different profile file than .bashrc."
    echo "Please set up manualy alias for compressor.sh by"
    echo "going to your profile file and appending"
    echo "alias compressor='bash path/to/compressor.sh'"
    echo "at the end of the profile file."
fi
