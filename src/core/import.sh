unbuffered_sed () {
    while IFS='' read -r buffered_line; do
        printf '%s\n' "$buffered_line" | sed -e "$1"
    done
}

dottle_import_exists () { return 0; }
dottle_import () {
    # import a config file
    # No configuration flags for this yet

    output debug "Flags for import: '$FLAGS'"


    if [ -d "$2" ]; then
        CONFIG_FILE="${2}/install.conf.yml"
    else
        CONFIG_FILE="${2}"
    fi

    if [ -e "$CONFIG_FILE" ]; then
        BASEDIR="$(dirname -- "${CONFIG_FILE}")"
        CONFIG_FILE="$(basename -- "${CONFIG_FILE}")"
    else
        output error "Couldn't import '$CONFIG_FILE'\n"
        return 1
    fi

    cd "$BASEDIR" || { output error "Couldn't cd into config directory." && return 1; }

    if [ "$1" != '__ROOT__' ]; then
        OUTPUT_FILTER='s/^/    /'
    fi

    [ "$1" != '__ROOT__' ] && output running "$1\n"

    case "$ACTION" in
        check)
            if dottle_action_check < "$CONFIG_FILE" | unbuffered_sed "$OUTPUT_FILTER"; then
                output ok "The file doesn't contain any errors\n"
            else
                output error "The file has some serious errors\n"
            fi
            ;;
        install|update)
            if dottle_action_check < "$CONFIG_FILE" | unbuffered_sed "$OUTPUT_FILTER"; then
                if dottle_action_exec < "$CONFIG_FILE" | unbuffered_sed "$OUTPUT_FILTER"; then
                    [ "$1" != '__ROOT__' ] && output ok "$1\n"
                fi
            fi
            ;;
        uninstall)
            output error "not implemented yet D:"
            return 1
            ;;
        *)
            output error "Action '$ACTION' not found. Try --help"
            return 1
    esac
    return 0
}
