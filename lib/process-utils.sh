# Creates the LIB_DIR global variable if it does not already exist. Use this variable to access the absolute path of the library directory containing generic scripts.
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function substitution() {

    function cleanup() {
        [[ -p "${FIFO}" ]] && rm "${FIFO}";
        return 0;
    }

    unsetVariables SUBSTITUTION;

    local OPT OPTARG;
    local -i OPTIND;
    local -r FIFO="/tmp/._$(cat /dev/urandom | tr -dc [:alnum:] | head -c 32).fifo";
    local -A DECLARATIONS;
    declare -ag SUBSTITUTION;

    while getopts pu OPT; do
        case ${OPT} in
            p|u) DECLARATIONS["${OPT}"]="true";;
        esac
    done

    shift $((OPTIND - 1));
    trap "cleanup" SIGINT SIGTERM EXIT;
    mkfifo "${FIFO}";
    "${@}" > "${FIFO}" 2> /dev/null &
    mapfile -t SUBSTITUTION < "${FIFO}";

    "${DECLARATIONS["p"]:-false}" && {
        echo ${SUBSTITUTION[@]};
        "${DECLARATIONS["u"]:-false}" && unset SUBSTITUTION;
    }
}

function temporary() {

    local TEMPORARY="/tmp/._$(cat /dev/urandom | tr -dc [:alnum:] | head -c 32).tmp";
    "${@}" > "${TEMPORARY}" 2> /dev/null;
    printf "${TEMPORARY}";

    return 0;
}

function append_path () {
    case ":${PATH}:" in
        *:"${1}":*);;
        *) export PATH="${PATH:+$PATH:}${1}";;
    esac

    return 0;
}

# Defines a function to ensure a value is unique in an indexed array before appending it.
function isUniqueEntry() {

    # Initialize a flag variable and an associative array to store unique properties.
    local OPT OPTARG;
    local -i OPTIND;
    local -A UNIQUE_PROPERTIES;

    # -A: Associative array to check within.
    # -q: Quiet mode; suppresses error messages.
    # -Q: Enables query mode to return the key-value pair.

    # Parse options passed to the function
    while getopts QAq OPT; do
        case ${OPT} in
            Q|A|q) UNIQUE_PROPERTIES["${OPT}"]='true';;
        esac
    done

    # Shift positional parameters by the number of options parsed
    shift $((OPTIND - 1));

    # Retrieve the attributes of the variable passed as the first argument.
    local -r FLAGS="$(declare -p "${1}" 2> /dev/null | awk '{sub(/declare -/, ""); print $1}')";

    [[ -z "${FLAGS}" ]] && {
        "${UNIQUE_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Unintitialized Variable" -c "echo ${1} must be first be intitialized before being passed as an argument." >&2;
        return 11;
    }

    # Check if the first argument (indexed array) is provided.
    if [[ -z ${1} ]]; then
        # If not in quiet mode, inform the user that both an indexed array and a value are required.
        "${UNIQUE_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Parameters Missing" -c "Please provide an indexed array as the first parameter and the value to append as the second." >&2;
        return 1;
    else
        # Check if the second argument (value to append) is provided.
        [[ -n ${2} ]] || {
            # If not in quiet mode, inform the user that a value to append is required.
            "${UNIQUE_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Value Missing" -c "A value is required as the second parameter to append to the array." >&2;
            return 2;
        }

        # Iterate over the flags of the variable to check its attributes.
        for ((OPTIND=0; OPTIND < "${#FLAGS}"; OPTIND++)); do
            case "${FLAGS:${OPTIND}:1}" in
                # If the variable is readonly, inform the user that it cannot be modified.
                r)
                    "${UNIQUE_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Readonly Variable" -c "The array is readonly and cannot be modified." >&2;
                    return 3;;
                # If the variable is integral, check that the value is an integer.
                i) 
                    [[ ${2} =~ ^((-)?[[:digit:]]+)$ ]] || {
                        # If not in quiet mode, inform the user that only integer values can be added.
                        "${UNIQUE_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Non-integer Value" -c "The value '${2}' is not an integer and cannot be added to an integral array." >&2;
                        return 4;
                    };;
                # If the variable is an indexed array, set the 'a' property.
                a) UNIQUE_PROPERTIES["a"]='true';;
                # If the variable is an associative array, inform the user that only indexed arrays are accepted.
                A)
                    "${UNIQUE_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Associative Array" -c "Only indexed arrays are accepted. An associative array was provided." >&2;
                    return 5;;
            esac
        done

        # If the variable is an indexed array, proceed to check for uniqueness.
        if "${UNIQUE_PROPERTIES["a"]:-false}"; then
            # Create a nameref to the indexed array variable.
            local -n REFERENCE="${1}";
            # Check if the value is not already in the array.
            if [[ -z "$(echo -n "${REFERENCE[@]}" | awk -v value="^${2}$" '{ if ($0 ~ value) { print $0 } }')" ]]; then
                # If unique, append the value to the array.
                if "${UNIQUE_PROPERTIES['A']:-false}"; then
                    echo -n "${2}";
                elif "${UNIQUE_PROPERTIES['Q']:-false}"; then 
                    # If in query mode, output the key-value pair.
                    UNIQUE_PROPERTIES['K']="${2}";

                    if [[ -z "$(echo -n "${REFERENCE[@]}" | awk -v value="^(-{1,2})${2}$" '{ if ($0 ~ value) { print $0 } }')" ]]; then
                        echo "-$([[ ${#UNIQUE_PROPERTIES[K]} -gt 1 ]] && echo -n '-')${UNIQUE_PROPERTIES[K]}";
                    else
                        # If not in quiet mode, inform the user that the parameter has already been set.
                        "${UNIQUE_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Duplicate Parameters" -c "The value '-$([[ ${#UNIQUE_PROPERTIES[K]} -gt 1 ]] && echo -n '-')${UNIQUE_PROPERTIES[K]}' already exists in the array and cannot be added again." >&2;
                        return 8;
                    fi
                else
                    REFERENCE+=("${2}");
                fi
            else
                # If not in quiet mode, inform the user that the value is not unique.
                "${UNIQUE_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Duplicate Value" -c "The value '${2}' already exists in the array and cannot be added again." >&2;
                return 7;
            fi
        else
            # If not an indexed array, inform the user of the requirement.
            "${UNIQUE_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Indexed Array Required" -c "The provided variable '${1}' is not an indexed array as required." >&2;
            return 6;
        fi
    fi

    # Return 0 if the function completes successfully.
    return 0;
}

# The isUniqueKey function checks if a key-value pair is unique within an associative array and adds it if it is unique.
function isUniqueKey() {

    # Initialize local variables for options, arguments, and to store properties of uniqueness.
    local OPT OPTARG;
    local -i OPTIND;
    local -A UNIQUE_KEY_PROPERTIES;
    local -a FIELDS;

    # Parse options passed to the function. Options include:
    # -p: Key-value pair to check for uniqueness.
    # -A: Associative array to check within.
    # -q: Quiet mode; suppresses error messages.
    # -Q: Enables query mode to return the key-value pair.
    # -m: Modify mode; allows updating existing keys.

    # Parse options passed to the function
    while getopts :p:A:Qqm OPT; do
        case ${OPT} in
            q|Q|m) UNIQUE_KEY_PROPERTIES["${OPT}"]='true';;
            p|A) UNIQUE_KEY_PROPERTIES["${OPT}"]="${OPTARG}";;
        esac
    done

    # Shift positional parameters by the number of options parsed
    shift $((OPTIND - 1));

    # Use awkFieldManager to split the key-value pair provided with the -p option.
    [[ -n "${UNIQUE_KEY_PROPERTIES["p"]}" ]] && awkFieldManager -d '=' "${UNIQUE_KEY_PROPERTIES["p"]}";

    # Check if a valid key-value pair is provided. If not, display an error message and return with code 1.
    [[ "${#FIELDS[@]}" -ne 2 ]] && {
        "${UNIQUE_KEY_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Key Value Pair Missing" -c "A value is required in the form of 'key=value' for the (-p) option." >&2;
        return 1;
    }

    # Ensure the key is not empty or just whitespace. If it is, display an error message and return with code 2.
    [[ -z "${FIELDS[0]}" || "${FIELDS[0]}" =~ ^[[:space:]]+$ ]] && {
        "${UNIQUE_KEY_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Null Key" -c "You cannot have a key that is empty." >&2;
        return 2;
    }

    # Default to the first positional parameter as the associative array if -A is not provided.
    "${UNIQUE_KEY_PROPERTIES["q"]:-false}" && OPTARG='-q' || unset OPTARG;

    # Default to the first positional parameter as the associative array if -A is not provided.
    UNIQUE_KEY_PROPERTIES["A"]="${UNIQUE_KEY_PROPERTIES["A"]:-${1}}";

    # If no associative array is specified, display an error message and return with code 3.
    [[ -z "${UNIQUE_KEY_PROPERTIES["A"]}" ]] && {
        "${UNIQUE_KEY_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Missing Associative Array" -c "You forgot to specify which associative you wish to modify/add to." >&2;
        return 3;
    }

    [[ -z "$(declare -p "${UNIQUE_KEY_PROPERTIES["A"]}" 2> /dev/null | awk '{sub(/declare -/, ""); print $1}')" ]] && {
        "${UNIQUE_KEY_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Unintitialized Associative Array" -c "echo ${UNIQUE_KEY_PROPERTIES["A"]} must be an intitialized associative array before being passed as an argument." >&2;
        return 11;
    }

    # Get the keys of the associative array using awkIndexer.

    local -a KEYS=($(awkIndexer ${OPTARG} -g 'key' -d "${UNIQUE_KEY_PROPERTIES["A"]}"));

    # Set quiet mode for the isUniqueEntry function if the -m or -q option is provided.
    ("${UNIQUE_KEY_PROPERTIES['m']:-false}" || "${UNIQUE_KEY_PROPERTIES['q']:-false}") && {
        OPTARG='-q';
    } || {
        unset OPTARG;
    }

    # Check if the key is unique using isUniqueEntry. If it is unique or modify mode is enabled, add/update the key-value pair.
    if "${UNIQUE_KEY_PROPERTIES['m']:-false}"; then
        local -n REFERENCE="${UNIQUE_KEY_PROPERTIES["A"]}";

        UNIQUE_KEY_PROPERTIES["K"]="${OPT:-${FIELDS[0]}}";
        REFERENCE["${UNIQUE_KEY_PROPERTIES["K"]}"]="${FIELDS[1]}";

        # If in query mode, output the key-value pair.
        "${UNIQUE_KEY_PROPERTIES['Q']:-false}" && {
            echo "-$([[ ${#UNIQUE_KEY_PROPERTIES[K]} -gt 1 ]] && echo '-')${UNIQUE_KEY_PROPERTIES[K]}" "${REFERENCE[${UNIQUE_KEY_PROPERTIES[K]}]}";
        }
    fi

    # Return success.
    return 0;
}

function typing() {
    local -a TYPING;
    local -A TYPING_PROPERTIES;
    local -i T=0 OPTIND;

    # Parse options passed to the function
    while getopts :m:q OPT; do
        case ${OPT} in
            q) TYPING_PROPERTIES["${OPT}"]="true";;
            m) TYPING_PROPERTIES["${OPT}"]="${OPTARG}";;
        esac
    done

    # Shift positional parameters by the number of options parsed
    shift $((OPTIND - 1));

    local -r FLAGS="$(declare -p "${1}" 2> /dev/null | awk '{sub(/declare -/, ""); print $1}')";

    [[ -z "${FLAGS}" ]] && {
        "${TYPING_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Unintitialized Variable" -c "echo ${1} must be first be intitialized before being passed as an argument." >&2;
        return 1;
    }

    for ((OPTIND=0; OPTIND < "${#FLAGS}"; OPTIND++)); do
        case "${FLAGS:${OPTIND}:1}" in
            a) TYPING+=('a');; # Indexed Array
            A) TYPING+=('A');; # Associative Array
            r) TYPING+=('r');; # readonly
            n) TYPING+=('n');; # Named Reference
            i) TYPING+=('i');; # Integral
            u) TYPING+=('u');; # Upper
            l) TYPING+=('l');; # Lower
            x) TYPING+=('x');; # Exported
        esac
    done

    if "${TYPING_PROPERTIES['m']:-false}"; then
echo
#        awkFieldManager -
    else
        echo "${TYPING[@]}";
    fi

    return 0;
}