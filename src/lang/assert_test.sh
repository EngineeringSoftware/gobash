#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the assert module.
#
# This module intentionally does not use assert functions to check the
# outcome of tests.

if [ -n "${ASSERT_TEST_MOD:-}" ]; then return 0; fi
readonly ASSERT_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${ASSERT_TEST_MOD}/assert.sh
. ${ASSERT_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_assert_fail() {
        ( assert_fail "message" ) > /dev/null 2>&1 && \
                return $EC

        ( assert_fail ) > /dev/null 2>&1 && \
                return $EC

        return 0
}
readonly -f test_assert_fail

function test_assert_ze() {
        ( assert_ze ) > /dev/null 2>&1 && \
                return $EC

        ( assert_ze 0 ) || \
                return $EC

        ( assert_ze 1 ) > /dev/null 2>&1 && \
                return $EC

        ( assert_ze 0 "message" ) || \
                return $EC

        return 0
}
readonly -f test_assert_ze

function test_assert_nz() {
        ( assert_nz ) > /dev/null 2>&1 && \
                return $EC

        ( assert_nz 1 ) || \
                return $EC

        ( assert_nz 0 ) > /dev/null 2>&1 && \
                return $EC

        ( assert_nz 1 "message" ) || \
                return $EC

        return 0
}
readonly -f test_assert_nz

function test_assert_eq() {
        ( assert_eq ) > /dev/null 2>&1 && \
                return $EC

        ( assert_eq 1 ) > /dev/null 2>&1 && \
                return $EC

        ( assert_eq 1 1 ) || \
                return $EC

        ( assert_eq 1 2 ) > /dev/null 2>&1 && \
                return $EC

        ( assert_eq "abc" "abc" ) || \
                return $EC

        return 0
}
readonly -f test_assert_eq

function test_assert_ne() {
        ( assert_ne ) > /dev/null 2>&1 && \
                return $EC

        ( assert_ne 1 ) > /dev/null 2>&1 && \
                return $EC

        ( assert_ne 1 2 ) || \
                return $EC

        ( assert_ne 1 1 ) > /dev/null 2>&1 && \
                return $EC

        ( assert_ne "abc" "abc" ) > /dev/null 2>&1 && \
                return $EC

        return 0
}
readonly -f test_assert_ne

function test_assert_gt() {
        ( assert_gt ) > /dev/null 2>&1 && \
                return $EC

        ( assert_gt 1 ) > /dev/null 2>&1 && \
                return $EC

        ( assert_gt 2 1 ) || \
                return $EC

        ( assert_gt 1 2 ) > /dev/null 2>&1 && \
                return $EC

        ( assert_gt 2 1 "message" ) || \
                return $EC

        return 0
}
readonly -f test_assert_gt

function test_assert_ge() {
        ( assert_ge ) > /dev/null 2>&1 && \
                return $EC

        ( assert_ge 1 ) > /dev/null 2>&1 && \
                return $EC

        ( assert_ge 2 2 ) || \
                return $EC

        ( assert_ge 2 2 "message" ) || \
                return $EC

        ( assert_ge 1 2 ) > /dev/null 2>&1 && \
                return $EC

        return 0
}
readonly -f test_assert_ge

function test_assert_lt() {
        ( assert_lt ) > /dev/null 2>&1 && \
                return $EC

        ( assert_lt 1 ) > /dev/null 2>&1 && \
                return $EC

        ( assert_lt 3 1 ) > /dev/null 2>&1 && \
                return $EC

        ( assert_lt 1 3 ) || \
                return $EC

        ( assert_lt 1 3 "message" ) || \
                return $EC

        return 0
}
readonly -f test_assert_lt

function test_assert_bw() {
        ( assert_bw ) > /dev/null 2>&1 && \
                return $EC

        ( assert_bw 1 ) > /dev/null 2>&1 && \
                return $EC

        ( assert_bw 2 1 ) > /dev/null 2>&1 && \
                return $EC

        ( assert_bw 2 1 1 ) > /dev/null 2>&1 && \
                return $EC

        ( assert_bw 2 1 3 ) || \
                return $EC

        return 0
}
readonly -f test_assert_bw

function test_assert_dir_exists() {
        ( assert_dir_exists ) > /dev/null 2>&1 && \
                return $EC

        ( assert_dir_exists "nowaythisisdir" ) > /dev/null 2>&1 && \
                return $EC

        ( assert_dir_exists "$(pwd)" ) || \
                return $EC

        return 0
}
readonly -f test_assert_dir_exists

function test_assert_file_exists() {
        ( assert_file_exists ) > /dev/null 2>&1 && \
                return $EC

        ( assert_file_exists "nowaythisisfile" ) > /dev/null 2>&1 && \
                return $EC

        ( assert_file_exists "${BASH_SOURCE[0]}" ) || \
                return $EC

        return 0
}
readonly -f test_assert_file_exists

function test_assert_exe_exists() {
        ( assert_exe_exists "bash" ) || \
                return $EC

        ( assert_exe_exists "nowaythisisabinary" ) > /dev/null 2>&1 && \
                return $EC

        return 0
}
readonly -f test_assert_exe_exists

function test_assert_port_free() {
        ( assert_port_free "" ) > /dev/null 2>&1 && \
                return $EC

        return 0
}
readonly -f test_assert_port_free

function test_assert_function_exists() {
        ( assert_function_exists ) > /dev/null 2>&1 && \
                return $EC

        ( assert_function_exists "nowaythisisafunction" ) > /dev/null 2>&1 && \
                return $EC

        ( assert_function_exists "${FUNCNAME}" ) || \
                return $EC

        return 0
}
readonly -f test_assert_function_exists

function test_assert_false() {
        ( assert_false ) > /dev/null 2>&1 && \
                return $EC

        ( assert_false 1 ) || \
                return $EC

        ( assert_false 0 ) > /dev/null 2>&1 && \
                return $EC

        ( assert_false "false" ) || \
                return $EC

        return 0
}
readonly -f test_assert_false

function test_assert_ec() {
        ( assert_ec ) > /dev/null 2>&1 && \
                return $EC

        ( assert_ec 0 ) > /dev/null 2>&1 && \
                return $EC

        ( assert_ec $EC ) || \
                return $EC

        return 0
}
readonly -f test_assert_ec
