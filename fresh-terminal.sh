#!/bin/bash

###############################################################################
# Fresh Terminal Setup Script
# Sets up: zsh, oh-my-zsh, fzf, ncdu, python, tmux, lazyvim
###############################################################################

set -e # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if running with sudo for system packages
check_sudo() {
  if [ "$EUID" -eq 0 ]; then
    print_warning "Please run this script as a normal user (not root)"
    print_warning "The script will prompt for sudo when needed"
    exit 1
  fi
}

# Support only Ubuntu and MacOS
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
    print_error "No supported package manager found!"
    exit 1
  fi
  print_success "Detected package manager: $PKG_MANAGER"
}

update_system() {
  print_step "Checking system packages..."
  # Only update if we have sudo access without password prompt
  if sudo -n true 2>/dev/null; then
    print_step "Updating system packages..."
    $UPDATE_CMD
    print_success "System packages updated"
  else
    print_warning "Skipping system update (no sudo access or password required)"
    print_warning "System packages will be installed only if already available"
  fi
}

install_zsh() {
  print_step "Checking zsh..."
  if [ -x "$(command -v zsh 2>/dev/null)" ]; then
    print_success "zsh already installed"
    return
  fi

  if sudo -n true 2>/dev/null; then
    $INSTALL_CMD zsh
    # Refresh command hash
    hash -r 2>/dev/null || true
    if [ -x "$(command -v zsh 2>/dev/null)" ]; then
      print_success "zsh installed"
    else
      print_error "zsh installation failed"
      exit 1
    fi
  else
    print_error "zsh not found and sudo not available. Please install zsh manually."
    exit 1
  fi
}

install_oh_my_zsh() {
  print_step "Installing oh-my-zsh..."
  if [ -d "$HOME/.oh-my-zsh" ]; then
    print_warning "oh-my-zsh already installed, skipping..."
  else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "oh-my-zsh installed"
  fi
}

configure_zshrc() {
  print_step "Configuring .zshrc for compatibility..."

  # Add PATH for local binaries
  if ! grep -q "\$HOME/.local/bin" "$HOME/.zshrc" 2>/dev/null; then
    cat >> "$HOME/.zshrc" << 'EOF'

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"
EOF
    print_success "Added ~/.local/bin to PATH in .zshrc"
  fi

  # Add TERM compatibility fix for Ghostty and other terminals
  if ! grep -q "Fix TERM for compatibility" "$HOME/.zshrc" 2>/dev/null; then
    cat >> "$HOME/.zshrc" << 'EOF'

# Fix TERM for compatibility on systems without Ghostty
if [[ "$TERM" == "xterm-ghostty" ]]; then
  if ! infocmp "$TERM" &>/dev/null; then
    export TERM="xterm-256color"
  fi
fi
EOF
    print_success "Added TERM compatibility fix to .zshrc"
  else
    print_success ".zshrc already configured"
  fi
}

install_fzf() {
  print_step "Installing fzf..."

  # Refresh command hash
  hash -r 2>/dev/null || true

  if [ -x "$(command -v fzf 2>/dev/null)" ]; then
    print_success "fzf already installed"
    return
  fi

  if [ "$PKG_MANAGER" = "apt" ]; then
    $INSTALL_CMD fzf
  elif [ "$PKG_MANAGER" = "brew" ]; then
    $INSTALL_CMD fzf
  else
    # Install from git for other systems
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
  fi

  # Refresh command hash again
  hash -r 2>/dev/null || true
  print_success "fzf installed"
}

install_ncdu() {
  print_step "Checking ncdu..."
  if command -v ncdu &>/dev/null; then
    print_success "ncdu already installed"
  else
    if sudo -n true 2>/dev/null; then
      $INSTALL_CMD ncdu
      print_success "ncdu installed"
    else
      print_warning "ncdu not found and sudo not available. Skipping ncdu installation."
    fi
  fi
}

install_cmake() {
  print_step "Checking cmake..."
  if command -v cmake &>/dev/null; then
    print_success "cmake already installed"
  else
    if sudo -n true 2>/dev/null; then
      $INSTALL_CMD cmake
      print_success "cmake installed"
    else
      print_warning "cmake not found and sudo not available. Skipping cmake installation."
    fi
  fi
}

install_curl_wget() {
  print_step "Checking curl and wget..."
  if command -v curl &>/dev/null; then
    print_success "curl already installed"
  else
    if sudo -n true 2>/dev/null; then
      $INSTALL_CMD curl
      print_success "curl installed"
    else
      print_warning "curl not found and sudo not available. Skipping curl installation."
    fi
  fi
  if command -v wget &>/dev/null; then
    print_success "wget already installed"
  else
    if sudo -n true 2>/dev/null; then
      $INSTALL_CMD wget
      print_success "wget installed"
    else
      print_warning "wget not found and sudo not available. Skipping wget installation."
    fi
  fi
}

install_python() {
  print_step "Checking Python..."
  if command -v python3 &>/dev/null; then
    print_success "Python already installed ($(python3 --version))"
  else
    if sudo -n true 2>/dev/null; then
      if [ "$PKG_MANAGER" = "apt" ]; then
        $INSTALL_CMD python3 python3-pip python3-venv
      else
        $INSTALL_CMD python3
      fi
      print_success "Python installed"
    else
      print_error "Python not found and sudo not available. Python is required."
      exit 1
    fi
  fi
}

install_tmux() {
  print_step "Checking tmux..."
  if command -v tmux &>/dev/null; then
    print_success "tmux already installed ($(tmux -V))"
  else
    if sudo -n true 2>/dev/null; then
      $INSTALL_CMD tmux
      print_success "tmux installed"
    else
      print_warning "tmux not found and sudo not available. Skipping tmux installation."
    fi
  fi
}

install_neovim() {
  print_step "Checking Neovim..."
  if command -v nvim &>/dev/null; then
    print_success "Neovim already installed ($(nvim --version | head -n1))"
    return
  fi

  # Try installing via package manager if sudo available
  if sudo -n true 2>/dev/null; then
    $INSTALL_CMD neovim
    if command -v nvim &>/dev/null; then
      print_success "Neovim installed via package manager"
      return
    fi
  fi

  # Detect architecture
  ARCH=$(uname -m)

  # Try tarball installation (works for x86_64)
  if [ "$ARCH" = "x86_64" ]; then
    print_step "Installing Neovim tarball (no sudo required)..."
    mkdir -p "$HOME/.local/bin"
    cd /tmp
    if wget -q https://github.com/neovim/neovim/releases/download/v0.10.3/nvim-linux64.tar.gz; then
      tar xzf nvim-linux64.tar.gz
      rm -rf "$HOME/.local/nvim-linux64"
      mv nvim-linux64 "$HOME/.local/"
      ln -sf "$HOME/.local/nvim-linux64/bin/nvim" "$HOME/.local/bin/nvim"
      rm -f nvim-linux64.tar.gz

      if command -v nvim &>/dev/null; then
        print_success "Neovim installed successfully"
        return
      fi
    fi
  fi

  # For ARM64 or if tarball failed, neovim needs sudo
  print_warning "Neovim not available without sudo on ARM64/aarch64"
  print_warning "To install Neovim, run: sudo apt-get install neovim"
  print_warning "Or: sudo snap install nvim --classic"
  print_warning "Continuing without Neovim..."
}

install_lazyvim() {
  print_step "Checking LazyVim..."

  # Only install LazyVim if neovim is available
  if ! command -v nvim &>/dev/null; then
    print_warning "Neovim not installed, skipping LazyVim installation"
    return
  fi

  # Backup existing nvim config if it exists
  if [ -d "$HOME/.config/nvim" ]; then
    print_warning "Backing up existing Neovim config..."
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d%H%M%S)"
    mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.backup.$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
    mv "$HOME/.local/state/nvim" "$HOME/.local/state/nvim.backup.$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
    mv "$HOME/.cache/nvim" "$HOME/.cache/nvim.backup.$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
  fi

  # Clone LazyVim starter
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim/.git"

  print_success "LazyVim installed"
}

install_git() {
  print_step "Checking git..."
  if command -v git &>/dev/null; then
    print_success "git already installed"
  else
    if sudo -n true 2>/dev/null; then
      $INSTALL_CMD git
      print_success "git installed"
    else
      print_error "git not found and sudo not available. Git is required."
      exit 1
    fi
  fi
}

install_dotfiles() {
  print_step "Cloning dotfiles from https://github.com/3nricoMarinelli/dotfiles..."

  TEMP_DIR=$(mktemp -d)
  git clone https://github.com/3nricoMarinelli/dotfiles "$TEMP_DIR"

  print_step "Moving dotfiles to home directory (overwriting existing files)..."

  # Copy all files and directories from the repo to home
  shopt -s dotglob # Include hidden files
  for item in "$TEMP_DIR"/*; do
    if [ -e "$item" ]; then
      basename_item=$(basename "$item")
      # Skip .git directory
      if [ "$basename_item" != ".git" ]; then
        cp -rf "$item" "$HOME/"
        print_success "Copied $basename_item"
      fi
    fi
  done

  # Cleanup
  rm -rf "$TEMP_DIR"
  print_success "Dotfiles installed and applied"
}

change_shell() {
  print_step "Changing default shell to zsh..."

  # Find zsh path
  ZSH_PATH=$(which zsh 2>/dev/null || echo "")

  if [ -z "$ZSH_PATH" ]; then
    # Try common locations
    if [ -x "/usr/bin/zsh" ]; then
      ZSH_PATH="/usr/bin/zsh"
    elif [ -x "/bin/zsh" ]; then
      ZSH_PATH="/bin/zsh"
    elif [ -x "/usr/local/bin/zsh" ]; then
      ZSH_PATH="/usr/local/bin/zsh"
    else
      print_error "Cannot find zsh executable"
      exit 1
    fi
  fi

  print_success "Found zsh at: $ZSH_PATH"

  if [ "$SHELL" = "$ZSH_PATH" ]; then
    print_success "Default shell is already zsh"
  else
    # Ensure zsh is in /etc/shells
    if ! grep -q "^${ZSH_PATH}$" /etc/shells 2>/dev/null; then
      print_step "Adding zsh to /etc/shells..."
      echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi

    chsh -s "$ZSH_PATH"
    print_success "Default shell changed to zsh (restart terminal to apply)"
  fi
}

main() {
  echo ""
  echo "╔═══════════════════════════════════════════════════════════╗"
  echo "║         Fresh Terminal Setup Script                       ║"
  echo "╚═══════════════════════════════════════════════════════════╝"
  echo ""

  check_sudo
  detect_package_manager

  echo ""
  print_step "Starting installation..."
  echo ""

  update_system
  install_git
  install_zsh
  install_oh_my_zsh
  configure_zshrc
  install_curl_wget
  install_cmake
  install_fzf
  install_ncdu
  install_python
  install_tmux
  install_neovim
  install_lazyvim
  install_dotfiles
  change_shell

  echo ""
  echo "╔═══════════════════════════════════════════════════════════╗"
  echo "║         Installation Complete! 🎉                         ║"
  echo "╚═══════════════════════════════════════════════════════════╝"
  echo ""
  print_success "All components installed successfully!"
  echo ""
  print_warning "Please restart your terminal or run: exec zsh"
  print_warning "LazyVim will install plugins on first run of nvim"
  echo ""
}

main
