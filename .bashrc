#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias config='/usr/bin/git --git-dir=/home/martin/dotfiles/ --work-tree=/home/martin'
PS1='[\u@\h \W]\$ '

if [ -s "$HOME/.nvm/nvm.sh" ]; then
  export NVM_DIR="$HOME/.nvm"
  nvm_cmds=(nvm node npm yarn)
  for cmd in $nvm_cmds ; do
    alias $cmd="unalias $nvm_cmds && unset nvm_cmds && . $NVM_DIR/nvm.sh && $cmd"
  done
fi

export PATH=$PATH:$HOME/.local/bin

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
source "$HOME/.cargo/env"
