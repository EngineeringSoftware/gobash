#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the list module.

if [ -n "${CONTAINER_LIST_TEST_MOD:-}" ]; then return 0; fi
readonly CONTAINER_LIST_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${CONTAINER_LIST_TEST_MOD}/list.sh
. ${CONTAINER_LIST_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_container_list_new() {
        local -r l=$(container_List)

        [ "$($l len)" -eq 0 ] || assert_fail
}
readonly -f test_container_list_new

function test_container_list_push_back() {
        local -r l=$(container_List)

        $l push_back 3
        $l push_back 4
        $l push_back 10

        [ "$($l len)" -eq 3 ] || assert_fail

        local e
        local v

        e=$($l front) || assert_fail
        v=$($e value) || assert_fail
        [ "${v}" = "3" ] || assert_fail

        e=$($l back) || assert_fail
        v=$($e value) || assert_fail
        [ "${v}" = 10 ] || assert_fail
}
readonly -f test_container_list_push_back

function test_container_list_push_front() {
        local l
        l=$(container_List) || assert_fail

        $l push_front 3
        $l push_front 4
        $l push_front 10

        [ "$($l len)" -eq 3 ] || assert_fail

        local e
        local v
 
        e=$($l front) || assert_fail
        v=$($e value) || assert_fail
        [ "${v}" = 10 ] || assert_fail

        e=$($l back) || assert_fail
        v=$($e value) || assert_fail
        [ "${v}" = 3 ] || assert_fail
}
readonly -f test_container_list_push_front
