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
        
        [ "${ms}" -le 1689708545316 ] && assert_fail
        return 0
}
readonly -f test_now_millis

function test_time_now_day_of_week() {
        local day
        day=$(time_now_day_of_week) || \
                assert_fail

        [ "${day}" -lt 0 ] && assert_fail
        [ "${day}" -gt 8 ] && assert_fail
        return 0
}
readonly -f test_time_now_day_of_week

function test_time_now_day_of_week_str() {
        local day
        day=$(time_now_day_of_week_str) || \
                assert_fail

        case "${day}" in
        "Monday"|"monday") ;;
        "Tuesday"|"tuesday") ;;
        "Wednesday"|"wednesday") ;;
        "Thursday"|"thursday") ;;
        "Friday"|"friday") ;;
        "Saturday"|"saturday") ;;
        "Sunday"|"sunday") ;;
        *) assert_fail "non-existing day of the week";;
        esac
}
readonly -f test_time_now_day_of_week_str

function test_time_now_day_of_month() {
        local day
        day=$(time_now_day_of_month) || \
                assert_fail

        [ "${day}" -lt 0 ] && assert_fail
        [ "${day}" -gt 32 ] && assert_fail
        return 0
}
readonly -f test_time_now_day_of_month

function test_time_now_year() {
        local year
        year=$(time_now_year) || \
                assert_fail
        
        [ "$($X_DATE +%Y)" != "${year}" ] && assert_fail "$($X_DATE +%Y) not equal to ${year}"
        return 0
}
readonly -f test_time_now_year

function test_time_now_month() {
        local month
        month=$(time_now_month) || \
                assert_fail

        [ "$($X_DATE +%m)" != "${month}" ] && assert_fail "$($X_DATE +%Y) not equal to ${year}"
        return 0
}
readonly -f test_time_now_month

function test_time_now_month_str() {
        local month
        month=$(time_now_month_str) || \
                assert_fail
                
        case "${month}" in
        "Jan"|"January") ;;
        "Feb"|"February") ;;
        "Mar"|"March") ;;
        "Apr"|"April") ;;
        "May") ;;
        "Jun"|"June") ;;
        "Jul"|"July") ;;
        "Aug"|"August") ;;
        "Sep"|"September") ;;
        "Oct"|"October") ;;
        "Nov"|"November") ;;
        "Dec"|"December") ;;
        *) assert_fail "non-existent month";;
        esac
}
readonly -f test_time_now_month_str

function test_time_duration() {
        function _f() {
                return 22
        }

        local ec=0
        time_duration_w "ABC" _f > /dev/null || ec=$?
        
        [ ${ec} -ne 22 ] && assert_fail
        return 0
}
readonly -f test_time_duration

function test_time_millis_to_seconds() {
        local secs
        secs=$(time_millis_to_seconds 2000) || \
                assert_fail
        
        [ ${secs} -ne 2 ] && assert_fail
        return 0
}
readonly -f test_time_millis_to_seconds

function test_time_millis_to_date() {
        local actual
        actual=$(time_millis_to_date "1670357961396") || \
                assert_fail

        [ "2022-12-06" != "${actual% *}" ] && assert_fail
        return 0
}
readonly -f test_time_millis_to_date

function test_time_num_to_month() {
        [ "Mar" != "$(time_num_to_month 3)" ] && assert_fail

        local ctx

        ctx=$(ctx_make)
        time_num_to_month $ctx 14 && \
                assert_fail
        ctx_show $ctx | grep 'incorrect month number' || \
                assert_fail
        return 0
}
readonly -f test_time_num_to_month

function test_time_month_to_num() {
        [ 3 -ne  $(time_month_to_num "Mar") ] && assert_fail

        local ctx

        ctx=$(ctx_make)
        time_month_to_num $ctx "abc" && \
                assert_fail
        ctx_show $ctx | grep 'incorrect month name' || \
                assert_fail
}
readonly -f test_time_month_to_num
