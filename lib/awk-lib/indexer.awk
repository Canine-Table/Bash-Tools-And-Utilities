BEGIN {

    if (key_or_value != "key" && key_or_value != "value") {
        key_or_value = "key and value";
    }

    array = substr(array, 1, length(array) - 1);
    key_value_indexes = 0;
    
    while (match(array, /\[.*\].*/)) {
        indexes = substr(array, RSTART, RSTART + RLENGTH);
        regexpr = "\" [.*].*";
        gsub(regexpr, "\"", indexes);;
        split(indexes, key_value_pairs, "]=\"");
        sub(/^\[/, "", key_value_pairs[1]);
        regexpr = "\".*$";
        sub(regexpr, "", key_value_pairs[2]);
        key_value_indexes++
        keys[key_value_indexes] = key_value_pairs[1];
        values[key_value_indexes] = key_value_pairs[2];
        array = substr(array, RSTART + 1);
    }

    delete key_value_pairs;
    indexes = arrayIndexer(key_value_indexes, index_range);
    split(indexes, start_stop_skip, ",");

    for (range = start_stop_skip[1]; range <= start_stop_skip[2]; range += start_stop_skip[3]) {
        if (key_or_value == "key") {
            printf keys[range];
        } else if (key_or_value == "value") {
            printf values[range];
        } else {
            printf keys[range] "=" values[range];
        }

        if (range + start_stop_skip[3] <= start_stop_skip[2]) {
            print;
        }
    }

    delete start_stop_skip;
}