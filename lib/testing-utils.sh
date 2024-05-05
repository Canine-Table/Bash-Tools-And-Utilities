# Check if LIB_DIR is already exported, if not, set it to the directory of this script
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function _systemctlInit() {

    [[ "${FUNCNAME[1]}" != 'initSystem' ]] && {
        awkDynamicBorders -l "Usage Error" -c "Please use the initSystem function instead of using _systemctlInit directly." >&2;
        return 1;
    }

    # Declare local variables for options and field properties

    # Shift positional parameters by the number of options parsed
    #shift $((OPTIND - 1));

    #"${INIT_PROPERTIES['t']}"

#    systemctl status ${INIT_PROPERTIES['s']}

    return 0;
}

awkArrayQuerier() {


    return 0;
}

# function optionParser() {
#     # Variables for options and arguments
#     local OPT OPTARG ARGUMENT;  
#     # Index of the next argument to be processed
#     local -i OPTIND;  
#     # Associative array for parser properties
#     local -A PARSER_PROPERTIES;  
#     # Array for parameters
#     local -a PARAMETERS;  

#     # Loop over options
#     while getopts :A:a:qp OPT; do  
#         # Switch case for options
#         case ${OPT} in  
#             # Set 'q' or 'p' property to true
#             q|p) PARSER_PROPERTIES["${OPT}"]="true";;
#             # Set 'a' or 'A' property to the option argument
#             a|A) PARSER_PROPERTIES["${OPT}"]="${OPTARG}";;  
#         esac
#     done

#     # Shift positional parameters
#     shift $((OPTIND - 1));  

#     # If 'A' property is not set
#     [[ -z "${PARSER_PROPERTIES["A"]}" ]] && {  
#         if [[ -n "${1}" ]]; then  
#             # Set 'A' property to it and shift positional parameters
#             PARSER_PROPERTIES["A"]="${1}";
#             shift;
#         else
#             # If there is no positional parameter, print an error message and return 1
#             "${PARSER_PROPERTIES["q"]:-false}" || awkDynamicBorders -l "Parameters Missing (-A)" -c "Please provide an associative array to use this function." >&2;
#             return 1;
#         fi
#     }

#     # Query the declaration of 'A' property
#     declarationQuery -m 'A' -n 'r' "${PARSER_PROPERTIES["A"]}" || return $?;  

#     # Declare a nameref variable to 'A' property
#     local -n REFERENCE="${PARSER_PROPERTIES["A"]}";  

#     [[ -z "${PARSER_PROPERTIES["a"]}" && -n "${1}" ]] && {  
#         # Set 'a' property to the positional parameter
#         PARSER_PROPERTIES["a"]="${1}";  
#         # Shift positional parameters
#         shift;  
#     } || {
#         # Set 'a' property to 'PARAMETERS'
#         PARSER_PROPERTIES["a"]='PARAMETERS';  
#         # Set 'p' property to true
#         PARSER_PROPERTIES["p"]="true";  
#     }

#     [[ -n "${PARSER_PROPERTIES["a"]}" ]] && {  
#         # Query the declaration of 'a' property
#         declarationQuery -m 'a' -n 'r' "${PARSER_PROPERTIES["a"]}" || {  
#             # Set 'a' property to 'PARAMETERS'
#             PARSER_PROPERTIES["a"]='PARAMETERS';  
#             # Set 'p' property to true
#             PARSER_PROPERTIES["p"]="true";  
#         }
#     }

#     # Declare a nameref variable to 'a' property
#     local -n PARAMETER_REFERENCE="${PARSER_PROPERTIES["a"]}";  

#     # Loop over the keys of REFERENCE array
#     for OPTARG in "${!REFERENCE[@]}"; do  
#         # Set OPT to the value of the current key in REFERENCE array
#         OPT="${REFERENCE["${OPTARG}"]}";  

#         # Check if the current key is a unique entry in 'a' property
#         ARGUMENT="$(isUniqueEntry -Q "${PARSER_PROPERTIES["a"]}" "${OPTARG}")";  
#         # If ARGUMENT is not empty, add it to PARAMETER_REFERENCE array
#         [[ -n "${ARGUMENT}" ]] && PARAMETER_REFERENCE+=("${ARGUMENT}");  
#         # Reset ARGUMENT
#         ARGUMENT="";  

#         if [[ -n "${OPT}" && "${REFERENCE["${OPTARG}"]}" != "true" && ! ${OPT} =~ ^[[:space:]]+$ ]]; then  
#             # Add OPT to PARAMETER_REFERENCE array
#             PARAMETER_REFERENCE+=("${OPT}");  
#         fi

#         # Reset OPT
#         OPT="";  
#     done

#     # If 'p' property is set
#     "${PARSER_PROPERTIES["p"]:-false}" && {  
#         # If 'q' property is not set, print the values of PARAMETER_REFERENCE array
#         "${PARSER_PROPERTIES["q"]:-false}" || echo -n "${PARAMETER_REFERENCE[@]}";  
#     }

#     # Return 0
#     return 0;  
# }
