# Check if LIB_DIR is already exported, if not, set it to the directory of this script
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function intervals() {

    local -i DEPTH=0;
    local OPT STATE='false';
    awkFieldManager -d ',' "${@}";

    for OPT in "${@}"; do
        STATE='false';
        grep -q '=' <<< "${OPT}" && {
            awkFieldManager -d '=' "${OPT}";
            OPT="$(awkParameterCompletion -d ',' -s "${FIELDS[0]}" 'hours,minutes,seconds')" && {
                case "${OPT}" in
                    'hours')
                        [[ ${FIELDS[1]} -ge 0 && ${FIELDS[1]} -lt 24 ]] && { ARGUMENTS[0]="${FIELDS[1]}"; };;
                    'minutes') 
                        [[ ${FIELDS[1]} -ge 0 && ${FIELDS[1]} -lt 60 ]] && { ARGUMENTS[1]="${FIELDS[1]}"; };;
                    'seconds') 
                        [[ ${FIELDS[1]} -ge 0 && ${FIELDS[1]} -lt 60 ]] && { ARGUMENTS[2]="${FIELDS[1]}"; };;
                esac
            } || hault;
        } || {
            [[ ${DEPTH} -eq 0 ]] && {
                [[ "${OPT}" -ge 0 && "${OPT}" -lt 24 ]] && { STATE='true'; } || { OPT=1; };
            } || {
                [[ "${OPT}" -ge 0 && "${OPT}" -lt 60 ]] && { STATE='true'; } || { OPT=59; };
            }
        }
        [[ ${DEPTH} -eq 3 ]] && break;
        DEPTH=$((DEPTH += 1));
    done
    continue;

}