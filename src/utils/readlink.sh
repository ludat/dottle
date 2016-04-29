# execute the function in a *subshell* to localize variables and the effect of `cd`.
rreadlink() {
    TARGET=$1
    FILE=''

    while true; do
        [ -e "$TARGET" ] || return 1
        cd "$(dirname -- "$TARGET")"
        FILE=$(basename -- "$TARGET")
        if [ -L "$FILE" ]; then
            TARGET=$(ls -l "$FILE")
            TARGET=${TARGET#* -> }
            continue
        fi
        break
    done

    printf '%s' "$(pwd -P)/$FILE"
}
