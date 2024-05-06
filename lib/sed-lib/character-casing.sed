/\\v/{
    s/\\v/\\n\\t/g;
}

/\\t/{
    s/\\t/    /g;
}

/\\n/{

    s/\\n/\(NewLine\)/g;

    /^\((Upper|Lower|Title)\)/{
        h; x; s/\).*/EOFisUnique\)/; s/^/EOFisUnique/; x; G; s/\n//;
        s/\([[:upper:]]{1}[[:lower:]]+\)//;
    };

    :new_line
    /\(NewLine\)/{
        b add_new_line;
    }

    /EOFisUnique\)$/{
        h; x; s/EOFisUnique\)/\)/; s/.*\(/\(/; x; H; x; s/\n//; s/EOFisUnique.*//; x; z; x;
    }

    b characters;

    :add_new_line
    h; x; s/\(NewLine\)/\(RemoveMePlease\)/; s/.*\(RemoveMePlease\)//; x;
    s/\(NewLine\).*//; G;

    b new_line;
}

:characters

/^\(Upper\)/{
    s/^\(Upper\)//g;
    y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/;
    b end;
}

/^\((Lower|Title)\)/{

    s/^\(Lower\)//g;
    y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/;

    /^\(title\)/{
        s/^\(title\)//g;

        :title
        s/(^|[[:space:]]+)[[:lower:]]/\U\0/; t next_word;
        b end;

        :next_word
        h; x;  
        b title;
    }
}

:end
q 0;