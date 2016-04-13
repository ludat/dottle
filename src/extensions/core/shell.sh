# escape a string mainly for expand_vars
escape () {
    output debug "EXPAND: '$1'"
    printf '%s' "$1" | sed \
                           -e 's:^~/:'"$HOME"'/:' \
                           -e 's/\\\([^\$]\)/\\\\&/g' \
                           -e 's/"/\\"/g' \
                           -e 's/\\\$/\\\$/g'
}

# expand env vars in a string
expand_vars () {
    eval printf '%s' "\"$(escape "$1")\""
}



dottle_shell_exists () { return 0; }
dottle_shell () {
    # execute an external command
    # Possible configuration flags:
    #   interactive: if set all stds will be redirected to this shell
    #       default: interactive!
    FLAGS=$(default_flag "$FLAGS" "interactive" "!")
    #   stdin: sets the stdin of cmd
    #       default: stdin=
    FLAGS=$(default_flag "$FLAGS" "stdin" "=")
    #   stdout: sets the stdout of cmd
    #       default: stdout=
    FLAGS=$(default_flag "$FLAGS" "stdout" "=")
    #   stderr: sets the stderr of cmd
    #       default: stderr=
    FLAGS=$(default_flag "$FLAGS" "stderr" "=")

    STDIN="$(get_flag "$FLAGS" 'stdin')"
    output debug "STDIN: $STDIN"
    STDOUT="$(get_flag "$FLAGS" 'stdout')"
    output debug "STDOUT: $STDOUT"
    STDERR="$(get_flag "$FLAGS" 'stderr')"
    output debug "STDERR: $STDERR"
    RUN="$1"
    OK=""
    CMD="${2}"

    # add >/dev/null to cmd if stdout flag is not set
    if [ "$(get_flag "$FLAGS" 'interactive')" = 'true' ]; then
        OK="     ${RUN}"
        RUN="${RUN}\n"
        CMD="$CMD > ${STDOUT:-/dev/stdout}"
        CMD="$CMD < ${STDIN:-/dev/tty}"
        CMD="$CMD 2> ${STDERR:-/dev/stderr}"
    elif [ "$(get_flag "$FLAGS" 'interactive')" = 'false' ]; then
        OK=" "
        RUN="${RUN} "
        CMD="$CMD > ${STDOUT:-/dev/null}"
        CMD="$CMD < ${STDIN:-/dev/null}"
        CMD="$CMD 2> ${STDERR:-/dev/null}"
    else
        output internal_error "interactive not in '$FLAGS'"
        return 1
    fi
    output debug "COMMAND: $CMD"

    output running "$RUN"
    if ( eval $CMD ); then
        output ok "$OK\n"
    else
        output error "$OK\n"
    fi
}
