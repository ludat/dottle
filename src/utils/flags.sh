get_flag () {
    printf '%s' " ${1} " | grep " ${2} " > /dev/null && printf '%s' "true" && return 0
    printf '%s' " ${1} " | grep " ${2}! " > /dev/null && printf '%s' "false" && return 0
    if printf '%s' " ${1} " | grep " ${2}=" > /dev/null; then
        printf '%s' " ${1} " | sed 's/.* '"${2}"'=\([^ ]*\) .*/\1/' && return 0
    fi
    return 1
}

default_flag () {
    if ! get_flag "$1" "$2"> /dev/null; then
        printf "%s %s%s" "${1}" "${2}" "${3}"
    else
        printf "%s" "${1}"
    fi
}
