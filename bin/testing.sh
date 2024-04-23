# create the BIN_DIR global variable if it does not already exist. Use this variable to access the absolute of this scripts location.
export | grep -q 'declare -x BIN_DIR=' || export BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function indexers() {
    source "${BIN_DIR}/../lib/configuration-utils.sh";
    libraries;

    local -A A=(
        ['x']="this"
        ['y']='hello'
        ['z']="world"
    );


    local -a B=(
        "this"
    );

database -r -f '.systemInformation'

#     isUniqueEntry -A B 'tis'
#     isUniqueEntry -Q B 'th'

#    isUniqueKey -Qqmp 'za=ss' -A A
#    echo "${A[@]}"
#    awkFieldManager -p  'a,hello,this,is,tom'

    return 0;

}

indexers;