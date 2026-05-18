#!/usr/bin/env bash

###############################################################################
# Embedded / Robotics Workstation Setup
#
# Features:
# - Ubuntu/Debian & macOS support
# - zsh + oh-my-zsh + powerlevel10k
# - tmux + TPM
# - latest Neovim + LazyVim
# - Ghostty terminal
# - Ollama
# - Embedded ARM toolchain
# - Embedded Linux / Yocto tooling
# - Robotics/dev tooling
# - Dotfiles via GNU stow
#
# Usage:
#   chmod +x setup.sh
#   ./setup.sh
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Globals
###############################################################################

LOG_FILE="$HOME/setup.log"

exec > >(tee -a "$LOG_FILE")
exec 2>&1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

###############################################################################
# Package Manager Configuration
###############################################################################

# Paths will be set relative to script directory
APT_PACKAGES_FILE=""
BREWFILE=""

###############################################################################
# Helpers
###############################################################################

print_step() {
    echo -e "\n${BLUE}==>${NC} $1"
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

cleanup() {
    if [[ -n "${SUDO_KEEPER_PID:-}" ]]; then
        kill "$SUDO_KEEPER_PID" 2>/dev/null || true
    fi
}

trap cleanup EXIT

###############################################################################
# Checks
###############################################################################

check_not_root() {
    if [[ "$EUID" -eq 0 ]]; then
        print_error "Run this script as a normal user."
        exit 1
    fi
}

detect_package_manager() {
     if command -v apt-get &>/dev/null; then
         PKG_MANAGER="apt"
         print_success "Detected package manager: apt (Ubuntu/Debian)"
     elif command -v brew &>/dev/null; then
         PKG_MANAGER="brew"
         print_success "Detected package manager: brew (macOS)"
     else
         print_error "Unsupported OS. Requires Ubuntu, Debian, or macOS with Homebrew."
         exit 1
     fi
 }

acquire_sudo() {
    print_step "Acquiring sudo privileges..."

    sudo -v

    (
        while true; do
            sudo -n true
            sleep 60
            kill -0 "$$" || exit
        done
    ) &

    SUDO_KEEPER_PID=$!

    print_success "Sudo ready"
}

###############################################################################
# System
###############################################################################

update_system() {
     print_step "Updating system..."

     if [[ "$PKG_MANAGER" == "apt" ]]; then
         sudo apt-get update || { print_error "Failed to update apt"; exit 1; }
         sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y || { print_error "Failed to upgrade system"; exit 1; }
     elif [[ "$PKG_MANAGER" == "brew" ]]; then
         brew update || { print_error "Failed to update brew"; exit 1; }
     fi

     print_success "System updated"
 }

install_packages_apt() {
     print_step "Installing packages from apt/packages.txt..."

     if [[ ! -f "$APT_PACKAGES_FILE" ]]; then
         print_error "apt/packages.txt not found at $APT_PACKAGES_FILE"
         exit 1
     fi

     # Execute the packages.txt file directly (it contains: sudo apt install -y ...)
     # If any single package fails, apt will try to install the rest
     bash "$APT_PACKAGES_FILE" || { print_warning "Some packages may have failed to install (continuing...)"; }

     print_success "Packages installed (apt)"
 }

install_packages_brew() {
     print_step "Installing packages from brew/Brewfile..."

     if [[ ! -f "$BREWFILE" ]]; then
         print_error "brew/Brewfile not found at $BREWFILE"
         exit 1
     fi

     # Use brew bundle to install from Brewfile
     brew bundle install --file="$BREWFILE" || { print_error "Failed to install some packages (but continuing)"; }

     print_success "Packages installed (brew)"
 }

install_all_packages() {
     if [[ "$PKG_MANAGER" == "apt" ]]; then
         install_packages_apt
     elif [[ "$PKG_MANAGER" == "brew" ]]; then
         install_packages_brew
     fi
 }



###############################################################################
# ZSH
###############################################################################

install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_success "oh-my-zsh already installed"
        return
    fi

    print_step "Installing oh-my-zsh..."

    RUNZSH=no CHSH=no sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended

    print_success "oh-my-zsh installed"
}

install_zsh_plugins() {
    print_step "Installing zsh plugins..."

    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        git clone \
            https://github.com/zsh-users/zsh-autosuggestions \
            "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi

    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        git clone \
            https://github.com/zsh-users/zsh-syntax-highlighting \
            "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi

    if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
        git clone --depth=1 \
            https://github.com/romkatv/powerlevel10k.git \
            "$ZSH_CUSTOM/themes/powerlevel10k"
    fi

    print_success "zsh plugins installed"
}

###############################################################################
# Fonts
###############################################################################

install_fonts() {
    print_step "Installing Meslo Nerd Fonts..."

    mkdir -p ~/.local/share/fonts

    cd /tmp

    wget -q \
        https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf

    wget -q \
        https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf

    wget -q \
        https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf

    wget -q \
        https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

    mv ./*.ttf ~/.local/share/fonts/

    fc-cache -fv

    print_success "Fonts installed"
}

###############################################################################
# Ghostty
###############################################################################

 install_ghostty() {
     if command -v ghostty &>/dev/null; then
         print_success "Ghostty already installed"
         return
     fi

     print_step "Installing Ghostty..."

     TMP_DIR=$(mktemp -d)
     cd "$TMP_DIR" || exit 1

     if [[ "$OSTYPE" == "linux-gnu"* ]]; then
         ARCH=$(dpkg --print-architecture)
         if [[ "$ARCH" == "amd64" ]]; then
             GHOSTTY_URL="https://release.files.ghostty.org/latest/ghostty-linux-x86_64.tar.gz"
         else
             GHOSTTY_URL="https://release.files.ghostty.org/latest/ghostty-linux-aarch64.tar.gz"
         fi

         curl -LO "$GHOSTTY_URL" || { print_error "Failed to download Ghostty"; exit 1; }
         tar -xzf ghostty-*.tar.gz || { print_error "Failed to extract Ghostty"; exit 1; }
         sudo mv ghostty /opt/ghostty || { print_error "Failed to install Ghostty"; exit 1; }
         sudo ln -sf /opt/ghostty/bin/ghostty /usr/local/bin/ghostty || exit 1

     elif [[ "$OSTYPE" == "darwin"* ]]; then
         print_step "Installing Ghostty via Homebrew..."
         brew install ghostty || { print_error "Failed to install Ghostty"; exit 1; }
     fi

     cd "$HOME" || exit 1
     rm -rf "$TMP_DIR"

     print_success "Ghostty installed"
 }

###############################################################################
# Ollama
###############################################################################

 install_ollama() {
     if command -v ollama &>/dev/null; then
         print_success "Ollama already installed"
         return
     fi

     print_step "Installing Ollama..."

     curl -fsSL https://ollama.com/install.sh | sh || { print_error "Failed to install Ollama"; exit 1; }

     if [[ "$PKG_MANAGER" == "apt" ]]; then
         sudo systemctl enable ollama || { print_error "Failed to enable ollama service"; exit 1; }
         sudo systemctl start ollama || { print_error "Failed to start ollama service"; exit 1; }
     elif [[ "$PKG_MANAGER" == "brew" ]]; then
         brew services start ollama || { print_error "Failed to start ollama service"; exit 1; }
     fi

     print_success "Ollama installed"
 }

###############################################################################
# Neovim
###############################################################################

 install_neovim() {
     if command -v nvim &>/dev/null; then
         print_success "Neovim already installed"
         return
     fi

     print_step "Installing latest Neovim..."

     if [[ "$PKG_MANAGER" == "apt" ]]; then
         TMP_DIR=$(mktemp -d)
         cd "$TMP_DIR" || exit 1

         curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz || { print_error "Failed to download Neovim"; exit 1; }

         sudo rm -rf /opt/nvim
         sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz || { print_error "Failed to extract Neovim"; exit 1; }
         sudo mv /opt/nvim-linux-x86_64 /opt/nvim || { print_error "Failed to move Neovim"; exit 1; }
         sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim || exit 1

         rm -f nvim-linux-x86_64.tar.gz
         cd "$HOME" || exit 1
         rm -rf "$TMP_DIR"

     elif [[ "$PKG_MANAGER" == "brew" ]]; then
         brew install neovim || { print_error "Failed to install Neovim"; exit 1; }
     fi

     print_success "Neovim installed"
 }

 install_lazyvim() {
     if [[ -d "$HOME/.config/nvim" ]]; then
         print_warning "nvim config already exists"
         return
     fi

     print_step "Installing LazyVim..."

     git clone https://github.com/LazyVim/starter ~/.config/nvim || { print_error "Failed to clone LazyVim"; exit 1; }
     rm -rf ~/.config/nvim/.git

     print_success "LazyVim installed"
 }

###############################################################################
# TPM
###############################################################################

install_tpm() {
    print_step "Installing TPM..."

    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        git clone \
            https://github.com/tmux-plugins/tpm \
            "$HOME/.tmux/plugins/tpm"
    fi

    print_success "TPM installed"
}

###############################################################################
# Dotfiles
###############################################################################

setup_dotfiles() {
    if [[ ! -d "$SCRIPT_DIR" ]]; then
        print_warning "No dotfiles directory found"
        return
    fi

    print_step "Applying dotfiles..."

    cd "$SCRIPT_DIR"

    local packages=(
        zsh
        tmux
        nvim
        ghostty
        git
    )

    for pkg in "${packages[@]}"; do
        if [[ -d "$pkg" ]]; then
            print_step "Stowing $pkg"
            stow --adopt --restow "$pkg"
        fi
    done

    cd "$HOME"

    print_success "Dotfiles applied"
}

###############################################################################
# Shell
###############################################################################

 change_shell() {
     local ZSH_PATH

     ZSH_PATH=$(command -v zsh) || { print_error "zsh not found in PATH"; exit 1; }

     if [[ "$SHELL" == "$ZSH_PATH" ]]; then
         print_success "zsh already default shell"
         return
     fi

     print_step "Changing default shell to zsh..."

     if [[ "$PKG_MANAGER" == "apt" ]]; then
         if ! grep -q "^${ZSH_PATH}$" /etc/shells; then
             echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null || { print_error "Failed to add zsh to /etc/shells"; exit 1; }
         fi
         chsh -s "$ZSH_PATH" || { print_error "Failed to change shell"; exit 1; }

     elif [[ "$PKG_MANAGER" == "brew" ]]; then
         # macOS: chsh with brew zsh
         chsh -s "$ZSH_PATH" || { print_error "Failed to change shell"; exit 1; }
     fi

     print_success "Default shell changed to zsh"
 }

###############################################################################
# Summary
###############################################################################

summary() {
    echo ""
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║            Workstation Setup Complete               ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo ""

    print_success "Embedded toolchain installed"
    print_success "Robotics packages installed"
    print_success "Ghostty installed"
    print_success "Ollama installed"
    print_success "LazyVim installed"
    print_success "tmux + TPM installed"
    print_success "zsh + p10k installed"

    echo ""
    echo "Reboot recommended."
    echo ""
}

###############################################################################
# Main
###############################################################################

 main() {
     echo ""
     echo "═══════════════════════════════════════════════════════"
     echo " Embedded / Robotics Workstation Setup"
     echo "═══════════════════════════════════════════════════════"
     echo ""

     # Initialize package file paths relative to this script
     APT_PACKAGES_FILE="$(cd "$(dirname "$SCRIPT_DIR")" && pwd)/apt/packages.txt"
     BREWFILE="$(cd "$(dirname "$SCRIPT_DIR")" && pwd)/brew/Brewfile"

     check_not_root

     detect_package_manager

     acquire_sudo

     # =========================================================================
     # SUDO BATCH (all privileged operations run back-to-back)
     # =========================================================================
     print_step "Phase 1: System & Package Installation (sudo)"

     update_system

     install_all_packages

     install_neovim

     install_ghostty

     install_ollama

     change_shell

     # =========================================================================
     # NON-SUDO BATCH (all user-level operations after sudo operations)
     # =========================================================================
     print_step "Phase 2: User Configuration (no sudo)"

     install_oh_my_zsh

     install_zsh_plugins

     install_fonts

     install_lazyvim

     install_tpm

     setup_dotfiles

     summary
 }

 main "$@"
