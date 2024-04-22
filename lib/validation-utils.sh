# Creates the LIB_DIR global variable if it does not already exist. Use this variable to access the absolute path of the library directory containing generic scripts.
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function unsetVariables() {
    local V;

    for V in "${@}"; do
        declare -p | awk '{sub(/=.*/, "", $0) ;print $3}' | grep -q "^${V}$" && unset "${V}";
    done

    return 0;
}
