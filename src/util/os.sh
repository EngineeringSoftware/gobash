#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# OS util functions.

if [ -n "${UTIL_OS_MOD:-}" ]; then return 0; fi
readonly UTIL_OS_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${UTIL_OS_MOD}/time.sh
. ${UTIL_OS_MOD}/fileinfo.sh
. ${UTIL_OS_MOD}/../lang/p.sh


# ----------
# Functions.

function os_stat() {
        # Return info describing a file.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local path="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local fi
        fi=$(FileInfo $ctx "${path}") || \
                { ctx_w $ctx "could not create FileInfo"; return $EC; }

        echo "${fi}"
}

function os_timeout() {
        # Run the given command (with arguments) up to timeout. A
        # duration of 0 disables timeout.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; return $EC; }
        local -r max_secs="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${max_secs}" ] && { ctx_w $ctx "no max_secs"; return $EC; }

        # Run in background.
        ( "$@" ) &
        local -r pid=$!

        os_wait "${pid}" "${max_secs}"
}

function os_wait() {
        # Wait for the given process to complete or timeout.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r pid="${1}"
        local -r max_secs="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${pid}" ] && { ctx_w $ctx "no pid"; return $EC; }
        [ -z "${max_secs}" ] && { ctx_w $ctx "no max_secs"; return $EC; }

        if [ "${max_secs}" -gt 0 ]; then
                # Launch a process that will timeout after ${max_secs}
                # In case of timeout, kill the process and its children.
                ( sleep "${max_secs}"
                  child_pid=$(pgrep -P "${pid}" | xargs)
                  os_kill $ctx "${child_pid}"
                  os_kill $ctx "${pid}"
                ) 2> /dev/null &
        fi

        # Wait for the process, so we get the exit code.
        wait "${pid}" 2> /dev/null
}

function os_loop_n() {
        # Run the given command (with arguments) in a loop n time.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; return $EC; }
        local -r n="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local ec=0

        local i
        for (( i=0; i<${n}; i++ )); do
                "$@" || ec=$?
        done
        return ${ec}
}

function os_loop_secs() {
        # Run the given command in a loop until time expires.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; return $EC; }
        local -r secs="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local ec=0

        local -r stime=$(time_now_millis $ctx)
        while :; do
                "$@" || ec=$?

                local etime=$(time_now_millis $ctx)
                local duration=$(( ${etime} - ${stime} ))
                [ ${duration} -ge ${secs} ] && break
        done
        return ${ec}
}
