# create the BIN_DIR global variable if it does not already exist. Use this variable to access the absolute of this scripts location.
export | grep -q 'declare -x BIN_DIR=' || export BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function wireless() {
    source "${BIN_DIR}/../lib/configuration-utils.sh";
    libraries;

    local INVALID;
    local -A DIALOG_RESPONSE DIALOG_INPUT;

    while "${INVALID:-true}"; do
        INVALID='false';
        dialogFactory DIALOG_INPUT \
            -V 'form' \
            -L 'ok=(Title)generate' \
            -L 'title=(Title)wireless configuration form' \
            -L 'message=Please fill in form, your configurations will be generated and stored in /tmp/wireless. Enjoy :D' \
            "(Required) Station Number=${DIALOG_RESPONSE[1]}" \
            "(Required) Student ID=${DIALOG_RESPONSE[2]}" \
            "(Optional) Mac Address=${DIALOG_RESPONSE[3]}";

        [[ $? == 1 ]] && break;

        [[ ${DIALOG_INPUT[1]} =~ ^([1-9]{1}|1[[:digit:]]{1}|2[0-5]{1})$ ]] || {
            dialogFactory \
                -V 'msg' \
                -L 'title=(Title)invalid station number' \
                -L "message=There are 25 stations, please digit to specify one, '${DIALOG_RESPONSE[1]}' is not an option." \
                -L 'ok=(Title)understood';
            INVALID='true';
        }

        [[ ${DIALOG_INPUT[2]} =~ ^([[:alpha:]]{4}[[:digit:]]{4})$ ]] || {
            dialogFactory \
                -V 'msg' \
                -L 'title=(Title)invalid sudent ID' \
                -L "message=the student id should be 8 characters starting with 4 alpha numeric characters and 4 digit. for example abcd0123 is valid, '${DIALOG_RESPONSE[1]}' is not." \
                -L 'ok=(Title)understood';
            INVALID='true';
        }
    done
}

wireless;