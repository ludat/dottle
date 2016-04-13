# get config file line indentation level
get_level () {
    printf '%s' "$1" | grep -o '^\s*' | grep -c -o " \{4\}"
}

dottle_install_exists () { return 0; }
dottle_install () {
    # install a config file
    # No configuration flags for this yet

    output debug "Flags for install: '$FLAGS'"

    if [ ! -f "$2" ]; then
        output error "Can't install '$2'. File doesn't exist\n"
        return 1
    fi

    BASEDIR="$(cd "$(dirname "${2}")" && pwd)"
    CONFIG_FILE="$(basename "${2}")"

    cd "$BASEDIR" || { output error "Couldn't cd into config directory." && return 1; }

    if [ "$1" != '__ROOT__' ]; then
        OUTPUT_FILTER='s/^/    /'
    fi

    [ "$1" != '__ROOT__' ] && output running "$1\n"

    COMMAND=''
    OPTIONS=''
    while IFS='' read -r line; do
        # Replace tabs with four spaces
        # Remove comments from lines
        line=$(printf '%s' "$line" | sed 's/#.*$//' | sed 's/^ *$//')
        if [ -z "$line" ]; then
            continue
        fi
        if [ "$(get_level "$line")" -eq "0" ]; then
            COMMAND="dottle_${line%%:*}"
            OPTIONS="${line#*:}"
        elif [ "$(get_level "$line")" -gt "0" ] && [ -n "$COMMAND" ]; then
            # Trim whitespaces
            FST_ARG=$( printf '%s' "${line%%:*}" | sed -e 's/^ *//' -e 's/ *$//')
            SND_ARG=$( printf '%s' "${line#*:}"  | sed -e 's/^ *//' -e 's/ *$//')
            if ("${COMMAND}_exists") > /dev/null 2>&1; then
                output debug "executing FLAGS='${OPTIONS}' '$COMMAND' '$FST_ARG' '$SND_ARG'"
                (FLAGS="${OPTIONS}" "$COMMAND" "$FST_ARG" "$SND_ARG" | sed -e "$OUTPUT_FILTER")
            else
                output error "command '$COMMAND' not found\n"
            fi
        fi
    done < "$CONFIG_FILE"
    [ "$1" != '__ROOT__' ] && output ok "$1\n"
    return 0
}
