# Check if LIB_DIR is already exported, if not, set it to the directory of this script
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";


function borders() {

    local -i OPTIND;
    local OPT OPTARG;
    local -A BORDER_PROPERTIES;

   while getopts :B:C:P:M: OPT; do
        case ${OPT} in
            C|B|P|M) BORDER_PROPERTIES[${OPT}]="${OPTARG}";;
        esac
    done

    shift $((OPTIND - 1));

    awk \
        -v padding="${BORDER_PROPERTIES[P]}" \
        -v margins="${BORDER_PROPERTIES[M]}" \
        -v columns="$(tput cols):${BORDER_PROPERTIES[C]}" \
        -v border="${BORDER_PROPERTIES[B]}" \
        -f "${LIB_DIR}/awk-lib/borders.awk"; 
    return 0;
}

function dialogFactory() {

    unsetVariables 'DIALOG_RESPONSE';

    # Declare local variables
    local -i DIALOG_ESC=255 DIALOG_ITEM_HELP=4 DIALOG_EXTRA=3 DIALOG_HELP=2 DIALOG_CANCEL=1 DIALOG_OK=0 OPTIND DIALOG_EXIT_STATUS;
    export DIALOGRC="${LIB_DIR}/../etc/.dialogrc";
    local OPT OPTARG;
    declare -g DIALOG_RESPONSE;
    local -a FIELDS;

    local -A DIALOG_PROPERTIES=(
        ["booleans"]='ascii-lines,beep,beep-after,clear,colors,cr-wrap,cursor-off-label,defaultno,erase-on-exit,ignore,insecure,keep-tite,keep-window,last-key,no-cancel,no-collapse,no-hot-list,no-items,no-kill,no-lines,no-mouse,no-nl-expand,no-ok,no-shadow,no-tags,print-maxsize,print-size,print-version,quoted,reorder,scrollbar,separate-output,single-quoted,size-err,stderr,stdout,tab-correct,trim,version,visit-items'
        ["variants"]='calendar,buildlist,checklist,dselect,fselect,editbox,form,tailbox,tailboxbg,textbox,timebox,infobox,inputbox,inputmenu,menu,mixedform,mixedgauge,gauge,msgbox,passwordform,passwordbox,pause,prgbox,programbox,progressbox,radiolist,rangebox,yesno'
        ["labels"]='message,no-label,backtitle,cancel-label,column-separator,help-label,default-item,exit-label,extra-label,default-button,title'
        ["buttons"]='extra-button,help-button'
        ["lines"]="$(($(tput lines) - 6))"
        ["columns"]="$(($(tput cols) - 3))"
    ) DIALOG_TOGGLES DIALOG_LABELS;

    # Parse command-line options
    while getopts :V:B:L: OPT; do
        case ${OPT} in
            V) DIALOG_PARAMETERS["${OPT}"]="$(awkParameterCompletion -d ',' -s "${OPTARG}" "${DIALOG_PROPERTIES["variants"]}")";;
            B)
                OPT="$(awkParameterCompletion -d ',' -s "${OPTARG}" "${DIALOG_PROPERTIES["booleans"]},${DIALOG_PROPERTIES["buttons"]}")" && {
                    DIALOG_TOGGLES["${OPT}"]="$(sedBooleanToggle "${DIALOG_TOGGLES["${OPT}"]}")";
                    "${DIALOG_TOGGLES["${OPT}"]}" || unset DIALOG_TOGGLES["${OPT}"];
                };;
            L)
                awkFieldManager -d '=' "${OPTARG}";
                OPT="$(awkParameterCompletion -d ',' -s "${FIELDS[0]}" "${DIALOG_PROPERTIES["labels"]}")" && {
                    sedIsEmpty -q "${FIELDS[1]}" && {
                        
                        [[ "${OPT}" == 'message' ]] && {
                            DIALOG_PROPERTIES["${OPT}"]="$(sedCharacterCasing "${FIELDS[1]}")";
                            continue;
                        }

                        DIALOG_LABELS["${OPT}"]="$(sedCharacterCasing "${FIELDS[1]}")";
                        [[ "${OPT}" == 'title' ]] && {
                            DIALOG_LABELS["${OPT}"]="┤ ${DIALOG_LABELS["${OPT}"]} ├";
                            continue;
                        }

                        awkFieldManager -d '-' "${OPT}";

                        OPT="$(awkParameterCompletion -q -d ',' -s "${FIELDS[0]}" "${DIALOG_PROPERTIES["buttons"]}")" && {
                            DIALOG_TOGGLES["${OPT}"]='true';
                        }

                        FIELDS=();
                    }
                };;
        esac
    done

    # Shift off the options from the positional parameters.
    shift $((OPTIND - 1));

    eval "PARAMETERS=($(echo "$(awkIndexQuerier -O 'flags' DIALOG_LABELS)")$(echo -n " ${!DIALOG_TOGGLES[@]} ${DIALOG_PARAMETERS[V]}" | sed 's/ / --/g'))";
    DIALOG_RESPONSE="$(dialog "${PARAMETERS[@]}" "\n${DIALOG_PROPERTIES["message"]:-Dialog}\n " "${DIALOG_PROPERTIES["lines"]}" "${DIALOG_PROPERTIES["columns"]}" 3>&1 1>&2 2>&3)";
    DIALOG_EXIT_STATUS=$?;

    [[ ${DIALOG_EXIT_STATUS} -eq 0 ]] && clear;

    return ${DIALOG_EXIT_STATUS};
}

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

# function awkParameterCompletion() {

#     # Declare local variables for options and field properties
#     local OPT OPTARG;
#     local -i OPTIND;
#     local -A COMPLETION_PROPERTIES;

#     # Parse options passed to the function
#     while getopts :d:P:A:s:q OPT; do
#         case ${OPT} in
#             q) COMPLETION_PROPERTIES["${OPT}"]='true';;
#             d|P|s|A) COMPLETION_PROPERTIES["${OPT}"]="${OPTARG}";;
#         esac
#     done

#     # Shift off the options from the positional parameters.
#     shift $((OPTIND - 1));

#     [[ -n "${COMPLETION_PROPERTIES["A"]}" && -z "${COMPLETION_PROPERTIES["s"]}" ]] && {
#         declarationQuery -q -m 'A' -n 'r' "${COMPLETION_PROPERTIES["A"]}" && COMPLETION_PROPERTIES["F"]='associative';
#         declarationQuery -q -m 'a' -n 'r' "${COMPLETION_PROPERTIES["A"]}" && COMPLETION_PROPERTIES["F"]='indexed';
#     }

#     [[ -z "${COMPLETION_PROPERTIES["P"]}" ]] && if [[ -n "${@}" ]]; then
#         COMPLETION_PROPERTIES["P"]="${*}";
#     else
#         # If neither is provided, print an error message and return with code 1
#         "${COMPLETION_PROPERTIES["q"]:-false}" || awkDynamicBorders -l 'Missing Parameters' -c "You must provide perameters" >&2;
#         return 1;
#     fi

#     OPTARG="$(awk \
#         -v parameters="${COMPLETION_PROPERTIES['P']}" \
#         -v string="${COMPLETION_PROPERTIES['s']}" \
#         -v delimiter="${COMPLETION_PROPERTIES['d']:- }" \
#         -v formating="${COMPLETION_PROPERTIES["F"]}" \
#         -f "${LIB_DIR}/awk-lib/parameter-completion.awk")" || case $? in

#         2)
#             "${COMPLETION_PROPERTIES["q"]:-false}" || awkDynamicBorders -d "█" -l "No Matching Parameter Found" -c "${OPTARG}" >&2;
#         return 2;;
#         3)
#             "${COMPLETION_PROPERTIES["q"]:-false}" || awkDynamicBorders -d "█" -l "To Many Matches Found" -c "${OPTARG}" >&2;
#         return 3;;
#     esac

#     if [[ -n "${COMPLETION_PROPERTIES["F"]}" ]]; then
#         eval "${COMPLETION_PROPERTIES["A"]}=($(echo -n "${OPTARG}"))";
#     else
#         echo -n "${OPTARG}";
#     fi

#     return 0;
# }




# function awkOptionParser() {

# }

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
