BEGIN {
    if (quote_values ~ /^(single)$/) {
        quote_values = "'";
    } else if (quote_values ~ /^(none)$/) {
        quote_values = "";
    } else if (quote_values ~ /^(tick)$/) {
        quote_values = "`";
    } else {
        quote_values = "\"";
    }

    # Determine the prefix for the passed parameter based on the flag style
    if (flag_style ~ /^(long|short|none)$/) {

        if (flag_style == "long") {
            prefix = "--";
        } else if (flag_style == "short") {
            prefix = "-";
        } else if (flag_style == "none") {
            prefix = "";
        }

        flag_style = "set";
    }
} {
    # Remove trailing " EOL" from each line and store the line in the arguments array
    sub(/ EOL$/, "");
    arguments[NR] = $0;
} END {
    # Loop over the options string as long as there are parameters left to process
    while (match(options, /:.*$/)) {
        # Split the current parameter from the options string
        parameter_count = split(substr(options, 1, RSTART), parameters, /\|/);

        # Loop over each parameter
        for (parameter_index = 1; parameter_index <= parameter_count; parameter_index++) {

            if (mandatory ~ /^(true|set)$/) {
                if (mandatory == "true") {

                    # If the parameter has a default value, use it as the value
                    if (default_value !~ /(^""$)|(^''$)|(^[[:space:]]*$)/) {

                        if (flag_style != "set") {
                            prefix = "-";

                            if (length(kwargs[1]) > 1) {
                                prefix = prefix "-";
                            }
                        }

                        passed_parameters = passed_parameters "" prefix "" kwargs[1] " " "" quote_values "" default_value "" quote_values " ";
                    } else {
                        exit 15;
                    }
                }

                mandatory = "false";
            }

            # Check if the parameter has a default value
            if (parameters[parameter_index] ~ /\[default=.+\]/) {
                # Extract the default value
                starting_index = index(parameters[parameter_index], "[default=") + length("[default=");
                default_value = substr(parameters[parameter_index], starting_index, index(parameters[parameter_index], "]") - starting_index);

                if (default_value ~ /^\(Mandatory=true\)/) {
                    sub(/^\(Mandatory=true\)/, "", default_value);
                    mandatory = "true";
                }

                # Remove the default value from the parameter string
                sub(/\[default=.+\]/, "", parameters[parameter_index]);
            } else if (length(default_value) > 0) {
                # Reset the default value if there is no default for the current parameter
                default_value = "";
            }

            # Check if the parameter requires a value
            requires_value = sub(/:$/, "", parameters[parameter_index]);
            # Split the parameter into its short and long form
            split(parameters[parameter_index], kwargs, ",");

            # If there is no long form, use the short form as the long form
            if (length(kwargs) == 1) {
                kwargs[2] = kwargs[1];
            }

            # Loop over each argument
            for (argument_index = 1; argument_index <= NR; argument_index++) {
                # Check if the argument is a flag followed by a space
                if (arguments[argument_index] ~ /^-[[:alpha:]]{1} / || arguments[argument_index] ~ /^--[[:alnum:]]{2,}(([-_]{1}[[:alnum:]]{1,})*)? /) {

                    # Extract the flag from the argument
                    key_pair = substr(arguments[argument_index], 1, index(arguments[argument_index], " ") - 1);

                    # Extract the value from the argument
                    value_pair = substr(arguments[argument_index], length(key_pair) + 2);

                    # Remove the leading dash(es) from the flag
                    sub(/^-(-)?/, "", key_pair);

                    # Create a pattern to match the short form of the parameter
                    pattern_match = "^" kwargs[2] "$";

                    # Check if the flag matches the short form of the parameter
                    if (key_pair ~ pattern_match) {

                        if (flag_style != "set") {
                            prefix = "-";

                            if (length(kwargs[1]) > 1) {
                                prefix = prefix "-";
                            }
                        }

                        # Check if the argument has a value
                        if (length(value_pair) == 0) {
                            if(requires_value == 0) {
                                # If the parameter is a boolean flag, add it to the passed parameters
                                passed_parameters = passed_parameters "" prefix "" kwargs[1] " ";

                                # Remove the parameter from the parameters array
                                delete parameters[parameter_index];
                                break;

                            } else if (default_value !~ /(^""$)|(^''$)|(^[[:space:]]*$)/) {
                                # If the parameter has a default value, use it as the value
                                value_pair = default_value;
                            } else if (length(nullable) == 0) {
                                # If the parameter is not nullable, skip it
                                continue;
                            }
                        }

                        # Add the parameter and its value to the passed parameters
                        passed_parameters = passed_parameters "" prefix "" kwargs[1] " " "" quote_values "" value_pair "" quote_values " ";

                        if (mandatory == "true") {
                            mandatory = "set";
                        }

                        # If the parameter is not unique, and the uniqueness is required, remove it from the parameters array
                        if (length(unique_no_required) == 0) {
                            delete parameters[parameter_index];
                            argument_index++;
                            continue;
                        }
                    }
                }
            }
        }

       # Remove the processed parameter from the options string
       options = substr(options, RSTART + 1);
   }

    delete parameters;
    delete arguments;

    # Print the passed parameters
    print passed_parameters;
}