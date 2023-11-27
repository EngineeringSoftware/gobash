#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the sys module.

if [ -n "${SYS_TEST_MOD:-}" ]; then return 0; fi
readonly SYS_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${SYS_TEST_MOD}/assert.sh
. ${SYS_TEST_MOD}/sys.sh
. ${SYS_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_sys_stack_trace() {
        function main() {
                sys_stack_trace | grep 'main' > /dev/null
        }
        main || \
                assert_fail
}
readonly -f test_sys_stack_trace

function test_sys_is_on_stack() {
        sys_is_on_stack "${FUNCNAME}" > /dev/null || \
                assert_fail

        sys_is_on_stack "blah" > /dev/null && \
                assert_fail

        return 0
}
readonly -f test_sys_is_on_stack

function test_sys_line_num() {
        assert_eq 39 $(sys_line_num)
}
readonly -f test_sys_line_num

function test_sys_line_prev() {
        # this is prev
        assert_eq "        # this is prev" "$(sys_line_prev)"
}
readonly -f test_sys_line_prev

function test_sys_line_next() {
        # this is prev
        assert_eq "        # this is next" "$(sys_line_next)"
        # this is next
}
readonly -f test_sys_line_next

function test_sys_bash_files() {
        sys_bash_files | grep 'sys_test.sh'
}
readonly -f test_sys_bash_files

function test_sys_functions() {
        sys_functions | grep 'sys_functions' || \
                assert_fail
}
readonly -f test_sys_functions

function test_sys_functions_in_file() {
        sys_functions_in_file "${BASH_SOURCE[0]}" | \
                grep '^test_sys_functions$' > /dev/null || \
                assert_fail
}
readonly -f test_sys_functions_in_file

function test_sys_function_doc_lines() {
        local -r script="$(sys_repo_path)/src/lang/sys.sh"
        local val

        val=$(sys_function_doc_lines "${script}" "sys_version") || \
                assert_fail
        assert_eq 1 "${val}"

        val=$(sys_function_doc_lines "${script}" "sys_line_prev") || \
                assert_fail
        assert_eq 2 "${val}"
}
readonly -f test_sys_function_doc_lines

function test_sys_function_doc() {
        local -r script="$(sys_repo_path)/src/lang/sys.sh"
        local val

        val=$(sys_function_doc "${script}" "sys_version") || \
                assert_fail
        assert_eq "Version." "${val}"

        val=$(sys_function_doc "${script}" "sys_line_prev") || \
                assert_fail
}
readonly -f test_sys_function_doc
