#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Util functions to manipulate binary numbers.

if [ -n "${BINARY_MOD:-}" ]; then return 0; fi
readonly BINARY_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${BINARY_MOD}/../lang/p.sh


# ----------
# Functions.

function binary_d2b() {
        # From decimal to binary.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r n="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # TODO: check for errors.
        echo "obase=2; ${n}" | bc
}

function binary_b2d() {
        # From binary to decimal.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r n="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # TODO: check for errors.
        echo "ibase=2;obase=A; ${n}" | bc
}
