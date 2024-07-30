# # Check if LIB_DIR is already exported, if not, set it to the directory of this script
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function database() {

    # Declare local variables for options and field properties
    local -r DATABASE_FILE="${LIB_DIR}/../etc/db.json";
    local -A DATABASE_PROPERTIES;
    local OPT OPTARG;
    local -i OPTIND;
    local -ai PROCESSES;

   # Parse options passed to the function
    while getopts :f:r: OPT; do
        case ${OPT} in
            f|r) DATABASE_PROPERTIES["${OPT}"]="${OPTARG}";;
        esac
    done

    # Shift positional parameters by the number of options parsed
    shift $((OPTIND - 1));
    DATABASE_PROPERTIES["F"]="$([[ ${DATABASE_PROPERTIES["F"]:0:1} == '.' ]] || printf '.')${DATABASE_PROPERTIES["F"]}";
    DATABASE_PROPERTIES['T']="$(jq -r "${DATABASE_PROPERTIES["F"]} | type" "${DATABASE_FILE}")";
    
    jq --indent 4 --raw-output "${DATABASE_PROPERTIES[F]}" "${DATABASE_FILE}";
echo "${DATABASE_PROPERTIES['T']}"
    return 0;
}

