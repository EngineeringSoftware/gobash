#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Util char functions.

if [ -n "${CHAR_MOD:-}" ]; then return 0; fi
readonly CHAR_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${CHAR_MOD}/../lang/p.sh


# ----------
# Functions.

function char_alphabet() {
        # Print alphabet on a single line.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        echo {a..z}
}
