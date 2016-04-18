

dottle_get_git_exists () { return 0; }
dottle_get_git () {
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
    #   update: if set and path already exists and is a git repo just pull from origin
    #       default: update
    FLAGS=$(default_flag "$FLAGS" "update" "")
    #   verify_ssl: if set check if cret is valid (usefull for self signed certs)
    #       default: verify_ssl
    FLAGS=$(default_flag "$FLAGS" "verify_ssl" "")
    #   recursive: when cloning a repo use flag --recursive
    #       default: recursive
    FLAGS=$(default_flag "$FLAGS" "recursive" "")
    #   tar_magic: if git is not installed use tar and curl to get remote files (hacky as fuck)
    #       default: tar_magic!
    FLAGS=$(default_flag "$FLAGS" "tar_magic" "!")
    #   force: try to get repo no matter what
    #       default: force!
    FLAGS=$(default_flag "$FLAGS" "force" "!")

    output debug "FLAGS: '${FLAGS}'"
    DEST="$(expand_vars "${1}")"
    output debug "DEST: '${DEST}'"
    REPO="$(expand_vars "${2}")"
    output debug "REPO: '${REPO}'"
    BRANCH="$(get_flag "$FLAGS" 'branch')"
    output debug "BRANCH: '${BRANCH}'"
    REMOTE="$(get_flag "$FLAGS" 'remote')"
    output debug "REMOTE: '${REMOTE}'"
    if [ "$(get_flag "$FLAGS" 'recursive')" = 'true' ]; then
        RECURSIVE="--recursive"
    else
        RECURSIVE=""
    fi
    output debug "RECURSIVE: '${RECURSIVE}'"
    if [ "$(get_flag "$FLAGS" 'verify_ssl')" = 'true' ]; then
        VERIFY_SSL="true"
    else
        VERIFY_SSL="false"
    fi
    output debug "VERIFY_SSL: '${VERIFY_SSL}'"

    # if git is not installed fail
    if ! command -v git > /dev/null && [ "$(get_flag "$FLAGS" 'tar_magic')" = 'false' ]; then
        output error "git is not installed and tar_magic flag is not set\n"
        return 1
    fi

    if [ -d "${DEST}/.git" ] && \
            [ "$(get_flag "$FLAGS" 'update')" = 'true' ] && \
            (cd "$DEST"; [ "$(git config --get "remote.${REMOTE}.url")" = "${REPO}" ]); then
        (
        if ! cd "$DEST"; then
            output error "Couldn't \`cd\` into '$DEST'\n"
            return 1
        fi

        if ! git config http.sslVerify "$VERIFY_SSL"; then
            output error "Couldn't set config\n"
            return 1
        fi

        output debug "git 'checkout' '$BRANCH'"
        if ! git checkout "$BRANCH" > /dev/null 2>&1; then
            output error "Couldn't checkout '$BRANCH'\n"
            return 1
        fi

        output running "pulling '$BRANCH' branch from '$REPO'\n"
        output debug "git 'pull' '$REMOTE' '$BRANCH'"
        if ! git pull "$REMOTE" "$BRANCH" > /dev/null 2>&1; then
            output error "Couldn't pull '$BRANCH' branch from '$REMOTE'\n"
            return 1
        fi

        if [ "$(get_flag "$FLAGS" 'recursive')" = 'true' ]; then
            output debug "git submodule update --init --recursive"
            if ! git submodule update --init --recursive > /dev/null 2>&1; then
                output error "Couldn't update submodules\n"
                return 1
            fi
        fi
        ) && output ok "Pulled successfully\n"
    else
        [ "$(get_flag "$FLAGS" 'backup')" = 'true' ] && backup "$DEST"
        rm -rf "$DEST"
        mkdir -p "$DEST"
        if command -v git > /dev/null; then
            output debug "git clone --config 'http.sslVerify=$VERIFY_SSL' '$RECURSIVE' --branch '$BRANCH' '$REPO' '$DEST'"
            if ! git clone --config "http.sslVerify=$VERIFY_SSL" "$RECURSIVE" --branch "$BRANCH" "$REPO" "$DEST" > /dev/null 2>&1; then
                output error "git clone command failed\n"
                return 1
            fi
        else
            output error "tar_magic is not implemented yet\n"
        fi
    fi
}
