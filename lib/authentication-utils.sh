# Creates the LIB_DIR global variable if it does not already exist. Use this variable to access the absolute path of the library directory containing generic scripts.
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function superUser() {

    local -i USER_ID="$(id -u)";
    local SUPER_USER="" S="";

    [ "${USER_ID}" -eq 0 ] && {
        # root does not need privilege elevation, so return 0, no action needed.
        return 0;
    } || {

        # if the user does not belong to the sudoers groups return 1.
        [[ "$(groups "$(whoami)")" =~ (wheel|sudo) ]] || return 1;

        # find out if the system has a package for privilege elevation.
        for S in 'doas' 'sudo'; do
            command -v "${S}" &> /dev/null && {
                SUPER_USER="${S}";
                break;
            }
        done
    }

    # if the system does not contain sudo or doas required for privilege elevation return 2.
    [ -z "${SUPER_USER}" ] && return 2;

    # print the package name installed on the system.
    printf "${SUPER_USER}";

    return 0;
}