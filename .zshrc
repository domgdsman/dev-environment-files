# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

echo "Starting interactive shell. Sourcing ~/.zshrc"

# if there is a virtual environment in the current working directory, activate it
if [[ -f ${PWD}/.venv/bin/activate ]]; then
  echo "Activating virtual environment found in project: ${PWD}/.venv/bin/activate"
  source ${PWD}/.venv/bin/activate

  if [[ -f ${PWD}/.env ]]; then
    echo "Loading environment variables from .env file"
    set -a
    source ${PWD}/.env
    set +a
  fi
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Set language
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

zstyle ':omz:update' mode reminder  # just remind me to update when it's time
zstyle ':omz:update' frequency 30  # how often to auto-update (in days)

plugins=(zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Accept suggestions with tab instead of right arrow
# ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[$ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[(i)forward-char]]=()
# bindkey '^I' autosuggest-accept

# history

setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
setopt hist_ignore_space  # Ignore commands that start with a space
setopt append_history     # append to the history file, don't overwrite it

HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
HIST_STAMPS="dd/mm/yyyy"


# PATH

export PATH="/usr/local/bin:$PATH"

# user private bin
if [ -d "$HOME/bin" ] ; then
    export PATH="$HOME/bin:$PATH"
fi

# user private local bin
if [ -d "$HOME/.local/bin" ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# wsl2
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  win_username=$(powershell.exe -Command '[System.Environment]::UserName' | tr -d '\r')
  export WIN_HOME="/mnt/c/Users/$win_username"
fi

# xdg (e.g.: k9s, avante.nvim)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_RUNTIME_DIR="/tmp/"

# Set ssl cert request bundle for python & pip
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# neovim
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  export PATH="$PATH:/opt/nvim-linux64/bin"
fi
export MYVIMRC="$HOME/.config/nvim/init.lua"

# cargo (rust)
export PATH="$PATH:$HOME/.cargo/bin"
[ -s "$HOME/.cargo/env" ] && \
. "$HOME/.cargo/env"

# poetry
export POETRY_VIRTUALENVS_CREATE="true"
export POETRY_VIRTUALENVS_IN_PROJECT="true"

poetry() {
  if [[ "$1" == "shell" && "$POETRY_VIRTUALENVS_IN_PROJECT" == "true" ]]; then
    if [[ -f ${PWD}/.venv/bin/activate ]]; then
      echo "Activating virtual environment found in project: ${PWD}/.venv/bin/activate"
      source ${PWD}/.venv/bin/activate
    else
      echo "Virtual environment not found in project. Using poetry to create it."
      command poetry "$@"
    fi

    if [[ -f ${PWD}/.env ]]; then
      echo "Loading environment variables from .env file"
      set -a
      source ${PWD}/.env
      set +a
    fi
  else
    command poetry "$@"
  fi
}

# git aliases
alias gsu='git stash push -u -- $(git ls-files --modified --others --exclude-standard)'  # git stash unstaged files
alias gcm='function _gcm(){ git add . && git commit -m "$1"; }; _gcm'  # git add + commit with message
alias gclean='git branch | grep -vE "^\*|^\s*(master|main|develop)$" | xargs git branch -D'  # delete all local branches except master, main, develop

# Node version manager (nvm)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Secrets
source ~/.secrets.env