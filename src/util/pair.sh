#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Pair collection.

if [ -n "${PAIR_MOD:-}" ]; then return 0; fi
readonly PAIR_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${PAIR_MOD}/../lang/p.sh
. ${PAIR_MOD}/math.sh

# ----------
# Functions.

function Pair() {
    # Pair collection.
    local ctx; is_ctx "${1}" && ctx="${1}" && shift
    [ $# -lt 0 ] && { ctx_wn $ctx; return $EC; }
    shift 0 || { ctx_wn $ctx; return $EC; }

    local pr=$(make_ $ctx "${FUNCNAME}") || \
        { ctx_w "cannot make ${FUNCNAME}"; return $EC; }

    pr=$(make_ $ctx \
        "${FUNCNAME}" \
        "first" "${NULL}" \
        "second" "${NULL}")

    if [ ! -z "${1}" ]; then
        $pr first "${1}"
    fi;
    if [ ! -z "${2}" ]; then
        $pr second "${2}"
    fi;
    echo "${pr}"
}

function Pair_swap_args() {
    # Swap two elements in the pair.
    local ctx; is_ctx "${1}" && ctx="${1}" && shift
    [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }

    local pr="${1}"

    if [[ ! -z $($pr first) ]] && [[ ! -z $($pr second) ]];
    then
        local tmp=$($pr first);
        $pr first $($pr second);
        $pr second $tmp;
    fi;
}