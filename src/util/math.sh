#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Math util functions.

if [ -n "${MATH_MOD:-}" ]; then return 0; fi
readonly MATH_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${MATH_MOD}/../lang/p.sh

readonly MATH_PI=$(echo "4*a(1)" | bc -l)
readonly MATH_SCALE=4


# ----------
# Functions.

function math_enabled() {
        # Return true if this module is enabled.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        ! is_exe "echo" && { ctx_w $ctx "no echo"; return $FALSE; }
        ! is_exe "shift" && { ctx_w $ctx "no shift"; return $FALSE; }
        ! is_exe "bc" && { ctx_w $ctx "no bc"; return $FALSE; }

        return $TRUE
}

function math_max() {
        # Return max of two numbers (ints only).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r a="${1}"
        local -r b="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${a}" ] && { ctx_w $ctx "no a"; return $EC; }
        [ -z "${b}" ] && { ctx_w $ctx "no b"; return $EC; }

        if [[ ${a} -gt ${b} ]]; then
                echo "${a}"
        else
                echo "${b}"
        fi
        return 0
}

function math_min() {
        # Return min of two numbers (ints only).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r a="${1}"
        local -r b="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${a}" ] && { ctx_w $ctx "no a"; return $EC; }
        [ -z "${b}" ] && { ctx_w $ctx "no b"; return $EC; }

        if [[ ${a} -gt ${b} ]]; then
                echo "${b}"
        else
                echo "${a}"
        fi
        return 0
}

function math_non_zero() {
        # Return non-zero value if one is non-zero.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r a="${1}"
        local -r b="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${a}" ] && { ctx_w $ctx "no a"; return $EC; }
        [ -z "${b}" ] && { ctx_w $ctx "no b"; return $EC; }

        [ ${a} -eq 0 ] && echo "${b}"
        echo "${a}"
}

function math_sin() {
        # Return sin(x).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r x="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${x}" ] && { ctx_w $ctx "no x"; return $EC; }

        echo "s (${x})" | bc -l
}

function math_cos() {
        # Return cos(x).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r x="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${x}" ] && { ctx_w $ctx "no x"; return $EC; }

        echo "c (${x})" | bc -l
}

function math_log() {
        # Natural logarithm of the given number.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        # Input value for the log function.
        local -r x="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${x}" ] && { ctx_w $ctx "no x"; return $EC; }

        echo "l (${x})" | bc -l
}

function math_sqrt() {
        # Return sqrt(x).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r x="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${x}" ] && { ctx_w $ctx "no x"; return $EC; }

        bc <<< "scale=${MATH_SCALE}; sqrt( ${x} )"
}

function math_pow() {
        # Return pow(x, y).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r x="${1}"
        local -r y="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${x}" ] && { ctx_w $ctx "no x"; return $EC; }
        [ -z "${y}" ] && { ctx_w $ctx "no y"; return $EC; }

        bc <<< "scale=${MATH_SCALE}; ${x} ^ ${y}"
}

function math_lt() {
        # Return true if x < y.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r x="${1}"
        local -r y="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${x}" ] && { ctx_w $ctx "no x"; return $EC; }
        [ -z "${y}" ] && { ctx_w $ctx "no y"; return $EC; }

        local v=$(bc -l <<< "${x} < ${y}")
        [ ${v} -ne 0 ]
}

function math_le() {
        # Return true if x <= y.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r x="${1}"
        local -r y="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${x}" ] && { ctx_w $ctx "no x"; return $EC; }
        [ -z "${y}" ] && { ctx_w $ctx "no y"; return $EC; }

        local v=$(bc -l <<< "${x} <= ${y}")
        [ ${v} -ne 0 ]
}

function math_gt() {
        # Return true if x > y.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r x="${1}"
        local -r y="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${x}" ] && { ctx_w $ctx "no x"; return $EC; }
        [ -z "${y}" ] && { ctx_w $ctx "no y"; return $EC; }

        local v=$(bc -l <<< "${x} > ${y}")
        [ ${v} -ne 0 ]
}

function math_ge() {
        # Return true if x >= y.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r x="${1}"
        local -r y="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${x}" ] && { ctx_w $ctx "no x"; return $EC; }
        [ -z "${y}" ] && { ctx_w $ctx "no y"; return $EC; }

        local res=$(bc -l <<< "${x} >= ${y}")
        [ ${res} -ne 0 ]
}

function math_calc() {
        # Compute given math expression.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r exp="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${exp}" ] && { ctx_w $ctx "no exp"; return $EC; }

        # TODO: get error from stderr?
        bc -l <<< "scale=${MATH_SCALE}; ${exp}"
}

function math_n_percent_n() {
        # Compute one number as a percent of another number.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r one="${1}"
        local -r two="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${one}" ] && { ctx_w $ctx "no one"; return $EC; }
        [ -z "${two}" ] && { ctx_w $ctx "no two"; return $EC; }

        math_calc $ctx "${one} * 100 / ${two}"
}

function math_percent_of() {
        # Computer x percent of the given number.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r x="${1}"
        local -r val="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${x}" ] && { ctx_w $ctx "no x"; return $EC; }
        [ -z "${val}" ] && { ctx_w $ctx "no val"; return $EC; }

        math_calc $ctx "${x} * ${val} / 100"
}

function math_floor() {
        # Return floor of a number.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local val="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${val}" ] && { ctx_w $ctx "no val"; return $EC; }

        local res

        if [ "${val:0:1}" = "-" ]; then
                val=${val#-}
                res=$(math_ceil $ctx "${val}")
                math_calc $ctx "${res} * (-1)" || return $?
                return 0
        fi

        res=$(bc -l <<< "scale=0; ${val} / 1")
        echo "${res}"
}

function math_ceil() {
        # Return ceil of a number.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local val="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${val}" ] && { ctx_w $ctx "no val"; return $EC; }

        local res

        if [ "${val:0:1}" = "-" ]; then
                val=${val#-}
                res=$(math_floor $ctx "${val}")
                math_calc $ctx "${res} * (-1)" || return $?
                return 0
        fi

        res=$(bc -l <<< "scale=0; ( ${val} + 1 ) / 1")
        echo "${res}"
}
