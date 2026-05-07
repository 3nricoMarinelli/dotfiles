# =============================================================================
#
# ~/.zsh/os/macos.zsh
#
# macOS-specific configuration
#
# =============================================================================

# --------------------------------------------
# Homebrew Configuration
# --------------------------------------------
export HOMEBREW_NO_AUTO_UPDATE=0

# --------------------------------------------
# OpenSSL
# --------------------------------------------
if [[ -d /opt/homebrew/opt/openssl@3 ]]; then
    export OPENSSL_ROOT_DIR="/opt/homebrew/opt/openssl@3"
fi

# --------------------------------------------
# alias
# --------------------------------------------

# use Apple Intelligence as a basic local llm model chat
alias llm="apfel --chat"

# --------------------------------------------
# functions
# --------------------------------------------

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

# Daily upgrade script
daily_upgrade() {
    brew update && brew upgrade
    echo "\033[0;34m==>\033[0;1m Updating Neovim Plugins...\033[0m"
    v --headless +PlugUpgrade +PlugUpdate > /dev/null 2>&1 < /dev/null &
    nvimpid=$!
    sleep 10
    kill $nvimpid
}

brew() {
    command brew "$@"
    if [[ "$1" == "install" || "$1" == "uninstall" || "$1" == "tap" || "$1" == "untap" ]]; then
        brew bundle dump --force --file=~/dotfiles/brew/Brewfile
    fi
}
