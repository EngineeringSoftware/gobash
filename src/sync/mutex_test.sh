#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the mutex module.

if [ -n "${MUTEX_TEST_MOD:-}" ]; then return 0; fi
readonly MUTEX_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${MUTEX_TEST_MOD}/mutex.sh
. ${MUTEX_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_mutex() {
        local mu
        mu=$(Mutex) || \
                assert_fail

        $mu lock || \
                assert_fail

        $mu unlock || \
                assert_fail
}
readonly -f test_mutex

function test_mutex_count() {
        local -r mu=$(Mutex)

        local -r count=$(Int 0)

        ( $mu lock; $count inc; $mu unlock ) &
        ( $mu lock; $count inc; $mu unlock ) &
        ( $mu lock; $count inc; $mu unlock ) &
        wait || \
                assert_fail

        assert_eq 3 "$($count val)"
}
readonly -f test_mutex_count
