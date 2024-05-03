# Check if LIB_DIR is already exported, if not, set it to the directory of this script
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function optionParser() {


    # Declare local variables for options and field properties
    local OPT OPTARG;
    local -i OPTIND;
    local -A PARSER_PROPERTIES;

   # Parse options passed to the function
    while getopts :A:a:q OPT; do
        case ${OPT} in
            q) PARSER_PROPERTIES["${OPT}"]="true";;
            a|A) PARSER_PROPERTIES["${OPT}"]="${OPTARG}";;
        esac
    done

    # Shift positional parameters by the number of options parsed
    shift $((OPTIND - 1));

    declarationQuery -m 'A' -n 'r' "${PARSER_PROPERTIES["A"]}" || return $?;

    [[ -n "${PARSER_PROPERTIES["a"]}" ]] && {
        declarationQuery -q -m 'a' -n 'r' "${PARSER_PROPERTIES["a"]}";
    }

    

    return 0;
}