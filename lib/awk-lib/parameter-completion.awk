BEGIN {
    # Splits the parameters into a list using the provided delimiter.

    if (length(delimiter) == 0) {
        delimiter = ":";
    } else if (length(delimiter) > 1) {
        delimiter = substr(parameter_delimiter, 1, 1);
    }

    if (length(parameter_delimiter) == 0) {
        if (delimiter == ",") {
            parameter_delimiter = ":";
        } else {
            parameter_delimiter = ",";
        }
    } else if (length(parameter_delimiter) == 0) {
        parameter_delimiter = substr(parameter_delimiter, 1, 1);
    }

    parameter_count = split(parameters, parameter_list, delimiter);

    # If the string length is greater than 0, it enters the first condition.
    if (length(string) > 0) {

        parameter_delimiter = ".*" parameter_delimiter;

        for (parameter_index = 1; parameter_index <= parameter_count; parameter_index++) {
            if (match(parameter_list[parameter_index], parameter_delimiter)) {
                return_parameter[parameter_index] = substr(parameter_list[parameter_index], RSTART , RLENGTH - 1);
                parameter_list[parameter_index] = substr(parameter_list[parameter_index], RSTART + RLENGTH);
            } else {
                return_parameter[parameter_index] = parameter_list[parameter_index];
            }
        }

        # Iterates over each character in the string.
        for (character_index = 1; character_index <= (length(string) + 1); character_index++) {
            # Creates a regex pattern starting with the caret symbol and the substring of the string up to the current character index.
            characters = "^" substr(string, 1, character_index);

            # Iterates over each parameter in the parameter list.
            for (parameter_index = 1; parameter_index <= parameter_count; parameter_index++) {
                # If the substring of the current parameter does not match the regex pattern, it deletes the parameter from the list.
                if (substr(parameter_list[parameter_index], 1, character_index) !~ characters) {
                    delete parameter_list[parameter_index];
                } else if (length(parameter_list) == 1) {
                    # If there is only one parameter left in the list, it checks if the parameter matches the string.
                    characters = "^" string;

                    if (parameter_list[parameter_index] ~ characters) {
                        # If the parameter matches the string, it prints the parameter and exits the program.
                        for (remainder in parameter_list) {
                            printf return_parameter[remainder];
                        }

                        delete return_parameter;
                        delete parameter_list;
                        exit 0;
                    }

                    no_match_found = "true";
                }

                # If there are no parameters left in the list or no match was found, it prints an error message and exits the program.
                if (length(parameter_list) == 0 || no_match_found == "true") {
                    gsub(delimiter, "█", parameters);
                    printf "The string '" string "' did not match any of the following parameters:█" parameters;
                    exit 2;
                }
            }

            # If the character index equals the string length and there is more than one parameter left in the list, it prints an error message and exits the program.
            if (character_index == length(string) && length(parameter_list) > 1) {
                printf "The string '" string "' is too ambiguous. The string still matches the following '" length(parameter_list) "' options:█";
                for (remainder in parameter_list) {
                    printf parameter_list[remainder] "█";
                }

                delete parameter_list;
                delete return_parameter;
                exit 3;
            }
        }
    } else {
        # If the string length is 0, it enters the second condition.
        for (parameter_index = 1; parameter_index <= parameter_count; parameter_index++) {
            # Sets the compare string to the first character of the current parameter.
            compare_string = substr(parameter_list[parameter_index], 1, 1);

            do {
                # Sets the unique string flag to 1.
                unique_string = 1;

                # Iterates over each parameter in the parameter list.
                for (string_index = 1; string_index <= parameter_count; string_index++) {
                    # If the string index does not equal the parameter index and the compare string equals the substring of the current string, it sets the unique string flag to 0.
                    if (string_index != parameter_index && compare_string == substr(parameter_list[string_index], 1, length(compare_string))) {
                        unique_string = 0;
                        break;
                    }
                } 

                # If the unique string flag is 0 and the length of the compare string is less than the length of the current parameter, it increases the length of the compare string by 1.
                if (unique_string == 0) {
                    if (length(compare_string) < length(parameter_list[parameter_index])) {
                        compare_string = substr(parameter_list[parameter_index], 1, length(compare_string) + 1);
                    } else {
                        break;
                    }
                }

            } while (unique_string == 0);

            closing_string = "";

            # Depending on the formatting, it prints the parameter and the compare string in a specific format.
            if (formating == "associative") {
                printf "[\"" parameter_list[parameter_index] "\"]=\"^(" compare_string;

            } else if(formating == "indexed") {
                printf "[" (indexed++) "]=\"" parameter_list[parameter_index] ",^(" compare_string;
            } else {
                printf parameter_list[parameter_index] ",^(" compare_string;
            }

            # Iterates over the remaining characters in the current parameter.
            for (remaining_string = length(compare_string) + 1; remaining_string <= length(parameter_list[parameter_index]); remaining_string++) {
                printf "(" substr(parameter_list[parameter_index], remaining_string, 1);
                closing_string = closing_string ")?";
            }

            printf closing_string ")$";

            if (length(formating) > 0) {
                print "\"";
            } else {
                print;
            }
        }

        delete parameter_list;
        exit 0;
    }
}