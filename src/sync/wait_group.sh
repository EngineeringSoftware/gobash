#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# WaitGroup supports waiting selectively on a group of processes.

if [ -n "${WAIT_GROUP_MOD:-}" ]; then return 0; fi
readonly WAIT_GROUP_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${WAIT_GROUP_MOD}/../lang/p.sh
. ${WAIT_GROUP_MOD}/../util/list.sh

assert_function_exists List


# ----------
# Functions.

function WaitGroup() {
        # WaitGroup.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "lst" "$(List $ctx)"
}

function WaitGroup_add() {
        # Add a process id to the wait group.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r wg="${1}"
        local -r pid="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local -r lst=$($wg $ctx lst)
        $lst $ctx add "${pid}"
}

function WaitGroup_wait() {
        # Wait until processes finish.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r wg="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r lst=$($wg $ctx lst)
        [ $($lst $ctx len) -eq 0 ] && return 0

        local ec=0
        local i
        for (( i=0; i<$($lst len); i++ )); do
                local pid=$($lst $ctx get ${i})
                wait "${pid}" || ec=$?
        done

        return ${ec}
}

function WaitGroup_len() {
        # Number of process in the group.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r wg="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        echo $($($wg $ctx lst) $ctx len)
}

function WaitGroup_to_string() {
        # String representation of this group.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r wg="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $($wg $ctx lst) $ctx to_string
}
