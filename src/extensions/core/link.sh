dottle_link_exists () { return 0; }
dottle_link () {
    # Creates link from the first arg to second arg
    # Possible configuration flags:
    #   create: if final directory doesn't exist create them recursively
    #       default: create
    FLAGS=$(default_flag "$FLAGS" "create" "")
    #   force: create recursive directories and symlink no matter what
    #       default: force!
    FLAGS=$(default_flag "$FLAGS" "force" "!")
    #   ign_broken: don't care if link will be broke
    #       default: ign_broken
    FLAGS=$(default_flag "$FLAGS" "ign_broken" "!")
    #   backup: if file already exists, back it up
    #       default: backup
    FLAGS=$(default_flag "$FLAGS" "backup" "")
    #   relative: if set target of links will be relative and won't be altered in any way
    #       default: relative
    FLAGS=$(default_flag "$FLAGS" "relative" "")

    case "$ACTION" in
        install|update)
            ;;
        uninstall)
            output error "not implemented yet D:"
            return 1
            ;;
        *)
            output error "Action '$ACTION' not supported for link module"
            return 1
            ;;
    esac

    # if the force flag is set some flags will be overridden
    if [ "$(get_flag "$FLAGS" 'force')" = 'true' ]; then
        FLAGS="$(set_flag "$FLAGS" "ign_broken" "true")"
        output debug "'ign_broken' flag was set to true\n"
        FLAGS="$(set_flag "$FLAGS" "create" "true")"
        output debug "'create' flag was set to true\n"
    fi

    output debug "Flags for link: '$FLAGS'"

    DEST="$(expand_vars "${1}")"
    output debug "DEST: '$DEST'"
    SOURCE="$(expand_vars "${BASEDIR}/${2}")"

    # if link will be broken and ign_broken flag is set exit
    if [ "$(get_flag "$FLAGS" 'ign_broken')" = 'false' ] && [ ! -e "$SOURCE" ]; then
        output error "'${SOURCE}' doesn't exists. Quiting because ign_broken flag is not set\n"
        return 1
    fi

    # if relative flag set to false expand with BASEDIR else let it raw
    if [ "$(get_flag "$FLAGS" 'relative')" = 'true' ]; then
        SOURCE_T="$(printf '%s' "$SOURCE" | sed -e 's:^/::')"
        DEST_T="$(printf '%s' "$DEST" | sed -e 's:^/::')"

        SOURCE_BASE="$(printf '%s' "$SOURCE_T" | grep -o "^[^/]*")"
        DEST_BASE="$(printf '%s' "$DEST_T" | grep -o "^[^/]*")"

        while [ "$DEST_BASE" = "$SOURCE_BASE" ]; do
            SOURCE_T="$(printf '%s' "$SOURCE_T" | sed -e 's:^[^/]*/::')"
            DEST_T="$(printf '%s' "$DEST_T" | sed -e 's:^[^/]*/::')"

            SOURCE_BASE="$(printf '%s' "$SOURCE_T" | grep -o "^[^/]*")"
            DEST_BASE="$(printf '%s' "$DEST_T" | grep -o "^[^/]*")"
        done
        if [ ! "$(dirname "$DEST_T")" = "." ]; then
            SOURCE="$(dirname "$DEST_T" | sed -e 's:[^/]*:..:g')/$SOURCE_T"
        else
            SOURCE="$SOURCE_T"
        fi
    fi

    output debug "SOURCE: '$SOURCE'"

    # if DEST dir doesn't exists and create flag is set, create it
    if ! [ -d "$(dirname "$DEST")" ]; then
        if [ "$(get_flag "$FLAGS" 'create')" = 'true' ]; then
            mkdir -p "$(dirname "$DEST")"
        else
            output warn "'$(dirname "${DEST}")' doesn't exists. Quiting because create flag is not set\n"
            return 1
        fi
    fi

    # if the dest path is a link and it points somewhere inside the basedir remove
    if [ -L "$DEST" ] && printf '%s' "$(rreadlink "$DEST")" | grep "^$BASEDIR" > /dev/null; then
        output info "File '${DEST}' exists and it points to my BASEDIR. Replacing it\n"
        rm "$DEST"
    fi

    # If the file already exists (maybe make a backup and) remove it
    if [ -e "$DEST" ]; then
        [ "$(get_flag "$FLAGS" 'backup')" = 'true' ] && backup "$DEST"
        rm -rf "$DEST"
    fi

    # Actually make the link
    if ln -s "$SOURCE" "$DEST"; then
        output ok "${1} -> ${SOURCE}\n"
    else
        output error "${1} -> ${SOURCE}\n"
    fi
}
