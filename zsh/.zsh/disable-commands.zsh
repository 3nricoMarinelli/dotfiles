# =============================================================================
#
# ~/.zsh/disable-commands.zsh
#
# Zsh guard avoiding command loops
#
# =============================================================================

_disabled() { echo "${funcstack[2]} disabled, avoid nesting commands!"; }

# Neovim floating terminal
if [[ -n "$NVIM" ]]; then
    unalias tmux 2>/dev/null
    eval 'tmux() { _disabled; }'

    unalias nvim 2>/dev/null
    eval 'nvim() { _disabled; }'
fi

# Tmux nesting
if [[ -n "$TMUX" ]]; then
    unalias tmux 2>/dev/null
    eval 'tmux() { _disabled; }'
fi
