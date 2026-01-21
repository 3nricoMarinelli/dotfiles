#!/bin/bash

###############################################################################
# Fresh Terminal Setup Script
# Sets up: zsh, oh-my-zsh, powerlevel10k, fzf, ncdu, python, tmux, lazyvim
#
# Installation Order:
# 1. System packages (git, curl, wget, cmake, ripgrep)
# 2. Zsh (shell)
# 3. Oh-My-Zsh (zsh framework)
# 4. Zsh plugins (autosuggestions, syntax-highlighting)
# 5. Powerlevel10k theme
# 6. Utilities (fzf, ncdu, python3)
# 7. Tmux + TPM (terminal multiplexer)
# 8. Neovim (latest from tarball for LazyVim compatibility)
# 9. Move custom dotfiles and robotics directory to home
# 10. Change default shell to zsh
# 11. Clean up: Remove dotfiles directory
###############################################################################

set -e # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
SCRIPT_DIR="$(pwd)"

print_step() {
  echo -e "${BLUE}==>${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

# Check if running as root (should not)
check_not_root() {
  if [ "$EUID" -eq 0 ]; then
    print_error "Please run this script as a normal user (not root)"
    print_error "The script will prompt for sudo password when needed"
    exit 1
  fi
}

# Prompt for sudo password upfront to enable unattended installation
acquire_sudo() {
  print_step "This script requires sudo privileges for package installation."
  print_step "You will be prompted for your password once."
  echo ""

  # Request sudo and keep it alive
  if ! sudo -v; then
    print_error "Failed to acquire sudo privileges. Exiting."
    exit 1
  fi

  # Keep sudo alive in the background
  (while true; do
    sudo -n true
    sleep 50
    kill -0 "$$" || exit
  done 2>/dev/null) &
  SUDO_KEEPER_PID=$!

  print_success "Sudo privileges acquired"
}

# Cleanup function to kill sudo keeper
cleanup() {
  if [ -n "$SUDO_KEEPER_PID" ]; then
    kill "$SUDO_KEEPER_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

# Support only Ubuntu/Debian and macOS
detect_package_manager() {
  if command -v apt-get &>/dev/null; then
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt-get install -y"
    UPDATE_CMD="sudo apt-get update"
  elif command -v brew &>/dev/null; then
    PKG_MANAGER="brew"
    INSTALL_CMD="brew install"
    UPDATE_CMD="brew update"
  else
    print_error "No supported package manager found (apt or brew required)"
    exit 1
  fi
  print_success "Detected package manager: $PKG_MANAGER"
}

update_system() {
  print_step "Updating system package lists..."
  $UPDATE_CMD
  print_success "System packages updated"
}

install_git() {
  print_step "Checking git..."
  if command -v git &>/dev/null; then
    print_success "git already installed"
  else
    $INSTALL_CMD git
    print_success "git installed"
  fi
}

install_curl_wget() {
  print_step "Checking curl and wget..."

  if ! command -v curl &>/dev/null; then
    $INSTALL_CMD curl
    print_success "curl installed"
  else
    print_success "curl already installed"
  fi

  if ! command -v wget &>/dev/null; then
    $INSTALL_CMD wget
    print_success "wget installed"
  else
    print_success "wget already installed"
  fi
}

install_cmake() {
  print_step "Checking cmake..."
  if command -v cmake &>/dev/null; then
    print_success "cmake already installed"
  else
    $INSTALL_CMD cmake
    print_success "cmake installed"
  fi
}

install_ripgrep() {
  print_step "Checking ripgrep (required for telescope)..."
  if command -v rg &>/dev/null; then
    print_success "ripgrep already installed"
  else
    $INSTALL_CMD ripgrep
    print_success "ripgrep installed"
  fi
}

install_zsh() {
  print_step "Checking zsh..."
  if command -v zsh &>/dev/null; then
    print_success "zsh already installed"
    return
  fi

  $INSTALL_CMD zsh
  hash -r 2>/dev/null || true

  if command -v zsh &>/dev/null; then
    print_success "zsh installed"
  else
    print_error "zsh installation failed"
    exit 1
  fi
}

install_oh_my_zsh() {
  print_step "Installing oh-my-zsh..."
  if [ -d "$HOME/.oh-my-zsh" ]; then
    print_warning "oh-my-zsh already installed, skipping..."
  else
    # Install oh-my-zsh unattended (won't change shell or start zsh)
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "oh-my-zsh installed"
  fi
}

install_zsh_plugins() {
  print_step "Installing zsh plugins..."

  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  # zsh-autosuggestions
  if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    print_success "zsh-autosuggestions already installed"
  else
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    print_success "zsh-autosuggestions installed"
  fi

  # zsh-syntax-highlighting
  if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    print_success "zsh-syntax-highlighting already installed"
  else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    print_success "zsh-syntax-highlighting installed"
  fi
}

install_powerlevel10k() {
  print_step "Installing Powerlevel10k theme..."

  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  if [ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    print_success "Powerlevel10k already installed"
  else
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    print_success "Powerlevel10k installed"
  fi
}

install_fzf() {
  print_step "Checking fzf..."
  hash -r 2>/dev/null || true

  if command -v fzf &>/dev/null; then
    print_success "fzf already installed"
    return
  fi

  if [ "$PKG_MANAGER" = "apt" ] || [ "$PKG_MANAGER" = "brew" ]; then
    $INSTALL_CMD fzf
  else
    # Fallback: install from git
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all --no-bash --no-fish
  fi

  hash -r 2>/dev/null || true
  print_success "fzf installed"
}

install_ncdu() {
  print_step "Checking ncdu..."
  if command -v ncdu &>/dev/null; then
    print_success "ncdu already installed"
  else
    $INSTALL_CMD ncdu
    print_success "ncdu installed"
  fi
}

install_python() {
  print_step "Checking Python..."
  if command -v python3 &>/dev/null; then
    print_success "Python already installed ($(python3 --version))"
  else
    if [ "$PKG_MANAGER" = "apt" ]; then
      $INSTALL_CMD python3 python3-pip python3-venv
    else
      $INSTALL_CMD python3
    fi
    print_success "Python installed"
  fi
}

install_tmux() {
  print_step "Checking tmux..."
  if command -v tmux &>/dev/null; then
    print_success "tmux already installed ($(tmux -V))"
  else
    $INSTALL_CMD tmux
    print_success "tmux installed"
  fi
}

install_tpm() {
  print_step "Installing Tmux Plugin Manager (TPM)..."
  if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    print_warning "TPM already installed, updating..."
    cd "$HOME/.tmux/plugins/tpm" && git pull -q
    cd "$HOME"
  else
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi
  print_success "TPM installed"
}

change_shell() {
  print_step "Setting zsh as default shell..."

  ZSH_PATH=$(command -v zsh 2>/dev/null || echo "")

  if [ -z "$ZSH_PATH" ]; then
    for path in /usr/bin/zsh /bin/zsh /usr/local/bin/zsh; do
      if [ -x "$path" ]; then
        ZSH_PATH="$path"
        break
      fi
    done
  fi

  if [ -z "$ZSH_PATH" ]; then
    print_error "Cannot find zsh executable"
    return 1
  fi

  print_success "Found zsh at: $ZSH_PATH"

  if [ "$SHELL" = "$ZSH_PATH" ]; then
    print_success "Default shell is already zsh"
    return
  fi

  # Ensure zsh is in /etc/shells
  if ! grep -q "^${ZSH_PATH}$" /etc/shells 2>/dev/null; then
    print_step "Adding zsh to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  fi

  # Change shell (may prompt for password on some systems)
  if chsh -s "$ZSH_PATH"; then
    print_success "Default shell changed to zsh"
  else
    print_warning "Could not change default shell automatically"
    print_warning "Run manually: chsh -s $ZSH_PATH"
  fi
  zsh
}

install_stow() {
  print_step "Checking stow..."
  if command -v stow &>/dev/null; then
    print_success "stow already installed"
  else
    $INSTALL_CMD stow
    print_success "stow installed"
  fi
}

dotfiles_manager() {
    print_step "Setting up dotfiles with stow..."
    cd "${SCRIPT_DIR}"
    local packages=(nvim tmux vim vscode zsh)
    for pkg in "${packages[@]}"; do
        if [ -d "$pkg" ]; then
            print_step "Stowing $pkg..."
            stow -v --adopt --restow "$pkg"
        fi
    done
    print_success "Dotfiles stowed successfully"
    cd "$HOME"
}

install_other_packages(){
	if command -v brew &>/dev/null; then
            cd "${SCRIPT_DIR}/brew"
            brew bundle install
        elif command -v apt  &>/dev/null; then
            cd "${SCRIPT_DIR}/apt"
            xargs -a "packages.txt" sudo apt-get install -y
        fi
        cd "$HOME"
}

main() {
  echo ""
  echo "╔═══════════════════════════════════════════════════════════╗"
  echo "║               Terminal Setup Script                       ║"
  echo "║    	     zsh + oh-my-zsh + p10k + tmux	    	    ║"
  echo "╚═══════════════════════════════════════════════════════════╝"
  echo ""

  check_not_root
  acquire_sudo
  detect_package_manager

  echo ""
  print_step "Starting installation..."
  echo ""

  update_system
  install_git
  install_curl_wget
  install_cmake
  install_ripgrep
  install_stow

  install_zsh
  install_oh_my_zsh
  install_zsh_plugins
  install_powerlevel10k

  install_fzf
  install_ncdu
  install_python

  install_tmux
  install_tpm

  dotfiles_manager
  install_other_packages

  change_shell

  echo ""
  echo "╔═══════════════════════════════════════════════════════════╗"
  echo "║         Developer Environment Complete!                   ║"
  echo "╚═══════════════════════════════════════════════════════════╝"
  echo ""
  print_success "All developer tools installed successfully!"

}

main "$@"
#reset
