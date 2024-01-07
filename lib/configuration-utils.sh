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
    local -a VALUES;
    local -A ARGUMENTS=(
        ["indent"]="4"
        ["q"]="false"
    ) BOOLEAN=(
        ["sort-keys"]="true"
        ["raw-output,join-output"]="false,true"
        ["monochrome-output,color-output"]="true,false"
        ["indent,tab"]="true,false"
    );

    while getopts :s:v:c:p:q OPT; do
        case ${OPT} in
            p|s) ARGUMENTS["${OPT}"]="${OPTARG}";;
            v) VALUES+=("${OPTARG}");;
            q) ARGUMENTS["${OPT}"]="true";;
            c) linkedStrings -v "BOOLEAN=${OPTARG},true,false";;
        esac
    done

    shift "$((OPTIND - 1))";

    if ! jq --exit-status "${ARGUMENTS["p"]}" "${DATABASE}" &> '/dev/null'; then
        ! "${ARGUMENTS["q"]}" && awkDynamicBorders -l 'Invalid Path' -c 'Please provide a json path that exists within your '${DATABASE}' file.';
        return 1;
    fi

    [[ -n "${ARGUMENTS[s]}" ]] && ! [[ ${ARGUMENTS[s]} =~ ^([[:digit:]]+:[[:digit:]]+)$ ]] && unset "${ARGUMENTS[s]}";

    if [[ -n "${ARGUMENTS["p"]}" ]]; then
        ARGUMENTS["type"]="$(jq --raw-output "${ARGUMENTS["p"]} | type" "${DATABASE}")";
    else
        ! "${ARGUMENTS["q"]}" && awkDynamicBorders -l 'Missing Argument' -c 'Please provide json path';
        return 2;
    fi

    for OPT in "${!BOOLEAN[@]}"; do
        OPTARG="$(linkedStrings -p -f 'true' -v "BOOLEAN=${OPT}")";
        [[ -n "${OPTARG}" ]] && PARAMETERS+=("--${OPTARG}");

        if [[ -n "${ARGUMENTS[${OPTARG}]}" ]]; then
            PARAMETERS+=("${ARGUMENTS[${OPTARG}]}");
        fi
    done
    
    if [[ -n "${VALUES[@]}" ]]; then
        if [[ "${ARGUMENTS["type"]}" == 'array' ]]; then
            OPTARG="[$(fieldManager -pm -q 'double' -d ',' -i ' ' "${VALUES[@]}")]";
        else
            OPTARG="\"${VALUES[*]}\"";
        fi

        jq "${PARAMETERS[@]}" "${ARGUMENTS["p"]} = ${OPTARG}" "${DATABASE}" | sponge "${DATABASE}";
    else
        if [[ "${ARGUMENTS["type"]}" == 'array' ]]; then
            ! [[ ${ARGUMENTS["p"]} =~ "\]$" ]] && ARGUMENTS["p"]+="[${ARGUMENTS["s"]}]";
        fi

        jq "${PARAMETERS[@]}" "${ARGUMENTS["p"]}" "${DATABASE}";
    fi

    return 0;
}
