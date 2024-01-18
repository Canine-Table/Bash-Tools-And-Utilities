export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> '/dev/null' && pwd)";

function substitution() {

    function cleanup() {
        [[ -f "${TEMPORARY}" ]] && rm "${TEMPORARY}" 2> '/dev/null';
        return 0;
    }

    trap "cleanup" SIGINT EXIT RETURN;

    local TEMPORARY="/tmp/_$(cat /dev/urandom | tr -dc [:alnum:] | head -c 32).tmp";
    local -i STATUS=0;

    touch "${TEMPORARY}";

    if ! eval "${@}" 1> "${TEMPORARY}" 2> '/dev/null'; then
        echo -en "${@}" &> "${TEMPORARY}";
        STATUS=1;
    fi

    [[ "$(awk '{print $1}' <<< "$(du -d 0 "${TEMPORARY}")")" -gt 0 ]] && cat "${TEMPORARY}";

    return "${STATUS}";
}
