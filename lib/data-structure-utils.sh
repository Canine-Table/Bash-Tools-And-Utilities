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
