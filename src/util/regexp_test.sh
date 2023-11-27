#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the regexp module.

if [ -n "${REGEXP_TEST_MOD:-}" ]; then return 0; fi
readonly REGEXP_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${REGEXP_TEST_MOD}/regexp.sh
. ${REGEXP_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_regexp_match_string() {
        local ec

        regexp_match_string ".essy" "Jessy" || \
                assert_fail

        regexp_match_string "J[e|b]ssy" "Jessy" || \
                assert_fail

        regexp_match_string "J[e|b]ssy" "Jbssy" || \
                assert_fail

        ec=0
        regexp_match_string "J[e|b]ssy" "Jdssy" || ec=$?
        assert_false ${ec}

        ec=0
        regexp_match_string "*J[e|b]ssy" "Jdssy" || ec=$?
        assert_ec ${ec}

        local ctx=$(ctx_make)
        regexp_match_string $ctx "!~~%^^^[" "string" && return $EC
        ctx_show $ctx | grep 'incorrect re' || \
                assert_fail
}
readonly -f test_regexp_match_string

function test_regexp_compile() {
        local regexp
        local ec

        regexp=$(regexp_compile "app[le]") || \
                assert_fail

        ec=0
        regexp=$(regexp_compile "*apple") || ec=$?
        assert_ec ${ec}

        regexp=$(regexp_compile "app[le]") || \
                assert_fail

        $regexp match_string "appe" || \
                assert_fail

        $regexp match_string "appl" || \
                assert_fail

        ec=0
        $regexp match_string "appb" || ec=$?
        assert_false ${ec}

        local ctx=$(ctx_make)
        regexp=$(regexp_compile $ctx "!~~%^^^[") && \
                assert_fail
        ctx_show $ctx | grep 'incorrect re' || \
                assert_fail
}
readonly -f test_regexp_compile

function test_regexp_to_string() {
        local regexp
        regexp=$(regexp_compile "app[le]") || \
                assert_fail
        assert_eq "app[le]" "$($regexp to_string)"
}
readonly -f test_regexp_to_string

function test_regexp_find_string() {
        local regexp
        regexp=$(regexp_compile "app[le]") || \
                assert_fail

        local str
        str=$($regexp find_string "some appe is an appl") || \
                assert_fail
        assert_eq "appe" "${str}"
}
readonly -f test_regexp_find_string

function test_regexp_string_index() {
        local regexp
        regexp=$(regexp_compile "app[le]") || \
                assert_fail

        local str="some appe is an appl"

        local lst
        lst=$($regexp find_string_index "${str}") || \
                assert_fail

        local res="${str:$($lst first):$($lst second)}"
        assert_eq "appe" "${res}"
        
}
readonly -f test_regexp_string_index

function test_regexp_string_submatch() {
        local regexp
        regexp=$(regexp_compile "a(.*)b(.*)c") || \
                assert_fail

        local str="xxxawillbmatchczzz"

        local lst
        lst=$($regexp find_string_submatch "${str}") || \
                assert_fail

        assert_eq "awillbmatchc" "$($lst get 0)"
        assert_eq "will" "$($lst get 1)"
        assert_eq "match" "$($lst get 2)"
}
readonly -f test_regexp_string_submatch
