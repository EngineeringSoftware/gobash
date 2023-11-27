#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the string module.

if [ -n "${STRINGS_TEST_MOD:-}" ]; then return 0; fi
readonly STRINGS_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${STRINGS_TEST_MOD}/strings.sh
. ${STRINGS_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_strings_len() {
        local len

        local val=""
        len=$(strings_len "${val}") || \
                assert_fail
        assert_eq 0 "${len}"

        local val="abc"
        len=$(strings_len "${val}") || \
                assert_fail
        assert_eq 3 "${len}"
}
readonly -f test_strings_len

function test_strings_count() {
        local c

        local -r val="something that has chars and many other chars and not many\nchars"

        c=$(strings_count "${val}" "chars") || \
                assert_fail
        assert_eq 3 "${c}"

        c=$(strings_count "${val}" "charss") || \
                assert_fail
        assert_eq 0 "${c}"

        c=$(strings_count "${val}" "char") || \
                assert_fail
        assert_eq 3 "${c}"

        c=$(strings_count "${val}" "and") || \
                assert_fail
        assert_eq 2 "${c}"
}
readonly -f test_strings_count

function test_strings_repeat() {
        local res

        res=$(strings_repeat "a" "4") || \
                assert_fail
        assert_eq "aaaa" "${res}"

        res=$(strings_repeat "a" "10") || \
                assert_fail
        assert_eq "aaaaaaaaaa" "${res}"

        res=$(strings_repeat "b" "1") || \
                assert_fail
        assert_eq "b" "${res}"

        strings_repeat "b" "0" && \
                assert_fail

        return 0
}
readonly -f test_strings_repeat

function test_strings_has() {
        strings_has "abcdefg" "abc" || \
                assert_fail

        strings_has "xabcdefg" "abc" || \
                assert_fail

        strings_has "something else" "abc" && \
                assert_fail

        return 0
}
readonly -f test_strings_has

function test_strings_has_prefix() {
        strings_has_prefix "abcdefg" "abc" || \
                assert_fail

        strings_has_prefix "abcdefg" "def" && \
                assert_fail

        local ctx=$(ctx_make)
        strings_has_prefix $ctx "abcdefg" && \
                assert_fail
        ctx_show $ctx | grep 'incorrect num' || \
                assert_fail

        strings_has_prefix "abc" "abc" || \
                assert_fail
}
readonly -f test_strings_has_prefix

function test_strings_has_suffix() {
        strings_has_suffix "abcdef" "def" || \
                assert_fail

        strings_has_suffix "abcd" "def" && \
                assert_fail

        strings_has_suffix && \
                assert_fail

        return 0
}
readonly -f test_strings_has_suffix

function test_strings_remove_prefix() {
        local val

        val=$(strings_remove_prefix "blah-1.0.1" "blah-") || \
                assert_fail
        assert_eq "1.0.1" "${val}"

        val=$(strings_remove_prefix "blah-1.0.1" "random") || \
                assert_fail
        assert_eq "blah-1.0.1" "${val}"
}
readonly -f test_strings_remove_prefix

function test_strings_sub() {
        local val

        val=$(strings_sub "abcdefg" 0 1) || \
                assert_fail
        assert_eq "a" "${val}"

        val=$(strings_sub "abcdefg" 0 5) || \
                assert_fail
        assert_eq "abcde" "${val}"
}
readonly -f test_strings_sub

function test_strings_remove_at() {
        local val

        val=$(strings_remove_at "abdc" 100) && \
                assert_fail

        val=$(strings_remove_at "abdc" -1) && \
                assert_fail

        val=$(strings_remove_at "abcd" 0) || \
                assert_fail
        assert_eq "bcd" "${val}"

        val=$(strings_remove_at "abcd" 1) || \
                assert_fail
        assert_eq "acd" "${val}"

        val=$(strings_remove_at "abcd" 3) || \
                assert_fail
        assert_eq "abc" "${val}"
}
readonly -f test_strings_remove_at

function test_strings_cap() {
        local val

        val=$(strings_cap "something") || \
                assert_fail
        assert_eq "Something" "${val}"

        val=$(strings_cap "Something") || \
                assert_fail
        assert_eq "Something" "${val}"

        val=$(strings_cap "s") || \
                assert_fail
        assert_eq "S" "${val}"

        val=$(strings_cap "") || \
                assert_fail
        assert_eq "" "${val}"

        val=$(strings_cap) && \
                assert_fail

        val=$(strings_cap "something else") || \
                assert_fail
        assert_eq "Something else" "${val}"
}
readonly -f test_strings_cap

function test_strings_cap_pipe() {
        local val

        val=$(echo "something" | strings_pcap) || \
                assert_fail
        assert_eq "Something" "${val}"

        val=$(echo "else" | xargs -I x "${X_BASH}" -c 'strings_cap x') || \
                assert_fail
        assert_eq "Else" "${val}"
}
readonly -f test_strings_cap_pipe

function test_strings_rev() {
        local val

        val=$(strings_rev "something") || \
                assert_fail
        assert_eq "gnihtemos" "${val}"

        val=$(strings_rev "s") || \
                assert_fail
        assert_eq "s" "${val}"

        val=$(strings_rev) && \
                assert_fail

        val=$(strings_rev "") || \
                assert_fail
        assert_eq "" "${val}"
}
readonly -f test_strings_rev

function test_strings_remove_spaces() {
        local val

        val=$(strings_remove_spaces "abc") || \
                assert_fail
        assert_eq "abc" "${val}"

        val=$(strings_remove_spaces "abc def") || \
                assert_fail
        assert_eq "abcdef" "${val}"

        val=$(strings_remove_spaces "abc     def") || \
                assert_fail
        assert_eq "abcdef" "${val}"

        val=$(strings_remove_spaces "  abc  def  ") || \
                assert_fail
        assert_eq "abcdef" "${val}"
}
readonly -f test_strings_remove_spaces

function test_strings_remove_char() {
        local val

        val=$(strings_remove_char "abc" 'b') || \
                assert_fail
        assert_eq "ac" "${val}"

        val=$(strings_remove_char "abc def" 'f') || \
                assert_fail
        assert_eq "abc de" "${val}"

        val=$(strings_remove_char "abf def" 'f') || \
                assert_fail
        assert_eq "ab de" "${val}"
}
readonly -f test_strings_remove_char

function test_strings_lstrip() {
        local val

        val=$(strings_lstrip "    abc") || \
                assert_fail
        assert_eq "abc" "${val}"

        val=$(strings_lstrip " abc   ") || \
                assert_fail
        assert_eq "abc   " "${val}"

        val=$(strings_lstrip "   ") || \
                assert_fail
        assert_eq "" "${val}"
}
readonly -f test_strings_lstrip

function test_strings_rstrip() {
        local val

        val=$(strings_rstrip "abc    ") || \
                assert_fail
        assert_eq "abc" "${val}"

        val=$(strings_rstrip "   abc ") || \
                assert_fail
        assert_eq "   abc" "${val}"

        val=$(strings_rstrip "abc") || \
                assert_fail
        assert_eq "abc" "${val}"

        val=$(strings_rstrip) && \
                assert_fail

        val=$(strings_rstrip "") || \
                assert_fail
        assert_eq "" "${val}"
}
readonly -f test_strings_rstrip

function test_strings_strip() {
        local val

        val=$(strings_strip "abc") || \
                assert_fail
        assert_eq "abc" "${val}"

        val=$(strings_strip "  abc ") || \
                assert_fail
        assert_eq "abc" "${val}"

        val=$(strings_strip "") || \
                assert_fail
        assert_eq "" "${val}"
}
readonly -f test_strings_strip

function test_strings_single_space() {
        local val

        val=$(strings_single_space "") || \
                assert_fail
        assert_eq "" "${val}"

        val=$(strings_single_space "      abc      d    ") || \
                assert_fail
        assert_eq " abc d " "${val}"

        val=$(strings_single_space "") || \
                assert_fail
        assert_eq "" "${val}"

        val=$(strings_single_space) && \
                assert_fail

        return 0
}
readonly -f test_strings_single_space

function test_strings_escape_slash() {
        local val

        val=$(strings_escape_slash "we have / something in this string /") || \
                assert_fail
        assert_eq "we have \/ something in this string \/" "${val}"

        val=$(strings_escape_slash "") || \
                assert_fail
        assert_eq "" "${val}"

        val=$(strings_escape_slash) && \
                assert_fail

        return 0
}
readonly -f test_strings_escape_slash

function test_strings_to_lower() {
        local val

        val=$(strings_to_lower "nothing to change") || \
                assert_fail
        assert_eq "nothing to change" "${val}"

        val=$(strings_to_lower "Something To chanGE") || \
                assert_fail
        assert_eq "something to change" "${val}"

        val=$(strings_to_lower "") || \
                assert_fail
        assert_eq "" "${val}"

        val=$(strings_to_lower) && \
                assert_fail

        return 0
}
readonly -f test_strings_to_lower

function test_strings_to_upper() {
        local val

        val=$(strings_to_upper "NOTHING TO CHANGE") || \
                assert_fail
        assert_eq "NOTHING TO CHANGE" "${val}"

        val=$(strings_to_upper "Something TO changE") || \
                assert_fail
        assert_eq "SOMETHING TO CHANGE" "${val}"

        val=$(strings_to_upper "") || \
                assert_fail
        assert_eq "" "${val}"

        val=$(strings_to_upper) && \
                assert_fail

        return 0
}
readonly -f test_strings_to_upper

function test_strings_swap_case() {
        local val

        val=$(strings_swap_case "aBcDeeeflj") || \
                assert_fail
        assert_eq "AbCdEEEFLJ" "${val}"

        val=$(strings_swap_case "") || \
                assert_fail
        assert_eq "" "${val}"

        val=$(strings_swap_case) && \
                assert_fail

        return 0
}
readonly -f test_strings_swap_case

function test_strings_index_of() {
        local val

        val=$(strings_index_of "abcdefg" "abc") || \
                assert_fail
        assert_eq 0 "${val}"

        val=$(strings_index_of "abcdefg" "def") || \
                assert_fail
        assert_eq 3 "${val}"

        val=$(strings_index_of "abcdefg" "xxx") || \
                assert_fail
        assert_eq -1 "${val}"

        val=$(strings_index_of) && \
                assert_fail

        val=$(strings_index_of "" "") || \
                assert_fail
}
readonly -f test_strings_index_of

function test_strings_join() {
        local val

        val=$(strings_join "," "a" "b" "c") || \
                assert_fail
        assert_eq "a,b,c" "${val}"

        val=$(strings_join "#" "a" "b" "c") || \
                assert_fail
        assert_eq "a#b#c" "${val}"

        val=$(strings_join) && \
                assert_fail

        val=$(strings_join ",") && \
                assert_fail

        val=$(strings_join "," "") || \
                assert_fail
        assert_eq "" "${val}"
}
readonly -f test_strings_join
