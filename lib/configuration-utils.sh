if [[ ! $(declare -p | grep 'declare -x LIB_DIR') ]]; then
    export LIB_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";
fi

function libraries() {
    local CONFIGURATION_UTILITY_FILE="$(realpath "${BASH_ARGV[0]}")" FILE;

    for FILE in ${LIB_DIR}/*.sh; do
        if [[ "${FILE}" != "${CONFIGURATION_UTILITY_FILE}" ]]; then
            source "${FILE}";
        fi
    done
    
    modifiableConfigurations
    return 0;
}

function modifiableConfigurations() {
    export DIALOGRC="${LIB_DIR}/../etc/.dialogrc";
    export VIMINIT="${LIB_DIR}/../etc/.vimrc";

    return 0;
}

libraries