#!/bin/bash

set -e

# Detect the platform
#
if [[ "$OSTYPE" == "darwin"* ]]; then
  PLATFORM="darwin"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Check for Ubuntu-specific files
  if [ -f "/etc/os-release" ] && grep -qi "ubuntu" /etc/os-release; then
    PLATFORM="ubuntu"
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
if [ -f "$SCRIPT_PATH" ]; then
  bash "$SCRIPT_PATH"
else
  echo "No script found for platform: $PLATFORM. Falling back to default."
  bash "$SCRIPT_DIR/default.sh"
fi
