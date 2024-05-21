# Define a function to set border styles based on the given style parameter.
function borderStyle(style) {
    # If the style is "double", set the border characters to double-line box drawing characters.
    if (style ~ /^(do(u(b(l(e)?)?)?)?)$/) {
        border_style["top_left"] = "╔";
        border_style["bottom_left"] = "╚";
        border_style["top_right"] = "╗";
        border_style["bottom_right"] = "╝";
        border_style["horizontal"] = "═";
        border_style["horizontal_up"] = "╩";
        border_style["horizontal_down"] = "╦";
        border_style["vertical"] = "║";
        border_style["vertical_left"] = "╣";
        border_style["vertical_right"] = "╠";
        border_style["horizontal_vertical"] = "╬";
    # If the style is "single", set the border characters to single-line box drawing characters.
    } else if (style ~ /^(si(n(g(l(e)?)?)?)?)$/) {
        border_style["top_left"] = "┌";
        border_style["bottom_left"] = "└";
        border_style["top_right"] = "┐";
        border_style["bottom_right"] = "┘";
        border_style["horizontal"] = "─";
        border_style["horizontal_up"] = "┴";
        border_style["horizontal_down"] = "┬";
        border_style["vertical"] = "│";
        border_style["vertical_left"] = "┤";
        border_style["vertical_right"] = "├";
        border_style["horizontal_vertical"] = "┼";
    # If a custom style is provided, use the first character of the style string for all border parts.
    } else if (length(style) > 0) {
        style = substr(style, 1, 1);
        border_style["top_left"] = style;
        border_style["bottom_left"] = style;
        border_style["top_right"] = style;
        border_style["bottom_right"] = style;
        border_style["horizontal"] = style;
        border_style["horizontal_up"] = style;
        border_style["horizontal_down"] = style;
        border_style["vertical"] = style;
        border_style["vertical_left"] = style;
        border_style["vertical_right"] = style;
        border_style["horizontal_vertical"] = style;
    }
}

# Define a function to validate spacing values, ensuring they are numeric.
function validSpacing(number) {
    # If the number is a valid digit, return it; otherwise, return 1.
    if (number ~ /^[[:digit:]]+$/) {
        return number;
    }
    return 1;
}

# Define a function to duplicate a character a specified number of times.
function characterDuplicator(count, character) {
    count = int(count);

    # Create a string of spaces equal to the count.

    if (count > 0) {
    characters = "";

        while (count--) {
            characters = characters " ";
        }

        # If a character is provided, replace all spaces with that character.
        if (length(character) > 0) {
            gsub(" ", character, characters);
        }

        return characters;
    }

    return "";
}

function realLength(string) {
    real_length = string;
    
}

function wrapping(line) {
    if (length(line) <= border_properties["line_length"]) {
        printf line
    } else {
        print border_properties["line_length"];
    }
}

# The BEGIN block is executed before processing any input lines.
BEGIN {
    # Split the 'columns' variable into 'terminal' array based on ':' delimiter.
    entry_count = split(columns, terminal, /[:]/)
    # Validate the terminal dimensions and set the number of columns accordingly.
    if (entry_count != 2 || terminal[2] < 6 || terminal[2] >= terminal[1]) {
        border_properties["columns"] = int(terminal[1]);
    } else {
        border_properties["columns"] = int(terminal[2]);
    }
    # Clear the 'terminal' array as it's no longer needed.
    delete terminal;
    # If the number of columns is less than 1, print an error message and exit.
    if (border_properties["columns"] < 1) {
        delete border_properties;
        print "The number of columns provided was either invalid or missing.";
        exit 10;
    }
    # If a border style is provided, set the border characters and adjust the column width.
    if (length(border) > 0) {
        borderStyle(border);
        border_properties["columns"] = border_properties["columns"] - 2;
        border_properties["divider"] = characterDuplicator(border_properties["columns"], border_style["horizontal"]);
    }
    # Split the 'padding' and 'margins' variables into their respective arrays.
    split(padding, pad_values, /[,]/);
    split(margins, margin_values, /[,]/);
    # Loop through the padding and margin values to validate and set them.
    for (set_spacing = 1; set_spacing <= 4; set_spacing++) {
        margin_values[set_spacing] = validSpacing(margin_values[set_spacing]);
        pad_values[set_spacing] = validSpacing(pad_values[set_spacing]);
        # For right and bottom values (even indices), adjust the column width and create padding/margin strings.
        if ((set_spacing % 2) == 0) {
            border_properties["columns"] = (border_properties["columns"] - (pad_values[set_spacing] + margin_values[set_spacing]));
            pad_values[set_spacing] = characterDuplicator(pad_values[set_spacing]);
            margin_values[set_spacing] = characterDuplicator(margin_values[set_spacing]);
        }
    }
    # If the adjusted column width is less than 1, print an error message and exit.
    if (border_properties["columns"] < 1) {
        print "You cannot fix anything within '" border_properties["columns"] "' columns, please reduce the spacing or zoom out to increase the screen size";
        exit 11;
    }
    # Adjust the divider based on the padding values.
    border_properties["divider"] = substr(border_properties["divider"], length(pad_values[2]) + 1 + length(pad_values[4]));
    border_properties["line_length"] = length(border_properties["divider"]) - length(margin_values[4] margin_values[2]);
}
# The main block processes each input line to create the formatted text box.
{
    # If a header is provided, print it with the appropriate padding.
    if (length(header) > 0) {
        if (pad_values[1] > 0) {
            while(pad_values[1]--) {
                print " ";
            }
        }
        # If a label is provided, print it; otherwise, print the top border.
        if (length(label) > 0) {
            print label;
            label = "";
        } else {
            print pad_values[4] "" border_style["top_left"] "" border_properties["divider"] "" border_style["top_right"] "" pad_values[2];
        }
    }

    # Print the top margin.
    for (margin = 1; margin <= margin_values[1]; margin++) {
        print pad_values[4] "" border_style["vertical"] "" characterDuplicator(length(border_properties["divider"])) "" border_style["vertical"] "" pad_values[2];
    }

    # Print each line of the main content, enclosed in vertical borders with margins.
    line_count = split($0, lines, /▀/);

    for (line_index = 1; line_index <= line_count; line_index++) {
        wrapping(lines[line_index]);
    }

    # Print the bottom margin.
    for (margin = 1; margin <= margin_values[3]; margin++) {
        print pad_values[4] "" border_style["vertical"] "" characterDuplicator(length(border_properties["divider"])) "" border_style["vertical"] "" pad_values[2];
    }
    # If a footer is provided, print it; otherwise, print the bottom border.
    if (length(footer) > 0) {
        printf pad_values[4] "" border_style["bottom_left"] "" border_properties["divider"] "" border_style["bottom_right"] "" pad_values[2];
        if (pad_values[3] > 0) {
            while(pad_values[3]--) {
                print "";
            }
        }
    } else {
        print pad_values[4] "" border_style["vertical_right"] "" border_properties["divider"] "" border_style["vertical_left"] "" pad_values[2];
    }
}
