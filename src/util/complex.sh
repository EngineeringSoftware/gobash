#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Complex number functions.

if [ -n "${COMPLEX_MOD:-}" ]; then return 0; fi
readonly COMPLEX_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${COMPLEX_MOD}/../lang/p.sh


# ----------
# Functions.

function Complex() {
        # Complex numbers.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r real="${1}"
        local -r imag="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "real" "${real}" \
              "imag" "${imag}"
}

function Complex_to_string() {
        # Return string representation of this complex number.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r c="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        echo "( $($c $ctx real) + $($c $ctx imag)i )"
}

function Complex_plus() {
        # Return a new number that is a sum of two numbers.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r c="${1}"
        local -r c2="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local -r real=$(bc -l <<< "$($c real) + $($c2 real)" )
        local -r imag=$(bc -l <<< "$($c imag) + $($c2 imag)" )

        local -r res=$(Complex $ctx "${real}" "${imag}")
        echo "${res}"
}

function Complex_minus() {
        # Return a new number that is a difference.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r c="${1}"
        local -r c2="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local -r real=$(bc -l <<< "$($c $ctx real) - $($c2 $ctx real)")
        local -r imag=$(bc -l <<< "$($c $ctx imag) - $($c2 $ctx imag)")

        local -r res=$(Complex $ctx "${real}" "${imag}")
        echo "${res}"
}

function Complex_times() {
        # Return a new number whose value is (c * c2)
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r c="${1}"
        local -r c2="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local -r real=$(bc -l <<< "$($c $ctx real) * $($c2 $ctx real) - $($c $ctx imag) * $($c2 $ctx imag)" )
        local -r imag=$(bc -l <<< "$($c $ctx real) * $($c2 $ctx real) + $($c $ctx imag) * $($c2 $ctx imag)" )

        local -r res=$(Complex $ctx "${real}" "${imag}")
        echo "${res}"
}

function Complex_scale() {
        # Return a new number whose value is (c * alpha)
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r c="${1}"
        local -r alpha="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        local -r real=$(bc -l <<< "$($c $ctx real) * ${alpha}")
        local -r imag=$(bc -l <<< "$($c $ctx imag) * ${alpha}")

        local -r res=$(Complex $ctx "${real}" "${imag}")
        echo "${res}"
}

function Complex_conjugate() {
        # Return a new number whose value is the conjugate of c.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r c="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        local -r res=$(Complex $ctx "$($c $ctx real)" -"$($c $ctx imag)")
        echo "${res}"
}

function Complex_eq() {
        # Return true if the given numbers are equal.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r c="${1}"
        local -r c2="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        ! is_set "$c2" && return $FALSE
        ! is_instanceof "$c2" Complex && return $FALSE

        [ "$($c $ctx real)" = "$($c2 $ctx real)" -a "$($c $ctx imag)" = "$($c2 $ctx imag)" ]
}
