# create the BIN_DIR global variable if it does not already exist. Use this variable to access the absolute of this scripts location.
export | grep -q 'declare -x BIN_DIR=' || export BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function indexers() {
    source "${BIN_DIR}/../lib/configuration-utils.sh";
    libraries;

#    local -A "A=($(database -r -f '.systemInformation.di'))"


    local -a B=(
        "this"
    );

#awkFieldManager -d '=' -p 'h=yu'
#echo ${#FIELDS[@]}
#typing BS
#echo "${A['packageManager']}"
#database -r -f '.systemInformation.di'

#     isUniqueEntry -A B 'tis'
#     isUniqueEntry -Q B 'th'
declare -A ARRAY=(
    ['xs']='fr'
);
#set -x
 #   isUniqueEntry -Q -p 's' B   ;

    isUniqueKey -p 'za=ss' ARRAY;
#set +x

#    echo "${A[@]}"
#    awkFieldManager -p  'a,hello,this,is,tom'

    return 0;

}

indexers;