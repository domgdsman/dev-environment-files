# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

echo "Starting interactive shell. Sourcing ~/.zshrc"

# if there is a virtual python environment in the current working directory, activate it
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

# Shell skins and plugins

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

# homebrew bin
export PATH="/usr/local/bin:$PATH"

# user private bin
if [ -d "$HOME/bin" ] ; then
    export PATH="$HOME/bin:$PATH"
fi

# user private local bin
if [ -d "$HOME/.local/bin" ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# visual studio code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# neovim (nvim)
export MYVIMRC="$HOME/.config/nvim/init.lua"
export XDG_RUNTIME_DIR="/tmp/" # avante.nvim

# depot tools (c++)
export PATH="$PATH:$HOME/bin/depot_tools"

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
alias gcmp='function _gcmp(){ git add . && git commit -m "$1" && git push; }; _gcmp'  # git add + commit with message + push
alias gclean='git branch | grep -vE "^\*|^\s*(master|main)$" | xargs git branch -D'  # delete all local branches except master, main, develop

# Load applications

# cargo (rust)
. "$HOME/.cargo/env"

# Node version manager (nvm)
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm


# Secrets
source ~/.secrets.env
