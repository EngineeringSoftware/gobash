#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the map module.

if [ -n "${MAP_TEST_MOD:-}" ]; then return 0; fi
readonly MAP_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${MAP_TEST_MOD}/map.sh
. ${MAP_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_map() {
        local map
        map=$(Map) || \
                assert_fail "Unable to make a map."

        map=$(Map "a" 1 "b" 2) || \
                assert_fail "Unable to make a map with elements."

        map=$(Map "a") && \
                assert_fail

        return 0
}
readonly -f test_map

function test_map_len() {
        local map
        local len

        map=$(Map) || \
                assert_fail

        len=$($map len)
        assert_eq 0 "${len}"

        map=$(Map "a" 1 "b" 2) || \
                assert_fail
        assert_eq 2 "$($map len)"
}
readonly -f test_map_len

function test_map_put() {
        local map
        local ec

        map=$(Map) || \
                assert_fail

        $map put "a" 1 || \
                assert_fail

        ec=0
        $map put || ec=$?
        assert_ec ${ec}
}
readonly -f test_map_put

function test_map_get() {
        local map
        local val

        map=$(Map "a" 1 "b" 2) || \
                assert_fail

        assert_eq 1 "$($map get 'a')"
        assert_eq 2 "$($map get 'b')"

        val=$($map get "z") && \
                assert_fail
        assert_eq "${NULL}" "${val}"
}
readonly -f test_map_get

function test_map_keys() {
        local map
        local keys
        local len

        map=$(Map "a" 1 "b" 2) || \
                assert_fail
        keys=$($map keys) || \
                assert_fail
        len=$($keys len)
        assert_eq 2 "${len}" "Incorrect length."

        map=$(Map) || \
                assert_fail
        keys=$($map keys) || \
                assert_fail
        len=$($keys len)
        assert_eq 0 "${len}"
}
readonly -f test_map_keys

function test_map_inc() {
        local map
        local val

        map=$(Map)

        $map inc "a" || assert_fail
        $map inc "a" || assert_fail
        $map inc "a" || assert_fail

        val=$($map get "a") || \
                assert_fail
        assert_eq 3 "${val}"
}
readonly -f test_map_inc

function test_map_methods_vs_fields() {
        local map
        map=$(Map)

        $map put "a" 1 || assert_fail
        $map put "b" 2 || assert_fail
        $map put "put" 3 || assert_fail
        $map put "d" 4 || assert_fail

        assert_eq 4 "$($map len)"
}
readonly -f test_map_methods_vs_fields

function test_map_key_order() {
        local map
        map=$(Map "b" 5 \
                  "a" 2 \
                  "c" 4 \
                  "z" 4 \
                  "aa" 5) || assert_fail

        assert_eq 5 "$($map len)"

        local keys
        keys=$($map keys) || assert_fail

        assert_eq 5 "$($keys len)"
        assert_eq b "$($keys get 0)"
        assert_eq a "$($keys get 1)"
        assert_eq c "$($keys get 2)"
        assert_eq z "$($keys get 3)"
        assert_eq aa "$($keys get 4)"
}
readonly -f test_map_key_order

function test_map_ctx() {
        local ctx=$(ctx_make)

        local map
        map=$(Map $ctx "b") && \
                assert_fail

        ctx_show $ctx | grep 'insufficient args' >/dev/null || \
                assert_fail
}
readonly -f test_map_ctx
