#!/bin/bash

source "./lib/configuration-utils.sh";
libraries;

function queue() {

    return 0;
}

function linkedStrings() {

    local OPTARG OPT KEY;
    local -a KEYS VALUES;
    local -i OPTIND;
    local -A STRING_PROPERTIES=(
        ["values"]=""
        ["s"]=""
        ["p"]=""
    );

local -n REFERENCE;
STRING

    while getopts :s:p: OPT; do
        case ${OPT} in
            s|p) STRING_PROPERTIES["${OPT}"]="${OPTARG}";;
        esac
    done

    shift "$((OPTIND - 1))";

    fieldManager -d '=' "${STRING_PROPERTIES["s"]}";
    REFERENCE="${FIELDS[0]}"

    KEY=("${FIELDS[1]}");

    KEYS=($(fieldManager -pu "${KEY}"));
    VALUES=($(fieldManager -pu "${REF[${KEY}]}"));

    if [[ "${#VALUES[@]}" -eq "${#KEYS[@]}" ]]; then
        fieldManager "${STRING_PROPERTIES["s"]}";

        for ((OPTIND=0; OPTIND < "${#KEYS[@]}"; OPTIND++)); do
            # if [[ "${KEYS["${OPTIND}"]}" == "${FIELDS[0]}" ]]; then
            #     STRING_PROPERTIES["values"]="";
            # else
            #     :
            # fi
        echo "${KEYS["${OPTIND}"]}";
        done
    fi

#    local -A STRING["${FIELDS[0]}"]="${FIELDS[1]}";

#     if [[ -n "${STRING_PROPERTIES["s"]}" ]]; then
#         local -n REF="${STRING_PROPERTIES["s"]}";
#         KEYS=($(fieldManager -pu "${!REF[@]}"));
#         VALUES=($(fieldManager -pu "${REF[@]}"));
#     fi

    return 0;
}

linkedStrings

declare -A DICT=(
    ["a,b,c"]="1,2,3"
);

 linkedStrings -s 'DICT=a,b,c' -v 'a,true,false';