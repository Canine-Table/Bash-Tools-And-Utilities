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

BEGIN {
    entry_count = split(columns, terminal, /[:]/)

    if (entry_count != 2 || terminal[2] < 6 || terminal[2] >= terminal[1]) {
        border_properties["columns"] = int(terminal[1]);
    } else {
        border_properties["columns"] = int(terminal[1]);
    }

    delete terminal;

    if (border_properties["columns"] < 1) {
        delete border_properties;
        print "The number of columns provided was either invalid or missing.";
        exit 10;
    }

    if (length(border) > 0) {
        borderStyle(border);
        border_properties["columns"] = int(border_properties["columns"] - 2);
    }
    
    split(padding, pad_values, /[,]/);
    split(margins, margin_values, /[,]/);

    for (set_spacing = 1; set_spacing <= 4; set_spacing++) {
        margin_values[set_spacing] = validSpacing(margin_values[set_spacing]);
        pad_values[set_spacing] = validSpacing(pad_values[set_spacing]);
    
        if ((set_spacing % 2) == 0) {
            border_properties["columns"] = (border_properties["columns"] - (pad_values[set_spacing] + margin_values[set_spacing]));
        }

        spacing[set_spacing] = pad_values[set_spacing] ":" margin_values[set_spacing];
        delete pad_values[set_spacing];
        delete margin_values[set_spacing];
    }

    if (border_properties["columns"] < 1) {
        print "You cannot fix anything within '" border_properties["columns"] "' columns, please reduce the spacing or zoom out to increase the screen size";
        exit 11;
    }
} {
    if (length(label) > 0) {
        print label;
        label = "";
    }
    
    print $0
}