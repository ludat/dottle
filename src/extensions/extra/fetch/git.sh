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

    if [ -d "${DEST}/.git" ]; then

        output ok "$DEST is installed and is a git repo"
    else
        [ "$(get_flag "$FLAGS" 'backup')" = 'true' ] && backup "$DEST"

        rm -rf "$DEST"

        mkdir -p "$DEST"

        output debug "Running git clone of '$REPO'"
        if ! git clone --recursive --branch "$BRANCH" "$REPO" "$DEST" > "$STDOUT" 2> "$STDERR" < "$STDIN"; then
            output error "git clone command failed\n"
            return 1
        fi
    fi
}



# this will be useful when the update command is in place

# [ "$(get_flag "$FLAGS" 'update')" = 'true' ] && \
# (cd "$DEST"; [ "$(git config --get "remote.${REMOTE}.url")" = "${REPO}" ])
# (
# if ! cd "$DEST"; then
#     output error "Couldn't \`cd\` into '$DEST'\n"
#     return 1
# fi

# if ! git config http.sslVerify "$VERIFY_SSL"; then
#     output error "Couldn't set config\n"
#     return 1
# fi

# output debug "git 'checkout' '$BRANCH'"
# if ! git checkout "$BRANCH" > /dev/null 2>&1; then
#     output error "Couldn't checkout '$BRANCH'\n"
#     return 1
# fi

# output running "pulling '$BRANCH' branch from '$REPO'\n"
# output debug "git 'pull' '$REMOTE' '$BRANCH'"
# if ! git pull "$REMOTE" "$BRANCH" > /dev/null 2>&1; then
#     output error "Couldn't pull '$BRANCH' branch from '$REMOTE'\n"
#     return 1
# fi

# if [ "$(get_flag "$FLAGS" 'recursive')" = 'true' ]; then
#     output debug "git submodule update --init --recursive"
#     if ! git submodule update --init --recursive > /dev/null 2>&1; then
#         output error "Couldn't update submodules\n"
#         return 1
#     fi
# fi
# ) && output ok "Pulled successfully\n"
