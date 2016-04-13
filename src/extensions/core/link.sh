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

    output debug "Flags for link: '$FLAGS'"

    DEST="$(expand_vars "${1}")"
    output debug "DEST: '$DEST'"
    SOURCE="$(expand_vars "${BASEDIR}/${2}")"

    # if link will be broken and ign_broken flag is set exit
    # if [ "$(get_flag "$FLAGS" 'ign_broken')" = 'false' ] && [ ! -e "$(cd "$(dirname "$DEST")" && pwd && rreadlink "$SOURCE")" ]; then
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
            # output info "SOURCE_T = $SOURCE_T"
            # output info "DEST_T = $DEST_T"

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

    # check if force flag is set
    if [ "$(get_flag "$FLAGS" 'force')" = 'true' ]; then
        output debug "force flag is set to true. I will do my best to fulfil your wishes master"
        [ "$(get_flag "$FLAGS" 'backup')" = 'true' ] && backup "$DEST"
        rm -rf "$DEST"
        mkdir -p "$(dirname "$DEST")"
        if ln -s "$SOURCE" "$DEST"; then
           output ok "${DEST} -> ${SOURCE}\n"
           return 0
        else
            output error "${DEST} -> ${SOURCE}\n"
            return 1
        fi
    fi

    # if DEST dir doesn't exists and create flag is set, create it
    if [ ! -d "$(dirname "$DEST")" ]; then
        if [ "$(get_flag "$FLAGS" 'create')" = 'true' ]; then
            mkdir -p "$(dirname "$DEST")"
        elif [ "$(get_flag "$FLAGS" 'create')" = 'false' ]; then
            output warn "'$(dirname "${DEST}")' doesn't exists. Quiting because create flag is not set\n"
            return 1
        else
            output internal_error "create not in '$FLAGS'"
        fi
    fi

    if [ -L "$DEST" ]; then
        if printf '%s' "$(rreadlink "$DEST")" | grep "^$BASEDIR" > /dev/null; then
            output info "File '${DEST}' exists and it points to my BASEDIR. Replacing it\n"
            rm "$DEST"
        else
            output error "'${DEST}' is a link but it's not mine. Quiting\n"
            return 1
        fi
    elif [ -e "$DEST" ]; then
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
