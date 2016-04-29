backup () {
    if [ -e "$1" ]; then
        while true; do
            NEW_FILE="${1}.$(date "+%Y-%m-%d_%H-%M-%S").dottle.backup"
            if [ ! -e "$NEW_FILE" ]; then
                if mv "$1" "$NEW_FILE"; then
                    output debug "Backed up '$1' to '$NEW_FILE'"
                    return 0
                else
                    output error "Failed to back up '${1}' to '${NEW_FILE}'"
                    return 1
                fi
            fi
        done
    else
        return 1
    fi
}
