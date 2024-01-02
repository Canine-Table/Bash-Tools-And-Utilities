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

    local -A BOOLEAN=(
        ["--sort-keys"]="true"
        ["--raw-output,--join-output"]="true,true"
        ["--monochrome-output,--color-output"]="true,false"
        ["--indent,--tab"]="true=4,false"
    );

    while getopts :i:d:s:q:mpu OPT; do
        case ${OPT} in
            u) FIELD_PROPERTIES["unset"]="true";;
        esac
    done

    shift "$((OPTIND - 1))";


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
