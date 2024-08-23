# Creates the LIB_DIR global variable if it does not already exist. Use this variable to access the absolute path of the library directory containing generic scripts.
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function padding() {

    local -i OPTIND;
    local OPT OPTARG;
    local -a FIELDS KWARGS;
    local -A PADDING_PROPERTIES=(
           ["parameters"]='1=top,2=end,3=bottom,4=start'
    );

    function format() {
        local -r SEPARATOR="$([[ $((${KWARGS[0]} % 2)) -eq 0 ]] && echo -n '\\t' || echo -n '\\n')";
        local -i PADDING=1;
    
        [[ ${FIELDS[-1]} =~ ^([1-9]{1}([[:digit:]]+)?)$ ]] && PADDING=${FIELDS[-1]};

        PADDING_PROPERTIES["${KWARGS[1]}"]="$(awk -v padding="${PADDING}" -v separator="${SEPARATOR}" \
            'BEGIN {
                string = sprintf("%*s", padding, "");
                if (separator ~ /\\t/) {
                    gsub(/ /, "    ", string);
                } else {
                    gsub(/ /, separator, string);
                }

                printf("%s", string);
            }';
        )";

        return 0;
    }

    while getopts :F: OPT; do
        case ${OPT} in
            F)
                for OPT in $(awkFieldManager -p "${PADDING_PROPERTIES["parameters"]}"); do
                    KWARGS=($(awkFieldManager -p -d '=' "${OPT}"));

                    for OPT in $(awkFieldManager -p "${OPTARG}"); do
                        awkFieldManager -d '=' "${OPT}";

                        OPT="$(awkParameterCompletion -q -d ',' -s "${FIELDS[0]}" "${KWARGS[1]}")" && {
                            format;
                            break;
                        }
                    done
                done ;;
        esac
    done

    # Shift off the options from the positional parameters.
    shift $((OPTIND - 1));

    echo -en "${PADDING_PROPERTIES["top"]:-\n}$(
        echo -n "${@}" | awk -v start="${PADDING_PROPERTIES["start"]}" -v end="${PADDING_PROPERTIES["end"]}" '{
                printf("%s%s%s", start, $0, end);
            }';
    )${PADDING_PROPERTIES["bottom"]:-\n}";

    return 0;
}

function hault() {
    command -v setterm &> /dev/null && {
        setterm -cursor off;
        trap 'setterm -cursor on' RETURN SIGINT SIGHUP;
    }

    read -n 1 -s;
    return 0;
}

function inform() {

    # Declare local variables
    local OPT OPTARG;
    local -i OPTIND;
    local -A OUTPUT_PROPERTIES;

    function _format() {
        case "${1}" in
            'error')
                OUTPUT_PROPERTIES['f']='31';
                OUTPUT_PROPERTIES['b']='40';
                OUTPUT_PROPERTIES['s']='-';
            ;;
            'alert')
                OUTPUT_PROPERTIES['f']='37';
                OUTPUT_PROPERTIES['b']='40';
                OUTPUT_PROPERTIES['s']='*';
            ;;
            'warning')
                OUTPUT_PROPERTIES['f']='33';
                OUTPUT_PROPERTIES['b']='40';
                OUTPUT_PROPERTIES['s']='!';
            ;;
            'info')
                OUTPUT_PROPERTIES['f']='34';
                OUTPUT_PROPERTIES['b']='40';
                OUTPUT_PROPERTIES['s']='#';
            ;;
            'debug')
                OUTPUT_PROPERTIES['f']='32';
                OUTPUT_PROPERTIES['b']='40';
                OUTPUT_PROPERTIES['s']='?';
            ;;
            *) return 1 ;;
        esac
    }

    function _println() {
        echo -e "\e[1;${OUTPUT_PROPERTIES['f']}m [${OUTPUT_PROPERTIES['s']}] \e[1;4;${OUTPUT_PROPERTIES['f']}m${1}\e[0;1;${OUTPUT_PROPERTIES['f']}m: \e[0;1;${OUTPUT_PROPERTIES['b']};$((OUTPUT_PROPERTIES['f'] + 60))m ${@:2} \e[0m";
        return 0;
    }

    # Parse command-line options
    while getopts :t: OPT; do
        case ${OPT} in
            t) OUTPUT_PROPERTIES["${OPT}"]="$(awkParameterCompletion -d ',' -s "${OPTARG}" 'error,alert,warning,info,debug')";;
        esac
    done

    # Shift positional parameters
    shift $((OPTIND - 1));

    _format 'error';
    if [[ -z "${OUTPUT_PROPERTIES[t]}" ]]; then
        _println 'Type (-t) Required' 'error, alert, warning, info, debug';
        return 1;
    elif [[ "${#}" -lt 2 ]]; then
        _println '2 Arguments are required Required' 'please provide a (1) label a (2) sentence following the (-t) type.';
        return 2;
    else
        _format "${OUTPUT_PROPERTIES[t]}";
        _println ${@};
        return 0;
    fi
}
