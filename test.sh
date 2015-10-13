. ./dottle

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
        printf "$?\n" > "$TEST_BASEDIR/exit.actual"
        )
    )
}

check_results () {
    (
    cd "$1"
    RESULT=
    for ACTUAL_FILE in $(find . -maxdepth 1 -mindepth 1 -name "*.expected" -type f) ; do
        if ! diff "$ACTUAL_FILE" "${ACTUAL_FILE%.expected}.actual"; then
            output error "$ACTUAL_FILE is not correct"
            RESULT=F
        fi
    done
    if ! diff --no-dereference --recursive fakehome.expected fakehome.actual; then
        RESULT=F
    fi
    if [ "$RESULT" = "F" ]; then
        exit 0
    else
        exit 1
    fi
    )
}

cleanup () {
    if [ -d "$1" ];then
        (cd "$1" && rm -rf *.actual)
    fi
}

TESTS_DIR="${1:-tests}"
RESULT=
for CMD_FILE in $(find "$TESTS_DIR" -type f -name "cmd.sh"); do
    TEST_DIR="$(dirname "$CMD_FILE")"
    output debug "running $TEST_DIR "
    cleanup "$TEST_DIR"
    run_test "$TEST_DIR"
    if ! check_results "$TEST_DIR"; then
        output ok "'$TEST_DIR' passed"
    else
        output error "'$TEST_DIR' failed"
        RESULT="F"
    fi
done
if [ "$RESULT" = "F" ]; then
    exit 1
else
    exit 0
fi
