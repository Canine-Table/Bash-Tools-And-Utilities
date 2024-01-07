BEGIN {

    if (key_or_value != "key" && key_or_value != "value") {
        key_or_value = "key and value";
    }
 
    indexes = arrayIndexer(keyValuePairs(array), index_range);
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