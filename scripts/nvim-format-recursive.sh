#!/bin/bash
# Format all files recursively using Neovim + Conform
# Usage: nvim-format-recursive /path/to/dir

set -e

DIR="${1:-.}"
NVIM_CONFIG_DIR="${2:-$HOME/.config/nvim}"

if [ ! -d "$DIR" ]; then
    echo "Error: Directory '$DIR' not found"
    exit 1
fi

echo "📝 Formatting all files in: $DIR"
echo "Using config from: $NVIM_CONFIG_DIR"

nvim --headless \
    -u "$NVIM_CONFIG_DIR/init.lua" \
    -S "$NVIM_CONFIG_DIR/lua/utils/format-recursive.lua" \
    -- "$DIR"

printf "\n✨ Done!\n"
