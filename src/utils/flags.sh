get_flag () {
    # if the key is alone exclamation point and there are pair number of quotes
    # to the left and right the print true
    if printf '%s' " ${1} " | \
            grep "^[^']*\(.*'.*'.*\)* ${2} [^']*\(.*'.*'.*\)*$" > /dev/null; then
        printf '%s' "true"
        return 0
    fi

    # if the key is alone followed by an exclamation point and there are pair
    # number of quotes to the left and right the print true
    if printf '%s' " ${1} " | \
            grep "^[^']*\(.*'.*'.*\)* ${2}! [^']*\(.*'.*'.*\)*$" > /dev/null; then
        printf '%s' "false"
        return 0
    fi

    # if the key is followed by an equals and a single quote then return
    # everything until another single quote
    if printf '%s' " ${1} " | \
            grep "^[^']*\(.*'.*'.*\)* ${2}='[^']*' [^']*\(.*'.*'.*\)*$" > /dev/null; then

        printf '%s' " ${1} " | \
            sed "s/^[^']*\(.*'.*'.*\)* ${2}='\([^']*\)' [^']*\(.*'.*'.*\)*$/\2/"
        return 0
    fi

    # if the key is followed by an equals then return everything until an space
    if printf '%s' " ${1} " | \
            grep "^[^']*\(.*'.*'.*\)* ${2}=[^ ]*' [^']*\(.*'.*'.*\)*$" > /dev/null; then

        printf '%s' " ${1} " | \
            sed "s/^[^']*\(.*'.*'.*\)* ${2}=\([^ ]*\) [^']*\(.*'.*'.*\)*$/\2/"
        return 0
    fi

    # else don't return nothing and report failure
    # TODO maybe this should explode louder
    return 1
}

default_flag () {
    if ! get_flag "$1" "$2"> /dev/null; then
        printf "%s %s%s" "${1}" "${2}" "${3}"
    else
        printf "%s" "${1}"
    fi
}
