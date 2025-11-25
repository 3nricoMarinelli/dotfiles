#!/bin/bash

###############################################################################
# ROS2 Humble + PX4 Setup Script for Ubuntu 22.04
# Native installation (no Docker)
#
# Installation Order:
# 1. System dependencies
# 2. ROS2 Humble Desktop
# 3. ROS2 development tools
# 4. PX4 Autopilot dependencies
# 5. PX4 Autopilot source code
# 6. Gazebo simulation environment
# 7. Workspace setup
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

# Check if running on Ubuntu 22.04
check_ubuntu_version() {
  print_step "Checking Ubuntu version..."

  if [ ! -f /etc/os-release ]; then
    print_error "Cannot detect OS version"
    exit 1
  fi

  . /etc/os-release

  if [ "$ID" != "ubuntu" ]; then
    print_error "This script is designed for Ubuntu only"
    print_error "Detected: $ID"
    exit 1
  fi

  if [ "$VERSION_ID" != "22.04" ]; then
    print_warning "This script is tested on Ubuntu 22.04"
    print_warning "Detected: Ubuntu $VERSION_ID"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  else
    print_success "Ubuntu 22.04 detected"
  fi
}

# Check if running as root (should not)
check_not_root() {
  if [ "$EUID" -eq 0 ]; then
    print_error "Please run this script as a normal user (not root)"
    print_error "The script will prompt for sudo password when needed"
    exit 1
  fi
}

# Update system
update_system() {
  print_step "Updating system packages..."
  sudo apt-get update
  sudo apt-get upgrade -y
  print_success "System updated"
}

# Install basic dependencies
install_basic_deps() {
  print_step "Installing basic dependencies..."
  sudo apt-get install -y \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    gnupg \
    lsb-release \
    git \
    build-essential \
    cmake \
    python3-pip \
    python3-venv
  print_success "Basic dependencies installed"
}

# Install ROS2 Humble
install_ros2_humble() {
  print_step "Installing ROS2 Humble..."

  # Check if already installed
  if [ -f /opt/ros/humble/setup.bash ]; then
    print_success "ROS2 Humble already installed"
    return
  fi

  # Add ROS2 repository
  print_step "Adding ROS2 repository..."
  sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

  sudo apt-get update

  # Install ROS2 Humble Desktop (includes RViz, demos, tutorials)
  print_step "Installing ROS2 Humble Desktop (this may take a while)..."
  sudo apt-get install -y ros-humble-desktop

  # Install ROS2 development tools
  print_step "Installing ROS2 development tools..."
  sudo apt-get install -y \
    ros-dev-tools \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool

  # Initialize rosdep
  if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
    print_step "Initializing rosdep..."
    sudo rosdep init
  fi
  rosdep update

  print_success "ROS2 Humble installed"
}

# Install ROS2 packages for PX4
install_ros2_px4_packages() {
  print_step "Installing ROS2 packages for PX4..."

  # Install common ROS2 packages
  sudo apt-get install -y \
    ros-humble-eigen3-cmake-module \
    ros-humble-xacro \
    ros-humble-joint-state-publisher \
    ros-humble-robot-state-publisher \
    ros-humble-geographic-msgs \
    ros-humble-sensor-msgs \
    ros-humble-cv-bridge

  # Try to install Gazebo-ROS integration (may not be available for all Gazebo versions)
  if sudo apt-cache show ros-humble-ros-gz 2>/dev/null | grep -q "Package: ros-humble-ros-gz"; then
    print_step "Installing ROS2-Gazebo integration..."
    sudo apt-get install -y ros-humble-ros-gz
    print_success "ROS2-Gazebo integration installed"
  else
    print_warning "ros-humble-ros-gz not available, skipping Gazebo-ROS bridge"
    print_warning "You can build the bridge manually later if needed"
  fi

  print_success "ROS2 PX4 packages installed"
}

# Install PX4 dependencies
install_px4_deps() {
  print_step "Installing PX4 dependencies..."

  # Install common dependencies
  sudo apt-get install -y \
    git \
    make \
    cmake \
    ninja-build \
    ccache \
    astyle \
    clang-format \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    libgstreamer-plugins-base1.0-dev \
    libimage-exiftool-perl \
    libopencv-dev \
    protobuf-compiler \
    geographiclib-tools

  # Install MAVLink dependencies
  pip3 install --user --upgrade \
    pymavlink \
    MAVProxy \
    pyros-genmsg \
    packaging \
    toml \
    numpy \
    empy==3.3.4 \
    jinja2 \
    jsonschema \
    kconfiglib \
    future \
    pyyaml

  print_success "PX4 dependencies installed"
}

# Install Gazebo
install_gazebo() {
  print_step "Checking Gazebo installation..."

  # Check if Gazebo (new) is already installed
  if command -v gz &>/dev/null; then
    GZ_VERSION=$(gz sim --version 2>/dev/null | head -1 || echo 'unknown version')
    print_success "Gazebo already installed ($GZ_VERSION)"
    return
  fi

  # Check if Gazebo Classic is already installed
  if command -v gazebo &>/dev/null; then
    GAZEBO_VERSION=$(gazebo --version 2>/dev/null | head -1 || echo 'unknown version')
    print_success "Gazebo Classic already installed ($GAZEBO_VERSION)"
    return
  fi

  # Offer choice between Gazebo Classic and Gazebo (new)
  echo ""
  print_step "No Gazebo installation found."
  echo "Choose Gazebo version to install:"
  echo "  1) Gazebo Classic (gazebo11) - Stable, well-tested with PX4"
  echo "  2) Gazebo (gz-garden) - Newer version, better performance"
  echo "  3) Skip Gazebo installation"
  echo ""
  read -p "Enter choice [1-3] (default: 1): " -n 1 -r GAZEBO_CHOICE
  echo ""

  case "${GAZEBO_CHOICE:-1}" in
    1)
      print_step "Installing Gazebo Classic (gazebo11)..."
      sudo apt-get install -y gazebo libgazebo-dev
      print_success "Gazebo Classic installed"
      ;;
    2)
      print_step "Installing Gazebo Garden..."
      # Add Gazebo repository
      sudo wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
      sudo apt-get update

      # Install Gazebo Garden (more compatible with Ubuntu 22.04 than Harmonic)
      if sudo apt-cache show gz-garden 2>/dev/null | grep -q "Package: gz-garden"; then
        sudo apt-get install -y gz-garden
        print_success "Gazebo Garden installed"
      else
        print_warning "Gazebo Garden not available, trying Gazebo Harmonic..."
        if sudo apt-cache show gz-harmonic 2>/dev/null | grep -q "Package: gz-harmonic"; then
          sudo apt-get install -y gz-harmonic
          print_success "Gazebo Harmonic installed"
        else
          print_error "No Gazebo packages available"
          print_warning "You may need to install Gazebo manually"
        fi
      fi
      ;;
    3)
      print_warning "Skipping Gazebo installation"
      ;;
    *)
      print_error "Invalid choice, skipping Gazebo installation"
      ;;
  esac
}

# Install visualization and hardware-acceleration helper packages
## NOTE: Visualization / hardware-acceleration dependencies (for VMs / UTM) were
## moved to setup-utm-desktop.sh. Run that script inside a UTM VM to install
## display drivers and SPICE/virtio helpers when needed.

# Clone PX4 Autopilot
clone_px4() {
  print_step "Cloning PX4 Autopilot..."

  PX4_DIR="$HOME/PX4-Autopilot"

  if [ -d "$PX4_DIR" ]; then
    print_warning "PX4-Autopilot directory already exists at $PX4_DIR"
    read -p "Update existing repository? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      cd "$PX4_DIR"
      git fetch origin
      git checkout main
      git pull
      print_success "PX4 Autopilot updated"
    else
      print_warning "Skipping PX4 clone"
      return
    fi
  else
    git clone https://github.com/PX4/PX4-Autopilot.git --recursive "$PX4_DIR"
    cd "$PX4_DIR"
    print_success "PX4 Autopilot cloned"
  fi

  # Run PX4 setup script
  print_step "Running PX4 setup script..."
  cd "$PX4_DIR"
  bash ./Tools/setup/ubuntu.sh --no-sim-tools

  print_success "PX4 setup complete"
}

# Setup ROS2 workspace
setup_ros2_workspace() {
  print_step "Setting up ROS2 workspace..."

  WORKSPACE_DIR="$HOME/ros2_ws"

  if [ -d "$WORKSPACE_DIR" ]; then
    print_success "ROS2 workspace already exists at $WORKSPACE_DIR"
  else
    mkdir -p "$WORKSPACE_DIR/src"
    print_success "ROS2 workspace created at $WORKSPACE_DIR"
  fi

  # Clone PX4 ROS2 bridge
  print_step "Cloning PX4 ROS2 bridge..."
  if [ -d "$WORKSPACE_DIR/src/px4_ros_com" ]; then
    print_success "PX4 ROS2 bridge already exists"
  else
    cd "$WORKSPACE_DIR/src"
    git clone https://github.com/PX4/px4_ros_com.git
    git clone https://github.com/PX4/px4_msgs.git
    print_success "PX4 ROS2 bridge cloned"
  fi

  # Build workspace
  print_step "Building ROS2 workspace (this may take a while)..."
  cd "$WORKSPACE_DIR"
  source /opt/ros/humble/setup.bash
  colcon build

  print_success "ROS2 workspace built"
}

# Setup environment
setup_environment() {
  print_step "Setting up environment..."

  BASHRC="$HOME/.bashrc"

  # Add ROS2 setup to bashrc if not already present
  if ! grep -q "source /opt/ros/humble/setup.bash" "$BASHRC"; then
    echo "" >> "$BASHRC"
    echo "# ROS2 Humble" >> "$BASHRC"
    echo "source /opt/ros/humble/setup.bash" >> "$BASHRC"
    print_success "Added ROS2 to .bashrc"
  fi

  # Add ROS2 workspace to bashrc if not already present
  if [ -d "$HOME/ros2_ws" ]; then
    if ! grep -q "source $HOME/ros2_ws/install/setup.bash" "$BASHRC"; then
      echo "source $HOME/ros2_ws/install/setup.bash" >> "$BASHRC"
      print_success "Added ROS2 workspace to .bashrc"
    fi
  fi

  # Add PX4 setup to bashrc if not already present
  if [ -d "$HOME/PX4-Autopilot" ]; then
    if ! grep -q "PX4-Autopilot" "$BASHRC"; then
      echo "" >> "$BASHRC"
      echo "# PX4 Autopilot" >> "$BASHRC"
      echo "export PX4_DIR=$HOME/PX4-Autopilot" >> "$BASHRC"
      echo "alias px4='cd \$PX4_DIR'" >> "$BASHRC"
      print_success "Added PX4 aliases to .bashrc"
    fi
  fi

  # Add colcon autocompletion
  if ! grep -q "colcon_cd" "$BASHRC"; then
    echo "" >> "$BASHRC"
    echo "# Colcon autocompletion" >> "$BASHRC"
    echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> "$BASHRC"
    echo "export _colcon_cd_root=~/ros2_ws" >> "$BASHRC"
  fi

  print_success "Environment configured"
}

# Print next steps
print_next_steps() {
  echo ""
  echo "╔═══════════════════════════════════════════════════════════╗"
  echo "║         ROS2 Humble + PX4 Installation Complete!         ║"
  echo "╚═══════════════════════════════════════════════════════════╝"
  echo ""
  print_success "Installation successful!"
  echo ""
  echo "Next steps:"
  echo "1. Restart your terminal or run: source ~/.bashrc"
  echo "2. Test ROS2: ros2 topic list"
  echo "3. Build PX4 SITL: cd ~/PX4-Autopilot && make px4_sitl"
  echo ""
  echo "4. Run simulation:"
  if command -v gazebo &>/dev/null; then
    echo "   Gazebo Classic: cd ~/PX4-Autopilot && make px4_sitl gazebo-classic_iris"
  fi
  if command -v gz &>/dev/null; then
    echo "   New Gazebo:     cd ~/PX4-Autopilot && make px4_sitl gz_x500"
  fi
  if ! command -v gazebo &>/dev/null && ! command -v gz &>/dev/null; then
    echo "   (No Gazebo installed - install manually or re-run script)"
  fi
  echo ""
  echo "Useful commands:"
  echo "  - px4                  : Navigate to PX4 directory"
  echo "  - ros2 run             : Run a ROS2 node"
  echo "  - colcon build         : Build ROS2 workspace"
  if command -v gazebo &>/dev/null; then
    echo "  - gazebo               : Launch Gazebo Classic"
  fi
  if command -v gz &>/dev/null; then
    echo "  - gz sim               : Launch new Gazebo"
  fi
  echo ""
  echo "Directories:"
  echo "  - PX4:        $HOME/PX4-Autopilot"
  echo "  - ROS2 ws:    $HOME/ros2_ws"
  echo ""
}

# Main installation function
main() {
  echo ""
  echo "╔═══════════════════════════════════════════════════════════╗"
  echo "║      ROS2 Humble + PX4 Setup for Ubuntu 22.04            ║"
  echo "║              Native Installation (no Docker)              ║"
  echo "╚═══════════════════════════════════════════════════════════╝"
  echo ""

  check_not_root
  check_ubuntu_version

  echo ""
  print_step "Starting installation..."
  echo ""

  # Phase 1: System setup
  update_system
  install_basic_deps

  # Phase 2: ROS2 installation
  install_ros2_humble
  install_ros2_px4_packages

  # Phase 3: PX4 dependencies
  install_px4_deps
  install_gazebo
  # For VM / UTM specific visualization, drivers and hardware acceleration helpers
  # run: ./setup-utm-desktop.sh (this keeps VM-specific packages out of native PX4 script)

  # Phase 4: PX4 Autopilot
  clone_px4

  # Phase 5: ROS2 workspace
  setup_ros2_workspace

  # Phase 6: Environment configuration
  setup_environment

  # Done
  print_next_steps
}

main "$@"
