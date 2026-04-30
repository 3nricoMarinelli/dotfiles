# =============================================================================
#
# ~/.zsh/utils/enhancements.zsh
#
# Zsh editor enhancements, key bindings, and utility tools
#
# =============================================================================

# ============================================
# Edit Command Line
# ============================================
# Press Ctrl+X followed by Ctrl+E to trigger
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line
bindkey -M vicmd 'v' edit-command-line

# ============================================
# Magic Space
# ============================================
# Expands history expressions like !! or !$ when you press space
bindkey ' ' magic-space

# ============================================
# Zsh Moving
# ============================================
# Enable zmv for batch file operations
autoload -Uz zmv

# Helpful aliases for zmv:
# zmv '(*).log' '$1.txt'           # Rename .log to .txt
# zmv -w '*.log' '*.txt'           # Same thing, simpler syntax
# zmv -n '(*).log' '$1.txt'        # Dry run (preview changes)
# zmv -i '(*).log' '$1.txt'        # Interactive mode (confirm each)
alias zcp='zmv -C'  # Copy with patterns
alias zln='zmv -L'  # Link with patterns
