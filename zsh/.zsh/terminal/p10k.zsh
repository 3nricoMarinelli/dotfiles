# =============================================================================
#
# ~/.zsh/terminal/p10k.zsh
#
# Powerlevel10k configuration based on terminal
#
# =============================================================================

# Powerlevel10k configuration based on terminal
if [[ "$TERM" == "xterm-ghostty" ]]; then
    [[ -f "$HOME/.p10k-ghostty.zsh" ]] && source "$HOME/.p10k-ghostty.zsh"
    if ! infocmp "$TERM" &>/dev/null; then
        export TERM="xterm-256color"
    fi
else
    [[ -f "$HOME/.p10k-vscode.zsh" ]] && source "$HOME/.p10k-vscode.zsh"
fi
