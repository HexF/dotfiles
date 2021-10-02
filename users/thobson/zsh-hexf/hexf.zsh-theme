prompt_hexf_precmd_short(){
    PROMPT=" "

    add_block(){
        # $1 format, $2 bg, $3 fg

        PROMPT="${PROMPT:0:-1}%K{$2}${PROMPT: -1}%f%F{$3}%K{$2}$1%k%F{$2}"
    }

    zstyle ':vcs_info:*' enable git

    zstyle ':vcs_info:git:*' formats " %b" 
    zstyle ':vcs_info:git:*' actionformats " %b %a" 
    vcs_info

    # exit code > git > user@host >   .... < pwd
    add_block "%B%?%b" "%(0?.0.1)" "7"
    [[ -n ${vcs_info_msg_0_} ]] && add_block "${vcs_info_msg_0_}" "4" "7"
    add_block "%n@%m" "%(!.1.6)" "7"

    RPROMPT="%F{11}%f%K{11}%F{8}%~%k%f"
    PROMPT="${PROMPT}%f "
}

prompt_hexf_setup(){
    autoload -Uz add-zsh-hook
    autoload -Uz vcs_info

    add-zsh-hook precmd prompt_hexf_precmd_short

}

prompt_hexf_setup "$@"