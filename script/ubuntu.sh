#!/bin/bash

PLATFORM="ubuntu"

check_and_install() {
  local tool=$1
  local install_cmd=$2

  if ! command -v "$tool" &>/dev/null; then
    echo "$tool is not installed. Installing..."
    eval "$install_cmd"
    echo "$tool ... OK"
  else
    echo "$tool is already installed ... OK"
  fi
}

install_fonts() {
  echo "Installing Cascadia Code font..."
  sudo apt-get install -y fonts-cascadia-code
}

# Oh-my-zsh installation
check_and_install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed ... OK"
  else
    echo "Oh My Zsh is not installed. Installing..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "Oh My Zsh ... OK"
  fi
}

check_and_install_rust() {
  if command -v rustup &>/dev/null; then
    echo "Rust is already installed ... OK"
  else
    echo "Rust is not installed. Installing..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    . "$HOME/.cargo/env"
    echo "Rust ... OK"
  fi
}

check_and_install_zellij() {
  if command -v zellij &>/dev/null; then
    echo "Zellij is already installed ... OK"
  else
    echo "Zellij is not installed. Installing..."
    cargo install --locked zellij
    echo "Zellij ... OK"
  fi
}

copy_if_exists() {
  local source=$1
  local target=$2

  if [ -f "$target" ]; then
    echo "$target ... OK"
  else
    cp "$source" "$target"

    if [ -d "$target" ]; then
      echo "$target ... OK"
    else
      cp -R "$source" "$target"
    fi
  fi
}

overwrite_file() {
  local source=$1
  local target=$2

  cp -f "$source" "$target"
}

# Install necessary tools.

echo "Installing tools"

# Update package lists and install prerequisites
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install build-essential

# Install tools
check_and_install "git" "sudo apt-get install -y git"
check_and_install "lazygit" "sudo add-apt-repository ppa:lazygit-team/release -y && sudo apt-get update && sudo apt-get install -y lazygit"
check_and_install "wezterm" "sudo add-apt-repository ppa:wez/ppa -y && sudo apt-get update && sudo apt-get install -y wezterm"
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
TEMP_DIR=$(mktemp -d)
git clone "$REPO_URL" "$TEMP_DIR"

# Configuration directories
WEZTERM_CONFIG_FILE="$HOME/.wezterm.lua"
WEZTERM_CONFIG_DIR="$HOME/.config/wezterm"
ZSH_CONFIG_FILE="$HOME/.zshrc"
ZELLIJ_CONFIG_DIR="$HOME/.config/zellij"
NEOVIM_CONFIG_DIR="$HOME/.config/nvim"

# TODO: think more about how to extend .zshrc file file and not overwrite it.
overwrite_file "$TEMP_DIR/platforms/$PLATFORM/terminal/zsh/.zshrc" "$ZSH_CONFIG_FILE"
copy_if_exists "$TEMP_DIR/platforms/$PLATFORM/terminal/wezterm/.wezterm.lua" "$WEZTERM_CONFIG_FILE"
copy_if_exists "$TEMP_DIR/platforms/$PLATFORM/terminal/wezterm" "$WEZTERM_CONFIG_DIR"
copy_if_exists "$TEMP_DIR/platforms/$PLATFORM/terminal/zellij" "$ZELLIJ_CONFIG_DIR"
copy_if_exists "$TEMP_DIR/platforms/$PLATFORM/terminal/nvim" "$NEOVIM_CONFIG_DIR"

echo "Installation ... OK"
