# Dotfiles

Personal dotfiles for setting up a fresh terminal environment with zsh, oh-my-zsh, Neovim (LazyVim), tmux, and other useful tools. Includes optional Docker-based robotics development environment.

## What's Included

- **Zsh** - Modern shell with oh-my-zsh framework + Powerlevel10k theme
- **Oh-My-Zsh** - Zsh configuration framework with plugins and themes
- **Neovim + LazyVim** - Modern Neovim distribution with sensible defaults
- **Tmux** - Terminal multiplexer with Catppuccin theme and useful plugins
- **Utilities** - fzf, ncdu, cmake, curl, wget, python3, ripgrep
- **Robotics** (Linux only) - Docker-based ROS 2 + Gazebo + PX4 environment

## Quick Start

Run the setup script to install everything in one shot:

```bash
curl -fsSL https://raw.githubusercontent.com/3nricoMarinelli/dotfiles/main/fresh-terminal.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/3nricoMarinelli/dotfiles.git
cd dotfiles
chmod +x fresh-terminal.sh
./fresh-terminal.sh
```

The script will prompt for sudo password when needed for package installation.

## Supported Platforms

- **Ubuntu/Debian** (apt) - Full support including robotics
- **macOS** (Homebrew) - Developer tools only (no robotics Docker)

## Installation Order

The setup script installs components in the correct order:

1. **System packages** - git, curl, wget, cmake, ripgrep
2. **Zsh** - Shell installation
3. **Oh-My-Zsh** - Zsh framework
4. **Zsh plugins** - autosuggestions, syntax-highlighting
5. **Powerlevel10k** - Theme
6. **Utilities** - fzf, ncdu, python3
7. **Tmux + TPM** - Terminal multiplexer
8. **Neovim** - Text editor (v0.11.5 from tarball)
9. **Dotfiles** - Custom configuration files
10. **Shell change** - Set zsh as default shell
11. **Robotics** (Linux only) - Optional Docker setup prompt

## Configuration Files

| File | Description |
|------|-------------|
| `.zshrc` | Zsh configuration with oh-my-zsh and OS detection |
| `.zshenv` | Environment variables for zsh |
| `.tmux.conf` | Tmux configuration with Catppuccin theme |
| `.config/nvim/` | LazyVim/Neovim configuration |
| `robotics/` | Docker-based robotics environment |

## Tmux Configuration

- **Prefix**: `` ` `` (backtick instead of Ctrl+b)
- **Split horizontal**: `` ` `` + `h` or `` ` `` + `|`
- **Split vertical**: `` ` `` + `v` or `` ` `` + `-`
- **Switch windows**: `Alt+1` through `Alt+9`
- **Navigate panes**: `Alt+w/a/s/d`
- **Fullscreen pane**: `Alt+f` or `` ` `` + `f`
- **Reload config**: `` ` `` + `r`

### Tmux Plugins (via TPM)

- vim-tmux-navigator
- catppuccin/tmux (theme)
- tmux-sensible
- tmux-yank
- tmux-resurrect
- tmux-continuum
- tmux-thumbs
- tmux-fzf
- tmux-fzf-url

## Neovim (LazyVim)

The Neovim configuration uses [LazyVim](https://www.lazyvim.org/) as a base with custom configurations:

- Custom keymaps in `lua/config/keymaps.lua`
- Telescope configuration
- Jupyter notebook support

Plugins will be automatically installed on first launch of `nvim`.

## Robotics Environment (Linux Only)

Docker-based development environment for robotics with:

- **ROS 2 Humble** - Full desktop installation
- **Gazebo Classic** - Simulation (best ARM64 compatibility)
- **PX4 Dependencies** - Autopilot SITL tools
- **GUI Support** - X11 forwarding for RViz, Gazebo

### Setup

During `fresh-terminal.sh`, you'll be prompted to set up the robotics environment. You can also run it manually:

```bash
cd ~/dotfiles/robotics
./setup-host.sh
```

This installs Docker and builds the robotics container image.

### Usage

After setup, use these commands:

| Command | Description |
|---------|-------------|
| `ros-start` | Start the robotics container |
| `ros-shell` | Enter container shell |
| `ros-stop` | Stop the container |
| `ros-status` | Check container status |
| `ros-logs` | View container logs |
| `ros-gui` | Enable X11 access for GUI apps |
| `ros-build` | Rebuild the container image |

### Inside the Container

```bash
# Enter the container
ros-shell

# ROS 2 commands
ros2 topic list
ros2 run demo_nodes_cpp talker

# Launch Gazebo (run ros-gui first on host)
gazebo

# Launch RViz
rviz2

# Clone PX4 (if needed)
clone-px4
```

### Workspace

Your ROS workspace is mounted at:
- **Host**: `~/dotfiles/robotics/ros-workspace/`
- **Container**: `/home/developer/ros2_ws/`

Files persist between container restarts.

### ARM64 / Apple Silicon Notes

The container is optimized for ARM64 VMs (UTM on Apple Silicon):

- Software rendering via Mesa llvmpipe (`LIBGL_ALWAYS_SOFTWARE=1`)
- Gazebo Classic for better performance
- All ROS 2 ARM64 packages supported

## Post-Installation

After running the setup script:

1. **Restart terminal** or run `exec zsh`
2. **Configure Powerlevel10k** - Will prompt on first run
3. **Install tmux plugins**: Press `` ` `` + `I` (capital I) in tmux
4. **Launch Neovim**: Run `nvim` and wait for plugins to install

## Manual Requirements

Some features may require additional setup:

- **Nerd Font** - Install a [Nerd Font](https://www.nerdfonts.com/) for icons
- **Node.js** - Required for some Neovim LSP servers

## Customization

- Modify `.zshrc` for shell customization
- Edit files in `.config/nvim/lua/plugins/` for Neovim plugins
- Adjust `.tmux.conf` for tmux settings
- Edit `robotics/Dockerfile` for container customization

## Troubleshooting

### Ghostty Terminal Compatibility

The `.zshrc` includes a fix for Ghostty terminal on systems that don't have the terminfo installed:

```bash
if [[ "$TERM" == "xterm-ghostty" ]]; then
  if ! infocmp "$TERM" &>/dev/null; then
    export TERM="xterm-256color"
  fi
fi
```

### Neovim Installation on Unsupported Architectures

If the automatic Neovim installation fails, install manually:

```bash
sudo apt-get install neovim
```

### Docker GUI Not Working

If GUI apps don't display from the container:

```bash
# On the host, run:
ros-gui
# or
xhost +local:docker
```

### Container Permission Issues

If you see permission errors for mounted volumes:

```bash
# Rebuild with your UID/GID
cd ~/dotfiles/robotics
USER_ID=$(id -u) GROUP_ID=$(id -g) docker compose build
```

## License

MIT
