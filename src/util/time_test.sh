#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Unit tests for the time module.

if [ -n "${TIME_TEST_MOD:-}" ]; then return 0; fi
readonly TIME_TEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${TIME_TEST_MOD}/time.sh
. ${TIME_TEST_MOD}/../testing/bunit.sh


# ----------
# Functions.

function test_now_millis() {
        local ms
        ms=$(time_now_millis) || \
                assert_fail
        assert_ge "${ms}" 1689708545316
}
readonly -f test_now_millis

function test_time_now_day() {
        local day
        day=$(time_now_day) || \
                assert_fail
        assert_gt "${day}" 0
        assert_lt "${day}" 8
}
readonly -f test_time_now_day

function test_time_now_year() {
        local year
        year=$(time_now_year) || \
                assert_fail
        assert_eq "$($X_DATE +%Y)" "${year}"
}
readonly -f test_time_now_year

function test_time_now_month() {
        local month
        month=$(time_now_month) || \
                assert_fail
        assert_eq "$($X_DATE +%m)" "${month}"
}
readonly -f test_time_now_month

function test_time_duration() {
        function _f() {
                return 22
        }

        local ec=0
        time_duration_w "ABC" _f > /dev/null || ec=$?
        assert_eq 22 ${ec}
}
readonly -f test_time_duration

function test_time_millis_to_seconds() {
        local secs
        secs=$(time_millis_to_seconds 2000) || \
                assert_fail
        assert_eq 2 "${secs}"
}
readonly -f test_time_millis_to_seconds

function test_time_millis_to_date() {
        local actual
        actual=$(time_millis_to_date "1670357961396") || \
                assert_fail
        assert_eq "2022-12-06" "${actual% *}"
}
readonly -f test_time_millis_to_date

function test_time_num_to_month() {
        assert_eq "Mar" $(time_num_to_month 3)

        local ctx

        ctx=$(ctx_make)
        time_num_to_month $ctx 14 && \
                assert_fail
        ctx_show $ctx | grep 'incorrect month number' || \
                assert_fail
}
readonly -f test_time_num_to_month

function test_time_month_to_num() {
        assert_eq 3 $(time_month_to_num "Mar")

        local ctx

        ctx=$(ctx_make)
        time_month_to_num $ctx "abc" && \
                assert_fail
        ctx_show $ctx | grep 'incorrect month name' || \
                assert_fail
}
readonly -f test_time_month_to_num
