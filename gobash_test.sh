#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Tests for the gobash module.

if [ -n "${GOBASH_TEST_MOD:-}" ]; then return 0; fi
readonly GOBASH_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${GOBASH_TEST_MOD}/gobash


# ----------
# Functions.

function test_gobash_help() {
        gobash_help > /dev/null || \
                assert_fail
}
readonly -f test_gobash_help

function test_gobash_func() {
        gobash_func > /dev/null && \
                assert_fail

        gobash_func sys_version > /dev/null || \
                assert_fail
}
readonly -f test_gobash_func

function test_gobash_test() {
        gobash_test > /dev/null && \
                assert_fail

        return 0
}
readonly -f test_gobash_test

function test_gobash_lint() {
        gobash_lint "${BASH_SOURCE[0]}" > /dev/null && \
                assert_fail

        return 0
}
readonly -f test_gobash_lint

# function test_gobash_doc() {
#         :
# }
# readonly -f test_gobash_doc

function test_gobash_version() {
        gobash_version > /dev/null || \
                assert_fail
}
readonly -f test_gobash_version

function test_gobash_ctx() {
        local ctx=$(ctx_make)

        main $ctx test | grep 'has to be provided' > /dev/null || \
                assert_fail

        ctx_show $ctx | grep 'arguments do not pass check' || \
                assert_fail
}
readonly -f test_gobash_ctx
