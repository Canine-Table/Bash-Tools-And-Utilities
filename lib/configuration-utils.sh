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

   # Parse options passed to the function
    while getopts :c:f:rq OPT; do
        case ${OPT} in
        r) DATABASE_PARAMETERS=(${DATABASE_PARAMETERS[@]} "$(isUniqueEntry -qQ DATABASE_PARAMETERS "${OPT}")");;
        c|f) DATABASE_PROPERTIES["${OPT}"]="${OPTARG}";;
        q) DATABASE_PROPERTIES["${OPT}"]='true';;
        esac
    done

    # Shift positional parameters by the number of options parsed
    shift $((OPTIND - 1));

    jq "${DATABASE_PARAMETERS[@]}" "${DATABASE_PROPERTIES["f"]:-.}" "${DATABASE_FILE}";
}