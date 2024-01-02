BEGIN {
    while (getline word < "-") {
        words[++lines] = word;
    }
} END {

    for (i = 1; i <= lines; i++) {
        prefix = substr(words[i], 1, 1); # start with one-character prefix

        do {
            unique = 1; # assume the prefix is unique

            for (j = 1; j <= lines; j++) {
                if (i != j && prefix == substr(words[j], 1, length(prefix))) {

                    # if the prefix matches the beginning of another word
                    #  set the flag to false
                    unique = 0;

                    # exit the inner loop
                    break;
                }
            }

            if (unique == 0) {

                # if the prefix is not unique, increase its length by one
                prefix = substr(words[i], 1, length(prefix) + 1);
            }
        } while (unique == 0);
        
        # add the unique prefix
        prefixes[words[i]] = prefix;
    }

    delete words;

    for (i in prefixes) {
        suffix = i;
        closing = "";
        sub(prefixes[i], "", suffix);

        if (length(suffix) > 0) {
            word = prefixes[i];
            for (j = 1; j <= length(suffix); j++) {
                word = word "(" substr(suffix, j, 1);
                closing = closing ")?"; 
            }
            word = "^(" word "" closing ")$";
        }

        print i "," word;
    }
}
