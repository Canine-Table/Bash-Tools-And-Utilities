/^(yes|true|on|1)$/{
    s/yes/no/; t end;
    s/true/false/; t end;
    s/on/off/; t end;
    s/1/0/; t end;
}


/^(no|false|off|0)$/{
    s/no/yes/; t end;
    s/false/true/; t end;
    s/off/on/; t end;
    s/0/1/; t end; 
} 

b default_value


:end
q 0;

:default_value
i\true
q 0;