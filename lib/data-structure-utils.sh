grep -q 'LIB_DIR' <(export) || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> '/dev/null' && pwd)";

function copyDataStructure() {

    local FAILED="false" OPT OPTARG;
    local -i OPTIND;
    local -A DATA_STRUCTURE=(
        ["type"]="a,Array"
        ["from"]=""
        ["to"]=""
    );

    while getopts :f:t:d OPT; do
        case ${OPT} in
            d) DATA_STRUCTURE["type"]="A,Dictionary";;
            f) DATA_STRUCTURE["from"]="${OPTARG}";;
            t) DATA_STRUCTURE["to"]="${OPTARG}";;
        esac
    done

    shift "$((OPTIND - 1))";
    fieldManager "${DATA_STRUCTURE["type"]}";

    if ! grep -q "^declare -${FIELDS[0]} ${DATA_STRUCTURE["from"]}\b" <(declare "-${FIELDS[0]}"); then
        echo "${DATA_STRUCTURE["from"]} is not an initialized ${FIELDS[1]}.";
        FAILED="true";
    fi

    DATA_STRUCTURE["type"]="${FIELDS[0]}";
    unset FIELDS;
    "${FAILED}" && return 1;
    [[ -z "${DATA_STRUCTURE["to"]}" ]] && DATA_STRUCTURE["to"]="__${RANDOM}";
    grep -q "^declare -${DATA_STRUCTURE["type"]} ${DATA_STRUCTURE["to"]}\b" <(declare "-${DATA_STRUCTURE["type"]}") && unset "${DATA_STRUCTURE["to"]}";

    declare "-${DATA_STRUCTURE["type"]}g" "${DATA_STRUCTURE["to"]}=($(
        for OPT in $(declare -p "${DATA_STRUCTURE["from"]}" | cut -s -d '=' -f 2- | tr -d '()'); do
            echo -n "${OPT} ";
        done
    ))";

    return 0;
}

function stack() {

    local -n STACK;
    local OPTARG OPT;
    local -i OPTIND;
    local -A STACK_PROPERTIES=(
        ["action"]=""
        ["value"]=""
    );

    while getopts :a:rpe OPT; do
        case ${OPT} in
            r|p|e) STACK_PROPERTIES["action"]="${OPT}";;
            a) STACK_PROPERTIES["value"]="${OPTARG}"
        esac
    done

    shift "$((OPTIND - 1))";

    if [[ -z "${1}" ]]; then
        echo "you forgot to specify the stack you wanted to use.";
        return 1;
    fi

    grep -q "${1}" <(declare -a) || declare -ag "${1}";

    STACK="${1}";

    case "${STACK_PROPERTIES["action"]:-"$([[ -n "${STACK_PROPERTIES["value"]}" ]] && echo -n 'a' || echo -n 'p')"}" in
        a) STACK+=(${STACK_PROPERTIES["value"]});;
        r) if [[ "${#STACK[@]}" -gt 0 ]]; then
                echo "${STACK["(-1)"]}";
                unset STACK["(-1)"];
            else
                echo "The ${1} stack is currently empty.";
                return 3;
            fi;;
        p) [[ -n "${STACK[@]}" ]] && echo "${STACK[(-1)]}";;
        e) [[ -z "${STACK[@]}" ]] && return 4;;
    esac

    return 0;
}

function linkedStrings() {

    local OPTARG OPT KEY STRING;
    local -a KEYS VALUES HASH_MAP;
    local -n REFERENCE;
    local -i OPTIND COUNT;
    local -A STRING_PROPERTIES=(
        ["q"]="false"
        ["a"]="false"
    );

    while getopts :f:v:aq OPT; do
        case ${OPT} in
            f|v) STRING_PROPERTIES["${OPT}"]="${OPTARG}";;
            q|a) STRING_PROPERTIES["${OPT}"]="true";;
        esac
    done

    shift "$((OPTIND - 1))";
    fieldManager -d '=' -s "${STRING_PROPERTIES["v"]}";
    REFERENCE="${FIELDS[0]}";
    COUNT="${#REFERENCE[@]}";

    for OPT in "${!REFERENCE[@]}"; do
        if [[ -n "${STRING_PROPERTIES["f"]}" && -z "${FIELDS[1]}" ]]; then
            ((COUNT--));
            fieldManager "${REFERENCE["${OPT}"]}";

            for ((OPTIND=0; OPTIND < "${#FIELDS[@]}"; OPTIND++)); do
                if [[ "${FIELDS["${OPTIND}"]}" == "${STRING_PROPERTIES["f"]}" ]]; then
                    fieldManager "${OPT}";
                    "${STRING_PROPERTIES["a"]}" && REFERENCE["found"]="${FIELDS["${OPTIND}"]}";
                    ! "${STRING_PROPERTIES["q"]}" && echo "${FIELDS["${OPTIND}"]}";
                    return 0;
                fi
            done

            if [[ "${COUNT}" -eq 0 ]]; then
                ! "${STRING_PROPERTIES["q"]}" && awkDynamicBorders -l 'No Matches Found' -c "None of the keys in the hash map contained '${STRING_PROPERTIES["f"]}' as a value.";
                return 1;
            fi
        else
            HASH_MAP+=($(fieldManager -p "${OPT}"));
        fi
    done

    fieldManager -s "${FIELDS[1]}";

    if STRING_PROPERTIES["key"]="$(awkCompletion -q "${FIELDS[0]}" "${HASH_MAP[@]}")"; then
        STRING_PROPERTIES["value"]="${FIELDS[1]}";
        STRING_PROPERTIES["defaults"]="${FIELDS[2]}";
        
        for OPT in "${!REFERENCE[@]}"; do
            grep -Pq "^(${STRING_PROPERTIES["key"]})$" <(fieldManager -pu "${OPT}") && KEY="${OPT}";
        done
    else
        if [[ -z "${STRING_PROPERTIES["f"]}" ]]; then
            ! "${STRING_PROPERTIES["q"]}" && awkDynamicBorders -l 'Invalid Key' -c "The key '${FIELDS[0]}' has not been declared within the hash map.";
            return 2;
        fi
    fi

    unset HASH_MAP;
    KEYS=($(fieldManager -pu "${KEY}"));
    VALUES=($(fieldManager -pu "${REFERENCE[${KEY}]}"));

    if [[ "${#VALUES[@]}" -eq "${#KEYS[@]}" ]]; then
        for ((OPTIND=0; OPTIND < "${#KEYS[@]}"; OPTIND++)); do
            if [[ -n "${STRING_PROPERTIES["f"]}" ]]; then
                if [[ "${VALUES["${OPTIND}"]}" == "${STRING_PROPERTIES["f"]}" ]]; then
                    "${STRING_PROPERTIES["a"]}" && REFERENCE["found"]="${KEYS["${OPTIND}"]}";
                    ! "${STRING_PROPERTIES["q"]}" && echo "${KEYS["${OPTIND}"]}";
                    return 0
                fi

                if [[ "$((${OPTIND} + 1))" -eq "${#KEYS[@]}" ]]; then
                    ! "${STRING_PROPERTIES["q"]}" && awkDynamicBorders -l 'No Matches Found' -c "the Key does not have a value that matches the value '${STRING_PROPERTIES["f"]}' within the hash map.";
                    return 3;
                fi
            else
                if [[ "${KEYS["${OPTIND}"]}" == "${STRING_PROPERTIES["key"]}" ]]; then
                    STRING+="${STRING_PROPERTIES["value"]}";
                elif [[ -n "${STRING_PROPERTIES["defaults"]}" ]]; then
                    STRING+="${STRING_PROPERTIES["defaults"]}";
                else
                    STRING+="${VALUES["${OPTIND}"]}";
                fi
                
                if [[ "$((${OPTIND} + 1))" -ne "${#KEYS[@]}" ]]; then
                    STRING+=",";
                fi
            fi
        done
    fi

    REFERENCE["${KEY}"]="${STRING}";
    ! "${STRING_PROPERTIES["q"]}" && echo "${REFERENCE["${KEY}"]}";
    return 0;
}
