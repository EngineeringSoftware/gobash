#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the whiptail module.

if [ -n "${WHIPTAIL_TEST_MOD:-}" ]; then return 0; fi
readonly WHIPTAIL_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${WHIPTAIL_TEST_MOD}/whiptail.sh
. ${WHIPTAIL_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_whiptail_doc() {
        whiptail_doc > /dev/null || assert_fail
}
readonly -f test_whiptail_doc

function test_whiptail_msg_box() {
        local -r t="${1}"
        ! whiptail_enabled && $t skip "no whiptail"

        local box
        box=$(WTMsgBox "Text") || assert_fail

        function whiptail() {
                return 0
        }
        $box show || assert_fail
}
readonly -f test_whiptail_msg_box

function test_whiptail_input_box() {
        local -r t="${1}"
        ! whiptail_enabled && $t skip "no whiptail"

        local box
        box=$(WTInputBox "Text") || assert_fail

        function whiptail() {
                echo "Result" >&3
                return 0
        }
        local -r res=$(UIResult)
        $box show "${res}"
        assert_eq "Result" "$($res val)"
}
readonly -f test_whiptail_input_box

function test_whiptail_menu() {
        local -r t="${1}"
        ! whiptail_enabled && $t skip "no whiptail"

        local -r lst=$(List)
        $lst add "option one"
        $lst add "option two"
        $lst add "option three"

        local box
        box=$(WTMenu "Text" "${lst}") || assert_fail

        function whiptail() {
                echo "2." >&3
                return 0
        }
        local -r res=$(UIResult)
        $box show "${res}"
        assert_eq "option three" "$($res val)"
}
readonly -f test_whiptail_menu

function test_whiptail_checklist() {
        local -r t="${1}"
        ! whiptail_enabled && $t skip "no whiptail"

        local -r lst=$(List)
        $lst add "option one"
        $lst add "option two"
        $lst add "option three"

        local box
        box=$(WTChecklist "Text" "${lst}") || \
                assert_fail

        function whiptail() {
                echo "1." "2." >&3
                return 0
        }
        local -r res=$(UIResult)
        $box show "${res}"
        local -r nlst=$($res val)
        assert_eq 2 "$($nlst len)"
        assert_eq "option two" "$($nlst get 0)"
        assert_eq "option three" "$($nlst get 1)"
}
readonly -f test_whiptail_checklist

function test_whiptail_radiolist() {
        local -r t="${1}"
        ! whiptail_enabled && $t skip "no whiptail"

        local -r lst=$(List)
        $lst add "option one"
        $lst add "option two"
        $lst add "option three"

        local box
        box=$(WTRadiolist "Text" "${lst}") || \
                assert_fail

        function whiptail() {
                echo "1." >&3
                return 0
        }
        local -r res=$(UIResult)
        $box show "${res}"
        assert_eq "option two" "$($res val)"
}
readonly -f test_whiptail_radiolist
