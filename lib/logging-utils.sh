# Creates the LIB_DIR global variable if it does not already exist. Use this variable to access the absolute path of the library directory containing generic scripts.
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function logging() {

    function loggingSeverity() {
        local -a SEVERITY=(
            'emergency'
            'alert'
            'critical'
            'warning'
            'notice'
            'informational'
            'debug'
        );
        LOGGING_PROPERTIES["${OPT}"]="$(awkCompletion -s "${OPTARG}" "${SEVERITY[@]}")";
    }

    # Declare local variables for options and field properties
    local OPT OPTARG;
    local -i OPTIND;
    local -A LOGGING_PROPERTIES;

   # Parse options passed to the function
    while getopts :l:q OPT; do
        case ${OPT} in
        l) LOGGING_PROPERTIES["${OPT}"]="${OPTARG}";;
        q) LOGGING_PROPERTIES["${OPT}"]='true';;
        esac
    done

    # Shift positional parameters by the number of options parsed
    shift $((OPTIND - 1));

#"root:$(grep -o '^\(wheel\|sudo\)' /etc/group)"
}