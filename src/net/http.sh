#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# http related structs and functions.

if [ -n "${HTTP_MOD:-}" ]; then return 0; fi
readonly HTTP_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${HTTP_MOD}/handler.sh
. ${HTTP_MOD}/../lang/p.sh
. ${HTTP_MOD}/../util/list.sh
. ${HTTP_MOD}/../util/os.sh


# ----------
# Functions.

function http_enabled() {
        # Return true/0 if this module is enabled; otherwise false/1.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        ! is_exe $ctx "ncat" && { ctx_w $ctx "no ncat"; return $FALSE; }

        return $TRUE
}

function Http() {
        # Http.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r address="${1}"
        local -r port="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${address}" ] && { ctx_w $ctx "no address"; return $EC; }
        [ -z "${port}" ] && { ctx_w $ctx "no port"; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "address" "${address}" \
              "port" "${port}" \
              "handlers" "$(List $ctx)" \
              "pid" "${NULL}"
}

function Http_handle_func() {
        # Handle the given function for the given path.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 4 ] && { ctx_wn $ctx; return $EC; }
        local -r http="${1}"
        local -r path="${2}"
        local -r script="${3}"
        local -r func="${4}"
        shift 4 || { ctx_wn $ctx; return $EC; }

        [ -z "${path}" ] && { ctx_w $ctx "no path"; return $EC; }
        [ -z "${script}" ] && { ctx_w $ctx "no script"; return $EC; }
        ! is_file $ctx "${script}" && { ctx_w $ctx "incorrect script"; return $EC; }
        [ -z "${func}" ] && { ctx_w $ctx "no func"; return $EC; }
        ! is_function $ctx "${func}" && { ctx_w $ctx "incorrect func"; return $EC; }

        local h
        h=$(Handler $ctx "${path}" "${script}" "${func}") || \
                { ctx_w $ctx "cannot make handler"; return $EC; }

        $($http $ctx handlers) $ctx add "$h"
}

function Http_listen_and_serve() {
        # Listen and serve requests (starts one background process).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r http="${1}"
        shift 0 || { ctx_wn $ctx; return $EC; }

        ! is_instanceof $ctx "$http" Http && \
                { ctx_w $ctx "incorrect arg"; return $EC; }

        ncat -l \
             --keep-open \
             "$($http $ctx address)" \
             "$($http $ctx port)" \
             -c "${HTTP_MOD}/response $($http $ctx handlers)" &
        $http $ctx pid "$!"
}

function Http_wait() {
        # Wait for the server to complete work.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r http="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        ! is_instanceof $ctx "$http" Http && \
                { ctx_w $ctx "incorrect arg"; return $EC; }

        local -r pid=$($http $ctx pid)
        wait "${pid}"
}

function Http_listen_and_serve_and_wait() {
        # Listen, server, and wait for the process.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r http="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $http $ctx listen_and_serve
        $http $ctx wait
}

function Http_kill_and_wait() {
        # Kill the background process and wait to be done.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r http="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        ! is_instanceof $ctx "$http" Http && \
                { ctx_w "incorrect arg"; return $EC; }

        local -r pid=$($http $ctx pid)
        disown "${pid}"
        os_kill $ctx "${pid}"
        wait "${pid}"
}
