# Creates the LIB_DIR global variable if it does not already exist. Use this variable to access the absolute path of the library directory containing generic scripts.
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function sedIsEmpty() {
    
    local OUTPUT='/dev/fd/1';
    
    [[ "${1}" == '-q' ]] && {
        OUTPUT='/dev/null';
        shift;
    }
    
    echo -n "${@}" | sed -f "${LIB_DIR}/sed-lib/is-empty.sed" > ${OUTPUT};
    return $?;
}

function sedBooleanToggle() {
    echo "${@}" | sed -E -f "${LIB_DIR}/sed-lib/boolean-toggle.sed";
    return 0;
}

function sedCharacterCasing() {
    echo "${@}" | sed -E -f "${LIB_DIR}/sed-lib/character-casing.sed";
    return 0;
}