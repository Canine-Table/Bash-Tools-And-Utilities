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

    local -A ARGUMENTS=(
        ["indent"]="4"
    );

    local -A BOOLEAN=(
        ["sort-keys"]="true"
        ["raw-output,join-output"]="false,true"
        ["monochrome-output,color-output"]="false,true"
        ["indent,tab"]="true,false"
    );

    while getopts :c:p: OPT; do
        case ${OPT} in
            p|s|n) ARGUMENTS["${OPT}"]="${OPTARG}";;
            c) linkedStrings -v "BOOLEAN=${OPTARG},true,false";;

        esac
    done

    shift "$((OPTIND - 1))";

    if [[ -n "${ARGUMENTS["p"]}" ]]; then
        ARGUMENTS["type"]="$(jq --raw-output "${ARGUMENTS["p"]} | type" "${DATABASE}")";
    else
        awkDynamicBorders -l 'Missing Argument' -c 'Please provide json path';
        return 1;
    fi

    for OPT in "${!BOOLEAN[@]}"; do
        OPTARG="$(linkedStrings -f 'true' -v "BOOLEAN=${OPT}")";
        PARAMETERS+=("--${OPTARG}");
    
        if [[ -n "${ARGUMENTS[${OPTARG}]}" ]]; then
            PARAMETERS+=("${ARGUMENTS[${OPTARG}]}");
        fi
    done

#    echo "${PARAMETERS[@]}"
    if [[ -n "${ARGUMENTS["n"]}" ]]; then
        :
    else
        if [[ "${ARGUMENTS["type"]}" == 'array' ]]; then
            ARGUMENTS["p"]+="[${ARGUMENTS["s"]}]";
        fi

        jq "${PARAMETERS[@]}" "${ARGUMENTS["p"]}" "${DATABASE}";
    fi

    return 0;
}
