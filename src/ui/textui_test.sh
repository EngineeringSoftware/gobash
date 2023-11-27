#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the textui module.

if [ -n "${TEXTUI_TEST:-}" ]; then return 0; fi
readonly TEXTUI_TEST=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${TEXTUI_TEST}/textui.sh
. ${TEXTUI_TEST}/ui.sh
. ${TEXTUI_TEST}/../testing/bunit.sh


# ----------
# Functions.

function test_textui_enabled() {
        textui_enabled
}
readonly -f test_textui_enabled

function test_textui_menu() {
        local lst=$(List "blue" "red" "green" "bright yellow")

        local menu
        menu=$(TextMenu "What is your favorite color?" "${lst}") || \
                assert_fail

        local res=$(UIResult)
        $menu show "${res}" <<< 0 || \
                assert_fail
        assert_eq "blue" "$($res val)"
}
readonly -f test_textui_menu

function test_textui_menu_invalid_value() {
        local lst=$(List "red" "blue")

        local menu
        menu=$(TextMenu "What is your favorite color?" "${lst}") || \
                assert_fail

        local res=$(UIResult)
        $menu show "${res}" <<< 80 && \
                assert_fail
        assert_eq "${NULL}" "$($res val)"
}
readonly -f test_textui_menu_invalid_value

function test_textui_progress() {
        local tp
        tp=$(TextProgress 20) || assert_fail

        $tp start
        $tp inc
        $tp stop
}
readonly -f test_textui_progress

function test_textui_spinner() {
        local ts
        ts=$(TextSpinner) || assert_fail

        $ts start
        sleep 3
        $ts stop
}
readonly -f test_textui_spinner
