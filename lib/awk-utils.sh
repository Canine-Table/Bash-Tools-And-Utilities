export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> '/dev/null' && pwd)";

function awkDescriptor() {
    local TEMPORARY="$(mktemp)";
    echo "${@}" > "${TEMPORARY}";
    awk -f "${LIB_DIR}/awk-lib/awk-utils.awk" -f "${TEMPORARY}";
    rm "${TEMPORARY}";
    return 0;
}

function awkCompletion() {

    unsetVariables {REMAINDER,KWARGS};

    local C COMPLETE;
    local -a COMPLETION REMAINDER;
    local -A SELECTION KWARGS;

    awkGetOptions  'print,p|empty,e:match,m:noMatch,n:noList,l:' -- "${@}";

    local -A COMPLETION_PROPERTIES=(
        ["match"]="${KWARGS["match"]}"
        ["print"]="${KWARGS["print"]:-"false"}"
        ["empty"]="${KWARGS["empty"]:-"Please provide a string to match with for the list of options."}"
        ["noList"]="${KWARGS["noList"]:-"Please provide a list of options to choose from."}"
        ["noMatch"]="${KWARGS["noMatch"]}"
        ["matched"]="false"
    );

    if [[ -z "${COMPLETION_PROPERTIES["match"]}" ]]; then
        if [[ -n "${REMAINDER[@]}" ]]; then
            COMPLETION_PROPERTIES["match"]="${REMAINDER[0]}";
            unset REMAINDER[0];
        else
            "${COMPLETION_PROPERTIES["print"]}" && awkDynamicBorders -l "Empty String" -c "${COMPLETION_PROPERTIES["empty"]}";
            return 1;
        fi
    fi

    if [[ -z "${REMAINDER[@]}" ]]; then
        "${COMPLETION_PROPERTIES["print"]}" && awkDynamicBorders -l "No List to provided" -c "${COMPLETION_PROPERTIES["noList"]}";
        return 2;
    fi

    for C in "${REMAINDER[@]}"; do
        awkFieldManager "${C}";

        if [[ "${#FIELDS[@]}" -gt 0 ]]; then
            SELECTION["${FIELDS[1]:-"${FIELDS[0]}"}"]="${FIELDS[0]}";
            COMPLETE+=",${FIELDS[1]:-"${FIELDS[0]}"}";
        fi
    done

   mapfile -t COMPLETION < <(awkFieldManager -g 'value' "${COMPLETE:1}" | awk -f "${LIB_DIR}/awk-lib/completion.awk");

    for C in "${COMPLETION[@]}"; do
        awkFieldManager "${C}";

        if [[ ${COMPLETION_PROPERTIES["match"],,} =~ ${FIELDS[1],,} ]]; then
            printf "${SELECTION[${FIELDS[0]}]}";
            COMPLETION_PROPERTIES["matched"]="true";
            break;
        fi
    done
    
    if ! "${COMPLETION_PROPERTIES["matched"]}"; then
        "${COMPLETION_PROPERTIES["print"]}" && awkDynamicBorders -l "No Match Found" -c "${COMPLETION_PROPERTIES["noMatch"]:-"${COMPLETION_PROPERTIES["match"]} did not match an option."}";
        return 3;
    fi

    return 0;
}

function awkDynamicBorders() {

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

            echo -en "${COMMANDS["${OPTIND}"]}" | awk "${PARAMETERS[@]}" -v columns="${BORDER_PROPERTIES["columns"]}" -f "${LIB_DIR}/awk-lib/awk-utils.awk" -f "${LIB_DIR}/awk-lib/dynamic-border.awk" 2> '/dev/null';

            if [[ -n "${PARAMETERS[@]}" ]]; then
                unset PARAMETERS;
            fi
        done
    else
        return 1;
    fi

    return 0;
}

function awkGetOptions() {

    unsetVariables {REMAINDER,KWARGS};

    local OPTION KEY VALUE;
    declare -ag REMAINDER;
    declare -Ag KWARGS;
    local -a GET_OPTIONS FIELDS;

    mapfile -t GET_OPTIONS < <(awk -v options="${1}" -f "${LIB_DIR}/awk-lib/get-options.awk" -v argv="${@}" 2> '/dev/null');

    for OPTION in "${GET_OPTIONS[@]}"; do
        if grep -q 'EOF' <<< "${OPTION}"; then
            if [[ -n "${OPTION:4}" ]]; then
                mapfile -t FIELDS < <(awk -v separator="\\n" -v delimiter="▒" -f "${LIB_DIR}/awk-lib/field-manager.awk" <<< "${OPTION:4}" 2> '/dev/null');
                REMAINDER=("${FIELDS[@]}");
            fi
        else
            mapfile -t FIELDS < <(awk -v separator="\n" -v delimiter="▓" -f "${LIB_DIR}/awk-lib/field-manager.awk" <<< "${OPTION}" 2> '/dev/null');
            if [[ -n  "${FIELDS[0]}" ]]; then
                VALUE="${FIELDS[1]}";
                mapfile -t FIELDS < <(awk -v separator="\\n" -v delimiter="░" -f "${LIB_DIR}/awk-lib/field-manager.awk" <<< "${FIELDS[0]}" 2> '/dev/null');

                for KEY in "${FIELDS[@]}"; do
                    KWARGS["${KEY}"]="${VALUE:-"true"}";
                done
            fi
        fi
    done

    return 0;
}

function awkFieldManager() {

    unsetVariables {REMAINDER,FIELDS,KWARGS};

    declare -ag FIELDS;
    local -A KWARGS;
    local -a REMAINDER;
    local -i INDEX;

    awkGetOptions 'unset,u|print,p|delimiter,d:quote,q:separator,s:index,i:get,g:' -- "${@}";

    local -A FIELD_PROPERTIES=(
        ["delimiter"]="${KWARGS["delimiter"]:-","}"
        ["separator"]="${KWARGS["separator"]:-"\\n"}"
        ["print"]="${KWARGS["print"]:-"false"}"
        ["unset"]="${KWARGS["unset"]:-"false"}"
        ["index"]="${KWARGS["index"]}"
        ["get"]="${KWARGS["get"]}"
    );

    [[ ${KWARGS["quote"]} =~ ^(s(i(n(g(l(e)?)?)?)?)?)$ ]] && FIELD_PROPERTIES["quote"]="'";
    [[ ${KWARGS["quote"]} =~ ^(d(o(u(b(l(e)?)?)?)?)?)$ ]] && FIELD_PROPERTIES["quote"]='"';

    unset KWARGS;
    mapfile -t FIELDS < <(awk -v separator="${FIELD_PROPERTIES["separator"]}" -v delimiter="${FIELD_PROPERTIES["delimiter"]}" -v quote="${FIELD_PROPERTIES["quote"]}" -f "${LIB_DIR}/awk-lib/field-manager.awk" <<< "${REMAINDER[@]}" 2> '/dev/null');

    "${FIELD_PROPERTIES["print"]}" && echo "${FIELDS[*]}";

    [[ -n "${FIELD_PROPERTIES["index"]}" || -n "${FIELD_PROPERTIES["get"]}" ]] && awkIndexer -g "${FIELD_PROPERTIES["get"]}" -r "${FIELD_PROPERTIES["index"]}" -a 'FIELDS';

    "${FIELD_PROPERTIES["unset"]}" && unset FIELDS;
    return 0;
}

function awkIndexer() {

    local STRING_ARRAY;
    local -a REMAINDER;
    local -A KWARGS;
    local KEY_OR_VALUE;

    awkGetOptions 'get,g:range,r:array,a:' -- "${@}";

    if ! STRING_ARRAY="$(declare -p "${KWARGS["array"]:-"${REMAINDER[0]}"}" 2> '/dev/null')"; then
        awkDynamicBorders -l "Undeclared Variable" -c "Please provide an array or hash map to index.\nThis variable '${KWARGS["array"]:-"${REMAINDER[0]}"}' has not been declared";
        return 1;
    fi

    local TYPE="$(awk '{print substr($2, 2)}' <<< "${STRING_ARRAY}")";

    case "${TYPE}" in
        A|a) ;;
        *) awkDynamicBorders -l "Invalid Variable Type" -c "The variable type must be either an array (-a) or a hash map (-A).\n'-${TYPE}' is not a valid type."; return 2;;
    esac

    [[ "${KWARGS["get"]}" =~ ^(v(a(l(u(e(s)?)?)?)?)?)$ ]] && KEY_OR_VALUE="value";
    [[ "${KWARGS["get"]}" =~ ^(k(e(y(s)?)?)?)$ ]] && KEY_OR_VALUE="key";

    if ! awk -v key_or_value="${KEY_OR_VALUE}" -v index_range="${KWARGS["range"]}" -f "${LIB_DIR}/awk-lib/awk-utils.awk" -f "${LIB_DIR}/awk-lib/indexer.awk" -v array="${STRING_ARRAY}"; then
        awkDynamicBorders -l "Uninitialized Variable" -c "Please an array or hash map to with at least 1 index.\nThis variable '${KWARGS["array"]:-"${REMAINDER[0]}"}' contains no values to index.";
        return 3;
    fi

    unset KWARGS REMAINDER;
    return 0;
}

function awkUtilities() {

    local -a AWK_LIBRARIES;
    local KEY;

    fileSystem -p "${LIB_DIR}/awk-lib" -t f -n 'name=*-utils.awk';

    for KEY in "${!FOUND[@]}"; do
        AWK_LIBRARIES+=("-f" "${FOUND["${KEY}"]}/${KEY}");
    done

    echo "${AWK_LIBRARIES[@]}";

    return 0;
}