#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Util time functions.

if [ -n "${TIME_MOD:-}" ]; then return 0; fi
readonly TIME_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${TIME_MOD}/../lang/p.sh


# ----------
# Functions.

function time_now_millis() {
        # Current time in milliseconds.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local -r os=$(os_name)
        if [ "${os}" = "${OS_MAC}" ]; then
                $X_DATE +%s000 || return $EC
        else
                echo $(($($X_DATE +%s%N)/1000000)) || return $EC
        fi
}

function time_now_week_day() {
        # Current day of the week (as a number: 1-Mon, ... 7-Sun).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        $X_DATE +%u
}

function time_now_week_day_str() {
        # Current day of the week (as a string: Monday, ... Sunday).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        $X_DATE +%A
}

function time_now_month_day() {
        # Current day of the month.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        $X_DATE +%e
}

function time_now_year() {
        # Current year.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        $X_DATE +%Y
}

function time_now_month() {
        # Current month (as a number).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        $X_DATE +%m
}

function time_now_month_str() {
        # Current month (as a full string, e.g., January).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        $X_DATE +%B
}

function time_now_iso8601() {
        # Current time in ISO 8601 format.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local -r os=$(os_name)
        if [ "${os}" = "${OS_MAC}" ]; then
                $X_DATE -u +"%Y-%m-%dT%H:%M:%SZ" || return $EC
        else
                $X_DATE -Is || return $EC
        fi
}

function time_millis_to_date() {
        # Return date format for the given number in milliseconds.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r -i millis="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r os=$(os_name)
        if [ "${os}" = "${OS_MAC}" ]; then
                local -r secs=$(( ${millis} / 1000 ))
                $X_DATE -r "${secs}" +"%Y-%m-%d %H:%M:%S" || return $EC
        else
                local -r as_date=$($X_DATE -d @$( echo "(${millis} + 500) / 1000" | bc))
                $X_DATE -d "${as_date}" +"%Y-%m-%d %H:%M:%S" || return $EC
        fi
}

function time_seconds_to_date() {
        # Convert from seconds to date format.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r seconds="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r as_date=$($X_DATE -d @"${seconds}")
        $X_DATE -d "${as_date}" +"%Y-%m-%d %H:%M:%S"
}

function time_millis_to_seconds() {
        # Convert milliseconds to seconds.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r millis="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        echo "${millis} / 1000" | bc
}

function time_duration_w() {
        # Prints duration to execute the given command.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; return $EC; }
        local -r marker="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${marker}" ] && { ctx_w $ctx "no marker"; return $EC; }

        local -r start=$(time_now_millis $ctx)
        local ec=0
        "$@" || ec=$?
        local -r endt=$(time_now_millis $ctx)
        echo "${marker}: $(( ${endt} - ${start} ))ms"

        return ${ec}
}

function time_num_to_month() {
        # Convert a number to month string.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r -i num="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${num}" ] && { ctx_w $ctx "no num"; return $EC; }

        case "${num}" in
        1|01) echo "Jan";;
        2|02) echo "Feb";;
        3|03) echo "Mar";;
        4|04) echo "Apr";;
        5|05) echo "May";;
        6|06) echo "Jun";;
        7|07) echo "Jul";;
        8|08) echo "Aug";;
        9|09) echo "Sep";;
        10) echo "Oct";;
        11) echo "Nov";;
        12) echo "Dec";;
        *) { ctx_w $ctx "incorrect month number"; return $EC; };;
        esac

        return 0
}

function time_month_to_num() {
        # Convert month (as a string) to number.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local str="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${str}" ] && { ctx_w $ctx "no str"; return $EC; }

        case "${str}" in
        "Jan"|"January") echo 1;;
        "Feb"|"February") echo 2;;
        "Mar"|"March") echo 3;;
        "Apr"|"April") echo 4;;
        "May") echo 5;;
        "Jun"|"June") echo 6;;
        "Jul"|"July") echo 7;;
        "Aug"|"August") echo 8;;
        "Sep"|"September") echo 9;;
        "Oct"|"October") echo 10;;
        "Nov"|"November") echo 11;;
        "Dec"|"December") echo 12;;
        *) { ctx_w $ctx "incorrect month name"; return $EC; };;
        esac

        return 0
}
