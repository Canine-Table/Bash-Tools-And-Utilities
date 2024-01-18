#!/bin/bash

function main() {

    export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> '/dev/null' && pwd)";
    source "${BIN_DIR}/../lib/configuration-utils.sh";
    libraries;

    local CONFIG="${HOME}/.ssh/config";

    [[ -f "${CONFIG}" && -r "${CONFIG}" && "$(awk '{print $1}' <(du completion))" -gt 0 ]] || {
        printf "${CONFIG}: no such readable non empty file." >&2;
        return 1;
    }

    local -a BASH_USER_NAMES;
    local -A "BASH_USERS_HOME_DIRECTORIES=(
        $(
            awk -F ':' '{
                if ($NF == "/bin/bash") {
                    print "[\"" $1 "\"]=\"" $6 "\"";
                }
            }' <(getent passwd);
        )
    )";

    for U in "${!BASH_USERS_HOME_DIRECTORIES[@]}"; do
        BASH_USER_NAMES+=("${U}");
    done

    while :; do
        echo -e "\n\tBash Users List\n\t---------------${BASH_USER_NAMES[@]/#/"\n\t"}";
        printf "\n\t";
        read -p "Select a User: " USERNAME;

        for U in "${BASH_USER_NAMES[@]}"; do
            if [[ "${USERNAME}" == "${U}" ]]; then
                break 2;
            fi
        done

        echo -e "\n\t'${USERNAME}' is not on the $(hostname)\n" >&2;
    done

    sed "/IdentityFile/{s/\/.*/$(
        awk '{
            gsub(/\//, "\\\/", $0);
            printf $0
        }' <<< "${BASH_USERS_HOME_DIRECTORIES["${USERNAME}"]}/.ssh/${USERNAME}_ed25519" 2> '/dev/null';
    )/g;}" "${CONFIG}" | sed 's/\/\//\//g'
    return 0;
}

main;
