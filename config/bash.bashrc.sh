#!/bin/bash

(
cat << 'EOF'
#
# /etc/bash.bashrc
#

function bashrc() {

    local FILE;

    umask 022;

    echo -e '\n';
    command -v neofetch &> /dev/null && {
        neofetch | (command -v lolcat &> /dev/null && lolcat || tee);
        echo -e '\n';
    }

    (command -v xrdb &> /dev/null && [ -n "${DISPLAY}" ]) && {
        for FILE in 'resources' 'defaults'; do
            FILE="${HOME}/.X${FILE}";
            [ -f "${FILE}" -a -r "${FILE}" ] && {
                xrdb -merge "${FILE}";
                break;
            }
        done
    }

    FILE="/etc/scripts/lib/configuration-utils.sh";
    [[ -f "${FILE}" && -r "${FILE}" ]] && {
        source "${FILE}";
        libraries;

        # Append our default paths
        append_path '.';
        append_path '..';
        append_path '/usr/local/sbin';
        append_path '/usr/local/bin';
        append_path '/usr/sbin';
        append_path '/usr/bin';
        append_path '/etc/scripts/sbin';
        append_path '/etc/scripts/bin';
        append_path "${HOME}/.local/sbin";
        append_path "${HOME}/.local/bin";

    } || export PATH=".:..:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/etc/scripts/bin";

    # If not running interactively, don't do anything
    [[ $- != *i* ]] && return;
    [[ $DISPLAY ]] && shopt -s checkwinsize;

    case ${TERM} in
        Eterm*|alacritty*|aterm*|foot*|gnome*|konsole*|kterm*|putty*|rxvt*|tmux*|xterm*) PROMPT_COMMAND+=('printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"');;
        screen*) PROMPT_COMMAND+=('printf "\033_%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"');;
    esac

    [[ -r '/usr/share/bash-completion/bash_completion' && -f  '/usr/share/bash-completion/bash_completion' ]] && source '/usr/share/bash-completion/bash_completion';

    shopt -oq posix || for FILE in '/usr/share/bash-completion/bash_completion' '/etc/bash_completion'; do
        [[ -r "${FILE}" && -f "${FILE}" ]] && {
            source "${FILE}";
            break;
        }
    done

    for FILE in '.bashrc' '.profile' '.bash_aliases' '.bash_profile'; do
        [[ -r "${HOME}/${FILE}" && -f "${HOME}/${FILE}" ]] && source "${HOME}/${FILE}";
    done

    for FILE in /etc/bash.bashrc.d/*.sh; do
        [[ -r "${FILE}" && -f "${FILE}" ]] && source "${FILE}";
    done

}

bashrc;

EOF
) > '/etc/bash.bashrc';

