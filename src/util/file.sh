#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# File util functions.

if [ -n "${FILE_MOD:-}" ]; then return 0; fi
readonly FILE_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${FILE_MOD}/fileinfo.sh
. ${FILE_MOD}/../lang/p.sh


# ----------
# Functions.

function file_enabled() {
        # Check if this module is enabled.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        ! is_exe $ctx "stat" && return $FALSE
        ! is_exe $ctx "ls" && return $FALSE
        ! is_exe $ctx "date" && return $FALSE

        return $TRUE
}

function file_newlines() {
        # Return the number of new lines in the file.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r pathf="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${pathf}" ] && { ctx_wa $ctx "pathf"; return $EC; }
        [ ! -f "${pathf}" ] && { ctx_wa $ctx "pathf"; return $EC; }

        cat "${pathf}" | $X_WC -l | $X_SED 's/^[[:space:]]*//'
}

function file_append_newline() {
        # Append newline at the end of the file.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r pathf="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${pathf}" ] && { ctx_wa $ctx "pathf"; return $EC; }
        [ ! -f "${pathf}" ] && { ctx_wa $ctx "pathf"; return $EC; }

        echo >> "${pathf}"
}

function file_insert_at() {
        # Insert given string at the specified index.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r path="${1}"
        local -r ix="${2}"
        local -r str="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ -z "${path}" ] && { ctx_wa $ctx "path"; return $EC; }
        [ ! -f "${path}" ] && { ctx_wa $ctx "path"; return $EC; }
        [ -z "${ix}" ] && { ctx_wa $ctx "ix"; return $EC; }
        [ -z "${str}" ] && { ctx_wa $ctx "str"; return $EC; }
        [ ${ix} -lt 1 ] && { ctx_wa $ctx "ix"; return $EC; }

        # TODO: allow insertion into an empty file.
        local nl=$(file_newlines "${path}")
        [ ${ix} -gt ${nl} ] && { ctx_wa $ctx "ix"; return $EC; }

        local tmpf=$(os_mktemp_file)
        awk -v line="${ix}" \
            -v text="${str}" \
            'NR == line {print text} 1' "${path}" > "${tmpf}" || return $EC
        mv "${tmpf}" "${path}"
}

function file_remove_at() {
        # Remove a line from the specified index.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r path="${1}"
        local -r ix="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${path}" ] && { ctx_wa $ctx "path"; return $EC; }
        [ ! -f "${path}" ] && { ctx_wa $ctx "path"; return $EC; }
        [ -z "${ix}" ] && { ctx_wa $ctx "ix"; return $EC; }
        [ ${ix} -lt 1 ] && { ctx_wa $ctx "ix"; return $EC; }
        local -r nl=$(file_newlines $ctx "${path}")
        [ ${ix} -gt ${nl} ] && { ctx_wa $ctx "ix"; return $EC; }

        local -r os=$(os_name)
        if [ "${os}" = "${OS_MAC}" ]; then
                $X_SED -i '' -e ''"${ix}"'d' "${path}" || return $EC
        else
                $X_SED -i "${ix}d" "${path}" || return $EC
        fi
}

function file_at() {
        # Return line at the given index.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r path="${1}"
        local -r ix="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${path}" ] && { ctx_wa $ctx "path"; return $EC; }
        [ ! -f "${path}" ] && { ctx_wa $ctx "path"; return $EC; }
        [ -z "${ix}" ] && { ctx_wa $ctx "ix"; return $EC; }
        [ ${ix} -lt 1 ] && { ctx_wa $ctx "ix"; return $EC; }
        local -r nl=$(file_newlines $ctx "${path}")
        [ ${ix} -gt ${nl} ] && { ctx_wa $ctx "ix"; return $EC; }

        $X_SED "${ix}!d" "${path}"
}

function file_remove_empty_lines() {
        # Remove all lines that contain only white spaces.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r path="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${path}" ] && { ctx_wa $ctx "path"; return $EC; }
        [ ! -f "${path}" ] && { ctx_wa $ctx "path"; return $EC; }

        local -r os=$(os_name)
        if [ "${os}" = "${OS_MAC}" ]; then
                $X_SED -i '' -E '/^[[:space:]]*$/d' "${path}" || return $EC
        else
                $X_SED -i '/^[[:space:]]*$/d' "${path}" || return $EC
        fi
}

function file_remove_matching_lines() {
        # Remove all lines that match (sed) pattern.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r path="${1}"
        local -r pattern="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${path}" ] && { ctx_wa $ctx "path"; return $EC; }
        [ ! -f "${path}" ] && { ctx_wa $ctx "path"; return $EC; }
        [ -z "${pattern}" ] && { ctx_wa $ctx "pattern"; return $EC; }

        local -r os=$(os_name)
        if [ "${os}" = "${OS_MAC}" ]; then
                $X_SED -i '' '/'"${pattern}"'/d' "${path}" || return $EC
        else
                $X_SED -i '/'"${pattern}"'/d' "${path}" || return $EC
        fi
}

function file_squeeze_blank_lines() {
        # Remove repeated empty lines.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r path="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${path}" ] && { ctx_wa $ctx "path"; return $EC; }
        [ ! -f "${path}" ] && { ctx_wa $ctx "path"; return $EC; }

        local -r tmpf=$(os_mktemp_file $ctx)
        cat -s "${path}" > "${tmpf}"
        mv "${tmpf}" "${path}"
}
