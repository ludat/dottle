# execute the function in a *subshell* to localize variables and the effect of `cd`.
rreadlink() {
    TARGET=$1
    FILE=''
    TARGET_DIR=''

    while true; do # Resolve potential symlinks until the ultimate target is found.
        [ -e "$TARGET" ] || return 1
        cd "$(dirname -- "$TARGET")" # Change to target dir; necessary for correct resolution of target path.
        FILE=$(basename -- "$TARGET") # Extract filename.
        if [ -L "$FILE" ]; then
            # Extract [next] target path, which may be defined
            # *relative* to the symlink's own directory.
            # Note: We parse `ls -l` output to find the symlink target
            #       which is the only POSIX-compliant, albeit somewhat fragile, way,
            TARGET=$(ls -l "$FILE")
            TARGET=${TARGET#* -> }
            continue # Resolve [next] symlink target.
        fi
        break # Ultimate target reached.
    done
    TARGET_DIR=$(pwd -P) # Get canonical dir. path
    # Output the ultimate target's canonical path.
    printf '%s' "${TARGET_DIR}/$FILE"
}
