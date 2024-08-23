#!/bin/bash

(
cat << 'EOF'
#
# /etc/profile
#

function profile() {


    local USER_ID="$(id -u)" SKELETON="/etc/scripts/config/skeleton.sh" S="/etc/scripts/lib/configuration-utils.sh";

    [[ -f "${S}" && -r "${S}" ]] && {
        source "${S}";
        libraries;

        # Append our default paths
        append_path '.';
        append_path '..';
        append_path '/usr/local/sbin';
        append_path '/usr/local/bin';
        append_path '/usr/sbin';
        append_path '/usr/bin';
        append_path '/etc/scripts/sbin';
        append_path '/etc/scripts/bin';

    } || export PATH=".:..:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/etc/scripts/bin";

    umask 022;

    [ "${USER_ID}" -eq 0 ] && for S in 'less' 'bash' 'xdotool' 'neofetch' 'lolcat'; do
        command -v "${S}" &> '/dev/null' || yes | pacman -S "${S}";
    done

    command -v less &> /dev/null && {
        export PAGER='less';
        export LESS='-R';
    }

    [ "${USER_ID}" -gt 999 -a "${USER_ID}" -lt 65533 -a -f "${SKELETON}" -a -r "${SKELETON}" ] && source "${SKELETON}";

    cat '/etc/shells' | grep -q '/bin/bash' && {
        S='/etc/profile.d';

        [[ -d "${S}" && -x "${S}" && -r "${S}" ]] && for S in /etc/profile.d/*.sh; do
            [ -f "${S}" ] && [ -r "${S}" ] && source "${S}";
        done

        S='/etc/bash.bashrc';

        [[ -f "${S}" && -r "${S}" ]] && {
            export | grep -q 'ENV' || export ENV="${S}";
            source "${S}";
        }
    }

    command -v xrandr &> /dev/null && {
        [[ "$(xrandr | awk '/*/{print $1}')" == '1920x1080' ]] || {
            [[ -n ${DISPLAY} ]] && cvt 1980 1080 32;
        }
    }

    # Termcap is outdated, old, and crusty, kill it.
    unset TERMCAP

    # Man is much better than us at figuring this out
    unset MANPATH

    return 0;
}

profile;

EOF
) > '/etc/profile';