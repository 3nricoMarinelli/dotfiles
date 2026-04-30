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
if [[ "$(uname)" == "Darwin" ]]; then
    plugins+=(brew macos marked2)
elif [[ "$(uname)" == "Linux" ]]; then
    plugins+=(ubuntu systemd)
fi

if command -v tmux > /dev/null; then
    plugins+=tmux
    ZSH_TMUX_AUTOREFRESH=true
    ZSH_TMUX_AUTOSTART=true
fi

# Source Oh My Zsh
source "$ZSH/oh-my-zsh.sh"
