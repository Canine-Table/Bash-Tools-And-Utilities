#!/bin/bash

source "./lib/configuration-utils.sh";
libraries;

function queue() {

    return 0;
}


#awkDynamicBorders -c 'ls --color=always -al,pwd,hostname' -l 'hello world'
#set -x
database -p "${1}"
#set +x
