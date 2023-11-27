#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Log functions.

if [ -n "${LOG_MOD:-}" ]; then return 0; fi
readonly LOG_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${LOG_MOD}/core.sh
. ${LOG_MOD}/unsafe.sh

# @mutable
_LOG_FILE="$(core_obj_dir)/world.txt"
readonly LOG_STDOUT="stdout"


# ----------
# Functions.

function _log() {
        # Log.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 4 ] && { ctx_wn $ctx; return $EC; }
        local -r level="${1}"
        local -r func="${2}"
        local -r logf="${3}"
        local -r msg="${4}"
        shift 4 || { ctx_wn $ctx; return $EC; }

        local text
        if [ -z "${msg}" ]; then
                text="${level}::($($X_DATE)) ${func}"
        else
                text="${level}::($($X_DATE)) ${func} ${msg}"
        fi

        if [ ! -z "${logf}" ]; then
                echo "${text}" >> "${logf}"
        else
                echo "${text}"
        fi

        return 0
}

function log_output() {
        # Return current output.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        echo "${_LOG_FILE}"
}

function log_set_output() {
        # Set output (either $LOG_STDOUT or filename).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r output="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        case "${output}" in
        ${LOG_STDOUT}) _LOG_FILE="";;
        *) _LOG_FILE="${output}";;
        esac
}

function log_e() {
        # Log error.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && { ctx_wn $ctx; return $EC; }
        local -r msg="${1}"
        shift 0 || { ctx_wn $ctx; return $EC; }

        _log $ctx "ERROR" "$(caller 0 | $X_CUT -f2 -d' ')" "${_LOG_FILE}" "${msg}" 1>&2
}

function log_w() {
        # Log warning.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && { ctx_wn $ctx; return $EC; }
        local -r msg="${1}"
        shift 0 || { ctx_wn $ctx; return $EC; }

        _log $ctx "WARN" "$(caller 0 | $X_CUT -f2 -d' ')" "${_LOG_FILE}" "${msg}" 1>&2
}

function log_i() {
        # Log info.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && { ctx_wn $ctx; return $EC; }
        local -r msg="${1}"
        shift 0 || { ctx_wn $ctx; return $EC; }

        _log $ctx "INFO" "$(caller 0 | $X_CUT -f2 -d' ')" "${_LOG_FILE}" "${msg}"
}
