function main() {

    local USER_ID="$(id -u)" SKELETON="/usr/local/conf/skeleton.sh" S;

    umask 022;
    export PAGER=less;
    export PATH=".:..:${HOME}/.local/sbin:${HOME}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
    export | grep -q 'ENV' || export ENV='/etc/profile';

    [ "${USER_ID}" -eq 0 ] && for S in 'doas' 'bash'; do
        command -v "${S}" &> '/dev/null' || apk add "${S}";
    done

    [ "${USER_ID}" -gt 999 -a "${USER_ID}" -lt 65533 -a -f "${SKELETON}" -a -r "${SKELETON}" ] && source "${SKELETON}";

    getent shells | grep -q '/bin/bash' && [ -d '/etc/profile.d/' -a -x '/etc/profile.d/' -a -r '/etc/profile.d/' ] && for S in /etc/profile.d/*.sh; do
        [ -f "${S}" ] && [ -r "${S}" ] && source "${S}";
    done

    return 0;
}

main;
