#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# List collection.

if [ -n "${LIST_MOD:-}" ]; then return 0; fi
readonly LIST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${LIST_MOD}/../lang/p.sh
. ${LIST_MOD}/math.sh


# ----------
# Functions.

function List() {
        # List collection.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local lst=$(unsafe_list_make $ctx)

        local el
        for el in "$@"; do
                List_add $ctx "${lst}" "${el}" || \
                        { ctx_w $ctx "cannot add an el"; return $EC; }
        done

        echo "${lst}"
}

function List_len() {
        # Return (length of the list, 0). If there is an error, return
        # (_, $EC).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        unsafe_len $ctx "${lst}"
}

function List_add() {
        # Add an element to the list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        local val="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        unsafe_list_add $ctx "${lst}" "${val}"
}

function List_get() {
        # Get an element at the index.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        local -r ix="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        unsafe_list_get $ctx "${lst}" "${ix}"
}

function List_delete() {
        # Delete an element at the index.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        local -r -i ix="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        unsafe_list_delete "${lst}" "${ix}"
}

function List_clear() {
        # Empty the list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${lst}" ] && { ctx_w $ctx "no lst"; return $EC; }

        unsafe_list_clear $ctx "${lst}"
}

function List_sum() {
        # Sum all the elements (ints only).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local len
        len=$(List_len $ctx "${lst}") || return $EC

        local sum=0
        local -i i
        for (( i=0; i<${len}; i++ )); do
                sum=$(( ${sum} + $(List_get $ctx "${lst}" "${i}") ))
        done

        echo "${sum}"
}

function List_min() {
        # Find min value (ints only).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local len
        len=$(List_len $ctx "${lst}") || \
                { ctx_w $ctx "cannot get len"; return $EC; }

        [ ${len} -eq 0 ] && { ctx_w $ctx "incorrect len"; return $EC; }

        local min=$(List_get $ctx "${lst}" 0)
        local -i i
        for (( i=1; i<${len}; i++ )); do
                local el
                el=$(List_get $ctx "${lst}" "${i}") || \
                        { ctx_w $ctx "cannot get an el"; return $EC; }
                if [ ${min} -gt ${el} ]; then
                        min=${el}
                fi
        done

        echo "${min}"
}

function List_is_empty() {
        # Return true if the list is empty.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -i len
        len=$(List_len $ctx "${lst}") || \
                { ctx_w $ctx "cannog get len"; return $EC; }

        [ ${len} -eq 0 ]
}

function List_contains() {
        # Return true if the list contains the given value.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        local -r val="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${lst}" ] && { ctx_w $ctx "no lst"; return $EC; }

        local -i len
        len=$(List_len $ctx "${lst}") || \
                { ctx_w $ctx "cannot get len"; return $EC; }

        local -i i
        for (( i=0; i<${len}; i++ )); do
                local el
                el=$(List_get $ctx "${lst}" ${i}) || \
                        { ctx_w $ctx "cannot get an el"; return $EC; }
                if [ "${el}" = "${val}" ]; then
                        return $TRUE
                fi
        done
        return $FALSE
}

function List_eq() {
        # Return true if two lists are the same (using references).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        local -r other="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        unsafe_list_eq $ctx "${lst}" "${other}"
}

function List_filter() {
        # Create a list by filtering this list using the predicate.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        local -r predicate="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local -i len
        len=$(List_len $ctx "${lst}") || return $EC

        local nlst=$(List $ctx)

        local -i i
        for (( i=0; i<${len}; i++ )); do
                local el
                el=$(List_get $ctx "${lst}" "${i}") || return $EC

                local ec=0
                ${predicate} $ctx "${el}" || \
                        { ec=$?; [ ${ec} -gt 1 ] && { ctx_w $ctx "predicate error"; return $EC; }; }

                if [ ${ec} -eq 0 ]; then
                        $nlst $ctx add "${el}"
                fi
        done

        echo "${nlst}"
}

function List_map() {
        # Apply mapper to each element in the list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        local -r mapper="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local -i len
        len=$(List_len $ctx "${lst}") || \
                { ctx_w $ctx "cannot get len"; return $EC; }

        local nlst=$(List $ctx)

        local -i i
        for (( i=0; i<${len}; i++ )); do
                local el
                el=$(List_get $ctx "${lst}" "${i}") || \
                        { ctx_w $ctx "cannot get an el"; return $EC; }

                local nel=$(${mapper} $ctx "${el}")
                $nlst $ctx add "${nel}"
        done

        echo "${nlst}"
}

function List_reduce() {
        # Reduce elements in the list with the given binary operator.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        local -r identity="${2}"
        local -r bi_op="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        local -i len
        len=$(List_len $ctx "${lst}") || \
                { ctx_w $ctx "cannot get len"; return $EC; }

        local res="${identity}"

        local -i i
        for (( i=0; i<${len}; i++ )); do
                local el
                el=$(List_get $ctx "${lst}" "${i}") || \
                        { ctx_w $ctx "cannot get an el"; return $EC; }
                res=$(${bi_op} $ctx "${res}" "${el}")
        done

        echo "${res}"
}

function List_any_match() {
        # Return true if any element satisfies the predicate.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        local -r predicate="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local -i len
        len=$(List_len $ctx "${lst}") || \
                { ctx_w $ctx "cannot get len"; return $EC; }

        local -i i
        for (( i=0; i<${len}; i++ )); do
                local el
                el=$(List_get $ctx "${lst}" "${i}") || \
                        { ctx_w $ctx "cannot get an el"; return $EC; }

                local ec=0
                ${predicate} $ctx "${el}" ||
                        { ec=$?; [ ${ec} -gt 1 ] && { ctx_w $ctx "predicate error"; return $EC; }; }

                if [ ${ec} -eq 0 ]; then
                        return $TRUE
                fi
        done
        return $FALSE
}

function List_all_match() {
        # Return true if all elements satisfy the predicate.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        local -r predicate="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local nlst
        nlst=$(List_filter $ctx "${lst}" "${predicate}") || \
                { ctx_w $ctx "could not filter"; return $EC; }

        [ $(List_len $ctx "${nlst}") -eq $(List_len $ctx "${lst}") ]
}

function List_first() {
        # Return (the first element, 0); (_, $EC) if none exists.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        List_get $ctx "${lst}" 0
}

function List_second() {
        # Return (the second element, 0); (_, $EC) if none exists.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        List_get $ctx "${lst}" 1
}

function List_last() {
        # Return (the last element, 0); (_, $EC) if none exists.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r lst="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        List_get $ctx "${lst}" $(( $(List_len $ctx "${lst}") - 1 ))
}
