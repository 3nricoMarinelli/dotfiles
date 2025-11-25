#!/bin/bash

###############################################################################
# Desktop Environment Setup for UTM VM
# Configures Ubuntu for UTM with virtio-gpu-pci display
#
# This script installs a desktop environment optimized for UTM's native display
# (better than VNC or X11 forwarding)
###############################################################################

set -e

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

check_not_root() {
  if [ "$EUID" -eq 0 ]; then
    print_error "Please run this script as a normal user (not root)"
    exit 1
  fi
}

# Install desktop environment
install_desktop() {
  echo ""
  echo "Choose desktop environment:"
  echo ""
  echo "  1) XFCE (Recommended - lightweight, fast)"
  echo "     - Memory: ~500MB"
  echo "     - Best for: ROS2 development, Gazebo"
  echo ""
  echo "  2) GNOME (Full-featured, modern)"
  echo "     - Memory: ~1.5GB"
  echo "     - Best for: Full Ubuntu desktop experience"
  echo ""
  echo "  3) LXDE (Very lightweight)"
  echo "     - Memory: ~300MB"
  echo "     - Best for: Limited VM resources"
  echo ""
  read -p "Enter choice [1-3] (default: 1): " -n 1 -r DE_CHOICE
  echo ""

  sudo apt-get update

  case "${DE_CHOICE:-1}" in
    1)
      print_step "Installing XFCE desktop..."
      sudo apt-get install -y \
        xfce4 \
        xfce4-goodies \
        lightdm \
        lightdm-gtk-greeter \
        lightdm-gtk-greeter-settings
      DISPLAY_MANAGER="lightdm"
      print_success "XFCE desktop installed"
      ;;
    2)
      print_step "Installing GNOME desktop..."
      sudo apt-get install -y \
        ubuntu-desktop \
        gdm3
      DISPLAY_MANAGER="gdm3"
      print_success "GNOME desktop installed"
      ;;
    3)
      print_step "Installing LXDE desktop..."
      sudo apt-get install -y \
        lxde \
        lightdm \
        lightdm-gtk-greeter
      DISPLAY_MANAGER="lightdm"
      print_success "LXDE desktop installed"
      ;;
    *)
      print_error "Invalid choice"
      exit 1
      ;;
  esac

  # Set default display manager
  sudo systemctl set-default graphical.target
  sudo systemctl enable $DISPLAY_MANAGER

  print_success "Display manager configured"
}

# Install graphics drivers and OpenGL support
install_graphics_support() {
  print_step "Installing graphics drivers and OpenGL support..."

  # Core packages for OpenGL / mesa / qxl display
  sudo apt-get install -y \
    mesa-utils \
    mesa-utils-extra \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    libglx-mesa0 \
    libglu1-mesa \
    libgles2-mesa \
    libglew2.2 \
    libdrm2 \
    xserver-xorg-video-qxl \

    # Additional virtualization / VM / UTM helper packages moved from PX4 setup
    libegl-mesa0 \
    libgbm1 \
    vulkan-tools \
    mesa-vulkan-drivers \
    spice-vdagent \
    spice-client-gtk \
    spice-webdavd \
    libgz-transport13-dev \
    libgz-sim8-dev \
    libgz-sensors8-dev

  print_success "Graphics & VM helper packages installed (where available)"

  # Attempt to install optional VM helper packages when available — don't fail overall
  OPTIONAL=(
    libvirglrenderer0
    libvirglrenderer1
    qemu-guest-agent
  )

  print_step "Attempting optional virtualization packages (may be missing on some arches)..."
  for pkg in "${OPTIONAL[@]}"; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      sudo apt-get install -y "$pkg" || true
      print_success "Installed optional package: $pkg"
    else
      print_warning "Optional package not available in apt: $pkg (skipping)"
    fi
  done

  # Enable SPICE agent if available
  if systemctl --version >/dev/null 2>&1; then
    if systemctl list-units --type=service | grep -q spice-vdagentd; then
      sudo systemctl enable --now spice-vdagentd.service || true
      print_success "SPICE agent enabled"
    else
      print_warning "SPICE service not present as a systemd unit (some packages provide only a binary)"
    fi
  fi

  print_success "Graphics drivers installed"
}

# Configure auto-login (optional)
configure_autologin() {
  echo ""
  read -p "Enable auto-login? (Skip login screen) [y/N]: " -n 1 -r AUTOLOGIN
  echo ""

  if [[ $AUTOLOGIN =~ ^[Yy]$ ]]; then
    USERNAME=$(whoami)

    if [ "$DISPLAY_MANAGER" = "lightdm" ]; then
      print_step "Configuring auto-login for lightdm..."
      sudo mkdir -p /etc/lightdm/lightdm.conf.d/
      cat << EOF | sudo tee /etc/lightdm/lightdm.conf.d/50-autologin.conf > /dev/null
[Seat:*]
autologin-user=$USERNAME
autologin-user-timeout=0
EOF
      print_success "Auto-login enabled for lightdm"
    elif [ "$DISPLAY_MANAGER" = "gdm3" ]; then
      print_step "Configuring auto-login for gdm3..."
      sudo sed -i "s/^#.*AutomaticLoginEnable.*$/AutomaticLoginEnable = true/" /etc/gdm3/custom.conf
      sudo sed -i "s/^#.*AutomaticLogin.*$/AutomaticLogin = $USERNAME/" /etc/gdm3/custom.conf
      print_success "Auto-login enabled for gdm3"
    fi
  else
    print_warning "Auto-login not configured"
  fi
}

# Optimize for Gazebo and 3D applications
optimize_for_gazebo() {
  print_step "Optimizing for Gazebo and 3D applications..."

  BASHRC="$HOME/.bashrc"

  # Add OpenGL optimization
  if ! grep -q "LIBGL_ALWAYS_SOFTWARE" "$BASHRC"; then
    cat >> "$BASHRC" << 'EOF'

# OpenGL and Gazebo optimization for UTM
# Comment these out if you have issues with 3D applications
export LIBGL_ALWAYS_INDIRECT=0
# export LIBGL_ALWAYS_SOFTWARE=1  # Uncomment if Gazebo has rendering issues

EOF
    print_success "OpenGL settings added to .bashrc"
  fi

  print_success "Optimization complete"
}

# Print post-installation instructions
print_instructions() {
  echo ""
  echo "╔═══════════════════════════════════════════════════════════╗"
  echo "║         Desktop Environment Installation Complete!        ║"
  echo "╚═══════════════════════════════════════════════════════════╝"
  echo ""
  print_success "Installation successful!"
  echo ""
  echo "Next steps:"
  echo "1. Reboot your VM: sudo reboot"
  echo "2. The desktop environment will start automatically"
  echo "3. Access the desktop through UTM's console window"
  echo ""
  echo "UTM Display Tips:"
  echo "- In UTM: Display > Fit to Screen (Cmd+0)"
  echo "- In UTM: Display > Zoom to Fit (Cmd+1)"
  echo "- Enable 'Retina Mode' in UTM display settings for better quality"
  echo ""
  echo "For better performance in UTM:"
  echo "- VM Settings > Display > select 'virtio-gpu-pci'"
  echo "- VM Settings > Display > increase 'Resolution' if needed"
  echo "- Allocate more RAM (4GB+ recommended for Gazebo)"
  echo "- Allocate more CPU cores (4+ recommended for ROS2 builds)"
  echo ""
  echo "Test graphics:"
  echo "  glxinfo | grep 'OpenGL version'  # Check OpenGL version"
  echo "  glxgears                         # Test 3D rendering"
  echo ""
  echo "If Gazebo has rendering issues, try:"
  echo "  1. Edit ~/.bashrc"
  echo "  2. Uncomment: export LIBGL_ALWAYS_SOFTWARE=1"
  echo "  3. Restart terminal or: source ~/.bashrc"
  echo ""
}

# Main installation function
main() {
  echo ""
  echo "╔═══════════════════════════════════════════════════════════╗"
  echo "║      Desktop Environment Setup for UTM VM                 ║"
  echo "║          Optimized for virtio-gpu-pci Display             ║"
  echo "╚═══════════════════════════════════════════════════════════╝"
  echo ""

  check_not_root

  print_step "This will install a desktop environment for UTM's native display"
  print_step "This is better than VNC or X11 forwarding for 3D applications"
  echo ""
  read -p "Continue? [Y/n]: " -n 1 -r CONTINUE
  echo ""

  if [[ $CONTINUE =~ ^[Nn]$ ]]; then
    print_warning "Installation cancelled"
    exit 0
  fi

  install_desktop
  install_graphics_support
  configure_autologin
  optimize_for_gazebo

  print_instructions
}

main "$@"
