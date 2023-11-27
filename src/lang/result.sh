#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Utility for collecting results from a function invocation.

if [ -n "${RESULT_MOD:-}" ]; then return 0; fi
readonly RESULT_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${RESULT_MOD}/core.sh
. ${RESULT_MOD}/make.sh


# ----------
# Functions.

function Result() {
        # Result.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 -o $# -gt 1 ] && { ctx_wn $ctx; return $EC; }
        local -r val="${1:-${NULL}}"
        shift 0 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "val" "${val}"
}

function Result_has_value() {
        # True if value is set.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ "${NULL}" = "$($res $ctx val)" ] && return $FALSE
        return $TRUE
}

function Result_to_string() {
        # String representation of the result.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        if Result_has_value $ctx "$res"; then
                if unsafe_is_object $ctx "$($res val)"; then
                        $($res $ctx val) $ctx to_string
                else
                        echo "$($res $ctx val)"
                fi
        else
                local uid=$($res)
                unsafe_to_string $ctx "${uid}"
        fi

        return 0
}
