#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the bool module.
#
# Tests intentionally do not use assert functions to check the output.

if [ -n "${BOOL_TEST_MOD:-}" ]; then return 0; fi
readonly BOOL_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${BOOL_TEST_MOD}/bool.sh
. ${BOOL_TEST_MOD}/os.sh
. ${BOOL_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_is_true() {
        is_true $TRUE || \
                return $EC

        is_true "true" || \
                return $EC

        local ec=0
        is_true "xxx" || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        return 0
}
readonly -f test_is_true

function test_is_false() {
        is_false $FALSE || \
                return $EC

        is_false "false" || \
                return $EC

        local ec=0
        is_false "xxx" || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        return 0
}
readonly -f test_is_false

function test_is_exe() {
        is_exe "bash" || \
                return $EC

        local ec=0
        is_exe "thisbashdoesnotexist" || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        return 0
}
readonly -f test_is_exe

function test_is_empty() {
        is_empty "" || \
                return $EC

        local ec

        ec=0
        is_empty "a" || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        ec=0
        is_empty "abc and more" || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        return 0
}
readonly -f test_is_empty

function test_is_function_true() {
        is_function "${FUNCNAME}" || \
                return $EC
}
readonly -f test_is_function_true

function test_is_function_false() {
        local ec

        ec=0
        is_function "something_that_is_not_a_function" || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        return 0
}
readonly -f test_is_function_false

function test_is_eq() {
        local ec

        ec=0
        is_eq "one" "two" || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        is_eq "one" "one" || \
                return $EC
}
readonly -f test_is_eq

function test_is_ne() {
        is_ne "one" "two" || \
                return $EC

        local ec

        ec=0
        is_ne "one" "one" || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        return 0
}
readonly -f test_is_ne

function test_is_set() {
        local ec

        ec=0
        is_set "" || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        is_set "abc" || \
                return $EC

        ec=0
        is_set "${NULL}" || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        return 0
}
readonly -f test_is_set

function test_is_null() {
        is_null "${NULL}" || \
                return $EC
}
readonly -f test_is_null

function test_is_int() {
        is_int 10 || \
                return $EC

        local ec

        ec=0
        is_int abc || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        ec=0
        is_int 10.2 || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        ec=0
        is_int 0008 || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        return 0
}
readonly -f test_is_int

function test_is_uint() {
        is_uint 10 || \
                return $EC

        is_uint abc && \
                return $EC

        is_uint 10.2 && \
                return $EC

        is_uint -10 && \
                return $EC

        return 0
}

function test_is_float() {
        is_float 1.2 || \
                return $EC

        local ec

        ec=0
        is_float 25. || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        ec=0
        is_float 25.5.5 || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        return 0
}
readonly -f test_is_float

function test_is_bool() {
        is_bool 0 || \
                return $EC

        is_bool 1 || \
                return $EC

        is_bool "true" || \
                return $EC

        is_bool "false" || \
                return $EC

        local ec

        ec=0
        is_bool "abc" || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        ec=0
        is_bool 333 || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        return 0
}
readonly -f test_is_bool

function test_is_string() {
        is_string "abc" || \
                return $EC

        is_string "" || \
                return $EC

        is_string 23 || \
                return $EC

        local ec

        ec=0
        is_string || ec=$?
        [ ${ec} -ne $EC ] && \
                return $EC

        return 0
}
readonly -f test_is_string

function test_is_file() {
        local -r tmpf=$(os_mktemp_file)
        is_file "${tmpf}" || \
                return $EC
}
readonly -f test_is_file

function test_is_gt() {
        is_gt 5 3 || \
                return $EC

        local ec

        ec=0
        is_gt 3 5 || ec=$?
        [ ${ec} -ne $FALSE ] && \
                return $EC

        return 0
}
readonly -f test_is_gt
