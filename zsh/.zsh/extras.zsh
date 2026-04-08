# =============================================================================
#
# ~/.zsh/extras.zsh
#
# Additional zsh enhancements and tools
#
# =============================================================================

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
