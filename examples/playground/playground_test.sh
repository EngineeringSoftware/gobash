#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Tests for running available playground.

if [ -n "${PLAYGROUND_TEST:-}" ]; then return 0; fi
readonly PLAYGROUND_TEST=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${PLAYGROUND_TEST}/../../gobash


# ----------
# Functions.

function _exet() {
        local funcn="${1}"
        shift 1 || return $EC

        "${PLAYGROUND_TEST}/${funcn#test_playground_*}" "$@"
}

function test_playground_clear_screen_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_playground_clear_screen_ex

function test_playground_concurrent_pi_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_playground_concurrent_pi_ex

function test_playground_hellow_world_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_playground_hellow_world_ex

function test_playground_http_server_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_playground_http_server_ex

function test_playground_sleep_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_playground_sleep_ex

function test_playground_test_function_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_playground_test_function_ex

function test_playground_ring_do_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_playground_ring_do_ex

function test_playground_ring_len_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_playground_ring_len_ex

function test_playground_ring_link_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_playground_ring_link_ex

function test_playground_ring_move_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_playground_ring_move_ex

function test_playground_ring_next_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_playground_ring_next_ex

function test_playground_ring_prev_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_playground_ring_prev_ex

function test_playground_ring_unlink_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_playground_ring_unlink_ex

function test_playground_list_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_playground_list_ex
