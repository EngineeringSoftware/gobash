#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the wait_group module.

if [ -n "${WAIT_GROUP_TEST_MOD:-}" ]; then return 0; fi
readonly WAIT_GROUP_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${WAIT_GROUP_TEST_MOD}/wait_group.sh
. ${WAIT_GROUP_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_wait_group() {
        local -r wg=$(WaitGroup)

        ( echo 1 >/dev/null  ) &
        $wg add $!

        ( echo 2 >/dev/null ) &
        $wg add $!

        assert_eq $($wg len) 2

        $wg wait || \
                assert_fail
}
readonly -f test_wait_group
