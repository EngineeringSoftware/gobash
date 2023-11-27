#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the log module.

if [ -n "${LOG_TEST_MOD:-}" ]; then return 0; fi
readonly LOG_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${LOG_TEST_MOD}/assert.sh
. ${LOG_TEST_MOD}/log.sh
. ${LOG_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_log_i() {
        rm -f "${_LOG_FILE}"
        log_i || \
                assert_fail
        log_i "Text" || \
                assert_fail

        grep 'Text' "${_LOG_FILE}" > /dev/null || \
                assert_fail

        local n
        n=$(cat "${_LOG_FILE}" | grep 'INFO::' | $X_WC -l | $X_SED 's/^[[:space:]]*//') || \
                assert_fail
        assert_eq 2 "${n}"
}
readonly -f test_log_i

function test_log_w() {
        rm -f "${_LOG_FILE}"
        log_w || \
                assert_fail
        log_w "Text" || \
                assert_fail

        grep 'Text' "${_LOG_FILE}" > /dev/null || \
                assert_fail

        local n
        n=$(cat "${_LOG_FILE}" | grep 'WARN::' | $X_WC -l | $X_SED 's/^[[:space:]]*//') || \
                assert_fail
        assert_eq 2 "${n}"
}
readonly -f test_log_w

function test_log_e() {
        rm -f "${_LOG_FILE}"
        log_e || \
                assert_fail
        log_e "Text" || \
                assert_fail

        grep 'Text' "${_LOG_FILE}" > /dev/null || \
                assert_fail

        local n
        n=$(cat "${_LOG_FILE}" | grep 'ERROR::' | $X_WC -l | $X_SED 's/^[[:space:]]*//') || \
                assert_fail
        assert_eq 2 "${n}"
}
readonly -f test_log_e
