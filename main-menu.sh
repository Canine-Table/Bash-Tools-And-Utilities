#!/bin/bash

source "./lib/configuration-utils.sh";
libraries;

function queue() {

    return 0;
}


#awkDynamicBorders -c 'ls --color=always -al,pwd,hostname' -l 'hello world'
#set -x
#database -p "${1}"
#set +x



declare -A DECLARED=(
    ["raw-output,join-output"]="12,23"
)

#"$(awkCompletion -q "${@}" {raw-output,join-output}),true,false"
database -p '.'
#linkedStrings -f 'k23' -v "DECLARED=raw" #-v "${1},true,false"
#awkCompletion "${1}" {raw-output,join-output}