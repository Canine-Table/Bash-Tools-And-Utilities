export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> '/dev/null' && pwd)";

function unsetVariables() {
    local V;

    for V in "${@}"; do
        grep -q "^${V}$" <<< "$(declare -p | awk '{sub(/=.*/, "", $0) ;print $3}')" && unset "${V}";
    done

    return 0;
}
