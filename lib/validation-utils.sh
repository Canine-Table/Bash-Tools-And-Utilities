# Creates the LIB_DIR global variable if it does not already exist. Use this variable to access the absolute path of the library directory containing generic scripts.
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function unsetVariables() {
    local V;

    for V in "${@}"; do
        declare -p | awk '{sub(/=.*/, "", $0) ;print $3}' | grep -q "^${V}$" && unset "${V}";
    done

    return 0;
}

function initSystem() {

    # Declare local variables for options and field properties
    local OPT;
    local -i OPTIND;
    local -A INIT_PROPERTIES;

    # Loop through a list of known init system commands to detect which one is available
    # The loop breaks as soon as it finds a valid command, storing it in the associative array
    for OPT in 'initctl' 'rc-service' 'systemctl'; do
        command -v "${OPT}" &> /dev/null && {
            INIT_PROPERTIES['i']="${OPT}";
            break;
        }
    done

   # Parse options passed to the function
# service
# mount
# swap
# socket
# target
# device
# automount
# timer
# path
# slice
# scope
    while getopts :s:q OPT; do
        case ${OPT} in
            q) INIT_PROPERTIES["${OPT}"]='true';; # Supports a quiet mode option '-q' to suppress error messages
            s) INIT_PROPERTIES["${OPT}"]="${OPTARG}";; # The '-s' option allows specifying the service name to act upon
        esac
    done

    # Shift positional parameters by the number of options parsed
    shift $((OPTIND - 1));

    [[ -z "${INIT_PROPERTIES["s"]}" && -n "${1}" ]] && {
        INIT_PROPERTIES["s"]="${1}";
        shift;
    }

    # Check if an init system was detected
    [[ -z "${INIT_PROPERTIES['i']}" ]] && {
        # If not, print an error message (unless in quiet mode) and return with an error code 1
        ${INIT_PROPERTIES["q"]:-false} || awkDynamicBorders -l "Init System Not Supported" -c "Supported init systems are 'initctl', 'rc-service' and 'systemctl'" >&2;
        return 1;
    }

    [[ -z "${INIT_PROPERTIES['s']}" ]] && {
        ${INIT_PROPERTIES["q"]:-false} || awkDynamicBorders -l "Missing Service" -c "echo ${INIT_PROPERTIES['i']} needs a service to act upon." >&2;
        return 2;
    }

    # Based on the detected init system, call the corresponding initialization function
    case "${INIT_PROPERTIES['i']}" in
        'initctl') _initctlInit;;
        'rc-service') _rcServiceInit;;
        'systemctl') _systemctlInit;;
    esac

    return 0;
}

function _initctlInit() {
    return 0;
}

function _rcServiceInit() {
    return 0;
}

function _systemctlInit() {

    [[ "${FUNCNAME[1]}" != 'initSystem' ]] && {
        awkDynamicBorders -l "Usage Error" -c "Please use the initSystem function instead of using _systemctlInit directly." >&2;
        return 1;
    }

    systemctl status ${INIT_PROPERTIES['s']}

    return 0;
}