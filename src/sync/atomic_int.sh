#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Atomic int related structs and functions.

if [ -n "${ATOMIC_INT_MOD:-}" ]; then return 0; fi
readonly ATOMIC_INT_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${ATOMIC_INT_MOD}/../lang/p.sh
. ${ATOMIC_INT_MOD}/mutex.sh


# ----------
# Functions.

function AtomicInt() {
        # AtomicInt.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -gt 1 ] && { ctx_wn $ctx; return $EC; }
        local -r -i val="${1:-0}"
        shift 0 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "mu" "$(Mutex $ctx)" \
              "val" "${val}"
}

function AtomicInt_inc() {
        # Increment.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r ai="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $ai $ctx add 1
}

function AtomicInt_add() {
        # Add to the value.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r ai="${1}"
        local -r -i i="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${i}" ] && { ctx_w $ctx "no i"; return $EC; }

        local mu
        mu=$($ai $ctx mu)
        $mu $ctx lock || { ctx_w $ctx "cannot lock"; return $EC; }

        local -r val=$(( $($ai $ctx val) + ${i} ))
        $ai $ctx val "${val}"

        $mu $ctx unlock || { ctx_w $ctx "cannot unlock"; return $EC; }

        echo "${val}"
}

function AtomicInt_compare_and_swap() {
        # Compare and swap.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r ai="${1}"
        local -r -i old="${2}"
        local -r -i new="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ -z "${old}" ] && { ctx_w $ctx "no old"; return $EC; }
        [ -z "${new}" ] && { ctx_w $ctx "no new"; return $EC; }

        local mu
        mu=$($ai $ctx mu)
        $mu $ctx lock || { ctx_w $ctx "cannot lock"; return $EC; }

        local swapped=$FALSE
        if [ $($ai $ctx val) -eq ${old} ]; then
                $ai $ctx val "${new}"
                swapped=$TRUE
        fi

        $mu $ctx unlock || { ctx_w $ctx "cannot unlock"; return $EC; }

        return ${swapped}
}

function AtomicInt_load() {
        # Load value.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r ai="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local mu
        mu=$($ai $ctx mu)
        $mu lock || { ctx_w $ctx "cannot lock"; return $EC; }

        local -r res=$($ai $ctx val)

        $mu $ctx unlock || { ctx_w $ctx "cannot unlock"; return $EC; }

        echo "${res}"
}

function AtomicInt_store() {
        # Store value.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r ai="${1}"
        local -r -i val="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${val}" ] && { ctx_w $ctx "no val"; return $EC; }

        local mu
        mu=$($ai $ctx mu)
        $mu $ctx lock || { ctx_w $ctx "cannot lock"; return $EC; }

        $ai $ctx val "${val}"

        $mu $ctx unlock || { ctx_w $ctx "cannot unlock"; return $EC; }

        return 0
}

function AtomicInt_swap() {
        # Swap values (store new and return old).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r ai="${1}"
        local -r -i new="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${new}" ] && { ctx_w $ctx "no new"; return $EC; }

        local mu
        mu=$($ai $ctx mu)
        $mu $ctx lock || { ctx_w $ctx "cannot lock"; return $EC; }

        local -r old=$($ai $ctx val)
        $ai $ctx val "${new}"

        $mu $ctx unlock || { ctx_w $ctx "cannot unlock"; return $EC; }

        echo "${old}"
}
