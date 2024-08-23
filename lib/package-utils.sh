# Creates the LIB_DIR global variable if it does not already exist. Use this variable to access the absolute path of the library directory containing generic scripts.
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function packages() {
	local SUPER_USER;
    
    SUPER_USER="$(superUser)" && {
        ${SUPER_USER} pacman -S ${@};
        return 0;
    } || return $?;
}

__displayPackages() {

    packages xorg-xrandr \
        autorand;

    return $?;
}

__audioPackages() {

    packages pipewire \
        alsa-utils \
        pipewire-alsa \
        pipewire-pulse \
        wireplumber \
        pavucontrol-qt \
        pipewire-jack;

    return $?;
}

__bashPackages() {

    packages bash \
        bash-completion;

    return $?;
}

