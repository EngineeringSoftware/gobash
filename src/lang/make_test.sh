#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the make module.

if [ -n "${MAKE_TEST_MOD:-}" ]; then return 0; fi
readonly MAKE_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${MAKE_TEST_MOD}/make.sh
. ${MAKE_TEST_MOD}/assert.sh
. ${MAKE_TEST_MOD}/bool.sh
. ${MAKE_TEST_MOD}/os.sh
. ${MAKE_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function Point() {
        local -r x="${1}"
        local -r y="${2}"
        shift 2 || return $EC

        make_ "${FUNCNAME}" \
              "x" "${x}" \
              "y" "${y}"
}

function Point_move() {
        local -r obj="${1}"
        local -r dx="${2}"
        local -r dy="${3}"
        shift 3 || return $EC

        local x
        x=$($obj x)

        x=$(( ${x} + ${dx} ))
        $obj x ${x}

        local y
        y=$($obj y)

        y=$(( ${y} + ${dy} ))
        $obj y ${y}

        return 0
}

function test_make_with_incorrect_name() {
        make_ "INCORRECT_NAME" && \
                assert_fail

        return 0
}
readonly -f test_make_with_incorrect_name

function test_make() {
        local obj

        obj=$(Point 2 3) || \
                assert_fail
}
readonly -f test_make

function test_make_method_call() {
        local obj

        obj=$(Point 2 3) || \
                assert_fail

        $obj move 1 1 || \
                assert_fail
}
readonly -f test_make_method_call

function test_make_field_get() {
        local obj

        obj=$(Point 2 3) || \
                assert_fail

        assert_eq 2 "$($obj x)"
        assert_eq 3 "$($obj y)"
}
readonly -f test_make_field_get

function test_make_field_set() {
        local obj

        obj=$(Point 2 3) || \
                assert_fail

        $obj x 6 || \
                assert_fail
        assert_eq 6 "$($obj x)"
}
readonly -f test_make_field_set

function test_make_incorrect_num_args() {
        make_ "Point" "x" && \
                assert_fail

        return 0
}
readonly -f test_make_incorrect_num_args

function test_make_access_incorrect_attribute() {
        local obj

        obj=$(Point 2 3) || \
                assert_fail
        $obj z && \
                assert_fail

        return 0
}
readonly -f test_make_access_incorrect_attribute

function test_make_is_instanceof() {
        local obj
        obj=$(Point 2 3) || \
                assert_fail

        is_instanceof "${obj}" Point || \
                assert_fail

        is_instanceof "${obj}" Unknown && \
                assert_fail

        return 0
}
readonly -f test_make_is_instanceof

function test_make_has_fld() {
        local obj
        obj=$(Point 2 3) || \
                assert_fail

        has_fld "${obj}" x || \
                assert_fail

        has_fld "${obj}" y || \
                assert_fail

        has_fld "${obj}" q && \
                assert_fail

        return 0
}
readonly -f test_make_has_fld

function test_make_is_object() {
        local obj

        obj=$(Point 2 3)
        is_object "${obj}" || \
                assert_fail

        is_object "abc" && \
                assert_fail

        is_object "" && \
                assert_fail

        is_object 1 && \
                assert_fail

        return 0
}
readonly -f test_make_is_object

function test_make_to_string() {
        local p
        p=$(Point 2 3) || \
                assert_fail

        local -r tmpf=$(os_mktemp_file)
        $p to_string > "${tmpf}" || \
                assert_fail

        grep '"x": "2"' "${tmpf}" > /dev/null || \
                assert_fail

        grep '"y": "3"' "${tmpf}" > /dev/null || \
                assert_fail
}
readonly -f test_make_to_string

function test_make_to_json() {
        local p
        p=$(Point 2 3) || \
                assert_fail

        local -r tmpf=$(os_mktemp_file)
        $p to_json > "${tmpf}" || \
                assert_fail

        grep '"x": "2"' "${tmpf}" > /dev/null || \
                assert_fail

        grep '"y": "3"' "${tmpf}" > /dev/null || \
                assert_fail
}
readonly -f test_make_to_json

function test_make_fld_order() {
        local obj=$(amake_ "x" 1 "a" 22 "z" 30 "d" 55)

        local uid
        uid=$(_unsafe_object_uid "${obj}") || \
                assert_fail
        local objf
        objf=$(_unsafe_object_file "${uid}") || \
                assert_fail

        $X_SED '2,2!d' "${objf}" | grep '"x": "1"' > /dev/null || \
                assert_fail

        $X_SED '3,3!d' "${objf}" | grep '"a": "22"' > /dev/null || \
                assert_fail

        $X_SED '4,4!d' "${objf}" | grep '"z": "30"' > /dev/null || \
                assert_fail

        $X_SED '5,5!d' "${objf}" | grep '"d": "55"' > /dev/null || \
                assert_fail

        local tmpf=$(os_mktemp_file)
        unsafe_flds "$obj" > "${tmpf}" || \
                assert_fail

        $X_SED '2,2!d' "${tmpf}" | grep '"x"' > /dev/null || \
                assert_fail

        $X_SED '3,3!d' "${tmpf}" | grep '"a"' > /dev/null || \
                assert_fail

        $X_SED '4,4!d' "${tmpf}" | grep '"z"' > /dev/null || \
                assert_fail

        $X_SED '5,5!d' "${tmpf}" | grep '"d"' > /dev/null || \
                assert_fail
}
readonly -f test_make_fld_order

function test_make_ctx() {
        local p=$(Point 3 3)
        # String broken in multiple lines is not accepted.
        local str="something
        here"

        local ctx=$(ctx_make)
        $p $ctx x "${str}"
        ctx_show $ctx | grep 'cannot set fld' >/dev/null || \
                assert_fail
}
readonly -f test_make_ctx
