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
