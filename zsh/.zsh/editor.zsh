# EDITOR = NVIM if NVIM > 0.12 else VIM

if ! command -v nvim >/dev/null 2>&1; then
    export EDITOR="vim"
else
    VERSION=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
    MAJOR=$(echo "$VERSION" | cut -d. -f1)
    MINOR=$(echo "$VERSION" | cut -d. -f2)

    if [[ -z "$VERSION" ]] || { (( MAJOR == 0 )) && (( MINOR < 12 )); } || (( MAJOR < 0 )); then
        export EDITOR="vim"
    else
        export EDITOR="nvim"
    fi
fi
