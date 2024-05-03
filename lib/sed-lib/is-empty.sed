/^'.*'$/{
    s/^'//; s/'$//; b remove_spaces;
}

/^".*"$/{
    s/^"//; s/"$//;
}

:remove_spaces

# Attempt to delete a line that is only whitespace
/^ *$/{
    # If the line was only whitespace, exit with 1
    q 1;
}

# If the line was not only whitespace, continue processing
# Further commands can be placed here if needed
q 0;