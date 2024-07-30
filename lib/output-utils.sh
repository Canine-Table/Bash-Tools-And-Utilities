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
