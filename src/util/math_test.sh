#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the math module.

if [ -n "${MATH_TEST_MOD:-}" ]; then return 0; fi
readonly MATH_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${MATH_TEST_MOD}/math.sh
. ${MATH_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_math_max() {
        assert_eq 3 $(math_max 3 1)
        assert_eq 4 $(math_max 3 4)
        assert_eq 9 $(math_max 9 -1)

        local ctx=$(ctx_make)
        math_max $ctx "" "" && \
                assert_fail
        ctx_show $ctx | grep 'no a' || \
                assert_fail
}
readonly -f test_math_max

function test_math_min() {
        assert_eq 1 $(math_min 1 3)
        assert_eq -1 $(math_min -1 3)
        assert_eq 1 $(math_min 9 1)

        local ctx=$(ctx_make)
        math_min $ctx "" "" && \
                assert_fail
        ctx_show $ctx | grep 'no a' || \
                assert_fail
}
readonly -f test_math_min

function test_math_non_zero() {
        assert_eq 55 $(math_non_zero 0 55)
        assert_eq 55 $(math_non_zero 55 0)
        assert_eq 0 $(math_non_zero 0 0)
        assert_eq 55 $(math_non_zero 55 56)
}
readonly -f test_math_non_zero

function test_math_sin() {
        local val

        val=$(math_sin 90) || \
                assert_fail
        assert_has_prefix "${val}" ".893"

        local ctx=$(ctx_make)
        math_sin $ctx && \
                assert_fail
        ctx_show $ctx | grep 'incorrect num' || \
                assert_fail
}
readonly -f test_math_sin

function test_math_cos() {
        local val

        val=$(math_cos 90) || \
                assert_fail
        assert_has_prefix "${val}" "-.448"

        local ctx=$(ctx_make)
        val=$(math_cos $ctx) && \
                assert_fail
        ctx_show $ctx | grep 'incorrect num' || \
                assert_fail
}
readonly -f test_math_cos

function test_math_log() {
        local val

        val=$(math_log 256) || \
                assert_fail
        assert_has_prefix "${val}" "5.54"

        val=$(math_log 1000) || \
                assert_fail
        assert_has_prefix "${val}" "6.90"

        val=$(math_log) && \
                assert_fail

        return 0
}
readonly -f test_math_log

function test_math_sqrt() {
        local val

        val=$(math_sqrt 2) || \
                assert_fail
        assert_has_prefix "${val}" "1.41"
}
readonly -f test_math_sqrt

function test_math_pow() {
        local val

        val=$(math_pow 2 5) || \
                assert_fail
        assert_eq 32 "${val}"
}
readonly -f test_math_pow

function test_math_lt() {
        math_lt 5 5 && \
                assert_fail

        math_lt 5 3 && \
                assert_fail

        math_lt 3 5 || \
                assert_fail

        math_lt 3.0 5.0 || \
                assert_fail

        math_lt 5.0 55.0 || \
                assert_fail
}
readonly -f test_math_lt

function test_math_le() {
        math_le 5 5 || \
                assert_fail

        math_le 4 5 || \
                assert_fail

        math_le 5 4 && \
                assert_fail

        math_le 5.5 4.4 && \
                assert_fail

        math_le 4.4 5.5 || \
                assert_fail
}
readonly -f test_math_le

function test_math_gt() {
        math_gt 5 5 && \
                assert_fail

        math_gt 5 4 || \
                assert_fail

        math_gt 6.0 6.0 && \
                assert_fail

        math_gt 6.0 0.6 || \
                assert_fail
}
readonly -f test_math_gt

function test_math_ge() {
        math_ge 5 5 || \
                assert_fail

        math_gt 5.0 5.1 && \
                assert_fail

        math_ge 5.1 5.0 || \
                assert_fail
}
readonly -f test_math_ge

function test_math_calc() {
        local v
        v=$(math_calc "5 + 3 * 10") || \
                assert_fail
        assert_eq 35 "${v}"
}
readonly -f test_math_calc

function test_math_n_percent_n() {
        local v

        v=$(math_n_percent_n 12 120) || \
                assert_fail
        assert_eq "10.0000" "${v}"

        v=$(math_n_percent_n 83 156) || \
                assert_fail
        assert_eq "53.2051" "${v}"
}
readonly -f test_math_n_percent_n

function test_math_percent_of() {
        assert_eq "30.0000" $(math_percent_of 30 100)
        assert_eq "9.6000" $(math_percent_of 32 30)
}
readonly -f test_math_percent_of

function test_math_floor() {
        assert_eq 53 $(math_floor "53.2051")
        assert_eq 53 $(math_floor "53.9051")
        assert_eq -1 $(math_floor "-0.8")
}
readonly -f test_math_floor

function test_math_ceil() {
        assert_eq 54 $(math_ceil "53.2051")
        assert_eq 54 $(math_ceil "53.9051")
        assert_eq 56 $(math_ceil "55.1")
        assert_eq 56 $(math_ceil "55.5")
        assert_eq 56 $(math_ceil "55.8")
        assert_eq 1 $(math_ceil "0.8")
        assert_eq 1 $(math_ceil "0.1")
        assert_eq 0 $(math_ceil "-0.8")
}
readonly -f test_math_ceil
