BEGIN {

    parameter_count = split(parameters, parameter_list, delimiter);

    if (length(string) > 0) {
        for (character_index = 1; character_index <= (length(string) + 1); character_index++) {

            characters = "^" substr(string, 1, character_index);

            for (parameter_index = 1; parameter_index <= parameter_count; parameter_index++) {
                if (substr(parameter_list[parameter_index], 1, character_index) !~ characters) {
                    delete parameter_list[parameter_index];
                } else if (length(parameter_list) == 1) {
                    characters = "^" string;

                    if (parameter_list[parameter_index] ~ characters) {

                        for (remainder in parameter_list) {
                            printf parameter_list[remainder];
                        }

                        delete parameter_list;
                        exit 0;
                    }

                    no_match_found = "true";
                }

                if (length(parameter_list) == 0 || no_match_found == "true") {
                    gsub(delimiter, "█", parameters);
                    printf "The string '" string "' did not match any of the following parameters:█" parameters;
                    exit 2;
                }
            }

            if (character_index == length(string) && length(parameter_list) > 1) {
                printf "The string '" string "' is to ambiguous. The string still matches the following '" length(parameter_list) "' options:█"
                for (remainder in parameter_list) {
                    printf parameter_list[remainder] "█";
                }

                delete parameter_list;
                exit 3;
            }
        }
    } else {
 
        for (parameter_index = 1; parameter_index <= parameter_count; parameter_index++) {

            compare_string = substr(parameter_list[parameter_index], 1, 1);

            do {

                unique_string = 1;

                for (string_index = 1; string_index <= parameter_count; string_index++) {
                    if (string_index != parameter_index && compare_string == substr(parameter_list[string_index], 1, length(compare_string))) {
                        unique_string = 0;
                        break;
                    }
                } 

                if (unique_string == 0) {
                    if (length(compare_string) < length(parameter_list[parameter_index])) {
                        compare_string = substr(parameter_list[parameter_index], 1, length(compare_string) + 1);
                    } else {
                        break;
                    }
                }

            } while (unique_string == 0);

            closing_string = "";

            printf parameter_list[parameter_index] ",^(" compare_string;

            for (remaining_string = length(compare_string) + 1; remaining_string <= length(parameter_list[parameter_index]); remaining_string++) {
                printf "(" substr(parameter_list[parameter_index], remaining_string, 1)
                closing_string = closing_string ")?";
            }

            print closing_string ")$";
        }
    }

    delete parameter_list;
    exit 0;
}
