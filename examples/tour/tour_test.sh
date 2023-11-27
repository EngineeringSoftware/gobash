#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Tests for running available tour.

if [ -n "${TOUR_TEST:-}" ]; then return 0; fi
readonly TOUR_TEST=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${TOUR_TEST}/../../gobash


# ----------
# Functions.

function _exet() {
        local funcn="${1}"
        shift 1 || return $EC

        "${TOUR_TEST}/${funcn#test_tour_*}" "$@"
}

function test_tour_case_details_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_case_details_ex

function test_tour_case_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_case_ex

function test_tour_fact_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_fact_ex

function test_tour_for_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_for_ex

function test_tour_func_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_func_ex

function test_tour_if_else_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_if_else_ex

function test_tour_if_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_if_ex

function test_tour_infinite_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_infinite_ex

function test_tour_loops_funcs_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_loops_funcs_ex

function test_tour_rand_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_rand_ex

function test_tour_select_details_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_select_details_ex

function test_tour_select_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_select_ex

function test_tour_test_cmd_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_test_cmd_ex

function test_tour_until_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_until_ex

function test_tour_variables_details_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_variables_details_ex

function test_tour_variables_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_variables_ex

function test_tour_welcome_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_welcome_ex

function test_tour_while_ex() {
        _exet "$FUNCNAME"
}
readonly -f test_tour_while_ex
