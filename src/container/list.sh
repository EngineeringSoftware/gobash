#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Doubly linked list.
#
# This directly corresponds to https://pkg.go.dev/container/list
# (src/container/list/list.go). Therefore, please check documentation
# for list.go for any method of interest.

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

        make_ $ctx \
              "$FUNCNAME" \
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

        [ -z "$e" ] && { ctx_w $ctx "e cannot be empty"; return $EC; }
        is_null $ctx "$e" && { ctx_w $ctx "e cannot be null"; return $EC; }

        local l
        l=$($e $ctx _list) || { ctx_w $ctx "cannot get list"; return $EC; }
        is_null $ctx "$l" && echo "$NULL" && return 0

        local p
        p=$($e $ctx _next) || { ctx_w $ctx "cannot get next"; return $EC; }

        local r
        r=$($l $ctx _root) || { ctx_w $ctx "cannot get root"; return $EC; }

        [ "$p" = "$r" ] && echo "$NULL" && return 0
        echo "$p"
}

function container_Element_prev() {
        # Get the previous element.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r e="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "$e" ] && { ctx_w $ctx "e cannot be empty"; return $EC; }
        is_null $ctx "$e" && { ctx_w $ctx "e cannot be null"; return $EC; }

        local l
        l=$($e $ctx _list) || { ctx_w $ctx "cannot get list"; return $EC; }
        is_null $ctx "$l" && return "$NULL"

        local p
        p=$($e $ctx _prev) || { ctx_w $ctx "cannot get prev"; return $EC; }

        local r
        r=$($l $ctx _root) || { ctx_w $ctx "cannot get root"; return $EC; }

        [ "$p" = "$r" ] && echo "$NULL" && return 0
        echo "$p"
}

function container_List() {
        # Construct a doubly linked list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        local e
        e=$(container_Element $ctx) || return $EC

        local l
        l=$(make_ $ctx "$FUNCNAME" \
                  "_root" "$e" \
                  "_len" 0) || return $EC

        $l $ctx init
}

function container_List_init() {
        # Init a list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC

        local r
        r=$($l $ctx _root) || { ctx_w $ctx "cannot get root"; return $EC; }

        $r $ctx _next "$r" || { ctx_w $ctx "cannot set next"; return $EC; }
        $r $ctx _prev "$r" || { ctx_w $ctx "cannot set prev"; return $EC; }
        $l $ctx _len 0 || { ctx_w $ctx "cannot set len"; return $EC; }

        echo "$l"
}

function container_List_len() {
        # Return length of a list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC

        $l $ctx _len
}

function container_List_front() {
        # Return element at the front.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC

        local len
        len=$($l $ctx _len) || { ctx_w $ctx "cannot get len"; return $EC; }
        [ "${len}" -eq 0 ] && echo "$NULL" && return 0

        local r
        r=$($l $ctx _root) || { ctx_w $ctx "cannot get root"; return $EC; }

        local n
        n=$($r $ctx _next) || { ctx_w $ctx "cannot get next"; return $EC; }
        echo "$n"
}

function container_List_back() {
        # Return element at the back.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC

        local len
        len=$($l $ctx _len) || { ctx_w $ctx "cannot get len"; return $EC; }
        [ "${len}" -eq 0 ] && echo "$NULL" && return 0

        local r
        r=$($l $ctx _root) || { ctx_w $ctx "cannot get root"; return $EC; }

        local p
        p=$($r $ctx _prev) || { ctx_w $ctx "cannot get prev"; return $EC; }
        echo "$p"
}

function _container_List_lazy_init() {
        # Lazy init the given list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC

        local r
        r=$($l $ctx _root) || { ctx_w $ctx "cannot get root"; return $EC; }

        if [ "$($r $ctx _next)" = "$NULL" ]; then
                $l $ctx init || { ctx_w $ctx "cannot init"; return $EC; }
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

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC
        is_null $ctx "$e" && return $EC
        is_null $ctx "$at" && return $EC

        $e $ctx _prev "$at" || { ctx_w $ctx "cannot set prev"; return $EC; }

        $e $ctx _next "$($at $ctx _next)" || \
                { ctx_w $ctx "cannot set next"; return $EC; }

        $($e $ctx _prev) $ctx _next "$e" || \
                { ctx_w $ctx "cannot set next"; return $EC; }

        $($e $ctx _next) $ctx _prev "$e" || \
                { ctx_w $ctx "cannot set prev"; return $EC; }

        $e $ctx _list "$l" || { ctx_w $ctx "cannot set list"; return $EC; }

        $l $ctx _len "$(( $($l $ctx _len) + 1 ))" || \
                { ctx_w $ctx "cannot set len"; return $EC; }

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

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC
        is_null $ctx "$at" && return $EC

        local e
        e=$(container_Element $ctx) || \
                { ctx_w $ctx "cannot make an element"; return $EC; }

        $e $ctx value "$v" || { ctx_w $ctx "cannot set value"; return $EC; }

        _container_List_insert $ctx "$l" "$e" "$at" || \
                { ctx_w $ctx "cannot insert element"; return $EC; }
}

function _container_List_remove() {
        # Remove the given element from the list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r e="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC

        $($e $ctx _prev) $ctx _next "$($e $ctx _next)"
        $($e $ctx _next) $ctx _prev "$($e $ctx _prev)"
        $e $ctx _next "$NULL"
        $e $ctx _prev "$NULL"
        $e $ctx _list "$NULL"
        $l $ctx _len "$(( $($l $ctx _len) - 1 ))"
}

function _container_List_move() {
        # Move the given element to the given element.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r e="${2}"
        local -r at="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC

        [ "$e" = "$at" ] && return 0

        $($e $ctx _prev) $ctx _next "$($e $ctx _next)"
        $($e $ctx _next) $ctx _prev "$($e $ctx _prev)"

        $e $ctx _prev "$at"
        $e $ctx _next "$($at _next)"
        $($e $ctx _prev) $ctx _next "$e"
        $($e $ctx _next) $ctx _prev "$e"
}

function container_List_remove() {
        # Remove the given element from this list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r e="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC
        is_null $ctx "$e" && return $EC

        if [ "$($e $ctx _list)" = "$l" ]; then
                _container_List_remove $ctx "$l" "$e" || \
                        { ctx_w $ctx "cannot remove"; return $EC; }
        fi
        echo "$($e $ctx value)"
}

function container_List_push_front() {
        # Push a value to the front of this list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r v="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC

        _container_List_lazy_init $ctx "$l" || \
                { ctx_w $ctx "cannot lazy init"; return $EC; }

        local -r r=$($l $ctx _root)
        _container_List_insert_value $ctx "$l" "$v" "$r" || \
                { ctx_w $ctx "cannot insert value"; return $EC; }
}

function container_List_push_back() {
        # Push a value to the back of this list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r v="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC

        _container_List_lazy_init $ctx "$l" || \
                { ctx_w $ctx "cannot lazy init"; return $EC; }

        local -r r=$($l $ctx _root)
        _container_List_insert_value $ctx "$l" "$v" "$($r $ctx _prev)" || \
                { ctx_w $ctx "cannot insert value"; return $EC; }
}

function container_List_insert_before() {
        # Insert a value before the marker element.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r v="${2}"
        local -r mark="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC
        is_null $ctx "$mark" && return $EC

        [ "$($mark $ctx _list)" != "$l" ] && echo "$NULL" && return 0

        _container_List_insert_value $ctx "$l" "$v" "$($mark $ctx _prev)" || \
                { ctx_w $ctx "cannot insert value"; return $EC; }
}

function container_List_insert_after() {
        # Insert a value after the marker element.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r v="${2}"
        local -r mark="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC
        is_null $ctx "$mark" && return $EC

        [ "$($mark $ctx _list)" != "$l" ] && echo "$NULL" && return 0

        _container_List_insert_value $ctx "$l" "$v" "$mark" || \
                { ctx_w $ctx "cannot insert value"; return $EC; }
}

function container_List_move_to_front() {
        # Move element to the front of the list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r e="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && { ctx_w $ctx "list cannot be null"; return $EC; }
        is_null $ctx "$e" && { ctx_w $ctx "element cannot be null"; return $EC; }

        [ "$($e $ctx _list)" != "$l" ] && return 0

        _container_List_move $ctx "$l" "$e" "$($l $ctx _root)" || \
                { ctx_w $ctx "cannot move"; return $EC; }
}

function container_List_move_to_back() {
        # Move element to the back of the list.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r e="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC
        is_null $ctx "$e" && return $EC

        [ "$($e $ctx _list)" != "$l" ] && return 0

        _container_List_move $ctx "$l" "$e" "$($($l $ctx _root) $ctx _prev)" || \
                { ctx_w $ctx "cannot move"; return $EC; }
}

function container_List_move_before() {
        # Move element before the given marker.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r e="${2}"
        local -r mark="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC
        is_null $ctx "$e" && return $EC
        is_null $ctx "$mark" && return $EC

        [ "$e" = "$mark" ] && return 0
        [ "$($e $ctx _list)" != "$l" ] && return 0
        [ "$($mark $ctx _list)" != "$l" ] && return 0

        _container_List_move $ctx "$l" "$e" "$($mark $ctx _prev)" || \
                { ctx_w $ctx "cannot move"; return $EC; }
}

function container_List_move_after() {
        # Move element after the given marker.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r e="${2}"
        local -r mark="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC
        is_null $ctx "$e" && return $EC
        is_null $ctx "$mark" && return $EC

        [ "$e" = "$mark" ] && return 0
        [ "$($e $ctx _list)" != "$l" ] && return 0
        [ "$($mark $ctx _list)" != "$l" ] && return 0

        _container_List_move $ctx "$l" "$e" "$mark" || \
                { ctx_w $ctx "cannot move"; return $EC; }
}

function container_List_push_back_list() {
        # Push one list at the end of another.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r other="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC
        is_null $ctx "$other" && return $EC

        _container_List_lazy_init $ctx "$l" || \
                { ctx_w $ctx "cannot lazy init"; return $EC; }

        local i
        i=$($other $ctx _len) || { ctx_w $ctx "cannot get len"; return $EC; }

        local e
        e=$($other $ctx front) || { ctx_w $ctx "cannot get front"; return $EC; }

        for (( ; i>0; i-- )); do
                _container_List_insert_value $ctx "$l" "$($e value)" "$($($l _root) _prev)" || \
                        { ctx_w $ctx "cannot insert value"; return $EC; }
                e=$($e $ctx next) || { ctx_w $ctx "cannot get next"; return $EC; }
        done
}

function container_List_push_front_list() {
        # Push one list to the front of another.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r l="${1}"
        local -r other="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "$l" ] && return $EC
        is_null $ctx "$l" && return $EC
        is_null $ctx "$other" && return $EC

        _container_List_lazy_init $ctx "$l" || \
                { ctx_w $ctx "cannot lazy init"; return $EC; }

        local i
        i=$($other $ctx _len) || { ctx_w $ctx "cannot get len"; return $EC; }

        local e
        e=$($other $ctx back) || { ctx_w $ctx "cannot get back"; return $EC; }

        for (( ; i>0; i-- )); do
                _container_List_insert_value $ctx "$l" "$($e value)" "$($l _root)" || \
                        { ctx_w $ctx "cannot insert value"; return $EC; }
                e=$($e $ctx prev) || { ctx_w $ctx "cannot get prev"; return $EC; }
        done
}
