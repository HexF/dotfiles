# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' matcher-list '' '' '' 'm:{[:lower:]}={[:upper:]}'
zstyle :compinstall filename "$ZDOTDIR/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=$ZDOTDIR/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt extendedglob notify
unsetopt beep
# End of lines configured by zsh-newuser-install


# Prompt 

#PROMPT='%F{154}%n%f %F{039}%B%m%b%f %F{226}%~%f%# '
PROMPT='%F{154}➜ %f %F{39}%~%f '
