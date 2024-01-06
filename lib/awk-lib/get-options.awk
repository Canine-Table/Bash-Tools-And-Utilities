BEGIN {

    while (match(options, /:.*$/)) {
        choice_count = split(substr(options, 1, RSTART), choices, "|");
        for (choice_index = 1; choice_index <= choice_count; choice_index++) {
            required  = sub(/:$/, "", choices[choice_index]);
            split(choices[choice_index], kwargs, ",");

            if (length(kwargs) == 1) {
                kwargs[2] = kwargs[1];
            }

            for (argument_index = 1; argument_index < ARGC; argument_index++) {

                if (ARGV[argument_index] ~ /^-/) {
                    for (character = 2; character <= length(ARGV[argument_index]); character++) {
                        sub_string = substr(ARGV[argument_index], character, 1);

                        if (kwargs[2] == sub_string) {
                            string = kwargs[2] "," kwargs[1];

                            if (length(ARGV[argument_index]) > 2) {
                                gsub(sub_string, "", ARGV[argument_index])
                            } else {
                               delete ARGV[argument_index];
                            }

                            if (required  > 0) {
                                string = string "=" ARGV[argument_index + 1];
                               delete ARGV[argument_index + 1];
                            }

                            print string;
                            break;
                        }
                    }
                }
            }
        }

        options = substr(options, RSTART + 1);
    }

    printf "EOF=";
    for (argument_index = 2; argument_index <= ARGC; argument_index++) {
        if (length(ARGV[argument_index]) > 0) {
            remainder = remainder "" ARGV[argument_index] ":";
        }
    }

    if (length(remainder) > 0) {
        printf substr(remainder, 1, length(remainder) - 1);
    }
}
