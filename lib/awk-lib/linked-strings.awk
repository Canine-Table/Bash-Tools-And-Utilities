BEGIN {
    for (key_index = 1; key_index <= keyValuePairs(hash_map); key_index++) {
        if ( keys[key_index] == key) {
            matched = "true";
        }
    }

    if (length(matched) == 0) {
        exit 1;
    }
}