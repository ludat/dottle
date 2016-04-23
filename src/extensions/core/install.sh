# get config file line indentation level
get_level () {
    printf '%s' "$1" | grep -o '^\s*' | grep -c -o " \{4\}"
}

dottle_action_install () {
    COMMAND=''
    OPTIONS=''
    IF_LEVEL=0
    IF_STATE="true"
    while IFS='' read -r line; do
        # Remove all things behind a hash and trim white spaces
        line=$(printf '%s' "$line" | sed 's/#.*$//' | sed 's/^ *$//')

        # If the line is empty, skip!
        if [ -z "$line" ]; then
            continue
        fi

        case "$line" in
            "if "*)
                if [ "$IF_STATE" = false ]; then
                    IF_LEVEL=$((IF_LEVEL + 1))
                else
                    IF_LEVEL=1
                    if eval "$(printf "%s" "$line" | sed 's/if \(.*\)$/\1/g')"; then
                        IF_STATE=true
                    else
                        IF_STATE=false
                    fi
                fi
                continue
                ;;
            "else")
                if [ "$IF_LEVEL" -eq 1 ]; then
                    if [ "$IF_STATE" = false ]; then
                        IF_STATE=true
                    else
                        IF_STATE=false
                    fi
                fi
                continue
                ;;
            "endif")
                if [ "$IF_LEVEL" -eq 1 ]; then
                    IF_STATE=true
                else
                    IF_LEVEL=$((IF_LEVEL - 1))
                fi
                continue
                ;;
        esac

        if [ "$IF_STATE" = false ]; then
            continue
        fi

        if [ "$(get_level "$line")" -eq "0" ]; then
            COMMAND=$(printf "%s" "dottle_${line%%:*}" | sed 's:[./_ \-]:_:g')
            OPTIONS="${line#*:}"
        elif [ "$(get_level "$line")" -gt "0" ] && [ -n "$COMMAND" ]; then
            # Trim whitespaces
            FST_ARG=$( printf '%s' "${line%%:*}" | sed -e 's/^ *//' -e 's/ *$//')
            SND_ARG=$( printf '%s' "${line#*:}"  | sed -e 's/^ *//' -e 's/ *$//')
            if (ACTION="$ACTION" "${COMMAND}_exists") > /dev/null 2>&1; then
                output debug "executing FLAGS='${OPTIONS}' '$COMMAND' '$FST_ARG' '$SND_ARG'"
                (ACTION="$ACTION" FLAGS="${OPTIONS}" "$COMMAND" "$FST_ARG" "$SND_ARG")
            else
                output error "command '$COMMAND' not found\n"
            fi
        fi
    done
    return 0
}
