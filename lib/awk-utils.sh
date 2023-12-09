if [[ ! $(declare -p | grep 'declare -x LIB_DIR') ]]; then
    export LIB_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";
fi

function awkDescriptor() {

    exec 9< <(echo "${@}");
    awk -f "${LIB_DIR}/awk-lib/awk-utils.awk" -f '/dev/fd/9';
    exec 9<&-;

    return 0;
}