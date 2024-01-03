function borderLabel(label,total) {
    third = int(total / 3);
    renainder = 3 % 2;

    if (length(label) < third) {
        label_size = characterString(lengthCounter(label) + 2, border_style["horizontal"]);
        print " " border_style["topLeft"] "" label_size "" border_style["topRight"];
        print " " border_style["vertical"] " " label " " border_style["vertical"];
    } else {
        split("", labels);
        fold(labels, third + 1, label);
        label_size = characterString(third + 3, border_style["horizontal"]);
        print " " border_style["topLeft"] "" label_size "" border_style["topRight"];

        for (l=1; l <= length(labels); l++) {
            gsub(/[[:space:]]*$/, "", labels[l]);
            print " " border_style["vertical"] " " labels[l] "" sprintf("%*s", third + 2 - length(labels[l]), "") "" border_style["vertical"];
        }

        delete labels;
    }

    print " " border_style["verticalRight"] "" label_size "" border_style["horizontalUp"] "" substr(horizontal, 1, length(horizontal) - 1 - length(label_size)) border_style["topRight"];
}

BEGIN {

    borderStyle(style);
    horizontal = characterString(columns - 4, border_style["horizontal"]);

    if (length(label) > 0 && int(columns / 3) < 7) {
        label = "";
        header = "true";
    }

    if (length(label) > 0) {
        borderLabel(label,columns);
    } else if (length(header) > 0) {
        print " " border_style["topLeft"] "" horizontal "" border_style["topRight"];
    }

    split("", lines);

    while (getline line < "-") {
        if (length(wordWrap) == 0) {
            lines[length(lines) + 1] = "";
        }

        fold(lines, columns - 6, line);
    }

    for (m = 1; m <= length(lines); m++) {
        gsub(/[[:space:]]*$/, "", lines[m]);
        print " " border_style["vertical"] " " lines[m] "" sprintf("%*s", columns - 5 - lengthCounter(lines[m]), "") "" border_style["vertical"];
    }

    delete lines;

    if (length(footer) > 0) {
        print " " border_style["bottomLeft"] "" horizontal "" border_style["bottomRight"] "";
    } else {
        print " " border_style["verticalRight"] "" horizontal "" border_style["verticalLeft"];
    }
}