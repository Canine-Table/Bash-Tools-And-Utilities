# /etc/bash.bashrc

function bashrc() {

    # Check if Shell is non-interactive.
    # Be done now!
    #[ ${-} == *i* ] || return 0;

    [[ -n ${DISPLAY} ]] && {
        shopt -s checkwinsize;
    }

    local FILE;
    
    [[ -d '/etc/bash.bashrc.d' && -r '/etc/bash.bashrc.d' ]] && for FILE in /etc/bash.bashrc.d/*.sh; do
        [[ -r "${FILE}" ]]  && source "${FILE}"; 
    done

    case ${TERM} in
        Eterm*|alacritty*|aterm*|foot*|gnome*|konsole*|kterm*|putty*|rxvt*|tmux*|xterm*) 
            PROMPT_COMMAND+=('printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"');;
        screen*)
            PROMPT_COMMAND+=('printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"');;
    esac

    [[ -r '/usr/share/bash-completion/bash_completion' ]] && source '/usr/share/bash-completion/bash_completion';
    
    command -v neofetch &> /dev/null && neofetch;

    return 0;
}

bashrc;

