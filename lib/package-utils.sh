# Creates the LIB_DIR global variable if it does not already exist. Use this variable to access the absolute path of the library directory containing generic scripts.
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

# function package() {
# }

__displayPackages() {

    packages xorg-xrandr \
        autorand;

    return $?;
}

__audioPackages() {

    package pipewire \
        alsa-utils \
        pipewire-alsa \
        pipewire-pulse \
        wireplumber \
        pavucontrol-qt \
        pipewire-jack;

    return $?;
}

__bashPackage() {

    package bash \
        bash-completion;

    return $?;
}

function package() {
    local PACKAGE;

    function _archRepository() {
        local SUPER_USER;

        SUPER_USER="$(superUser -q)" || {
            comand -v yay &> /dev/null && {
                PACKAGES="yay";
            } || return $?;
        }

        local TASK;
        TASKS="$(awkParameterCompletion -d ',' -s "${1}" 'install,remove,update,search')" &&  case "${TASKS}" in
            'install') ${SUPER_USER} ${PACKAGE} -S "${2}";;
            'remove') ${SUPER_USER} ${PACKAGE} -R "${2}";;
            'update') ${SUPER_USER} ${PACKAGE} -Syu;;
            'search')
                ${PACKAGE} -Ss "${2}" | awk -F '/' 'BEGIN {
                    table = 0;
                } {
                    if ($0 !~ /^[[:space:]]+/) {
                        gsub(/ .*/, "", $2);
                        if (++table % 3 == 0) {
                            printf("%-35s\n", $2);
                        } else {
                            printf("%-35s", $2);
                        }
                    }
                }' | less;
            ;;
        esac

        return 0;
    }

    function _debianRepository() {
        local SUPER_USER;
        
        SUPER_USER="$(superUser)" && {
            return 0;
        } || return $?;
    }

    function _redhatRepository() {
        local SUPER_USER;
        
        SUPER_USER="$(superUser)" && {
            return 0;
        } || return $?;
    }

    function _opensuseRepository() {
        local SUPER_USER;
        
        SUPER_USER="$(superUser)" && {
            return 0;
        } || return $?;
    }

    local PACKAGES=(
        'apt' 'apt-get'
        'dnf' 'yum'
        'pacman'
        'zypper'
    );
 
    for PACKAGE in "${PACKAGES[@]}"; do
        command -v "${PACKAGE}" &> /dev/null && case "${PACKAGE}" in
            'pacman') _archRepository "${@}"
                break;;
            'apt'|'apt-get') _debianRepository "${@}"
                break;;
            'dnf'|'yum') _redhatRepository "${@}"
                break;;
            'zypper') _opensuseRepository "${@}"
                break;;
        esac
    done

    return 0;
}
