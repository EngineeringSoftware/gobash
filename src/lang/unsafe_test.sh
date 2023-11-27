#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the unsafe module.

if [ -n "${UNSAFE_TEST_MOD:-}" ]; then return 0; fi
readonly UNSAFE_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${UNSAFE_TEST_MOD}/assert.sh
. ${UNSAFE_TEST_MOD}/make.sh
. ${UNSAFE_TEST_MOD}/unsafe.sh
. ${UNSAFE_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_unsafe_flds() {
        function Person() {
                make_ "${FUNCNAME}" \
                      "name" "${1}" \
                      "age" "${2}"
        }

        local -r o=$(Person "Jessy" "18")
        assert_eq 4 $(unsafe_flds "${o}" | $X_WC -l)
}
readonly -f test_unsafe_flds

function test_unsafe_keys() {
        local map
        local lst
        local len

        map=$(unsafe_object_make "Map")
        unsafe_set_fld "${map}" "a" 3
        unsafe_set_fld "${map}" "b" 33

        lst=$(unsafe_keys "${map}") || \
                assert_fail
        len=$(unsafe_len "${lst}") || \
                assert_fail
        assert_eq 2 "${len}"
}
readonly -f test_unsafe_keys

function test_unsafe_object_make() {
        local uid
        uid=$(unsafe_object_make "AnyName") || \
                assert_fail

        local objf
        objf=$(_unsafe_object_file "${uid}") || \
                assert_fail

        [ -f "${objf}" ]
}
readonly -f test_unsafe_object_make

function test_unsafe_copy() {
        function Person() {
                make_ "${FUNCNAME}" \
                      "name" "${1}" \
                      "age" "${2}"
        }

        function Circle() {
                make_ "${FUNCNAME}" \
                      "r" "${1}"
        }

        local p
        p=$(Person "Jessy" 10) || \
                assert_fail
        local c
        c=$(Circle 20) || \
                assert_fail

        assert_eq "Jessy" "$($p name)"
        assert_eq 10 "$($p age)"

        unsafe_copy "${p}" "${c}" || \
                assert_fail
        assert_eq 20 "$($p r)"
}
readonly -f test_unsafe_copy

function test_unsafe_object_uid() {
        function Person() {
                make_ "${FUNCNAME}" \
                      "name" "${1}" \
                      "age" "${2}"
        }

        local p
        p=$(Person "Jessy" 60) || \
                assert_fail
        local uid
        uid=$(_unsafe_object_uid "${p}") || \
                assert_fail

        [[ "${uid}" = "Person"* ]] || \
                assert_fail "Incorrect prefix for object uid."
}
readonly -f test_unsafe_object_uid

function test_unsafe_clone() {
        function Person() {
                make_ "${FUNCNAME}" \
                      "name" "${1}" \
                      "age" "${2}"
        }

        local p
        p=$(Person "Jessy" 20) || \
                assert_fail
        local c=$(unsafe_clone "${p}") || \
                assert_fail

        assert_eq "Jessy" "$($c name)"
        assert_eq 20 "$($c age)"

        assert_ne "$($c)" "$($p)"
}
readonly -f test_unsafe_clone

function test_unsafe_zero() {
        local v

        v=$(unsafe_zero "${INT}") || \
                assert_fail
        assert_eq 0 "${v}"

        v=$(unsafe_zero "${BOOL}") || \
                assert_fail
        assert_nz "${v}"

        v=$(unsafe_zero "${FLOAT}") || \
                assert_fail
        assert_eq 0.0 "${v}"

        v=$(unsafe_zero "${STRING}") || \
                assert_fail
        assert_eq "" "${v}"

        unsafe_zero "WHAT" && \
                assert_fail

        return 0
}
readonly -f test_unsafe_zero

function test_unsafe_set_get_has() {
        local val

        local obj=$(unsafe_object_make "AnyName")
        unsafe_set_fld "${obj}" "a" 30 || \
                assert_fail
        unsafe_set_fld "${obj}" "b" "some string \"that has strings\"" || \
                assert_fail

        unsafe_has_fld "${obj}" "a" || \
                assert_fail

        unsafe_has_fld "${obj}" "b" || \
                assert_fail

        unsafe_has_fld "${obj}" "c" && \
                assert_fail

        val=$(unsafe_get_fld "${obj}" "a") || \
                assert_fail
        assert_eq 30 "${val}"

        val=$(unsafe_get_fld "${obj}" "b") || \
                assert_fail
        assert_eq "some string \"that has strings\"" "${val}"

        local uid=$(_unsafe_object_uid "${obj}")

        unsafe_has_fld "${uid}" "a" || \
                assert_fail

        unsafe_has_fld "${uid}" "b" || \
                assert_fail

        unsafe_has_fld "${uid}" "c" && \
                assert_fail

        unsafe_get_fld "${uid}" "a" || \
                assert_fail

        unsafe_get_fld "${uid}" "b" || \
                assert_fail

        local ec=0
        val=$(unsafe_get_fld "${uid}" "c") || ec=$?
        assert_false ${ec}
        assert_eq "${NULL}" "${val}"
}
readonly -f test_unsafe_set_get_has

function test_unsafe_len() {
        local obj=$(unsafe_object_make "AnyName")
        unsafe_set_fld "${obj}" "a" 30 || \
                assert_fail
        unsafe_set_fld "${obj}" "b" "some string" || \
                assert_fail

        local len
        len=$(unsafe_len "${obj}") || \
                assert_fail
        assert_eq 2 "${len}"
}
readonly -f test_unsafe_len
