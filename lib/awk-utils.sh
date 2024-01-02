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


function awkBorder() {

    local OPT OPTARG ARR;
    local -i OPTIND;
    local -a DOCUMENTS;
    local -Ai BORDER_PROPERTIES=(
        ["lines"]="$(tput lines)"
        ["columns"]="$(tput cols)"
        ["leftMargin"]="1"
        ["leftPadding"]="1"
        ["rightMargin"]="1"
        ["rightPadding"]="1"
    );

    for ARR in "${@}"; do
        [[ -f "${ARR}" && -r "${ARR}" ]] && DOCUMENTS+=("$(cat "${ARR}")") || DOCUMENTS+=("${ARR}");
    done

    for ((OPTIND=0; OPTIND < "${#DOCUMENTS[@]}"; OPTIND++)); do
        echo -e "\n\n${DOCUMENTS["${OPTIND}"]}\n\n" | awk -v properties="${BORDER_PROPERTIES[*]}" -f "${LIB_DIR}/awk-lib/awk-utils.awk" -f "${LIB_DIR}/awk-lib/borders.awk"
    done

    return 0;
}

