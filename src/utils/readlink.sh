# execute the function in a *subshell* to localize variables and the effect of `cd`.
rreadlink() {
    target=$1
    fname=''
    targetDir=''

    while true; do # Resolve potential symlinks until the ultimate target is found.
        [ -L "$target" ] || [ -e "$target" ] || return 1
        cd "$(dirname -- "$target")" # Change to target dir; necessary for correct resolution of target path.
        fname=$(basename -- "$target") # Extract filename.
        if [ -L "$fname" ]; then
            # Extract [next] target path, which may be defined
            # *relative* to the symlink's own directory.
            # Note: We parse `ls -l` output to find the symlink target
            #       which is the only POSIX-compliant, albeit somewhat fragile, way,
            target=$(ls -l "$fname")
            target=${target#* -> }
            continue # Resolve [next] symlink target.
        fi
        break # Ultimate target reached.
    done
    targetDir=$(pwd -P) # Get canonical dir. path
    # Output the ultimate target's canonical path.
    printf '%s' "${targetDir}/$fname"
}
