dottle_import_exists () { return 0; }
dottle_import () {
    # import a config file
    # No configuration flags for this yet

    output debug "Flags for import: '$FLAGS'"

    if [ ! -f "$2" ]; then
        output error "Can't import '$2'. File doesn't exist\n"
        return 1
    fi

    BASEDIR="$(cd "$(dirname "${2}")" && pwd)"
    CONFIG_FILE="$(basename "${2}")"

    cd "$BASEDIR" || { output error "Couldn't cd into config directory." && return 1; }

    if [ "$1" != '__ROOT__' ]; then
        OUTPUT_FILTER='s/^/    /'
    fi

    [ "$1" != '__ROOT__' ] && output running "$1\n"

    case "$ACTION" in
        check)
            if dottle_action_check < "$CONFIG_FILE" | sed -e "$OUTPUT_FILTER"; then
                output ok "The file doesn't contain any errors\n"
            else
                output error "The file has some serious errors\n"
            fi
            ;;
        install|update)
            if dottle_action_check < "$CONFIG_FILE" | sed -e "$OUTPUT_FILTER"; then
                if dottle_action_exec < "$CONFIG_FILE" | sed -e "$OUTPUT_FILTER"; then
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
