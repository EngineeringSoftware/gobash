#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the os module.

if [ -n "${LANG_OS_TEST_MOD:-}" ]; then return 0; fi
readonly LANG_OS_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${LANG_OS_TEST_MOD}/assert.sh
. ${LANG_OS_TEST_MOD}/os.sh


# ----------
# Functions.

function test_os_name() {
        os_name || \
                assert_fail
}
readonly -f test_os_name

function test_os_arch() {
        os_arch || \
                assert_fail
}
readonly -f test_os_arch

function test_os_mktemp_file() {
        local -r f=$(os_mktemp_file)
        [ -f "${f}" ] || \
                assert_fail
}
readonly -f test_os_mktemp_file

function test_os_mktemp_dir() {
        local -r d=$(os_mktemp_dir)
        [ -d "${d}" ] || \
                assert_fail
}
readonly -f test_os_mktemp_dir

function test_os_get_pid() {
        os_get_pid > /dev/null || \
                assert_fail
}
readonly -f test_os_get_pid
