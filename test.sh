. ./src/utils/output.sh
. ./src/utils/readlink.sh

export DOTTLE_PATH="$(rreadlink "${DOTTLE_PATH:-dottle}")"

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

check_results () {
    (
    cd "$1"
    RESULT=
    for ACTUAL_FILE in $(find . -maxdepth 1 -mindepth 1 -name "*.expected") ; do
        if ! diff --recursive --unified "$ACTUAL_FILE" "${ACTUAL_FILE%.expected}.actual" > "${ACTUAL_FILE%.expected}.diff"; then
            output debug "$ACTUAL_FILE is not correct" | sed 's/^/    /'
            RESULT=F
        fi
    done
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
TESTS_DIR="${1:-tests}"
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
