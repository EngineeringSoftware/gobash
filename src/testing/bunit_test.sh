#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the bunit module.

if [ -n "${BUNIT_TEST_MOD:-}" ]; then return 0; fi
readonly BUNIT_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${BUNIT_TEST_MOD}/bunit.sh
. ${BUNIT_TEST_MOD}/../util/os.sh


# ----------
# Functions.

function test_bunit_doc() {
        bunit_doc > /dev/null || assert_fail
}
readonly -f test_bunit_doc

function test_bunit_skip() {
        local -r t="${1}"
        $t skip

        assert_fail "Should not be here."
}
readonly -f test_bunit_skip

function test_bunit_skip_with_msg() {
        local -r t="${1}"
        $t skip "We want to ignore this test."

        assert_fail "Should not be here."
}
readonly -f test_bunit_skip_with_msg

function test_bunit_skip_now() {
        local -r t="${1}"
        $t skip_now

        assert_fail "Sould not be here."
}
readonly -f test_bunit_skip_now

# Not inside function due to the way we start test in subprocesses.
function z_test_nested_pass() {
        :
}

# Not inside function due to the way we start test in subprocesses.
function z_test_nested_skip() {
        local -r t="${1}"
        $t skip "I want to skip this test."

        assert_fail "Should not be here."
}

# Not inside function due to the way we start test in subprocesses.
function z_test_nested_fail_return() {
        return 1
}

# Not inside function due to the way we start test in subprocesses.
function z_test_nested_fail_now() {
        local -r t="${1}"

        $t fail_now
}

function test_bunit_main() {
        local res
        local failed

        res=$(BUnitResult)
        ( BUNIT_TEST_LINE_RE="^function z_test_nested_pass"
          _bunit_main "${res}" --paths "${BUNIT_TEST_MOD}/bunit_test.sh" ) > /dev/null || \
                assert_fail
        assert_eq 1 "$($res total)"
        failed=$($res failed)
        assert_eq 0 "$($failed len)"

        res=$(BUnitResult)
        ( BUNIT_TEST_LINE_RE="^function z_test_nested_fail_return"
          _bunit_main "${res}" --paths "${BUNIT_TEST_MOD}/bunit_test.sh" ) > /dev/null && \
                assert_fail
        assert_eq 1 "$($res total)"
        failed=$($res failed)
        assert_eq 1 "$($failed len)"

        res=$(BUnitResult)
        ( BUNIT_TEST_LINE_RE="^function z_test_nested_fail_now"
          _bunit_main "${res}" --paths "${BUNIT_TEST_MOD}/bunit_test.sh" ) > /dev/null && \
                assert_fail
        assert_eq 1 "$($res total)"
        failed=$($res failed)
        assert_eq 1 "$($failed len)"

        res=$(BUnitResult)
        ( BUNIT_TEST_LINE_RE="^function z_test_nested_skip"
          _bunit_main "${res}" --paths "${BUNIT_TEST_MOD}/bunit_test.sh" ) > /dev/null || \
                assert_fail
        assert_eq 1 "$($res total)"
        failed=$($res failed)
        assert_eq 0 "$($failed len)"
}
readonly -f test_bunit_main

# Not inside function due to the way we start test in subprocesses.
function z_test_x_one() {
        :
}

# Not inside function due to the way we start test in subprocesses.
function z_test_x_two() {
        :
}

function test_bunit_junitxml() {
        local res=$(BUnitResult)
        local tmpf=$(os_mktemp_file)
        ( BUNIT_TEST_LINE_RE="^function z_test_x"
          _bunit_main "${res}" \
                      --paths "${BUNIT_TEST_MOD}/bunit_test.sh" \
                      --junitxml "${tmpf}" ) \
                > /dev/null || \
                assert_fail

        local -r os=$(os_name)
        if [ "${os}" = "${OS_MAC}" ]; then
                $X_SED -i '' 's/timestamp=".*"/timestamp=""/g' "${tmpf}" || \
                        assert_fail
                $X_SED -i '' 's/time=".*"/time=""/g' "${tmpf}" || \
                        assert_fail
                $X_SED -i '' 's/hostname=".*"/hostname="HOST"/g' "${tmpf}" || \
                        assert_fail
                $X_SED -i '' 's/classname=".*"/classname="bunit_test.sh"/g' "${tmpf}" || \
                        assert_fail
        else
                $X_SED -i 's/timestamp=".*"/timestamp=""/g' "${tmpf}" || \
                        assert_fail
                $X_SED -i 's/time=".*"/time=""/g' "${tmpf}" || \
                        assert_fail
                $X_SED -i 's/hostname=".*"/hostname="HOST"/g' "${tmpf}" || \
                        assert_fail
                $X_SED -i 's/classname=".*"/classname="bunit_test.sh"/g' "${tmpf}" || \
                        assert_fail
        fi

        diff "${tmpf}" "${BUNIT_TEST_MOD}/testdata/${FUNCNAME}.xml" || \
                assert_fail
}
readonly -f test_bunit_junitxml

function z_test_timeout() {
        $X_SLEEP 100
}

function test_bunit_timeout() {
        local res=$(BUnitResult)

        ( BUNIT_TEST_LINE_RE="^function z_test_timeout"
          _bunit_main "${res}" \
                      --paths "${BUNIT_TEST_MOD}/bunit_test.sh" \
                      --max-secs 2 ) > /dev/null && \
                assert_fail
        assert_eq 1 "$($res total)"
        assert_lt "$($res duration)" 5000
}
readonly -f test_bunit_timeout
