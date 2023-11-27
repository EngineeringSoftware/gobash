#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the ring module.

if [ -n "${CONTAINER_RING_TEST_MOD:-}" ]; then return 0; fi
readonly CONTAINER_RING_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${CONTAINER_RING_TEST_MOD}/ring.sh
. ${CONTAINER_RING_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_container_ring_constructor() {
        local r
        r=$(container_Ring 0) && assert_fail
        r=$(container_Ring "abc") && assert_fail
        
        r=$(container_Ring 1) || assert_fail
        is_null "$($r next)" && assert_fail
        is_null "$($r prev)" && assert_fail

        r=$(container_Ring 2) || assert_fail
        is_null "$($r next)" && assert_fail
        is_null "$($r prev)" && assert_fail

        [ "$($($r _next) _next)" = "$r" ] || assert_fail
        [ "$($($r _prev) _prev)" = "$r" ] || assert_fail

        return 0
}
readonly -f test_container_ring_constructor

function test_container_ring_len() {
        local r
        r=$(container_Ring 5)
        [ "$($r len)" -eq 5 ] || assert_fail
}
readonly -f test_container_ring_len

function test_container_ring_next() {
        local r
        r=$(container_Ring 3) || assert_fail
        [ "$($r _next)" = "$($r next)" ] || assert_fail

        $r _next "$NULL"
        [ "$r" = "$($r next)" ] || assert_fail
}
readonly -f test_container_ring_next

function test_container_ring_prev() {
        local r
        r=$(container_Ring 3) || assert_fail
        [ "$($r _prev)" = "$($r prev)" ] || assert_fail

        $r _prev "$NULL"
        [ "$r" = "$($r prev)" ] || assert_fail
}
readonly -f test_container_ring_prev

function test_container_ring_do() {
        local r
        r=$(container_Ring 3) || assert_fail

        $r value "$(Int 3)"
        $($r _next) value "$(Int 4)"
        $($($r _next) _next) value "$(Int 5)"

        function f() {
                local val="${1}"
                $val val "$(( $($val val) + 1 ))"
        }

        $r do "f"
        $($r value) to_string | grep '"val": "4"' > /dev/null
}
readonly -f test_container_ring_do

function test_container_ring_link() {
        local r
        r=$(container_Ring 2) || assert_fail

        local s
        s=$(container_Ring 2) || assert_fail

        $r link "$s" > /dev/null
        [ "$($r len)" = 4 ] || assert_fail
}
readonly -f test_container_ring_link

function test_container_ring_move() {
        local r
        r=$(container_Ring 3) || assert_fail

        $r value 1
        $($r _next) value 2
        $($($r _next) _next) value 3

        r=$($r move 0) || assert_fail
        [ "$($r value)" -eq 1 ] || assert_fail

        r=$($r move 1) || assert_fail
        [ "$($r value)" -eq 2 ] || assert_fail

        r=$($r move -1) || assert_fail
        [ "$($r value)" -eq 1 ] || assert_fail

        r=$($r move 2) || assert_fail
        [ "$($r value)" -eq 3 ] || assert_fail
}
readonly -f test_container_ring_move

function test_container_ring_unlink() {
        local r
        r=$(container_Ring 3) || assert_fail

        $r value 1
        $($r _next) value 2
        $($($r _next) _next) value 3

        $r unlink 0 > /dev/null
        [ "$($r value)" -eq 1 ] || assert_fail

        $r unlink 1 > /dev/null
        [ "$($r len)" -eq 2 ] || assert_fail
        [ "$($r value)" -eq 1 ] || assert_fail
        [ "$($($r _next) value)" -eq 3 ] || assert_fail
}
readonly -f test_container_ring_unlink
