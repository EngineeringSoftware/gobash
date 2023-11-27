#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Named pipe wrapper.
#
# @deprecated(this did not end up as planned.)

if [ -n "${PIPE_MOD:-}" ]; then return 0; fi
readonly PIPE_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${PIPE_MOD}/core.sh
. ${PIPE_MOD}/make.sh
. ${PIPE_MOD}/os.sh

readonly PIPE_END="__closed__"


# ----------
# Functions.

function Pipe() {
        # Named pipe.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local -r rawd="$(os_mktemp_dir $ctx)/fifo"
        mkfifo "${rawd}"

        make_ $ctx \
              "${FUNCNAME}" \
              "rawd" "${rawd}"
}

function Pipe_send() {
        # Send.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r pipe="${1}"
        local -r val="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        echo "${val}" >"$($pipe $ctx rawd)"
}

function Pipe_close() {
        # Close.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r pipe="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        echo "${PIPE_END}" >"$($pipe $ctx rawd)"
}

function Pipe_recv() {
        # Receive.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r pipe="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        read line <"$($pipe $ctx rawd)"
        [ "${line}" = "${PIPE_END}" ] && return $FALSE

        echo "${line}"
        return $TRUE
}
