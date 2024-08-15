#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Random value generators.

if [ -n "${RAND_MOD:-}" ]; then return 0; fi
readonly RAND_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${RAND_MOD}/../lang/p.sh


# ----------
# Functions.

function rand_bool() {
        # Generate random bool.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        # No arguments to check.

        echo $(( ${RANDOM} % 2 ))
}

function rand_return() {
        # Return (`return`) randomly 0 or 1. This can be convenient to
        # use in if statements.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        # No arguments to check.

        [ $(rand_bool) = 1 ]
}

function rand_args() {
        # Return random argument given to this function.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -eq 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        # No arguments to check.

        local vals=( $@ )
        local len=${#vals[@]}
        local ix=$(( $RANDOM % len ))
        echo "${vals[${ix}]}"
}

function rand_int() {
        # Generate random int.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        # No arguments to check.

        echo "${RANDOM}"
}

function rand_intn() {
        # Generate random int up to (but excluding) the given value.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        # Max value to generate (excluding the value itself).
        local -r max="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${max}" ] && { ctx_wa $ctx "max"; return $EC; }
        [ ${max} -le 0 ] && { ctx_wa $ctx "max"; return $EC; }

        local -r delta=$(( ${max} + 1 ))

        local val=$(rand_int $ctx)
        val=$(( ${val} % ${max} ))

        echo "${val}"
}

function rand_string() {
        # Generate random string up to the given length.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && { ctx_wn $ctx; return $EC; }
        # Length of the string to generate (max 32).
        local -r -i len="${1:-32}"
        shift 0 || { ctx_wn $ctx; return $EC; }

        [ -z "${len}" ] && { ctx_wa $ctx "len"; return $EC; }

        [ ${len} -le 1 -o ${len} -gt 32 ] && { ctx_wa $ctx "len"; return $EC; }

        echo "${RANDOM}" | $X_MD5 | head -c "${len}"; echo
}
