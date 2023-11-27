#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# Support for parsing command line flags.

if [ -n "${FLAGS_MOD:-}" ]; then return 0; fi
readonly FLAGS_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${FLAGS_MOD}/map.sh
. ${FLAGS_MOD}/strings.sh


# ----------
# Functions.

function Args() {
        # Data for keeping map of argument names and values.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        make_ $ctx "${FUNCNAME}"
}

function Flag() {
        # Command line flag.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r name="${1}"
        local -r type="${2}"
        local -r doc="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ -z "${name}" ] && return $EC
        # TODO: check name no white chars.
        [ -z "${type}" ] && return $EC
        [ -z "${doc}" ] && return $EC

        [ "${type}" = "${INT}" -o \
                    "${type}" = "${BOOL}" -o \
                    "${type}" = "${FLOAT}" -o \
                    "${type}" = "${STRING}" ] || \
                { ctx_w $ctx "unknown type ${type}"; return $EC; }

        make_ $ctx \
              "${FUNCNAME}" \
              "name" "${name}" \
              "type" "${type}" \
              "doc" "${doc}"
}

function Flags() {
        # Command line flags.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r doc="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${doc}" ] && return $EC

        make_ $ctx \
              "${FUNCNAME}" \
              "doc" "${doc}" \
              "map" "$(Map)"
}

function Flags_add() {
        # Add a flag.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r flags="${1}"
        local -r flag="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        $($flags $ctx map) $ctx put "$($flag name)" "${flag}"
}

function Flags_help() {
        # Print help message.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r flags="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        echo "$($flags $ctx doc)"

        local -r map=$($flags $ctx map)
        local -r keys=$($map $ctx keys)
        local i
        for (( i=0; i<$($keys $ctx len); i++ )); do
                local name=$($keys $ctx get "${i}")
                local flag=$($map $ctx get "${name}")
                echo "  --${name} ($($flag $ctx type)) - $($flag $ctx doc)"
        done
}

function Flags_parse() {
        # Parse command line flags.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 2 ] && { ctx_wn $ctx; return $EC; }
        local -r flags="${1}"
        local -r args="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        # Decided not to force use of Args as the only accepted type.
        #! is_instanceof $ctx "${args}" Args && \
                #{ ctx_w $ctx "incorrect args"; return $EC; }

        local -r map=$($flags $ctx map)
        local -r keys=$($map $ctx keys)
        local i
        for (( i=0; i<$($keys $ctx len); i++ )); do
                local name=$($keys $ctx get "${i}")
                local flag=$($map $ctx get "${name}")
                local val=$(unsafe_zero $ctx "$($flag type)")
                unsafe_set_fld $ctx "$args" "${name}" "${val}"
        done

        _flags_parse $ctx "${flags}" "${args}" "$@"
}

function Flags_to_string() {
        # Print flags in human readable format.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r flags="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        $($flags $ctx map) $ctx to_string
}

function _flags_parse_to_map() {
        # Parse flags to a map.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 2 ] && { ctx_wn $ctx; return $EC; }
        local -r omap="${1}"
        local -r flags="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        ! is_instanceof $ctx "${omap}" Map && return $EC
        ! is_instanceof $ctx "${flags}" Flags && return $EC

        local a=( "$@" )

        local -r map=$($flags $ctx map)

        local -i i
        for (( i=0; i<$#; )); do
                local arg="${a[$i]}"
                if [[ "${arg}" != --* ]]; then
                        ctx_w $ctx "Argument '${arg}' does not start with '--'."
                        return $EC
                fi
                local name=$(strings_remove_prefix $ctx "${arg}" "--")
                name=${name//"-"/"_"}

                local flag
                flag=$($map $ctx get "${name}")
                if is_null $ctx "${flag}"; then
                        ctx_w $ctx "Flag '${name}' does not exit."
                        return $EC
                fi
                local type=$($flag $ctx type)

                i=$(( $i + 1 ))
                local val="${a[$i]}"
                # For boolean flags set the default value to true (if
                # not value provided).
                if [[ "${val}" = --* || ${i} -ge $# && "${type}" = "${BOOL}" ]]; then
                        $omap $ctx put "${name}" "true"
                else
                        local func="is_${type}"
                        if ! is_function $ctx "${func}"; then
                                ctx_w $ctx "Invalid type ${type}."
                                return $EC
                        fi

                        if ! ${func} "${val}"; then
                                ctx_w $ctx "Value ${val} cannot be parsed to ${type}."
                                return $EC
                        fi

                        $omap $ctx put "${name}" "${val}"
                        i=$(( $i + 1 ))
                fi
        done

        return 0
}

function _flags_parse() {
        # Parse flags.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -lt 2 ] && { ctx_wn $ctx; return $EC; }
        local -r flags="${1}"
        local -r args="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        ! is_object $ctx "${args}" && { ctx_w $ctx "not an object"; return $EC; }

        local -r omap=$(Map $ctx)
        _flags_parse_to_map $ctx "${omap}" "${flags}" "$@" || \
                { ctx_w $ctx "cannot parse to map"; return $EC; }

        local keys
        keys=$($omap $ctx keys)

        local -i i
        for (( i=0; i < $($keys $ctx len); i++ )); do
                local key
                key=$($keys $ctx get "${i}")
                $args $ctx "${key}" "$($omap $ctx get ${key})" || \
                        { ctx_w $ctx "flag '${key}' does not exit"; return $EC; }
        done

        return 0
}
