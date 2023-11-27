#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# FileInfo.

if [ -n "${FILEINFO_MOD:-}" ]; then return 0; fi
readonly FILEINFO_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${FILEINFO_MOD}/../lang/p.sh


# ----------
# Functions.

function FileInfo() {
        # FileInfo struct.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r path="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -f "${path}" ] || \
                { ctx_w $ctx "incorrect path"; return $EC; }

        # TODO: capture all info here at the time of construction?
        make_ $ctx \
              "${FUNCNAME}" \
              "path" "${path}"
}

function FileInfo_name() {
        # Basename of the file.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r fi="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        basename "$($fi path)"
}

function FileInfo_size() {
        # Length in bytes (unknown for non-regular files).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r fi="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r os=$(os_name)
        if [ "${os}" = "${OS_MAC}" ]; then
                stat -f "%z" "$($fi path)" || return $EC
        else
                stat --printf="%s\n" "$($fi path)" || return $EC
        fi
}

function FileInfo_mode() {
        # Mode bits for the file.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r fi="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        ls -la "$($fi path)" | $X_CUT -f1 -d' '
}

function FileInfo_mod_time() {
        # Modification time.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r fi="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $X_DATE -r "$($fi path)" "+%Y-%m-%d %H:%M:%S.%N %z %Z"
}

function FileInfo_is_dir() {
        # Return true if directory.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r fi="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -d "$($fi path)" ]
}

function FileInfo_to_string() {
        # String format.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r fi="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $fi $ctx name
        $fi $ctx size
        $fi $ctx mode
        $fi $ctx mod_time
}
