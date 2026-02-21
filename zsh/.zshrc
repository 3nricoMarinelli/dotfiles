# =============================================================================
#
# ~/.zshrc
#
# Cross-platform zsh configuration for macOS and Linux
#
# =============================================================================

# ============================================
# OS & SSH Detection
# ============================================

# Detect operating system
if [[ "$(uname)" == "Darwin" ]]; then
    OS_FLAG="macos"
elif [[ "$(uname)" == "Linux" ]]; then
    OS_FLAG="linux"
else
    OS_FLAG="unknown"
fi

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
# Oh My Zsh
# ============================================

export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
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
# Environment Variables & PATH
# ============================================

# Editor
export EDITOR=nvim

# Less configuration for color support and better defaults
export LESS='-R -F -X -i -M -W'
# -R: Allow raw control characters (for colors)
# -F: Quit if entire file fits on one screen
# -X: Don't clear screen on exit
# -i: Ignore case in searches
# -M: Long prompt with line numbers
# -W: Highlight first unread line after scrolling

# Man pages with color highlighting
export LESS_TERMCAP_mb=$'\e[1;32m'     # Begin blinking (green)
export LESS_TERMCAP_md=$'\e[1;34m'     # Begin bold (blue)
export LESS_TERMCAP_me=$'\e[0m'        # End all mode
export LESS_TERMCAP_se=$'\e[0m'        # End standout mode
export LESS_TERMCAP_so=$'\e[1;43;30m'  # Begin standout mode (yellow background)
export LESS_TERMCAP_ue=$'\e[0m'        # End underline
export LESS_TERMCAP_us=$'\e[1;4;31m'   # Begin underline (red)

# Pager for man pages
export MANPAGER='less -R'

# PATH
export PATH="$HOME/.local/bin:$PATH"

# Python Virtual Environments
export VENV_HOME="$HOME/.virtualenvs"
[[ -d "$VENV_HOME" ]] || mkdir -p "$VENV_HOME"

# Micromamba/Conda
export MAMBA_EXE="$HOME/.local/bin/micromamba"
export MAMBA_ROOT_PREFIX="$HOME/micromamba"

# Load local environment if exists
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# ============================================
# OS-Specific Configuration
# ============================================

# --------------------------------------------
# macOS
# --------------------------------------------
if [[ "$OS_FLAG" == "macos" ]]; then
    # Homebrew
    export HOMEBREW_NO_AUTO_UPDATE=0
    # default ARM
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # OpenSSL
    if [[ -d /opt/homebrew/opt/openssl@3 ]]; then
        export OPENSSL_ROOT_DIR="/opt/homebrew/opt/openssl@3"
    fi
fi

# --------------------------------------------
# Linux
# --------------------------------------------
if [[ "$OS_FLAG" == "linux" ]]; then
    # Display configuration for GUI apps in SSH
    alias bat="batcat"
fi

# ============================================
# Terminal & Appearance
# ============================================

# Powerlevel10k configuration based on terminal
if [[ "$TERM" == "xterm-ghostty" ]]; then
    [[ -f "$HOME/.p10k-ghostty.zsh" ]] && source "$HOME/.p10k-ghostty.zsh"
    if ! infocmp "$TERM" &>/dev/null; then
        export TERM="xterm-256color"
    fi
else
    [[ -f "$HOME/.p10k-vscode.zsh" ]] && source "$HOME/.p10k-vscode.zsh"
fi

# ============================================
# Aliases
# ============================================

# --------------------------------------------
# General Aliases
# --------------------------------------------
alias storage='ncdu'
alias v='nvim'

# TMUX
alias tn='tmux new-session -s'
alias tl='tmux list-session'
alias ta='tmux attach-session'

# --------------------------------------------
# Suffix Aliases (Open files by extension)
# --------------------------------------------
alias -s json=jless
alias -s html=open
alias -s log=bat
alias -s md=bat
alias -s txt='$EDITOR'
alias -s c='$EDITOR'
alias -s h='$EDITOR'
alias -s cpp='$EDITOR'
alias -s hpp='$EDITOR'
alias -s cu='$EDITOR'
alias -s cuh='$EDITOR'
alias -s rs='$EDITOR'
alias -s py='$EDITOR'
alias -s go='$EDITOR'
alias -s dart='$EDITOR'

# --------------------------------------------
# Global Aliases (Use anywhere in commands)
# --------------------------------------------
alias -g NE='2>/dev/null'      # Redirect stderr to /dev/null
alias -g NO='>/dev/null'       # Redirect stdout to /dev/null
alias -g NUL='>/dev/null 2>&1' # Redirect both to /dev/null
alias -g J='| jq'              # Pipe to jq
alias -g L='| less -R'         # Pipe to less with color support
alias -g G='| grep --color=always'  # Pipe to grep with color preserved

# macOS-specific global alias
if [[ "$OS_FLAG" == "macos" ]]; then
    export ICLOUD="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
    alias -g C='| pbcopy' # Copy output to clipboard
fi

# ============================================
# Zsh Enhancements & Tools
# ============================================

# --------------------------------------------
# FZF
# --------------------------------------------
fcd() {
    local dir
    dir=$(find ${1:-.} -type d -not -path '*/\.*' 2>/dev/null | fzf +m) && cd "$dir"
}

[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# --------------------------------------------
# Python Virtual Environment Functions
# --------------------------------------------
lsvenv() {
    ls -1 "$VENV_HOME"
}

venv() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: venv <name>"
    else
        source "$VENV_HOME/$1/bin/activate"
    fi
}

mkvenv() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: mkvenv <name>"
    else
        python3 -m venv "$VENV_HOME/$1"
    fi
}

rmvenv() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: rmvenv <name>"
    else
        rm -rf "$VENV_HOME/$1"
    fi
}

# --------------------------------------------
# macOS-Specific Functions
# --------------------------------------------
if [[ "$OS_FLAG" == "macos" ]]; then
    # Switch to x86 Homebrew (Rosetta)
    brew-x86() {
        if [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
            echo "Switched to x86 Homebrew (Rosetta) at $(which brew)"
        else
            echo "x86 Homebrew not installed."
        fi
    }

    # Switch to ARM Homebrew (native)
    brew-arm() {
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            echo "Switched to ARM Homebrew (native) at $(which brew)"
        else
            echo "ARM Homebrew not installed."
        fi
    }

    # SSH into local Ubuntu server
    ubuntu() {
        ssh "$USER-ubuntu@$UBUNTU_IP"
        }

    # Android SDK alias
    if [[ -f "$HOME/Library/Android/sdk/platform-tools/adb" ]]; then
        alias adb="$HOME/Library/Android/sdk/platform-tools/adb"
    fi
fi

# ============================================
# Hooks
# ============================================

# On directory change, list contents and auto-activate Python virtual environment
chpwd() {
  ls -a
  if [[ -d .venv ]]; then
    source .venv/bin/activate
  fi
}

# ============================================
# Zsh Enhancements & Tools
# ============================================

# --------------------------------------------
# FZF
# --------------------------------------------
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# --------------------------------------------
# Zsh Hacks
# --------------------------------------------
# Press Ctrl+X followed by Ctrl+E to trigger
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
bindkey -M vicmd 'v' edit-command-line

# Press Ctrl+_ (Ctrl+Underscore) to undo in zsh

# Expands history expressions like !! or !$ when you press space
bindkey ' ' magic-space

# Enable zmv
autoload -Uz zmv

# Usage examples:
# zmv '(*).log' '$1.txt'           # Rename .log to .txt
# zmv -w '*.log' '*.txt'           # Same thing, simpler syntax
# zmv -n '(*).log' '$1.txt'        # Dry run (preview changes)
# zmv -i '(*).log' '$1.txt'        # Interactive mode (confirm each)

# Helpful aliases for zmv
alias zcp='zmv -C'  # Copy with patterns
alias zln='zmv -L'  # Link with patterns

# --------------------------------------------
# Micromamba/Conda
# --------------------------------------------
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

# --------------------------------------------
# Completions
# --------------------------------------------
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
    autoload -Uz compinit
    compinit -i
fi

if [[ "$OS_FLAG" == "macos" ]]; then
    [[ -s "/usr/local/share/zsh/site-functions/_bun" ]] && source "/usr/local/share/zsh/site-functions/_bun"
fi
