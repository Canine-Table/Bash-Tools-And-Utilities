# Creates the LIB_DIR global variable if it does not already exist. Use this variable to access the absolute path of the library directory containing generic scripts.
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

awkIndexQuerier() {

    # Declare local variables
    local OPT OPTARG;
    local -i OPTIND;
    local -A INDEX_QUERIER_PROPERTIES;

    # Parse command-line options
    while getopts :A:R:Q:F:q OPT; do
        case ${OPT} in
            q)  INDEX_QUERIER_PROPERTIES["${OPT}"]='true';;
            A|R|F) INDEX_QUERIER_PROPERTIES["${OPT}"]="${OPTARG}";;
            Q)  INDEX_QUERIER_PROPERTIES["${OPT}"]="$(awkParameterCompletion -s "${OPTARG}" 'keys' 'values' 'both')";;
        esac
    done

    # Shift positional parameters
    shift $((OPTIND - 1));

    # If 'A' property is not set
    [[ -z "${INDEX_QUERIER_PROPERTIES["A"]}" ]] && {
        if [[ -n "${1}" ]]; then
            # If there is a positional parameter, set 'A' property to it and shift positional parameters
            INDEX_QUERIER_PROPERTIES["A"]="${1}";
            shift;
        else
            # If there is no positional parameter, print an error message and return 2
            "${INDEX_QUERIER_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Parameters Missing (-A) or (-a)" -c "Please provide either an associative array (-A) or an indexed array (-a) to use this function." >&2;
            return 2;
        fi
    }
    
    {
        declarationQuery -q -m 'A' "${INDEX_QUERIER_PROPERTIES["A"]}" || declarationQuery -q -m 'a' "${INDEX_QUERIER_PROPERTIES["A"]}"
    } || {
        "${INDEX_QUERIER_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Unintitialized Variable of a Valid Type" -c "${INDEX_QUERIER_PROPERTIES["A"]} must be either an associative array (-A) or an indexed array (-a) for this function to work." >&2;
        return 16;
    }

    declare -p "${INDEX_QUERIER_PROPERTIES["A"]}" | awk \
        -v query="${INDEX_QUERIER_PROPERTIES["Q"]:-both}" \
        -v index_range="${INDEX_QUERIER_PROPERTIES["R"]}" \
        -v find_match="${INDEX_QUERIER_PROPERTIES["F"]}" \
        -f "${LIB_DIR}/awk-lib/option-manager.awk";

    return 0;
}

function awkGetOptions() {

    # Declare local variables
    local OPT OPTARG;
    local -i OPTIND;
    local -A GET_OPTIONS_PROPERTIES;

    # (-N) kwargs can be nullable
    # (-U) unique kwargs are no longer required
    # (-O) the formated option string passed to thi function for processing
    # (-A) specify an action
    # (-q) quiet mode
    # (-I) inform of empty field in the option string rather than just skipping that option.
    # Parse command-line options
    while getopts :O:Q:A:F:qNUMI OPT; do
        case ${OPT} in
            q|N|U|M|I) GET_OPTIONS_PROPERTIES["${OPT}"]='true';;
            O) GET_OPTIONS_PROPERTIES["${OPT}"]="${OPTARG}";;
            Q) GET_OPTIONS_PROPERTIES["${OPT}"]="$(awkParameterCompletion -s "${OPTARG}" 'single' 'double' 'tick' 'none')";;
            F) GET_OPTIONS_PROPERTIES["${OPT}"]="$(awkParameterCompletion -s "${OPTARG}" 'long' 'short' 'none')";;
            A) GET_OPTIONS_PROPERTIES["${OPT}"]="$(awkParameterCompletion -s "${OPTARG}" 'skip' 'exit')";;
        esac
    done

    # Shift positional parameters
    shift $((OPTIND - 1));

    # Check if -O option is provided
    [[ -z "${GET_OPTIONS_PROPERTIES["O"]}" ]] && {
        if [[ -n "${1}" ]]; then
            GET_OPTIONS_PROPERTIES["O"]="${1}";
            shift;
        else
            "${GET_OPTIONS_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Missing Options" -c "Please provide (-O) options to process." >&2;
            return 1;
        fi
    }

    # Check if arguments are provided
    [[ -z "${@}" ]] && {
        "${GET_OPTIONS_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Missing Arguments" -c "Please provide arguments to process." >&2;
        return 2;
    }
    
    # Prepare arguments and invoke AWK script
    OPTARG="$(echo -en "${@/#/'EOL\n'}" | tail -n "${#@}" | awk \
        -v options="${GET_OPTIONS_PROPERTIES["O"]}" \
        -v flag_style="${GET_OPTIONS_PROPERTIES['F']}" \
        -v quote_values="${GET_OPTIONS_PROPERTIES['Q']}" \
        -v nullable="${GET_OPTIONS_PROPERTIES['N']}" \
        -v flag_style_action="${GET_OPTIONS_PROPERTIES['A']}" \
        -v flag_style_must_match="${GET_OPTIONS_PROPERTIES['M']}" \
        -v inform_of_empty_flag="${GET_OPTIONS_PROPERTIES['I']}" \
        -v unique_not_required="${GET_OPTIONS_PROPERTIES['U']}" \
        -f "${LIB_DIR}/awk-lib/get-options.awk")" || case $? in

        # Handle error codes from AWK script
        15)
            "${GET_OPTIONS_PROPERTIES["q"]:-false}" || awkDynamicBorders -d "█" -l "Default Value Required" -c "The following parameter ${OPTARG} requires a default value specified by the (Mandatory=true) argument you passed for this parameter." >&2;
            return 15;;
        16)
            "${GET_OPTIONS_PROPERTIES["q"]:-false}" || awkDynamicBorders -d "█" -l "Flag Style Mismatch" -c "The following flags did not meet the prerequisites of a '${GET_OPTIONS_PROPERTIES['F']}' option: ${OPTARG}" >&2;
            return 16;;
        17)
            "${GET_OPTIONS_PROPERTIES["q"]:-false}" || awkDynamicBorders  -l "Empty Flag Detected" -c "An empty ${OPTARG} was not detected from (-O) before the specifier option." >&2;
            return 17;;
    esac

    # Print the output from AWK script
    echo -n "${OPTARG}";

    return 0;
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
                FIELD_PROPERTIES["${OPT}"]="${QUOTES[${MATCHES[0]}]}";
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

# The awkParameterCompletion function generates autocompletion suggestions based on a provided string and a list of options, utilizing an external awk script for processing.
function awkParameterCompletion() {
    # Declare local variables for options and field properties
    local OPT OPTARG;
    local -i OPTIND;
    local -A COMPLETION_PROPERTIES;
    
    # Parse options passed to the function
    while getopts :D:d:P:A:s:q OPT; do
        case ${OPT} in
            q) 
                # Set the 'q' option in the COMPLETION_PROPERTIES associative array to 'true'
                COMPLETION_PROPERTIES["${OPT}"]='true';;
            D|d|P|s|A) 
                # Set the respective option in the COMPLETION_PROPERTIES associative array to the argument value
                COMPLETION_PROPERTIES["${OPT}"]="${OPTARG}";;
        esac
    done
    
    # Shift off the options from the positional parameters.
    shift $((OPTIND - 1));
    
    # If the 'A' option is set and the 's' option is not set, check if the 'A' option is an associative array or an indexed array
    [[ -n "${COMPLETION_PROPERTIES["A"]}" && -z "${COMPLETION_PROPERTIES["s"]}" ]] && {
        declarationQuery -q -m 'A' -n 'r' "${COMPLETION_PROPERTIES["A"]}" && COMPLETION_PROPERTIES["F"]='associative';
        declarationQuery -q -m 'a' -n 'r' "${COMPLETION_PROPERTIES["A"]}" && COMPLETION_PROPERTIES["F"]='indexed';
    }
    
    # If the 'P' option is not set, check if there are any positional parameters. If there are, set the 'P' option to the positional parameters.
    # If there are no positional parameters, print an error message and return with code 1
    [[ -z "${COMPLETION_PROPERTIES["P"]}" ]] && if [[ -n "${@}" ]]; then
        COMPLETION_PROPERTIES["P"]="${*}";
    else
        "${COMPLETION_PROPERTIES["q"]:-false}" || awkDynamicBorders -l 'Missing Parameters' -c "You must provide parameters" >&2;
        return 1;
    fi
    
    # Call the AWK function with the options set in the COMPLETION_PROPERTIES associative array
    OPTARG="$(awk \
        -v parameters="${COMPLETION_PROPERTIES['P']}" \
        -v string="${COMPLETION_PROPERTIES['s']}" \
        -v delimiter="${COMPLETION_PROPERTIES['d']:- }" \
        -v parameter_delimiter="${COMPLETION_PROPERTIES['D']:-,}" \
        -v formating="${COMPLETION_PROPERTIES["F"]}" \
        -f "${LIB_DIR}/awk-lib/parameter-completion.awk")" || case $? in

        2)
            # If the AWK function returns with code 2, print an error message and return with code 2
            "${COMPLETION_PROPERTIES["q"]:-false}" || awkDynamicBorders -d "█" -l "No Matching Parameter Found" -c "${OPTARG}" >&2;
            return 2;;
        3)
            # If the AWK function returns with code 3, print an error message and return with code 3
            "${COMPLETION_PROPERTIES["q"]:-false}" || awkDynamicBorders -d "█" -l "Too Many Matches Found" -c "${OPTARG}" >&2;
            return 3;;
    esac
    
    # If the 'F' option is set, assign the output of the AWK function to the 'A' option in the COMPLETION_PROPERTIES associative array
    # If the 'F' option is not set, print the output of the AWK function
    if [[ -n "${COMPLETION_PROPERTIES["F"]}" ]]; then
        eval "${COMPLETION_PROPERTIES["A"]}=($(echo -n "${OPTARG}"))";
    else
        echo -n "${OPTARG}";
    fi
    
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
