#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the atomic_int module.

if [ -n "${ATOMIC_INT_TEST_MOD:-}" ]; then return 0; fi
readonly ATOMIC_INT_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${ATOMIC_INT_TEST_MOD}/atomic_int.sh
. ${ATOMIC_INT_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_atomic_int_inc() {
        local ai
        ai=$(AtomicInt 0) || \
                assert_fail

        ( $ai inc > /dev/null ) &
        ( $ai inc > /dev/null ) &
        ( $ai inc > /dev/null ) &
        wait || \
                assert_fail
        assert_eq 3 "$($ai val)"
}
readonly -f test_atomic_int_inc

function test_atomic_int_add() {
        local -r ai=$(AtomicInt 5)
        local res
        res=$($ai add 10) || \
                assert_fail
        assert_eq 15 "${res}"

        ( $ai add 3 > /dev/null ) &
        ( $ai add 2 > /dev/null ) &
        ( $ai add 1 > /dev/null ) &
        wait || \
                assert_fail
        assert_eq 21 "$($ai val)"
}
readonly -f test_atomic_int_add

function test_atomic_int_compare_and_swap() {
        local -r ai=$(AtomicInt 10)

        $ai compare_and_swap 9 20 && \
                assert_fail
        assert_eq 10 "$($ai val)"

        $ai compare_and_swap 10 20 || \
                assert_fail
        assert_eq 20 "$($ai val)"
}
readonly -f test_atomic_int_compare_and_swap

function test_atomic_int_load() {
        local ai
        ai=$(AtomicInt 10) || \
                assert_fail

        local res
        res=$($ai load) || \
                assert_fail
        assert_eq 10 "$($ai val)"
}
readonly -f test_atomic_int_load

function test_atomic_int_store() {
        local ai
        ai=$(AtomicInt 100) || \
                assert_fail

        $ai store 99 || \
                assert_fail
        assert_eq 99 "$($ai val)"
}
readonly -f test_atomic_int_store

function test_atomic_int_swap() {
        local ai
        ai=$(AtomicInt 10) || \
                assert_fail

        local res
        res=$($ai swap 8) || \
                assert_fail
        assert_eq 10 "${res}"
        assert_eq 8 "$($ai val)"
}
readonly -f test_atomic_int_swap
