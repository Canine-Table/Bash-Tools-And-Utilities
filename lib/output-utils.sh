# Creates the LIB_DIR global variable if it does not already exist. Use this variable to access the absolute path of the library directory containing generic scripts.
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function message() {

    local MESSAGE=${1} TYPE;
    local -a FIELDS;

    [[ -z "${MESSAGE}" ]] && return 1;

    awkFieldManager -d '=' "${MESSAGE}";

    TYPE="$(awkParameterCompletion -q -s "${FIELDS[0]}" -d ',' -O 'warning,error,message')" && {
        [[ -n "${FIELDS[1]}" ]] && MESSAGE="${FIELDS[1]}";
    } || {
        TYPE='message';
    }

    case "${TYPE}" in
        warning) echo "$(tput bold; tput setaf 1)[!] WARNING: $(sedCharacterCasing ${MESSAGE})$(tput sgr0)" >&2;;
        error) echo "$(tput bold; tput setaf 1)[-] ERROR: $(sedCharacterCasing ${MESSAGE})$(tput sgr0)" >&2;;
        message) echo "$(tput bold; tput setaf 2)[+] $(sedCharacterCasing ${MESSAGE})$(tput sgr0)";;
    esac

    return 0;
}
