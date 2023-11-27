#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# API for some bash variables.
# https://tldp.org/LDP/abs/html/internalvariables.html

if [ -n "${BASH_MOD:-}" ]; then return 0; fi
readonly BASH_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${BASH_MOD}/core.sh


# ----------
# Functions.

function bash_version_major() {
        # Return bash major number.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        echo "${BASH_VERSINFO[0]}"
}

function bash_version_minor() {
        # Return bash minor number.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        echo "${BASH_VERSINFO[1]}"
}

function bash_version_patch() {
        # Return bash patch number.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        echo "${BASH_VERSINFO[2]}"
}

function bash_version_build() {
        # Return bash build number.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        echo "${BASH_VERSINFO[3]}"
}

function bash_version_release() {
        # Return bash release string.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        echo "${BASH_VERSINFO[4]}"
}

function bash_version_arch() {
        # Return bash architecture string.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        echo "${BASH_VERSINFO[5]}"
}
