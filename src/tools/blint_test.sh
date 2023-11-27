#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the blint module.

if [ -n "${BLINT_TEST_MOD:-}" ]; then return 0; fi
readonly BLINT_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${BLINT_TEST_MOD}/blint.sh
. ${BLINT_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function _blint_testfile() {
        echo "${BLINT_TEST_MOD}/testdata/${1}"
}

function test_blint_check_she_bang() {
        local -r res=$(BLintResult)
        _blint_check_she_bang "${res}" $(_blint_testfile "blint_she_bang")

        $res has_failing || \
                assert_fail

        assert_eq 1 "$($res nfailing)"
}
readonly -f test_blint_check_she_bang

function test_blint_check_tabs() {
        local -r res=$(BLintResult)
        _blint_check_tabs "${res}" $(_blint_testfile "blint_tabs")

        $res has_failing || \
                assert_fail

        assert_eq 1 "$($res nfailing)"
}
readonly -f test_blint_check_tabs

function test_blint_check_signature() {
        local -r res=$(BLintResult)
        _blint_check_signature "${res}" $(_blint_testfile "blint_signature")

        $res has_failing || \
                assert_fail

        assert_eq 2 "$($res nfailing)"
}
readonly -f test_blint_check_signature

function test_blint_check_brief_doc() {
        local -r res=$(BLintResult)
        _blint_check_brief_doc "${res}" $(_blint_testfile "blint_brief_doc")

        $res has_failing || \
                assert_fail

        assert_eq 1 "$($res nfailing)"
}
readonly -f test_blint_check_brief_doc

function test_blint_check_readonly_tests() {
        local -r res=$(BLintResult)
        _blint_check_readonly_tests "${res}" $(_blint_testfile "blint_readonly_tests")

        $res has_failing || \
                assert_fail

        assert_eq 1 "$($res nfailing)"
}
readonly -f test_blint_check_readonly_tests
