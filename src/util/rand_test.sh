#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the rand module.

if [ -n "${RAND_TEST_MOD:-}" ]; then return 0; fi
readonly RAND_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${RAND_TEST_MOD}/rand.sh
. ${RAND_TEST_MOD}/strings.sh
. ${RAND_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_rand_bool() {
        local val
        val=$(rand_bool) || \
                assert_fail

        is_bool "${val}" || \
                assert_fail
}
readonly -f test_rand_bool

function test_rand_int() {
        local val
        val=$(rand_int) || \
                assert_fail

        is_int "${val}" || \
                assert_fail
}
readonly -f test_rand_int

function test_rand_intn() {
        local val
        val=$(rand_intn 10) || \
                assert_fail
        assert_bw "${val}" 0 9
}
readonly -f test_rand_intn

function test_rand_string() {
        local val
        local ctx

        val=$(rand_string) || \
                assert_fail
        assert_eq 32 $(strings_len "${val}")

        val=$(rand_string 6) || \
                assert_fail
        assert_eq 6 $(strings_len "${val}")

        ctx=$(ctx_make)
        rand_string $ctx -1 && \
                assert_fail
        ctx_show $ctx | grep 'len' || \
                assert_fail

        ctx=$(ctx_make)
        rand_string $ctx 33 && \
                assert_fail
        ctx_show $ctx | grep 'len' || \
                assert_fail

        val=$(rand_string 32) || \
                assert_fail
        assert_eq 32 $(strings_len "${val}")
}
readonly -f test_rand_string
