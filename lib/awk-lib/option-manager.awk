{
    sub(/.*=\(/, ""); 
    $0 = substr($0, 1, length($0) - 2);

    entry_count = split($0, entries, /\]="|" \[|^\[/);

    if (entry_count < 2) {
        delete entries;
        exit 10;
    }

    for (entry_index = 1; entry_index <= entry_count; entry_index++) {
        # keys
        if ((entry_index % 2) == 0) {
            key = entries[entry_index];
            key_indexes[++key_count] = key;
        } else {
            value_indexes[key] = entries[entry_index];
        }
    }

    delete entries;

    # TODO: query section
    if (length(query) > 0) {
        for (entry_index = 1; entry_index <= key_count; entry_index++) {
            printf value_indexes[key_indexes[entry_index]];

            if (entry_index < key_count) {
                printf "\n";
            }
        }
    }



    # options manager section
    entry_count = split(add, entries, /('|")?=/);

    if (entry_count > 2) {
        delete entries;
        exit 11;
    }

}