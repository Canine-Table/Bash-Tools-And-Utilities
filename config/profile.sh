# /etc/profile


function profile() {

    source "/etc/scripts/lib/configuration-utils.sh";
    libraries;

    local USER_ID="$(id -u)" SKELETON="/etc/scripts/config/skeleton.sh" S;

    umask 022;
    export PATH=".:..:${HOME}/.local/sbin:${HOME}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/etc/scripts/bin";
    export | grep -q 'ENV' || export ENV='/etc/bash.bashrc';

    # Append our default paths
    append_path '/usr/local/sbin';
    append_path '/usr/local/bin';

    [ "${USER_ID}" -eq 0 ] && for S in 'less' 'bash' 'xdotool' 'neofetch'; do
        command -v "${S}" &> '/dev/null' || yes | pacman -S "${S}";
    done

    command -v less &> /dev/null && export PAGER=less;

    [ "${USER_ID}" -gt 999 -a "${USER_ID}" -lt 65533 -a -f "${SKELETON}" -a -r "${SKELETON}" ] && source "${SKELETON}";

    cat '/etc/shells' | grep -q '/bin/bash' && {
        [ -d '/etc/profile.d/' -a -x '/etc/profile.d/' -a -r '/etc/profile.d/' ] && for S in /etc/profile.d/*.sh; do
            [ -f "${S}" ] && [ -r "${S}" ] && source "${S}";
        done

        [ -r '/etc/bash.bashrc' ] && source '/etc/bash.bashrc';
    }

    [[ "$(xrandr | awk '/*/{print $1}')" == '1920x1080' ]] || {
        [[ -n ${DISPLAY} ]] && cvt 1980 1080 32;
    }

    # Termcap is outdated, old, and crusty, kill it.
    unset TERMCAP

    # Man is much better than us at figuring this out
    unset MANPATH

    return 0;
}

profile;

