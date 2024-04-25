# Creates the LIB_DIR global variable if it does not already exist. Use this variable to access the absolute path of the library directory containing generic scripts.
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

# The awkIndexer function processes arrays and associative arrays using awk by validating data types, parsing options, and fetching indexes based on provided parameters.
function awkIndexer() {

    # Declare local variables for options and field properties
    local OPT OPTARG DATA;
    local -i OPTIND;
    local -A INDEXER_PROPERTIES;

    # Nested function to check if the data type is valid
    function dataTypeChecker() {
        # Check the type of the variable passed as an argument
        INDEXER_PROPERTIES["${OPT}"]="$(declarationQuery -p -n 'r' "${OPTARG}" | grep -o '\(A\|a\)')" || INDEXER_PROPERTIES["E"]='true';

        # Extract the data from the variable passed as an argument
        DATA="$(declare -p "${OPTARG}" | awk -v variable="declare -.* ${OPTARG}=" '{sub(variable, ""); print $0}')";
        return 0;
    }

   # Parse options passed to the function
    while getopts :g:d:i:q OPT; do
        case ${OPT} in
            d) [[ -n "${OPTARG}" ]] && dataTypeChecker;; # Check data type
            i) [[ ${OPTARG} =~ ^[[:digit:]]*:[[:digit:]]*:[[:digit:]]*$ ]] && INDEXER_PROPERTIES["${OPT}"]="${OPTARG}" ;; # Set index range if it matches the pattern
            q) INDEXER_PROPERTIES["${OPT}"]='true';;
            g) INDEXER_PROPERTIES["${OPT}"]="$(awkCompletion -s "${OPTARG}" 'key' 'value')" ;; # Get key or value for indexing (defaults to both)
        esac
    done

    # Shift positional parameters by the number of options parsed
    shift $((OPTIND - 1));

    "${INDEXER_PROPERTIES["E"]:-false}" && {
        "${INDEXER_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Invalid Variable Type" -c "The variable type must be either an array (-a) or an associative array (-A)." >&2;
        return 1; # If neither, return an error
    }

    # Check if data was actually passed to the function
    if ! awk -v array="${DATA}" -v key_or_value="${INDEXER_PROPERTIES['g']}" -v index_range="${INDEXER_PROPERTIES["i"]:-0::1}" -f "${LIB_DIR}/awk-lib/awk-utils.awk" -f "${LIB_DIR}/awk-lib/indexer.awk"; then
        "${INDEXER_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Uninitialized or Missing Array" -c "Please provide an array (-a) or an associative array (-A) with at least 1 index." >&2;
        return 2;
    fi

    return 0; # Return success if everything is fine
}

# The awkCompletion function generates autocompletion suggestions based on a provided string and a list of options, utilizing an external awk script for processing.
function awkCompletion() {

    # Declare local variables for options and field properties
    local OPT OPTARG LIST;
    local -i OPTIND;
    local -a COMPLETION;
    local -A COMPLETION_PROPERTIES CHOICES;
    local -r FIFO="/tmp/._$(cat /dev/urandom | tr -dc [:alnum:] | head -c 32).fifo";

   # Parse options passed to the function
    while getopts :s:S:L:q OPT; do
        case ${OPT} in
        s|S|E|L) COMPLETION_PROPERTIES["${OPT}"]="${OPTARG}";;
        q) COMPLETION_PROPERTIES["${OPT}"]='true';;
        esac
    done

    # Shift positional parameters by the number of options parsed
    shift $((OPTIND - 1));

    # Check if the 's' option is set, otherwise use the first positional parameter as the string to match
    [[ -z "${COMPLETION_PROPERTIES["s"]}" ]] && if [[ -n "${@}" ]]; then
        COMPLETION_PROPERTIES["s"]="${1}";
        shift;
    else
        # If neither is provided, print an error message and return with code 1
        ! "${COMPLETION_PROPERTIES["q"]:-false}" && awkDynamicBorders -l 'Missing String' -c "echo ${COMPLETION_PROPERTIES["S"]:-"Please provide a string to match with for the list of options."}" >&2;
        return 1;
    fi

    [[ -z "${@}" ]] && {
        # If no list is provided, print an error message and return with code 2
        ! "${COMPLETION_PROPERTIES["q"]:-false}" && awkDynamicBorders -l 'Missing List' -c "echo ${COMPLETION_PROPERTIES["L"]:-"Please provide a list of options to choose from."}" >&2;
        return 2;
    }

    for OPT in "${@}"; do
        awkFieldManager "${OPT}";

        # Process each option in the list to build a completion list and a map of choices
        if [[ "${#FIELDS[@]}" -gt 0 ]]; then
            LIST+=",${FIELDS[1]:-"${FIELDS[0]}"}";
            CHOICES["${FIELDS[1]:-"${FIELDS[0]}"}"]="${FIELDS[0]}";
        fi
    done

    # Create a named pipe (FIFO) and use awk to filter the completion list
    mkfifo "${FIFO}";
    awkFieldManager -pu "${LIST:1}" | awk -f "${LIB_DIR}/awk-lib/completion.awk" > "${FIFO}" 2> /dev/null &
    mapfile -t COMPLETION < "${FIFO}";
    [[ -p "${FIFO}" ]] && rm "${FIFO}";

    LIST="";

    for OPT in "${COMPLETION[@]}"; do
        awkFieldManager "${OPT}";
        LIST+="█${FIELDS[0]}";

        if [[ ${COMPLETION_PROPERTIES["s"],,} =~ ${FIELDS[1],,} ]]; then
            printf "${CHOICES["${FIELDS[0]}"]}"
            COMPLETION_PROPERTIES["matched"]="true";
            break;
        fi
    done

    # If no match is found, print an error message and return with code 3
    "${COMPLETION_PROPERTIES["matched"]:-false}" || {
        "${COMPLETION_PROPERTIES["q"]:-false}" || awkDynamicBorders -d '█' -l 'No Match Found' -c "\"${COMPLETION_PROPERTIES["E"]:-"${COMPLETION_PROPERTIES["s"]}\" did not match any of the following options: ${LIST}"}" >&2;
        return 3;
    }

    return 0;
}

# Defines a function to display borders around text dynamically using AWK
function awkDynamicBorders() {

    # Declare local variables for options and field properties
    local OPT OPTARG;
    local -i OPTIND;
    local -A BORDER_PROPERTIES;
    local -a PAGES PARAMETERS;

   function setCommands() {
        awkFieldManager -d "${BORDER_PROPERTIES['d']:-,}" "${OPTARG}";
        PAGES+=("${FIELDS[@]}");
        return 0;
    }

    function borderStyle() {

        local S;
        local -a MATCHES;

        # Loop through styles and find a using an AWK script
        for S in 'single' 'double'; do
            MATCHES=($(printf "${S}" | awk -f "${LIB_DIR}/awk-lib/completion.awk" | tr ',' '\n'));

            # If a match is found, set the quote type in BORDER_PROPERTIES
            [[ ${OPTARG} =~ ${MATCHES[1]} ]] && {
                BORDER_PROPERTIES["${OPT}"]="${MATCHES[0]}";
                return 0;
            }
        done

        BORDER_PROPERTIES["${OPT}"]="${OPTARG}";
        # Return 1 if no match is found
        return 1;
    }

   # Parse options passed to the function
    while getopts :s:d:l:c:C:W OPT; do
        case ${OPT} in
            s) borderStyle;; # Set border style
            c) setCommands;; # Set display fields
            l) BORDER_PROPERTIES["${OPT}"]="${OPTARG}";; # Set label
            d) BORDER_PROPERTIES["${OPT}"]="${OPTARG}";;
            C) [[ ${OPTARG} =~ ^[[:digit:]]+$ && "${OPTARG}" -gt 6 && "${OPTARG}" -lt "$(tput cols)" ]] && BORDER_PROPERTIES["${OPT}"]="${OPTARG}";; # Set column width if within valid range
            W) BORDER_PROPERTIES["${OPT}"]='true';; # Enable word wrapping
        esac
    done

    # Shift positional parameters by the number of options parsed
    shift $((OPTIND - 1));

    if [[ -n "${PAGES[@]}" ]]; then

        # Apply border properties to the display content
        for ((OPTIND=0; OPTIND < "${#PAGES[@]}"; OPTIND++)); do

            # Set header label or enable header
            if [[ "${OPTIND}" -eq 0 ]]; then
                if [[ -n "${BORDER_PROPERTIES["l"]}" ]]; then
                    PARAMETERS+=('-v' "label=${BORDER_PROPERTIES["l"]}");
                else
                    PARAMETERS+=("-v" "header=true");
                fi
            fi

            # Enable footer for the last display item
            [[ "$((OPTIND + 1))" -eq "${#PAGES[@]}" ]] && PARAMETERS+=("-v" "footer=true");

            # Apply word wrapping if enabled
            "${BORDER_PROPERTIES["W"]:-false}" && PARAMETERS+=("-v" "wordWrap=${BORDER_PROPERTIES["W"]}");

            # Process command output or file content
            if command -v "$(printf "${PAGES["${OPTIND}"]}" | cut -d ' ' -f 1)" &> '/dev/null'; then
                PAGES["${OPTIND}"]="$(eval "${PAGES["${OPTIND}"]}")";
            elif [[ -f "${PAGES["${OPTIND}"]}" && -r "${PAGES["${OPTIND}"]}" ]]; then
                PAGES["${OPTIND}"]="$(cat "${PAGES["${OPTIND}"]}")";
            fi

            # Apply the dynamic border using AWK
            echo -en "${PAGES["${OPTIND}"]}" | awk "${PARAMETERS[@]}" \
                -v style="${BORDER_PROPERTIES['s']:-single}" \
                -v columns="${BORDER_PROPERTIES['C']:-$(tput cols)}" \
                -f "${BIN_DIR}/../lib/awk-lib/awk-utils.awk" \
                -f "${BIN_DIR}/../lib/awk-lib/dynamic-border.awk" 2> '/dev/null';

            # Reset parameters for the next iteration
            [[ -n "${PARAMETERS[@]}" ]] && unset PARAMETERS;
        done
    fi

    return 0; # Indicate successful execution
}

# Defines a function to manage fields using AWK
function awkFieldManager() {

    # Call a function to unset the global FIELDS variables
    unsetVariables FIELDS;

    # Declare local variables for options and field properties
    local OPT OPTARG;
    local -i OPTIND;
    local -A FIELD_PROPERTIES;
    declare -ag FIELDS;

    # Create a unique FIFO (named pipe) for inter-process communication
    local FIFO="/tmp/._$(cat /dev/urandom | tr -dc [:alnum:] | head -c 32).fifo";

    # Define a function to determine the type of quotes to use
    function quotes() {
        
        local Q="";
        local -a MATCHES;

        # Initialize a variable for quote type
        local -A QUOTES=(
            ["single"]="\'"
            ["double"]="\""
        );

        # Loop through quote types and find matches using an AWK script
        for Q in "${!QUOTES[@]}"; do
            MATCHES=($(printf "${Q}" | awk -f "${LIB_DIR}/awk-lib/completion.awk" | tr ',' '\n'));

            # If a match is found, set the quote type in FIELD_PROPERTIES
            [[ ${OPTARG} =~ ${MATCHES[1]} ]] && {
                FIELD_PROPERTIES["${OPT}"]="${QUOTES["${MATCHES[0]}"]}";
                return 0;
            }
        done

        # Return 1 if no match is found
        return 1;
    }

    # Parse options passed to the function
    while getopts :s:d:q:nkpu OPT; do
        case ${OPT} in
            q) quotes;; # Call quotes function for quote type
            s|d) FIELD_PROPERTIES["${OPT}"]="${OPTARG}";; # Set separator or delimiter
            n|p|u) FIELD_PROPERTIES["${OPT}"]='true';; # Set flags for numbering, printing, or unsetting
            k) FIELD_PROPERTIES["${OPT}"]='false';; # Set flag to keep the FIFO
        esac
    done

    # Shift positional parameters by the number of options parsed
    shift $((OPTIND - 1));

    # Create the FIFO
    mkfifo "${FIFO}";

    # Send input to AWK script and redirect output to FIFO
    echo -en "${@}" | awk \
        -v separator="${FIELD_PROPERTIES['s']}" \
        -v delimiter="${FIELD_PROPERTIES['d']}" \
        -v quote="${FIELD_PROPERTIES['q']}" \
        -f "${LIB_DIR}/awk-lib/field-manager.awk" 2> /dev/null 1> "${FIFO}" &

    # Read the processed fields from FIFO into the FIELDS array
    mapfile -t FIELDS < "${FIFO}";
    OPTIND=0;

    # Remove the FIFO if the 'k' (keep) option is not set
    [[ -p "${FIFO}" && ${FIELD_PROPERTIES['k']:-true} ]] && rm "${FIFO}";

    # If 'p' (print) option is set, print the fields
    "${FIELD_PROPERTIES['p']:-false}" && for OPT in "${FIELDS[@]}"; do
        printf "$("${FIELD_PROPERTIES["n"]:-false}" && echo "${OPTIND}) ")${OPT}$([[ "${OPTIND}" -lt "$((${#FIELDS[@]} - 1))" && -z "${FIELD_PROPERTIES['s']}" ]] && echo "\n")";
        OPTIND=$((OPTIND + 1));
    done

    # If 'p' (print) and 'u' (unset) options are set, unset the FIELDS array
    "${FIELD_PROPERTIES['p']:-false}" && "${FIELD_PROPERTIES['u']:-false}" && unset FIELDS;

    # Return success
    return 0;
}