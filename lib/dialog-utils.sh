# Check if LIB_DIR is already exported, if not, set it to the directory of this script
export | grep -q 'declare -x LIB_DIR=' || export LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)";

function dialogFactory() {

    # unset any existing
    unsetVariables DIALOG_RESPONSE;

    declarationQuery -q -m A -n r "${1}" && {
        # if a hash map was passed, reference it instead
        local -n DIALOG_RESPONSE="${1}";
        shift;
    } || {
        declare -gA DIALOG_RESPONSE;
    }

    # Set DIALOGRC used by the dialog command if the file exists
    [[ -f "${LIB_DIR}/../etc/.dialogrc" && -r "${LIB_DIR}/../etc/.dialogrc" ]] && export DIALOGRC="${LIB_DIR}/../etc/.dialogrc";

    # Declare local variables
    local -i DIALOG_ESC=255 DIALOG_ITEM_HELP=4 DIALOG_EXTRA=3 DIALOG_HELP=2 DIALOG_CANCEL=1 DIALOG_OK=0 OPTIND DIALOG_EXIT_STATUS DEPTH;
    local OPT OPTARG KWARG TAG SPACING DIALOG_OUTPUT;
    local -a FIELDS PARAMETERS ARGUMENTS;
    local -l STATE='off';

    # Define accepted properties of this funtion
    local -A DIALOG_PROPERTIES=(
        ["booleans"]='autosize,ascii-lines,beep,beep-after,clear,colors,cr-wrap,cursor-off-label,defaultno,erase-on-exit,ignore,keep-tite,keep-window,last-key,no-cancel,no-hot-list,no-items,no-kill,no-lines,no-mouse,no-nl-expand,no-ok,no-shadow,no-tags,print-maxsize,print-size,print-version,quoted,reorder,scrollbar,single-quoted,size-err,stderr,stdout,tab-correct,trim,version,visit-items'
        ["variants"]='treeview,calendar,buildlist,checklist,dselect,fselect,editbox,form,tailboxfg,tailboxbg,textbox,timebox,infobox,inputbox,inputmenu,menu,mixedform,mixedgauge,gauge,msgbox,passwordform,passwordbox,pause,prgbox,programbox,progressbox,radiolist,rangebox,yesno'
        ["labels"]='range,seconds,percentage,ok-label,positioning,length,message,no-label,backtitle,cancel-label,yes-label,column-separator,help-label,default-item,exit-label,extra-label,default-button,title,interval'
        ["buttons"]='extra-button,help-button'
        ["lines"]=$(($(tput lines) - 6))
        ["columns"]=$(($(tput cols) - 3))
    ) DIALOG_TOGGLES DIALOG_LABELS DIALOG_TAGS;

    # Parse command-line options
    while getopts :V:B:L: OPT; do
        case ${OPT} in
            V) DIALOG_PARAMETERS["${OPT}"]="$(awkParameterCompletion -d ',' -s "${OPTARG}" "${DIALOG_PROPERTIES["variants"]}")" || hault;;
            B)
                OPT="$(awkParameterCompletion -d ',' -s "${OPTARG}" "${DIALOG_PROPERTIES["booleans"]},${DIALOG_PROPERTIES["buttons"]}")" && {
                    [[ "${OPT}" == 'autosize' ]] && {
                        ("${DIALOG_PROPERTIES["positioning"]:-false}" && "${DIALOG_PROPERTIES["autosize"]:-false}") || {
                            DIALOG_PROPERTIES["columns"]=0;
                            DIALOG_PROPERTIES["lines"]=0;
                            DIALOG_PROPERTIES["${OPT}"]="true";
                        }
                    } || {
                        DIALOG_TOGGLES["${OPT}"]="$(sedBooleanToggle "${DIALOG_TOGGLES["${OPT}"]}")";
                        "${DIALOG_TOGGLES["${OPT}"]}" || unset DIALOG_TOGGLES["${OPT}"];
                    }
                } || hault;;
            L)
                awkFieldManager -d '=' "${OPTARG}";
                OPT="$(awkParameterCompletion -d ',' -s "${FIELDS[0]}" "${DIALOG_PROPERTIES[labels]}")" && {
                    sedIsEmpty -q "${FIELDS[1]}" && {

                        [[ "${OPT}" == 'length' ]] && {
                            [[ ${FIELDS[1]} =~ ^[[:digit:]]+$ && ${FIELDS[1]} -gt 0 ]] && DIALOG_PROPERTIES["${OPT}"]="${FIELDS[1]}";
                            continue;
                        }

                        [[ "${OPT}" == 'seconds' ]] && {
                            [[ ${FIELDS[1]} =~ ^[[:digit:]]+$ ]] && ARGUMENTS[0]="${FIELDS[1]}";
                            continue;
                        }

                        [[ "${OPT}" == 'percentage' ]] && {
                            [[ ${FIELDS[1]} =~ ^([[:digit:]]{1}|([1-9][[:digit:]]){1}|100)$ ]] && ARGUMENTS[0]="${FIELDS[1]}";
                            continue;
                        }

                        [[ "${OPT}" == 'range' ]] && {
                            DEPTH=0;
                            ARGUMENTS=(1 10 5);
                            awkFieldManager -d ',' "${OPTARG}";
                            for OPT in "${FIELDS[@]}"; do
                                [[ ${DEPTH} -eq 0 && "${OPT}" -lt "${FIELDS[1]}" && "${OPT}" -lt "${FIELDS[2]}" ]] && ARGUMENTS[0]="${OPT}";
                                [[ ${DEPTH} -eq 1 && "${OPT}" -gt "${FIELDS[0]}" && "${OPT}" -gt "${FIELDS[2]}" ]] && ARGUMENTS[1]="${OPT}";
                                [[ ${DEPTH} -eq 2 ]] && {
                                    [[ "${OPT}" -gt "${FIELDS[0]}" && "${OPT}" -lt "${FIELDS[0]}" ]] && ARGUMENTS[2]="${OPT}";
                                    break 
                                } || DEPTH=$((DEPTH += 1));
                            done
                        }

                        [[ "${OPT}" == 'interval' ]] && {
                            DEPTH=0;
                            ARGUMENTS=(1 59 59);
                            awkFieldManager -d ',' "$(echo -n "${OPTARG}" | cut -d '=' -f 2-)";

                            for OPT in "${FIELDS[@]}"; do
                                STATE='false';
                                grep -q '=' <<< "${OPT}" && {
                                    awkFieldManager -d '=' "${OPT}";
                                    OPT="$(awkParameterCompletion -d ',' -s "${FIELDS[0]}" 'hours,minutes,seconds')" && {
                                        case "${OPT}" in
                                            'hours')
                                                [[ ${FIELDS[1]} -ge 0 && ${FIELDS[1]} -lt 24 ]] && { ARGUMENTS[0]="${FIELDS[1]}"; };;
                                            'minutes') 
                                                [[ ${FIELDS[1]} -ge 0 && ${FIELDS[1]} -lt 60 ]] && { ARGUMENTS[1]="${FIELDS[1]}"; };;
                                            'seconds') 
                                                [[ ${FIELDS[1]} -ge 0 && ${FIELDS[1]} -lt 60 ]] && { ARGUMENTS[2]="${FIELDS[1]}"; };;
                                        esac
                                    } || hault;
                                } || {
                                    [[ ${DEPTH} -eq 0 ]] && {
                                        [[ "${OPT}" -ge 0 && "${OPT}" -lt 24 ]] && { STATE='true'; } || { OPT=1; };
                                    } || {
                                        [[ "${OPT}" -ge 0 && "${OPT}" -lt 60 ]] && { STATE='true'; } || { OPT=59; };
                                    }
                                }
                                [[ ${DEPTH} -eq 2 ]] && break || DEPTH=$((DEPTH += 1));
                            done
                            continue;
                        }

                        [[ "${OPT}" == 'positioning' ]] && {
                            awkFieldManager -d ',' "$(echo "${OPTARG}" | cut -d '=' -f 2-)";

                            "${DIALOG_PROPERTIES["positioning"]:-false}" && "${DIALOG_PROPERTIES["autosize"]:-false}" || {
                                DIALOG_PROPERTIES["${OPT}"]="true";
                                DEPTH=0;

                                for OPT in "${FIELDS[@]}"; do
                                    awkFieldManager -d '=' "${OPT}";

                                    [[ ${FIELDS[-1]} =~ ^([[:digit:]]+)$ && ${FIELDS[-1]} -gt 32 ]] || continue;

                                    OPTARG="$(awkParameterCompletion -q -d ',' -s "${FIELDS[0]}" 'lines,columns')" && {
                                        [[ "${OPTARG}" == 'lines' ]] && { DEPTH=$((DEPTH+=3)); } || { SPACING="$((DIALOG_PROPERTIES["${OPTARG}"] - FIELDS[-1]))"; DEPTH=$((DEPTH+=7)); };
                                        [[ ${FIELDS[-1]} -lt ${DIALOG_PROPERTIES["${OPTARG}"]} ]] && DIALOG_PROPERTIES["${OPTARG}"]="${FIELDS[-1]}";
                                        [[ ${DEPTH} =~ ^(4|8)$ ]] && break;
                                    } || {
                                        if [[ ${DEPTH} =~ ^(0|8)$ ]]; then
                                            [[ ${FIELDS[-1]} -lt ${DIALOG_PROPERTIES["lines"]} ]] && DIALOG_PROPERTIES["lines"]="${FIELDS[-1]}";
                                            [[ ${DEPTH} -eq 8 ]] && break;
                                            DEPTH=$((DEPTH+=3));

                                        elif [[ ${DEPTH} =~ ^(1|4)$ ]]; then
                                            [[ ${FIELDS[-1]} -lt ${DIALOG_PROPERTIES["columns"]} ]] && {
                                                DIALOG_PROPERTIES["columns"]="${FIELDS[-1]}";
                                            }

                                            [[ ${DEPTH} -eq 4 ]] && break;
                                            DEPTH=$((DEPTH+=7));
                                        fi
                                    }

                                    DEPTH=$((DEPTH+=1));
                                done
                            }
                            continue;
                        }

                        [[ "${OPT}" == 'message' ]] && {
                            DIALOG_PROPERTIES["${OPT}"]="$(sedCharacterCasing "${FIELDS[1]}")";
                            continue;
                        }

                        DIALOG_LABELS["${OPT}"]="$(sedCharacterCasing "${FIELDS[1]}")";
                        [[ "${OPT}" == 'title' ]] && {
                            DIALOG_LABELS["${OPT}"]="┤ ${DIALOG_LABELS["${OPT}"]}├";
                            continue;
                        }

                        awkFieldManager -d '-' "${OPT}";

                        OPT="$(awkParameterCompletion -q -d ',' -s "${FIELDS[0]}" "${DIALOG_PROPERTIES["buttons"]}")" && {
                            DIALOG_TOGGLES["${OPT}"]='true';
                        }
                    }
                    FIELDS=();
                } || hault;;
        esac
    done

    # Shift off the options from the positional parameters.
    shift $((OPTIND - 1));

    [[ -z "${DIALOG_PARAMETERS[V]}" ]] && {
       return 2;
    } || {

        [[ "${DIALOG_PARAMETERS[V]}" =~ ^(calendar)$ || "${DIALOG_PROPERTIES["autosize"]}" == 'true' ]] && {
            DIALOG_PROPERTIES["other"]="\n${DIALOG_PROPERTIES[message]:-$(command -v fortune &> /dev/null && fortune | sed 's/\t/    /g' || printf 'Dialog')}";
            DIALOG_PROPERTIES["lines"]=0; DIALOG_PROPERTIES["columns"]=0;
        }

        [[ "${DIALOG_PARAMETERS[V]}" =~ ^(password(box|form))$ ]] && {
            PARAMETERS+=('--insecure');
        }

        if [[ "${DIALOG_PARAMETERS[V]}" =~ ^((password|mixed)?form|(radio|check|build)list|(input)?menu|treeview)$ ]]; then
            ARGUMENTS=("${DIALOG_PROPERTIES["columns"]}"); OPTIND=0; OPTARG=""; DEPTH=0; FIELDS=();

            for OPT in "${@}"; do
                awkFieldManager -d ':' "${OPT}";
                STATE="${FIELDS[1]}";
                [[ ${#FIELDS[@]} -ge 2 ]] && {

                    [[ ${STATE} =~ ^(yes|true|on|ok)$ ]] && {
                        STATE='on';
                    }

                    [[ ${STATE} =~ ^(no|false|off)$ ]] && {
                        STATE='off';
                    }

                    [[ "${DIALOG_PARAMETERS[V]}" =~ ^(treeview)$ && ${FIELDS[2]} =~ ^([1-9]{1}[[:digit:]]*)$ ]] && {
                        DEPTH=${FIELDS[2]:-1};
                    }

                    [[ ${OPTIND} -eq 0 ]] && {
                        SPACING=$((-7));
                        [[ "${DIALOG_PARAMETERS[V]}" =~ ^(treeview)$ ]] && SPACING=$((SPACING -= (${FIELDS[2]:-2} * 4)));
                    }

                    OPT="${FIELDS[0]}";
                }

                [[ ${STATE} =~ ^(on|off)$ ]] || STATE='off';    
                awkFieldManager -d '=' "${OPT}";

                OPTIND=$((OPTIND+=1));

                KWARG="${OPT}";
                TAG="${OPTIND}";

                [[ ${#FIELDS[@]} -eq 2 ]] && {
                    TAG="${FIELDS[0]}";
                    OPT="${FIELDS[1]}";
                }

                if [[ "${DIALOG_PARAMETERS[V]}" =~ ^((password|mixed)?form)$ ]]; then
                    OPT="${FIELDS[0]}"; DIALOG_PROPERTIES["${OPT}"]="${FIELDS[1]}";
                    ARGUMENTS+=(" ${OPT}:" $((OPTIND)) 2 "${DIALOG_PROPERTIES["${OPT}"]}" $((OPTIND)) $((${#OPT} + 5)) $((${DIALOG_PROPERTIES["columns"]} - ${#OPT} - 11)) ${DIALOG_PROPERTIES["length"]:-0});
                elif [[ "${DIALOG_PARAMETERS[V]}" =~ ^((radio|build|check)list|(input)?menu|treeview)$ ]]; then
                    if [[ "${DIALOG_PARAMETERS[V]}" =~ ^((radio|build|check)list|treeview)$ ]]; then
                        [[ "${DIALOG_PARAMETERS[V]}" =~ ^(buildlist)$ ]] || SPACING="${SPACING}";
                        OPTARG="${STATE}";

                        [[ "${DIALOG_PARAMETERS[V]}" == 'radiolist' ]] && {
                            [[ "${DIALOG_PARAMETERS["selected"]}" != 'radiolist' ]] && {
                                DIALOG_PARAMETERS["selected"]='radiolist';
                                OPTARG="on";
                            }
                        }
                    fi

                   [[ "${DIALOG_PARAMETERS[V]}" =~ ^(buildlist)$ ]] || {
                        [[ ${OPTIND} -eq 1 ]] && SPACING="$(awk -v opt="${OPT} ${TAG}" -v spacing="${SPACING}" -v columns="${DIALOG_PROPERTIES["columns"]}" 'BEGIN {printf("%*s", columns - length(opt) + spacing, ""); }')" || SPACING="";
                    }

                    ARGUMENTS+=("${TAG}" "${OPT}${SPACING}" ${OPTARG});

                   [[ "${DIALOG_PARAMETERS[V]}" =~ ^(treeview)$ ]] && ARGUMENTS+=("${DEPTH:-0}");
                fi

                DIALOG_TAGS["${OPTIND}"]="${TAG}";
            done
        elif [[ "${DIALOG_PARAMETERS[V]}" =~ ^((tailbox(bg|fg))|(msg|edit|time|text|progress|info|program|range)box|(f|d)select|calendar|gauge|pause|yesno)$ ]]; then
            [[ "${DIALOG_PARAMETERS[V]}" =~ ^(tailboxfg)$ ]] && DIALOG_PARAMETERS[V]='tailbox';

            [[ -z "${ARGUMENTS[@]}" ]] && {
                case "${DIALOG_PARAMETERS[V]}" in
                    'gauge') ARGUMENTS=($((RANDOM % 100)));;
                    'timebox') ARGUMENTS=($((RANDOM % 24)) $((RANDOM % 60)) $((RANDOM % 60)));;
                    'pause') ARGUMENTS=($((RANDOM)));;
                    'rangebox') ARGUMENTS=(1 10 5);;
                    'calendar') ARGUMENTS=($(date +"%d %m %Y"));;
                esac
            }

            KWARG="$(dialog | grep -- "--${DIALOG_PARAMETERS[V]}" | awk '{gsub(/<|>/, ""); print $2}')";

            [[ "${DIALOG_PARAMETERS[V]}" =~ ^(timebox)$ ]] || {
                for OPT in "${@}"; do
                    if  [[ -d "${OPT}" && -r "${OPT}" && "${KWARG}" =~ ^(directory)$ ]] || [[ -f "${OPT}" && -r "${OPT}" && "${KWARG}" =~ ^(file(path)?)$ ]] || [[ "${KWARG}" =~ ^(text)$ ]]; then
                        [[ -n "${OPT}" ]] && {
                            [[ "${KWARG}" == 'text' ]] && {
                                [[ -z "${DIALOG_PROPERTIES["message"]}" ]] && DIALOG_PROPERTIES["message"]="${OPT}";
                            } || { DIALOG_PROPERTIES["other"]="${OPT}"; };
                            break;
                        }
                    fi
                done

                [[ -z "${DIALOG_PROPERTIES["other"]}" && "${KWARG}" != 'text' ]] && {
                    awkDynamicBorders -l "Invalid ${OPTARG^}" -d "█" -c "The ${OPTARG} parameter passed '${@}' for '--${DIALOG_PARAMETERS[V]}' does not exist, cannot be accessed or is invalid.";
                    hault;
                    return 3;
                }
            }
        fi
    }

    eval "PARAMETERS+=($(echo "$(awkIndexQuerier -O 'flags' DIALOG_LABELS | sed 's/"" $/" /')")$(echo -n " ${!DIALOG_TOGGLES[@]} ${DIALOG_PARAMETERS[V]}" | sed 's/ / --/g'))";
    exec 7>&2;

    DIALOG_OUTPUT="$(
        dialog --trace '/tmp/dialog.log' --output-separator '<output-separator>' --output-fd 7 --no-collapse "${PARAMETERS[@]}" \
            "${DIALOG_PROPERTIES["other"]:-$(awkDynamicBorders -C $((DIALOG_PROPERTIES["columns"] - 4)) -d "█" -c "${DIALOG_PROPERTIES[message]:-$(command -v fortune &> /dev/null && fortune | sed 's/\t/    /g' || printf 'Dialog')}")}" \
            "${DIALOG_PROPERTIES["lines"]}" "${DIALOG_PROPERTIES["columns"]}" "${ARGUMENTS[@]}" 3>&1 1>&7 7>&3;
    )";

    DIALOG_EXIT_STATUS=$?;
    exec 7>&-;

    echo "${DIALOG_OUTPUT}" | grep -q "<output-separator>" && {
        OPTIND=1;
        
        while read -r OPT; do
            [[ -n "${OPT}" ]] && {
                DIALOG_RESPONSE["${DIALOG_TAGS[$OPTIND]}"]="${OPT}";
            }

        OPTIND=$((OPTIND+=1));

        done <<< $(echo "${DIALOG_OUTPUT}" | awk '{
            entry_count = split($0, entries, "<output-separator>");
            for (entry_index = 1; entry_index <= entry_count; entry_index++) {
                if (entries[entry_index] ~ /^"/ && entries[entry_index] ~ /"$/) {
                    gsub(/(^")|("$)/, "", entries[entry_index]);
                }
                print entries[entry_index];
            }
            delete entries;
        }');
    } || DIALOG_RESPONSE['0']="${DIALOG_OUTPUT}";
    
    [[ "${DIALOG_PARAMETERS[V]}" =~ ^(infobox)$ ]] && hault;
    [[ -z "${DIALOG_TOGGLES['keep-window']}" || -n "${DIALOG_TOGGLES['erase-on-exit']}" || -n "${DIALOG_TOGGLES['clear']}" ]] && clear;

    return ${DIALOG_EXIT_STATUS};
}
