#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# OS functions.

if [ -n "${LANG_OS_MOD:-}" ]; then return 0; fi
readonly LANG_OS_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${LANG_OS_MOD}/core.sh

readonly OS_LINUX="linux"
readonly OS_MAC="darwin"
readonly OS_WINDOWS="windows"
readonly OS_UNKNOWN="unknown"


# ----------
# Functions.

function os_name() {
        # Return OS name. If OS is not known, return "$OS_UNKNOWN".
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        case "${OSTYPE}" in
        linux*) echo "${OS_LINUX}";;
        darwin*) echo "${OS_MAC}";;
        win*) echo "${OS_WINDOWS}";;
        *) echo "${OS_UNKNOWN}";;
        esac
}

function os_arch() {
        # Return OS architecture.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }
        
        arch
}

function os_kill() {
        # Kills the given process.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r pid="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        kill -9 "${pid}"
}

function os_mktemp() {
        # Make a temporary file.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        core_mktemp_file "$@"
}

function os_mktemp_file() {
        # Make a temporary file.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        # No arguments to check.

        mktemp
}

function os_mktemp_dir() {
        # Make a temporary directory.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        # No arguments to check.

        mktemp -d
}

function os_remake_dir() {
        # Remake (delete and create) a directory.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r d="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        rm -rf "${d}"
        mkdir -p "${d}"

        echo "${d}"
}

function os_get_pid() {
        # Return this process id.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        "${X_BASH}" -c 'echo ${PPID}'
}
