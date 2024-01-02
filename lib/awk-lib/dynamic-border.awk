function borderLabel(label,total) {
    third = int(total / 3);

    if (length(label) + 4 < third) {
        label_size = characterString(length(label) + 2, border_style["horizontal"]);
        print " " border_style["topLeft"] "" label_size "" border_style["topRight"];
        print " " border_style["vertical"] " " label " " border_style["vertical"];
        print " " border_style["verticalRight"] "" label_size "" border_style["horizontalUp"] "" substr(horizontal, 1, length(horizontal) - 1 - length(label_size)) border_style["topRight"];
    } else {
        remainder = total % 3;
    }
}

BEGIN {

    borderStyle(style);

    horizontal=characterString(columns - 4, border_style["horizontal"]);

    if (length(label) > 0) {

        borderLabel(label,columns);

    } else if (length(header) > 0) {
        print " " border_style["topLeft"] "" horizontal "" border_style["topRight"];
    }

    while (getline line < "-") {
        delete lines[z]
        folds(lines,columns - 6,line);
    }

    for (i in lines) {
       print " " border_style["vertical"] " " lines[i] "" sprintf("%*s", columns - 5 - length(lines[i]), "") "" border_style["vertical"];
    }
    
    if (length(footer) > 0) {
        print " "  border_style["bottomLeft"] "" horizontal "" border_style["bottomRight"] "";
    } else {
        print " " border_style["verticalRight"] "" horizontal "" border_style["verticalLeft"];
    }
}