# main
case "$1" in
    --help)
        dottle_show_help
        ;;
    check)
        CONFIG_FILE="${2:-install.conf.yml}"
        if dottle_check; then
            output ok "The file doesn't contain any errors\n"
        else
            output error "The file has some serious errors\n"
        fi
        ;;
    install)
        CONFIG_FILE="${2:-install.conf.yml}"
        if (dottle_check "Checking root" "$CONFIG_FILE"); then
            (dottle_install "__ROOT__" "$CONFIG_FILE")
        fi
        ;;
    remove)
        output error "not implemented yet\n"
        ;;
    clean)
        output error "not implemented yet\n"
        ;;
    *)
        printf "%s\n" "Try 'install' or '--help'"
        ;;
esac
