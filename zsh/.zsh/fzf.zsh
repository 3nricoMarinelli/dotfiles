# =============================================================================
#
# ~/.zsh/utils/fzf.zsh
#
# FZF integration and fuzzy finding utilities
#
# =============================================================================

# Fuzzy cd: search for directories and cd into them
fcd() {
    local dir
    dir=$(find ${1:-.} -type d -not -path '*/\.*' 2>/dev/null | fzf +m) && cd "$dir"
}

# Source FZF shell completion and bindings
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
