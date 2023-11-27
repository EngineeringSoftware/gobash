#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Response related structs and functions.

if [ -n "${RESPONSE_MOD:-}" ]; then return 0; fi
readonly RESPONSE_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${RESPONSE_MOD}/../lang/p.sh


# ----------
# Functions.

function Response() {
        # Response to http request.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r -i code="${1}"
        local -r info="${2}"
        local -r proto="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "code" "${code}" \
              "info" "${info}" \
              "proto" "${proto}" \
              "rawf" "${NULL}"
}

function Response_write() {
        # Buffer the string into the response.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        local -r str="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        if is_null $ctx "$($res $ctx rawf)"; then
                $res $ctx rawf "$(os_mktemp_file $ctx)"
        fi
        printf "${str}" >> "$($res $ctx rawf)"
}

function Response_to_string() {
        # String version of the response.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r res="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local prefix="$($res $ctx proto) $($res $ctx code) $($res $ctx info)\n"

        if is_null $ctx "$($res $ctx rawf)"; then
                printf "${prefix}"
        else
                printf "${prefix}\n$(cat $($res $ctx rawf))\n"
        fi
}

function response_make_bad_request() {
        # Create a response for 400.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        # No arguments to check.

        Response $ctx 400 "Bad Request" "HTTP/1.1"
}

function response_make_not_found() {
        # Create a response for 404.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        # No arguments to check.

        Response $ctx 404 "Not Found" "HTTP/1.1"
}

function response_make_ok() {
        # Create a response for 200.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        # No arguments to check.

        Response $ctx 200 "OK" "HTTP/1.1"
}

function response_make_internal_server_error() {
        # Create a response for 500.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        # No arguments to check.

        Response $ctx 500 "Internal Server Error" "HTTP/1.1"
}
