#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Core constants, variables, and functions.

if [ -n "${CORE_MOD:-}" ]; then return 0; fi
readonly CORE_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${CORE_MOD}/x.sh

readonly EC=255
readonly NULL="null"
readonly TRUE=0
readonly FALSE=1

# Types.
readonly INT="int"
readonly BOOL="bool"
readonly FLOAT="float"
readonly STRING="string"

# Directory for gobash files.
readonly _CORE_OBJ_DIR="${CORE_MOD}/../../.objects"

# File for global context.
readonly _CORE_GLOBAL_CONTEXT="${_CORE_OBJ_DIR}/context.txt"
# File for global stack trace.
readonly _CORE_GLOBAL_STACKTRACE="${_CORE_OBJ_DIR}/strace.txt"


# ----------
# Functions.

function core_obj_dir() {
        # Dir for gobash files.
        [ $# -ne 0 ] && return $EC
        shift 0 || return $EC

        echo "${_CORE_OBJ_DIR}"
}

# TODO: make it into a variable.
function core_tmp_dir() {
        # Temporary directory.
        [ $# -ne 0 ] && return $EC
        shift 0 || return $EC

        local d
        d=$(mktemp -d) || return $EC
        dirname "${d}"
}

function core_mktemp_file() {
        # Make a temporary file.
        [ $# -ne 3 ] && return $EC
        local -r tmpd="${1}"
        local -r template="${2}"
        local -r suffix="${3}"
        shift 3 || return $EC

        [ -z "${tmpd}" ] && return $EC
        [ -z "${template}" ] && return $EC
        [ -z "${suffix}" ] && return $EC

        # No-atomic (cannot use --suffix or --tmpdir).
        f=$(mktemp "${tmpd}/${template}") || return $EC
        mv "${f}" "${f}${suffix}"
        echo "${f}${suffix}"
}

function ctx_make() {
        # Make a context.
        [ $# -lt 0 ] && return $EC
        shift 0 || return $EC

        local f
        # Non-atomic (to avoid --suffix).
        f=$(core_mktemp_file "${_CORE_OBJ_DIR}" "tmp.XXXX" ".ctx")
        local -r id=$(basename "${f}" ".ctx")

        # Make the file that will also have traces.
        touch "${_CORE_OBJ_DIR}/${id}.strace"

        echo "${id}"
}
readonly -f ctx_make
export -f ctx_make

function is_ctx() {
        # Check if it is a valid context.
        [ $# -lt 0 ] && return $EC
        local -r ctx="${1}"
        shift 0 || return $EC

        # Has to be 1 (or export any variable used for false).
        [[ "${ctx}" != "tmp"* ]] && return 1

        local -r f="${_CORE_OBJ_DIR}/${ctx}.ctx"
        [ -f "${f}" ]
}
readonly -f is_ctx
export -f is_ctx

function ctx_w() {
        # Record a message.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && return $EC
        local msg="${1}"
        shift 0 || return $EC

        local f="${_CORE_OBJ_DIR}/${ctx}.ctx"
        if [ ! -f "${f}" ]; then
                f="${_CORE_GLOBAL_CONTEXT}"
        fi

        if [ -z "${msg}" ]; then
                msg="Message not provided."
        fi
        echo "${msg}" >> "${f}"

        local f="${_CORE_OBJ_DIR}/${ctx}.strace"
        if [ ! -f "${f}" ]; then
                f="${_CORE_GLOBAL_STACKTRACE}"
        fi

        echo "${msg}" >> "${f}"
        # Stack.
        ( local -i i=0
          while :; do
                  caller "${i}" || break
                  i=$(( ${i} + 1 ))
          done
        ) >> "${f}"
}
readonly -f ctx_w
export -f ctx_w

function ctx_wn() {
        # Record error with number of arguments.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && return $EC
        shift 0 || return $EC

        ctx_w $ctx "incorrect number of arguments"
}
readonly -f ctx_wn
export -f ctx_wn

function ctx_wa() {
        # Record error with an argument.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && return $EC
        local -r aname="${1}"
        shift 0 || return $EC

        ctx_w $ctx "incorrect argument ${aname}"
}
readonly -f ctx_wa
export -f ctx_wa

function ctx_show() {
        # Print context.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && return $EC
        shift 0 || return $EC

        local f="${_CORE_OBJ_DIR}/${ctx}.ctx"
        local is_global=$FALSE
        if [ ! -f "${f}" ]; then
                f="${_CORE_GLOBAL_CONTEXT}"
                is_global=$TRUE
        fi

        if [ -f "${f}" ]; then
                cat "${f}"
        fi

        if [ "${is_global}" = $TRUE ] ; then
                printf "check the global context if needed\n"
        else
                printf "check the following context if needed: $ctx\n"
        fi

        return 0
}
readonly -f ctx_show
export -f ctx_show

function ctx_stack() {
        # Print stack trace.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && return $EC
        shift 0 || return $EC

        local f="${_CORE_OBJ_DIR}/${ctx}.strace"
        if [ ! -f "${f}" ]; then
                f="${_CORE_GLOBAL_STACKTRACE}"
        fi

        if [ -f "${f}" ]; then
                cat "${f}"
        fi

        return 0
}
readonly -f ctx_stack
export -f ctx_stack

function ctx_clear() {
        # Clear context.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && return $EC
        shift 0 || return $EC

        local f="${_CORE_OBJ_DIR}/${ctx}.txt"
        if [ ! -f "${f}" ]; then
                f="${_CORE_GLOBAL_CONTEXT}"
        fi
        > "${f}"

        local f="${_CORE_OBJ_DIR}/${ctx}.strace"
        if [ ! -f "${f}" ]; then
                f="${_CORE_GLOBAL_STACKTRACE}"
        fi
        > "${f}"
}
readonly -f ctx_clear
export -f ctx_clear
