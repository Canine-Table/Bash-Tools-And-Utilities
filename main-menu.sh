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


function dialogFactory() {


    function setTextOptions() {

        local -A LABELS=(
            "title"
            "backtitle"
            "help-label"
            "ok-label"
            "no-label"
            "yes-label"            
            "extra-label"
            "exit-label"
        );



        fieldManager -d '=' "${1}";
        local -l OPTION="${FIELDS[0]}";
        fieldManager "${FIELDS[1]}";
        local VALUE="${FIELDS[0]}";
        local KEY="$(awkCompletion "${VALUE}" {title,backtitle,{ex{tra,it},yes,no,ok,help}-label})";

        if [[ "${#FIELDS[@]}" -eq 1 ]]; then
            VALUE="$(awkDescriptor "BEGIN { textCase(\"$(awkCompletion "${FIELDS[1]}" {title,lower,upper}" case")\") }")";
        fi

        # if [[ ${OPTION} =~ ^(t(i(t(l(e)?)?)?)?)$ ]]; then
        #     DECLARATIONS["title"]="${VALUE}";
        # elif [[ ${OPTION} =~ ^(b(a(c(k(t(i(t(l(e)?)?)?)?)?)?)?)?)$ ]]; then
        #     DECLARATIONS["backTitle"]="${VALUE}";
        # elif [[ ${OPTION} =~ ^(o(k)?)$ ]]; then
        #     DECLARATIONS["okLabel"]="${VALUE}";
        # elif [[ ${OPTION} =~ ^(h(e(l(p)?)?)?)$ ]]; then
        #     DECLARATIONS["helpLabel"]="${VALUE}";
        #     BOOLEAN["helpButton"]="true";
        # elif [[ ${OPTION} =~ ^(ext(r(a)?)?)$ ]]; then
        #     DECLARATIONS["extraLabel"]="${VALUE}";
        #     BOOLEAN["extraButton"]="true";
        # elif [[ ${OPTION} =~ ^(c(a(n(c(e(l)?)?)?)?)?)$ ]]; then
        #     DECLARATIONS["cancelLabel"]="${VALUE}";
        # elif [[ ${OPTION} =~ ^(exi(t)?)$ ]]; then
        #     DECLARATIONS["exitLabel"]="${VALUE}";
        # elif [[ ${OPTION} =~ ^(n(o)?)$ ]]; then
        #     DECLARATIONS["noLabel"]="${VALUE}";
        # elif [[ ${OPTION} =~ ^(y(e(s)?)?)$ ]]; then
        #     DECLARATIONS["yesLabel"]="${VALUE}";
        # fi

        return 0;
    }

    
    local -i OPTIND STATUS;
    local OPT OPTARG;

    local -A ARGUMENTS=(
        ["yes-label"]=""
        ["ok-label"]=""
        ["no-label"]=""
        ["exit-label"]=""
        ["cancel-label"]=""
        ["extra-label"]=""
        ["help-label"]=""
        ["title"]=""
        ["backtitle"]=""
        ["l"]=""
        ["c"]=""
    )

    local -A BOOLEANS=(
        ["clear"]="true"
        ["ascii-lines,no-lines"]="false,false"
        ["no-ok"]="false"
        ["no-tags"]="false"
        ["keep-window"]="false"
        ["ignore"]="true"
        ["no-collapse"]="true"
        ["no-cancel"]="false"
        ["defaultno"]="true"
        ["insecure"]="true"
        ["no-shadow,shadow"]="true,false"
        ["no-mouse"]="false"
        ["quoted,single-quoted"]="false,false"
        ["help-button"]="false"
        ["extra-button"]="false"
        ["keep-tite"]="false"
        ["scrollbar"]="false"
        ["defaultno"]="true"
    );

    while getopts :l:c:L: OPT; do
        case ${OPT} in
            l|c) ARGUMENTS["${OPT}"]="${OPTARG}";;
            L)
        esac
    done

    shift "$((OPTIND - 1))";

    for OPT in "${!BOOLEANS[@]}"; do
        if [[ ${BOOLEANS["${OPT}"]} =~ true ]]; then
            if [[ ${BOOLEANS["${OPT}"]} =~ , ]]; then
               PARAMETERS+=("--$(linkedStrings -p -f 'true' -v "BOOLEANS=${OPT}")");
            else
                PARAMETERS+=("--${OPT}");
            fi
        fi
    done

    for OPT in "${!ARGUMENTS[@]}"; do
        if [[ "${#OPT}" -gt 1 && -n "${ARGUMENTS["${OPT}"]}" ]]; then
            PARAMETERS+=("--${OPT}" "${ARGUMENTS["${OPT}"]}");
        fi
    done

    echo "${PARAMETERS[@]}";

    return "${STATUS:-0}";
}

#dialogFactory

function awkLinkedStrings() {

    return 0;
}


#awkFieldManager -- -pl -i 1 -du ',' 'hello,world,this,is,tom';
#echo {FIELDS[@]}

#awkGetOptions 'good,g:help,h|link,l|print,p|arrow,a:docker,d:r:c:e:f:' -a 'hello' -d 'world du ie ' -hlp -g xyzs "gi" "fi ddie dj" "gge  ewuwi wwe wewe w eeewew";

# function awkFieldManager() {

#     return 0;
# }

#fruits
#"$(awkCompletion -q "${@}" {raw-output,join-output}),true,false"
# fieldManager -pm -q 'double' -d '' -i '  ' "${DECLARED[@]}"
#database -p '.miscellaneous.fruits' #-v "orange";
#linkedStrings -f 'k23' -v "DECLARED=raw" #-v "${1},true,false"
#awkCompletion "${1}" {raw-output,join-output}


# #!/usr/bin/awk -f

# # Define the default field properties
# BEGIN {
#   inputFieldSeparator = " "
#   outputFieldSeparator = "\n"
#   delimiter = ","
#   string = ""
#   merge = 0
#   print = 0
#   unset = 0
#   quote = "\""
# }

# # Define a function to set the quote character
# function quote(q) {
#   if (q ~ /^('|s(i(n(g(l(e(q(u(o(t(e(s)?)?)?)?)?)?)?)?)?)?)?)$/) {
#     quote = "'"
#   } else if (q ~ /^("|d(o(u(b(l(e(q(u(o(t(e(s)?)?)?)?)?)?)?)?)?)?)?)$/ || q == "") {
#     quote = "\""
#   } else {
#     print "You did not specify a valid quotation.\nYou can choose between single and double quotes.\nDefaulting to double quotes."
#   }
# }

# # Parse the command line arguments using getopts
# function getopts(optstring, options, OPTIND, OPTARG, OPTERR) {
#   # Initialize the variables
#   OPTIND = 1
#   OPTARG = ""
#   OPTERR = 0
#   # Loop through the arguments
#   while (OPTIND <= ARGC) {
#     # Check if the argument is an option
#     if (ARGV[OPTIND] ~ /^-/) {
#       # Get the option character
#       opt = substr(ARGV[OPTIND], 2, 1)
#       # Check if the option is in the optstring
#       if (index(optstring, opt) > 0) {
#         # Set the options array
#         options[opt] = 1
#         # Check if the option requires an argument
#         if (substr(optstring, index(optstring, opt) + 1, 1) == ":") {
#           # Shift to the next argument
#           OPTIND++
#           # Check if the argument is valid
#           if (ARGV[OPTIND] ~ /^-/) {
#             # Invalid argument
#             OPTERR = 1
#             break
#           } else {
#             # Valid argument
#             OPTARG = ARGV[OPTIND]
#           }
#         }
#       } else {
#         # Invalid option
#         OPTERR = 1
#         break
#       }
#     } else {
#       # Not an option
#       break
#     }
#     # Shift to the next argument
#     OPTIND++
#   }
#   # Return the error status
#   return OPTERR
# }

# Main function
#function fieldManager() {
  # Declare the local variables
#   local optstring = "o:i:d:s:q:mpu"
#   local options[256]
#   local opt
#   local arg
#   local count
#   local i
#   local fields[256]

  # Parse the command line arguments
#   if (getopts(optstring, options, OPTIND, OPTARG, OPTERR)) {
#     # Error occurred
#     print "Invalid option or argument"
#     exit 1
#   }

  # Set the field properties according to the options
#   for (opt in options) {
#     if (options[opt]) {
#       arg = OPTARG
#       if (opt == "u") {
#         unset = 1
#       } else if (opt == "p") {
#         print = 1
#       } else if (opt == "m") {
#         merge = 1
#       } else if (opt == "q") {
#         quote(arg)
#       } else if (opt == "o") {
#         outputFieldSeparator = arg
#       } else if (opt == "i") {
#         inputFieldSeparator = arg
#       } else if (opt == "d") {
#         delimiter = arg
#       } else if (opt == "s") {
#         string = arg
#       }
#     }
#   }

  # Shift the arguments
#   for (i = OPTIND; i <= ARGC; i++) {
#     ARGV[i - OPTIND + 1] = ARGV[i]
#   }
#   ARGC -= OPTIND - 1

  # Check if the string is empty
#   if (string == "") {
#     # Use the first argument as the string
#     if (ARGC > 1) {
#       string = ARGV[1]
#     } else {
#       # No string given
#       print "String required"
#       exit 1
#     }
#   }

#   # Check if the delimiter is empty
#   if (delimiter == "") {
#     delimiter = ","
#   }

#   # Check if the merge option is set
#   if (merge) {
#     # Check if the input field separator is empty
#     if (inputFieldSeparator == "") {
#       inputFieldSeparator = " "
#     }
#     # Set the field separator to the input field separator
#     FS = inputFieldSeparator
#     # Split the string into fields
#     split(string, fields)
#     # Join the fields with the delimiter and the quote
#     string = quote fields[1] quote
#     for (i = 2; i in fields; i++) {
#       string = string delimiter quote fields[i] quote
#     }
#     # Add the quote at the beginning and the end of the string
#     string = quote string quote
#     # Store the string in the fields array
#     fields[1] = string
#     count = 1
#   } else {
#     # Check if the delimiter is longer than one character
#     if (length(delimiter) > 1) {
#       # Use only the first character
#       print "The delimiter can only be one character.\nThe first character of '" delimiter "' will be used."
#       delimiter = substr(delimiter, 1, 1)
#     }
#     # Set the field separator to the delimiter
#     FS = delimiter
#     # Split the string into fields
#     count = split(string, fields)
#     # Add the quote at the beginning and the end of each field
#     for (i = 1; i <= count; i++) {
#       fields[i] = quote fields[i] quote
#     }
#   }

#   # Print the fields according to the print option and the output field separator
#   if (print) {
#     for (i = 1; i <= count; i++) {
#       printf fields[i]
#       if (outputFieldSeparator != "" && i < count) {
#         printf outputFieldSeparator
#       }
#     }
#     print ""
#   }

#   # Unset the fields array according to the unset option
#   if (unset) {
#     delete fields
#   }

#   # Return 0
#   return 0
# }

# # Call the main function
# fieldManager()
