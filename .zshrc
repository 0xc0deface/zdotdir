#!/bin/zsh
#
# .zshrc - Zsh file loaded on interactive shell sessions.
#

export PATH=$PATH:$HOME/bin

export LS_COLORS="$(vivid generate iceberg-dark)"

# Enable Powerlevel10k instant prompt. Should stay close to the top of .zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSCRIPTDIR=${ZDOTDIR:-$HOME}/scripts
path=($ZSCRIPTDIR $path)

# Lazy-load (autoload) Zsh function files from a directory.
ZFUNCDIR=${ZDOTDIR:-$HOME}/.zfunctions
fpath=($ZFUNCDIR $fpath)
autoload -Uz $ZFUNCDIR/*(.:t)

# Set any zstyles you might use for configuration.
[[ ! -f ${ZDOTDIR:-$HOME}/.zstyles ]] || source ${ZDOTDIR:-$HOME}/.zstyles

# Clone antidote if necessary.
if [[ ! -d ${ZDOTDIR:-$HOME}/.antidote ]]; then
  git clone https://github.com/mattmc3/antidote ${ZDOTDIR:-$HOME}/.antidote
fi

# Create an amazing Zsh config using antidote plugins.
source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh
antidote load

# Source anything in .zshrc.d.
for _rc in ${ZDOTDIR:-$HOME}/.zshrc.d/*.zsh; do
  # Ignore tilde files.
  if [[ $_rc:t != '~'* ]]; then
    source "$_rc"
  fi
done
unset _rc

source <(fzf --zsh)

# To customize prompt, run `p10k configure` or edit ~/zdotdir/.p10k.zsh.
[[ ! -f ~/zdotdir/.p10k.zsh ]] || source ~/zdotdir/.p10k.zsh

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
eval "$(pyenv virtualenv-init -)"

#aliases
alias ls="eza --color=auto --icons=auto --group-directories-first"

# https://github.com/sineemore/backpack/tree/master
# backpack is a wrapper for ssh that allows you to run commands on remote servers
alias ssh=backpack

# make sure completion still works for ssh (and other aliases)
setopt completealiases

alias ssh-askpass="ksshaskpass"
alias which=/usr/bin/which
alias cheat="cheat --colorize"

# For debug symbols
export DEBUGINFOD_URLS=https://debuginfod.elfutils.org/

export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
