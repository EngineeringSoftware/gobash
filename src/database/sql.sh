#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# SQL support (experimental).

if [ -n "${SQL_MOD:-}" ]; then return 0; fi
readonly SQL_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${SQL_MOD}/../lang/p.sh


# ----------
# Functions.

function SQLite() {
        # SQL driver.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r path="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        ! is_exe $ctx "sqlite3" && \
                { ctx_w $ctx "no sqlite3"; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "path" "${path}"
}

function SQLite_query() {
        # Query db.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r db="${1}"
        local -r query="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local -r path=$($db $ctx path)
        sqlite3 "${path}" "${query}"
}

function sql_connect() {
        # Connect to a database using the given driver.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r driver="${1}"
        local -r path="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        case "${driver}" in
        "sqlite3") SQLite $ctx "${path}"; return $?;;
        *) { ctx_w $ctx "unknown driver"; return $EC; }
        esac
}
