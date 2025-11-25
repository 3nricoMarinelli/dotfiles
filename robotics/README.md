# Robotics Development Environment

This directory contains setup scripts and configuration for ROS2 Humble + PX4 Autopilot development.

## Setup Options

### Option 1: Native Ubuntu Installation (Recommended for Ubuntu users)

For Ubuntu 22.04 users who want to install ROS2 Humble and PX4 directly on their system.

```bash
./setup-ubuntu-ros2-px4.sh
```

**What it installs:**
- ROS2 Humble Desktop (with RViz, demos, tutorials)
- ROS2 development tools (colcon, rosdep, vcstool)
- ROS2 packages for robotics (eigen3, xacro, geographic-msgs, sensor-msgs)
- PX4 Autopilot source code and dependencies
- Gazebo simulator (you choose: Classic or Garden during installation)
- PX4 ROS2 bridge (px4_ros_com, px4_msgs)
- Optional: Gazebo-ROS integration (if available)

**Requirements:**
- Ubuntu 22.04 (tested, other versions may work)
- ~15 GB free disk space
- Internet connection
- Sudo privileges

**Installation time:** ~30-45 minutes depending on internet speed

**Directories created:**
- `~/PX4-Autopilot` - PX4 source code
- `~/ros2_ws` - ROS2 workspace with PX4 bridge

**During installation:**
- You'll be prompted to choose a Gazebo version:
  - **Gazebo Classic (gazebo11)**: Recommended for beginners, stable and well-tested with PX4
  - **Gazebo Garden**: Newer version with better performance, but may have compatibility issues
  - Skip if you already have Gazebo or want to install it manually

**After installation:**
```bash
# Restart terminal or source bashrc
source ~/.bashrc

# Test ROS2
ros2 topic list

# Build and run PX4 SITL
cd ~/PX4-Autopilot
make px4_sitl

# Run Gazebo simulation (if using Gazebo Classic)
cd ~/PX4-Autopilot
make px4_sitl gazebo-classic_iris

# Or for newer Gazebo (Garden/Harmonic)
cd ~/PX4-Autopilot
make px4_sitl gz_x500
```

---

### Option 2: Docker Container (For macOS or other systems)

For macOS or non-Ubuntu systems, use the Docker-based setup.

```bash
# Setup host (install Docker, configure XQuartz on macOS)
./setup-host.sh

# Start containers
docker-compose up -d

# Enter development container
docker exec -it ros2-px4-dev bash
```

**What it provides:**
- Isolated Ubuntu 22.04 container
- Pre-configured ROS2 Humble + PX4 environment
- X11 forwarding for GUI applications (RViz, Gazebo)
- Volume mounts for code persistence

**Requirements:**
- Docker Desktop installed
- ~10 GB free disk space
- On macOS: XQuartz for GUI applications

**Note:** Docker on macOS has limitations with OpenGL acceleration, so Gazebo performance may be reduced. Consider using a VM for better performance.

---

### Option 3: GUI Display Setup

#### For UTM VMs (Recommended)

If you're running Ubuntu in UTM on macOS with virtio-gpu-pci display:

```bash
./setup-utm-desktop.sh
```

**Why this is best for UTM:**
- Uses UTM's native display (better performance than VNC/X11)
- Direct GPU access with virtio-gpu-pci
- Good 3D acceleration for Gazebo
- Desktop environment choices: XFCE (recommended), GNOME, or LXDE
- No network configuration needed

**After installation:**
1. Reboot the VM: `sudo reboot`
2. Desktop will appear in UTM's console window
3. Use UTM's "Fit to Screen" (Cmd+0) for best view
4. Enable "Retina Mode" in UTM display settings for better quality

**UTM configuration tips:**
- Display: virtio-gpu-pci (already configured)
- RAM: 4GB+ recommended for Gazebo
- CPU: 4+ cores recommended for ROS2 builds
- Resolution: Increase if display is too small

---

#### For Other Headless VMs

If you're running a headless VM (not UTM) or need remote access:

```bash
./setup-gui-display.sh
```

**Display options:**

1. **X11 Forwarding** (Simple, lightweight)
   - No desktop environment needed
   - Good for: RViz, simple GUIs, testing
   - Connect: `ssh -X user@vm_ip`
   - Test with: `xeyes`

2. **VNC Server** (Better performance)
   - Full desktop environment (XFCE/GNOME/LXDE)
   - Good for: Gazebo, heavy applications
   - Connect: Use VNC viewer on host machine
   - Resolution: 1920x1080 (configurable)

**macOS host setup for X11:**
```bash
# Install XQuartz (X11 server for macOS)
brew install --cask xquartz

# After installing, logout and login (or restart)
# Then connect with:
ssh -Y user@vm_ip
```

**VNC client for macOS:**
```bash
# Built-in (Finder > Go > Connect to Server > vnc://vm_ip:5901)
# Or install TigerVNC:
brew install --cask tigervnc-viewer
```

---

## Quick Command Reference

### ROS2 Commands
```bash
# List all topics
ros2 topic list

# Echo a topic
ros2 topic echo /topic_name

# List all nodes
ros2 node list

# Build workspace
cd ~/ros2_ws
colcon build

# Source workspace
source ~/ros2_ws/install/setup.bash
```

### PX4 Commands
```bash
# Build PX4 for SITL (Software In The Loop)
cd ~/PX4-Autopilot
make px4_sitl

# Build and run with Gazebo Classic
make px4_sitl gazebo-classic_iris

# Build and run with new Gazebo (Garden/Harmonic)
make px4_sitl gz_x500

# List all available make targets
make list_vmd_make_targets

# Clean build
make clean
make distclean

# Run PX4 tests
make tests
```

### Gazebo Commands
```bash
# Gazebo Classic commands:
gazebo                          # Launch Gazebo Classic
gazebo --version                # Check version
killall -9 gzserver gzclient    # Kill if stuck

# New Gazebo (Garden/Harmonic) commands:
gz sim                          # Launch Gazebo
gz sim --version                # Check version
gz model --list                 # List available models
killall -9 gz                   # Kill if stuck

# Universal: Kill all Gazebo processes
killall -9 gz gzserver gzclient
```

---

## Troubleshooting

### "Unable to locate package ros-humble-*"
This usually means:
1. ROS2 repository not added correctly - re-run the script or manually add:
```bash
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt update
```
2. Package doesn't exist for your ROS2 version - the script will skip optional packages automatically

### ROS2 not found
```bash
source /opt/ros/humble/setup.bash
```

### PX4 build fails
```bash
cd ~/PX4-Autopilot
make distclean
make px4_sitl
```

### Gazebo won't start
```bash
# Kill existing processes
killall -9 gz gzserver gzclient

# Clear Gazebo cache
rm -rf ~/.gz
```

### Permission denied errors
```bash
# Fix workspace permissions
sudo chown -R $USER:$USER ~/ros2_ws
```

### X11 forwarding not working
```bash
# On VM: Check X11 forwarding is enabled
grep X11Forwarding /etc/ssh/sshd_config
# Should show: X11Forwarding yes

# Reconnect with X11 forwarding
ssh -Y user@vm_ip

# Test X11
echo $DISPLAY  # Should show something like localhost:10.0
xeyes          # Should open a GUI window

# If still not working on macOS:
# 1. Install XQuartz: brew install --cask xquartz
# 2. Logout and login (or restart)
# 3. Open XQuartz from Applications
# 4. In XQuartz preferences, enable "Allow connections from network clients"
```

### VNC connection refused
```bash
# Check VNC service status
sudo systemctl status vncserver@1

# Restart VNC service
sudo systemctl restart vncserver@1

# Check VNC is listening
netstat -tulpn | grep 5901

# Check firewall (if enabled)
sudo ufw status
sudo ufw allow 5901/tcp
```

### Gazebo black screen or crashes in VNC
```bash
# Add to ~/.bashrc for software rendering
export LIBGL_ALWAYS_SOFTWARE=1

# Or try with different rendering
export SVGA_VGPU10=0

# Restart VNC after adding these
sudo systemctl restart vncserver@1
```

### UTM: Display shows login screen but no desktop after login
```bash
# Check display manager status
sudo systemctl status lightdm
# or
sudo systemctl status gdm3

# Restart display manager
sudo systemctl restart lightdm

# Check logs
journalctl -xe | grep -i display
```

### UTM: Gazebo performance issues or rendering errors
```bash
# Check OpenGL version
glxinfo | grep "OpenGL version"

# If version is low, try software rendering
echo 'export LIBGL_ALWAYS_SOFTWARE=1' >> ~/.bashrc
source ~/.bashrc

# Check video driver
lspci | grep VGA

# Allocate more RAM in UTM settings (4GB+ for Gazebo)
# Allocate more CPU cores (4+ recommended)
```

### UTM: Screen resolution too small or doesn't fit
```bash
# In UTM app:
# 1. View > Zoom to Fit (Cmd+1)
# 2. View > Fit to Screen (Cmd+0)
# 3. Display settings > Enable "Retina Mode"

# In VM: Increase resolution (XFCE)
# Settings > Display > Resolution

# Or manually set resolution
xrandr --output Virtual-1 --mode 1920x1080
```

---

## Development Workflow

### 1. Create a new ROS2 package
```bash
cd ~/ros2_ws/src
ros2 pkg create --build-type ament_cmake my_package
cd ~/ros2_ws
colcon build --packages-select my_package
```

### 2. Run PX4 SITL with ROS2 bridge
```bash
# Terminal 1: Start PX4
cd ~/PX4-Autopilot
make px4_sitl gz_x500

# Terminal 2: Run micrortps agent
MicroXRCEAgent udp4 -p 8888

# Terminal 3: Run your ROS2 nodes
source ~/ros2_ws/install/setup.bash
ros2 run my_package my_node
```

### 3. Monitor with RViz
```bash
rviz2
```

---

## Additional Resources

- [ROS2 Documentation](https://docs.ros.org/en/humble/)
- [PX4 User Guide](https://docs.px4.io/)
- [PX4 ROS2 Integration](https://docs.px4.io/main/en/ros/ros2_comm.html)
- [Gazebo Documentation](https://gazebosim.org/docs)

---

## Maintenance

### Update ROS2 packages
```bash
sudo apt update
sudo apt upgrade ros-humble-*
```

### Update PX4
```bash
cd ~/PX4-Autopilot
git fetch origin
git checkout main
git pull
git submodule update --init --recursive
```

### Update ROS2 workspace
```bash
cd ~/ros2_ws
git -C src/px4_ros_com pull
git -C src/px4_msgs pull
colcon build
```
