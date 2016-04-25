dottle_git_is_already_installed () {
    # if dest exists AND the remote is ok AND the branch is ok, there is nothing to do
    (
        cd "$DEST" &&
            [ -d ".git" ] &&
            [ "$(git config --get "remote.${REMOTE}.url")" = "${REPO}" ] &&
            [ "$(git rev-parse --abbrev-ref HEAD)" = "${BRANCH}" ]
    ) > /dev/null 2>&1
}

dottle_fetch_git_exists () { return 0; }
dottle_fetch_git () {
    # Get git repo into a directory
    # Possible configuration flags:
    #   branch: branch name of the repo
    #       default: branch=master
    FLAGS=$(default_flag "$FLAGS" "branch" "=master")
    #   remote: branch name of the repo
    #       default: remote=origin
    FLAGS=$(default_flag "$FLAGS" "remote" "=origin")
    #   backup: if the file already exists back it up otherwise just remove it
    #       default: backup!
    FLAGS=$(default_flag "$FLAGS" "backup" "!")
    #   force: try to get repo no matter what
    #       default: force!
    FLAGS=$(default_flag "$FLAGS" "force" "!")
    #   interactive: if set all stds will be redirected to this shell
    #       default: interactive!
    FLAGS=$(default_flag "$FLAGS" "interactive" "!")
    #   create: if final directory doesn't exist create them recursively
    #       default: create
    FLAGS=$(default_flag "$FLAGS" "create" "")

    output debug "FLAGS: '${FLAGS}'"
    DEST="$(expand_vars "${1}")"
    output debug "DEST: '${DEST}'"
    REPO="$(expand_vars "${2}")"
    output debug "REPO: '${REPO}'"
    BRANCH="$(get_flag "$FLAGS" 'branch')"
    output debug "BRANCH: '${BRANCH}'"
    REMOTE="$(get_flag "$FLAGS" 'remote')"
    output debug "REMOTE: '${REMOTE}'"

    # if git is not installed fail
    if ! command -v git > /dev/null; then
        output error "git is not installed\n"
        return 1
    fi

    # add >/dev/null to cmd if stdout flag is not set
    if [ "$(get_flag "$FLAGS" 'interactive')" = 'true' ]; then
        STDOUT=/dev/stdout
        STDIN=/dev/tty
        STDERR=/dev/stderr
    elif [ "$(get_flag "$FLAGS" 'interactive')" = 'false' ]; then
        STDOUT=/dev/null
        STDIN=/dev/null
        STDERR=/dev/stderr
    else
        output internal_error "interactive not in '$FLAGS'"
        return 1
    fi

    case "$ACTION" in
        install)
            dottle_fetch_git_install
        ;;
        update)
            dottle_fetch_git_update
        ;;
        uninstall)
            output info "not implemented yet D:"
            return 1
            ;;
        *)
            output error "Action '$ACTION' not supported for fetch.git module"
            return 1
            ;;
    esac
}

dottle_fetch_git_install () {
    if dottle_git_is_already_installed; then
        output ok "'$REPO' already installed in '$DEST'\n"
        return 0
    fi

    # if DEST dir doesn't exists and create flag is set, create it
    if ! [ -d "$(dirname "$DEST")" ]; then
        if [ "$(get_flag "$FLAGS" 'create')" = 'true' ]; then
            mkdir -p "$(dirname "$DEST")"
        else
            output error "'$(dirname "${DEST}")' doesn't exists. Quiting because create flag is not set\n"
            return 1
        fi
    fi

    # If the file already exists (maybe make a backup and) remove it
    if [ -e "$DEST" ]; then
        [ "$(get_flag "$FLAGS" 'backup')" = 'true' ] && backup "$DEST"
        rm -rf "$DEST"
    fi

    output debug "git clone --recursive --origin \"$REMOTE\" --branch \"$BRANCH\" \"$REPO\" \"$DEST\" > \"$STDOUT\" 2> \"$STDERR\" < \"$STDIN\""
    if git clone --recursive \
            --origin "$REMOTE" \
            --branch "$BRANCH" \
            "$REPO" "$DEST" > "$STDOUT" 2> "$STDERR" < "$STDIN"; then
        output ok "Cloned '$REPO' in '$DEST'"
    else
        output error "Failed to clone '$REPO'"
        return 1
    fi

}

dottle_fetch_git_update () {
    if ! dottle_git_is_already_installed; then
        output ok "'$REPO' is not installed in '$DEST'. Try 'install' instead of update\n"
        return 0
    fi

    cd "$DEST" || { return 1; }

    output running "pulling '$BRANCH' branch from '$REPO'\n"
    if git pull "$REMOTE" "$BRANCH" > "$STDOUT" 2> "$STDERR" < "$STDIN"; then
        output ok "Pulled successfully\n"
    else
        output error "Couldn't pull '$BRANCH' branch from '$REMOTE'\n"
        return 1
    fi

    output debug "git submodule update --init --recursive"
    if git submodule update --init --recursive; then
        output ok "Pulled submodules successfully"
        return 0
    else
        output error "Couldn't update submodules\n"
        return 1
    fi
}
