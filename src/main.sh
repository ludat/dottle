# main
case "$1" in
    --help)
        dottle_show_help
        ;;
    --version)
        dottle_show_version
        ;;
    selfupgrade)
        output error "Not implemented yet D:"
        ;;
    *)
        ACTION="$1" dottle_import "__ROOT__" "${2:-.}"
        ;;
esac
