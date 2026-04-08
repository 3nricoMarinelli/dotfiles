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

# Source Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# ============================================
# Modular Source Files
# ============================================

# Determine the directory where this .zshrc is located
ZSH_MODULES_DIR="${${(%):-%N}:A:h}/.zsh"

# Environment variables & PATH
source "$ZSH_MODULES_DIR/environment.zsh"

# Shell aliases
source "$ZSH_MODULES_DIR/aliases.zsh"

# Shell functions
source "$ZSH_MODULES_DIR/functions.zsh"

# Extras (FZF, zsh hacks, zmv)
source "$ZSH_MODULES_DIR/extras.zsh"

# Terminal-specific configuration (Powerlevel10k)
source "$ZSH_MODULES_DIR/terminal/p10k.zsh"

# OS-specific configuration
if [[ "$OS_FLAG" == "macos" ]]; then
    source "$ZSH_MODULES_DIR/os/macos.zsh"
elif [[ "$OS_FLAG" == "linux" ]]; then
    source "$ZSH_MODULES_DIR/os/linux.zsh"
fi

# Autocompletions
source "$ZSH_MODULES_DIR/completions.zsh"

# Load OpenCode modular script (if exists)
[[ -f "$HOME/.zsh/opencode-llama.zsh" ]] && source "$HOME/.zsh/opencode-llama.zsh"
