# create the BIN_DIR global variable if it does not already exist. Use this variable to access the absolute of this scripts location.
export | grep -q 'declare -x BIN_DIR=' || export BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function testing() {
    source "${BIN_DIR}/../lib/configuration-utils.sh";
    libraries;

#    database -f 'systemInformation.j'
}


testing;