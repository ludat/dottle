dottle_debug_exists () { return 0; }
dottle_debug () {
    FLAGS=$(default_flag "$FLAGS" "true" "")
    FLAGS=$(default_flag "$FLAGS" "false" "!")
    FLAGS=$(default_flag "$FLAGS" "first" "=first")
    FLAGS=$(default_flag "$FLAGS" "second" "=second")
    output ok "debug command\n"
    output ok "Flags: '$FLAGS'\n"
    ARG1="$(expand_vars "${1}")"
    output ok "Arg1:  '$ARG1'\n"
    ARG2="$(expand_vars "${2}")"
    output ok "Arg2:  '$ARG2'\n"
}
