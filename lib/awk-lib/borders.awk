function borderStyle(style) {
    if (style ~ "double") {
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
    } else if (style == "single") {
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

function validSpacing(number) {
    if (number ~ /^[[:digit:]]+$/) {
        return number;
    }
    
    return 1;
}

function characterDuplicator(count, character) {

    characters = sprintf("%*s", count, "");

    if (length(character) > 0) {
        gsub(" ", character, characters);
    }

    return characters;
}

BEGIN {
    entry_count = split(columns, terminal, /[:]/)

    if (entry_count != 2 || terminal[2] < 6 || terminal[2] >= terminal[1]) {
        border_properties["columns"] = int(terminal[1]);
    } else {
        border_properties["columns"] = int(terminal[2]);
    }

    delete terminal;

    if (border_properties["columns"] < 1) {
        delete border_properties;
        print "The number of columns provided was either invalid or missing.";
        exit 10;
    }

    if (length(border) > 0) {
        borderStyle(border);
        border_properties["columns"] = border_properties["columns"] - 2;
        border_properties["divider"] = characterDuplicator(border_properties["columns"], border_style["horizontal"]);
    }

    split(padding, pad_values, /[,]/);
    split(margins, margin_values, /[,]/);

    for (set_spacing = 1; set_spacing <= 4; set_spacing++) {
        margin_values[set_spacing] = validSpacing(margin_values[set_spacing]);
        pad_values[set_spacing] = validSpacing(pad_values[set_spacing]);
    
        if ((set_spacing % 2) == 0) {
            border_properties["columns"] = (border_properties["columns"] - (pad_values[set_spacing] + margin_values[set_spacing]));
            pad_values[set_spacing] = characterDuplicator(pad_values[set_spacing]);
            margin_values[set_spacing] = characterDuplicator(margin_values[set_spacing]);
        }
    }

    if (border_properties["columns"] < 1) {
        print "You cannot fix anything within '" border_properties["columns"] "' columns, please reduce the spacing or zoom out to increase the screen size";
        exit 11;
    }


    border_properties["divider"] = substr(border_properties["divider"], length(pad_values[2]) + 1 + length(pad_values[4]));
} {
    if (length(header) > 0) {
        if (pad_values[1] > 0) {
            while(pad_values[1]--) {
                print " ";
            }
        }

        if (length(label) > 0) {
            print label;
            label = "";
        } else {
            print pad_values[4] "" border_style["top_left"] "" border_properties["divider"] "" border_style["top_right"] "" pad_values[2];
        }
    }

    for (margin = 1; margin <= margin_values[1]; margin++) {
        print pad_values[4] "" border_style["vertical"] "" characterDuplicator(length(border_properties["divider"])) "" border_style["vertical"] "" pad_values[2];
    }

    #================================================================================================================================
    # TODO: the main body of the formated page
    #================================================================================================================================

    line_count = split($0, lines, /▀/);

    for (line_index = 1; line_index <= line_count; line_index++) {
        print pad_values[4] "" border_style["vertical"] "" margin_values[4] "" lines[line_index];
    }

    #================================================================================================================================
    #================================================================================================================================

    for (margin = 1; margin <= margin_values[3]; margin++) {
        print pad_values[4] "" border_style["vertical"] "" characterDuplicator(length(border_properties["divider"])) "" border_style["vertical"] "" pad_values[2];
    }

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