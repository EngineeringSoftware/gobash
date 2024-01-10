#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Runtime functions.

if [ -n "${LANG_RUNTIME_MOD:-}" ]; then return 0; fi
readonly LANG_RUNTIME_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${LANG_RUNTIME_MOD}/core.sh
. ${LANG_RUNTIME_MOD}/bool.sh


# ----------
# Functions.

function runtime_num_cpu() {
        # Return the number of logical CPUs.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        if is_mac; then
                sysctl -n hw.logicalcpu_max
        else
                [ ! -f "/proc/cpuinfo" ] && \
                        { ctx_w $ctx "no cpuinfo"; return $EC; }
                cat /proc/cpuinfo | grep 'processor' | wc -l
        fi
}

function runtime_num_physical_cpu() {
        # Return the number of physical CPUs.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        if is_mac; then
                sysctl -n hw.physicalcpu_max
        else
                [ ! -f "/proc/cpuinfo" ] && \
                        { ctx_w $ctx "no cpuinfo"; return $EC; }
                cat /proc/cpuinfo  | grep 'core id' | sort -u | wc -l
        fi
}
