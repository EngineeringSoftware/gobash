#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the binary functions.

if [ -n "${BINARY_TEST_MOD:-}" ]; then return 0; fi
readonly BINARY_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${BINARY_TEST_MOD}/binary.sh
. ${BINARY_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_binary_d2b() {
        local res

        res=$(binary_d2b "3")
        [ "${res}" = "11" ] || \
                assert_fail

        res=$(binary_d2b "33")
        [ "${res}" = "100001" ] || \
                assert_fail

        return 0
}
readonly -f test_binary_d2b

function test_binary_b2d() {
        local res

        res=$(binary_b2d "011")
        [ "${res}" = "3" ] || \
                assert_fail

        res=$(binary_b2d "100001")
        [ "${res}" = "33" ] || \
                assert_fail

        #binary_b2d "100001a" && \
                #assert_fail

        return 0
}
readonly -f test_binary_b2d
