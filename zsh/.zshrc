# =============================================================================
#
# ~/.zshrc
#
# Cross-platform zsh configuration for macOS and Linux
#
# =============================================================================

# ============================================
# OS & SSH Detection
# ============================================

# Detect if running over SSH (used to disable GUI/display features)
if [[ -n "$SSH_TTY" ]] || [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_CONNECTION" ]]; then
    SSH_SESSION="true"
else
    SSH_SESSION="false"
fi

# Determine the directory where this .zshrc is located
ZSH_MODULES_DIR="${${(%):-%N}:A:h}/.zsh"

# ============================================
# Modular Source Files
# ============================================

for zsh_file in "$ZSH_MODULES_DIR"/*.zsh; do
    source "$zsh_file"
done

# OS-specific configuration
if [[ "$(uname)" == "Darwin" ]]; then
    source "$ZSH_MODULES_DIR/os-specific/macos.zsh"
elif [[ "$(uname)" == "Linux" ]]; then
    source "$ZSH_MODULES_DIR/os-specific/linux.zsh"
fi
