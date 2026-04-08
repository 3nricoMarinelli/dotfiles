# =============================================================================
#
# ~/.zsh/aliases.zsh
#
# All shell aliases
#
# =============================================================================

# --------------------------------------------
# General Aliases
# --------------------------------------------
alias storage='ncdu'
alias v='nvim'
alias gs='git status'
alias gds='git diff --stat'
alias o='opencode'

# TMUX
alias tn='tmux new-session -s'
alias tl='tmux list-session'
alias ta='tmux attach-session'

# --------------------------------------------
# Suffix Aliases (Open files by extension)
# --------------------------------------------
alias -s json=jless
alias -s html=open
alias -s log=bat
alias -s md=bat
alias -s txt='$EDITOR'
alias -s c='$EDITOR'
alias -s h='$EDITOR'
alias -s cpp='$EDITOR'
alias -s hpp='$EDITOR'
alias -s cu='$EDITOR'
alias -s cuh='$EDITOR'
alias -s rs='$EDITOR'
alias -s py='$EDITOR'
alias -s go='$EDITOR'
alias -s dart='$EDITOR'

# --------------------------------------------
# Global Aliases (Use anywhere in commands)
# --------------------------------------------
alias -g NE='2>/dev/null'      # Redirect stderr to /dev/null
alias -g NO='>/dev/null'       # Redirect stdout to /dev/null
alias -g NUL='>/dev/null 2>&1' # Redirect both to /dev/null
alias -g J='| jq'              # Pipe to jq
alias -g L='| less -R'         # Pipe to less with color support
alias -g G='| grep --color=always'  # Pipe to grep with color preserved
