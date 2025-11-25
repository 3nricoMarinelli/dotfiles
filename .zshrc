# .zshrc
# Cross-platform zsh configuration for macOS and Linux

# ============================================
# OS Detection - Set OS_FLAG early
# ============================================
if [[ "$(uname)" == "Darwin" ]]; then
    OS_FLAG="macos"
elif [[ "$(uname)" == "Linux" ]]; then
    OS_FLAG="linux"
else
    OS_FLAG="unknown"
fi

# ============================================
# Powerlevel10k Instant Prompt
# ============================================
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================
# Oh My Zsh Configuration
# ============================================
export ZSH="$HOME/.oh-my-zsh"

# Theme: Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# ============================================
# Plugins Configuration
# ============================================
# Base plugins (cross-platform)
plugins=(
    battery
    branch
    common-aliases
    command-not-found
    colorize
    copypath
    docker
    fzf
    gh
    git
    git-auto-fetch
    git-commit
    gitfast
    github
    gitignore
    git-lfs
    git-prompt
    man
    nmap
    pip
    pre-commit
    python
    pylint
    ssh
    sudo
    timer
    universalarchive
    virtualenv
    wd
    zsh-autosuggestions
    zsh-interactive-cd
    zsh-navigation-tools
    zsh-syntax-highlighting
)

# OS-specific plugins
if [[ "$OS_FLAG" == "macos" ]]; then
    plugins+=(brew macos marked2)
elif [[ "$OS_FLAG" == "linux" ]]; then
    plugins+=(ubuntu systemd)
fi

source "$ZSH/oh-my-zsh.sh"

# ============================================
# PATH Configuration
# ============================================
export PATH="$HOME/.local/bin:$PATH"

# macOS-specific PATH additions
if [[ "$OS_FLAG" == "macos" ]]; then
    export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"
    export PATH="$HOME/Library/Python/3.14/bin:$PATH"
fi

# ============================================
# Homebrew Setup (macOS only)
# ============================================
if [[ "$OS_FLAG" == "macos" ]]; then
    # Default to ARM Homebrew (native performance)
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # Auto-detect and set brew based on terminal architecture (Rosetta)
    if [[ "$(arch)" == "i386" ]] && [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    # Function to switch to x86 Homebrew (for PX4, Rosetta apps)
    brew-x86() {
        if [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
            echo "Switched to x86 Homebrew (Rosetta)"
            echo "Location: $(which brew)"
            arch
        else
            echo "x86 Homebrew not installed"
        fi
    }

    # Function to switch to ARM Homebrew (native)
    brew-arm() {
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            echo "Switched to ARM Homebrew (native)"
            echo "Location: $(which brew)"
            arch
        else
            echo "ARM Homebrew not installed"
        fi
    }

    # Alias to check current brew
    alias brew-which='echo "Current: $(which brew)" && arch'

    # Fix completion paths for active brew
    if type brew &>/dev/null; then
        FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
        autoload -Uz compinit
        compinit -i
    fi

    # OpenSSL path for macOS
    if [[ -d /opt/homebrew/opt/openssl@3 ]]; then
        export OPENSSL_ROOT_DIR="/opt/homebrew/opt/openssl@3"
    fi
fi

# ============================================
# Environment Setup
# ============================================
# Load local environment if exists
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# Display for X11 forwarding (Linux)
if [[ "$OS_FLAG" == "linux" ]]; then
    export DISPLAY=:0
fi

# FZF configuration
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# Powerlevel10k configuration
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# ============================================
# Micromamba/Conda Setup
# ============================================
export MAMBA_EXE="$HOME/.local/bin/micromamba"
export MAMBA_ROOT_PREFIX="$HOME/micromamba"

if [[ -f "$MAMBA_EXE" ]]; then
    __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
    if [[ $? -eq 0 ]]; then
        eval "$__mamba_setup"
    else
        alias micromamba="$MAMBA_EXE"
    fi
    unset __mamba_setup
    eval "$(micromamba shell hook -s zsh)"
fi

# ============================================
# Virtual Environment Functions
# ============================================
export VENV_HOME="$HOME/.virtualenvs"
[[ -d "$VENV_HOME" ]] || mkdir -p "$VENV_HOME"

lsvenv() {
    ls -1 "$VENV_HOME"
}

venv() {
    if [[ $# -eq 0 ]]; then
        echo "Please provide venv name"
    else
        source "$VENV_HOME/$1/bin/activate"
    fi
}

mkvenv() {
    if [[ $# -eq 0 ]]; then
        echo "Please provide venv name"
    else
        python3 -m venv "$VENV_HOME/$1"
    fi
}

rmvenv() {
    if [[ $# -eq 0 ]]; then
        echo "Please provide venv name"
    else
        rm -r "$VENV_HOME/$1"
    fi
}

# ============================================
# Utility Functions
# ============================================
# FZF directory navigation
fcd() {
    local dir
    dir=$(find ${1:-.} -type d -not -path '*/\.*' 2>/dev/null | fzf +m) && cd "$dir"
}

# ============================================
# macOS-specific Functions
# ============================================
if [[ "$OS_FLAG" == "macos" ]]; then
    # VM running Ubuntu for ROS and PX4
    ubuntu() {
        local vm_name="Ubuntu-ROS-PX4"
        open -a UTM -j
        while [[ "$(utmctl status "$vm_name" 2>/dev/null)" != "started" ]]; do
            local vm_uuid=$(utmctl list | grep "$vm_name" | awk '{print $1}')
            utmctl start "$vm_uuid"
            sleep 2
        done
        ssh ubuntu@192.168.64.20
    }

    # Bun completions (macOS)
    [[ -s "/usr/local/share/zsh/site-functions/_bun" ]] && source "/usr/local/share/zsh/site-functions/_bun"

    # Android SDK alias
    if [[ -f "$HOME/Library/Android/sdk/platform-tools/adb" ]]; then
        alias adb="$HOME/Library/Android/sdk/platform-tools/adb"
    fi
fi

# ============================================
# Common Aliases
# ============================================
alias storage='ncdu'
alias v='nvim'

# TMUX aliases
alias tn='tmux new-session -s'
alias tl='tmux list-session'
alias ta='tmux attach-session'

# ============================================
# Robotics Docker Environment (Linux only)
# ============================================
if [[ "$OS_FLAG" == "linux" ]] && command -v docker &>/dev/null; then
    # Find robotics directory
    if [[ -d "$HOME/dotfiles/robotics" ]]; then
        ROBOTICS_DIR="$HOME/dotfiles/robotics"
    elif [[ -d "$HOME/.dotfiles/robotics" ]]; then
        ROBOTICS_DIR="$HOME/.dotfiles/robotics"
    fi

    if [[ -n "$ROBOTICS_DIR" ]]; then
        # Container management aliases
        alias ros-start="cd $ROBOTICS_DIR && docker compose up -d && cd -"
        alias ros-stop="cd $ROBOTICS_DIR && docker compose down && cd -"
        alias ros-shell="docker exec -it ros-dev bash"
        alias ros-logs="docker logs -f ros-dev"
        alias ros-build="cd $ROBOTICS_DIR && docker compose build && cd -"

        # X11 access for GUI applications
        alias ros-gui="xhost +local:docker 2>/dev/null && echo 'X11 access enabled for Docker'"

        # Quick status check
        ros-status() {
            if docker ps --format '{{.Names}}' | grep -q '^ros-dev$'; then
                echo "ros-dev container is running"
                docker ps --filter name=ros-dev --format 'table {{.Status}}\t{{.Ports}}'
            else
                echo "ros-dev container is not running"
                echo "Start with: ros-start"
            fi
        }
    fi
fi

# ============================================
# Terminal Compatibility
# ============================================
# Fix TERM for compatibility on systems without Ghostty
if [[ "$TERM" == "xterm-ghostty" ]]; then
    if ! infocmp "$TERM" &>/dev/null; then
        export TERM="xterm-256color"
    fi
fi
