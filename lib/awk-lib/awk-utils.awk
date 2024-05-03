function random(min,max) {
    return int(min + rand() * (max - min + 1));
}

function borderStyle(style) {
    if (style == "double") {
        border_style["topLeft"] = "╔";
        border_style["bottomLeft"] = "╚";
        border_style["topRight"] = "╗";
        border_style["bottomRight"] = "╝";
        border_style["horizontal"] = "═";
        border_style["horizontalUp"] = "╩";
        border_style["horizontalDown"] = "╦";
        border_style["vertical"] = "║";
        border_style["verticalLeft"] = "╣";
        border_style["verticalRight"] = "╠";
        border_style["horizontalVertical"] = "╬";
    } else if (style == "single") {
        border_style["topLeft"] = "┌";
        border_style["bottomLeft"] = "└";
        border_style["topRight"] = "┐";
        border_style["bottomRight"] = "┘";
        border_style["horizontal"] = "─";
        border_style["horizontalUp"] = "┴";
        border_style["horizontalDown"] = "┬";
        border_style["vertical"] = "│";
        border_style["verticalLeft"] = "┤";
        border_style["verticalRight"] = "├";
        border_style["horizontalVertical"] = "┼";
    } else if (length(style) > 0) {
        style = substr(style, 1, 1);
        border_style["topLeft"] = style;
        border_style["bottomLeft"] = style;
        border_style["topRight"] = style;
        border_style["bottomRight"] = style;
        border_style["horizontal"] = style;
        border_style["horizontalUp"] = style;
        border_style["horizontalDown"] = style;
        border_style["vertical"] = style;
        border_style["verticalLeft"] = style;
        border_style["verticalRight"] = style;
        border_style["horizontalVertical"] = style;
    }
}

function characterString(count,character) {
    string=sprintf("%*s", count, "");
    gsub(" ", character, string);
    return string;
}

function wrap(array,columns,string) {

    array_index = length(array);
    current_length = length(array[array_index]);
    string_index = 1;

    if (current_length > 0) {
        array[array_index++] = array[array_index] "" substr(string, 1, columns - current_length);
        string_index = columns - current_length + 1;
    }

    for (; string_index <= length(string); string_index += columns) {
        array[array_index++] = substr(string, string_index, columns);
    }

    return array[--array_index];
}

function fold(array,columns,string) {

    if (length(array) == 0) {
        array[1] = "";
    }

    string = string " EOF";
    array_index = length(array);
    current_length = lengthCounter(array[array_index]);

    if (current_length > 0) {
        if (current_length + 2 < columns) {
            placeholder_string = " ";
        } else {
            array[++array_index] = "";
        }
    }

    placeholder_string = array[array_index] "" placeholder_string;

    while (match(string, /[[:space:]]+/)) {
        new_string = substr(string, 1, RSTART + RLENGTH - 1);

        new_string_length = lengthCounter(new_string);
        placeholder_string_length = lengthCounter(placeholder_string);

        if (new_string_length - 2 >= columns) {
            if (placeholder_string_length > 0 && lengthCounter(array[array_index]) + placeholder_string_length < columns) {
                array[array_index] = array[array_index] "" placeholder_string;
            } else {
                if (placeholder_string_length > 0) {
                    new_string = " " new_string;
                }

                new_string = placeholder_string "" new_string;
            }

            placeholder_string = wrap(array, columns, new_string);
        } else if (new_string_length + placeholder_string_length - 2 >= columns) {
            array[array_index++] = placeholder_string;
            placeholder_string = "";
            continue;
        } else {
            placeholder_string = placeholder_string "" new_string;
        }

        string = substr(string, RSTART + RLENGTH );
    }

    if (length(placeholder_string) > 0) {
        array[array_index] = substr(placeholder_string, 1);
    }

    placeholder_string = "";
    new_string_length = 0;
    placeholder_string_length = 0;

}

function lengthCounter(string) {
    gsub(/\033\[[0-9;]*m/, "", string);
    return length(string);
}

function notNull(value,default) {
    if (length(value) > 0) {
        default = value;
    }
    return default;
}

function absolute(value) {
    return (value < 0 ? -value : value);
}

function arrayIndexer(indexes, range) {

    # Check if 'indexes' is a positive integer, exit with code 1 if not
    # If 'indexes' is zero, exit with code 1
    if (indexes !~ /^[[:digit:]]+$/ || indexes == 0) {
        exit 1;
    }

    # Split the 'range' string into an array 'ranges' using ':' as the delimiter
    split(range, ranges, ":");

    # If 'ranges' has less than 2 elements, duplicate the first element
    if (length(ranges) < 2) {
        ranges[2] = ranges[1];
    }

    # Loop through the 'ranges' array and process each range value
    for (range_index = 1; range_index <= 3; range_index++) {
        # If the range value is negative, add it to 'indexes'
        if (ranges[range_index] ~ /^\(-[[:digit:]]+\)$/) {
            value = indexes + substr(ranges[range_index], 2, length(ranges[range_index]) - 2);
        # If the range value is positive, remove any '+' signs and use the value as is
        } else if (ranges[range_index] ~ /^\((+)?[[:digit:]]+\)$/) {
            value = substr(ranges[range_index], 2, length(ranges[range_index]) - 2);
            sub(/+/, "", value);
        # If the range value is a positive integer without parentheses, use the value as is
        } else if (ranges[range_index] ~ /^[[:digit:]]+$/) {
            value = ranges[range_index];
        # If the range value does not match any expected format, set it to an empty string
        } else {
            value = "";
        }

        # If 'value' is empty or out of bounds, adjust it using modulo with 'indexes'
        if (length(value) < 1) {
            value = "";
        } else if (int(value) < 1 || int(value) > indexes) {
            value = int(absolute(value)) % int(indexes);
        }

        # Set default values for the first and third elements of 'ranges' to 1, and for the second to 'indexes'
        if (range_index ~ /^(1|3)$/) {
            defaults = 1;
        } else {
            defaults = indexes;
        }

        # Use the 'notNull' function to ensure 'ranges' elements are not null, applying defaults if necessary
        ranges[range_index] = notNull(value, defaults);
    }

    # Concatenate the processed 'ranges' values into a single string 'value'
    value = ranges[1] "," ranges[2] "," ranges[3];
    # Delete the 'ranges' array to free up memory
    delete ranges;
    # Return the concatenated string 'value'
    return value;
}

function keyValuePairs(array) {
    # Initialize empty arrays for keys and values
    split("", keys, "");
    split("", values, "");

    # Initialize the index for storing key-value pairs
    key_value_indexes = -1;

    # Remove the first and last characters of the input string (assumed to be enclosing characters)
    array = substr(array, 1, length(array) - 1);

    # Loop to process the string as long as it contains key-value pairs in the expected format
    while (match(array, /\[.*\].*/)) {
        # Extract the matched key-value pair substring
        indexes = substr(array, RSTART, RSTART + RLENGTH);

        # Regular expression to remove quotes from the extracted substring
        regexpr = "\" [.*].*";
        gsub(regexpr, "\"", indexes);

        # Split the substring into key and value using the delimiter ']=\"'
        split(indexes, key_value_pairs, "]=\"");

        # Remove the leading '[' from the key
        sub(/^\[/, "", key_value_pairs[1]);

        # Regular expression to remove trailing characters from the value
        regexpr = "\".*$";
        sub(regexpr, "", key_value_pairs[2]);

        # Increment the index and store the key and value in their respective arrays
        key_value_indexes++;
        keys[key_value_indexes] = key_value_pairs[1];
        values[key_value_indexes] = key_value_pairs[2];

        # Update the input string by removing the processed key-value pair
        array = substr(array, RSTART + 1);
    }

    # Delete the temporary array used for processing
    delete key_value_pairs;

    # Return the count of key-value pairs found
    return key_value_indexes;
}

function quoteRemover(string) {

    newString = string;

    if (newString ~ /^".*"$/) {
        gsub(/^"|"$/, "", newString);
    } else if (newString ~ /^'.*'$/) {
        gsub(/^'|'$/, "", newString);
    }

    gsub(/^[[:space:]]+$/, "", newString);

    printf newString;
}