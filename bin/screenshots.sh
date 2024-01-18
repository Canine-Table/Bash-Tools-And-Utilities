#!/bin/bash

function main() {

    export | grep -q 'declare -x BIN_DIR=' || export BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> '/dev/null' && pwd)";
    source "${BIN_DIR}/../lib/configuration-utils.sh";
    libraries;

    local SCREENSHOTS="${HOME}/Pictures/Screenshots" S;

    [[ -d "${SCREENSHOTS}" ]] || mkdir -m 755 -p "${SCREENSHOTS}";

    while :; do
        fileSystem -p "${HOME}/Pictures" -n 'name=Screenshot*.png'

        [[ -n "${FOUND[@]}" ]] && for S in "${!FOUND[@]}"; do
            mv "${FOUND["${S}"]}/${S}" "${SCREENSHOTS}/$(ls -l --time-style=full-iso "${FOUND["${S}"]}/${S}" | cut -d ' ' -f 6-7 | tr ' ' '_').png";
            unset FOUND;
        done

        sleep 3;
    done

    return 0;
}

main &