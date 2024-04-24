# Creates the LIB_DIR global variable if it does not already exist. Use this variable to access the absolute path of the library directory containing generic scripts.
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function libraries() {
    local FILE;

    # import all the bash functions within the files located within the library directory.
    for FILE in ${LIB_DIR}/*.sh; do
        source "${FILE}";
    done

    return 0;
}

function database() {

    # Declare local variables for options and field properties
    local -r DATABASE_FILE="${LIB_DIR}/../etc/db.json";
    local -a DATABASE_PARAMETERS;
    local -A DATABASE_PROPERTIES;
    local OPT OPTARG;
    local -i OPTIND;
    local -ai PROCESSES;

   # Parse options passed to the function
    while getopts :c:f:A:Trmq OPT; do
        case ${OPT} in
        r) DATABASE_PARAMETERS=(${DATABASE_PARAMETERS[@]} "$(isUniqueEntry -qQ DATABASE_PARAMETERS "${OPT}")");;
        c|f|A) DATABASE_PROPERTIES["${OPT}"]="${OPTARG}";;
        q|m) DATABASE_PROPERTIES["${OPT}"]='true';;
        T) DATABASE_PROPERTIES["${OPT}"]='false';;
        esac
    done

    # Shift positional parameters by the number of options parsed
    shift $((OPTIND - 1));

    DATABASE_PROPERTIES["f"]="$([[ ${DATABASE_PROPERTIES["f"]:0:1} == '.' ]] || printf '.')${DATABASE_PROPERTIES["f"]}";

    "${DATABASE_PROPERTIES['T']:-true}" && {
        DATABASE_PROPERTIES['t']="$(jq -r "${DATABASE_PROPERTIES["f"]:-.} | type" "${DATABASE_FILE}")" & PROCESSES+=($!);
    }
            wait "${PROCESSES[@]}";

    if "${DATABASE_PROPERTIES['c']:-false}"; then
    echo '1'
    elif [[ "${DATABASE_PROPERTIES['t']}" != 'null' ]]; then
        "${DATABASE_PROPERTIES['T']:-true}" && {

            case "${DATABASE_PROPERTIES['t']}" in
                'array') DATABASE_PROPERTIES["f"]+='[]';;
                'object')

                    [[ -n "${DATABASE_PROPERTIES['A']}" ]] && {
                        local FLAG="$(declare -p "${DATABASE_PROPERTIES['A']}" | awk '{sub(/declare -/, ""); print $1}')";
                    }

                    for OPT in $(jq "${DATABASE_PARAMETERS[@]}" "${DATABASE_PROPERTIES["f"]} | keys[]" "${DATABASE_FILE}"); do
                        echo "['${OPT}']='$(jq -r "${DATABASE_PROPERTIES["f"]}.${OPT}" "${DATABASE_FILE}")'";
                    done

                    return 0;;
            esac
        }

        jq "${DATABASE_PARAMETERS[@]}" "${DATABASE_PROPERTIES["f"]}" "${DATABASE_FILE}";
    fi
}