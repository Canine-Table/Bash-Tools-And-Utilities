#!/bin/bash

function main() {

    export | grep -q 'declare -x BIN_DIR=' || export BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> '/dev/null' && pwd)";
    source "${BIN_DIR}/../lib/configuration-utils.sh";
    libraries;

    local SCREENSHOTS="${HOME}/Pictures/Screenshots" ANSWERS="${HOME}/Documents/Plaintext/TXT/Answers" S;

    [[ -d "${SCREENSHOTS}" ]] || mkdir -m 755 -p "${SCREENSHOTS}";
    [[ -d "${SCREENSHOTS}" ]] || mkdir -m 755 -p "${ANSWERS}";

    while :; do
        fileSystem -M 1 -p "${HOME}/Pictures" -n 'name=Screenshot*.png'

        [[ -n "${FOUND[@]}" ]] && for S in "${!FOUND[@]}"; do
            mv "${FOUND["${S}"]}/${S}" "${SCREENSHOTS}/screenshots_$(ls -l --time-style=full-iso "${FOUND["${S}"]}/${S}" | cut -d ' ' -f 6-7 | tr ' ' '_').png";
            unset FOUND;
        done

        fileSystem -M 1 -p "${HOME}/Downloads" -n 'name=Answer*';
        
        [[ -n "${FOUND[@]}" ]] && for S in "${!FOUND[@]}"; do
            mv "${FOUND["${S}"]}/${S}" "${ANSWERS}/$(sed -n '2p' "${FOUND["${S}"]}/${S}" | tr ' ' '_' | tr -dc [:alnum:]_ | cut -c -32).txt";
            unset FOUND;
        done

        sleep 3;
    done

    return 0;
}

main &