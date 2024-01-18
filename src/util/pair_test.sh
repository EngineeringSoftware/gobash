#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the pair module.

if [ -n "${PAIR_TEST_MOD:-}" ]; then return 0; fi
readonly PAIR_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${PAIR_TEST_MOD}/pair.sh
. ${PAIR_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_pair() {
        local pr
        pr=$(Pair) || \
                assert_fail
}
readonly -f test_pair

function test_pair_uninit() {
        local pr
        pr=$(Pair) || \
                assert_fail
    
        assert_eq "$($pr first)" "${NULL}"
        assert_eq "$($pr second)" "${NULL}"
}
readonly -f test_pair_uninit

function test_pair_init() {
        local pr
        pr=$(Pair 1 2) || \
                assert_fail
    
        assert_eq "$($pr first)" "1"
        assert_eq "$($pr second)" "2"
}
readonly -f test_pair_init

function test_pair_set() {
        local pr
        pr=$(Pair) || \
                assert_fail
        $pr first 1
        assert_eq "$($pr first)" "1"
        assert_eq "$($pr second)" "${NULL}"

        $pr second 2
        assert_eq "$($pr first)" "1"
        assert_eq "$($pr second)" "2"
}
readonly -f test_pair_set

function test_pair_swap() {
        local pr1
        local pr2
        pr1=$(Pair 1 2) || \
                assert_fail
        pr2=$(Pair A B) || \
                assert_fail

        $pr1 swap "$pr2"
        assert_eq "$($pr1 first)" "A"
        assert_eq "$($pr1 second)" "B"
        assert_eq "$($pr2 first)" "1"
        assert_eq "$($pr2 second)" "3"
}
readonly -f test_pair_swap

function test_pair_swap_args() {
        local pr
        pr=$(Pair A B) || \
                assert_fail

        $pr swap_args
        assert_eq "$($pr first)" "B"
        assert_eq "$($pr second)" "A"
}
readonly -f test_pair_swap_args
