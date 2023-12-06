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

function test_container_list_remove() {
        local l
        l=$(container_List)

        $l push_back 3
        $l push_back 10
        $l push_back 55

        [ "$($l len)" -eq 3 ] || assert_fail

        local e
        local v

        e=$($l front)
        $l remove "$e" || assert_fail
        [ "$($l len)" -eq 2 ] || assert_fail

        e=$($l front)
        v=$($e value)
        [ "${v}" -eq 10 ] || assert_fail

        e=$($l back)
        $l remove "$e" || assert_fail
        [ "$($l len)" -eq 1 ] || assert_fail

        e=$($l front)
        v=$($e value)
        [ "${v}" -eq 10 ] || assert_fail

        e=$($l front)
        $l remove "$e" || assert_fail
        [ "$($l len)" -eq 0 ] || assert_fail
}
readonly -f test_container_list_remove

function test_container_list_insert_before() {
        local l
        l=$(container_List) || assert_fail

        $l push_back 3 || assert_fail

        local e
        local v

        e=$($l front) || assert_fail
        $l insert_before 10 "$e" || assert_fail

        [ "$($l len)" -eq 2 ] || assert_fail

        e=$($l front) || assert_fail
        v=$($e value) || assert_fail
        [ "${v}" = 10 ] || assert_fail
}
readonly -f test_container_list_insert_before

function test_container_list_insert_after() {
        local l
        l=$(container_List) || assert_fail

        $l push_back 3 || assert_fail

        local e
        local v

        e=$($l front) || assert_fail
        $l insert_after 10 "$e" || assert_fail

        [ "$($l len)" -eq 2 ] || assert_fail

        e=$($l front)
        v=$($e value)
        [ "${v}" = 3 ] || assert_fail
}
readonly -f test_container_list_insert_after

function test_container_list_move_to_front() {
        local l
        l=$(container_List)

        $l push_back 3
        $l push_back 10

        local e
        local v

        e=$($l back)
        $l move_to_front "$e" || assert_fail

        e=$($l front)
        v=$($e value)
        [ "${v}" = 10 ] || assert_fail "was ${v}"
}
readonly -f test_container_list_move_to_front

function test_container_list_move_to_back() {
        local l
        l=$(container_List)

        $l push_back 3
        $l push_back 10

        local e
        local v

        e=$($l front)
        $l move_to_back "$e" || assert_fail

        e=$($l front)
        v=$($e value)
        [ "${v}" = 10 ] || assert_fail "was ${v}"
}
readonly -f test_container_list_move_to_back

function test_container_list_move_before() {
        local l
        l=$(container_List)

        $l push_back 3
        $l push_back 5
        $l push_back 10

        local e1
        local e2
        local e3
        local v

        e1=$($l front)
        e2=$($e1 next)
        e3=$($e2 next)

        $l move_before "$e3" "$e2" || assert_fail
        [ "$($l len)" = 3 ] || assert_fail

        e2=$($e1 next)
        v=$($e2 value)
        [ "${v}" = 10 ] || assert_fail
}
readonly -f test_container_list_move_before

function test_container_list_move_after() {
        local l
        l=$(container_List)

        $l push_back 3
        $l push_back 5
        $l push_back 10

        local e1
        local e2
        local e3
        local v

        e1=$($l front)
        e2=$($e1 next)
        e3=$($e2 next)

        $l move_after "$e3" "$e1" || assert_fail
        [ "$($l len)" = 3 ] || assert_fail

        e2=$($e1 next)
        v=$($e2 value)
        [ "${v}" = 10 ] || assert_fail
}
readonly -f test_container_list_move_after

function test_container_list_push_back_list() {
        local l1
        l1=$(container_List)
        $l1 push_back 2
        $l1 push_back 3

        local l2
        l2=$(container_List)
        $l2 push_back 10
        $l2 push_back 20

        $l1 push_back_list "$l2" || assert_fail
        [ "$($l1 len)" -eq 4 ] || assert_fail

        local e
        local v

        e=$($l1 front)
        v=$($e value)
        [ "${v}" -eq 2 ] || assert_fail

        e=$($l1 back)
        v=$($e value)
        [ "${v}" -eq 20 ] || assert_fail
}
readonly -f test_container_list_push_back_list

function test_container_list_push_front_list() {
        local l1
        l1=$(container_List)
        $l1 push_back 2
        $l1 push_back 3

        local l2
        l2=$(container_List)
        $l2 push_back 10
        $l2 push_back 20

        $l1 push_front_list "$l2" || assert_fail
        [ "$($l1 len)" -eq 4 ] || assert_fail

        local e
        local v

        e=$($l1 front)
        v=$($e value)
        [ "${v}" -eq 10 ] || assert_fail

        e=$($l1 back)
        v=$($e value)
        [ "${v}" -eq 3 ] || assert_fail
}
readonly -f test_container_list_push_front_list
