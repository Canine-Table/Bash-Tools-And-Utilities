{

    # Set the default delimiter to a comma if not provided
    if (length(delimiter) == 0) {
        delimiter = ",";
    }

    # Split the input line into fields based on the delimiter
    field_count = split($0, fields, delimiter);

    # Loop through each field
    for (field_index = 1; field_index <= field_count; field_index++) {
        
        # Print each field wrapped in quotes, followed by the separator
        printf quote "" fields[field_index] "" quote;
        
        if (field_index < field_count) {
            print separator;
        }
    }

    # Delete the fields array to free up memory
    delete fields;
}