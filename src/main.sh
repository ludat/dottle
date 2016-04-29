# main
case "$1" in
    --help)
        dottle_show_help
        ;;
    selfupgrade)
        output error "Not implemented yet D:"
        ;;
    *)
        ACTION="$1" dottle_import "__ROOT__" "${2:-.}"
        ;;
esac
