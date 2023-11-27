#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Low level object manipulation.

if [ -n "${MAKE_MOD:-}" ]; then return 0; fi
readonly MAKE_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${MAKE_MOD}/core.sh
. ${MAKE_MOD}/unsafe.sh
. ${MAKE_MOD}/bool.sh


# ----------
# Functions.

function make_() {
        # Alloc.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; return $EC; }
        local -r struct="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ "${struct}" = "" ] && \
                { ctx_w $ctx "no such struct"; return $EC; }

        is_function $ctx "${struct}" > /dev/null || \
                { ctx_w $ctx "constructor does not exist"; return $EC; }

        [ $(( $# % 2 )) -ne 0 ] && \
                { ctx_w $ctx "insufficient args"; return $EC; }

        local -r uid=$(unsafe_object_make $ctx "${struct}")

        local -r num_args=$#
        local -i i
        for (( i=0; i<${num_args}; i+=2 )); do
                local fld="${1}"
                local val="${2}"
                unsafe_set_fld $ctx "${uid}" "${fld}" "${val}"
                shift 2 || \
                        { ctx_w $ctx "insufficient args"; return $EC; }
        done

        echo "_make_access ${uid}"
}
readonly -f make_

function amake_() {
        # Anonymous struct.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        # Anonymous structs.
        make_ $ctx "${FUNCNAME}" "$@"
}
readonly -f amake_

function _make_invoke() {
        # Method invoke.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 2 ] && { ctx_wn $ctx; return $EC; }
        local -r func="${1}"
        local -r uid="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        # TODO(milos): could check for private methods.
        "${func}" $ctx "_make_access ${uid}" "$@"
}
readonly -f _make_invoke

function _make_access() {
        # Access.
        local -r uid="${1}"
        local ctx; is_ctx "${2}" && ctx="${2}" && shift
        [ $# -lt 1 ] && { ctx_wn $ctx; return $EC; }
        #local -r uid="${1}" # moved up
        local -r attr="${2}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # Cannot be empty.
        [ -z "${uid}" ] && { ctx_w $ctx "incorrect id"; return $EC; }

        # Return uid if no arguments.
        [ $# -eq 0 ] && echo "${uid}" && return 0
        shift

        local struct=$(echo "${uid}" | $X_SED 's/\(.*\)@.*/\1/g')

        local -r func="${struct}_${attr}"
        if is_function $ctx "${func}" > /dev/null 2>&1; then
                # Method.
                _make_invoke $ctx "${func}" "${uid}" "$@" || return $?
                return 0
        fi

        if unsafe_has_fld $ctx "${uid}" "${attr}"; then
                # It is a field.
                if [ $# -eq 0 ]; then
                        unsafe_get_fld $ctx "${uid}" "${attr}" || \
                                { local ec=$?; ctx_w $ctx "cannot get fld"; return ${ec}; }
                        return 0
                elif [ $# -eq 1 ]; then
                        unsafe_set_fld $ctx "${uid}" "${attr}" "${1}" || \
                                { local ec=$?; ctx_w $ctx "cannot set fld"; return ${ec}; }
                        return 0
                else
                        # Cannot have more than 1 argument for fields.
                        ctx_w $ctx "cannot have more than 1 arg"
                        return $EC
                fi
        fi

        # Check if one of the default methods.
        if [[ "${func}" = *"to_string" ]]; then
                unsafe_to_string $ctx "${uid}" || return $?
                return 0
        elif [[ "${func}" = *"to_json" ]]; then
                unsafe_to_json $ctx "${uid}" || return $?
                return 0
        fi

        ctx_w $ctx "cannot access ${attr}"; return $EC
}
readonly -f _make_access
