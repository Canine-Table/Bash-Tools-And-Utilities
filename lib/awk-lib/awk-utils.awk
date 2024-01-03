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

# function colorCounter(new_string) {
#     # regex = "(^[[|\e\[|\033\[).*m)";
#     new_string = colors
#     # gsub(regex, "", new_string);

#     print length(colors) "   =   " colors;
#     regexpr = "\\033[";

#     gsub("\\033[", "ge", colors);
#     print length(colors) "   =   " colors;
# }
