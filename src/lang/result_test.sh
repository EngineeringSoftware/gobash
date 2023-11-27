#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the result module.

if [ -n "${RESULT_TEST_MOD:-}" ]; then return 0; fi
readonly RESULT_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${RESULT_TEST_MOD}/assert.sh
. ${RESULT_TEST_MOD}/result.sh
. ${RESULT_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function z_test_result() {
        local -r res="${1}"

        # Random values to simulate setting error and value.
        $res val 55
        return $EC
}

function test_result() {
        local -r res=$(Result)

        z_test_result "${res}" && \
                assert_fail

        $res has_value || \
                assert_fail
}
readonly -f test_result

function test_result_to_string() {
        local -r res=$(Result)

        $res to_string | grep '"val": null' > /dev/null || \
                assert_fail

        $res val 55
        $res to_string | grep '55' > /dev/null || \
                assert_fail
}
readonly -f test_result_to_string
