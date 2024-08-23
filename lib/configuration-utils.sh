# Creates the LIB_DIR global variable if it does not already exist. Use this variable to access the absolute path of the library directory containing generic scripts.
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function libraries() {
    local FILE;

    # import all the bash functions within the files located within the library directory.
    for FILE in ${LIB_DIR}/*.sh; do
        source "${FILE}";
    done

    return 0;
}

function append_path() {
    case ":${PATH}:" in
        *:"${1}":*) return 1;;
        *) export PATH="${PATH:+$PATH:}$1";;
    esac

    return 0;
}

__sddmAstronautTheme() {
    local SUPER_USER;
    
    SUPER_USER="$(superUser)" && {
        command -v git &> /dev/null || {
            yes | ${SUPER_USER} pacman -S git || return $?;
        }

        [[ -d '/usr/share/sddm/themes/sddm-astronaut-theme' ]] && {
            inform -t 'error' 'sddm-astronaut-theme' 'sddm-astronaut-theme is already located at /usr/share/sddm/themes/sddm-astronaut-theme/';
        } || {
            ${SUPER_USER} git clone 'https://github.com/keyitdev/sddm-astronaut-theme.git' '/usr/share/sddm/themes/sddm-astronaut-theme';
            ${SUPER_USER} cp /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* '/usr/share/fonts/';
        }
    } || return $?;

    return 0;
}