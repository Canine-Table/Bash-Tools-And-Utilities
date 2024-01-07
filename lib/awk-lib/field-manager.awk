{
    field_count = split($0, fields, delimiter);

    for (field_index = 1; field_index <= field_count; field_index++) {
        printf quote "" fields[field_index] "" quote;
        if (field_index < field_count) {
            printf separator;
        }
    }
}