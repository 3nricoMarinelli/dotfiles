# =============================================================================
#
# ~/.zsh/functions.zsh
#
# Shell functions
#
# =============================================================================

# --------------------------------------------
# FZF Functions
# --------------------------------------------
fcd() {
    local dir
    dir=$(find ${1:-.} -type d -not -path '*/\.*' 2>/dev/null | fzf +m) && cd "$dir"
}

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
# Hook Functions
# --------------------------------------------
# On directory change, list contents and auto-activate Python virtual environment
chpwd() {
  ls -a
  if [[ -d .venv ]]; then
    source .venv/bin/activate
  fi
}
