#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Util for carrying UI results.
# TODO: do we need this or just use Result?

if [ -n "${UI_MOD:-}" ]; then return 0; fi
readonly UI_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


# ----------
# Functions.

function UIResult() {
        # UI result.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "_err" "${NULL}" \
              "_val" "${NULL}" \
              "_cancelled" "$FALSE"
}

function UIResult_val() {
        # Get the value.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $res $ctx _val
}

function UIResult_is_cancelled() {
        # Return true if it was cancelled.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        is_true $ctx $($res $ctx _cancelled)
}
