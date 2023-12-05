#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Doubly linked list.
#
# This directly corresponds to https://pkg.go.dev/container/list
# (src/container/list/list.go).

if [ -n "${CONTAINER_LIST_MOD:-}" ]; then return 0; fi
readonly CONTAINER_LIST_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${CONTAINER_LIST_MOD}/../lang/p.sh
. ${CONTAINER_LIST_MOD}/../util/p.sh


# ----------
# Functions.

function container_Element() {
        # Construct an element of a list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        make_ "$FUNCNAME" \
              "value" "$NULL" \
              "_next" "$NULL" \
              "_prev" "$NULL" \
              "_list" "$NULL"
}

function container_Element_next() {
        # Get the next element.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r e="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r l=$($e _list)
        is_null "$l" && echo "$NULL" && return 0

        local -r p=$($e _next)
        local -r r=$($l _root)
        [ "$p" = "$r" ] && echo "$NULL" && return 0

        echo "$p"
}

function container_Element_prev() {
        # Get the previous element.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r e="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r l=$($e _list)
        is_null "$l" && return "$NULL"

        local -r p=$($e _prev)
        local -r r=$($l _root)
        [ "$p" = "$r" ] && return "$NULL"

        echo "$p"
}

function container_List() {
        # Construct a doubly linked list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local l
        l=$(make_ "$FUNCNAME" \
                  "_root" "$(container_Element)" \
                  "_len" 0) || return $EC

        $l init
}

function container_List_init() {
        # Init a list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r r=$($l _root)
        $r _next "$r"
        $r _prev "$r"

        echo "$l"
}

function container_List_len() {
        # Return length of a list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $l _len
}

function container_List_front() {
        # Return element at the front.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r len=$($l _len)
        [ "${len}" -eq 0 ] && echo "$NULL" && return 0

        local -r r=$($l _root)
        echo "$($r _next)"
}

function container_List_back() {
        # Return element at the back.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r len=$($l _len)
        [ "${len}" -eq 0 ] && echo "$NULL" && return 0

        local -r r=$($l _root)
        echo "$($r _prev)"
}

function _container_List_lazy_init() {
        # Lazy init the given list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        if [ "$($($l _root) _next)" = "$NULL" ]; then
                $l init
        fi
}

function _container_List_insert() {
        # Insert an element at the given element.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r e="${2}"
        local -r at="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        $e _prev "$at"
        $e _next "$($at _next)"
        $($e _prev) _next "$e"
        $($e _next) _prev "$e"
        $e _list "$l"
        $l _len "$(( $($l _len) + 1 ))"

        echo "$e"
}

function _container_List_insert_value() {
        # Insert a value at the given element.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r v="${2}"
        local -r at="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        local -r e=$(container_Element)
        $e value "$v"
        _container_List_insert "$l" "$e" "$at"
}

function _container_List_remove() {
        # Remove the given element from the list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r e="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        $($e _prev) _next "$($e _next)"
        $($e _next) _prev "$($e _prev)"
        $e _next "$NULL"
        $e _prev "$NULL"
        $e _list "$NULL"
        $l _len "$(( $($l _len) - 1 ))"
}

function _container_List_move() {
        # Move the given element to the given element.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r e="${2}"
        local -r at="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ "$e" = "$at" ] && return 0

        $($e _prev) _next "$($e _next)"
        $($e _next) _prev "$($e _prev)"

        $e _prev "$at"
        $e _next "$($at _next)"
        $($e _prev) _next "$e"
        $($e _next) _prev "$e"
}

function container_List_remove() {
        # Remove the given element from this list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r e="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        if [ "$($e _list)" = "$l" ]; then
                _container_List_remove "$l" "$e"
        fi
        echo "$($e value)"
}

function container_List_push_front() {
        # Push a value to the front of this list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r v="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        _container_List_lazy_init "$l"

        local -r r=$($l _root)
        _container_List_insert_value "$l" "$v" "$r"
}

function container_List_push_back() {
        # Push a value to the back of this list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r v="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        _container_List_lazy_init "$l"

        local -r r=$($l _root)
        _container_List_insert_value "$l" "$v" "$($r _prev)"
}

function container_List_insert_before() {
        # Insert a value before the marker element.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r v="${2}"
        local -r mark="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ "$($mark _list)" != "$l" ] && echo "$NULL" && return 0

        _container_List_insert_value "$l" "$v" "$($mark _prev)"
}

function container_List_insert_after() {
        # Insert a value after the marker element.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r v="${2}"
        local -r mark="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ "$($mark _list)" != "$l" ] && echo "$NULL" && return 0

        _container_List_insert_value "$l" "$v" "$mark"
}

function container_List_move_to_front() {
        # Move element to the front of the list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r e="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ "$($e _list)" != "$l" ] && return 0
        $l move "$e" "$($l _root)"
}

function container_List_move_to_back() {
        # Move element to the back of the list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r e="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ "$($e _list)" != "$l" ] && return 0

        $l move "$e" "$($($l _root) _prev)"
}

function container_List_move_before() {
        # Move element before the given marker.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r e="${2}"
        local -r mark="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ "$e" = "$mark" ] && return 0
        [ "$($e _list)" != "$l" ] && return 0
        [ "$($mark _list)" != "$l" ] && return 0

        $l move "$e" "$($mark _prev)"
}

function container_List_move_after() {
        # Move element after the given marker.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r e="${2}"
        local -r mark="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ "$e" = "$mark" ] && return 0
        [ "$($e _list)" != "$l" ] && return 0
        [ "$($mark _list)" != "$l" ] && return 0

        $l move "$e" "$mark"
}

function container_List_push_back_list() {
        # Push one list at the end of another.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r other="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        _container_List_lazy_init "$l"

        local i=$($other _len)
        local e=$($other front)
        for (( ; i>0; i-- )); do
                _container_List_insert_value "$l" "$($e value)" "$($($l _root) _prev)"
                e=$($e next)
        done
}

function container_List_push_front_list() {
        # Push one list to the front of another.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r other="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        _container_List_lazy_init "$l"

        local i=$($other _len)
        local e=$($other back)
        for (( ; i>0; i-- )); do
                _container_List_insert_value "$l" "$($e value)" "$($l _root)"
                e=$($e prev)
        done
}
