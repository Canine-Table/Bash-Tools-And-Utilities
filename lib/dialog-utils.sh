if [[ ! $(declare -p | grep 'declare -x LIB_DIR') ]]; then
    export LIB_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";
fi

function yesNoDialog() {

    local -A DEFAULTS=(
        ["yesLabel"]="Yes"
        ["noLabel"]="No"
        ["exitLabel"]="Exit"
        ["cancelLabel"]="Cancel"
        ["extraLabel"]="Extra"
        ["helpLabel"]="Help"
        ["value"]=""
        ["label"]=""
    );

    local -A ARGUMENTS=(
        ["clearScreen"]="--clear"
        ["asciiLines"]="--ascii-lines"
        ["noOk"]="--no-ok"
        ["noTags"]="--no-tags"
        ["keepWindow"]="--keep-window"
        ["ignore"]="--ignore"
        ["noCollapse"]="--no-collapse"
        ["noLines"]="--no-lines"
        ["noCancel"]="--no-cancel"
        ["defaultNo"]="--defaultno"
        ["insecure"]="--insecure"
        ["noShadow"]="--no-shadow"
        ["noMouse"]="--no-mouse"
        ["quoted"]="--quoted"
        ["singleQuoted"]="--single-quoted"
        ["shadow"]="--shadow"
        ["helpButton"]="--help-button"
        ["extraButton"]="--extra-button"
        ["keepTite"]="--keep-tite"
        ["scrollbar"]="--scrollbar"
        ["title"]="--title"
        ["backTitle"]="--backtitle"
        ["defaultNo"]="--defaultno"
        ["yesLabel"]="--yes-label"
        ["okLabel"]="--ok-label"
        ["noLabel"]="--no-label"
        ["exitLabel"]="--exit-label"
        ["cancelLabel"]="--cancel-label"
        ["extraLabel"]="--extra-label"
        ["helpLabel"]="--help-label"
    );

    local -A BOOLEAN=(
        ["clearScreen"]="true"
        ["asciiLines"]="false"
        ["noLines"]="false"
        ["noTags"]="false"
        ["noOk"]="false"
        ["keepWindow"]="true"
        ["ignore"]="false"
        ["noCollapse"]="false"
        ["noCancel"]="false"
        ["defaultNo"]="false"
        ["insecure"]="false"
        ["noMouse"]="false"
        ["quoted"]="false"
        ["singleQuoted"]="false"
        ["shadow"]="false"
        ["helpButton"]="false"
        ["extraButton"]="false"
        ["keepTite"]="false"
        ["scrollbar"]="false"
    );


    local -A DECLARATIONS=(
        ["title"]=""
        ["backTitle"]=""
        ["yesLabel"]=""
        ["noLabel"]=""
        ["okLabel"]=""
        ["exitLabel"]=""
        ["cancelLabel"]=""
        ["extraLabel"]=""
        ["helpLabel"]=""
    );

    local -a PARAMETERS OPTIONS;
    local -Ai SIZE=(
        ["width"]="$(($(tput cols) - 6))"
        ["hieght"]="$(($(tput lines) - 3))"
    );

    local -i DIALOG_ESC=255 DIALOG_ITEM_HELP=4 DIALOG_EXTRA=3 DIALOG_HELP=2 DIALOG_CANCEL=1 DIALOG_OK=0  OPTIND AUTO_SIZE INDEX;
    local FULL_SCREEN="false" SELECTED="false" OPT OPTARG I VARIANT;

    function setTextOptions() {

        local -l OPTION="$(echo "${1}" | cut -s -d '=' -f 1)";

        local VALUE="$(echo -n "${1}" | cut -s -d '=' -f 2)";
        local -i COUNT="$(echo -n "${VALUE}" | sed 's/[^,]//g' | wc -c)";

        if [[ ${COUNT} -eq 1 ]]; then
            VALUE="$(awkDescriptor "BEGIN { textCase(\"${VALUE}\") }")";
        fi

        if [[ ${OPTION} =~ ^(t(i(t(l(e)?)?)?)?)$ ]]; then
            DECLARATIONS["title"]="${VALUE}";
        elif [[ ${OPTION} =~ ^(b(a(c(k(t(i(t(l(e)?)?)?)?)?)?)?)?)$ ]]; then
            DECLARATIONS["backTitle"]="${VALUE}";
        elif [[ ${OPTION} =~ ^(o(k)?)$ ]]; then
            DECLARATIONS["okLabel"]="${VALUE}";
        elif [[ ${OPTION} =~ ^(h(e(l(p)?)?)?)$ ]]; then
            DECLARATIONS["helpLabel"]="${VALUE}";
            BOOLEAN["helpButton"]="true";
        elif [[ ${OPTION} =~ ^(ext(r(a)?)?)$ ]]; then
            DECLARATIONS["extraLabel"]="${VALUE}";
            BOOLEAN["extraButton"]="true";
        elif [[ ${OPTION} =~ ^(c(a(n(c(e(l)?)?)?)?)?)$ ]]; then
            DECLARATIONS["cancelLabel"]="${VALUE}";
        elif [[ ${OPTION} =~ ^(exi(t)?)$ ]]; then
            DECLARATIONS["exitLabel"]="${VALUE}";
        elif [[ ${OPTION} =~ ^(n(o)?)$ ]]; then
            DECLARATIONS["noLabel"]="${VALUE}";
        elif [[ ${OPTION} =~ ^(y(e(s)?)?)$ ]]; then
            DECLARATIONS["yesLabel"]="${VALUE}";
        fi

        return 0;
    }

    function changeStates() {
        local -l CHANGE="$(echo "${1}" | cut -d '=' -f 1)" STATE="$(echo "${1}" | cut -d '=' -f 2)";
        local -i COUNT="$(echo -n "${1}" | sed 's/[^=]//g' | wc -c)";

        function boolean() {
            if [[ "${COUNT}" -eq 1 ]]; then
                if [[ "${STATE}" =~ ^(y(e(s)?)?|t(r(u(e)?)?)?|0)$ ]]; then
                    BOOLEAN["${1}"]="true";
                else
                    BOOLEAN["${1}"]="false";
                fi
            elif [[ "${BOOLEAN["${1}"]}" == 'true' ]]; then
                BOOLEAN["${1}"]="false";
            else
                BOOLEAN["${1}"]="true";
            fi

            return 0;
        }

        if [[ ${CHANGE} =~ ^(c(l(e(a(r(s(c(r(e(e(n)?)?)?)?)?)?)?)?)?)?)$ ]]; then
            boolean "clearScreen";
        elif [[ ${CHANGE} =~ ^(a(s(c(i(i(l(i(n(e(s)?)?)?)?)?)?)?)?)?)$ ]]; then
            boolean "asciiLines";
        elif [[ ${CHANGE} =~ ^(nook)$ ]]; then
            boolean "noOk";
        elif [[ ${CHANGE} =~ ^(noot(a(g(s)?)?)?)$ ]]; then
            boolean "noTags";
        elif [[ ${CHANGE} =~ ^(keepw(i(n(d(o(w)?)?)?)?)?)$ ]]; then
            boolean "keepWindow";
        elif [[ ${CHANGE} =~ ^(ig(n(o(r(e)?)?)?)?)$ ]]; then
            boolean "ignore";
        elif [[ ${CHANGE} =~ ^(noco(l(l(a(p(s(e)?)?)?)?)?)?)$ ]]; then
            boolean "noColapse";
        elif [[ ${CHANGE} =~ ^(nol(i(n(e(s)?)?)?)?)$ ]]; then
            boolean "noLines";
        elif [[ ${CHANGE} =~ ^(noca(n(c(e(l)?)?)?)?)$ ]]; then
            boolean "noCancel";
        elif [[ ${CHANGE} =~ ^(d(e(f(a(u(l(t(n(o)?)?)?)?)?)?)?)?)$ ]]; then
            boolean "defaultNo";
        elif [[ ${CHANGE} =~ ^(in(s(e(c(u(r(e)?)?)?)?)?)?)$ ]]; then
            boolean "insecure";
        elif [[ ${CHANGE} =~ ^(nos(h(a(d(o(w)?)?)?)?)?)$ ]]; then
            boolean "noShadow";
        elif [[ ${CHANGE} =~ ^(q(u(o(t(e(d)?)?)?)?)?)$ ]]; then
            boolean "quoted";
        elif [[ ${CHANGE} =~ ^(nom(o(u(s(e)?)?)?)?)$ ]]; then
            boolean "noMouse";
        elif [[ ${CHANGE} =~ ^(si(n(g(l(e(q(u(o(t(e(d)?)?)?)?)?)?)?)?)?)?)$ ]]; then
            boolean "singleQuoted";
        elif [[ ${CHANGE} =~ ^(sh(a(d(o(w)?)?)?)?)$ ]]; then
            boolean "shadow";
        elif [[ ${CHANGE} =~ ^(keept(i(t(e)?)?)?)$ ]]; then
            boolean "keepTite";
        elif [[ ${CHANGE} =~ ^(sc(r(o(l(l(b(a(r)?)?)?)?)?)?)?)$ ]]; then
            boolean "scrollbar";
        fi

        return 0;
    }

    function setVariant() {
        if [[ ${1,,} =~ ^(ca(l(e(n(d(e(r)?)?)?)?)?)?)$ ]]; then
            VARIANT="--calendar";
        elif [[ ${1,,} =~ ^(b(u(i(l(d(l(i(s(t)?)?)?)?)?)?)?)?)$ ]]; then
            VARIANT="--buildlist";
        elif [[ ${1,,} =~ ^(c(h(e(c(k(l(i(s(t)?)?)?)?)?)?)?)?)$ ]]; then
            VARIANT="--checklist";
        elif [[ ${1,,} =~ ^(d(s(e(l(e(c(t)?)?)?)?)?)?)$ ]]; then
            VARIANT="--dselect";
        elif [[ ${1,,} =~ ^(fs(e(l(e(c(t)?)?)?)?)?)$ ]]; then
            VARIANT="--fselect";
        elif [[ ${1,,} =~ ^(e(d(i(t(b(o(x)?)?)?)?)?)?)$ ]]; then
            VARIANT="--editbox";
        elif [[ ${1,,} =~ ^(fo(r(m)?)?)$ ]]; then
            VARIANT="--form";
        elif [[ ${1,,} =~ ^(tailbox)$ ]]; then
            VARIANT="--tailbox";
        elif [[ ${1,,} =~ ^(tailbox(b(g)?)?)$ ]]; then
            VARIANT="--tailboxbg";
        elif [[ ${1,,} =~ ^(te(x(t(b(o(x)?)?)?)?)?)$ ]]; then
            VARIANT="--textbox";
        elif [[ ${1,,} =~ ^(ti(m(e(b(o(x)?)?)?)?)?)$ ]]; then
            VARIANT="--timebox";
        elif [[ ${1,,} =~ ^(tr(e(e(v(i(e(w)?)?)?)?)?)?)$ ]]; then
            VARIANT="--treeview";
        elif [[ ${1,,} =~ ^(inf(o(b(o(x)?)?)?)?)$ ]]; then
            VARIANT="--infobox";
        elif [[ ${1,,} =~ ^(inputb(o(x)?)?)$ ]]; then
            VARIANT="--inputbox";
        elif [[ ${1,,} =~ ^(inputm(e(n(u)?)?)?)$ ]]; then
            VARIANT="--inputmenu";
        elif [[ ${1,,} =~ ^(me(n(u)?)?)$ ]]; then
            VARIANT="--menu";
        elif [[ ${1,,} =~ ^(mixedf(o(r(m)?)?)?)$ ]]; then
            VARIANT="--mixedform";
        elif [[ ${1,,} =~ ^(mixedg(a(u(g(e)?)?)?)?)$ ]]; then
            VARIANT="--mixedgauge";
        elif [[ ${1,,} =~ ^(g(a(u(g(e)?)?)?)?)$ ]]; then
            VARIANT="--gauge";
        elif [[ ${1,,} =~ ^(ms(g(b(o(x)?)?)?)?)$ ]]; then
            VARIANT="--msgbox";
        elif [[ ${1,,} =~ ^(password(f(o(r(m)?)?)?)?)$ ]]; then
            VARIANT="--passwordform";
        elif [[ ${1,,} =~ ^(password(b(o(x)?)?)?)$ ]]; then
            VARIANT="--passwordbox";
        elif [[ ${1,,} =~ ^(pau(s(e)?)?)$ ]]; then
            VARIANT="--pause";
        elif [[ ${1,,} =~ ^(prg(b(o(x)?)?)?)$ ]]; then
            VARIANT="--prgbox";
        elif [[ ${1,,} =~ ^(progra(m(b(o(x)?)?)?)?)$ ]]; then
            VARIANT="--programbox";
        elif [[ ${1,,} =~ ^(progr(e(s(s(b(o(x)?)?)?)?)?)?)$ ]]; then
            VARIANT="--progressbox";
        elif [[ ${1,,} =~ ^(rad(i(o(l(i(s(t)?)?)?)?)?)?)$ ]]; then
            VARIANT="--radiolist";
        elif [[ ${1,,} =~ ^(ran(g(e(b(o(x)?)?)?)?)?)$ ]]; then
            VARIANT="--rangebox";
        elif [[ ${1,,} =~ ^(y(e(s(n(o)?)?)?)?)$ ]]; then
            VARIANT="--yesno";
        fi

        return 0;
    }

    while getopts :t:r:s:v:af OPT; do
        case ${OPT} in
            v) setVariant "${OPTARG}";;
            a) AUTO_SIZE="false";;
            f) FULL_SCREEN="true";;
            t) setTextOptions "${OPTARG}";;
            s) changeStates "${OPTARG}";;
            r) REMOVE="${OPTARG}";;
        esac
    done

    shift "$((OPTIND - 1))";

    if "${FULL_SCREEN}"; then
        BOOLEAN["noShadow"]="true";
        SIZE=(
            ["width"]="$(tput cols)"
            ["hieght"]="$(tput lines)"
        );

    fi

    for I in "${!BOOLEAN[@]}"; do
        if "${BOOLEAN["${I}"]}"; then
            PARAMETERS+=("${ARGUMENTS["${I}"]}");
        fi
    done

    for I in "${!DECLARATIONS[@]}"; do
        if [[ -n "${DECLARATIONS["${I}"]}" ]]; then
            if [[ "${I}" == 'title' ]]; then
                DECLARATIONS["${I}"]="┤ ${DECLARATIONS["${I}"]} ├";
            fi

            PARAMETERS+=("${ARGUMENTS["${I}"]}" "${DECLARATIONS["${I}"]}");
        fi
    done

    OPTIONS+=("${VARIANT}" "${1}");
    shift;

    if grep -q -P '^(--(((t(ext|ail))|progr(am|ess)|msg|info)box(?(4)(bg))?|yesno))$' <(echo "${VARIANT}"); then
        DIALOG_RESPONSE="$(dialog "${PARAMETERS[@]}" "${OPTIONS[@]:0:2}" "${AUTO_SIZE:-"${SIZE["hieght"]}"}" "${AUTO_SIZE:-"${SIZE["width"]}"}" 3>&1 1>&2 2>&3)";
    else
        INDEX=1;
        if grep -q -P '^(--((mixed|password)?form|(input)?menu|(radio|check)list|treeview))$' <(echo "${VARIANT}"); then
            OPTIONS+=("${AUTO_SIZE:-"${SIZE["hieght"]}"}");
        fi

        for I in "${@}"; do
            if [[ "$(echo -n "${I}" | sed 's/[^=]//g' | wc -c)" -eq 1 && "$(echo -n "${I,,}" | cut -d '=' -f 2)" == 'on' ]]; then
                SELECTED="true";
                I="$(echo "${I}" | cut -d '=' -f 1)";
            fi

            if grep -Pq '^(--(((input)?menu|(radio|check)list|treeview))$' <(echo "${VARIANT}"); then
                OPTIONS+=("${INDEX}" "${I}");
            elif grep -Pq '^(--(password|mixed)?form)$'  <(echo "${VARIANT}"); then
                DEFAULTS["label"]="$(echo "${I}" | cut -d '=' -f '1')";
                DEFAULTS["value"]="$(echo "${I}" | cut -s -d '=' -f '2')";

                if [[ -z "${DEFAULTS["value"]}" ]]; then
                    DEFAULTS["value"]="";
                fi

                OPTIONS+=(  
                    " ${DEFAULTS["label"]}: "
                    "${INDEX}"
                    "0"
                    "${DEFAULTS["value"]}"
                    "${INDEX}"
                    "$((${#DEFAULTS["label"]} + 4))"
                    "$((${SIZE["width"]} - ${#DEFAULTS["label"]} - 10))"
                    "0"
                );
            else
                OPTIONS+=("${I}");
            fi

            ((INDEX++));

            if grep -Pq '^(--(build|radio|check)list)$' <(echo "${VARIANT}"); then
                if "${SELECTED}"; then
                    OPTIONS+=("on");
                    SELECTED="false";
                else
                    OPTIONS+=("off");
                fi
            fi
        done

        DIALOG_RESPONSE="$(dialog "${PARAMETERS[@]}" "${OPTIONS[@]:0:2}" "${AUTO_SIZE:-"${SIZE["hieght"]}"}" "${AUTO_SIZE:-"${SIZE["width"]}"}" "${OPTIONS[@]:2}" 3>&1 1>&2 2>&3)";
    fi
            

    echo dialog "${PARAMETERS[@]}" "${OPTIONS[@]:0:2}" "${AUTO_SIZE:-"${SIZE["hieght"]}"}" "${AUTO_SIZE:-"${SIZE["width"]}"}" "${OPTIONS[@]:2}" 3>&1 1>&2 2>&3
    DIALOG_EXIT_STATUS="${?}";
    return "${DIALOG_EXIT_STATUS:-0}";
}





