#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Handler related functions.

if [ -n "${HANDLER_MOD:-}" ]; then return 0; fi
readonly HANDLER_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${HANDLER_MOD}/../lang/p.sh


# ----------
# Functions.

function Handler() {
        # Handler of http requests.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r path="${1}"
        local -r script="${2}"
        local -r func="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "path" "${path}" \
              "script" "${script}" \
              "func" "${func}"
}
