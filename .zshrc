#!/bin/zsh
#
# .zshrc - Zsh file loaded on interactive shell sessions.
#

export PATH=$PATH:$HOME/bin

if [[ -d "$HOME/.config/emacs/bin" ]]; then
  export PATH=$PATH:$HOME/.config/emacs/bin
fi

export LS_COLORS="$(vivid generate iceberg-dark)"

unsetopt correct_all

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

autoload -Uz compinit
compinit

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

alias emacs='emacs -nw'

alias findfile='find . -type f -name'
alias findfolder='find . -type d -name'


#--executability, -E      preserve executability
#--verbose, -v            increase verbosity
#--recursive, -r          recurse into directories
#--links, -l              copy symlinks as symlinks
#--times, -t              preserve modification times
#--compress, -z           compress file data during the transfer
#--partial                keep partially transferred files
#--delete-after           receiver deletes after transfer, not during
#--bwlimit=RATE           limit socket I/O bandwidth

#--delete-after is useful but risky on the first run. better to run and then add it after
alias fsync='rsync -rltvzE --progress --partial'
alias fsynclimit='fsync --bwlimit=1400'

# For debug symbols
export DEBUGINFOD_URLS=https://debuginfod.elfutils.org/

export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket

source ${ZDOTDIR:-$HOME}/files/export_backpack

#disable flow control
#stty ixany > /dev/null 2>&1
#stty ixoff -ixon > /dev/null  2>&1
#

#not sure this does anything
#bindkey '^[[28;5~' copy

