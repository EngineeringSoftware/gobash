#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Request related structs and functions.

if [ -n "${REQUEST_MOD:-}" ]; then return 0; fi
readonly REQUEST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${REQUEST_MOD}/../lang/p.sh


# ----------
# Functions.

function Request() {
        # Http request.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 4 ] && { ctx_wn $ctx; return $EC; }
        local -r method="${1}"
        local -r path="${2}"
        local -r proto="${3}"
        local -r rawf="${4}"
        shift 4 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "method" "${method}" \
              "proto" "${proto}" \
              "path" "${path}" \
              "rawf" "${rawf}"
}

function request_parse() {
        # Parse http request.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local -r rawf=$(os_mktemp_file $ctx)
        _request_read $ctx "${rawf}" ||
                { ctx_w $ctx "fail read"; return $EC; }

        local -r method=$(head -n 1 "${rawf}" | $X_CUT -f1 -d' ')
        local -r path=$(head -n 1 "${rawf}" | $X_CUT -f2 -d' ')
        local -r proto=$(head -n 1 "${rawf}" | $X_CUT -f3 -d' ')

        case ${method} in
        GET) ;;
        PUT) ;;
        DELETE) ;;
        POST) ;;
        PATCH) ;;
        *) { ctx_w $ctx "incorrect method"; return $EC; } ;;
        esac

        # TODO(milos): more parsing.

        local req
        req=$(Request $ctx "${method}" "${path}" "${proto}" "${rawf}") || \
                { ctx_w $ctx "cannot make request"; return $EC; }

        echo "${req}"
}

function _request_read() {
        # Read request into a file.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r rawf="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        ! is_file $ctx "${rawf}" && return $EC

        while :; do
                read l
                l=$(echo "${l}" | sed 's///')
                [ -z "${l}" ] && break
                echo "${l}" >> "${rawf}"
        done
}
