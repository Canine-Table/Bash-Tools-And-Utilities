#dialog --cancel-label "1" --exit-label "2" --extra-label "3" --help-label "4" 


    # exec 9< <(
    #     echo 'BEGIN {title("hello world");}'
    # )

    # awk -f './lib/awk-lib/awk-utils.awk' -f '/dev/fd/9'
    # exec 9<&-;

source "./lib/configuration-utils.sh"
# VALUE="$(awkDescriptor "BEGIN { textCase(\"${@}\") }")";
# echo "${VALUE}";

yesNoDialog "${@}";

#dialog --no-label "31"  --yes-label "1" --extra-button --extra-label "e" --help-button --help-label "h" --yesno "yes or no" 0 0