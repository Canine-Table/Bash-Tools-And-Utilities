if [[ ! $(declare -p | grep 'declare -x LIB_DIR') ]]; then
    export LIB_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";
fi

function consoleCodes() {

    local -Ai TEXT_PROPERTIES=(
        ["foreground"]="38"
        ["background"]="48"
        ["weight"]="0"
    );

    local OPT OPTARG STRING CLEAR I;
    local -i OPTIND SCROLLING;

    local -A CONSOLE_PROPERTIES=(
        ["clear"]=""
        ["moveCursor"]=""
        ["save"]="false"
        ["restore"]="true"
        ["hideCursor"]="false"
        ["lineWrapping"]="true"
        ["foreground"]="false"
        ["background"]="false"
        ["weight"]="false"
    );

    local -Ai CURSOR_POSISTION=(
        ["back"]="-1"
        ["forward"]="-1"
        ["down"]="-1"
        ["up"]="-1"
    );

    local -a SET_PROPERTIES RESET_PROPERTIES;

    function setTextProperties() {
        local -l PROPERTY="${OPT}" VALUE="${OPTARG}";
        local -Ai PREFIXES=(
            ["light"]=""
            ["dark"]=""
        );

        if [[ ${PROPERTY} =~ ^(b|f)$ ]]; then

            case "${PROPERTY}" in
                b) PROPERTY="background"; PREFIXES=(["light"]="10" ["dark"]="4");;
                f) PROPERTY="foreground"; PREFIXES=(["light"]="9" ["dark"]="3");;
            esac

            function setColorProperty() {
                local -i NUMBER="${1}";

                if [[ ${NUMBER} -le 7 ]]; then
                    TEXT_PROPERTIES["${PROPERTY}"]="${PREFIXES["dark"]}$((${NUMBER} % 8))";
                else
                    TEXT_PROPERTIES["${PROPERTY}"]="${PREFIXES["light"]}$((${NUMBER} % 8))";
                fi

                return 0;
            }

            if [[ ${VALUE} =~ ^(bla(c(k)?)?|0|30|40)$ ]]; then
                setColorProperty "0";
            elif [[ ${VALUE} =~ ^(r(e(d)?)?|1|31|41)$ ]]; then
                setColorProperty "1";
            elif [[ ${VALUE} =~ ^(gr(e(e(n)?)?)?|2|32|42)$ ]]; then
                setColorProperty "2";
            elif [[ ${VALUE} =~ ^(y(e(l(l(o(w)?)?)?)?)?|3|33|43)$ ]]; then
                setColorProperty "3";
            elif [[ ${VALUE} =~ ^(blu(e)?|4|34|44)$ ]]; then
                setColorProperty "4";
            elif [[ ${VALUE} =~ ^(p(u(r(p(l(e)?)?)?)?)?|5|35|45)$ ]]; then
                setColorProperty "5";
            elif [[ ${VALUE} =~ ^(t(e(a(l)?)?)?|6|36|46)$ ]]; then
                setColorProperty "6";
            elif [[ ${VALUE} =~ ^(w(h(i(t(e)?)?)?)?|7|37|47)$ ]]; then
                setColorProperty "7";
            elif [[ ${VALUE} =~ ^(g(r(a(y)?)?)?|8|90|100)$ ]]; then
                setColorProperty "8";
            elif [[ ${VALUE} =~ ^(l(i(g(h(t)?)?)?)?r(e(d)?)?|9|91|101)$ ]]; then
                setColorProperty "9";
            elif [[ ${VALUE} =~ ^(l(i(g(h(t)?)?)?)?g(r(e(e(n)?)?)?)?|10|92|102)$ ]]; then
                setColorProperty "10";
            elif [[ ${VALUE} =~ ^(l(i(g(h(t)?)?)?)?y(e(l(l(o(w)?)?)?)?)?|11|93|103)$ ]]; then
                setColorProperty "11";
            elif [[ ${VALUE} =~ ^(l(i(g(h(t)?)?)?)?b(l(u(e)?)?)?|12|94|104)$ ]]; then
                setColorProperty "12";
            elif [[ ${VALUE} =~ ^(l(i(g(h(t)?)?)?)?p(u(r(p(l(e)?)?)?)?)?|13|95|105)$ ]]; then
                setColorProperty "13";
            elif [[ ${VALUE} =~ ^(l(i(g(h(t)?)?)?)?t(e(a(l)?)?)?|14|96|106)$ ]]; then
                setColorProperty "14";
            elif [[ ${VALUE} =~ ^(l(i(g(h(t)?)?)?)?w(h(i(t(e)?)?)?)?|15|97|107)$ ]]; then
                setColorProperty "15";
            fi
        elif [[ ${PROPERTY} =~ ^(w)$ ]]; then
            if [[ ${VALUE} =~ ^(r(e(g(u(l(a(r)?)?)?)?)?)?|0)$ ]]; then
                TEXT_PROPERTIES["weight"]="0";
            elif [[ ${VALUE} =~ ^(bo(l(d)?)?|1)$ ]]; then
                TEXT_PROPERTIES["weight"]="1";
            elif [[ ${VALUE} =~ ^(l(i(g(h(t(e(r)?)?)?)?)?)?|2)$ ]]; then
                TEXT_PROPERTIES["weight"]="2";
            elif [[ ${VALUE} =~ ^(i(t(a(l(i(c(s)?)?)?)?)?)?|3)$ ]]; then
                TEXT_PROPERTIES["weight"]="3";
            elif [[ ${VALUE} =~ ^(u(n(d(e(r(l(i(n(e(d)?)?)?)?)?)?)?)?)?|4)$ ]]; then
                TEXT_PROPERTIES["weight"]="4";
            elif [[ ${VALUE} =~ ^(b(l(i(n(k(s|e(r(s)?)?)?)?)?)?)?|5)$ ]]; then
                TEXT_PROPERTIES["weight"]="5";
            elif [[ ${VALUE} =~ ^(h(i(g(h(l(i(g(h(t(s)?)?)?)?)?)?)?)?)?|7)$ ]]; then
                TEXT_PROPERTIES["weight"]="7";
            elif [[ ${VALUE} =~ ^(t(r(a(n(s(p(a(r(e(n(t|c(y)?)?)?)?)?)?)?)?)?)?)?|8)$ ]]; then
                TEXT_PROPERTIES["weight"]="8";
            elif [[ ${VALUE} =~ ^(s(t(r(i(k(e(o(u(t)?)?)?)?)?)?)?)?|9)$ ]]; then
                TEXT_PROPERTIES["weight"]="9";
            fi
        fi

        return 0;
    }

    function setCursorPosision() {
        local COORDINATES="${1}" I;

        getCursorPosision() {
            echo -n "${COORDINATES}" | cut -s -d ',' -f "${1}";
            return 0;
        }

        local -A POSISTION=(
            ["up"]="$(getCursorPosision 1)"
            ["forward"]="$(getCursorPosision 2)"
            ["down"]="$(getCursorPosision 3)"
            ["back"]="$(getCursorPosision 4)"
        );

        for I in "${!POSISTION[@]}"; do
            if [[ ${POSISTION["${I}"]} =~ ^([[:digit:]]+)$ && ${POSISTION["${I}"]} -gt 0 ]]; then
                CURSOR_POSISTION["${I}"]="${POSISTION["${I}"]}";
            fi
        done

        return 0;
    }

    function setResetConsoleProperties() {
        local KEY="$(echo "${1}" | cut -d '=' -f 1)" VALUE="$(echo "${1}" | cut -d '=' -f 2)";

        if [[ -n "${KEY}" ]]; then
            SET_PROPERTIES+=("${KEY}");
        fi

        if [[ -n "${VALUE}" ]]; then
            RESET_PROPERTIES+=("${VALUE}");
        fi

        return 0;
    }

    function outputString() {

        if "${CONSOLE_PROPERTIES["save"]}"; then
            printf '\e[?1049h%s' "${CONSOLE_PROPERTIES["clear"]}";
        fi

        printf "$(printf '\e[%dA\e[%dC%s\e[%dB\e[%dD' "${CURSOR_POSISTION["up"]}" "${CURSOR_POSISTION["forward"]}" "${@}" "${CURSOR_POSISTION["down"]}" "${CURSOR_POSISTION["back"]}")";

        if "${CONSOLE_PROPERTIES["restore"]}"; then
            printf '\e[?10491';
        fi

        return 0;
    }

    function clearScreen() {
        local -i NUMBER="${1}";

        if ! [[ ${NUMBER} =~ ^(1|3)$ ]]; then
            NUMBER="2";
        fi

        CONSOLE_PROPERTIES["clear"]="\e[${NUMBER}J";

        return 0;
    }

    function moveCursor() {
        local COORDINATES='\\e[';
        local -A MOVE=(
            ["line"]="$(echo "${1}" | cut -s -d ',' -f 1)"
            ["column"]="$(echo "${1}" | cut -s -d ',' -f 2)"
        );

        if [[ -n "${MOVE["line"]}" ]]; then
            COORDINATES+="${MOVE["line"]}";
        fi

        if [[ -n "${MOVE["column"]}" ]]; then
            COORDINATES+=";${MOVE["column"]}";
        fi

        CONSOLE_PROPERTIES["moveCursor"]="${COORDINATES}H";

        return 0;
    }

    while getopts :s:f:b:w:p:c:C:m:WFBRSHL OPT; do
        case ${OPT} in
            f|b|w) setTextProperties;;
            s) STRING="${OPTARG}";;
            B) CONSOLE_PROPERTIES["background"]="true";;
            F) CONSOLE_PROPERTIES["foreground"]="true";;
            W) CONSOLE_PROPERTIES["weight"]="true";;
            c) clearScreen "${OPTARG}";;
            C) moveCursor "${OPTARG}";;
            S) CONSOLE_PROPERTIES["save"]="true";;
            R) CONSOLE_PROPERTIES["restore"]="false";;
            H) CONSOLE_PROPERTIES["hideCursor"]="true";;
            m) CONSOLE_PROPERTIES["scrollMargin"]="${OPTARG}";;
            L) CONSOLE_PROPERTIES["lineWrapping"]="false";;
            p) setCursorPosision "${OPTARG}";;
        esac
    done

    shift "$((OPTIND - 1))";

    if [[ -z "${STRING}" && -n "${@}" ]]; then
        STRING="${@}";
    fi

    if ! "${CONSOLE_PROPERTIES["save"]}" && [[ -n "${CONSOLE_PROPERTIES["clear"]}" ]]; then
        printf "${CONSOLE_PROPERTIES["clear"]}";
    fi

    if [[ -n "${CONSOLE_PROPERTIES["moveCursor"]}" ]]; then
        printf "${CONSOLE_PROPERTIES["moveCursor"]}";
    fi

    if "${CONSOLE_PROPERTIES["hideCursor"]}"; then
        setResetConsoleProperties '[?251=[?25h';
    fi

    if [[ ${CONSOLE_PROPERTIES["scrollMargin"]} =~ ^([[:digit:]]+)$ ]]; then
        setResetConsoleProperties "[0;${SCREEN["scrollMargin"]}r=[;r";
    fi

    if "${CONSOLE_PROPERTIES["lineWrapping"]}"; then
        setResetConsoleProperties '[?7h=[?71';
    fi

    for I in "${SET_PROPERTIES[@]}"; do
        printf "\e${I}";
    done

    if [[ -n "${STRING}" ]]; then
        if echo -n {"${CONSOLE_PROPERTIES["weight"]}","${CONSOLE_PROPERTIES["foreground"]}","${CONSOLE_PROPERTIES["background"]}"} | grep -q '\btrue\b'; then
            outputString "$(echo "${STRING}" | awk -v multicolored_foreground="${CONSOLE_PROPERTIES["foreground"]}" -v multicolored_background="${CONSOLE_PROPERTIES["background"]}" -v random_weight="${CONSOLE_PROPERTIES["weight"]}" -v foreground="${TEXT_PROPERTIES["foreground"]}" -v background="${TEXT_PROPERTIES["background"]}" -v weight="${TEXT_PROPERTIES["weight"]}" -f "${LIB_DIR}/awk-lib/awk-utils.awk" -f "${LIB_DIR}/awk-lib/colors.awk")";
        elif [[ "$(echo -n "${#TEXT_PROPERTIES[@]}")" -gt 0 ]]; then
            outputString "\\e[${TEXT_PROPERTIES["weight"]:-0};${TEXT_PROPERTIES["foreground"]:-98};${TEXT_PROPERTIES["background"]:-108}m${STRING}\\e[m";
        fi
    fi

    for I in "${RESET_PROPERTIES[@]}"; do
        printf "\e${I}";
    done

    return 0;
}
