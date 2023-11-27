#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Int related structs and functions.

if [ -n "${INT_MOD:-}" ]; then return 0; fi
readonly INT_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${INT_MOD}/core.sh
. ${INT_MOD}/make.sh


# ----------
# Functions.

function Int() {
        # An integer.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && { ctx_wn $ctx; return $EC; }
        local -r val="${1:-0}"
        shift 0 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "val" "${val}"
}

function Int_inc() {
        # Increment value.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r i="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $i $ctx val $(( $($i $ctx val) + 1 ))
}

function Int_dec() {
        # Decrement value.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r i="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $i $ctx val $(( $($i $ctx val) - 1 ))
}

function Int_gt() {
        # Return true if greater or equal to other.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r i="${1}"
        local other="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        # Support int and Int.
        if ! is_int $ctx "${other}"; then
                other=$($other $ctx val)
        fi

        [ $($i $ctx val) -gt ${other} ]
}

function Int_ge() {
        # Return true if greater or equal to other.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r i="${1}"
        local other="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        # Support int and Int.
        if ! is_int $ctx "${other}"; then
                other=$($other $ctx val)
        fi

        [ $($i $ctx val) -ge ${other} ]
}

function Int_eq() {
        # Return true if equal to other.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r i="${1}"
        local other="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        # Support int and Int.
        if ! is_int $ctx "${other}"; then
                other=$($other $ctx val)
        fi

        [ $($i $ctx val) -eq ${other} ]
}

function Int_lt() {
        # Return true if less than other.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r i="${1}"
        local other="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        # Support int and Int.
        if ! is_int $ctx "${other}"; then
                other=$($other $ctx val)
        fi

        [ $($i $ctx val) -lt ${other} ]
}

function Int_le() {
        # Return true if less than or equal to other.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r i="${1}"
        local other="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        # Support int and Int.
        if ! is_int $ctx "${other}"; then
                other=$($other $ctx val)
        fi

        [ $($i $ctx val) -le ${other} ]
}
