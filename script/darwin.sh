#!/bin/bash

set -e

PLATFORM="darwin"
LOG_FILE="/tmp/ok-install.log"

# Source functions
source "$(dirname "${BASH_SOURCE[0]}")/functions/check_and_install.sh"

install_fonts() {
  brew install --cask font-cascadia-code >>"$LOG_FILE" 2>&1
  echo "Cascadia Code font...OK"
}

# Oh-my-zsh is an exception because "omz" commands is a function
# in zsh, it is not a standalone command.
check_and_install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed ... OK"
  else
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >>"$LOG_FILE" 2>&1
    echo "Oh My Zsh ... OK"
  fi
}

check_and_install_rust() {
  if command -v rustup &>/dev/null; then
    echo "Rust is already installed ... OK"
  else
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y >>"$LOG_FILE" 2>&1
    source "$HOME/.cargo/env" >>"$LOG_FILE" 2>&1
    echo "Rust ... OK"
  fi
}

check_and_install_zellij() {
  if command -v zellij &>/dev/null; then
    echo "Zellij is already installed ... OK"
  else
    echo "Installing Zellij..."
    cargo install --locked zellij >>"$LOG_FILE" 2>&1
    echo "Zellij ... OK"
  fi
}

copy_if_not_exist() {
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

# Check tools for presence and install them if they are missing
check_and_install "brew" '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
check_and_install "git" "brew install git"
check_and_install "lazygit" "brew install lazygit"
check_and_install "wezterm" "brew install --cask wezterm"
check_and_install "ghostty" "brew install --cask ghostty"
check_and_install "zsh" "brew install zsh"
check_and_install "starship" "brew install starship"
check_and_install "fzf" "brew install fzf"
check_and_install "nvim" "brew install neovim"
check_and_install "ngrok" "brew install ngrok/ngrok/ngrok"
check_and_install "mise" "brew install mise"
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
STARSHIP_CONFIG_FILE="$HOME/.config/starship.toml"

overwrite_file "$TEMP_DIR/platforms/$PLATFORM/terminal/zshrc/.zshrc" "$ZSH_CONFIG_FILE"
copy_if_not_exist "$TEMP_DIR/platforms/$PLATFORM/terminal/wezterm/.wezterm.lua" "$WEZTERM_CONFIG_FILE"
copy_if_not_exist "$TEMP_DIR/platforms/$PLATFORM/terminal/wezterm" "$WEZTERM_CONFIG_DIR"
copy_if_not_exist "$TEMP_DIR/platforms/$PLATFORM/terminal/zellij" "$ZELLIJ_CONFIG_DIR"
copy_if_not_exist "$TEMP_DIR/platforms/$PLATFORM/terminal/nvim" "$NEOVIM_CONFIG_DIR"
copy_if_not_exist "$TEMP_DIR/platforms/$PLATFORM/terminal/starship/starship.toml" "$STARSHIP_CONFIG_FILE"

# Cleanup tmp directory
rm -rf "$TEMP_DIR" >>"$LOG_FILE" 2>&1
