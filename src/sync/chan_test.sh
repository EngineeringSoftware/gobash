#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the channel module.

if [ -n "${CHAN_TEST_MOD:-}" ]; then return 0; fi
readonly CHAN_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${CHAN_TEST_MOD}/chan.sh
. ${CHAN_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_chan() {
        local ch
        ch=$(Chan) || \
                assert_fail

        ( $ch send 55 ) &

        local i=$(Int)
        ( local val=$($ch recv); $i val "${val}" ) &
        wait || \
                assert_fail

        assert_eq 55 "$($i val)"
}
readonly -f test_chan

function test_chan_values() {
        local ch
        ch=$(Chan) || \
                assert_fail

        ( $ch send 1 ) &
        ( $ch send 2 ) &
        ( $ch send 3 ) &

        local s=0
        local i
        for (( i=0; i<3; i++ )); do
                local val
                val=$($ch recv) || \
                        assert_fail
                s=$(( ${s} + ${val} ))
        done

        wait || \
                assert_fail

        assert_eq 6 "${s}"
}
readonly -f test_chan_values

function test_chan_objects() {
        function Point() {
                make_ "${FUNCNAME}" \
                      "x" "${1}" \
                      "y" "${2}"
        }

        local ch
        ch=$(Chan) || \
                assert_fail

        ( $ch send "$(Point 3 4)" ) &
        ( $ch send "$(Point 8 8)" ) &

        local i
        for (( i=0; i<2; i++ )); do
                local val
                val=$($ch recv) || \
                        assert_fail
                is_instanceof "${val}" Point || \
                        assert_fail

                [ $($val x) -eq 3 -o $($val x) -eq 8 ] || \
                        assert_fail

                [ $($val y) -eq 4 -o $($val y) -eq 8 ] || \
                        assert_fail
        done
        wait || \
                assert_fail
}
readonly -f test_chan_objects

function test_chan_close() {
        local ch
        ch=$(Chan) || \
                assert_fail

        order_ch=$(Chan) || \
                assert_fail

        ( $ch send 33; $order_ch send "go" ) &
        ( $ch send 55; $order_ch send "go" ) &

        ( $order_ch recv > /dev/null; $order_ch recv > /dev/null; $ch close ) &

        while :; do
                local ec=0
                $ch recv > /dev/null || ec=$?
                is_false ${ec} && break
        done
}
readonly -f test_chan_close

function test_chan_sends_recv() {
        local ch
        ch=$(Chan) || \
                assert_fail

        local -r -i n=2
        local i
        for (( i=0; i<${n}; i++ )); do
                ( $ch send $i ) &
        done

        for (( i=0; i<${n}; i++ )); do
                local ec=0
                $ch recv > /dev/null || ec=$?
                is_false ${ec} && break
        done
        wait || \
                assert_fail
}
readonly -f test_chan_sends_recv
