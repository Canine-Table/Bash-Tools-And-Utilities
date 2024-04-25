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
    if [[ -z "${1}" ]]; then
        # If not in quiet mode, inform the user that both an indexed array and a value are required.
        "${UNIQUE_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Parameters Missing" -c "Please provide an indexed array as the first parameter and the value to append as the second." >&2;
        return 1;
    else
        # Check if the second argument (value to append) is provided.
        [[ -n "${2}" ]] || {
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
            if ! echo -n "${REFERENCE[@]}" | grep -q "\(\b${2}\b\)"; then

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

# Function to ensure a key-value pair is unique within an associative array.
function isUniqueKey() {
    # Define local variables for options, arguments, and uniqueness properties.
    local OPT OPTARG;
    local -i OPTIND;
    local -A UNIQUE_KEY_PROPERTIES;
    local -a FIELDS;

    # Parse options: -p for key-value pair, -A for array, -q for quiet, -Q for query, -m for modify.
    while getopts :p:A:Qqm OPT; do
        case ${OPT} in
            q|Q|m) UNIQUE_KEY_PROPERTIES["${OPT}"]='true';;
            p|A) UNIQUE_KEY_PROPERTIES["${OPT}"]="${OPTARG}";;
        esac
    done

    # Shift off the options from the positional parameters.
    shift $((OPTIND - 1));

    # Split the key-value pair using awkFieldManager.
    [[ -n "${UNIQUE_KEY_PROPERTIES["p"]}" ]] && awkFieldManager -d '=' "${UNIQUE_KEY_PROPERTIES["p"]}";

    # Validate the key-value pair format.
    [[ "${#FIELDS[@]}" -ne 2 ]] && {
        "${UNIQUE_KEY_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Key Value Pair Missing" -c "Format 'key=value' required for -p option." >&2;
        return 1;
    }

    # Ensure the key is not empty.
    [[ -z "${FIELDS[0]}" || "${FIELDS[0]}" =~ ^[[:space:]]+$ ]] && {
        "${UNIQUE_KEY_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Null Key" -c "Key cannot be empty." >&2;
        return 2;
    }

    # Set the default associative array if -A is not provided.
    UNIQUE_KEY_PROPERTIES["A"]="${UNIQUE_KEY_PROPERTIES["A"]:-${1}}";

    # Check if the associative array is specified and initialized.
    [[ -z "${UNIQUE_KEY_PROPERTIES["A"]}" ]] && {
        "${UNIQUE_KEY_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Missing Associative Array" -c "Specify which associative array to modify/add to." >&2;
        return 3;
    }

    # Verify the associative array is initialized.
    [[ -z "$(declare -p "${UNIQUE_KEY_PROPERTIES["A"]}" 2> /dev/null | awk '{sub(/declare -/, ""); print $1}')" ]] && {
        "${UNIQUE_KEY_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Unintitialized Associative Array" -c "echo ${UNIQUE_KEY_PROPERTIES["A"]} must be initialized before use." >&2;
        return 11;
    }

    # Retrieve the keys of the associative array.
    local -a KEYS=($(awkIndexer ${OPTARG} -g 'key' -d "${UNIQUE_KEY_PROPERTIES["A"]}"));

    # Set quiet mode for isUniqueEntry if -m or -q is provided.
    ("${UNIQUE_KEY_PROPERTIES['m']:-false}" || "${UNIQUE_KEY_PROPERTIES['q']:-false}") && {
        OPTARG='-q';
    } || {
        OPTARG="";
    }

    # Add/update the key-value pair if it's unique or if modify mode is enabled.
    if "${UNIQUE_KEY_PROPERTIES['m']:-false}" || $(isUniqueEntry ${OPTARG} KEYS "${FIELDS[0]}"); then
        local -n REFERENCE="${UNIQUE_KEY_PROPERTIES["A"]}";

        UNIQUE_KEY_PROPERTIES["K"]="${FIELDS[0]}";
        REFERENCE["${UNIQUE_KEY_PROPERTIES["K"]}"]="${FIELDS[1]}";

        # Output the key-value pair in query mode.
        "${UNIQUE_KEY_PROPERTIES['Q']:-false}" && {
            echo "-$([[ ${#UNIQUE_KEY_PROPERTIES[K]} -gt 1 ]] && echo '-')${UNIQUE_KEY_PROPERTIES[K]}" "${REFERENCE[${UNIQUE_KEY_PROPERTIES[K]}]}";
        }
    fi

    # Success.
    return 0;
}

# Function to query the declaration of variables or functions
function declarationQuery() {
    # Declare local variables for options and their arguments, typing array and properties associative array, and option index
    local OPT OPTARG;
    local -a TYPING;
    local -A TYPING_PROPERTIES;
    local -i OPTIND;

    # Parse options passed to the function (-n, -m, -q)
    while getopts :n:m:qp OPT; do
        case ${OPT} in
            p|q) TYPING_PROPERTIES["${OPT}"]="true";; # Quiet mode, suppress error messages
            n|m) TYPING_PROPERTIES["${OPT}"]="${OPTARG}";; # Name or match specific flags
        esac
    done

    # Shift positional parameters by the number of options parsed
    shift $((OPTIND - 1));

    # Check if the first argument is empty or if the function name is not declared
    if [[ -z "${1}" ]]; then
        # If quiet mode is not set, print error message and return error code 1
        "${TYPING_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Unspecified Variable" -c "You must provide a variable name to type check." >&2;
        return 1;
    elif [[ -z "$(declare -F "${1}")" ]]; then
        # Get the flags of the variable if it's not a function
        local -r FLAGS="$(declare -p "${1}" 2> /dev/null | awk '{sub(/declare -/, ""); print $1}')";
    else
        # If it's a function, set the flag to 'f'
        local -r FLAGS='f';
    fi

    # If FLAGS is empty, print error message and return error code 2
    [[ -z "${FLAGS}" ]] && {
        "${TYPING_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Unintitialized Variable" -c "echo ${1} must first be intitialized before being passed as an argument." >&2;
        return 2;
    }

    # Iterate over each character in FLAGS and add to TYPING array
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
            f) TYPING+=('f');; # Function
        esac
    done

    # If 'n' or 'm' options are set, process the flags
    if  [[ -n "${TYPING_PROPERTIES['n']}" || -n "${TYPING_PROPERTIES['m']}" ]]; then
        local -a FIELDS;

        # Function to manage declaration flags
        function declarationFlags() {
            awkFieldManager "${1}";

            # Build a regex pattern for the flags
            for OPT in "${FIELDS[@]}"; do
                [[ ${OPT} =~ ^(f|a|A|r|n|i|u|l|x)$ ]] && OPTARG+="(?=.*\b${OPT}\b)";
            done

            echo -n "${OPTARG}";
            OPTARG="";
            OPT="";
            unset FIELDS;

            return 0;
        }

        # Check if all 'm' flags are present
        [[ -n "${TYPING_PROPERTIES['m']}" ]] && {
            if ! echo -n "${TYPING[@]}" | grep -qP $(declarationFlags "${TYPING_PROPERTIES['m']}"); then
                # If quiet mode is not set, print error message and set error code 16
                "${TYPING_PROPERTIES["q"]:-false}" || awkDynamicBorders -d '█' -l "Flags Not Found" -c "The ${1} variable does not contain all the flags in '${TYPING_PROPERTIES[m]}'." >&2;
                TYPING_PROPERTIES['M']=16;
            fi
        }

        # Check if any 'n' flags are present
        [[ -n "${TYPING_PROPERTIES['n']}" ]] && {
            if echo -n "${TYPING[@]}" | grep -qP $(declarationFlags "${TYPING_PROPERTIES['n']}"); then
                # If quiet mode is not set, print error message and set error code 32
                "${TYPING_PROPERTIES["q"]:-false}" || awkDynamicBorders  -d '█' -l "Flags Found" -c "The ${1} variable contains 1 or more of the following flags '${TYPING_PROPERTIES[n]}' flags." >&2;
                TYPING_PROPERTIES['N']=32;
            fi
        }
    fi

    # Return the sum of error codes
    "${TYPING_PROPERTIES['p']:-false}" && echo -n "${TYPING[@]}";
    return $((0 + "${TYPING_PROPERTIES['N']:-0}" + "${TYPING_PROPERTIES['M']:-0}"));
}
