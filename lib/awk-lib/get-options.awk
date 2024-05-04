{
    sub(/ EOL$/, "");
    arguments[NR] = $0;
} END {

    options = options ":";
    while (match(options, /:.*$/)) {
        parameter_count = split(substr(options, 1, RSTART), parameters, /\|/);

        for (parameter_index = 1; parameter_index <= parameter_count; parameter_index++) {
            if (parameters[parameter_index] ~ /\[default=.+\]/) {
                starting_index = index(parameters[parameter_index], "[default=") + length("[default=");
                default_value = substr(parameters[parameter_index], starting_index, index(parameters[parameter_index], "]") - starting_index);
                sub(/\[default=.+\]/, "", parameters[parameter_index]);
            } else if (length(default_value) > 0) {
                default_value = "";
            }

            sub(/:$/, "", parameters[parameter_index]);
            split(parameters[parameter_index], kwargs, ",");

            if (length(kwargs) == 1) {
                kwargs[2] = kwargs[1];
            }

            for (argument_index = 1; argument_index <= NR; argument_index++) {
                if (arguments[argument_index] ~ /^-[[:alpha:]]{1} / || arguments[argument_index] ~ /^--[[:alnum:]]{2,}(([-_]{1}[[:alnum:]]{1,})*)? /) {
                    
                    # -1 for before match
                    key_pair = substr(arguments[argument_index], 1, index(arguments[argument_index], " ") - 1);

                    # +2 for match and 1 space
                    value_pair = substr(arguments[argument_index], length(key_pair) + 2);

                    sub(/^-(-)?/, "", key_pair);
                    pattern_match = "^" kwargs[2] "$";

                    if (key_pair ~ pattern_match) {

                        if (length(value_pair) == 0) {
                            if (length(default_value) > 0) {
                                value_pair = default_value;
                            } else if (length(nullable) == 0) {
                                continue;
                            }
                        }

                        if (flag_style ~ /^(long|short|none)$/) {

                            if (flag_style == "long") {
                                prefix = "--";
                            } else if (flag_style == "short") {
                                prefix = "-";
                            } else if (flag_style == "none") {
                                prefix = "";
                            }

                            flag_style = "set";
                        } else if (flag_style != "set") {
                            prefix = "-";

                            if (length(kwargs[1]) > 1) {
                                prefix = prefix "-";
                            }
                        }

                        passed_parameters = passed_parameters "" prefix "" kwargs[1] " " "\"" value_pair "\" ";

                        if (length(unique) == 0) {
                            delete parameters[parameter_index];
                            argument_index++
                            continue;
                        }
                    }
                }
            }
        }

       options = substr(options, RSTART + 1);
   }

    print passed_parameters;
}
