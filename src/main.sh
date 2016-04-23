# main
case "$1" in
    --help)
        dottle_show_help
        ;;
    *)
        ACTION="$1" dottle_import "__ROOT__" "${2:-install.conf.yml}"
        ;;
esac
