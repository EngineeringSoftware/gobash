#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the set module.

if [ -n "${SET_TEST_MOD:-}" ]; then return 0; fi
readonly SET_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${SET_TEST_MOD}/set.sh
. ${SET_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_set() {
        local s
        s=$(Set) || \
                assert_fail
}
readonly -f test_set

function test_set_len() {
        local s
        s=$(Set) || \
                assert_fail

        local len
        len=$($s len) || \
                assert_fail
        assert_eq 0 "${len}" "Len not 0."

        $s add 5
        $s add 10
        len=$($s len) || \
                assert_fail
        assert_eq 2 "${len}" "Len not 2."

        $s add 5
        len=$($s len) || \
                assert_fail
        assert_eq 2 "${len}" "Len not 2."
}
readonly -f test_set_len

function test_set_contains() {
        local s
        s=$(Set) || \
                assert_fail

        $s add 5 || \
                assert_fail
        $s add 10 || \
                assert_fail

        $s contains 5 || \
                assert_fail

        local ec=0
        $s contains 11 || ec=$?
        assert_false ${ec}
}
readonly -f test_set_contains

function test_set_clear() {
        local s
        s=$(Set) || \
                assert_fail

        $s add 5 || \
                assert_fail
        $s add 10 || \
                assert_fail

        local len
        len=$($s len) || \
                assert_fail
        assert_eq 2 "${len}"

        $s clear
        len=$($s len) || \
                assert_fail
        assert_eq 0 "${len}"
}
readonly -f test_set_clear
