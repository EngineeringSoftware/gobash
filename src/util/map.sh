#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Map collection.

if [ -n "${MAP_MOD:-}" ]; then return 0; fi
readonly MAP_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${MAP_MOD}/list.sh


# ----------
# Functions.

function Map() {
        # Map collection.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local map
        map=$(make_ $ctx "${FUNCNAME}") || \
                { ctx_w "cannot make ${FUNCNAME}"; return $EC; }

        local -r nargs=$#
        local -i i
        for (( i=0; i<${nargs}; i+=2 )); do
                $map $ctx put "${1}" "${2}" || \
                        { ctx_w $ctx "cannot put"; return $EC; }

                shift 2 || \
                        { ctx_w $ctx "insufficient args"; return $EC; }
        done

        echo "${map}"
}

function Map_len() {
        # Size of the map.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r map="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        unsafe_len $ctx "${map}" || \
                { ctx_w $ctx "cannot get map len"; return $EC; }
}

function Map_put() {
        # Add key, value pair into the map.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r map="${1}"
        local -r key="${2}"
        local -r val="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ -z "${map}" ] && { ctx_w $ctx "no map"; return $EC; }
        [ -z "${key}" ] && { ctx_w $ctx "no key"; return $EC; }
        # Value can be empty.

        unsafe_set_fld $ctx "${map}" "${key}" "${val}" || \
                { ctx_w $ctx "could not put into map"; return $EC; }
}

function Map_get() {
        # Get (value, 0) for the key. Return (null, 1) if key is not
        # available.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r map="${1}"
        local -r key="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        unsafe_get_fld "${map}" "${key}"
}

function Map_inc() {
        # Increment value for the given key.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r map="${1}"
        local -r key="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local ec=0
        local val
        val=$($map $ctx get "${key}") || \
                { ec=$?; [ ${ec} -gt $FALSE ] && return ${ec}; }

        if [ ${ec} -eq 0 ]; then
                # Key is already in.
                $map $ctx put "${key}" "$(( ${val} + 1 ))" || \
                        { ctx_w $ctx "cannot put"; return $EC; }
        else
                # No key.
                $map $ctx put "${key}" 1 || \
                        { ctx_w $ctx "cannot put"; return $EC; }
        fi
}

function Map_keys() {
        # Return list of keys in the same order as in the map.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r map="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        unsafe_keys $ctx "${map}"
}
