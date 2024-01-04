grep -q 'LIB_DIR' <(export) || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> '/dev/null' && pwd)";

function awkDescriptor() {

    exec 9< <(echo "${@}");
    awk -f "${LIB_DIR}/awk-lib/awk-utils.awk" -f '/dev/fd/9';
    exec 9<&-;

    return 0;
}

function awkCompletion() {

    local -i OPTIND;
    local LIST OPT OPTARG;
    local -a REGEX;
    local -A COMPLETION_PROPERTIES=(
        ["a"]=""
        ["e"]=""
        ["n"]=""
        ["A"]=""
        ["print"]="true"
        ["matched"]="false"
    ) CHOICES;

    while getopts :a:A:e:n:q OPT; do
        case ${OPT} in
            q) COMPLETION_PROPERTIES["print"]="false";;
            e|n|A|a) COMPLETION_PROPERTIES["${OPT}"]="${OPTARG}";;
        esac
    done

    shift "$((OPTIND - 1))";

    if [[ -z "${COMPLETION_PROPERTIES["a"]}" ]]; then
        if [[ -n "${@}" ]]; then
            COMPLETION_PROPERTIES["a"]="${1}";
            shift;
        else
            "${COMPLETION_PROPERTIES["print"]}" && echo "${COMPLETION_PROPERTIES["A"]:-"Please provide a string to match with for the list of options."}";
            return 1;
        fi
    fi

    if [[ -z "${@}" ]]; then
        "${COMPLETION_PROPERTIES["print"]}" && echo "${COMPLETION_PROPERTIES["n"]:-"Please provide a list of options to choose from."}";
        return 2;
    fi

    for OPT in "${@}"; do
        fieldManager -d "," "${OPT}";

        if [[ "${#FIELDS[@]}" -gt 0 ]]; then
            CHOICES["${FIELDS[1]:-${FIELDS[0]}}"]="${FIELDS[0]}";
            LIST+=",${FIELDS[1]:-${FIELDS[0]}}";
        fi
    done

    mapfile REGEX < <(fieldManager -pm -i ',' -d '\n' "${LIST:1}" | awk -f "${LIB_DIR}/awk-lib/completion.awk");

    for OPT in "${REGEX[@]}"; do
        fieldManager -d "," "${OPT}";

        if [[ ${COMPLETION_PROPERTIES["a"],,} =~ ${FIELDS[1],,} ]]; then
            printf "${CHOICES[${FIELDS[0]}]}";
            COMPLETION_PROPERTIES["matched"]="true";
            break;
        fi
    done

    if ! "${COMPLETION_PROPERTIES["matched"]}"; then
        "${COMPLETION_PROPERTIES["print"]}" && echo "${COMPLETION_PROPERTIES["e"]:-"${COMPLETION_PROPERTIES["a"]} did not match an option."}";
        return 2;
    fi

    return 0;
}


awkDynamicBorders() {

    function setCommands() {
        fieldManager "${OPTARG}";
        COMMANDS+=("${FIELDS[@]}")
        return 0;
    }

    local -i OPTIND;
    local OPT OPTARG;
    local -a COMMANDS PARAMETERS;
    local -A BORDER_PROPERTIES=(
        ["label"]=""
        ["columns"]="$(tput cols)"
        ["wordWrap"]="false"
        ["style"]="single"
    );

    while getopts :s:l:c:C:W OPT; do
        case ${OPT} in
            l) BORDER_PROPERTIES["label"]="${OPTARG}";;
            s) BORDER_PROPERTIES["style"]="$(awkCompletion "${OPTARG}" {"single","double"})";;
            c) setCommands;;
            W) BORDER_PROPERTIES["wordWrap"]="true";;
            C) [[ ${OPTARG} =~ ^[[:digit:]]+$ && "${OPTARG}" -gt 6 && "${OPTARG}" -lt "$(tput cols)" ]] && BORDER_PROPERTIES["columns"]="${OPTARG}";;
        esac
    done

    shift "$((OPTIND - 1))";

    if [[ -n "${COMMANDS[@]}" ]]; then
        for ((OPTIND=0; OPTIND < "${#COMMANDS[@]}"; OPTIND++)); do

            if [[ "${OPTIND}" -eq 0 ]]; then
                if [[ -n "${BORDER_PROPERTIES["label"]}" ]]; then
                    PARAMETERS+=('-v' "label=${BORDER_PROPERTIES["label"]}");
                else
                    PARAMETERS+=("-v" "header=true");
                fi
            fi

            if [[ "$((OPTIND + 1))" -eq "${#COMMANDS[@]}" ]]; then
                PARAMETERS+=("-v" "footer=true");
            fi

            if command -v "$(cut -d ' ' -f 1 <<< "${COMMANDS["${OPTIND}"]}")" &> '/dev/null'; then
                COMMANDS["${OPTIND}"]="$(eval "${COMMANDS["${OPTIND}"]}")";
            elif [[ -f "${COMMANDS["${OPTIND}"]}" && -r "${COMMANDS["${OPTIND}"]}" ]]; then
                COMMANDS["${OPTIND}"]="$(cat "${COMMANDS["${OPTIND}"]}")";
            fi

            if "${BORDER_PROPERTIES["wordWrap"]}"; then
                PARAMETERS+=("-v" "wordWrap=${BORDER_PROPERTIES["wordWrap"]}");
            fi

            PARAMETERS+=("-v" "style=${BORDER_PROPERTIES["style"]}");

            echo -n "${COMMANDS["${OPTIND}"]}" | awk "${PARAMETERS[@]}" -v columns="${BORDER_PROPERTIES["columns"]}" -f "${LIB_DIR}/awk-lib/awk-utils.awk" -f "${LIB_DIR}/awk-lib/dynamic-border.awk" 2> '/dev/null';

            if [[ -n "${PARAMETERS[@]}" ]]; then
                unset PARAMETERS;
            fi
        done
    else
        return 1;
    fi

    return 0;
}
