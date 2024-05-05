BEGIN {
    if (length(find_match) > 0) {
        if (find_match ~ /^\(KeysOnly=true\)/) {
            sub(/^\(KeysOnly=true\)/, "", find_match);
            find_match_in = "keys";
        } else if (find_match ~ /^\(ValuesOnly=true\)/) {
            sub(/^\(ValuesOnly=true\)/, "", find_match);
            find_match_in = "values";
        }
    }
} {
    # Remove everything before '=('
    sub(/.*=\(/, "");

    # Remove the first and last character of the string
    # Split the string into entries array using the given delimiters
    entry_count = split(substr($0, 1, length($0) - 2), entries, /\]="|" \[|^\[/);

    # If there are less than 2 entries, delete the entries array and exit with code 10
    if (entry_count < 2) {
        delete entries;
        exit 10;
    }

    # Loop over the entries array
    for (entry_index = 1; entry_index <= entry_count; entry_index++) {
        # If the index is even, it's a key pair
        if ((entry_index % 2) == 0) {
            key_pair = entries[entry_index];
            key_indexes[++key_count] = key_pair;
        } else {
            # If the index is odd, it's a value pair
            value_indexes[key_pair] = entries[entry_index];
        }
    }

    # Delete the entries array
    delete entries;

    # If the query length is greater than 0
    if (length(query) > 0) {
        # Split the index range into start, stop, and skip values
        index_range_count = split(index_range, start_stop_skip, /:/);

        # Validate and set the start value
        if (start_stop_skip[1] !~ /^[[:digit:]]+$/ || start_stop_skip[1] < 1 || start_stop_skip[1] > key_count) {
            start_stop_skip[1] = 1;
        }

        # Validate and set the stop value
        if (start_stop_skip[2] !~ /^[[:digit:]]+$/ || start_stop_skip[2] < start_stop_skip[1] || start_stop_skip[2] > key_count) {
            start_stop_skip[2] = key_count;
        }

        # Validate and set the skip value
        if (start_stop_skip[3] !~ /^[[:digit:]]+$/ || start_stop_skip[3] < 1) {
            start_stop_skip[3] = 1;
        }

        # Loop from start to stop with a step of skip
        for (; start_stop_skip[1] <= start_stop_skip[2]; start_stop_skip[1] += start_stop_skip[3]) {

            # if find_match is set check for and print out only the keys and or values that match the pattern
            if (length(find_match) > 0 && (! ((find_match_in != "values" && key_indexes[start_stop_skip[1]] ~ find_match) || (find_match_in != "keys" && value_indexes[key_indexes[start_stop_skip[1]]] ~ find_match)))) {
                continue;
            }

            # If the query is "both", print both key and value
            if (query == "both") {
                printf "[\"" key_indexes[start_stop_skip[1]] "\"]=\"" value_indexes[key_indexes[start_stop_skip[1]]] "\"";
            } else if (query == "keys") {
                # If the query is "keys", print only the key
                printf key_indexes[start_stop_skip[1]];
            } else if (query == "values") {
                # If the query is "values", print only the value
                printf value_indexes[key_indexes[start_stop_skip[1]]];
            } else {
                # If the query is neither "both", "keys", nor "values", delete arrays and exit with code 13
                delete start_stop_skip;
                delete key_indexes;
                delete value_indexes;
                exit 13;
            }

            # If the next index is within the key count, print a newline
            if ((start_stop_skip[1] + start_stop_skip[3]) <= key_count) {
                printf "\n";
            }
        }

        # Delete arrays and exit with code 0
        delete start_stop_skip;
        delete key_indexes;
        delete value_indexes;
        exit 0;
    }

    # If the radio length is greater than 0
    if (length(radio) > 0) {
        # Split the radio into radio group
        radio_count = split(radio, radio_group, /,/);
    }

    # Loop over the key indexes
    for (entry_index = 1; entry_index <= key_count; entry_index++) {

        # If the radio length is greater than 0
        if (length(radio) > 0) {
            # Loop over the radio group
            for (radio_index = 1; radio_index <= radio_count; radio_index++) {

                # If the radio group index is equal to the key, set radio group member to "true"
                if (radio_group[radio_index] == key) {
                    radio_group_member = "true";
                }

                # If the radio group index is equal to the key index
                if (radio_group[radio_index] == key_indexes[entry_index]) {
                    # If modify is "true", append the radio group index to the selected radio group
                    if (modify == "true") {
                        radio_group["selected"] = radio_group["selected"] "" radio_group[radio_index] "█";
                    } else {
                        # If modify is not "true", increment the selected index and append the radio group index to the radio string
                        selected_index++;
                        radio_string = radio_string "," radio_group[radio_index];
                    }
                }
            }
        } else if (key_indexes[entry_index] == key) {
            # If the key index is equal to the key
            if (modify == "true") {
                break;
            } else {
                # If modify is not "true", delete arrays and exit with code 11
                delete key_indexes;
                delete value_indexes;
                delete radio_group;
                exit 11;
            }
        }
    }

    # If the radio group member is "true"
    if (radio_group_member == "true") {

        # If the selected index is greater than 0
        if (selected_index > 0) {
            # Print the radio string without the first character, delete arrays, and exit with code 12
            printf substr(radio_string, 2, length(radio_string));
            delete key_indexes;
            delete value_indexes;
            delete radio_group;
            exit 12;
        }

        # If the selected radio group length is greater than 0
        if (length(radio_group["selected"]) > 0) {
            # Print the selected radio group
            printf radio_group["selected"];
        }
    }

    # If the selected index is greater than 1
    if (selected_index > 1) {
        # Print the radio string without the first character, delete arrays, and exit with code 13
        printf substr(radio_string, 2, length(radio_string));
        delete key_indexes;
        delete value_indexes;
        delete radio_group;
        exit 13;
    }

    # Print the key-value pair
    printf "[\"" key "\"]=\"" value "\"";

    # Delete arrays and exit with code 0
    delete key_indexes;
    delete value_indexes;
    delete radio_group;
    exit 0
}
