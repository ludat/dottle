true_flag_regex () {
    printf "\(^[^']*\)\(.*'.*'.*\)* \(%s\) \([^']*\)\(.*'.*'.*\)*$" "$1"
}
false_flag_regex () {
    printf "\(^[^']*\)\(.*'.*'.*\)* \(%s!\) \([^']*\)\(.*'.*'.*\)*$" "$1"
}
quoted_flag_regex () {
    printf "\(^[^']*\)\(.*'.*'.*\)* %s='\([^']*\)' \([^']\)*\(.*'.*'.*\)*$" "$1"
}
simple_flag_regex () {
    printf "\(^[^']*\)\(.*'.*'.*\)* %s=\([^ ]*\) \([^']*\)\(.*'.*'.*\)*$" "$1"
}

get_flag () {
    # if the key is alone exclamation point and there are pair number of quotes
    # to the left and right the print true
    if printf '%s' " ${1} " | grep "$(true_flag_regex "${2}")" > /dev/null; then
        printf '%s' "true"
        return 0
    fi

    # if the key is alone followed by an exclamation point and there are pair
    # number of quotes to the left and right the print true
    if printf '%s' " ${1} " | grep "$(false_flag_regex "${2}")" > /dev/null; then
        printf '%s' "false"
        return 0
    fi

    # if the key is followed by an equals and a single quote then return
    # everything until another single quote
    if printf '%s' " ${1} " | grep "$(quoted_flag_regex "${2}")" > /dev/null; then
        printf '%s' " ${1} " | sed "s/$(quoted_flag_regex "${2}")/\3/"
        return 0
    fi

    # if the key is followed by an equals then return everything until an space
    if printf '%s' " ${1} " | grep "$(simple_flag_regex "${2}")" > /dev/null; then
        printf '%s' " ${1} " | sed "s/$(simple_flag_regex "${2}")/\3/"
        return 0
    fi

    # else don't return nothing and report failure
    # TODO maybe this should explode louder
    return 1
}

remove_flag () {
    # if the key is alone exclamation point
    if printf '%s' " ${1} " | grep "$(true_flag_regex "${2}")" > /dev/null; then
        printf '%s' " ${1} " | sed "s/$(true_flag_regex "${2}")/\1\2 \4\5/"
        return 0
    fi

    # if the key is alone followed by an exclamation point
    if printf '%s' " ${1} " | grep "$(false_flag_regex "${2}")" > /dev/null; then
        printf '%s' " ${1} " | sed "s/$(false_flag_regex "${2}")/\1\2 \4\5/"
        return 0
    fi

    # if the key is followed by an equals and a single quote
    if printf '%s' " ${1} " | grep "$(quoted_flag_regex "${2}")" > /dev/null; then
        printf '%s' " ${1} " | sed "s/$(quoted_flag_regex "${2}")/\1\2 \4\5/"
        return 0
    fi

    # if the key is followed by an equals
    if printf '%s' " ${1} " | grep "$(simple_flag_regex "${2}")" > /dev/null; then
        printf '%s' " ${1} " | sed "s/$(simple_flag_regex "${2}")/\1\2 \4\5/"
        return 0
    fi

    # else the key is not in the array so I don't have to do nothing
    printf '%s' "${1}"
}

set_flag () {
    add_flag "$(remove_flag "$1" "$2")" "${2}" "${3}"
}

add_flag () {
    printf "%s %s%s" "${1}" "${2}" "${3}"
}

default_flag () {
    if ! get_flag "$1" "$2"> /dev/null; then
        add_flag "${1}" "${2}" "${3}"
    else
        printf "%s" "${1}"
    fi
}
