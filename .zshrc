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
# SSH Detection - Set SSH_SESSION flag
# ============================================
# Detect if running over SSH (used to disable GUI/display features)
if [[ -n "$SSH_TTY" ]] || [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_CONNECTION" ]]; then
    SSH_SESSION="true"
else
    SSH_SESSION="false"
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
    brew upgrade

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

# Display configuration
if [[ "$OS_FLAG" == "linux" ]]; then
    # On Linux VM with desktop environment, always set DISPLAY=:0
    # This allows GUI apps (rviz2, gazebo) to work when SSH'd into the VM
    # The display will appear on the VM's virtual monitor (UTM window)
    export DISPLAY="${DISPLAY:-:0}"
    export LIBGL_ALWAYS_SOFTWARE=1

    # Allow local connections to X server (needed for SSH sessions to show GUI on VM display)
    if [[ "$SSH_SESSION" == "true" ]] && command -v xhost &>/dev/null; then
        xhost +local: &>/dev/null
    fi
fi

# FZF configuration
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# ============================================
# Terminal Compatibility and Appearence
# ============================================
# Powerlevel10k configuration
if [[ "$TERM" == "xterm-ghostty" ]]; then
[[ -f "$HOME/.p10k-ghostty.zsh" ]] && source "$HOME/.p10k-ghostty.zsh"
    if ! infocmp "$TERM" &>/dev/null; then
        export TERM="xterm-256color"
    fi
    else
[[ -f "$HOME/.p10k-vscode.zsh" ]] && source "$HOME/.p10k-vscode.zsh"
fi

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
    # Use UTM display window for GUI apps (rviz2, gazebo, etc.)
    ubuntu() {
        local vm_name="Ubuntu"
        while [[ "$(utmctl status "$vm_name" 2>/dev/null)" != "started" ]]; do
            local vm_uuid=$(utmctl list | grep "$vm_name" | awk '{print $1}')
            utmctl start "$vm_uuid"
            sleep 3
        done
        ssh ubuntu@192.168.64.27
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

