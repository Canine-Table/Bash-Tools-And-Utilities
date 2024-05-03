# Check if LIB_DIR is already exported, if not, set it to the directory of this script
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";


function optionManager() {

    local OPT OPTARG;
    local -i OPTIND;
    local -a FIELDS;
    local -A OPTION_PROPERTIES;

    while getopts :G:A:a:k:d:mq OPT; do
        case ${OPT} in
            m|q) OPTION_PROPERTIES["${OPT}"]='true';;
            k|d|a|G|A) OPTION_PROPERTIES["${OPT}"]="${OPTARG}";;
        esac
    done

    shift $((OPTIND - 1));

    [[ -z "${OPTION_PROPERTIES["a"]}" ]] && {
        if [[ -n "${1}" ]]; then
            OPTION_PROPERTIES["a"]="${1}";
            shift;
        else
            "${OPTION_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Invalid Entry (-k)" -c "Please provide (-k) key to process."
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

    if [[ -n "${OPTION_PROPERTIES['k']}" ]]; then
        FIELDS[0]="${OPTION_PROPERTIES['k']}";
        FIELDS[1]="${OPTION_PROPERTIES["a"]}"
    else 
        awkFieldManager -d '=' "${OPTION_PROPERTIES["a"]}"
    fi
  
    [[ -z "$(echo -n "${FIELDS[0]}" | sed '/^".*"$/{ s/^"//; s/"$//; }')" || -z "$(echo -n "${FIELDS[0]}" | sed "/^'.*'$/{ s/^'//; s/'$//; }")" || $(echo -n "${FIELDS[0]}" | tr -d \"\') =~ ^[[:space:]]+$ ]] && {
        "${OPTION_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Parameter (-a) is Empty" -c "Please provide (-a) as either 'value' or 'key'=value' with or without quotes." >&2;
        return 3;
    }

    if [[ "${#FIELDS[@]}" -gt 2 && -z "${OPTION_PROPERTIES['k']}" ]]; then
        OPTION_PROPERTIES['v']="$(echo -n "${OPTION_PROPERTIES["a"]}" | sed "s/^${FIELDS[0]}[[:space:]]*=//")";
    elif [[ -n "${FIELDS[1]}" ]];then 
        OPTION_PROPERTIES['v']="${FIELDS[1]}";
    fi

    OPTION_PROPERTIES['k']="${FIELDS[0]}";
    FIELDS=();

    DATA="$(declare -p "${OPTION_PROPERTIES["A"]}" | awk \
        -v key="${OPTION_PROPERTIES['k']}" \
        -v value="${OPTION_PROPERTIES['v']:-${OPTION_PROPERTIES['d']:-true}}" \
        -v modify="${OPTION_PROPERTIES["m"]:-false}" \
        -v radio="${OPTION_PROPERTIES["G"]}" \
        -f "${LIB_DIR}/awk-lib/option-manager.awk")" || case $? in
            10)
                "${OPTION_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Empty Associative Array" -c "Please provide an associative array (-A) with at least 1 index." >&2;
                return 10;;
            11)
                "${OPTION_PROPERTIES["q"]:-false}" || awkDynamicBorders -d "█" -l "Key Already Exists" -c "Please provide the (-m) flag if you wish to modify existing key values, '${OPTION_PROPERTIES['k']}' already exists within the '${OPTION_PROPERTIES["A"]}' associative array." >&2;
                return 11;;
            12)
                "${OPTION_PROPERTIES["q"]:-false}" || awkDynamicBorders -d "█" -l "Radio Already Set" -c "Please provide the (-m) flag if you wish to modify existing key values, '${OPTION_PROPERTIES['k']}' already exists within the '${OPTION_PROPERTIES["A"]}' associative array, only 1 of the following choices can be selected at onces '${OPTION_PROPERTIES["G"]}'" >&2;
                return 12;;
        esac

    echo "${DATA}";
    return 0;
}