# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

# Detect OS and set plugin
if [ "$(uname)" = "Darwin" ]; then
  OS_NAME = "macos"
elif [ "$(uname)" = "Linux" ]; then
  OS_NAME = "ubuntu" # use only Ubuntu Linux distro with zsh
else
  OS_NAME = ""
fi

plugins=(
  battery 
  brew 
  branch 
  common-aliases
  command-not-found
  colorize
  copypath
  docker
  fzf
  gh
  git
  git-auto-fetch
  git-commit
  gitfast
  github
  gitignore
  git-lfs
  git-prompt
  man
  marked2
  nmap
  pip
  pre-commit
  python
  pylint
  ssh
  sudo
  systemd
  thefuck
  timer
  universalarchive
  virtualenv
  wd
  zsh-autosuggestions 
  zsh-interactive-cd
  zsh-navigation-tools
  zsh-syntax-highlighting
  $OS_NAME
)

source $ZSH/oh-my-zsh.sh

fcd() {
  local dir
  dir=$(find ${1:-.} -type d -not -path '*/\.*' 2> /dev/null | fzf +m) && cd "$dir"	
}
# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# ============================================
# Dual Homebrew Setup for Apple Silicon
# ============================================

if [$OS_NAME == "macos"]; then
  # Default to ARM Homebrew (native performance)
  eval "$(/opt/homebrew/bin/brew shellenv)"

# Function to switch to x86 Homebrew (for PX4, Rosetta apps)
brew-x86() {
  eval "$(/usr/local/bin/brew shellenv)"
  echo "✅ Switched to x86 Homebrew (Rosetta)"
  echo "📍 $(which brew)"
  arch
}

# Function to switch to ARM Homebrew (native)
brew-arm() {
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo "✅ Switched to ARM Homebrew (native)"
  echo "📍 $(which brew)"
  arch
}

# Alias to check current brew
alias brew-which='echo "Current: $(which brew)" && arch'

# Auto-detect and set brew based on terminal architecture
if [[ $(arch) == "i386" ]]; then
  # Running in Rosetta terminal - use x86 brew automatically
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Fix completion paths for active brew
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit -i
fi

. "$HOME/.local/bin/env"
export PATH="$HOME/.local/bin:$PATH"
export DISPLAY=:0
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export OPENSSL_ROOT_DIR=/opt/homebrew/opt/openssl@3
alias storage='ncdu'
alias v='nvim'

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'micromamba shell init' !!
export MAMBA_EXE="$HOME/.local/bin/micromamba";
export MAMBA_ROOT_PREFIX="$HOME/micromamba";
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
  eval "$__mamba_setup"
else
  alias micromamba="$MAMBA_EXE"  # Fallback on help from micromamba activate
fi
unset __mamba_setup
eval "$(micromamba shell hook -s zsh)"
# <<< mamba initialize <<<
fi

# Virtual environment functions
export VENV_HOME="$HOME/.virtualenvs"
[[ -d $VENV_HOME ]] || mkdir $VENV_HOME

lsvenv() {
  ls -1 $VENV_HOME
}

venv() {
  if [ $# -eq 0 ]
  then
    echo "Please provide venv name"
  else
    source "$VENV_HOME/$1/bin/activate"
  fi
}

mkvenv() {
  if [ $# -eq 0 ]
  then
    echo "Please provide venv name"
  else
    python3 -m venv $VENV_HOME/$1
  fi
}

rmvenv() {
  if [ $# -eq 0 ]
  then
    echo "Please provide venv name"
  else
    rm -r $VENV_HOME/$1
  fi
}
export PATH="$HOME/Library/Python/3.14/bin/:$PATH"


alias tn='tmux new-session -s'
alias tl='tmux list-session'
alias ta='tmux attach-session'
