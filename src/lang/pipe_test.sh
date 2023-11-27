#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the pipe module.

if [ -n "${PIPE_TEST_MOD:-}" ]; then return 0; fi
readonly PIPE_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${PIPE_TEST_MOD}/assert.sh
. ${PIPE_TEST_MOD}/pipe.sh
. ${PIPE_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_pipe() {
        local p
        p=$(Pipe) || \
                assert_fail
        ( $p send "Text" ) &

        local msg
        msg=$($p recv) || \
                assert_fail
        assert_eq "${msg}" "Text"
        wait || \
                assert_fail
}
readonly -f test_pipe
