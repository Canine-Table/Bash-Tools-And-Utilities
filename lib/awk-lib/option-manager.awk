{
    sub(/.*=\(/, ""); 
    $0 = substr($0, 1, length($0) - 2);

    entry_count = split($0, entries, /\]="|" \[|^\[/);

    if (entry_count < 2) {
        delete entries;
        exit 10;
    }

    for (entry_index = 1; entry_index <= entry_count; entry_index++) {
        # keys pairs
        if ((entry_index % 2) == 0) {
            key_pair = entries[entry_index];
            key_indexes[++key_count] = key_pair;
        } else {
            value_indexes[key_pair] = entries[entry_index];
        }
    }

    delete entries;

    if (length(query) > 0) {
        index_range_count = split(index_range, start_stop_skip, /:/);

        if (start_stop_skip[1] !~ /^[[:digit:]]+$/ || start_stop_skip[1] < 1 || start_stop_skip[1] > key_count) {
            start_stop_skip[1] = 1;
        }

        if (start_stop_skip[2] !~ /^[[:digit:]]+$/ || start_stop_skip[2] < start_stop_skip[1] || start_stop_skip[2] > key_count) {
            start_stop_skip[2] = key_count;
        }

        if (start_stop_skip[3] !~ /^[[:digit:]]+$/ || start_stop_skip[3] < 1) {
            start_stop_skip[3] = 1;
        }

        for (; start_stop_skip[1] <= start_stop_skip[2]; start_stop_skip[1] += start_stop_skip[3]) {

            if (query == "both") {
                printf "[\"" key_indexes[start_stop_skip[1]] "\"]=\"" value_indexes[key_indexes[start_stop_skip[1]]] "\"";
            } else if (query == "keys") {
                printf key_indexes[start_stop_skip[1]];
            } else if (query == "values") {
                printf value_indexes[key_indexes[start_stop_skip[1]]];
            } else {
                delete start_stop_skip key_indexes value_indexes;
                exit 13;
            }

            if ((start_stop_skip[1] + start_stop_skip[3]) <= key_count) {
                printf "\n";
            }
        }

        delete start_stop_skip key_indexes value_indexes;
        exit 0;
    }


    if (length(radio) > 0) {
        radio_count = split(radio, radio_group, /,/);
    }

    for (entry_index = 1; entry_index <= key_count; entry_index++) {

        if (length(radio) > 0) {
            for (radio_index = 1; radio_index <= radio_count; radio_index++) {
                if (radio_group[radio_index] == key_indexes[entry_index]) {
                    delete key_indexes value_indexes radio_group;
                    exit 12;
                }
            }
        }

        if (key_indexes[entry_index] == key) {
            if (modify == "true") {
                break;
            } else {
                delete key_indexes value_indexes radio_group;
                exit 11;
            }
        }
    }

    printf "[\"" key "\"]=\"" value "\"";
    delete key_indexes value_indexes radio_group;
    exit 0
}