#!/bin/bash


function main() {
    export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> '/dev/null' && pwd)";
    source "${BIN_DIR}/../lib/configuration-utils.sh";
    libraries;

    local C;

    [[ -z "${SUPER_USER}" ]] && {
        [[ "$(id -u)" -eq 0 ]] || {
            for C in {"doas","sudo"}; do
                command -v "${C}" &> '/dev/null' && {
                    declare -x SUPER_USER="${C}";
                }
            done
        }
    }

    local DIRECTORY="/var/run/pid";
    local  FILE="${DIRECTORY}/agent.pid";
    printf "${SSH_AGENT_PID}" > "${FILE}";

    [[ -d '/var/run/pid' ]] || {
        ${SUPER_USER} mkdir -m 777 -p "${DIRECTORY}" && ${SUPER_USER} chown "${_}";
    }

    [[ -f "${FILE}" ]] || {
        ${SUPER_USER} touch "${FILE}" && ${SUPER_USER} chmod 666 "${_}" && ${SUPER_USER} chown root:root "${_}";
    }

    local AGENT_PID="$(cat "${FILE}")";
    
    [[ -n "${AGENT_PID}" ]] && ps -A | awk '{if ($1 ~ /^[[:digit:]]+$/) {print $1}}' | grep -q "${AGENT_PID}" || {

        for C in $(ps -A | awk '{if ($NF == "ssh-agent") {print $1}}'); do
            ${SUPER_USER} kill "${C}";
        done

        ssh-agent "${SHELL}";
    }

    [[ -n "${1}" ]] && {
        
        local -a ARRAY;
        mapfile -t ARRAY < <(awk -v host="${1}" -f "${LIB_DIR}/awk-lib/ssh-agent.awk" "${HOME}/.ssh/config");
        if [[ "${#ARRAY[@]}" -eq 2 ]]; then
            grep -q "$(awk '{printf $2}' <(ssh-add -L))" <<< "${ARRAY[1]}" || {
                ssh-add "${ARRAY[0]}";
            } 
        else
            awkDynamicBorders -t "Host not found" -c "No host with the name '${1}' exists within your '${HOME}/.ssh/config' file.";
            return 1;
        fi

        /usr/bin/ssh "${1}";
    }

    return 0;
}

main "${1}";
exit 0;
