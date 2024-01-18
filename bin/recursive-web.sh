#!/bin/bash

function main() {
    export | grep -q 'declare -x BIN_DIR=' || export BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> '/dev/null' && pwd)";
    source "${BIN_DIR}/../lib/configuration-utils.sh";
    libraries;

    trap 'clear' SIGINT EXIT RETURN;

    while :; do
        if ! getDialog -v 'inputbox' -t 'ok=Install' -t 'title=recursive website installer,t'; then
            clear;
            break;
        fi

        if [[ -n "${DIALOG_RESPONSE}" ]]; then
            if [[ ${DIALOG_RESPONSE} =~ ^((http(s)?|ftp)[:]//.+)$ ]]; then
                if getDialog -v 'yesno' -t 'title=confirm download,t' -t 'yes=confirm,t' -t 'no=cancel,t' "\nAre you sure you want to install '${DIALOG_RESPONSE}' recursively?"; then
                    clear;
                    mkdir -p "${HOME}/Downloads";
                    wget -r -p -k -np --no-check-certificate --convert-links -P "${HOME}/Downloads" "${DIALOG_RESPONSE}" &
                    break;
                fi
            else
                getDialog -v 'msg' -t 'ok=continue,t' -t 'title=invalid link,t' '\nPlease enter a valid url to download recursively.';
            fi
        else
            getDialog -v 'msg' -t 'ok=continue,t' -t 'title=empty link,t' '\nPlease enter a link to download recursively.';
        fi
    done
    return 0;
}

main;