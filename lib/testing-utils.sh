# # Check if LIB_DIR is already exported, if not, set it to the directory of this script
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function database() {

    # Declare local variables for options and field properties
    local -r DATABASE_FILE="${LIB_DIR}/../etc/db.json";
    local -A DATABASE_PROPERTIES;
    local OPT OPTARG PLACEHOLDER;
    local -i OPTIND;
    local -A VALUES FIELDS;

   # Parse options passed to the function
    while getopts :F:R: OPT; do
        case ${OPT} in
            F) DATABASE_PROPERTIES["${OPT}"]="${OPTARG}";;
            R) ;;
        esac
    done

    # Shift positional parameters by the number of options parsed
    shift $((OPTIND - 1));

    DATABASE_PROPERTIES["F"]="$([[ ${DATABASE_PROPERTIES["F"]:0:1} == '.' ]] || printf '.')${DATABASE_PROPERTIES["F"]}";

    function _changeRoot() {
        local OPT OPTARG;
        local -i OPTIND;
        local -A CHANGE_ROOT_PROPERTIES

        # Parse options passed to the function
        while getopts :T:R:P: OPT; do
            case ${OPT} in
                T|R|P) CHANGE_ROOT_PROPERTIES["${OPT}"]="${OPTARG}";;
            esac
        done

        # Shift positional parameters by the number of options parsed
        shift $((OPTIND - 1));

        case "${CHANGE_ROOT_PROPERTIES["T"]}" in
            'string')
                echo "${CHANGE_ROOT_PROPERTIES[R]}"
                return 1;;
            'number')
                echo "${CHANGE_ROOT_PROPERTIES[R]}";
                return 2;;
            'object') 
                for OPT in $(jq --indent 4 -r "${CHANGE_ROOT_PROPERTIES[R]} | keys[]" "${DATABASE_FILE}"); do
                    echo "${OPT} is an ${CHANGE_ROOT_PROPERTIES["T"]}";
                    OPTARG="$(jq --indent 4 -r "${CHANGE_ROOT_PROPERTIES[R]}${OPT}" "${DATABASE_FILE}")";
 
                   _changeRoot \
                        -T "$(jq --indent 4 -r "${OPTARG} | type" "${DATABASE_FILE}")" \
                        -R  "${OPTARG}" \
                        -P "${CHANGE_ROOT_PROPERTIES[R]}";
                done
                return 3;;
            'array')
 
                for OPT in $(jq --indent 4 -r "${CHANGE_ROOT_PROPERTIES[R]} | keys[]" "${DATABASE_FILE}"); do
                    ! [[ "${OPT}" =~ ((\[|\])(,)?) ]] && {
                       OPTARG="$(jq --indent 4 -r "${CHANGE_ROOT_PROPERTIES[R]}[$OPT]" "${DATABASE_FILE}")";

                        _changeRoot \
                            -T "$(jq -r "${CHANGE_ROOT_PROPERTIES[R]}[${OPT}] | type" "${DATABASE_FILE}")" \
                            -R  "${OPTARG}";
                    }
                done ;
                return 4;;
            'boolean')
                echo "${CHANGE_ROOT_PROPERTIES[R]}";
                return 5;;
            'null') 
                echo "Value is ${CHANGE_ROOT_PROPERTIES["T"]}"
                return 6;;
        esac

        return 0;
    }

    _changeRoot \
        -T "$(jq --indent 4 -r "${DATABASE_PROPERTIES["F"]} | type" "${DATABASE_FILE}")" \
        -R "${DATABASE_PROPERTIES["F"]}";

    return 0;
}

