# =============================================================================
#
# ~/.zsh/terminal/p10k.zsh
#
# Powerlevel10k configuration based on terminal
#
# =============================================================================

# Powerlevel10k configuration based on terminal
[[ -f "$HOME/.p10k-ghostty.zsh" ]] && source "$HOME/.p10k-ghostty.zsh"
if ! infocmp "$TERM" &>/dev/null; then
export TERM="xterm-256color"
fi
