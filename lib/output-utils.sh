grep -q 'LIB_DIR' <(export) || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> '/dev/null' && pwd)";

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

function fieldManager() {

    [[ -z "${FIELDS}" ]] || unset FIELDS;

    declare -ga FIELDS;
    local -i OPTIND COUNT;
    local OPT OPTARG;
    local -A FIELD_PROPERTIES=(
        ["inputFieldSeparator"]=" "
        ["outputFieldSeparator"]="\n"
        ["delimiter"]=","
        ["string"]=""
        ["merge"]="false"
        ["print"]="false"
        ["unset"]="false"
        ["quote"]=""
    );

    function quote() {
        [[ ${1,,} =~ ^(\'|s(i(n(g(l(e(q(u(o(t(e(s)?)?)?)?)?)?)?)?)?)?)?)$ ]] && FIELD_PROPERTIES["quote"]="'";
        if [[ ${1,,} =~ ^(\"|d(o(u(b(l(e(q(u(o(t(e(s)?)?)?)?)?)?)?)?)?)?)?)$ || -z "${FIELD_PROPERTIES["quote"]}" ]]; then
            [[ -z "${BASH_REMATCH[@]}" ]] && echo -e 'You did not specify a valid quotation.\nYou can choose between single and double quotes.\nDefaulting to double quotes.';
            FIELD_PROPERTIES["quote"]='"';
        fi

        return 0;
    }

    while getopts :o:i:d:s:q:mpu OPT; do
        case ${OPT} in
            u) FIELD_PROPERTIES["unset"]="true";;
            p) FIELD_PROPERTIES["print"]="true";;
            m) FIELD_PROPERTIES["merge"]="true";;
            q) quote "${OPTARG}";;
            o) FIELD_PROPERTIES["outputFieldSeparator"]="${OPTARG}";;
            i) FIELD_PROPERTIES["inputFieldSeparator"]="${OPTARG}";;
            d) FIELD_PROPERTIES["delimiter"]="${OPTARG}";;
            s) FIELD_PROPERTIES["string"]="${OPTARG}";;
        esac
    done

    shift "$((OPTIND - 1))";

    [[ -z "${FIELD_PROPERTIES["string"]}" ]] && if [[ -n "${@}" ]]; then
        FIELD_PROPERTIES["string"]="${@}";
    else
        echo "String required";
        return 1;
    fi

    [[ -z "${FIELD_PROPERTIES["delimiter"]}" ]] && FIELD_PROPERTIES["delimiter"]=",";

    if ! "${FIELD_PROPERTIES["merge"]}"; then
        [[ "${#FIELD_PROPERTIES["delimiter"]}" -gt 1 ]] && echo -e "The delimiter can only be one character.\nThe first character of '${FIELD_PROPERTIES["delimiter"]}' will be used.";
        COUNT="$(sed "s/[^${FIELD_PROPERTIES["delimiter"]}]//g" <<< "${FIELD_PROPERTIES["string"]}" | wc -c)";

        for ((OPTIND=1; OPTIND <= "${COUNT}"; OPTIND++)); do
            FIELDS+=("$(cut -d "${FIELD_PROPERTIES["delimiter"]:0:1}" -f "${OPTIND}" <<< "${FIELD_PROPERTIES["string"]}" | sed "s/^[[:space:]]*/${FIELD_PROPERTIES["quote"]}/g; s/[[:space:]]*$/${FIELD_PROPERTIES["quote"]}/g;")");
            "${FIELD_PROPERTIES["print"]}" && printf "${FIELDS[(-1)]}" && [[ -n "${FIELD_PROPERTIES["outputFieldSeparator"]}" && "${OPTIND}" -lt "${COUNT}" ]] && printf "${FIELD_PROPERTIES["outputFieldSeparator"]}";
        done
    else
        [[ -z "${FIELD_PROPERTIES["inputFieldSeparator"]}" ]] && FIELD_PROPERTIES["inputFieldSeparator"]=" ";
        FIELDS=("$(sed "s/${FIELD_PROPERTIES["inputFieldSeparator"]}/${FIELD_PROPERTIES["delimiter"]}/g; s/$/${FIELD_PROPERTIES["quote"]}/g; s/^/${FIELD_PROPERTIES["quote"]}/g;" <<< "${FIELD_PROPERTIES["string"]}" | sed "s/${FIELD_PROPERTIES["delimiter"]}/${FIELD_PROPERTIES["quote"]}${FIELD_PROPERTIES["delimiter"]}${FIELD_PROPERTIES["quote"]}/g" )");
        "${FIELD_PROPERTIES["print"]}" && printf "${FIELDS[(-1)]}";
    fi

    "${FIELD_PROPERTIES["unset"]}" && unset FIELDS;
    return 0;
}

function fileSystem() {

    function setName() {

        fieldManager -d '=' "${OPTARG}";
        local NOT='';
        local -n REF;
        local -a TYPES=(
            "regex,extentions"
            "regex,regexpr"
            "name"
            "lname,links"
            "lname"
            "path,directory"
            "path"
            "wholename"
            "wholename,fullname"
        ) MATCHES;

        local TYPE="$(awkCompletion "${FIELDS[0]}" "${TYPES[@]}")" S;

        if [[ -n "${FIELDS[1]}" ]]; then

            if [[ "${OPT}" == 'N' ]]; then
                REF='EXCLUDE';
                NOT='-not';
            else
                REF='INCLUDE';
            fi

            if [[ ${TYPE} =~ ^((l)?name|path|wholename|!)$ ]]; then
                MATCHES=($(fieldManager -pu "${FIELDS[1]}"));

                for S in "${MATCHES[@]}"; do
                    REF+=(${NOT} "${TYPE/#/-${FILE_SYSTEM_PROPERTIES["caseSensitive"]}}" "${S}");
                done
            else
                REF+=(${NOT} "${TYPE/#/-${FILE_SYSTEM_PROPERTIES["caseSensitive"]}}" ".*\.\($(fieldManager -pm -i ',' -d '\\|' "${FIELDS[1]}")\)");
            fi
        else
            return 1;
        fi

        return 0;
    }

    function setProperty() {
        if [[ "${OPT}" == 't' && -z "${FILE_SYSTEM_PROPERTIES["type"]}" ]]; then
            local TYPE;
            local -a TYPES=(
                "f,files"
                "d,directories"
                "c,character files"
                "p,named pipe files"
                "b,block devices"
                "l,links"
                "s,sockets"
            );

            if TYPE="$(awkCompletion -q "${OPTARG}" "${TYPES[@]}")"; then
                FILE_SYSTEM_PROPERTIES["type"]="-${FILE_SYSTEM_PROPERTIES["currentFileSystem"]}type";
                PARAMETERS+=("${FILE_SYSTEM_PROPERTIES["type"]}" "${TYPE}");
            fi
        elif [[ ${OPT} =~ ^([Mm])$ ]]; then
            local DEPTH;

            case "${BASH_REMATCH[0]}" in
                M) DEPTH='-maxdepth';;
                m) DEPTH='-mindepth';;
            esac

            if [[ -z "${FILE_SYSTEM_PROPERTIES["${DEPTH}"]}" && ${OPTARG} =~ ^[[:digit:]]+$ && "${OPTARG}" -gt 0 ]]; then
                FILE_SYSTEM_PROPERTIES["${DEPTH}"]="${OPTARG}";
                PARAMETERS+=("${DEPTH}" "${FILE_SYSTEM_PROPERTIES["${DEPTH}"]}");
            fi
        fi

        return 0;
    }

    function setPath() {
        [[ -d "${OPTARG}" && -r "${OPTARG}" ]] && FILE_SYSTEM_PROPERTIES["path"]="${OPTARG}";
        return 0;
    }

    [[ -z "${FOUND}" ]] || unset FOUND;
    
    declare -Ag FOUND;
    local OPT OPTARG;
    local -i OPTIND;
    local -a INCLUDE EXCLUDE PARAMETERS;
    local -A FILE_SYSTEM_PROPERTIES=(
        ["caseSensitive"]="i"
        ["currentFileSystem"]=""
        ["type"]=""
        ["path"]=""
        ["-maxdepth"]=""
        ["-mindepth"]=""
    );

    while getopts :p:t:m:M:N:n:cf OPT; do
        case ${OPT} in
            c) [[ -z "${FILE_SYSTEM_PROPERTIES["caseSensitive"]}" ]] && FILE_SYSTEM_PROPERTIES["caseSensitive"]="i" || unset FILE_SYSTEM_PROPERTIES["caseSensitive"];;
            f) [[ -z "${FILE_SYSTEM_PROPERTIES["currentFileSystem"]}" ]] && FILE_SYSTEM_PROPERTIES["currentFileSystem"]="x" || unset FILE_SYSTEM_PROPERTIES["currentFileSystem"];;
            p) setPath;;
            N|n) setName;;
            t|M|m) setProperty;;
        esac
    done

    shift "$((OPTIND - 1))";

    mapfile -t NAMES < <(
        for ((OPTIND=0; OPTIND < "${#INCLUDE[@]}"; OPTIND+=2)); do
            find "${FILE_SYSTEM_PROPERTIES["path"]:-"${PWD}"}" "${PARAMETERS[@]}" "${INCLUDE[@]:${OPTIND}:2}" "${EXCLUDE[@]}" -exec realpath "{}" \; 2> '/dev/null';
        done
    );

    for OPT in "${NAMES[@]}"; do
        FOUND["$(basename "${OPT}")"]="$(dirname "${OPT}")";
    done

    return 0;
}