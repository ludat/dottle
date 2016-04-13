backup () {
    if [ -e "$1" ] && [ ! -L "$1" ]; then
        while true; do
            new_file="${1}.$(date "+%Y-%m-%d_%H-%M-%S").backup"
            if [ ! -e "${new_file}" ]; then
                if mv "$1" "$new_file"; then
                    output debug "Backed up '$1' to '$new_file'"
                    return 0
                else
                    output error "Failed to back up '${1}' to '${new_file}'"
                    return 1
                fi
            fi
        done
    else
        return 1
    fi
}
