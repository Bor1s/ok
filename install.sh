#!/bin/bash

set -e

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

# Path to platform-specific scripts
SCRIPT_DIR="$(dirname "$0")/script"
SCRIPT_PATH="$SCRIPT_DIR/$PLATFORM.sh"

# Run the platform-specific script
bash "$SCRIPT_PATH"
