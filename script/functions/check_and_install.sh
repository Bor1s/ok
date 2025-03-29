#!/bin/bash

check_and_install() {
  local tool=$1
  local install_cmd=$2

  if ! command -v "$tool" &>/dev/null; then
    echo "Installing $tool..."
    eval "$install_cmd" >>"$LOG_FILE" 2>&1
    echo "$tool ... OK"
  else
    echo "$tool is already installed ... OK"
  fi
}