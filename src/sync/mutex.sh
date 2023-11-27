#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Mutex related structs and functions.

if [ -n "${MUTEX_MOD:-}" ]; then return 0; fi
readonly MUTEX_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${MUTEX_MOD}/../lang/p.sh

readonly MUTEX_SLEEP_TIME=0.01


# ----------
# Functions.

function Mutex() {
        # Mutex.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "mud" "$(os_mktemp_dir $ctx)/mutex"
}

function Mutex_lock() {
        # Lock.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r mu="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r mud=$($mu $ctx mud)
        # Can do better than busy waiting.
        while :; do
                if mkdir "${mud}" 2>/dev/null; then
                        break
                fi
                sleep "${MUTEX_SLEEP_TIME}"
        done
        # Hoding the lock.
}

function Mutex_unlock() {
        # Unlock.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r mu="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        rm -rf "$($mu $ctx mud)"
}
