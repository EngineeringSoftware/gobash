#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Util functions to manipulate file paths.

if [ -n "${FILEPATH_MOD:-}" ]; then return 0; fi
readonly FILEPATH_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${FILEPATH_MOD}/../lang/p.sh


# ----------
# Functions.

function filepath_base() {
        # Return the last element on the path. If path is an empty
        # string, the output is ".".
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r path="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        if [ -z "${path}" ]; then
                echo "." || return $?
        else
                basename -- "${path}" || return $?
        fi
}

function filepath_ext() {
        # Return the extension, i.e., text after the final dot on the
        # last element of the path. It is empty if there is no dot.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r path="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r filename=$(basename -- "${path}")
        if [[ "${filename}" != *"."* ]]; then
                echo "" || return $?
        else
                local -r ext="${filename##*.}"
                echo ".${ext}" || return $?
        fi
}

function filepath_dir() {
        # Return all but the last element on path. Trailing / (one or
        # more) are ignored. If the path is empty, return ".".
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r path="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        dirname "${path}"
}

function filepath_is_abs() {
        # Return true if the path is absolute; otherwise false.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r path="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [[ "${path}" = /* ]]
}
