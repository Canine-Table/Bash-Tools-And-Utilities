#!/bin/bash

source "./lib/configuration-utils.sh";
libraries;

#awkBorder "$(jq -r '.miscellaneous.lorumIpsum[1]' 'etc/db.json')";
#fieldManager -p -q s -s 'hello world, this is ,tom ,and,jerry'
#jq -r '.miscellaneous.lorumIpsum[1]' 'etc/db.json'


function queue() {

    return 0;
}







# function awkBorder() {

    # local OPT OPTARG ARR;
    # local -i OPTIND;
    # local -a DOCUMENTS;
    # local -Ai BORDER_PROPERTIES=(
    #     ["lines"]="$(tput lines)"
    #     ["columns"]="$(tput cols)"
    #     ["leftMargin"]="1"
    #     ["leftPadding"]="1"
    #     ["rightMargin"]="1"
    #     ["rightPadding"]="1"
    # );

    # for ARR in "${@}"; do
    #     [[ -f "${ARR}" && -r "${ARR}" ]] && DOCUMENTS+=("$(cat "${ARR}")") || DOCUMENTS+=("${ARR}");
    # done

    # for ((OPTIND=0; OPTIND < "${#DOCUMENTS[@]}"; OPTIND++)); do
    #     echo -e "\n\n${DOCUMENTS["${OPTIND}"]}\n\n" | awk -v properties="${BORDER_PROPERTIES[*]}" -f "${LIB_DIR}/awk-lib/awk-utils.awk" -f "${LIB_DIR}/awk-lib/borders.awk"
    # done
    
#     return 0;
# }

# awkBorder


awkDynamicBorders() {

    function setCommands() {
        fieldManager "${OPTARG}";
        COMMANDS+=("${FIELDS[@]}")
        return 0;
    }

    local -i OPTIND;
    local OPT OPTARG;
    local -a COMMANDS PARAMETERS;
    local -A BORDER_PROPERTIES=(
        ["label"]=""
        ["columns"]="$(tput cols)"
        ["wordWrap"]="false"
        ["style"]="single"
    );

    while getopts :s:l:c:C:W OPT; do
        case ${OPT} in
            l) BORDER_PROPERTIES["label"]="${OPTARG}";;
            s) BORDER_PROPERTIES["style"]="$(awkCompletion "${OPTARG}" {"single","double"})";;
            c) setCommands;;
            W) BORDER_PROPERTIES["wordWrap"]="true";;
            C) [[ ${OPTARG} =~ ^[[:digit:]]+$ && "${OPTARG}" -gt 6 && "${OPTARG}" -lt "$(tput cols)" ]] && BORDER_PROPERTIES["columns"]="${OPTARG}";;
        esac
    done

    shift "$((OPTIND - 1))";

    if [[ -n "${COMMANDS[@]}" ]]; then
        for ((OPTIND=0; OPTIND < "${#COMMANDS[@]}"; OPTIND++)); do

            if [[ "${OPTIND}" -eq 0 ]]; then
                if [[ -n "${BORDER_PROPERTIES["label"]}" ]]; then
                    PARAMETERS+=('-v' "label=${BORDER_PROPERTIES["label"]}");
                else
                    PARAMETERS+=("-v" "header=true");
                fi
            fi

            if [[ "$((OPTIND + 1))" -eq "${#COMMANDS[@]}" ]]; then
                PARAMETERS+=("-v" "footer=true");
            fi

            if command -v "$(cut -d ' ' -f 1 <<< "${COMMANDS["${OPTIND}"]}")" &> '/dev/null'; then
                COMMANDS["${OPTIND}"]="$(eval "${COMMANDS["${OPTIND}"]}")";
            elif [[ -f "${COMMANDS["${OPTIND}"]}" && -r "${COMMANDS["${OPTIND}"]}" ]]; then
                COMMANDS["${OPTIND}"]="$(cat "${COMMANDS["${OPTIND}"]}")";
            fi

            if "${BORDER_PROPERTIES["wordWrap"]}"; then
                PARAMETERS+=("-v" "wordWrap=${BORDER_PROPERTIES["wordWrap"]}");
            fi

            PARAMETERS+=("-v" "style=${BORDER_PROPERTIES["style"]}");

            echo -n "${COMMANDS["${OPTIND}"]}" | awk "${PARAMETERS[@]}" -v columns="${BORDER_PROPERTIES["columns"]}" -f './lib/awk-lib/awk-utils.awk' -f './lib/awk-lib/dynamic-border.awk' 2> '/dev/null';

            if [[ -n "${PARAMETERS[@]}" ]]; then
                unset PARAMETERS;
            fi
        done
    else
        return 1;
    fi

    return 0;
}

#-c "ls -al"
#awkDynamicBorders -s 'd' -c "ls -al"  -c "ls" -c "  s s Lorem ipsum dolor sit amet"
#awkDynamicBorders -s 'd' -c "ls -al"  -c "ls" -c "  s s Lorem ipsum dolor sit amet"
awkDynamicBorders -C 16 -c "ls --color=always" -l "-fxssssfssf" # 's s Lorem ipsum dolor sit amet 3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412737245870066063155881748815209209628292540917153643678925903600113305305488204665213841469519415116094330572703657595919530921861173819326117931051185480744623799627495673518857527248912279381830119491298336733624406566430860213949463952247371907021798609437027705392171762931767523846748184676694051320005681271452635608277857713427577896091736371787214684409012249534301465495853710507922796892589235420199561121290219608640344181598136297747713099605187072113499999983729780499510597317328160963185950244594553469083026425223082533446850352619311881710100031378387528865875332083814206171776691473035982534904287554687311595628638823537875937519577818577805321712268066130019278766111959092164201989   s s Lorem ipsum dolor sit amet')" #-l 'hello world' #-c "  s s Lorem ipsum dolor sit amet 3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412737245870066063155881748815209209628292540917153643678925903600113305305488204665213841469519415116094330572703657595919530921861173819326117931051185480744623799627495673518857527248912279381830119491298336733624406566430860213949463952247371907021798609437027705392171762931767523846748184676694051320005681271452635608277857713427577896091736371787214684409012249534301465495853710507922796892589235420199561121290219608640344181598136297747713099605187072113499999983729780499510597317328160963185950244594553469083026425223082533446850352619311881710100031378387528865875332083814206171776691473035982534904287554687311595628638823537875937519577818577805321712268066130019278766111959092164201989   s s Lorem ipsum dolor sit amet"

# function linkedStrings() {

#     local OPTARG OPT KEY;
#     local -a KEYS VALUES;
#     local -i OPTIND;
#     local -A STRING_PROPERTIES=(
#         ["values"]=""
#         ["s"]=""
#         ["p"]=""
#     );

#     while getopts :s:p: OPT; do
#         case ${OPT} in
#             s|p) STRING_PROPERTIES["${OPT}"]="${OPTARG}";;
#         esac
#     done

#     shift "$((OPTIND - 1))";

#     fieldManager -d '=' "${STRING_PROPERTIES["s"]}";
#     local -n REF="${FIELDS[0]}"

#     KEY=("${FIELDS[1]}");

#     KEYS=($(fieldManager -pu "${KEY}"));
#     VALUES=($(fieldManager -pu "${REF[${KEY}]}"));

#     if [[ "${#VALUES[@]}" -eq "${#KEYS[@]}" ]]; then
#         fieldManager "${STRING_PROPERTIES["s"]}";

#         for ((OPTIND=0; OPTIND < ${#KEYS[@]}"; OPTIND++)); do
#             if [[ "${KEYS["${OPTIND}"]}" == "${FIELDS[0]}" ]]; then
#                 STRING_PROPERTIES["values"]=""
#             else
#                 :
#             fi
#         done
#     fi

        # echo "${VALUES[@]}"
        # echo "${KEYS[@]}"
#    local -A STRING["${FIELDS[0]}"]="${FIELDS[1]}";
#    echo "${!STRING[@]}"
#echo    "${["${FIELDS[1]}"]}"
    # if [[ -n "${STRING_PROPERTIES["s"]}" ]]; then
    #     local -n REF="${STRING_PROPERTIES["s"]}";
    #     KEYS=($(fieldManager -pu "${!REF[@]}"));
    #     VALUES=($(fieldManager -pu "${REF[@]}"));
    #     echo "${KEYS[@]}"
    # fi

#     return 0;
# }


# declare -A DICT=(
#     ["a,b,c"]="1,2,3"
# );

# linkedStrings -s 'DICT=a,b,c' -v 'a,true,false';