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
eval "$(/opt/homebrew/bin/brew shellenv)"

# --------------------------------------------
# OpenSSL
# --------------------------------------------
if [[ -d /opt/homebrew/opt/openssl@3 ]]; then
    export OPENSSL_ROOT_DIR="/opt/homebrew/opt/openssl@3"
fi

# --------------------------------------------
# macOS-specific functions
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

# SSH into local Ubuntu server
ubuntu() { ssh -Y "$USER@$UBUNTU_IP" -p "$UBUNTU_PORT" -i "$UBUNTU_PK"}

# Daily upgrade script
daily_upgrade() {
    brew update && brew upgrade
    echo "\033[0;34m==>\033[0;1m Updating Neovim Plugins...\033[0m"
    v --headless +PlugUpgrade +PlugUpdate > /dev/null 2>&1 < /dev/null &
    nvimpid=$!
    sleep 10
    kill $nvimpid
}

# Android SDK alias
if [[ -f "$HOME/Library/Android/sdk/platform-tools/adb" ]]; then
    alias adb="$HOME/Library/Android/sdk/platform-tools/adb"
fi

# Bun completion
[[ -s "/usr/local/share/zsh/site-functions/_bun" ]] && source "/usr/local/share/zsh/site-functions/_bun"
