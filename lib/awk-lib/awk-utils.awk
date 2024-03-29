function textCase(string) {
    split(string, strings, ",");

    if (tolower(strings[2]) ~ /^(u(p(p(e(r(c(a(s(e)?)?)?)?)?)?)?)?)$/) {
        print toupper(strings[1]);
    } else if (tolower(strings[2]) ~ /^(l(o(w(e(r(c(a(s(e)?)?)?)?)?)?)?)?)$/) {
        print tolower(strings[1]);
    } else if (tolower(strings[2]) ~ /^(t(i(t(l(e(c(a(s(e)?)?)?)?)?)?)?)?)$/) {
        gsub(/ /, "░", strings[1]);
        new_string = "";

        while (match(strings[1], /[[:alnum:]]{1}░+/)) {
            new_string = new_string "" toupper(substr(strings[1], 1, 1)) "" substr(strings[1], 2, RSTART + RLENGTH - 2);
            strings[1] = substr(strings[1], RSTART + RLENGTH);
    }

        new_string = new_string "" toupper(substr(strings[1], 1, 1)) "" substr(strings[1], 2);
        gsub(/░/, " ", new_string);
        print new_string;

    } else {
        print string;
    }

    delete strings;
}

function random(min,max) {
    return int(min + rand() * (max - min + 1));
}

function borderStyle(style) {
    if (style == "double") {
        border_style["topLeft"]="╔";
        border_style["bottomLeft"]="╚";
        border_style["topRight"]="╗";
        border_style["bottomRight"]="╝";
        border_style["horizontal"]="═";
        border_style["horizontalUp"]="╩";
        border_style["horizontalDown"]="╦";
        border_style["vertical"]="║";
        border_style["verticalLeft"]="╣";
        border_style["verticalRight"]="╠";
        border_style["horizontalVertical"]="╬";
    } else {
        border_style["topLeft"]="┌";
        border_style["bottomLeft"]="└";
        border_style["topRight"]="┐";
        border_style["bottomRight"]="┘";
        border_style["horizontal"]="─";
        border_style["horizontalUp"]="┴";
        border_style["horizontalDown"]="┬";
        border_style["vertical"]="│";
        border_style["verticalLeft"]="┤";
        border_style["verticalRight"]="├";
        border_style["horizontalVertical"]="┼";
    }
}

function characterString(count,character) {
    string=sprintf("%*s", count, "");
    gsub(" ", character, string);
    return string;
}

function wrap(array,columns,string) {

    current_length = length(array[length(array)]);
    string_index = 1;

    if (current_length + length(string) > columns) {
        array[current_length++] = array[current_length] "" substr(string, 1, columns - current_length);
        string_index = columns - current_length;
    }

    for (; string_index <= length(string); string_index += columns) {
        array[current_length] = substr(string, string_index, columns)
        
        if (string_index < length(string)) {
            current_length++;
        }
    }
}

function fold(string,count) {
    string = string " EOF";
    array_index = 0;

    if(match(string, /^[[:space:]]+/)) {
        new_string = substr(string, 1, RSTART + RLENGTH - 1);
        string = substr(string, RSTART + RLENGTH);
    }

    while (match(string, /[[:space:]]+/)) {
        sub_string = substr(string, 1, RSTART + RLENGTH - 1);

        if (length(sub_string) + length(new_string) < 20) {
            new_string = new_string "" sub_string;
        } else {
            new_array[++array_index] = new_string;
            new_string = sub_string;
        }

        string = substr(string, RSTART + RLENGTH);
    }

    if (length(new_string) > 0) {
        new_array[++array_index] = new_string;
    } 

    for (i = 1; i < length(new_array); i++) {
        print new_array[i];
    }
    
    delete new_array;
}

function folds(array,columns,string) {

    if (length(array) == 0) {
        array[1] = "";
    }
    
    string = string " EOF";
    array_index = length(array);
    current_length = length(array[array_index]);

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

        if (length(new_string) >= columns) {
            if (length(placeholder_string) > 0 && length(array[array_index]) + length(placeholder_string) < columns) {
                array[array_index] = array[array_index] "" placeholder_string;
            } else {
                new_string = placeholder_string "" new_string;
            }

            placeholder_string = "";
            wrap(array, columns, new_string);
        } else if (length(new_string) + length(placeholder_string) >= columns) {
            array[array_index++] = placeholder_string;
            placeholder_string = "";
            continue;
        } else {
            placeholder_string = placeholder_string "" new_string;
        }

        string = substr(string, RSTART + RLENGTH);
    }

    if (length(placeholder_string) > 0) {
        array[array_index] = substr(placeholder_string, 1, length(placeholder_string) - 1);
    }
}