#.config

# XDG Dirs

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# Path
export PATH="$PATH:$HOME/.local/bin"

# ZSH
export ZDOTDIR=$XDG_CONFIG_HOME/zsh

# WGET
export WGETRC="$XDG_CONFIG_HOME/wget/.wgetrc"

# STEP-CLI
export STEPPATH="$XDG_DATA_HOME/step/"

# ncurses
export TERMINFO="$XDG_DATA_HOME"/terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo

# GnuPG
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
alias gpg2="gpg2 --homedir $GNUPGHOME"

# NPM
export NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc

# NVM
export NVM_DIR="$XDG_DATA_HOME"/nvm

## More Scripts

# Globals

export BROWSER="firefox"
export EDITOR="nano"

# My Scripts

# stepssh.sh (.local/bin)

export STEPSSH_LOGINEMAIL="thomas@hexf.me"
export STEPSSH_LOGINPROVISIONER="keycloak"


# SSH Agent

eval $(systemctl --user show-environment | grep SSH_AUTH_SOCK)
export SSH_AUTH_SOCK
