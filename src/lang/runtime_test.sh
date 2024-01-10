#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the runtime module.

if [ -n "${LANG_RUNTIME_TEST_MOD:-}" ]; then return 0; fi
readonly LANG_RUNTIME_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${LANG_RUNTIME_TEST_MOD}/assert.sh
. ${LANG_RUNTIME_TEST_MOD}/os.sh


# ----------
# Functions.

function test_runtime_num_cpu() {
        local n
        n=$(runtime_num_cpu) || assert_fail

        ! is_int "${n}" && assert_fail
        [ "${n}" -lt 1 ] && assert_fail
        return 0
}
readonly -f test_runtime_num_cpu

function test_runtime_num_physical_cpu() {
        local n
        n=$(runtime_num_physical_cpu) || assert_fail

        ! is_int "${n}" && assert_fail
        [ "${n}" -lt 1 ] && assert_fail
        return 0
}
readonly -f test_runtime_num_physical_cpu
