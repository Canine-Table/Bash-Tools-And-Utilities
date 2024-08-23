# Creates the LIB_DIR global variable if it does not already exist. Use this variable to access the absolute path of the library directory containing generic scripts.
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function libraries() {
    local FILE;

    # import all the bash functions within the files located within the library directory.
    for FILE in ${LIB_DIR}/*.sh; do
        source "${FILE}";
    done

    return 0;
}

function append_path() {
    case ":${PATH}:" in
        *:"${1}":*) return 1;;
        *) export PATH="${PATH:+$PATH:}$1";;
    esac

    return 0;
}

