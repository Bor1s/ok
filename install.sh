#!/bin/bash

set -e

LOG_FILE="/tmp/ok-install.log"

# Detect the platform
if [[ "$OSTYPE" == "darwin"* ]]; then
  PLATFORM="darwin"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Check for Ubuntu specifically
  if [ -f "/etc/os-release" ]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" ]]; then
      PLATFORM="ubuntu"
    else
      PLATFORM="linux"
    fi
  else
    PLATFORM="linux"
  fi
else
  PLATFORM="unknown"
fi

echo "Installation started. Logs are available in $LOG_FILE"

REPO_URL="https://github.com/Bor1s/ok.git"
TEMP_DIR=$(mktemp -d) >>"$LOG_FILE" 2>&1
git clone "$REPO_URL" "$TEMP_DIR" >>"$LOG_FILE" 2>&1

# Path to platform-specific scripts
SCRIPT_DIR="$TEMP_DIR/script"
SCRIPT_PATH="$SCRIPT_DIR/$PLATFORM.sh"

# Run the platform-specific script
bash "$SCRIPT_PATH"

# Cleanup tmp directory
rm -rf "$TEMP_DIR" >>"$LOG_FILE" 2>&1

echo "Installation ... OK"
