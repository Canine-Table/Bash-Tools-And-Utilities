function textColor(character) {

    if (record_properies["random_weight"] == "true") {
        record_properies["weight"] = random(0,7);
    }

    if (record_properies["multicolored_foreground"] == "true") {
        if (random(0,1) == 1){
            prefix = 3;
        } else {
            prefix = 9;
        }

        record_properies["foreground"] = prefix "" random(0,7);
    }

    if (record_properies["multicolored_background"] == "true") {
        if (random(0,1) == 1){
            prefix = 4;
        } else {
            prefix = 10;
        }

        record_properies["background"] = prefix "" random(0,7);
    }

    record_properies["string"] = record_properies["string"] "\\e[" record_properies["weight"] ";" record_properies["foreground"] ";" record_properies["background"] "m" character "\\e[m";
}

BEGIN {

    record_properies["string"] = "";

    if (length(weight) > 0) {
        record_properies["weight"] = weight;
    } else {
        record_properies["weight"] = 0;
    }

    if (length(foreground) > 0) {
        record_properies["foreground"] = foreground;
    } else {
        record_properies["foreground"] = 98;
    }

    if (length(background) > 0) {
        record_properies["background"] = background;
    } else {
        record_properies["background"] = 108;
    }

    if (length(random_weight) > 0 && random_weight == "true") {
        record_properies["random_weight"] = "true";
    } else {
        record_properies["random_weight"] = "false";
    }

    if (length(multicolored_foreground) > 0 && multicolored_foreground == "true") {
        record_properies["multicolored_foreground"] = "true";
    } else {
        record_properies["multicolored_foreground"] = "false";
    }

    if (length(multicolored_background) > 0 && multicolored_background == "true") {
        record_properies["multicolored_background"] = "true";
    } else {
        record_properies["multicolored_background"] = "false";
    }
} {
    for (character_index = 1; character_index <= length($0); character_index++) {
        textColor(substr($0, character_index, 1));
    }

} END {
    printf record_properies["string"];
}
