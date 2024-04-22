# Creates the LIB_DIR global variable if it does not already exist. Use this variable to access the absolute path of the library directory containing generic scripts.
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function substitution() {

    function cleanup() {
        [[ -p "${FIFO}" ]] && rm "${FIFO}";
        return 0;
    }

    unsetVariables SUBSTITUTION;

    local OPT OPTARG;
    local -i OPTIND;
    local -r FIFO="/tmp/._$(cat /dev/urandom | tr -dc [:alnum:] | head -c 32).fifo";
    local -A DECLARATIONS;
    declare -ag SUBSTITUTION;

    while getopts pu OPT; do
        case ${OPT} in
            p|u) DECLARATIONS["${OPT}"]="true";;
        esac
    done

    shift $((OPTIND - 1));
    trap "cleanup" SIGINT SIGTERM EXIT;
    mkfifo "${FIFO}";
    "${@}" > "${FIFO}" 2> /dev/null &
    mapfile -t SUBSTITUTION < "${FIFO}";

    "${DECLARATIONS["p"]:-false}" && {
        echo ${SUBSTITUTION[@]};
        "${DECLARATIONS["u"]:-false}" && unset SUBSTITUTION;
    }
}

function temporary() {

    local TEMPORARY="/tmp/._$(cat /dev/urandom | tr -dc [:alnum:] | head -c 32).tmp";
    "${@}" > "${TEMPORARY}" 2> /dev/null;
    printf "${TEMPORARY}";

    return 0;
}

function append_path () {
    case ":${PATH}:" in
        *:"${1}":*);;
        *) export PATH="${PATH:+$PATH:}${1}";;
    esac

    return 0;
}