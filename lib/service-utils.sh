# Creates the LIB_DIR global variable if it does not already exist. Use this variable to access the absolute path of the library directory containing generic scripts.
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function _initctlInit() {
    return 0;
}

function _rcServiceInit() {
    local SERVICE;

    [[ -f '/etc/openrc' ]] && {
        :
    } || {
        SERVICE=$?;
        inform -t 'alert' 'openrc' 'System is not running openrc.';
        return ${SERVICE};
    }
}


function _sysvInit() {
    local SERVICE;

    [[ -f '/etc/inittab' ]] && {
        :
    } || {
        SERVICE=$?;
        inform -t 'alert' 'sysvinit' 'System is not running sysvinit.';
        return ${SERVICE};
    }
}

function _systemdInit() {

    local SERVICE TASK SUPER_USER;
    local -i NUMBER=0;

    [[ -d '/run/systemd/system' ]] && {    

         systemctl status "${1}" &> /dev/null && {
            TASKS="$(awkParameterCompletion -d ',' -s "${2}" 'restart,enable,disable,reset-failed,status')" && {

                case "${TASK:-status}" in
                    'restart'|'enable'|'disable'|'reset-failed'|'daemon-reload')
                        SUPER_USER="$(superUser)" && {
                            [[ "${TASK}" =~ ^((en|dis)able)$ ]] && {
                                ${SUPER_USER} systemctl ${TASK} --now ${1};
                            } || {
                                ${SUPER_USER} systemctl ${TASK} ${1};
                            }
                            return 0;
                        } || {
                            return $?;
                        }
                    ;;
                    *) systemctl status "${1}" ;;
                esac
            }
        } || {
        
            {
                inform -t 'error' "${1}?" "${1} in not a service on this system, did you mean on or these?";
                for SERVICE in $(find /usr/lib/systemd/system/ -type f -iname "*${1}*" 2> /dev/null -exec basename '{}' \;); do
                    [[ "${NUMBER}" -eq 0 && -z "${SERVICE}" ]] && {
                        inform -t 'warning' "No Service Found" "You have no matches for the service called ${1}.";
                        break;
                    } || inform -t 'info' "$((++NUMBER))" "${SERVICE}";
                done
 
            } | less -R
            return 0;
        }

        return 1;
    } || {
        SERVICE=$?;
        inform -t 'alert' 'systemd' 'System is not running systemd.';
        return ${SERVICE};
    }
}


function service() {

    case "$(ps -p 1 -o comm=)" in
        'systemd') _systemdInit "${@}";;
        'openrc-init') _rcServiceInit "${@}";;
        'init') _sysvInit "${@}";;
    esac
 
    return 0;
}
