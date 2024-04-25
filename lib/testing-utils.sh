# Check if LIB_DIR is already exported, if not, set it to the directory of this script
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";


function optionManager() {

    local OPT OPTARG;
    local -i OPTIND;
    local -a FIELDS;
    local -A OPTION_PROPERTIES;

    while getopts :G:A:a:d:mq OPT; do
        case ${OPT} in
            m|q) OPTION_PROPERTIES["${OPT}"]='true';;
            d|a|G|A) OPTION_PROPERTIES["${OPT}"]="${OPTARG}";;
        esac
    done

    shift $((OPTIND - 1));

    [[ -z "${OPTION_PROPERTIES["a"]}" ]] && {
        if [[ -n "${1}" ]]; then
            OPTION_PROPERTIES["a"]="${1}";
            shift;
        else
            "${OPTION_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Invalid Entry (-a)" -c "Please provide (-a) as either 'value' or 'key'=value' with or without quotes."
            return 1;
        fi
    }

    [[ -z "${OPTION_PROPERTIES["A"]}" ]] && {
        if [[ -n "${1}" ]]; then
            OPTION_PROPERTIES["A"]="${1}";
            shift;
        else
            "${OPTION_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Parameters Missing (-A)" -c "Please provide an associative array to use this function." >&2;
            return 2;
        fi
    }

    declarationQuery -m 'A' -n 'r' "${OPTION_PROPERTIES["A"]}" || return $?;

    local -n REFERENCE="${OPTION_PROPERTIES["A"]}";

    awkFieldManager -p -d '=' "${OPTION_PROPERTIES["a"]}"

    [[ -z "${FIELDS[0]}" || "${FIELDS[0]}" =~ ^[[:space]]+:$ ]] && {
        "${OPTION_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Parameter (-a) is Empty" -c "Please provide (-a) as either 'value' or 'key'=value' with or without quotes." >&2;
        return 3;
    }

    OPTION_PROPERTIES['k']="${FIELDS[0]}";
    [[ -n "${FIELDS[1]}" ]] && OPTION_PROPERTIES['v']="${FIELDS[1]}";
    FIELDS=();

    DATA="$(declare -p "${OPTION_PROPERTIES["A"]}" | awk \
        -v key=${OPTION_PROPERTIES['k']} \
        -v value="${OPTION_PROPERTIES['v']:-${OPTION_PROPERTIES['d']:-true}}" \
        -v modify="${OPTION_PROPERTIES["m"]:-false}" \
        -v  radio="${OPTION_PROPERTIES["G"]}" \
        -f "${LIB_DIR}/awk-lib/option-manager.awk")" || case $? in
            10)
                "${OPTION_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Empty Associative Array" -c "Please provide an associative array (-A) with at least 1 index." >&2;
                return 10;;
        esac

    echo "${DATA}";
    return 0;
}