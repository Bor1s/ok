#!/bin/bash

PLATFORM="darwin"

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
  brew install --cask font-cascadia-code
}

# Oh-my-zsh is an exception because "omz" commands is a function
# in zsh, it is not a standalone command.
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
  if ! command -v "$rustup" &>/dev/null; then
    echo "Rust is already installed ... OK"
  else
    echo "Rust is not installed. Installing..."
    curl https://sh.rustup.rs -sSf | sh
    echo "Rust ... OK"
  fi
}

check_and_install_zellij() {
  if ! command -v "$zellij" &>/dev/null; then
    echo "Zellij is already installed ... OK"
  else
    echo "Zellij is not installed. Installing..."
    # cargo install --locked zellij
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
      cp -r "$source" "$target"
    fi
  fi
}

overwite_file() {
  local source=$1
  local target=$2

  cp -f "$source" "$target"
}

# Install necessary tools.

echo "Installing tools"

# Check tools for presence and install them if they are missing
check_and_install "brew" '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
check_and_install "git" "brew install git"
check_and_install "lazygit" "brew install lazygit"
check_and_install "wezterm" "brew install --cask wezterm"
check_and_install "zsh" "brew install zsh"
check_and_install "fzf" "brew install fzf"
check_and_install "neovim" "brew install neovim"
check_and_install "ngrok" "brew install ngrok/ngrok/ngrok"
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
copy_if_not_exist "$TEMP_DIR/platfroms/$PLATFORM/terminal/wezterm/.wezterm.lua" "$WEZTERM_CONFIG_FILE"
copy_if_not_exist "$TEMP_DIR/platforms/$PLATFORM/terminal/wezterm" "$WEZTERM_CONFIG_DIR"
copy_if_not_exist "$TEMP_DIR/platforms/$PLATFORM/terminal/zellij" "$ZELLIJ_CONFIG_DIR"
copy_if_not_exist "$TEMP_DIR/platforms/$PLATFORM/terminal/nvim" "$NEOVIM_CONFIG_DIR"

echo "Installation ... OK"
