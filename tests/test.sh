#!/bin/sh

. ./src/utils/output.sh
. ./src/utils/readlink.sh

export DOTTLE_PATH="$(rreadlink "${DOTTLE_PATH:-dottle}")"
export DEFAULTS_PATH="$(rreadlink "${DEFAULTS_PATH:-tests/defaults}")"
export TESTS_PATH="${1:-tests/cases}"

run_test () {
    if [ -z "$1" ]; then
        return 1
    fi
    ( cd "$1"
    TEST_BASEPATH="$(pwd)"

    rm -rf fakehome.actual
    if [ -d "fakehome" ]; then
        cp -R fakehome fakehome.actual
    else
        mkdir fakehome.actual
    fi

        (
        cd fakehome.actual
        FAKEHOME="$TEST_BASEPATH/fakehome.actual"
        HOME="$FAKEHOME" "$TEST_BASEPATH/cmd.sh" \
            > "$TEST_BASEPATH/stdout.actual" \
            2> "$TEST_BASEPATH/stderr.actual"
        printf "%d\n" "$?" > "$TEST_BASEPATH/exit.actual"
        )
    )
}
are_different () {
    if diff --recursive --unified "$1" "$2" > "$3"; then
        return 1
    else
        output debug "$1 is not correct"
        return 0
    fi
}

check_results () {
    (
    cd "$1" || return 1
    RESULT=
    for FILE in "stderr" "stdout" "exit"; do
        if [ -e "${FILE}.expected" ]; then
            FILE_TO_COMPARE="${FILE}.expected"
        else
            FILE_TO_COMPARE="$DEFAULTS_PATH/$FILE.expected"
        fi

        if are_different "${FILE}.actual" "$FILE_TO_COMPARE" "${FILE}.diff"; then
            RESULT=F
        fi
    done
    if [ -e "fakehome.expected" ]; then
        FILE_TO_COMPARE="fakehome.expected"
    else
        FILE_TO_COMPARE="fakehome"
    fi
    if are_different "fakehome.actual" "$FILE_TO_COMPARE" "fakehome.diff"; then
        RESULT=F
    fi

    if [ "$RESULT" = "F" ]; then
        exit 1
    else
        exit 0
    fi
    )
}

cleanup () {
    if [ -d "$1" ]; then
        (cd "$1" && rm -rf ./*.actual ./*.diff)
    else
        output error "cleanup function was called with a non existent directory"
    fi
}

[ -f "errors.log" ] && rm errors.log
output debug "running tests for '$TESTS_PATH'"
find "$TESTS_PATH" -type f -name "cmd.sh" | while read -r CMD_FILE; do
    TEST_PATH="$(dirname "$CMD_FILE")"
    cleanup "$TEST_PATH"
    run_test "$TEST_PATH"
    if check_results "$TEST_PATH"; then
        printf "."
    else
        printf "F"
        printf "'%s' failed\n" "$TEST_PATH" >> errors.log
    fi
done

printf "\n"
if [ -f "errors.log" ]; then
    output error "Some tests failed\n"
    cat errors.log
    exit 1
else
    output ok "All tests passed\n"
    exit 0
fi
