#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the complex module.

if [ -n "${COMPLEX_TEST_MOD:-}" ]; then return 0; fi
readonly COMPLEX_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${COMPLEX_TEST_MOD}/complex.sh
. ${COMPLEX_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_complex() {
        local -r c=$(Complex 10 11)
        assert_eq "$($c to_string)" "( 10 + 11i )"
}
readonly -f test_complex

function test_complex_plus() {
        local c1
        c1=$(Complex 2 3) || \
                assert_fail

        local c2
        c2=$(Complex 4 5) || \
                assert_fail

        local res
        res=$($c1 plus "${c2}") || \
                assert_fail

        assert_eq 6 "$($res real)"
        assert_eq 8 "$($res imag)"
}
readonly -f test_complex_plus

function test_complex_minus() {
        local -r c1=$(Complex 2 3)
        local -r c2=$(Complex 4 5)

        local res
        res=$($c1 minus "${c2}") || \
                assert_fail

        assert_eq -2 "$($res real)"
        assert_eq -2 "$($res imag)"
}
readonly -f test_complex_minus

function test_complex_times() {
        local -r c1=$(Complex 2 3)
        local -r c2=$(Complex 4 5)

        local res
        res=$($c1 times "${c2}") || \
                assert_fail

        assert_eq -7 "$($res real)"
        assert_eq 23 "$($res imag)"
}
readonly -f test_complex_times

function test_complex_scale() {
        local -r c=$(Complex 10 11)

        local res
        res=$($c scale 2.2) || \
                assert_fail

        assert_eq 22.0 "$($res real)"
        assert_eq 24.2 "$($res imag)"
}
readonly -f test_complex_scale

function test_complex_conjugate() {
        local -r c=$(Complex 10 11)

        local res
        res=$($c conjugate) || \
                assert_fail

        assert_eq "$($res real)" "10"
        assert_eq "$($res imag)" "-11"
}
readonly -f test_complex_conjugate

function test_complex_eq() {
        local -r c1=$(Complex 2 3)
        local -r c2=$(Complex 4 5)
        local -r c3=$(Complex 4 5)

        local ctx

        ctx=$(ctx_make)
        $c1 $ctx eq && \
                assert_fail
        ctx_show $ctx | grep 'incorrect number of arguments' || \
                assert_fail

        $c1 eq "" && \
                assert_fail

        $c1 eq "$c2" && \
                assert_fail

        $c2 eq "$c3" || \
                assert_fail
}
readonly -f test_complex_eq
