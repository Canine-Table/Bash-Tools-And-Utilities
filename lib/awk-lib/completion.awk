BEGIN {
    # Read words from the input and store them in an array
    while (getline word < "-") {
        words[++lines] = word;
    }
}

END {
    # Iterate over each word to find a unique prefix
    for (i = 1; i <= lines; i++) {
        prefix = substr(words[i], 1, 1); # Start with a one-character prefix

        do {
            unique = 1; # Assume the prefix is unique

            # Check if the prefix is unique among all words
            for (j = 1; j <= lines; j++) {
                if (i != j && prefix == substr(words[j], 1, length(prefix))) {
                    unique = 0; # The prefix is not unique
                    break; # Exit the inner loop
                }
            }

            # If the prefix is not unique, increase its length by one
            if (unique == 0) {
                prefix = substr(words[i], 1, length(prefix) + 1);
            }
        } while (unique == 0); # Repeat until a unique prefix is found
        
        # Store the unique prefix in an associative array
        prefixes[words[i]] = prefix;
    }

    # Clear the words array to free up memory
    delete words;

    # Iterate over the prefixes array to construct regex patterns
    for (i in prefixes) {
        suffix = i;
        closing = "";
        sub(prefixes[i], "", suffix); # Remove the prefix from the word

        # If there is a suffix, construct a regex pattern with optional characters
        if (length(suffix) > 0) {
            word = prefixes[i];
            for (j = 1; j <= length(suffix); j++) {
                word = word "(" substr(suffix, j, 1); # Add opening parentheses
                closing = closing ")?"; # Add closing parentheses and a question mark
            }
            word = "^(" word "" closing ")$"; # Finalize the regex pattern
        }

        # Print the word and its corresponding regex pattern
        print i "," word;
    }
}
