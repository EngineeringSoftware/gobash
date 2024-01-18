#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the os module.

if [ -n "${UTIL_OS_TEST_MOD:-}" ]; then return 0; fi
readonly UTIL_OS_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${UTIL_OS_TEST_MOD}/os.sh


# ----------
# Functions.

function test_os_stat() {
        local fi

        fi=$(os_stat "$(sys_repo_path)/README.md") || \
                assert_fail

        assert_eq "README.md" "$($fi name)"
        assert_gt "$($fi size)" 3000
        # The value might not be the same in CI.
        # assert_eq "-rw-rw-r--" "$($fi mode)"
        $fi is_dir && \
                assert_fail
        is_null "$($fi mod_time)" && \
                assert_fail

        $fi to_string | grep 'README.md' || \
                assert_fail

        local ctx
        ctx=$(ctx_make)
        fi=$(os_stat $ctx "blabblah") && \
                assert_fail
        ctx_show $ctx | grep 'incorrect path' || \
                assert_fail
}
readonly -f test_os_stat

function _abc() {
        local a="${1}"
        local b="${2}"

        sleep 60
        local c=$(( ${a} + ${b} ))
        echo ${c}
}

function test_os_timeout() {
        os_timeout 5 "_abc" 3 4 && \
                assert_fail

        return 0
}
readonly -f test_os_timeout

function _def() {
        :
}

function test_os_wo_timeout() {
        os_timeout 60 "_def" "a" "b" || \
                assert_fail
}
readonly -f test_os_wo_timeout

function test_os_disable_timeout() {
        os_timeout 0 "_def" "a" "b" || \
                assert_fail
}
readonly -f test_os_disable_timeout

function test_os_loop_n() {
        os_loop_n 3 "_def" || \
                assert_fail
}
readonly -f test_os_loop_n

function test_os_loop_secs() {
        os_loop_secs 3 "_def" || \
                assert_fail
}
readonly -f test_os_loop_secs
