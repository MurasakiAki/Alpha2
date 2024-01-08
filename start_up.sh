#!/bin/zsh

# 1. Make compressor script executable
chmod +x "$(dirname "$0")/compressor"

# 2. Export the path for immediate use
export PATH=$PATH:$(pwd)

# 3. Write the path to the appropriate profile file for persistence

# Detect the current shell
SHELL_NAME=$(basename $SHELL)

# Check for common profile files used by different shells
if [ -f "$HOME/.bashrc" ]; then
  PROFILE_FILE="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
  PROFILE_FILE="$HOME/.bash_profile"
elif [ -f "$HOME/.zshrc" ]; then
  PROFILE_FILE="$HOME/.zshrc"
else
  echo "Unsupported shell or profile file not found. Please manually update your profile file."
  exit 1
fi

# Append the path to the selected profile file
echo 'export PATH=$PATH:'"$(pwd)" >> $PROFILE_FILE
source $PROFILE_FILE

echo $PROFILE_FILE
echo "Startup script executed successfully."
