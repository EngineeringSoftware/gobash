#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Tests for running available examples.

if [ -n "${EXAMPLES_TEST:-}" ]; then return 0; fi
readonly EXAMPLES_TEST=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${EXAMPLES_TEST}/../gobash


# ----------
# Functions.

function _exet() {
        local funcn="${1}"
        shift 1 || return $EC

        "${EXAMPLES_TEST}/${funcn#test_examples_*}" "$@"
}

function test_examples_anonymous_struct_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_anonymous_struct_ex

function test_examples_flags_details_ex() {
        _exet "$FUNCNAME" "--ignore"
}
readonly -f test_examples_flags_details_ex

function test_examples_log_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_log_ex

function test_examples_result_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_result_ex

function test_examples_text_progress_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_text_progress_ex

function test_examples_wait_group_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_wait_group_ex

function test_examples_binary_trees_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_binary_trees_ex

function test_examples_flags_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_flags_ex

function test_examples_map_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_map_ex

function test_examples_shapes_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_shapes_ex

function test_examples_text_spinner_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_text_spinner_ex

function test_examples_web_server_ex() {
        # Expects user input.
        #_exet "$FUNCNAME"
        :
}
readonly -f test_examples_web_server_ex

function test_examples_chan_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_chan_ex

function test_examples_hello_world_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_hello_world_ex

function test_examples_methods_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_methods_ex

function test_examples_strings_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_strings_ex

function test_examples_to_json_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_to_json_ex

function test_examples_whiptail_ex() {
        local -r t="${1}"
        ! whiptail_enabled && $t skip "no whiptail"

        _exet "$FUNCNAME"
}
readonly -f test_examples_whiptail_ex

function test_examples_error_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_error_ex

function test_examples_linked_list_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_linked_list_ex

function test_examples_mutex_counter_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_mutex_counter_ex

function test_examples_structs_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_structs_ex

function test_examples_to_string_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_to_string_ex

function test_examples_file_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_file_ex

function test_examples_list_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_list_ex

function test_examples_regexp_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_regexp_ex

function test_examples_text_menu_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_text_menu_ex

function test_examples_user_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_user_ex

function test_examples_visitor_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_visitor_ex

function test_examples_template_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_examples_template_ex
