#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Communication channel related structs and functions.

if [ -n "${CHAN_MOD:-}" ]; then return 0; fi
readonly CHAN_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${CHAN_MOD}/../lang/p.sh
. ${CHAN_MOD}/../util/list.sh
. ${CHAN_MOD}/mutex.sh
. ${CHAN_MOD}/atomic_int.sh

CHAN_SLEEP_TIME=0.1


# ----------
# Functions.

function Chan() {
        # Channel.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local d
        d=$(os_mktemp_dir $ctx) || { ctx_w $ctx "cannot make dir"; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "d" "${d}" \
              "ais" "$(AtomicInt $ctx)" \
              "air" "$(AtomicInt $ctx)"
}

function Chan_send() {
        # Send a value.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r ch="${1}"
        local -r val="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local ix
        ix=$($($ch $ctx ais) $ctx inc) || \
                { ctx_w $ctx "cannot inc"; return $EC; }

        local -r d=$($ch $ctx d)
        local -r valf="${d}/${ix}.val"
        echo "$val" > "${valf}"
        local -r sendf="${d}/${ix}.ch"
        # Has to be created after we wrote the value.
        touch "${sendf}"

        while :; do
                [ ! -f "${sendf}" ] && break
                sleep "${CHAN_SLEEP_TIME}"
        done
}

function Chan_recv() {
        # Receive a value.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r ch="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local ix
        ix=$($($ch $ctx air) $ctx inc) || \
                { ctx_w $ctx "cannot inc"; return $EC; }

        local -r d=$($ch $ctx d)
        local -r valf="${d}/${ix}.val"
        local -r recvf="${d}/${ix}.ch"
        local -r closef="${d}/close"

        while :; do
                if [ -f "${recvf}" ]; then
                        local val=$(cat "${valf}")
                        rm -f "${valf}"
                        rm -f "${recvf}"
                        echo "${val}"
                        break
                fi

                # No values, so check if closed.
                if [ -f "${closef}" ]; then
                        return $FALSE
                fi

                sleep "${CHAN_SLEEP_TIME}"
        done

        return 0
}

function Chan_close() {
        # Close the channel.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r ch="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r d=$($ch $ctx d)
        local -r closef="${d}/close"
        touch "${closef}"
}
