#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Util functions for checking values/system.

if [ -n "${BOOL_MOD:-}" ]; then return 0; fi
readonly BOOL_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${BOOL_MOD}/bash.sh
. ${BOOL_MOD}/core.sh
. ${BOOL_MOD}/os.sh


# ----------
# Functions.

function is_true() {
        # True if value is considered true in this library.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r val="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ "${val}" = $TRUE -o "${val}" = "true" ]
}

function is_false() {
        # True if value is considered false in this library.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r val="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ "${val}" = $FALSE -o "${val}" = "false" ]
}

function is_exe() {
        # True if the given argument corresponds to an executable.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r exe="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        if ! hash "${exe}" 2> /dev/null; then
                return $FALSE
        else
                return $TRUE
        fi
}

function is_empty() {
        # True if an empty string.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r str="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${str}" ]
}

function is_function() {
        # True if the given name corresponds to a function.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r func="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        declare -F "${func}" > /dev/null
}

function is_file() {
        # True if it is a valid file.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r path="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -f "${path}" ]
}

function is_eq() {
        # True if values are equal (lexical).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r one="${1}"
        local -r two="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ "${one}" = "${two}" ]
}

function is_ne() {
        # True if values are not equal (lexical).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r one="${1}"
        local -r two="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        ! is_eq $ctx "${one}" "${two}"
}

# @deprecated(remove)
function is_set() {
        # True if the value is set.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r val="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        ! [ "${val}" = "" -o "${val}" = "${NULL}" ]
}

function is_null() {
        # True if the value is null.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r val="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ "${val}" = "${NULL}" ]
}

function is_int() {
        # True if the given value can be parsed as an int (bc).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r val="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        # Int cannot have . in the value.
        local -r re='\.'
        [[ "${val}" =~ ${re} ]] && return $FALSE

        local -r res=$(bc <<< "${val} * 1" 2>&1)
        [ "${val}" = "${res}" ]
}

function is_float() {
        # True if the given value can be a float (bc).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r val="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r res=$(bc <<< "${val} * 1" 2>&1)
        [ "${val}" = "${res}" ]
}

function is_bool() {
        # True if the given value can be a bool.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r val="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        is_true $ctx "${val}" || is_false $ctx "${val}"
}

function is_string() {
        # True if the given value can be a string.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r val="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        true
}

function is_gt() {
        # True if one value is greater than another (ints only).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r one="${1}"
        local -r two="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        ! is_int "${one}" && return $EC
        ! is_int "${two}" && return $EC

        [ ${one} -gt ${two} ]
}

function is_object() {
        # True if the given argument is a valid object.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r obj="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        unsafe_is_object $ctx "${obj}"
}

function is_instanceof() {
        # True if the object is instance of the given struct.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r obj="${1}"
        local -r struct="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        # TODO: move to be a method on alloc?

        is_object "$obj" || return $FALSE

        unsafe_is_instanceof $ctx "$obj" "${struct}"
}

function has_fld() {
        # True if the object has the given field.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r obj="${1}"
        local -r fld="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        # TODO: move to be a method on alloc?

        unsafe_has_fld $ctx "$obj" "${fld}"
}

function is_ec() {
        # True if the value is an error (as def in this library).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r ec="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ ${ec} -eq $EC ]
}

function is_bash3() {
        # True if this function is invoked by bash 3.x process.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        [ $(bash_version_major $ctx) = "3" ]
}

function is_bash4() {
        # True if this function is invoked by bash 4.x process.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        [ $(bash_version_major $ctx) = "4" ]
}

function is_bash5() {
        # True if this function is invoked by bash 5.x process.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        [ $(bash_version_major $ctx) = "5" ]
}

function is_linux() {
        # Return true/0 if linux.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local name
        name=$(os_name $ctx)
        [ "${name}" = "${OS_LINUX}" ]
}

function is_mac() {
        # Return true/0 if mac.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local name
        name=$(os_name $ctx)
        [ "${name}" = "${OS_MAC}" ]
}
