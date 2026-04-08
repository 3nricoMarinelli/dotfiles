# =============================================================================
#
# ~/.zsh/environment.zsh
#
# Environment variables and PATH configuration
#
# =============================================================================

# --------------------------------------------
# Editor
# --------------------------------------------
export EDITOR=nvim

# --------------------------------------------
# Less configuration for color support
# --------------------------------------------
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

# --------------------------------------------
# PATH
# --------------------------------------------
export PATH="$HOME/.local/bin:$PATH"

# --------------------------------------------
# Python Virtual Environments
# --------------------------------------------
export VENV_HOME="$HOME/.virtualenvs"
[[ -d "$VENV_HOME" ]] || mkdir -p "$VENV_HOME"

# --------------------------------------------
# Micromamba/Conda
# --------------------------------------------
export MAMBA_EXE="$HOME/.local/bin/micromamba"
export MAMBA_ROOT_PREFIX="$HOME/micromamba"

# Load micromamba if available
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
# Load local environment if exists
# --------------------------------------------
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"
