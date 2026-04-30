# =============================================================================
#
# ~/.zsh/utils/python-venv.zsh
#
# Python virtual environment management functions
#
# =============================================================================

# List available virtual environments
lsvenv() {
    ls -1 "$VENV_HOME"
}

# Activate a virtual environment
venv() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: venv <name>"
    else
        source "$VENV_HOME/$1/bin/activate"
    fi
}

# Create a new virtual environment
mkvenv() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: mkvenv <name>"
    else
        python3 -m venv "$VENV_HOME/$1"
    fi
}

# Remove a virtual environment
rmvenv() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: rmvenv <name>"
    else
        rm -rf "$VENV_HOME/$1"
    fi
}

# On directory change: list contents and auto-activate Python virtual environment
chpwd() {
    ls -a
    if [[ -d .venv ]]; then
        source .venv/bin/activate
    fi
}
