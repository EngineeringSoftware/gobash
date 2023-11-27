#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Set collection.

# @deprecated(Remove and use Map)

if [ -n "${SET_MOD:-}" ]; then return 0; fi
readonly SET_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${SET_MOD}/../lang/p.sh
. ${SET_MOD}/list.sh


# ----------
# Functions.

function Set() {
        # Set collection.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local list
        list=$(List $ctx) || \
                { ctx_w $ctx "cannot construct ${FUNCNAME}"; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "list" "$list"
}

function Set_len() {
        # Size of the set.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r set="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local list
        list=$($set $ctx list)

        $list $ctx len
}

function Set_add() {
        # Add an element to the set.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r set="${1}"
        local -r val="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local list
        list=$($set $ctx list)

        if $list $ctx contains "${val}"; then
                return $FALSE
        fi

        $list $ctx add "${val}"
}

function Set_contains() {
        # Return true if the given value is in the set.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r obj="${1}"
        local -r val="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local list
        list=$($obj $ctx list)

        $list $ctx contains "${val}"
}

function Set_clear() {
        # Remove all elements from the set. Return (, 0) if
        # successful; (, $EC) otherwise.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r obj="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local list
        list=$($obj $ctx list)

        $list $ctx clear
}
