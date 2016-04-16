#!/bin/sh

. ./src/utils/output.sh
. ./src/utils/readlink.sh

export DOTTLE_PATH="$(rreadlink "${DOTTLE_PATH:-dottle}")"
export DEFAULTS_PATH="$(rreadlink "${DEFAULTS_PATH:-tests/defaults}")"
export TESTS_DIR="${1:-tests/cases}"

run_test () {
    if [ -z "$1" ]; then
        return 1
    fi
    ( cd "$1"
    TEST_BASEDIR="$(pwd)"

    rm -rf fakehome.actual
    if [ -d "fakehome" ]; then
        cp -R fakehome fakehome.actual
    else
        mkdir fakehome.actual
    fi

        (
        cd fakehome.actual
        FAKEHOME="$TEST_BASEDIR/fakehome.actual"
        HOME="$FAKEHOME" "$TEST_BASEDIR/cmd.sh" \
            > "$TEST_BASEDIR/stdout.actual" \
            2> "$TEST_BASEDIR/stderr.actual"
        printf "%d\n" "$?" > "$TEST_BASEDIR/exit.actual"
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
output debug "running tests for '$TESTS_DIR'"
find "$TESTS_DIR" -type f -name "cmd.sh" | while read -r CMD_FILE; do
    TEST_DIR="$(dirname "$CMD_FILE")"
    cleanup "$TEST_DIR"
    run_test "$TEST_DIR"
    if check_results "$TEST_DIR"; then
        printf "."
    else
        printf "F"
        printf "'%s' failed\n" "$TEST_DIR" >> errors.log
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
