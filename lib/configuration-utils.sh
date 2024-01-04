grep -q 'LIB_DIR' <(export) || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> '/dev/null' && pwd)";


function libraries() {
    local FILE;

    for FILE in ${LIB_DIR}/*.sh; do
        source "${FILE}";
    done
    
    modifiableConfigurations
    return 0;
}

function modifiableConfigurations() {
    export DIALOGRC="${LIB_DIR}/../etc/.dialogrc";
    export VIMINIT="${LIB_DIR}/../etc/.vimrc";
    export INPUTRC="${LIB_DIR}/../etc/.inputrc";
    return 0;
}

function database() {

    local DATABASE="${LIB_DIR}/../etc/db.json";
    local -i OPTIND;
    local OPT OPTARG;
    local -a PARAMETERS;
    local -A ARGUMENTS=(
        ["indent"]="4"
    );

    local -A BOOLEAN=(
        ["sort-keys"]="true"
        ["raw-output,join-output"]="false,true"
        ["monochrome-output,color-output"]="false,true"
        ["indent,tab"]="true,false"
    );

    while getopts :p: OPT; do
        case ${OPT} in
            p) ARGUMENTS["p"]="${OPTARG}";;
        esac
    done

    shift "$((OPTIND - 1))";

    if [[ -n "${ARGUMENTS["p"]}" ]]; then
        ARGUMENTS["type"]="$(jq --raw-output ".${ARGUMENTS["p"]} | type" "${DATABASE}")";
    else
        awkDynamicBorders -l 'Missing Argument' -c 'Please provide json path';
        return 1;
    fi

    for OPT in "${!BOOLEAN[@]}"; do
        OPTARG="$(linkedStrings -f 'true' -s "BOOLEAN=${OPT}")";
        PARAMETERS+=("--${OPTARG}");
    
        if [[ -n "${ARGUMENTS[${OPTARG}]}" ]]; then
            PARAMETERS+=("${ARGUMENTS[${OPTARG}]}");
        fi
    done


    if [[ "${ARGUMENTS["type"]}" == 'array' ]]; then
        ARGUMENTS["p"]+='[]';
    fi

    jq "${PARAMETERS[@]}" ".${ARGUMENTS["p"]}" "${DATABASE}";

    return 0;
}


function parameterExpansion() {

    [[ -z "${PARAMETER_EXPANSION}" ]] || unset PARAMETER_EXPANSION;
    declare -ag PARAMETER_EXPANSION;

    local -A EXPANSION;
    local -i OPTIND;
    local E;
    local -a KEYS VALUES

    for E in "${!EXPANSION[@]}"; do
        KEYS=($(fieldManager -pu -s "${E}"));
        VALUES=($(fieldManager -pu -s "${EXPANSION["${E}"]}"));

        for ((OPTIND=0; OPTIND < "${#KEYS[@]}"; OPTIND++)); do
            fieldManager -d '=' -s "${VALUES["${OPTIND}"]}";
            if "${FIELDS[0]}"; then
                PARAMETER_EXPANSION+=("${KEYS["${OPTIND}"]}");
                [[ -n "${FIELDS[1]}" ]] && PARAMETER_EXPANSION+=("${FIELDS[1]}");
                break;
            fi
        done
    done

    echo "${PARAMETER_EXPANSION[@]}";
    return 0;
}
