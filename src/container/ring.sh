#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Operations on circural lists.
#
# (This is also used to explore if we should use package as part of
# the struct name.)
#
# This directly corresponds to https://pkg.go.dev/container/ring
# (src/container/ring/ring.go).

if [ -n "${CONTAINER_RING_MOD:-}" ]; then return 0; fi
readonly CONTAINER_RING_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${CONTAINER_RING_MOD}/../lang/p.sh
. ${CONTAINER_RING_MOD}/../util/p.sh


# ----------
# Functions.

function container_Ring() {
        # Construct a ring.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r n="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        ! is_gt $ctx "${n}" 0 && return $EC

        local r
        r=$(make_ $ctx "$FUNCNAME" \
                  "value" "$NULL" \
                  "_next" "$NULL" \
                  "_prev" "$NULL")
        local p="${r}"

        local i
        for (( i=1; i<${n}; i++ )); do
                local c
                c=$(make_ $ctx "$FUNCNAME" \
                          "value" "$NULL" \
                          "_next" "$NULL" \
                          "_prev" "$p")
                $p $ctx _next "$c"
                p="$c"
        done
        $p $ctx _next "$r"
        $r $ctx _prev "$p"

        echo "$r"
}

function container_Ring_len() {
        # Return length of the ring.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r r="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local n=0

        # This can happen only if the function is explicitly invoked
        # (and not invoked like a method).
        if [ "$r" = "$NULL" ]; then
                echo "${n}"
                return 0
        fi

        local c="$r"
        while :; do
                n=$(( ${n} + 1 ))
                c=$($c $ctx _next)
                [ "$c" = "$r" ] && break
        done
        echo "${n}"
}

function container_Ring_init() {
        # Return the next ring element.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r r="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $r $ctx _next "$r"
        $r $ctx _prev "$r"
        echo "$r"
}

function container_Ring_next() {
        # Return the next ring element.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r r="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        if is_null $ctx "$($r _next)"; then
                container_Ring_init $ctx "$r" > /dev/null
        fi

        echo "$($r $ctx _next)"
}

function container_Ring_prev() {
        # Return the previous ring element.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r r="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        if is_null $ctx "$($r _prev)"; then
                container_Ring_init $ctx "$r" > /dev/null
        fi

        echo "$($r $ctx _prev)"
}

function container_Ring_do() {
        # Call the given function on each element of the ring.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r r="${1}"
        local -r f="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        if [ "$r" != "$NULL" ]; then
                "${f}" $ctx "$($r value)"
                local p=$($r $ctx _next)
                while [ "$p" != "$r" ]; do
                        "${f}" $ctx "$($p value)"
                        p=$($p $ctx _next)
                done
        fi
}

function container_Ring_link() {
        # Connect ring r with ring s.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r r="${1}"
        local -r s="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local n
        n=$($r $ctx _next)
        if ! is_null $ctx "$s"; then
                local p
                p=$($s $ctx _prev)
                $r $ctx _next "$s"
                $s $ctx _prev "$r"
                $n $ctx _prev "$p"
                $p $ctx _next "$n"
        fi
        echo "$n"
}

function container_Ring_move() {
        # Move n % len(r) elements backward or forward.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local r="${1}"
        local n="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        if is_null $ctx "$($r _next)"; then
                container_Ring_init $ctx "$r" > /dev/null
        fi

        if [ ${n} -lt 0 ]; then
                for (( ; n<0; n++ )); do
                        r=$($r $ctx _prev)
                done
        elif [ ${n} -gt 0 ]; then
                for (( ; n>0; n-- )); do
                        r=$($r $ctx _next)
                done
        fi

        echo "$r"
}

function container_Ring_unlink() {
        # Unlike elements.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local r="${1}"
        local n="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ ${n} -lt 0 ] && return 0

        local t
        t=$(container_Ring_move $ctx "$r" "$(( ${n} + 1 ))")
        container_Ring_link $ctx "$r" "$t"
}
