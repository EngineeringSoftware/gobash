#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the int module.

if [ -n "${INT_TEST_MOD:-}" ]; then return 0; fi
readonly INT_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${INT_TEST_MOD}/assert.sh
. ${INT_TEST_MOD}/bool.sh
. ${INT_TEST_MOD}/int.sh
. ${INT_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_int() {
        local z
        z=$(Int) || \
                assert_fail
        assert_eq 0 "$($z val)"

        local i=$(Int 33)
        assert_eq 33 "$($i val)"
}
readonly -f test_int

function test_int_inc() {
        local i=$(Int 33)
        $i inc
        assert_eq 34 "$($i val)"
}
readonly -f test_int_inc

function test_int_dec() {
        local i=$(Int 33)
        $i dec
        assert_eq 32 "$($i val)"
}
readonly -f test_int_dec

function test_int_gt() {
        local i=$(Int 33)

        $i gt 32 || assert_fail
        $i gt 45 && assert_fail

        local i2=$(Int 34)
        $i gt "${i2}" && assert_fail

        local i3=$(Int 32)
        $i gt "${i3}" || assert_fail
}
readonly -f test_int_gt

function test_int_ge() {
        local i=$(Int 33)

        $i ge 33 || assert_fail
        $i ge 32 || assert_fail
        $i ge 44 && assert_fail

        return 0
}
readonly -f test_int_ge

function test_int_eq() {
        local i=$(Int 33)

        $i eq 33 || assert_fail
        $i eq 34 && assert_fail
        $i eq 32 && assert_fail

        return 0
}
readonly -f test_int_eq

function test_int_lt() {
        local i=$(Int 33)

        $i lt 45 || assert_fail
        $i lt 33 && assert_fail
        $i lt 20 && assert_fail

        return 0
}
readonly -f test_int_lt

function test_int_le() {
        local i=$(Int 33)

        $i le 45 || assert_fail
        $i le 33 || assert_fail
        $i le 20 && assert_fail

        return 0
}
readonly -f test_int_le
