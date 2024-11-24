#!/bin/bash

set -e

PLATFORM="ubuntu"
LOG_FILE="/tmp/ok-install.log"

check_and_install() {
  local tool=$1
  local install_cmd=$2

  if ! command -v "$tool" &>/dev/null; then
    echo "$tool is not installed. Installing..."
    eval "$install_cmd" >>"$LOG_FILE" 2>&1
    echo "$tool ... OK"
  else
    echo "$tool is already installed ... OK"
  fi
}

install_fonts() {
  echo "Installing Cascadia Code font..."
  sudo apt-get install -y fonts-cascadia-code >>"$LOG_FILE" 2>&1
}

check_and_install_lazygit() {
  if command -v lazygit &>/dev/null; then
    echo "lazygit is already installed ... OK"
  else
    echo "lazygit is not installed. Installing..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*') >>"$LOG_FILE" 2>&1
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" >>"$LOG_FILE" 2>&1
    tar xf lazygit.tar.gz lazygit >>"$LOG_FILE" 2>&1
    sudo install lazygit -D -t /usr/local/bin/ >>"$LOG_FILE" 2>&1
    echo "lazygit ... OK"
  fi
}

check_and_install_wezterm() {
  if command -v wezterm &>/dev/null; then
    echo "wezterm is already installed ... OK"
  else
    echo "wezterm is not installed. Installing..."
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg >>"$LOG_FILE" 2>&1
    echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list >>"$LOG_FILE" 2>&1
    sudo apt update >>"$LOG_FILE" 2>&1
    sudo apt install wezterm >>"$LOG_FILE" 2>&1
    echo "wezterm ... OK"
  fi
}

# Oh-my-zsh installation
check_and_install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed ... OK"
  else
    echo "Oh My Zsh is not installed. Installing..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >>"$LOG_FILE" 2>&1
    echo "Oh My Zsh ... OK"
  fi
}

check_and_install_rust() {
  if command -v rustup &>/dev/null; then
    echo "Rust is already installed ... OK"
  else
    echo "Rust is not installed. Installing..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y >>"$LOG_FILE" 2>&1
    source "$HOME/.cargo/env"
    echo "Rust ... OK"
  fi
}

check_and_install_zellij() {
  if command -v zellij &>/dev/null; then
    echo "Zellij is already installed ... OK"
  else
    echo "Zellij is not installed. Installing..."
    cargo install --locked zellij >>"$LOG_FILE" 2>&1
    echo "Zellij ... OK"
  fi
}

copy_if_not_exists() {
  local source=$1
  local target=$2

  # Ensure the parent directory exists
  mkdir -p "$(dirname "$target")" >>"$LOG_FILE" 2>&1

  if [ -e "$target" ]; then
    echo "$target already exists ... OK"
  else
    if [ -d "$source" ]; then
      cp -r "$source" "$target" >>"$LOG_FILE" 2>&1
    else
      cp "$source" "$target" >>"$LOG_FILE" 2>&1
    fi
    echo "$target ... OK"
  fi
}

overwrite_file() {
  local source=$1
  local target=$2

  cp -f "$source" "$target" >>"$LOG_FILE" 2>&1
}

# Install necessary tools.

echo "Installing tools"

# Update package lists and install prerequisites
sudo apt-get update >>"$LOG_FILE" 2>&1
sudo apt-get upgrade -y >>"$LOG_FILE" 2>&1
sudo apt install -y build-essential >>"$LOG_FILE" 2>&1

# Install tools
check_and_install "git" "sudo apt-get install -y git"
check_and_install_lazygit
check_and_install_wezterm
check_and_install "zsh" "sudo apt-get install -y zsh"
check_and_install "fzf" "sudo apt-get install -y fzf"
check_and_install "neovim" "sudo apt-get install -y neovim"
check_and_install "ngrok" "curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && echo \"deb https://ngrok-agent.s3.amazonaws.com buster main\" | sudo tee /etc/apt/sources.list.d/ngrok.list && sudo apt-get update && sudo apt-get install -y ngrok"
check_and_install_oh_my_zsh
check_and_install_rust
check_and_install_zellij

install_fonts

# Copy configuration files
#
# Clone repository (if running directly via curl)
REPO_URL="https://github.com/Bor1s/ok.git"
TEMP_DIR=$(mktemp -d) >>"$LOG_FILE" 2>&1
git clone "$REPO_URL" "$TEMP_DIR" >>"$LOG_FILE" 2>&1

# Configuration directories
WEZTERM_CONFIG_FILE="$HOME/.wezterm.lua"
WEZTERM_CONFIG_DIR="$HOME/.config/wezterm"
ZSH_CONFIG_FILE="$HOME/.zshrc"
ZELLIJ_CONFIG_DIR="$HOME/.config/zellij"
NEOVIM_CONFIG_DIR="$HOME/.config/nvim"

# TODO: think more about how to extend .zshrc file file and not overwrite it.
overwrite_file "$TEMP_DIR/platforms/$PLATFORM/terminal/zshrc/.zshrc" "$ZSH_CONFIG_FILE"
copy_if_not_exists "$TEMP_DIR/platforms/$PLATFORM/terminal/wezterm/.wezterm.lua" "$WEZTERM_CONFIG_FILE"
copy_if_not_exists "$TEMP_DIR/platforms/$PLATFORM/terminal/wezterm" "$WEZTERM_CONFIG_DIR"
copy_if_not_exists "$TEMP_DIR/platforms/$PLATFORM/terminal/zellij" "$ZELLIJ_CONFIG_DIR"
copy_if_not_exists "$TEMP_DIR/platforms/$PLATFORM/terminal/nvim" "$NEOVIM_CONFIG_DIR"

# Cleanup tmp directory
rm -rf "$TEMP_DIR" >>"$LOG_FILE" 2>&1
