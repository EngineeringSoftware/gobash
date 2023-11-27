#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the json module.

if [ -n "${JQMEM_TEST_MOD:-}" ]; then return 0; fi
readonly JQMEM_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${JQMEM_TEST_MOD}/assert.sh
. ${JQMEM_TEST_MOD}/jqmem.sh
. ${JQMEM_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_json_set_empty() {
        local -r f=$(os_mktemp_file)
        echo "{}" > "${f}"

        json_set "${f}" "a" "" || \
                assert_fail
        grep '"a": ""' "${f}" > /dev/null || \
                assert_fail
}
readonly -f test_json_set_empty

function test_json_set_null() {
        local -r f=$(os_mktemp_file)
        echo "{}" > "${f}"

        json_set "${f}" "a" "null" || \
                assert_fail
        grep '"a": null' "${f}" > /dev/null || \
                assert_fail
}
readonly -f test_json_set_null

function test_json_get_null() {
        local -r f=$(os_mktemp_file)
        echo "{ \"x\": null }" > "${f}" || \
                assert_fail

        local val
        val=$(json_get "${f}" "x") || \
                assert_fail
        assert_eq "null" "${val}"
}
readonly -f test_json_get_null

function test_json_set_true() {
        local -r f=$(os_mktemp_file)
        echo "{}" > "${f}"

        json_set "${f}" "x" "true" || \
                assert_fail
        grep '"x": true' "${f}" > /dev/null || \
                assert_fail
}
readonly -f test_json_set_true

function test_json_set_false() {
        local -r f=$(os_mktemp_file)
        echo "{}" > "${f}"

        json_set "${f}" "x" "false" || \
                assert_fail

        grep '"x": false' "${f}" > /dev/null || \
                assert_fail
}
readonly -f test_json_set_false

function test_json_set_get() {
        local f=$(os_mktemp_file)
        echo "{}" > "${f}"

        json_set "${f}" "a" 5 || \
                assert_fail
        json_set "${f}" "b" 7 || \
                assert_fail

        local actual

        actual=$(json_get "${f}" "a") || \
                assert_fail
        assert_eq 5 "${actual}"
}
readonly -f test_json_set_get

function test_json_set_string() {
        local f=$(os_mktemp_file)
        echo "{}" > "${f}"

        json_set "${f}" "a" "abc" || \
                assert_fail

        grep '"a": "abc"' "${f}" > /dev/null || \
                assert_fail
}
readonly -f test_json_set_string

function test_json_set_no_file() {
        json_set && \
                assert_fail

        return 0
}
readonly -f test_json_set_no_file

function test_json_set_no_fld() {
        local f=$(os_mktemp_file)
        json_set "${f}" && \
                assert_fail

        return 0
}
readonly -f test_json_set_no_fld

function test_json_get_no_file() {
        json_get && \
                assert_fail

        return 0
}
readonly -f test_json_get_no_file

function test_json_get_non_existant_fld() {
        local f=$(os_mktemp_file)
        echo "{}" > "${f}"
        local actual
        actual=$(json_get "${f}" "a") || \
                assert_fail
        assert_eq "null" "${actual}"
}
readonly -f test_json_get_non_existant_fld

function test_json_has_no() {
        local f=$(os_mktemp_file)
        echo "{}" > "${f}"
        json_has "${f}" "a" && \
                assert_fail

        return 0
}
readonly -f test_json_has_no

function test_json_has_yes() {
        local f=$(os_mktemp_file)
        cat << END > "${f}"
{
    "x": 5
}
END
        json_has "${f}" "x" || \
                assert_fail
}
readonly -f test_json_has_yes

function test_json_set_array() {
        local f=$(os_mktemp_file)
        echo "{}" > "${f}"
        json_set "${f}" "elems" "[]" || \
                assert_fail
        grep '"elems": \[\]' "${f}" > /dev/null || \
                assert_fail
}
readonly -f test_json_set_array

function test_json_set_dict() {
        local f=$(os_mktemp_file)
        echo "{}" > "${f}"
        json_set "${f}" "elems" "{}" || \
                assert_fail
        grep '"elems": {}' "${f}" > /dev/null || \
                assert_fail
}
readonly -f test_json_set_dict
